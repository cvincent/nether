{ pkgs, lib, ... }:

{
  # Force Slack to use XWayland, which fixes screensharing and missing window
  # on boot
  home.packages = [
    (pkgs.slack.overrideAttrs (oldAttrs: {
      fixupPhase = ''
        sed -i -e 's/,"WebRTCPipeWireCapturer"/,"LebRTCPipeWireCapturer"/' $out/lib/slack/resources/app.asar

        rm $out/bin/slack
        makeWrapper $out/lib/slack/slack $out/bin/slack \
        --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
        --suffix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]} \
        --unset WAYLAND_DISPLAY
      '';
    }))
  ];
}
