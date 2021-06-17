{ mkDerivation, stdenv, ghc, base 
}:
mkDerivation {
  pname = "pure-sync";
  version = "0.8.0.0";
  src = ./.;
  libraryHaskellDepends = [ base ];
  homepage = "github.com/grumply/pure-sync";
  license = stdenv.lib.licenses.bsd3;
}
