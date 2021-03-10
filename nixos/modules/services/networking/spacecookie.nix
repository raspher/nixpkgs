{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.spacecookie;

  spacecookieConfig = {
    inherit (cfg) port;
  } // cfg.settings;

  format = pkgs.formats.json {};

  configFile = format.generate "spacecookie.json" spacecookieConfig;

in {
  imports = [
    (mkRenamedOptionModule [ "services" "spacecookie" "root" ] [ "services" "spacecookie" "settings" "root" ])
    (mkRenamedOptionModule [ "services" "spacecookie" "hostname" ] [ "services" "spacecookie" "settings" "hostname" ])
  ];

  options = {

    services.spacecookie = {

      enable = mkEnableOption "spacecookie";

      package = mkOption {
        type = types.package;
        default = pkgs.haskellPackages.spacecookie;
        example = literalExample ''
          pkgs.haskell.lib.justStaticExecutables pkgs.haskellPackages.spacecookie
        '';
        description = ''
          The spacecookie derivation to use. This can be used to
          override the used package or to use another version.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to open the necessary port in the firewall for spacecookie.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 70;
        description = ''
          Port the gopher service should be exposed on.
        '';
      };

      address = mkOption {
        type = types.str;
        default = "[::]";
        description = ''
          Address to listen on. Must be in the
          <literal>ListenStream=</literal> syntax of
          <link xlink:href="https://www.freedesktop.org/software/systemd/man/systemd.socket.html">systemd.socket(5)</link>.
        '';
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = format.type;

          options.hostname = mkOption {
            type = types.str;
            default = "localhost";
            description = ''
              The hostname the service is reachable via. Clients
              will use this hostname for further requests after
              loading the initial gopher menu.
            '';
          };

          options.root = mkOption {
            type = types.path;
            default = "/srv/gopher";
            description = ''
              The directory spacecookie should serve via gopher.
              Files in there need to be world-readable since
              the spacecookie service file sets
              <literal>DynamicUser=true</literal>.
            '';
          };
        };

        description = ''
          Settings for spacecookie. The settings set here are
          directly translated to the spacecookie JSON config
          file. See the
          <link xlink:href="https://github.com/sternenseemann/spacecookie/#configuration">spacecookie documentation</link>
          for explanations of all options.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? user);
        message = ''
          spacecookie is started as a normal user, so the setuid
          feature doesn't work. If you want to run spacecookie as
          a specific user, set:
          systemd.services.spacecookie.serviceConfig = {
            DynamicUser = false;
            User = "youruser";
            Group = "yourgroup";
          }
        '';
      }
      {
        assertion = !(cfg.settings ? port);
        message = ''
          The NixOS spacecookie module uses socket activation,
          so the port option has no effect. Use the port option
          in services.spacecookie instead.
        '';
      }
    ];

    systemd.sockets.spacecookie = {
      description = "Socket for the Spacecookie Gopher Server";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "${cfg.address}:${toString cfg.port}" ];
      socketConfig = {
        BindIPv6Only = "both";
      };
    };

    systemd.services.spacecookie = {
      description = "Spacecookie Gopher Server";
      wantedBy = [ "multi-user.target" ];
      requires = [ "spacecookie.socket" ];

      serviceConfig = {
        Type = "notify";
        ExecStart = "${lib.getBin cfg.package}/bin/spacecookie ${configFile}";
        FileDescriptorStoreMax = 1;

        DynamicUser = true;

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;

        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictRealtime = true;

        # AF_UNIX for communication with systemd
        # AF_INET replaced by BindIPv6Only=both
        RestrictAddressFamilies = "AF_UNIX AF_INET6";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
