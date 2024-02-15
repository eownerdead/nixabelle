{ lib, stdenv, fetchurl, coreutils, gnutar, nettools, jdk, polyml, rlwrap, perl
, isabelle, symlinkJoin, curl, fetchhg, rsync }:
let
  sha1 = stdenv.mkDerivation {
    pname = "isabelle-sha1";
    version = "2021-1";

    src = fetchhg {
      url = "https://isabelle.sketis.net/repos/sha1";
      rev = "e0239faa6f42";
      sha256 = "sha256-4sxHzU/ixMAkSo67FiE6/ZqWJq9Nb9OMNhMoXH2bEy4=";
    };

    buildPhase = ''
      LDFLAGS="-fPIC -shared"
      CFLAGS="-fPIC -I."
      $CC $CFLAGS -c sha1.c -o sha1.o
      $LD $LDFLAGS sha1.o -o libsha1.so
    '';

    installPhase = ''
      mkdir -p $out/lib
      cp libsha1.so $out/lib/
    '';
  };

  java = jdk;

  contrib-bash_process = fetchurl {
    url = "https://isabelle.sketis.net/components/bash_process-1.3.tar.gz";
    sha256 = "sha256-GLLiYA1IA3lajrW2mN3eZtc4saO3XfwrdG7jP97DSvU=";
  };
  contrib-isabelle_fonts = fetchurl {
    url =
      "https://isabelle.sketis.net/components/isabelle_fonts-20211004.tar.gz";
    sha256 = "sha256-0Q/LhAdVD1tpBnug7z/++LCFalsmwLoVE81oyz6nwHM=";
  };
  contrib-isabelle_setup = fetchurl {
    url =
      "https://isabelle.sketis.net/components/isabelle_setup-20230206.tar.gz";
    sha256 = "sha256-5bF95eBElvYLOFcnKsoRmJEvsSyvNSb0zJdqJnOo7r4=";
  };
  contrib-jfreechart = fetchurl {
    url = "https://isabelle.sketis.net/components/jfreechart-1.5.3.tar.gz";
    sha256 = "sha256-39Un5RC9xi6252ZsPaUm2SDr3GaFc1KLvEJ+cphwEbs=";
  };
  contrib-jsoup = fetchurl {
    url = "https://isabelle.sketis.net/components/jsoup-1.15.4.tar.gz";
    sha256 = "sha256-RIcF2KJ5gJoZj4EW3dfqXEhXW0oqvbCcwUB3Dy2mciI=";
  };
  contrib-kodkodi = fetchurl {
    url = "https://isabelle.sketis.net/components/kodkodi-1.5.7.tar.gz";
    sha256 = "sha256-BY5I2vLexZwTJnhSIIPciv08Cby4E8OhGpKNPO+RDqE=";
  };
  contrib-lipics = fetchurl {
    url = "https://isabelle.sketis.net/components/lipics-3.1.3.tar.gz";
    sha256 = "sha256-cqJ0N+Gytmr03DDC46oN4h7jW8XaavnwlT5/Om0EIKU=";
  };
  contrib-postgresql = fetchurl {
    url = "https://isabelle.sketis.net/components/postgresql-42.6.0.tar.gz";
    sha256 = "sha256-KXb0+kln+Gd3X7R35XFpuHP5uHdt3kCqeoOjzLYTsFY=";
  };
  contrib-scala = fetchurl {
    url = "https://isabelle.sketis.net/components/scala-3.3.0.tar.gz";
    sha256 = "sha256-66IHIwF5KTJNx1pVsvZZmbZLP6QrOerOob4cdZ7xMU8=";
  };
  contrib-sqlite-jdbc = fetchurl {
    url =
      "https://isabelle.sketis.net/components/sqlite-jdbc-3.42.0.0-1.tar.gz";
    sha256 = "sha256-p/gBdJkhRm81QhJHIYWOqSQmKBYkUI8DYKnfo9GqJm4=";
  };
  contrib-xz-java = fetchurl {
    url = "https://isabelle.sketis.net/components/xz-java-1.9.tar.gz";
    sha256 = "sha256-Cmal9ykBRs/wFbZTnM6afF4fC+QCYzsUyeapj9HmDNw=";
  };
  contrib-zstd-jni = fetchurl {
    url = "https://isabelle.sketis.net/components/zstd-jni-1.5.5-4.tar.gz";
    sha256 = "sha256-rWY43x4hlo0gcSo7VlZEe3EuynIWieU9F8k+BhwkJmg=";
  };
in stdenv.mkDerivation rec {
  pname = "isabelle";
  version = "2023";

  src = fetchurl {
    url =
      "https://github.com/m-fleury/isabelle-emacs/archive/Isabelle${version}-vsce.tar.gz";
    sha256 = "sha256-nE6Ec+4XA3LdC+dFwY7leUvS8EluQJEjclMm3lN39rQ=";
  };

  buildInputs = [
    polyml
    nettools # nettools needed for hostname
    curl
  ];

  postUnpack = ''
    mkdir $sourceRoot/contrib
    pushd $sourceRoot/contrib

    echo 'unpacking source archive ${contrib-bash_process}'
    tar -xf ${contrib-bash_process}
    echo 'unpacking source archive ${contrib-isabelle_fonts}'
    tar -xf ${contrib-isabelle_fonts}
    echo 'unpacking source archive ${contrib-isabelle_setup}'
    tar -xf ${contrib-isabelle_setup}
    echo 'unpacking source archive ${contrib-jfreechart}'
    tar -xf ${contrib-jfreechart}
    echo 'unpacking source archive ${contrib-jsoup}'
    tar -xf ${contrib-jsoup}
    echo 'unpacking source archive ${contrib-kodkodi}'
    tar -xf ${contrib-kodkodi}
    echo 'unpacking source archive ${contrib-lipics}'
    tar -xf ${contrib-lipics}
    echo 'unpacking source archive ${contrib-postgresql}'
    tar -xf ${contrib-postgresql}
    echo 'unpacking source archive ${contrib-scala}'
    tar -xf ${contrib-scala}
    echo 'unpacking source archive ${contrib-sqlite-jdbc}'
    tar -xf ${contrib-sqlite-jdbc}
    echo 'unpacking source archive ${contrib-xz-java}'
    tar -xf ${contrib-xz-java}
    echo 'unpacking source archive ${contrib-zstd-jni}'
    tar -xf ${contrib-zstd-jni}

    popd
  '';

  postPatch = ''
    patchShebangs .

    rm Admin/etc/build.props # Don't build `Isabelle/Scala/Admin`

    cat > etc/components << EOF
    #built-in components
    src/Tools/Graphview
    src/Tools/Setup
    src/Tools/VSCode
    src/HOL/Mutabelle
    src/HOL/Library/Sum_of_Squares
    src/HOL/SPARK
    src/HOL/Tools
    src/HOL/TPTP

    #bundled components
    contrib/bash_process-1.3
    contrib/isabelle_fonts-20211004
    contrib/isabelle_setup-20230206
    contrib/jfreechart-1.5.3
    contrib/jsoup-1.15.4
    contrib/kodkodi-1.5.7
    contrib/lipics-3.1.3
    contrib/postgresql-42.6.0
    contrib/scala-3.3.0
    contrib/sqlite-jdbc-3.42.0.0-1
    contrib/xz-java-1.9
    contrib/zstd-jni-1.5.5-4
    EOF

    cat >> etc/settings << EOF

    ISABELLE_LOGIC=Pure

    ISABELLE_JAVA_PLATFORM="${stdenv.system}"
    ISABELLE_JDK_HOME="${java}"

    ML_SYSTEM_64=true
    ML_SYSTEM=polyml
    ML_PLATFORM="${stdenv.system}"
    ML_HOME="${polyml}/bin"
    ML_OPTIONS="--minheap 1000"
    POLYML_HOME="\$COMPONENT"
    ML_SOURCES="\$POLYML_HOME/src"

    # From gnu-utils component
    ISABELLE_PRINTENV="${coreutils}/bin/printenv"
    ISABELLE_TAR="${gnutar}/bin/tar"

    ISABELLE_LINE_EDITOR="${rlwrap}/bin/rlwrap"

    ISABELLE_RSYNC_HOME="$COMPONENT"
    ISABELLE_RSYNC="${rsync}/bin/rsync"
    EOF

    substituteInPlace lib/Tools/env \
      --replace /usr/bin/env "${coreutils}/bin/env"

    substituteInPlace src/Tools/Setup/src/Environment.java \
      --replace 'cmd.add("/usr/bin/env");' "" \
      --replace 'cmd.add("bash");' "cmd.add(\"$SHELL\");"

    substituteInPlace src/Pure/General/sha1.ML \
      --replace '"$ML_HOME/" ^ (if ML_System.platform_is_windows then "sha1.dll" else "libsha1.so")' \
      '"${sha1}/lib/libsha1.so"'

    patchelf \
      --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
      contrib/bash_process-*/platform_${stdenv.system}/bash_process
  '';

  patches = [ ./nixabelle.patch ];

  buildPhase = ''
    export HOME=$TMP # The build fails if home is not set
    setup_name=$(basename contrib/isabelle_setup-*)

    SCALA_DIR=$(basename contrib/scala-*)

    #The following is adapted from https://isabelle.sketis.net/repos/isabelle/file/Isabelle2021-1/Admin/lib/Tools/build_setup
    TARGET_DIR="contrib/$setup_name/lib"
    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR/isabelle/setup"
    declare -a ARGS=("-Xlint:unchecked")

    SOURCES="$(${perl}/bin/perl -e 'while (<>) { if (m/(\S+\.java)/)  { print "$1 "; } }' "src/Tools/Setup/etc/build.props")"
    for SRC in $SOURCES; do
      ARGS["''${#ARGS[@]}"]="src/Tools/Setup/$SRC"
    done

    ${java}/bin/javac \
      -d "$TARGET_DIR" -classpath "contrib/$SCALA_DIR/lib/*" "''${ARGS[@]}"
    ${java}/bin/jar -c -f "$TARGET_DIR/isabelle_setup.jar" \
      -e "isabelle.setup.Setup" -C "$TARGET_DIR" isabelle
    rm -rf "$TARGET_DIR/isabelle"

    # Prebuild Pure Session
    bin/isabelle build -v -o system_heaps -b Pure
  '';

  installPhase = ''
    mkdir -p $out/opt/isabelle/
    cp -r ./ $out/opt/isabelle/ # mv: inter-device move failed: ...
    cd $out/opt/isabelle/
    mkdir $out/bin/
    ./bin/isabelle install $out/bin/

    # fonts
    mkdir -p "$out/share/fonts/ttf-hinted/"
    cp -r ./contrib/isabelle_fonts-*/ttf-hinted \
      "$out/share/fonts/"
  '';

  meta = with lib; {
    description = "A generic proof assistant";
    longDescription = ''
      Isabelle is a generic proof assistant.  It allows mathematical formulas
      to be expressed in a formal language and provides tools for proving those
      formulas in a logical calculus.
    '';
    homepage = "https://isabelle.in.tum.de/";
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryNativeCode # source bundles binary dependencies
    ];
    license = licenses.bsd3;
    platforms = platforms.unix;
  };

  passthru.withComponents = components:
    let base = "$out/${isabelle.dirname}";
    in symlinkJoin {
      name = "isabelle-with-components-${isabelle.version}";
      paths = [ isabelle ];

      buildInputs = components;

      postBuild = ''
        rm $out/bin/*

        cd ${base}
        rm bin/*
        cp ${isabelle}/${isabelle.dirname}/bin/* bin/
        rm etc/components
        cat ${isabelle}/${isabelle.dirname}/etc/components > etc/components

        export HOME=$TMP
        bin/isabelle install $out/bin
        patchShebangs $out/bin
      '' + lib.concatMapStringsSep "\n" (c: ''
        echo ${c}/lib/thys >> ${base}/etc/components
      '') components;
    };
}

