# RustDesk-Server安装脚本

## 安装&卸载

### 一键安装
> 推荐 root 用户

```sh
wget -N  http://raw.githubusercontent.com/sshpc/rustdesktool/main/rustdesktool.sh && chmod +x ./rustdesktool.sh && ./rustdesktool.sh
```

> 再次执行

```sh
./rustdesktool.sh
```

## 客户端配置

客户端下载(Windows、Ubuntu、Mac、Android..) https://rustdesk.com/download
>默认安装后使用的是官方的服务器，需要换成自己的

需要准备的信息：

1. 服务器公网IP地址 
2. 服务器公钥 （安装完成后获取）
> 默认安装目录下的 id_ed25519.pub

在客户端的网络设置里配置：
* ID服务器地址：<你的服务器IP>
* 中继服务器地址：<你的服务器IP>
* API服务器地址：留空
* 秘钥：粘贴你的服务器公钥

>若连接失败,请检查防火墙端口是否打开 

hbbs 监听21115(tcp), 21116(tcp/udp), 21118(tcp)，hbbr 监听21117(tcp), 21119(tcp)。21115是hbbs用作NAT类型测试，21116/UDP是hbbs用作ID注册与心跳服务，21116/TCP是hbbs用作TCP打洞与连接服务，21117是hbbr用作中继服务, 21118和21119是为了支持网页客户端。如果不需要网页客户端可以不开。


## 其他

官方rep： https://github.com/rustdesk/rustdesk

* 默认安装目录
/usr/local/rustdesk-sever
>可在安装脚本里修改

* 服务安装目录
```
/usr/lib/systemd/system/RustDeskHbbr.service
/usr/lib/systemd/system/RustDeskHbbs.service
```
* 支持国内环境
镜像支持 https://gitmirror.com/





