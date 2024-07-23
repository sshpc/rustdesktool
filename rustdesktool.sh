#!/bin/bash
export LANG=en_US.UTF-8

#初始化
initself() {
    version='1.2.1'
    #官方版本号
    rustdeskserverversion='1.1.10-3'
    installType='yum -y install'
    removeType='yum -y remove'
    upgrade="yum -y update"
    release='linux'
    #菜单名称(默认首页)
    menuname='首页'
    #安装目录
    installdirectory='/usr/local/rustdesk-sever'

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
    #按任意键继续
    waitinput() {
        echo
        read -n1 -r -p "按任意键继续...(退出 Ctrl+C)"
    }
    #菜单头部
    menutop() {
        clear
        _green '# RustDesk-Server 安装脚本'
        _green '# Github <https://github.com/sshpc/rustdesktool>'
        _blue '# You Server:'${release}
        echo
        _blue ">~~~~~~~~~~~~~~  rustdesk-server tool ~~~~~~~~~~~~<  v: $version"
        echo
        _yellow "当前菜单: $menuname "
        echo
    }
    #菜单渲染
    menu() {
        menutop
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
        echo
        printf '\033[0;31;36m%b\033[0m' "q: 退出  "
        if [[ "$number" != "" ]]; then printf '\033[0;31;36m%b\033[0m' "b: 返回  0: 首页"; fi
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
        elif [[ $number == 0 ]]; then
            main
        elif [[ $number == 'b' ]]; then
            ${FUNCNAME[3]}
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
    clear
}

#检查系统
checkSystem() {
    if [[ -n $(find /etc -name "redhat-release") ]] || grep </proc/version -q -i "centos"; then
        release="centos"
        installType='yum -y install'
        removeType='yum -y remove'
        upgrade="yum update -y --skip-broken"
    elif [[ -f "/etc/issue" ]] && grep </etc/issue -q -i "debian" || [[ -f "/proc/version" ]] && grep </etc/issue -q -i "debian" || [[ -f "/etc/os-release" ]] && grep </etc/os-release -q -i "ID=debian"; then
        release="debian"
        installType='apt -y install'
        upgrade="apt update"
        removeType='apt -y autoremove'
    elif [[ -f "/etc/issue" ]] && grep </etc/issue -q -i "ubuntu" || [[ -f "/proc/version" ]] && grep </etc/issue -q -i "ubuntu"; then
        release="ubuntu"
        installType='apt -y install'
        upgrade="apt update"
        removeType='apt -y autoremove'
    elif [[ -f "/etc/issue" ]] && grep </etc/issue -q -i "Alpine" || [[ -f "/proc/version" ]] && grep </proc/version -q -i "Alpine"; then
        release="alpine"
        installType='apk add'
        upgrade="apk update"
        removeType='apt del'
    fi

    if [[ -z ${release} ]]; then
        echoContent red "\n不支持此系统\n"
        _red "$(cat /etc/issue)"
        _red "$(cat /proc/version)"
        exit 0
    fi
}

#脚本升级
updateself() {

    _blue '下载github最新版'
    wget -N http://raw.githubusercontent.com/sshpc/rustdesktool/main/rustdesktool.sh
    # 检查上一条命令的退出状态码
    if [ $? -eq 0 ]; then
        chmod +x ./rustdesktool.sh && ./rustdesktool.sh
    else
        _red "下载失败,请重试"
    fi

}

#查看状态
viewstatus() {
    echo
    _blue 'RustDeskHbbs status:'
    systemctl status RustDeskHbbs | awk '/Active/'
    echo
    _blue 'RustDeskHbbr status:'
    systemctl status RustDeskHbbr | awk '/Active/'
    echo
    _blue 'net status:'
    echo
    netstat -tuln | grep -E ":(21115|21116|21117|21118|21119)\b"
}

startservice() {
    _blue "启动服务"

    systemctl start RustDeskHbbs
    systemctl start RustDeskHbbr

    viewstatus
}

stopservice() {
    _blue "停止服务"

    systemctl stop RustDeskHbbs
    systemctl stop RustDeskHbbr

    viewstatus
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
        _yellow '检测到文件存在 覆盖安装...'
        uninstall
    fi

    _blue "开始安装"
    echo
    mkdir -p $installdirectory
    ${installType} wget
    ${installType} unzip

    # 下载链接列表#兼容国内环境
    links=(
        "https://gh.ddlc.top/https://github.com/rustdesk/rustdesk-server/releases/download/$rustdeskserverversion/rustdesk-server-linux-amd64.zip"
        "https://ghproxy.com/https://github.com/rustdesk/rustdesk-server/releases/download/$rustdeskserverversion/rustdesk-server-linux-amd64.zip"
        "https://github.com/rustdesk/rustdesk-server/releases/download/$rustdeskserverversion/rustdesk-server-linux-amd64.zip"
    )

    # 设置超时时间（秒）
    timeout=7

    # 遍历链接列表
    for link in "${links[@]}"; do
        echo "正在尝试下载：$link"

        # 使用 wget 下载文件，并设置超时时间
        wget --timeout="$timeout" "$link" -P $installdirectory

        # 检查 wget 的退出状态
        if [ $? -eq 0 ]; then
            echo "下载成功：$link"
            break # 下载成功，跳出循环
        else
            _yellow "下载失败，继续尝试下一个镜像链接"
        fi
    done

    if [ ! -f "$installdirectory/rustdesk-server-linux-amd64.zip" ]; then

        _red "尝试全部链接下载失败,请检查"
    fi
    unzip $installdirectory/rustdesk-server-linux-amd64.zip -d $installdirectory

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
ExecStart=$installdirectory/hbbr -k _
ExecStop=/bin/kill -TERM \$MAINPID

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
ExecStart=$installdirectory/hbbs -k _
ExecStop=/bin/kill -TERM \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

    _blue "配置开机自启"
    systemctl enable RustDeskHbbs
    systemctl enable RustDeskHbbr
    echo

    #启动服务
    startservice

    clear
    _green '安装成功'
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

    menuname='首页'
    options=("安装" install "卸载" uninstall "查看状态" viewstatus "查看key" viewkey "启动服务" startservice "停止服务" stopservice "升级脚本" updateself)
    menu "${options[@]}"
}

initself
checkSystem
main
