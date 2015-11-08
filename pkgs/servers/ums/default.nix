{ stdenv, fetchurl, makeWrapper, libzen, libmediainfo
, oraclejre7 ? null, oraclejre8 ? null, jre7 ? null, jre8 ? null
, useOracle ? false
, useJava7 ? false
}:

assert useOracle == true  && useJava7 == true   -> oraclejre7 != null;
assert useOracle == true  && useJava7 == false  -> oraclejre8 != null;
assert useOracle == false && useJava7 == true   -> jre7       != null;
assert useOracle == false && useJava7 == false  -> jre8       != null;

let
  java = if useOracle then
            if useJava7 then oraclejre7 else oraclejre8
         else
            if useJava7 then jre7 else jre8;

in stdenv.mkDerivation rec {
  version = "5.3.0";
  name = "UMS";
  javaVersion = if useJava7 then "Java7" else "Java8";

  src = fetchurl {
    url = "http://sourceforge.net/projects/unimediaserver/files/Official%20Releases/Linux/${name}-${version}-${javaVersion}.tgz/download";
    sha256 = "0j4rzhixfmzsk7arb5r5g628n6fj9wizxpc6faq1h55fz1b9bzgz";
    name = "${name}-${javaVersion}.tgz";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    cp -a . $out/
    mkdir $out/bin

    makeWrapper "$out/UMS.sh" "$out/bin/UMS" \
      --prefix LD_LIBRARY_PATH ":" "${libzen}/lib:${libmediainfo}/lib" \
      --set JAVA_HOME "${java}"
  '';

  meta = {
      description = "Universal Media Server: a DLNA-compliant UPnP Media Server.";
      license = stdenv.lib.licenses.gpl2;
      platforms = stdenv.lib.platforms.linux;
      maintainers = [ stdenv.lib.maintainers.thall ];
  };
}
