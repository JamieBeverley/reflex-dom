{ mkDerivation, ghc, aeson, base, bifunctors, bimap, blaze-builder
, bytestring, constraints, containers, contravariant, data-default
, dependent-map, dependent-sum, dependent-sum-template, directory
, exception-transformers, ghcjs-dom, hlint, jsaddle, keycode, lens
, monad-control, mtl, primitive, ref-tf, reflex, semigroups, stdenv
, stm, template-haskell, temporary, text, these, transformers
, unix, zenc, hashable, chromium, process, jsaddle-warp
, linux-namespaces, iproute, network-uri, fontconfig
}:
let addGcTestDepends = drv: if (stdenv.system != "x86_64-linux" || stdenv.hostPlatform != stdenv.buildPlatform || (ghc.isGhcjs or false)) then drv else drv // {
      # The headless browser run as part of gc tests would hang/crash without this
      preCheck = ''
        export FONTCONFIG_PATH=${fontconfig.out}/etc/fonts
      '';
      testHaskellDepends = (drv.testHaskellDepends or []) ++ [ temporary jsaddle-warp process linux-namespaces ];
      testSystemDepends = (drv.testSystemDepends or []) ++ [ chromium iproute ];
    };
in mkDerivation (addGcTestDepends {
  pname = "reflex-dom-core";
  version = "0.4";
  src = ./.;
  libraryHaskellDepends = [
    aeson base bifunctors bimap blaze-builder bytestring constraints
    containers contravariant data-default dependent-map dependent-sum
    dependent-sum-template directory exception-transformers ghcjs-dom
    jsaddle keycode lens monad-control mtl primitive ref-tf
    reflex semigroups stm template-haskell text these transformers
    unix zenc network-uri
  ] ++ (if ghc.isGhcjs or false then [
    hashable
  ] else []);

  #TODO: Get hlint working for cross-compilation
  doCheck = stdenv.hostPlatform == stdenv.buildPlatform && !(ghc.isGhcjs or false);

  # The headless browser run as part of the tests will exit without this
  preBuild = ''
    export HOME="$PWD"
  '';

  # Show some output while running tests, so we might notice what's wrong
  testTarget = "--show-details=streaming";

  testHaskellDepends = [ base hlint ];
  description = "Functional Reactive Web Apps with Reflex";
  license = stdenv.lib.licenses.bsd3;
})
