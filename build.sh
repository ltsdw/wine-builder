#! /bin/sh

_base=6
_minor=13
_pkgver="$_base.$_minor"
wine_pkg="wine-$_pkgver"
staging_pkg="wine-staging-$_pkgver"
_basedir=$PWD
_srcdir="$_basedir/src"
_march="native" #name of the target architecture

w32AppFont()
{
    #font aliasing settings for Win32 applications
    if ! [ -z $XDG_CONFIG_HOME ]; then
        font_dir_path="$XDG_CONFIG_HOME/fontconfig/conf.d"
        install -d "$font_dir_path"
        install -m644 "$_basedir/font/30-win32-aliases.conf" "$font_dir_path"
    fi
}

w32AppFontDel()
{
    #delete font file for Win32 applications
    if ! [ -z $XDG_CONFIG_HOME ]; then
        font_dir_path="$XDG_CONFIG_HOME/fontconfig/conf.d"
        rm "$font_dir_path/30-win32-aliases.conf"
    fi
}

init()
{
    mkdir -p $_srcdir #create source directory if not exist

    t_winepkg="$wine_pkg.tar.xz"
    t_stagingpkg="wine-staging-v$_pkgver.tar.gz"
    curl_wine="curl -L https://dl.winehq.org/wine/source/$_base.x/wine-$_pkgver.tar.xz -o $t_winepkg -#"
    curl_staging="curl -L https://github.com/wine-staging/wine-staging/archive/v$_pkgver/wine-staging-v$_pkgver.tar.gz -o $t_stagingpkg -#"

    if ! [ -f $t_winepkg ]; then
        echo "dowloading $t_winepkg"
        $curl_wine
    fi

    if ! [ -f $t_stagingpkg ]; then
        echo "downloading $t_stagingpkg"
        $curl_staging
    fi

    #excracting source
    tar xvf $t_winepkg -C $_srcdir
    tar xvf $t_stagingpkg -C $_srcdir

}

srcClean()
{
    #delete all files and directory inside source directory
    rm -rf $_srcdir/$wine_pkg
    rm -rf $_srcdir/$staging_pkg
    rm -rf $_srcdir/$wine_pkg-32-build
    rm -rf $_srcdir/$wine_pkg-64-build
}

prepare()
{
    cd $_srcdir

    #clean early build
    rm -rf $wine_pkg-32-build
    rm -rf $wine_pkg-64-build

    mkdir -p $wine_pkg-32-build
    mkdir -p $wine_pkg-64-build

    #patches to aply to wine-staging
    for patch in $_basedir/patches/staging/*; do
        if [ -f $patch ]; then
            echo applying $patch
            patch -d "$_srcdir/$staging_pkg" -p1 -i $patch
        fi
    done

    #staging patches
    "$_srcdir/$staging_pkg/patches/patchinstall.sh" DESTDIR="$_srcdir/$wine_pkg" --all

    #patches to apply to wine
    for patch in $_basedir/patches/*; do
        if [ -f $patch ]; then
            echo applying $patch
            patch -d "$_srcdir/$wine_pkg" -p1 -i $patch
        fi
    done

    #use generic processor architecture if not specified 
    if ! [ -z $_march ]; then
        export CFLAGS="-march=$_march -O2 -pipe"
    else
        export CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe"
    fi

    export LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"

    #build 64 bits
    cd "$_srcdir/$wine_pkg-64-build"
    ../$wine_pkg/configure \
        --prefix=/usr \
        --libdir=/usr/lib \
        --with-x \
        --with-gstreamer \
        --enable-win64 \
        --with-xattr

    make -j$(nproc)

    #build 32 bits
    export PKG_CONFIG_PATH="/usr/lib32/pkgconfig"
    cd "$_srcdir/$wine_pkg-32-build"
    ../$wine_pkg/configure \
        --prefix=/usr \
        --with-x \
        --with-gstreamer \
        --with-xattr \
        --libdir=/usr/lib32 \
        --with-wine64="$_srcdir/$wine_pkg-64-build"

    make -j$(nproc)
}

$@

