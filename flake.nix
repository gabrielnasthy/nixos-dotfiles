{
  description = "DevShell for Rust projects with sccache, just, cargo tools, and direnv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          name = "rust-dev";
          buildInputs = with pkgs; [
            # Rust toolchain manager
            rustup

            # Build cache
            sccache

            # Task runner
            just

            # Cargo tools
            cargo-nextest
            cargo-udeps
            cargo-audit
            cargo-deny

            # Useful base tools
            pkg-config
            openssl
          ];

          RUSTC_WRAPPER = "sccache";
          SCCACHE_DIR = "${toString ./._sccache}";
          CARGO_HOME = "${toString ./._cargo}";
          RUSTUP_HOME = "${toString ./._rustup}";

          shellHook = ''
            # Initialize rustup with default toolchain if not present
            if ! command -v rustc >/dev/null 2>&1; then
              echo "Initializing rustup (stable + rustfmt + clippy)";
              rustup default stable || true
              rustup component add rustfmt clippy || true
            fi

            # Informative banner
            echo "[DevShell] RUSTC_WRAPPER=$RUSTC_WRAPPER | sccache dir: $SCCACHE_DIR"
          '';
        };
      }
    );
}
