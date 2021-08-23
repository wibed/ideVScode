FROM ubuntu:bionic as base

RUN groupadd -g 1001 user
RUN useradd -u 1001 -g 1001 -G video -ms /bin/bash user


RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    wget \
    curl \
    libx11-xcb1 \
    libasound2 \
    libxshmfence1 \
    git \
    libnss3-dev \
    libxkbfile1 \
    libsecret-1-0 \
    libgtk-3-0 \
    libxss1 \
    libgbm1

RUN curl -s https://api.github.com/repos/VSCodium/vscodium/releases/latest \
  | grep "browser_download_url.*deb" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | wget -qi -

RUN dpkg -i $(ls -l \
  | grep -e "codium.*amd64.deb" \
  | grep -v "sha256" \
  | cut -d' ' -f11)


#RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add - \
#  && add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

#RUN apt-get -y update \
#  && apt-get -y install code


ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV SWIFT_SIGNING_KEY=A62AE125BBBFBB96A6E042EC925CC1CCED3D1561
ENV SWIFT_PLATFORM=ubuntu18.04
ENV SWIFT_BRANCH=swift-5.4.2-release
ENV SWIFT_VERSION=swift-5.4.2-RELEASE
ENV SWIFT_WEBROOT=https://swift.org/builds/
RUN apt-get install -y \
  libatomic1 \
  libcurl4 \
  libxml2 \
  libedit2 \
  libsqlite3-0 \
  libc6-dev \
  binutils \
  libgcc-5-dev \
  libstdc++-5-dev \
  zlib1g-dev \
  libpython2.7 \
  tzdata \
  git \
  pkg-config

RUN SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)/"\
  && SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz" \
  && SWIFT_SIG_URL="$SWIFT_BIN_URL.sig" \
  && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz "$SWIFT_SIG_URL" -o swift.tar.gz.sig

RUN tar -xzf swift.tar.gz --directory / --strip-components=1 \
  && chmod -R o+r /usr/lib/swift \
  && rm -rf swift.tar.gz.sig swift.tar.gz


RUN apt-get install -y \
    python3.8 \
    python3-pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
RUN python -m pip install pip
RUN pip3 install \
    grip \
    python-lsp-server


RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g \
    typescript \
    marked \
    dockerfile-language-server-nodejs \
    typescript-language-server \
    vscode-css-languageserver-bin


RUN git clone https://github.com/apple/sourcekit-lsp \
 && cd sourcekit-lsp/Editors/vscode \
 && npm install \
 && npm run dev-package \
 && su user -c "codium --install-extension sourcekit-lsp-development.vsix"


USER user
ENTRYPOINT ["codium", "--verbose", "--user-data-dir=/home/user"]
