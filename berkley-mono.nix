{
  lib,
  stdenvNoCC,
  variant ? "ligaturesoff-0variant1-7-variant0",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "berkley-mono";
  version = "1";

  src = null;

  meta = {
    description = "Berkley Mono Typeface";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
