{
  config,
  lib,
  dream2nix,
  ...
}: let
  # pyproject = lib.importTOML (config.mkDerivation.src + /pyproject.toml);
in {
  imports = [
    dream2nix.modules.dream2nix.rust-cargo-lock
    dream2nix.modules.dream2nix.buildRustPackage
    # dream2nix.modules.dream2nix.rust-crane
    # dream2nix.modules.dream2nix.pip
    dream2nix.modules.dream2nix.flags
  ];

  deps = {
    nixpkgs,
    self,
    ...
  }: {
    stdenv = nixpkgs.stdenv;
    darwin = nixpkgs.darwin;
    openssl = nixpkgs.openssl;
    pkg-config = nixpkgs.pkg-config;
    # python = nixpkgs.python312;
    # rustPlatform = nixpkgs.rustPlatform;
    # cargo = nixpkgs.cargo;
    # rustc = nixpkgs.rustc;
  };

  flagsOffered = {
    pyarrow = "todo...";
  };

  flags = {
    pyarrow = lib.mkDefault false;
  };

  # inherit (pyproject.project) name version;
  name = "object-store-python";
  version = "0.1.10";

  mkDerivation = {
    src = ./.;
    buildInputs = [
      # config.deps.python
      # config.deps.cargo
      # config.deps.rustPlatform.cargoSetupHook
      # config.deps.rustc
      config.deps.openssl
      config.deps.pkg-config
    ]
    ++ lib.optionals (config.deps.stdenv.isDarwin) [
      config.deps.darwin.apple_sdk.frameworks.SystemConfiguration
    ];
  };

  # buildPythonPackage = {
  #   format = lib.mkForce "pyproject";
  #
  #   build-system = [
  #     config.deps.rustPlatform.maturinBuildHook
  #   ];
  # };

  # pip = {
  #   requirementsList =
  #     pyproject.build-system.requires
  #     or []
  #     # ++ pyproject.project.dependencies
  #     ++ lib.optionals (config.flags.pyarrow) pyproject.project.optional-dependencies.pyarrow;
  #   flattenDependencies = true;
  #   # object-store-python currently needs to build from main and requires rust
  #   # during locking. It provide asyncio support
  #   # nativeBuildInputs = [
  #   #   config.deps.cargo
  #   #   config.deps.rustPlatform.cargoSetupHook
  #   #   config.deps.rustc
  #   # ];
  #   # overrideAll.deps.python = lib.mkForce config.deps.python;
  #   overrides = {};
  # };
}
