#! /bin/sh

_base=6
_minor=13
_pkgver="$_base.$_minor"
wine_pkg="wine-$_pkgver.tar.xz"
staging_pkg="wine-staging-v$_pkgver.tar.gz"
_basedir=$(pwd)
_srcdir="$_basedir/src"

init()
{

    mkdir -p $_srcdir #create source directory if not exist

#    clone or update source files
#    gc_wine="git clone git://source.winehq.org/git/wine.git"
#    gc_wine_staging="git clone git+https://github.com/wine-staging/wine-staging.git"
#    gf_wine="git --git-dir=wine/.git fetch wine"
#    gf_wine_staging="git --git-dir=wine-staging/.git fetch wine-staging"

    curl_wine="curl -L https://dl.winehq.org/wine/source/$_base.x/wine-$_pkgver.tar.xz -o $wine_pkg -#"
    curl_staging="curl -L https://github.com/wine-staging/wine-staging/archive/v$_pkgver/wine-staging-v$_pkgver.tar.gz -o $staging_pkg"

    if ! [ -f $wine_pkg ]; then
        echo "dowloading $wine_pkg"
        $curl_wine
    fi

    if ! [ -f $staging_pkg ]; then
        echo "downloading $staging_pkg"
        $curl_staging
    fi

    tar xvf $wine_pkg -C $_srcdir
    tar xvf $staging_pkg -C $_srcdir
    #cp wine wine-staging $src #copy files to source directory
}

pkgver() {
    _ver="$(git -C wine-staging describe --long --tags | sed 's/\([^-]*-g\)/r\1/;s/-/./g;s/^v//;s/\.rc/rc/')"
}

srcClean()
{
    #delete all files and directory inside source directory
    rm -rf "$_srcdir/wine-$_pkgver"
    rm -rf "$_srcdir/wine-staging-$_pkgver"
}

prepare()
{
    rm -rf build-{32,64}
    mkdir -p build-{32,64}

    echo applying staging patches
    cd "$_srcdir/wine-staging-$_pkgver/patches"
    ./patchinstall.sh DESTDIR="$_srcdir/wine-$_pkgver" --all
    cd $_basedir
    #for dir in "$*"; do
    #    for patch in $dir/*.patch; do
    #        if [ -f $patch ]; then
    #            #du -h $patch
    #            #ls "$_srcdir/wine-$_pkgver"
    #            echo applying $patch
    #            patch -d "$_srcdir/wine-$_pkgver" -p1 -i "../../$patch"
    #        fi
    #    done
    #    popd
        #fi
    #done
}


$@

