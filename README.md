# wine-builder

a simple script to apply [staging patches](https://github.com/wine-staging/wine-staging) and some patches that I got from [wine-tkg](https://github.com/Frogging-Family/wine-tkg-git) at top of wine and build it.

# usage

```
git clone https://github.com/ltsdw/wine-builder
cd wine-builder
```

install the dependencies inside of [dependencies.txt](https://github.com/ltsdw/wine-builder/blob/main/dependencies.txt)

```
./wine-builder --build
```

the package will be put inside ___pkg/wine-ltsdw-VERSION___ directory, you can copy to anywhere you want to (it's meant to be installed locally not system-wide).

# environment variables

| environment variables | description |
| :-------------------- | :---------- |
| <tt>WINEESYNC</tt>                 | 1 to enable esync, +esync to debug
| <tt>WINEFSYNC</tt>                 | 1 to enable fsync
| <tt>WINEFSYNC_SPINCOUNT</tt>       | default to 100
| <tt>WINEFSYNC_FUTEX2</tt>          | 1 to enable fsync_futex2
| <tt>WINE_DISABLE_WRITE_WATCH</tt>  | 1 to disable write watch
| <tt>STAGING_WRITECOPY</tt>         | 1 to simulate the memory management system of Windows more precisely
| <tt>STAGING_SHARED_MEMORY</tt>     | 1 to enable shared memory
  
