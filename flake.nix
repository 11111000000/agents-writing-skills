{
  description = "Development shell and checks for agents-writing-skills";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f system (import nixpkgs { inherit system; }));
      toolset =
        pkgs:
        let
          nodejs = if pkgs ? nodejs_22 then pkgs.nodejs_22 else pkgs.nodejs;
          nixfmt =
            if pkgs ? nixfmt-tree then
              pkgs.nixfmt-tree
            else if pkgs ? nixfmt-rfc-style then
              pkgs.nixfmt-rfc-style
            else
              pkgs.nixfmt;
        in
        [
          pkgs.bash
          pkgs.bc
          pkgs.coreutils
          pkgs.findutils
          pkgs.gawk
          pkgs.git
          pkgs.gnugrep
          pkgs.gnused
          pkgs.jq
          pkgs.python3
          nodejs
          nixfmt
        ];
      repoRootSnippet = ''
        root="''${AGENTS_WRITING_SKILLS_ROOT:-}"
        if [ -z "$root" ]; then
          root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
        fi
        cd "$root"
      '';
      mkScript =
        pkgs: name: text:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = toolset pkgs;
          text = repoRootSnippet + text;
        };
    in
    {
      devShells = forAllSystems (
        system: pkgs: {
          default = pkgs.mkShell {
            packages = toolset pkgs;
            shellHook = ''
              export AGENTS_WRITING_SKILLS_ROOT="$PWD"
            '';
          };
        }
      );

      packages = forAllSystems (
        system: pkgs: {
          validate = mkScript pkgs "agents-writing-skills-validate" ''
            bash ./scripts/validate-skills.sh .
            bash ./scripts/validate-manifest.sh
          '';
          test-benchmark = mkScript pkgs "agents-writing-skills-test-benchmark" ''
            bash ./scripts/test-benchmark.sh
          '';
          build-site = mkScript pkgs "agents-writing-skills-build-site" ''
            bash ./scripts/build-site.sh "''${1:-public}"
          '';
          default = self.packages.${system}.validate;
        }
      );

      apps = forAllSystems (
        system: pkgs: {
          validate = {
            type = "app";
            program = "${self.packages.${system}.validate}/bin/agents-writing-skills-validate";
          };
          test-benchmark = {
            type = "app";
            program = "${self.packages.${system}.test-benchmark}/bin/agents-writing-skills-test-benchmark";
          };
          build-site = {
            type = "app";
            program = "${self.packages.${system}.build-site}/bin/agents-writing-skills-build-site";
          };
          default = self.apps.${system}.validate;
        }
      );

      checks = forAllSystems (
        system: pkgs: {
          validate =
            pkgs.runCommand "agents-writing-skills-check"
              {
                nativeBuildInputs = toolset pkgs;
                src = self;
              }
              ''
                cp -R "$src" source
                chmod -R u+w source
                cd source
                bash ./scripts/test-benchmark.sh
                bash ./scripts/validate-skills.sh .
                bash ./scripts/validate-manifest.sh
                touch "$out"
              '';
          site-build =
            let
              buildSite = self.apps.${system}.build-site.program;
            in
            pkgs.runCommand "agents-writing-skills-site-build"
              {
                nativeBuildInputs = toolset pkgs;
                src = self;
                inherit buildSite;
              }
              ''
                cp -R "$src" source
                chmod -R u+w source
                cd source
                "$buildSite" "$out-staging"
                if [[ ! -f "$out-staging/index.html" ]]; then
                  echo "site build did not produce index.html" >&2
                  exit 1
                fi
                if [[ ! -d "$out-staging/knowledge/01-Patterns" ]]; then
                  echo "knowledge base missing" >&2
                  exit 1
                fi
                mkdir -p "$out"
                cp -R "$out-staging"/* "$out/"
                touch "$out/.stamp"
              '';
        }
      );

      formatter = forAllSystems (
        system: pkgs:
        if pkgs ? nixfmt-tree then
          pkgs.nixfmt-tree
        else if pkgs ? nixfmt-rfc-style then
          pkgs.nixfmt-rfc-style
        else
          pkgs.nixfmt
      );
    };
}
