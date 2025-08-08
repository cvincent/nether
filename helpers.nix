{ lib }:
{
  # TODO: Extract all of mkFeature into its own module
  nixosModule =
    { options, ... }:
    {
      home-manager.extraSpecialArgs.osOptions = options;
    };

  helpers = rec {
    getSoftwareNamespaces =
      feature: includeToplevel:
      # Feature attrs not included in the list below are assumed to be
      # namespaced attrsets of software definitions for this feature
      feature
      |> lib.attrsets.filterAttrs (
        softwareNamespace: _:
        !(lib.lists.elem softwareNamespace (
          (
            [
              "description"
              "options"
              "nixos"
              "hm"
            ]
            ++ lib.optional (!includeToplevel) "toplevel"
          )
        ))
      );

    mkSoftwareOptions =
      {
        pkgs,
        options,
        softwareName,
        softwareDef ? { },
      }:
      let
        # Inferring the options by precedence:
        # - If package is explicitly defined, use it; can be null to skip
        #   generating a package option
        # - If the name is in nether.software, pull its options in, but override
        #   enable to default to enableDefault (default true)
        # - If the name is in pkgs, use that package
        # - Otherwise, only an enable option is defined, unless enableDefault is
        #   null

        enableDefault = if softwareDef ? enableDefault then softwareDef.enableDefault else true;

        defaultPackage =
          if softwareDef ? package then
            softwareDef.package
          else if options ? nether.software.${softwareName} then
            "mkSoftwareModule"
          else if pkgs ? ${softwareName} then
            pkgs.${softwareName}
          else
            "custom";

        startingOpts =
          if defaultPackage == "mkSoftwareModule" then options.nether.software.${softwareName} else { };

        description =
          if defaultPackage == "mkSoftwareModule" then
            softwareDef.description or options.nether.software.${softwareName}.enable.description
              or softwareName
          else
            softwareDef.description or defaultPackage.meta.description or softwareName;

        enableOpt.enable = lib.mkOption {
          type = lib.types.bool;
          default = enableDefault;
          inherit description;
        };

        packageOpt =
          if lib.isDerivation defaultPackage then
            {
              package = lib.mkOption {
                type = lib.types.package;
                default = defaultPackage;
              };
            }
          else
            { };
      in
      (
        startingOpts
        // (lib.optionalAttrs (enableDefault != null) enableOpt)
        // packageOpt
        // (softwareDef.options or { })
      );

    # TODO: This logic is repeated
    filterSoftwareDefs =
      softwareDefs:
      lib.filterAttrs (
        softwareName: _:
        !lib.elem softwareName [
          "description"
          "options"
          "nixos"
          "hm"
        ]
      ) softwareDefs;

    softwareNamespaceEnable =
      thisConfig: softwareNamespace:
      if softwareNamespace == "toplevel" then true else thisConfig."${softwareNamespace}".enable;

    softwareConfig =
      thisConfig: softwareNamespace: softwareName:
      if softwareNamespace == "toplevel" then
        thisConfig."${softwareName}"
      else
        thisConfig."${softwareNamespace}"."${softwareName}";

    softwareEnable =
      thisConfig: softwareNamespace: softwareName:
      if softwareNamespace == "toplevel" then
        thisConfig."${softwareName}".enable
      else
        thisConfig."${softwareNamespace}".enable
        && thisConfig."${softwareNamespace}"."${softwareName}".enable;

    mkFeature =
      featureName: featureDef:
      {
        moduleWithSystem,
        helpers,
        ...
      }:
      {
        flake.nixosModules."${featureName}" = moduleWithSystem (
          systemArgs@{
            pkgs,
            pkgInputs,
            inputs',
            self',
            system,
          }:
          nixosModuleArgs@{ options, config, ... }:
          let
            thisConfig = config.nether."${featureName}";

            featureDefFn = if builtins.isFunction featureDef then featureDef else (_: featureDef);

            feature = (
              featureDefFn (
                systemArgs
                // nixosModuleArgs
                // {
                  "${featureName}" = thisConfig;
                  inherit (config) nether;
                  inherit helpers;
                }
              )
            );

            softwareNamespaces = getSoftwareNamespaces feature false;
            softwareNamespacesWithToplevel = getSoftwareNamespaces feature true;

            enableOption = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = feature.description;
              };
            };

            softwareNamespaceOptions =
              softwareNamespaces
              |> lib.mapAttrs (
                softwareNamespace: softwareDefs:
                {
                  # Each software namespace gets its own enable option,
                  # default true
                  enable = lib.mkOption {
                    type = lib.types.bool;
                    description = (softwareDefs.description or "${featureName} ${softwareNamespace}");
                    default = true;
                  };
                }
                // (
                  (
                    softwareDefs
                    |> filterSoftwareDefs
                    |> lib.mapAttrs (
                      softwareName: softwareDef:
                      mkSoftwareOptions {
                        inherit
                          pkgs
                          options
                          softwareName
                          softwareDef
                          ;
                      }
                    )
                  )
                  // (softwareDefs.options or { })
                )
              );

            softwareToplevelOptions =
              (
                (feature.toplevel or { })
                |> filterSoftwareDefs
                |> lib.mapAttrs (
                  softwareName: softwareDef:
                  mkSoftwareOptions {
                    inherit
                      pkgs
                      options
                      softwareName
                      softwareDef
                      ;
                  }
                )
              )
              // (feature.toplevel.options or { });

            toplevelOptions = feature.options or { };

            featureOptions =
              enableOption
              |> lib.recursiveUpdate softwareNamespaceOptions
              |> lib.recursiveUpdate softwareToplevelOptions
              |> lib.recursiveUpdate toplevelOptions;
          in
          {
            options.nether."${featureName}" = featureOptions;

            config = (lib.mkIf thisConfig.enable) (
              lib.mkMerge (
                [ ]
                ++ (
                  # For each software namespace, and each software definition
                  # within them, if it refers to a nether.software module, pass
                  # our feature options through to the software module.
                  softwareNamespacesWithToplevel
                  |> lib.mapAttrsToList (
                    softwareNamespace: softwareDefs: {
                      nether.software = lib.mkIf (softwareNamespaceEnable thisConfig softwareNamespace) (
                        softwareDefs
                        |> filterSoftwareDefs
                        |> lib.filterAttrs (softwareName: _: options ? nether.software."${softwareName}")
                        |> lib.mapAttrs (
                          softwareName: _:
                          (softwareConfig thisConfig softwareNamespace softwareName)
                          |> lib.filterAttrs (
                            configName: _: lib.elem configName (lib.attrNames options.nether.software."${softwareName}")
                          )
                        )
                      );
                    }
                  )
                )
                ++ (
                  # Include any nixos configs from enabled software definitions
                  softwareNamespacesWithToplevel
                  |> lib.attrsets.mapAttrsToList (
                    softwareNamespace: softwareDefs:
                    softwareDefs
                    |> filterSoftwareDefs
                    |> lib.attrsets.mapAttrsToList (
                      softwareName: softwareDef:
                      (lib.mkIf (softwareEnable thisConfig softwareNamespace softwareName) (
                        (softwareDef.nixos or { })
                        |> lib.recursiveUpdate (
                          # Software defs can use a `config` attr to set
                          # software options, as a shortcut compared to doing it
                          # from just `nixos`
                          if softwareNamespace == "toplevel" then
                            { nether."${featureName}"."${softwareName}" = (softwareDef.config or { }); }
                          else
                            { nether."${featureName}"."${softwareNamespace}"."${softwareName}" = (softwareDef.config or { }); }
                        )
                      ))
                    )
                  )
                  |> lib.flatten
                )
                ++ (
                  # Include any nixos configs from enabled software namespaces
                  softwareNamespacesWithToplevel
                  |> lib.mapAttrsToList (
                    softwareNamespace: softwareDefs:
                    (lib.mkIf (softwareNamespaceEnable thisConfig softwareNamespace) (softwareDefs.nixos or { }))
                  )
                )
                ++ [ (feature.nixos or { }) ]
              )
            );
          }
        );

        flake.homeModules."${featureName}" = moduleWithSystem (
          systemArgs@{
            pkgs,
            pkgInputs,
            inputs',
            self',
            system,
          }:
          homeModuleArgs@{
            osConfig,
            osOptions,
            helpers,
            ...
          }:
          let
            thisConfig = osConfig.nether."${featureName}";

            featureDefFn = if builtins.isFunction featureDef then featureDef else (_: featureDef);

            feature = featureDefFn (
              systemArgs
              // homeModuleArgs
              // {
                config = osConfig;
                options = osOptions;
                "${featureName}" = thisConfig;
                inherit (osConfig) nether;
                inherit helpers;
              }
            );

            softwareNamespacesWithToplevel = getSoftwareNamespaces feature true;
          in
          {
            config = (lib.mkIf thisConfig.enable) (
              lib.mkMerge (
                [ ]
                ++ (
                  # For each software namespace, and each software definition
                  # within them, if it's not a nether.software module, but it
                  # has a package defined, add the it to home.packages.
                  softwareNamespacesWithToplevel
                  |> lib.mapAttrsToList (
                    softwareNamespace: softwareDefs: {
                      home.packages = lib.optionals (softwareNamespaceEnable thisConfig softwareNamespace) (
                        softwareDefs
                        |> filterSoftwareDefs
                        |> lib.filterAttrs (
                          softwareName: _:
                          !(osOptions ? nether.software."${softwareName}")
                          && ((softwareConfig thisConfig softwareNamespace softwareName) ? package)
                        )
                        |> lib.mapAttrsToList (
                          softwareName: _:
                          lib.optional (softwareEnable thisConfig softwareNamespace softwareName)
                            (softwareConfig thisConfig softwareNamespace softwareName).package
                        )
                        |> lib.flatten
                      );
                    }
                  )
                )
                ++ (
                  # Include any hm configs from enabled software definitions
                  softwareNamespacesWithToplevel
                  |> lib.attrsets.mapAttrsToList (
                    softwareNamespace: softwareDefs:
                    softwareDefs
                    |> filterSoftwareDefs
                    |> lib.attrsets.mapAttrsToList (
                      softwareName: softwareDef:
                      lib.mkIf (
                        (softwareNamespaceEnable thisConfig softwareNamespace)
                        && (softwareEnable thisConfig softwareNamespace softwareName)
                      ) (softwareDef.hm or { })
                    )
                  )
                  |> lib.flatten
                )
                ++ (
                  # Include any hm configs from enabled software namespaces
                  softwareNamespacesWithToplevel
                  |> lib.mapAttrsToList (
                    softwareNamespace: softwareDefs:
                    lib.mkIf (softwareNamespaceEnable thisConfig softwareNamespace) (softwareDefs.hm or { })
                  )
                )
                ++ [ (feature.hm or { }) ]
              )
            );
          }
        );
      };

    mkModuleDir =
      dir:
      {
        moduleArgs,
        applyArgs ? { },
        exclude ? [ ],
        additionalImports ? [ ],
        camelize ? false,
      }:
      let
        inherit (moduleArgs) flake-parts-lib;
        excluded = exclude ++ [ "default.nix" ];
      in
      {
        imports =
          (
            dir
            |> builtins.readDir
            |> builtins.attrNames
            |> builtins.filter (f: !builtins.elem f excluded)
            |> builtins.map (
              module:
              flake-parts-lib.importApply (dir + "/${module}") (
                applyArgs
                // {
                  name = module |> lib.removeSuffix ".nix" |> (str: if camelize then lib.toCamelCase str else str);
                }
              )
            )
          )
          ++ additionalImports;
      };

    mkSoftware =
      softwareName: softwareDef:
      {
        moduleWithSystem,
        inputs,
        ...
      }:
      {
        flake.nixosModules."software-${softwareName}" = moduleWithSystem (
          systemArgs@{
            pkgs,
            pkgInputs,
            inputs',
            self',
            system,
          }:
          nixosModuleArgs@{ config, helpers, ... }:
          let
            thisConfig = config.nether.software."${softwareName}";

            softwareDefFn = if builtins.isFunction softwareDef then softwareDef else (_: softwareDef);

            software = (
              softwareDefFn (
                systemArgs
                // nixosModuleArgs
                // {
                  "${softwareName}" = thisConfig;
                  inherit (config) nether;
                  inherit inputs helpers;
                }
              )
            );
          in
          {
            options = {
              nether.software."${softwareName}" =
                let
                  package =
                    if software ? package && software.package != null then
                      software.package
                    else if pkgs ? "${softwareName}" && (!(software ? package) || software.package != null) then
                      pkgs.${softwareName}
                    else
                      null;
                in
                {
                  enable = lib.mkEnableOption package.meta.description or softwareName;
                }
                // (
                  if package != null then
                    {
                      package = lib.mkOption {
                        type = lib.types.package;
                        default = software.package;
                      };
                    }
                  else
                    { }
                )
                // (software.options or { });
            };

            config = (lib.mkIf thisConfig.enable) (software.nixos or { });
          }
        );

        flake.homeModules."software-${softwareName}" = moduleWithSystem (
          systemArgs@{
            pkgs,
            pkgInputs,
            inputs',
            self',
            system,
          }:
          homeModuleArgs@{ osConfig, helpers, ... }:
          let
            thisConfig = osConfig.nether.software."${softwareName}";

            softwareDefFn = if builtins.isFunction softwareDef then softwareDef else (_: softwareDef);

            software = (
              softwareDefFn (
                systemArgs
                // homeModuleArgs
                // {
                  config = osConfig;
                  "${softwareName}" = thisConfig;
                  inherit (osConfig) nether;
                  inherit inputs helpers;
                }
              )
            );
          in
          {
            config = (lib.mkIf thisConfig.enable) (software.hm or { });
          }
        );
      };

    mkSoftwareChoice =
      {
        name,
        namespace,
        thisConfig,
        enableDefault ? false,
      }:
      softwareDefs:
      let
        featureName = name;
        softwareNamespace = namespace;
        choices = softwareDefs |> filterSoftwareDefs |> lib.attrNames;
      in
      {
        "${softwareNamespace}" =
          softwareDefs
          |> filterSoftwareDefs
          |> lib.mapAttrs (_: softwareDef: lib.recursiveUpdate softwareDef { inherit enableDefault; })
          |> lib.recursiveUpdate {
            options = (
              {
                default = {
                  which = lib.mkOption {
                    type = lib.types.enum ([ null ] ++ choices);
                    default = null;
                  };

                  package = lib.mkOption { type = lib.types.package; };
                  path = lib.mkOption { type = lib.types.str; };
                };
              }
              |> (lib.recursiveUpdate (softwareDefs.options or { }))
            );

            nixos = softwareDefs.nixos or { };
            hm = softwareDefs.hm or { };
          };

        nixos =
          let
            forceEnableDefault = lib.listToAttrs (
              map (softwareName: {
                name = softwareName;
                value = {
                  enable = lib.mkIf (
                    if softwareNamespace == "toplevel" then
                      thisConfig.default.which == softwareName
                    else
                      thisConfig.${softwareNamespace}.default.which == softwareName
                  ) (lib.mkForce true);
                };
              }) choices
            );
          in
          if softwareNamespace == "toplevel" then
            {
              nether."${featureName}" = (
                {
                  default = lib.mkIf (thisConfig.default.which != null) {
                    package = lib.mkForce thisConfig."${thisConfig.default.which}".package;
                    path = lib.mkForce "${thisConfig.default.package}/bin/${thisConfig.default.which}";
                  };
                }
                // forceEnableDefault
              );
            }
          else
            {
              nether."${featureName}"."${softwareNamespace}" = (
                {
                  default = lib.mkIf (thisConfig.${softwareNamespace}.default.which != null) {
                    package =
                      lib.mkForce
                        thisConfig."${softwareNamespace}"."${thisConfig."${softwareNamespace}".default.which}".package;
                    path = lib.mkForce "${thisConfig."${softwareNamespace}".default.package}/bin/${
                      thisConfig."${softwareNamespace}".default.which
                    }";
                  };
                }
                // forceEnableDefault
              );
            };
      };
  };

  flakeModuleHelpers =
    { lib, ... }:
    {
      _module.args.helpers = rec {
        pkgOpt = (
          pkg: default: description: {
            enable = lib.mkOption {
              type = lib.types.bool;
              inherit description default;
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = pkg;
            };
          }
        );

        pkgOptPkg = (pkgOpt: lib.optional pkgOpt.enable pkgOpt.package);

        boolOpt =
          default: description:
          (lib.mkOption {
            type = lib.types.bool;
            inherit description default;
          });

        # Create a feature module package option that delegates to a software
        # module
        delegateToSoftware = (
          options: name: defaultEnable:
          let
            softwareOpts = options.nether.software."${name}";
          in
          (pkgOpt softwareOpts.package.default defaultEnable softwareOpts.enable.description)
        );
      };
    };

  homeModuleHelpers =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      _module.args.helpers = {
        directSymlink = (
          path:
          [
            "${osConfig.nether.homeDirectory}/dotfiles/"
            (
              path
              |> toString
              |> builtins.match "\/nix\/store\/[a-z0-9]+-source\/(.+)"
              |> lib.strings.concatStrings
            )
          ]
          |> lib.strings.concatStrings
          |> config.lib.file.mkOutOfStoreSymlink
        );
      };
    };
}
