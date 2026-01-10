-- #! /usr/bin/env nix-shell
--[[
#! nix-shell -i 'imapfilter -c' -p 'lua.withPackages(ps: with ps; [ penlight cjson ])'
]]

-- Basic config
options.timeout = 120
options.subscribe = true
options.certificates = false
options.starttls = false

local file = require("pl.file")
local pretty = require("pl.pretty")
local tablex = require("pl.tablex")
local utils = require("pl.utils")
local cjson = require("cjson")

local account_name = "@account@";
if account_name:sub(1, 1) == "@" then
  account_name = "personal"
end

local mail_config_file_path = "@mailConfigFilePath@"
if mail_config_file_path:sub(1, 1) == "@" then
  mail_config_file_path = "/home/cvincent/.config/mail-config.json"
end

local mail_config = cjson.decode(file.read(mail_config_file_path))
local account_config = mail_config.accountConfigs[account_name]

local all_ref_names = tablex.keys(account_config.folders)
local filters_base_path = mail_config.filtersBasePath .. "/" .. account_name
local screened_out_folder = account_config.folders.screened_out.imapPath;
local spam_folder = account_config.folders.spam.imapPath;
local trash_folder = account_config.folders.trash.imapPath;
local unscreened_folder = account_config.folders.unscreened.imapPath;

local mark_read_ref_names = tablex.filter(all_ref_names, function(ref_name)
  return not tablex.find(account_config.totalCountFolders, ref_name)
end)

-- Read lines from the given file, creating it if it doesn't exist
local function lines_from(path)
  local exists = io.open(path, "r")

  if not exists then
    local directory = path:match("^(.*)[/\\]")
    os.execute(string.format('mkdir -p "%s"', directory))
    io.open(path, "w"):close()
  else
    exists:close()
  end

  return utils.readlines(path)
end

-- Filter functions
local filter_by_address = function(address)
  return account["Inbox"]:contain_from(address) + account[unscreened_folder]:contain_from(address)
end

-- For each IMAP folder, run its filters
-- TODO: Add more filtering besides just address...if needed...or rewrite this
-- whole setup with Rust lol.

tablex.foreachi(all_ref_names, function(ref_name)
  print("Processing " .. ref_name .. "...")

  local imap_path = account_config.folders[ref_name].imapPath
  local by_address = lines_from(filters_base_path .. "/" .. ref_name .. "/by_address")
  local results = {}

  for _k, address in ipairs(by_address) do
    print("Moving " .. address .. " to " .. ref_name .. "...")
    results = results + filter_by_address(address)
  end

  if next(results) then
    if tablex.find(mark_read_ref_names, ref_name) then
      results:mark_seen()
    end

    results:move_messages(account[imap_path])
  end
end)

-- Move everything still in Inbox to Unscreened
print("Moving remaining messages to Unscreened...")
account["Inbox"]:select_all():move_messages(account[unscreened_folder])

-- All messages in folders with null/unset notifyLevel get marked read
tablex.foreachi(mark_read_ref_names, function(ref_name)
  local imap_path = account_config.folders[ref_name].imapPath
  account[imap_path]:is_unseen():mark_seen()
end)

print("Deleting old Screened Out...")
account[screened_out_folder]:is_older(30):delete_messages()

print("Deleting old Spam...")
account[spam_folder]:is_older(30):delete_messages()

print("Deleting old Trash...")
account[trash_folder]:is_older(30):delete_messages()
