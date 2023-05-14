# Rockchip Multimedia Docker Images
Dockerized build system for Rockchip multimedia libraries to provide accelerated video encoding & decoding via Gstreamer.

## Quick Start
Run the pre-built image:
```shell
docker run -it --privileged docker.io/milas/rkmpp:bookworm-latest
```
> 💡 The `--privileged` flag is required to allow access to the hardware encoder/decoder.

## Build Prerequisites
* Docker w/ buildx plugin
  * If `docker buildx inspect` works, you're all set!
* `arm64` host
  * Cross-compilation from `amd64` not currently supported

## Docker Image
The Docker image is currently based off of Debian Bookworm, which contains Gstreamer 1.22.

The base OS image is subject to change based on Rockchip upstream.
It's probably possible to use a different Debian version or Ubuntu as the base, but no support is provided for that due to the sheer number of Gstreamer dependencies.

Build the image:
```shell
docker buildx bake bookworm --load
```
_This step is **optional**. Pre-built images are [available on Docker Hub][hub/rkmpp]._

Run the image:
```shell
docker run -it --privileged docker.io/milas/rkmpp:bookworm-latest
```

## `librga` aka RGA (Raster Graphic Acceleration Unit)
**Upstream**: https://github.com/JeffyCN/mirrors/tree/linux-rga

```shell
docker buildx bake rkmpp-rga
```
```
out/
└── rga
    └── usr
        └── local
            ├── include
            │   └── rga
            │       ├── drmrga.h
            │       ├── RgaApi.h
            │       ├── rga.h
            │       ├── RockchipRga.h
            │       └── RockchipRgaMacro.h
            └── lib
                ├── librga.so -> librga.so.2
                ├── librga.so.2 -> librga.so.2.0.0
                ├── librga.so.2.0.0
                └── pkgconfig
                    └── librga.pc
```


## `mpp` aka MPP (Media Process Platform)
**Upstream**: https://github.com/rockchip-linux/mpp/tree/develop

```shell
docker buildx bake rkmpp-mpp
```
```
out/
└── mpp
    └── usr
        └── local
            ├── bin
            │   ├── mpi_dec_mt_test
            │   ├── mpi_dec_multi_test
            │   ├── mpi_dec_nt_test
            │   ├── mpi_dec_test
            │   ├── mpi_enc_mt_test
            │   ├── mpi_enc_test
            │   ├── mpi_rc2_test
            │   ├── mpp_info_test
            │   └── vpu_api_test
            ├── include
            │   └── rockchip
            │       ├── mpp_buffer.h
            │       ├── mpp_compat.h
            │       ├── mpp_err.h
            │       ├── mpp_frame.h
            │       ├── mpp_log_def.h
            │       ├── mpp_log.h
            │       ├── mpp_meta.h
            │       ├── mpp_packet.h
            │       ├── mpp_rc_api.h
            │       ├── mpp_rc_defs.h
            │       ├── mpp_task.h
            │       ├── rk_hdr_meta_com.h
            │       ├── rk_mpi_cmd.h
            │       ├── rk_mpi.h
            │       ├── rk_type.h
            │       ├── rk_vdec_cfg.h
            │       ├── rk_vdec_cmd.h
            │       ├── rk_venc_cfg.h
            │       ├── rk_venc_cmd.h
            │       ├── rk_venc_rc.h
            │       ├── rk_venc_ref.h
            │       ├── vpu_api.h
            │       └── vpu.h
            └── lib
                ├── librockchip_mpp.so -> librockchip_mpp.so.1
                ├── librockchip_mpp.so.0
                ├── librockchip_mpp.so.1 -> librockchip_mpp.so.0
                ├── librockchip_vpu.so -> librockchip_vpu.so.1
                ├── librockchip_vpu.so.0
                ├── librockchip_vpu.so.1 -> librockchip_vpu.so.0
                └── pkgconfig
                    ├── rockchip_mpp.pc
                    └── rockchip_vpu.pc
```

## `gstreamer-rockhip` aka Gstreamer Plugin 
**Upstream**: https://github.com/JeffyCN/mirrors/tree/gstreamer-rockchip

```shell
docker buildx bake rkmpp-gstreamer-plugin
```
```
out/
└── gstreamer
    └── usr
        └── local
            └── lib
                └── aarch64-linux-gnu
                    └── gstreamer-1.0
                        ├── libgstkmssrc.so
                        ├── libgstrkximage.so
                        └── libgstrockchipmpp.so
```

[hub/rkmpp]: https://hub.docker.com/r/milas/rkmpp
