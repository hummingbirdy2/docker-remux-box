FROM lsiobase/ubuntu:focal

# ===========================
# Container labels
LABEL maintainer="Hummingbird the Second"

# ===========================
# Environment Settings
ENV DEBIAN_FRONTEND="noninteractive"

# Arguments Settings
ARG TZ=UTC

# ===========================
# Install Mono
# version: https://www.mono-project.com/download/stable/

ARG MONO_VERSION=6.10.0.104

RUN echo '\n'"MONO: Install necessary packages" && \
  apt-get update && \
  apt-get install -y --no-install-recommends gnupg dirmngr && \
  rm -rf /var/lib/apt/lists/* && \
  \
  echo '\n'"MONO: Import the repository’s GPG key" && \
  export GNUPGHOME="$(mktemp -d)" && \
  gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
  gpg --batch --export --armor 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF > /etc/apt/trusted.gpg.d/mono.gpg.asc && \
  gpgconf --kill all && \
  rm -rf "$GNUPGHOME" && \
  apt-key list | grep 'Xamarin' && \
  apt-get purge -y --auto-remove gnupg dirmngr && \
  \
  echo '\n'"MONO: Add the repository + install packages" && \
  echo "deb http://download.mono-project.com/repo/ubuntu stable-focal/snapshots/$MONO_VERSION main" > /etc/apt/sources.list.d/mono-official-stable.list && \
  apt-get update && \
  apt-get install -y mono-runtime nuget && \
  rm -rf /var/lib/apt/lists/* /tmp/* /etc/apt/trusted.gpg.d/mono.gpg.asc /etc/apt/sources.list.d/mono-official-stable.list

# ===========================
# Install Wine
# version: https://www.winehq.org/

ARG WINE_VERSION=5.0.2
ARG WINE_PACKAGE_VERSION=${WINE_VERSION}~focal

RUN echo '\n'"WINE: Install necessary packages" && \
  apt-get update && \
  apt-get install -y --no-install-recommends gnupg dirmngr wget && \
  rm -rf /var/lib/apt/lists/* && \
  \
  echo '\n'"WINE: Import the repository’s GPG key" && \
  export GNUPGHOME="$(mktemp -d)" && \
  gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys D43F640145369C51D786DDEA76F1A20FF987672F && \
  gpg --batch --export --armor D43F640145369C51D786DDEA76F1A20FF987672F > /etc/apt/trusted.gpg.d/winehq.gpg.asc && \
  gpgconf --kill all && \
  rm -rf "$GNUPGHOME" && \
  apt-key list | grep 'WineHQ' && \
  apt-get purge -y --auto-remove gnupg dirmngr wget && \
  \
  echo '\n'"WINE: Add the repositories + install packages" && \
  dpkg --add-architecture i386 && \
  echo "deb http://dl.winehq.org/wine-builds/ubuntu/ focal main" >> /etc/apt/sources.list.d/winehq.list && \
  apt-get update && \
  apt-get install -y --install-recommends winehq-stable=$WINE_PACKAGE_VERSION ttf-mscorefonts-installer && \
  rm -rf /var/lib/apt/lists/* /etc/apt/trusted.gpg.d/winehq.gpg.asc /etc/apt/sources.list.d/wine-obs.list /etc/apt/sources.list.d/winehq.list

# ===========================
# Install BDInfoCLI-ng (fork by zoffline)
# version: https://github.com/zoffline/BDInfoCLI-ng/tree/UHD_Support_CLI/prebuilt

ARG BDINFOCLI_VERSION=0.7.5.5
ARG BDINFOCLI_ZIP_URL=https://github.com/zoffline/BDInfoCLI-ng/raw/UHD_Support_CLI/prebuilt/BDInfoCLI-ng_v${BDINFOCLI_VERSION}.zip

RUN echo '\n'"BDINFOCLI: Install necessary packages" && \
  apt-get update && \
  apt-get install -y --no-install-recommends unzip && \
  rm -rf /var/lib/apt/lists/* && \
  \
  echo '\n'"BDINFOCLI: Download prebuild" && \
  export ZIP="$(mktemp -d)" && \
  curl -o "$ZIP/tmp.zip" -L $BDINFOCLI_ZIP_URL && \
  mkdir -p /app/bdinfo && \
  unzip -j "$ZIP/tmp.zip" -d /app/bdinfo && \
  rm -rf $ZIP && \
  echo '#!/bin/bash \n mono /app/bdinfo/BDInfo.exe "$@"' > /usr/bin/bdinfo && chmod +x /usr/bin/bdinfo && \
  apt-get purge -y --auto-remove unzip && \
  rm -rf /var/lib/apt/lists/*

# ===========================
# Install eac3to
# version: https://forum.doom9.org/showthread.php?t=125966
# flac version: https://xiph.org/flac/news.html

ARG EAC3TO_ZIP_URL=http://madshi.net/eac3to.zip

ARG LIBFLAC_VERSION=1.3.3
ARG LIBFLAC_ZIP_URL=https://www.rarewares.org/files/lossless/flac_dll-${LIBFLAC_VERSION}-x86.zip

RUN echo '\n'"EAC3TO: Install necessary packages" && \
  apt-get update && \
  apt-get install -y --no-install-recommends unzip && \
  rm -rf /var/lib/apt/lists/* && \
  \
  echo '\n'"EAC3TO: Download prebuild + update libFlac" && \
  export ZIP="$(mktemp -d)" && \
  curl -o "$ZIP/eac3to.zip" -L "${EAC3TO_ZIP_URL}" && \
  curl -o "$ZIP/libflac.zip" -L "${LIBFLAC_ZIP_URL}" && \
  mkdir -p /app/eac3to && \
  unzip "$ZIP/eac3to.zip" -d /app/eac3to && \
  unzip "$ZIP/libflac.zip" -d $ZIP && \
  rm -v /app/eac3to/libFLAC.dll && \
  mv -v $ZIP/libFLAC_dynamic.dll /app/eac3to/libFLAC.dll && \
  rm -rf $ZIP && \
  echo '#!/bin/bash \n wine /app/eac3to/eac3to.exe "$@"' > /usr/bin/eac3to && chmod +x /usr/bin/eac3to && \
  apt-get purge -y --auto-remove unzip && \
  rm -rf /var/lib/apt/lists/* && \
  \
  echo '\n'"EAC3TO: Remove audios to avoid ALSA lib error" && \
  rm -v /app/eac3to/*.wav

# ===========================
# Install mkvtoolnix (latest)
# version: https://mkvtoolnix.download/doc/NEWS.md

RUN echo '\n'"MKVTOOLNIX: Install necessary packages" && \
  apt-get update && \
  apt-get install -y --no-install-recommends gnupg wget && \
  rm -rf /var/lib/apt/lists/* && \
  \
  echo '\n'"MKVTOOLNIX: Import the repository and the GPG key" && \
  wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
  echo "deb http://mkvtoolnix.download/ubuntu/ focal main"  > /etc/apt/sources.list.d/mkvtoolnix.list && \
  apt-get purge -y --auto-remove gnupg wget && \
  \
  echo '\n'"MKVTOOLNIX: Install package" && \
  apt-get update && \
  apt-get install -y mkvtoolnix && \
  rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/mkvtoolnix.list

# ===========================
# Install mediainfo (latest)
# version: https://mediaarea.net/en/MediaInfo

RUN echo '\n'"MEDIAINFO: Install necessary packages" && \
  apt-get update && \
  apt-get install -y --no-install-recommends gnupg dirmngr && \
  rm -rf /var/lib/apt/lists/* && \
  \
  echo '\n'"MEDIAINFO: Import the repository’s GPG key" && \
  export GNUPGHOME="$(mktemp -d)" && \
  gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5CDF62C7AE05CC847657390C10E11090EC0E438 && \
  gpg --batch --export --armor C5CDF62C7AE05CC847657390C10E11090EC0E438 > /etc/apt/trusted.gpg.d/mediaarea.gpg.asc && \
  gpgconf --kill all && \
  rm -rf "$GNUPGHOME" && \
  apt-key list | grep 'MediaArea' && \
  apt-get purge -y --auto-remove gnupg dirmngr && \
  \
  echo '\n'"MEDIAINFO: Add the repository + install package" && \
  echo "deb http://mediaarea.net/repo/deb/ubuntu focal main" > /etc/apt/sources.list.d/mediaarea.list && \
  apt-get update && \
  apt-get install -y mediainfo && \
  rm -rf /var/lib/apt/lists/* /etc/apt/trusted.gpg.d/mediaarea.gpg.asc /etc/apt/sources.list.d/mediaarea.list

# ===========================
# Install others tools (latest from distro repository)
# nano: https://www.nano-editor.org/
# sox: http://sox.sourceforge.net/Main/HomePage
# ffmpeg: https://ffmpeg.org/

RUN echo '\n'"OTHERS TOOLS: Install packages" && \
  apt-get update && \
  apt-get install -y nano sox ffmpeg && \
  rm -rf /var/lib/apt/lists/*

# ===========================
# Add local files
COPY root/ /
