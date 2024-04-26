# RustDesk安装脚本

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

需要准备的信息：

1. 服务器IP地址 
2. 服务器公钥 （安装完成后获取）
> 默认安装目录下的 id_ed25519.pub


* ID服务器地址：<你的服务器IP>
* 中继服务器地址：<你的服务器IP>
* API服务器地址：可以留空
* 秘钥：粘贴你的服务器公钥

## 其他

* 默认安装目录
/usr/local/rustdesk-sever
>可在安装脚本里修改

* 服务安装目录
```
/usr/lib/systemd/system/RustDeskHbbr.service
/usr/lib/systemd/system/RustDeskHbbs.service
```





