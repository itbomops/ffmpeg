#!/bin/bash
#### Щоб скоріше компілило запускаєш make -j 10
#### https://trac.ffmpeg.org/wiki/CompilationGuide/Centos
#### https://github.com/kripken/emscripten/issues/3280
#### Перед компіляцією самого ffmpeg запускаєш:

PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

echo "Get the Dependencies"
yum install autoconf automake bzip2 cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel zeromq-devel -y;
yum install alsa-lib.x86_64 autoconf automake bzip2 cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel zeromq-devel freetype-devel.x86_64 yasm -y;

mkdir ~/ffmpeg_sources

echo "Compilation & Installation"
echo "NASM"
cd ~/ffmpeg_sources
curl -O -L http://www.nasm.us/pub/nasm/releasebuilds/2.13.02/nasm-2.13.02.tar.bz2
tar xjvf nasm-2.13.02.tar.bz2
cd nasm-2.13.02
./autogen.sh
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make -j 10
make install

echo "YASM"
cd ~/ffmpeg_sources
curl -O -L http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make -j 10
make install

echo "libx264"
cd ~/ffmpeg_sources
git clone --depth 1 http://git.videolan.org/git/x264
cd x264
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make -j 10
make install

echo "libx265"
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make -j 10
make install

echo "libfdk_aac"
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make -j 10
make install

echo "libmp3lame"
cd ~/ffmpeg_sources
curl -O -L http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
tar xzvf lame-3.100.tar.gz
cd lame-3.100
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
make -j 10
make install

echo "libopus"
cd ~/ffmpeg_sources
curl -O -L https://archive.mozilla.org/pub/opus/opus-1.2.1.tar.gz
tar xzvf opus-1.2.1.tar.gz
cd opus-1.2.1
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make -j 10
make install

echo "libogg"
cd ~/ffmpeg_sources
curl -O -L http://downloads.xiph.org/releases/ogg/libogg-1.3.3.tar.gz
tar xzvf libogg-1.3.3.tar.gz
cd libogg-1.3.3
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make -j 10
make install

 echo "openssl"
 cd ~/ffmpeg_sources
 curl -O -L https://www.openssl.org/source/openssl-1.0.2m.tar.gz
 tar xzvf openssl-1.0.2m.tar.gz
 cd openssl-1.0.2m
 ./config --prefix="$HOME/ffmpeg_build"
 make -j 10
 make install

echo "libvorbis"
cd ~/ffmpeg_sources
curl -O -L http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz
tar xzvf libvorbis-1.3.5.tar.gz
cd libvorbis-1.3.5
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make -j 10
make install

echo "libvpx"
cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
make -j 10
make install

echo "libzimg"
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/sekrit-twc/zimg.git
cd zimg
./autogen.sh
./configure --prefix="$HOME/ffmpeg_build"
make -j 10
make install

echo "FFmpeg"
cd ~/ffmpeg_sources
curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
 ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libfdk_aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree \
  --enable-libzmq \
  --enable-openssl \
  --enable-libzimg
make -j 10
make install
hash -r