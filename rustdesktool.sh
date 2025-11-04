#!/bin/bash
export LANG=en_US.UTF-8


#安装目录
installdirectory='/usr/local/rustdesk-server'
#官方版本号
rustdeskserverversion='1.1.14'
# 配置文件下载代理主机列表（github加速）
proxyhost=(
    "https://gh.ddlc.top"
    "https://gh-proxy.com"
    "https://edgeone.gh-proxy.com"
    "https://cdn.gh-proxy.com"
    "https://hk.gh-proxy.com"
)
#下载超时时间
timeout=3

installType=''
removeType=''
upgrade=''
release='linux'
version='1.3'

#字体颜色定义
_red() {
    printf '\033[0;31;31m%b\033[0m' "$1"
    echo
}
_green() {
    printf '\033[0;31;32m%b\033[0m' "$1"
    echo
}
_yellow() {
    printf '\033[0;31;33m%b\033[0m' "$1"
    echo
}
_blue() {
    printf '\033[0;31;36m%b\033[0m' "$1"
    echo
}
waitinput() {
    echo
    read -n1 -r -p "按任意键继续...(退出 Ctrl+C)"
}
# 加载动画
loading() {
    local pids=("$@")
    local delay=0.1
    local spinstr='|/-\'
    tput civis # 隐藏光标
    
    while :; do
        local all_done=true
        for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                all_done=false
                local temp=${spinstr#?}
                printf "\r\033[0;31;36m[ %c ] loading ...\033[0m" "$spinstr"
                local spinstr=$temp${spinstr%"$temp"}
                sleep $delay
            fi
        done
        [[ $all_done == true ]] && break
    done
    
    tput cnorm        # 恢复光标
    printf "\r\033[K" # 清除行
}

# 通用下载函数：从镜像列表中依次尝试下载文件
download_file() {
    local url="$1"
    local path="$2"
    local output=""
    local dest=""
    if [[ -n "$path" ]]; then
        dest="$path"
    else
        dest="."
    fi
    for base in "${proxyhost[@]}"; do
        output="${dest}/$(basename "$url")"
        (
            wget -q --timeout="$timeout" "${base}/$url" -O "$output" > /dev/null 2>&1
        ) &
        local pid=$!
        loading $pid
        wait $pid
        if [[ -s "$output" ]]; then
            return 0
        fi
    done
    return 1
}


#菜单渲染
menu() {
    printf "\033[H\033[2J"
    _green '# RustDesk-Server x86 一键安装脚本'
    _green '# Rep <https://github.com/sshpc/rustdesktool>'
    _blue '# You Server:'${release}
    _blue "服务状态: [$(check_rustdesk_status)]"
    echo
    _blue ">~~~~~~~~~~~~~~  rustdesk-server tool ~~~~~~~~~~~~<  v: $version"
    echo
    options=("$@")
    num_options=${#options[@]}
    # 计算数组中的字符最大长度
    max_len=0
    for ((i = 0; i < num_options; i++)); do
        # 获取当前字符串的长度
        str_len=${#options[i]}

        # 更新最大长度
        if ((str_len > max_len)); then
            max_len=$str_len
        fi
    done
    # 渲染菜单
    for ((i = 0; i < num_options; i += 4)); do
        printf "%s%*s  " "$((i / 2 + 1)): ${options[i]}" "$((max_len - ${#options[i]}))"
        if [[ "${options[i + 2]}" != "" ]]; then printf "$((i / 2 + 2)): ${options[i + 2]}"; fi
        echo
        echo
    done
    printf '\033[0;31;31m%b\033[0m' "q: 退出  "
    echo
    echo
    # 获取用户输入
    read -ep "请输入命令号: " number
    if [[ $number -ge 1 && $number -le $((num_options / 2)) ]]; then
        #找到函数名索引
        action_index=$((2 * (number - 1) + 1))
        #函数名赋值
        parentfun=${options[action_index]}
        #函数执行
        ${options[action_index]}
        waitinput
        main
    elif [[ $number == 'q' ]]; then
        echo
        exit
    else
        echo
        _red '输入有误  回车返回首页'
        waitinput
        main
    fi
}

#检查系统
checkSystem() {

    if grep -qi "centos\|red hat" /etc/os-release; then
        release="centos"
        installType='yum -y install'
        removeType='yum -y remove'
        upgrade="yum update -y --skip-broken"
    elif grep -qi "ubuntu" /etc/os-release; then
        release="ubuntu"
        installType='apt -y install'
        removeType='apt -y autoremove'
        upgrade="apt update"
    elif grep -qi "debian" /etc/os-release; then
        release="debian"
        installType='apt -y install'
        removeType='apt -y autoremove'
        upgrade="apt update"
    elif grep -qi "alpine" /etc/os-release; then
        release="alpine"
        installType='apk add'
        upgrade="apk update"
        removeType='apk del'
    else
        _red "不支持此系统"
        _red "$(cat /etc/issue)"
        _red "$(cat /proc/version)"
        exit 1
    fi
}



#脚本升级
updateself() {

    _blue '下载最新版脚本'
    if ! download_file "https://raw.githubusercontent.com/sshpc/rustdesktool/main/rustdesktool.sh"; then
        _red "rustdesktool.sh 下载失败！"
        return 1
    fi
    chmod +x ./rustdesktool.sh 
    _green "脚本更新成功"
    exec bash ./rustdesktool.sh
}

check_rustdesk_status() {
    local hbbs_service="/usr/lib/systemd/system/RustDeskHbbs.service"
    local hbbr_service="/usr/lib/systemd/system/RustDeskHbbr.service"

    # 判断是否安装
    if [[ ! -f "$hbbs_service" || ! -f "$hbbr_service" ]]; then
        echo "未安装"
        return
    fi

    # 判断是否运行
    if systemctl is-active --quiet RustDeskHbbs && systemctl is-active --quiet RustDeskHbbr; then
        echo "运行中"
    else
        echo "未运行"
    fi
}



#查看状态
viewstatus() {
    echo
    _blue 'RustDeskHbbs status:'
    systemctl status RustDeskHbbs | awk '/Active/'
    _blue 'RustDeskHbbr status:'
    systemctl status RustDeskHbbr | awk '/Active/'
    _blue 'net status:'
    netstat -tuln | grep -E ":(21115|21116|21117|21118|21119)\b"
}

startservice() {
    _blue "启动服务"
    (
        systemctl start RustDeskHbbs > /dev/null 2>&1
        systemctl start RustDeskHbbr > /dev/null 2>&1
    ) &
    local pid=$!
    loading $pid
    wait $pid
    _green "服务已启动"
}

stopservice() {
    _blue "停止服务"
    (
        systemctl stop RustDeskHbbs > /dev/null 2>&1
        systemctl stop RustDeskHbbr > /dev/null 2>&1
    ) &
    local pid=$!
    loading $pid
    wait $pid
    _yellow "服务已停止"
}

viewkey() {
    echo
    _blue '公钥:'
    cat $installdirectory/id_ed25519.pub
    echo
    echo
}

#卸载
uninstall() {
    read -rp "确认卸载？(y/N): " c
    [[ $c == y ]] || return
    stopservice

    systemctl disable RustDeskHbbs
    systemctl disable RustDeskHbbr

    rm -rf $installdirectory
    rm -rf /usr/lib/systemd/system/RustDeskHbbs.service
    rm -rf /usr/lib/systemd/system/RustDeskHbbr.service

    _blue '已卸载'
    echo
}

#安装
install() {

    #检查是否已安装
    if [ -f "/usr/lib/systemd/system/RustDeskHbbr.service" ]; then
        _yellow '检测到文件存在 卸载旧版...'
        uninstall
    fi

    _blue "开始安装"
    mkdir -p $installdirectory
    
     # 检查并安装 wget
    if ! command -v wget >/dev/null 2>&1; then
        _yellow "未检测到 wget，正在安装..."
        ${installType} wget || { _red "wget 安装失败"; exit 1; }
    fi

    # 检查并安装 unzip
    if ! command -v unzip >/dev/null 2>&1; then
        _yellow "未检测到 unzip，正在安装..."
        ${installType} unzip || { _red "unzip 安装失败"; exit 1; }
    fi

    _blue "下载安装文件"
    if ! download_file "https://github.com/rustdesk/rustdesk-server/releases/download/$rustdeskserverversion/rustdesk-server-linux-amd64.zip" "$installdirectory"; then
        _red "rustdesk-server-linux-amd64.zip下载失败！"
        exit 1
    fi

    _blue "解压文件"
    (
        unzip $installdirectory/rustdesk-server-linux-amd64.zip -d $installdirectory > /dev/null 2>&1
    ) &
    local pid=$!
    loading $pid
    wait $pid

    mv $installdirectory/amd64/* $installdirectory/

    rm $installdirectory/rustdesk-server-linux-amd64.zip
    rm -r $installdirectory/amd64

    chmod +x $installdirectory/hbbr
    chmod +x $installdirectory/hbbs

    if [ ! -f "/usr/lib/systemd/system/RustDeskHbbr.service" ]; then
        #文件不存在
        touch /usr/lib/systemd/system/RustDeskHbbr.service
    fi

    cat <<EOF >/usr/lib/systemd/system/RustDeskHbbr.service
[Unit]
Description=RustDesk Hbbr
After=network.target

[Service]
User=root
Type=simple
WorkingDirectory=$installdirectory
ExecStart=$installdirectory/hbbr
ExecStop=/bin/kill -TERM \$MAINPID
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    if [ ! -f "/usr/lib/systemd/system/RustDeskHbbs.service" ]; then
        #文件不存在
        touch /usr/lib/systemd/system/RustDeskHbbs.service
    fi

    cat <<EOF >/usr/lib/systemd/system/RustDeskHbbs.service
[Unit]
Description=RustDesk Hbbs
After=network.target

[Service]
User=root
Type=simple
WorkingDirectory=$installdirectory
ExecStart=$installdirectory/hbbs
ExecStop=/bin/kill -TERM \$MAINPID
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    _blue "配置开机自启"
    systemctl enable RustDeskHbbs
    systemctl enable RustDeskHbbr
    echo

    #启动服务
    startservice

    #printf "\033[H\033[2J"
    echo
    _green '安装完成'
    viewkey

    local ip="$(wget -q -T10 -O- ipinfo.io/ip)"
    _green '公网 IP:'
    echo $ip
    echo
    _yellow "请手动放行防火墙 TCP & UDP端口 21115-21119"
    echo

}


#主函数
main() {
    options=("安装" install "卸载" uninstall "查看状态" viewstatus "查看key" viewkey "启动服务" startservice "停止服务" stopservice "升级脚本" updateself)
    menu "${options[@]}"
}

checkSystem
main
