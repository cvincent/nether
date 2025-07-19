{ config, pkgs, ... }:
{
  home.packages = [ pkgs.davmail ];

  systemd.user.services.davmail = {
    Unit.Description = "DavMail POP/IMAP/SMTP Exchange Gateway";

    Install.WantedBy = [ "default.target" ];

    Service = {
      ExecStart = "${pkgs.davmail}/bin/davmail ${config.home.homeDirectory}/.config/davmail/davmail.properties";
      Restart = "on-failure";
    };
  };

  home.file."./.config/davmail/davmail.properties".text = ''
    # NOTE: May need to change this to O365Interactive or other and run davmail as
    # a GUI to get the initial oauth tokens
    davmail.mode=O365Modern
    davmail.oauth.tokenFilePath=${config.home.homeDirectory}/.davmail-token.properties

    # Server
    davmail.server=true
    davmail.bindAddress=0.0.0.0
    davmail.imapPort=14333
    davmail.smtpPort=10255
    davmail.caldavPort=10800
    davmail.popPort=
    davmail.ldapPort=

    # Pretend to be the Outlook desktop client
    davmail.oauth.clientId=d3590ed6-52b3-4102-aeff-aad2292ab01c
    davmail.oauth.redirectUri=urn:ietf:wg:oauth:2.0:oob

    # Other config, defaults generated from GUI
    davmail.url=https://outlook.office365.com/EWS/Exchange.asmx
    davmail.ssl.keystoreType=
    davmail.ssl.keystorePass=
    davmail.proxyPassword=
    davmail.enableKerberos=false
    davmail.folderSizeLimit=
    davmail.forceActiveSyncUpdate=false
    davmail.imapAutoExpunge=true
    davmail.useSystemProxies=false
    davmail.proxyUser=
    davmail.ssl.nosecuresmtp=false
    davmail.caldavPastDelay=0
    davmail.ssl.keyPass=
    log4j.logger.httpclient.wire=WARN
    davmail.noProxyFor=
    davmail.popMarkReadOnRetr=false
    davmail.ssl.nosecureimap=false
    davmail.disableTrayActivitySwitch=false
    davmail.caldavAutoSchedule=true
    davmail.enableProxy=false
    davmail.proxyPort=
    davmail.smtpSaveInSent=true
    davmail.ssl.nosecurepop=false
    davmail.ssl.pkcs11Library=
    log4j.rootLogger=WARN
    davmail.ssl.keystoreFile=
    log4j.logger.davmail=DEBUG
    davmail.ssl.clientKeystoreType=
    davmail.clientSoTimeout=
    davmail.ssl.pkcs11Config=
    davmail.ssl.clientKeystorePass=
    davmail.sentKeepDelay=0
    davmail.ssl.nosecureldap=false
    davmail.imapAlwaysApproxMsgSize=false
    davmail.ssl.nosecurecaldav=false
    davmail.showStartupBanner=true
    log4j.logger.httpclient=WARN
    davmail.proxyHost=
    davmail.server.certificate.hash=
    davmail.disableGuiNotifications=false
    davmail.imapIdleDelay=
    davmail.allowRemote=false
    davmail.disableUpdateCheck=false
    davmail.enableKeepAlive=false
    davmail.ssl.clientKeystoreFile=
    davmail.logFilePath=
    davmail.carddavReadPhoto=true
    davmail.keepDelay=30
    davmail.caldavAlarmSound=
    davmail.oauth.tenantId=
    davmail.logFileSize=
    log4j.logger.org.apache.http.conn.ssl=WARN
    log4j.logger.org.apache.http=WARN
    davmail.defaultDomain=
    davmail.caldavEditNotifications=false
    log4j.logger.org.apache.http.wire=WARN
  '';
}
