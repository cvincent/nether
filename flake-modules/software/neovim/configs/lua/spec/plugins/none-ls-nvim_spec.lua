describe("none-ls.nvim integration", function()
  vim.opt.rtp:prepend("/home/cvincent/.local/share/nvim/lazy/none-ls.nvim")

  local integration = require("plugins/none-ls-nvim")

  local stringx = require("pl.stringx")
  local stub = require("luassert.stub")
  local mock = require("luassert.mock")

  it("extracts Boundary warnings", function()
    local fake_boundary_warnings = stringx.dedent([[
      warning: forbidden reference to Ecto.Association.NotLoaded
        (references from MyApp to Ecto are not allowed)
        lib/my_app/my_file.ex:1

      warning: forbidden reference to Ecto.Association.NotLoaded
        (references from MyApp to Ecto are not allowed)
        lib/my_app/my_file.ex:2

      warning: forbidden reference to Ecto.Association.NotLoaded
        (references from MyApp to Ecto are not allowed)
        lib/my_app/my_file.ex:3

      warning: Missing.Mod is not included in any boundary
        lib/my_app/my_file.ex:4
    ]])

    local fake_file_lines = {
      "asdf Ecto.Association.NotLoaded",
      "asdfasdf Association.NotLoaded",
      "asdfasdfasfd NotLoaded",
      "asdfasdfasfd Missing.Mod",
    }

    local readfile = stub(vim.fn, "readfile", function(path)
      if path:match("lib/my_app/my_file%.ex$") then
        return fake_file_lines
      end
    end)

    local diagnostics = {}
    local done = function(d) diagnostics = d end

    integration.exports.from_elixir_boundary_warnings()(
      { output = fake_boundary_warnings },
      done
    )

    assert.equal(4, #diagnostics)

    assert.match("forbidden", diagnostics[1].message)
    assert.match("references from MyApp", diagnostics[1].message)

    assert.equal(6, diagnostics[1].col)
    assert.equal(10, diagnostics[2].col)
    assert.equal(14, diagnostics[3].col)
    assert.equal(14, diagnostics[4].col)

    readfile:revert()
  end)

  it("extracts Dialyzer warnings", function()
    local fake_dialyzer_warnings = stringx.dedent([[
      lib/my_app_schemas/widget.ex:0:unknown_type
      Unknown type: MyAppSchemas.Account.t/0.
      ________________________________________________________________________________
      lib/my_app_web/live/widget_live/index.ex:29:9:call
      The function call will not succeed.

      MyApp.Widgets.new_widget!(any(), _attrs :: %{:access_token => _, :id => nil, :metadata => _, _ => _}) ::
        :ok
      def a() do
        :ok
      end

      breaks the contract
      (MyAppSchemas.User.t(), %{:access_token => String.t(), :metadata => map()}) ::
        MyAppSchemas.Widget.t()

      ________________________________________________________________________________
      lib/my_app/users.ex:6:invalid_contract
      The @spec for the function does not match the success typing of the function.

      Function:
      MyApp.Users.fetch_and_update/1

      Success typing:
      (%MyApp.UserScope{:user => nil | [map()] | %{atom() => _}, _ => _}) :: :ok

      But the spec is:
      (MyApp.UserScope.t()) :: [MyAppSchemas.Widget.t()]

      ________________________________________________________________________________
      done (warnings were emitted)
      Halting VM with exit status 2
    ]])

    local diagnostics = {}
    local done = function(d) diagnostics = d end

    integration.exports.from_multiline_pattern(
      "([^.]+%.exs?):(%d+):(%d+):(.-)________________________________________________________________________________\n",
      { "filename", "row", "col", "message" },
      {
        --- @param output string
        pre = function(output)
          local ok = true
          for file, line, err in output:gmatch("([^.\n]+%.exs?):(%d+):([^:\n]+)\n") do
            match = file .. ":" .. line .. ":" .. err
            if line == 0 then line = 1 end
            ok, output = pcall(string.gsub, output, match, file .. ":" .. line .. ":1:" .. err)
            if not ok then return "" end
          end
          return output
        end,
      }
    )({ output = fake_dialyzer_warnings, }, done)

    -- vim.print(diagnostics)
  end)
end)
