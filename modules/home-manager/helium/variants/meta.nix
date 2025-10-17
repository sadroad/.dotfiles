lib: rec {
  chromium = {
    pname = "chromium";
    meta = {
      description = "Open source web browser from Google";
      longDescription = ''
        Chromium is an open source web browser from Google that aims to build a
        safer, faster, and more stable way for all Internet users to experience
        the web. It has a minimalist user interface and provides the vast majority
        of source code for Google Chrome (which has some additional features).
      '';
      homepage = "https://www.chromium.org/";
      license = lib.licenses.bsd3;
      mainProgram = "chromium";
      maintainers = with lib.maintainers; [
        networkexception
        emilylange
      ];
    };
  };
  helium = {
    pname = "helium";
    meta = {
      description = "Private, fast, and honest web browser based on Chromium";
      homepage = "https://helium.computer/";
      license = lib.licenses.gpl3Only;
      mainProgram = "helium";
      maintainers = with lib.maintainers; [
        asterismono
      ];
    };
  };
}
