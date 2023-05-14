group default {
  targets = ["libs", "bookworm"]
}

variable DEBUG {
  default = false
}

target bookworm {
  args = {
    OS_BASE = "docker.io/debian:bookworm"
  }
  tags = ["docker.io/milas/rkmpp:bookworm-latest"]
  target = DEBUG ? "os-debug" : "os"
}

group libs {
  targets = ["rga", "mpp", "gstreamer-plugin"]
}

target gstreamer {
  target = "gstreamer"
  output = ["type=local,dest=./out/gstreamer"]
}

target rga {
  target = "rockchip-rga"
  output = ["type=local,dest=./out/rga"]
}

target mpp {
  target = "rockchip-mpp"
  output = ["type=local,dest=./out/mpp"]
}

target gstreamer-plugin {
  target = "rockchip-gstreamer-plugin"
  output = ["type=local,dest=./out/gstreamer"]
}
