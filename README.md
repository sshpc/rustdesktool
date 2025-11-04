# RustDesk-Server 一键安装脚本

## 示例
```sh
# RustDesk-Server x86 一键安装脚本
# Rep <https://github.com/sshpc/rustdesktool>
# You Server:ubuntu
服务状态: [运行中]

>~~~~~~~~~~~~~~  rustdesk-server tool ~~~~~~~~~~~~<  v: 1.3

1: 安装            2: 卸载

3: 查看状态          4: 查看key

5: 启动服务          6: 停止服务

7: 升级脚本          

q: 退出  

请输入命令号:
```

## 安装&卸载

### 一键安装
> root 用户

```sh
wget -N  https://raw.githubusercontent.com/sshpc/rustdesktool/main/rustdesktool.sh && chmod +x ./rustdesktool.sh && ./rustdesktool.sh
```

> 再次执行

```sh
./rustdesktool.sh
```
### 国内加速链接

```sh
wget -N  https://gh.ddlc.top/https://raw.githubusercontent.com/sshpc/rustdesktool/main/rustdesktool.sh && chmod +x ./rustdesktool.sh && ./rustdesktool.sh
```
```sh
wget -N  https://gh-proxy.com/https://raw.githubusercontent.com/sshpc/rustdesktool/main/rustdesktool.sh && chmod +x ./rustdesktool.sh && ./rustdesktool.sh
```

## 客户端下载
官方地址 
https://rustdesk.com/download

支持 (Windows、Ubuntu、Mac、Android..) 

## 客户端配置

>默认安装后使用的是官方的服务器，需要换成自己的

 设置 → 网络
* ID服务器地址：<你的服务器IP>
* 中继服务器地址：<你的服务器IP>
* API服务器地址：留空
* 秘钥：你的服务器公钥（安装后获得）


## 其他信息

### 默认安装目录
/usr/local/rustdesk-sever

### 服务安装目录

/usr/lib/systemd/system/RustDeskHbbr.service
/usr/lib/systemd/system/RustDeskHbbs.service


### 秘钥位置
默认安装目录下的 id_ed25519.pub

>自定义秘钥：安装后手动替换安装目录下的 id_ed25519.pub 和 id_ed25519

### 端口

>若连接失败,请检查防火墙端口是否打开 

hbbs 监听21115(tcp), 21116(tcp/udp), 21118(tcp)

hbbr 监听21117(tcp), 21119(tcp)

* 21115 -> hbbs用作NAT类型测试
* 21116/UDP -> hbbs用作ID注册与心跳服务
* 21116/TCP -> hbbs用作TCP打洞与连接服务
* 21117 -> hbbr中继服务
* 21118、21119 -> 网页客户端


### 官方 rep： 

https://github.com/rustdesk/rustdesk-server






