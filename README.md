Forked the [PVFree](http://freepv.sourceforge.net/) projct and made `qtvr2img` build-able under Ubuntu 20.04.

```
docker build . -t wypath_converter
docker run --rm -v "$(pwd)":/codes wypath_converter
```
