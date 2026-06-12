{ config, pkgs, ... }:
let
  myUser = "godfist";
  command = "bin/nbfc_service --config-file '/home/${myUser}/.config/nbfc.json'";

  nbfc = pkgs.stdenv.mkDerivation {
    name = "nbfc-linux";
    src = pkgs.fetchFromGitHub {
      owner = "nbfc-linux";
      repo = "nbfc-linux";
      rev = "8347986c2a0186ad6166ef2668ce85a6b2e300e3";
      hash = "sha256-NRkn4nl4vqRWSghSjXJqaGNPJkrScE4sPW2Bbc1U9OY=";
    };
    nativeBuildInputs = with pkgs; [ autoreconfHook pkg-config ];
    buildInputs = with pkgs; [ curl json_c lua5_3 libxml2 ];
    buildFlags = [ "PREFIX=$(out)" ];
    installPhase = ''
      mkdir -p $out/bin $out/share/nbfc/configs
      install -Dm755 src/nbfc_service $out/bin/nbfc_service
      install -Dm755 src/nbfc         $out/bin/nbfc
      install -Dm755 src/ec_probe     $out/bin/ec_probe
      cp -r share/nbfc/configs/. $out/share/nbfc/configs/
    '';
  };
in {
  environment.systemPackages = [ nbfc ];

  systemd.services.nbfc_service = {
    enable = true;
    description = "NoteBook FanControl service";
    serviceConfig.Type = "simple";
    path = [ pkgs.kmod ];
    script = "${nbfc}/${command}";
    wantedBy = [ "multi-user.target" ];
  };
}
