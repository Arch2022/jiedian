#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/Quili.sh"

# 自动设置快捷键的功能
function check_and_set_alias() {
    local alias_name="quili"
    local profile_file="$HOME/.profile"

    # 检查快捷键是否已经设置
    if ! grep -q "$alias_name" "$profile_file"; then
        echo "设置快捷键 '$alias_name' 到 $profile_file"
        echo "alias $alias_name='bash $SCRIPT_PATH'" >> "$profile_file"
        # 添加提醒用户激活快捷键的信息
        echo "快捷键 '$alias_name' 已设置。请运行 'source $profile_file' 来激活快捷键，或重新登录。"
    else
        # 如果快捷键已经设置，提供一个提示信息
        echo "快捷键 '$alias_name' 已经设置在 $profile_file。"
        echo "如果快捷键不起作用，请尝试运行 'source $profile_file' 或重新登录。"
    fi
}

# 节点安装功能 (Linux)
function install_node_linux() {
    # 检查并安装 gvm
    if ! command -v gvm &> /dev/null; then
        echo "gvm is not installed."
        read -p "Do you want to install gvm using snap? (y/n): " choice
        if [ "$choice" = "y" ]; then
            sudo apt install snapd
            sudo snap install gvm
        else
            curl -sSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
        fi
        source ~/.bashrc
    fi

    # 增加swap空间
    sudo mkdir /swap
    sudo fallocate -l 24G /swap/swapfile
    sudo chmod 600 /swap/swapfile
    sudo mkswap /swap/swapfile
    sudo swapon /swap/swapfile
    echo '/swap/swapfile swap swap defaults 0 0' >> /etc/fstab

    # 向/etc/sysctl.conf文件追加内容
    echo -e "\n# 自定义最大接收和发送缓冲区大小" >> /etc/sysctl.conf
    echo "net.core.rmem_max=600000000" >> /etc/sysctl.conf
    echo "net.core.wmem_max=600000000" >> /etc/sysctl.conf

    echo "配置已添加到/etc/sysctl.conf"

    # 重新加载sysctl配置以应用更改
    sysctl -p

    echo "sysctl配置已重新加载"

    # 更新并升级Ubuntu软件包
    sudo apt update && sudo apt -y upgrade

    # 安装wget、screen和git等组件
    sudo apt install git ufw bison screen binutils gcc make bsdmainutils -y

    # 安装Go
    if ! gvm list | grep -q "go1.20.2"; then
        echo "go1.20.2 is not installed."
        read -p "Do you want to install it automatically? (y/n): " choice
        if [ "$choice" = "y" ]; then
            gvm install go1.20.2 || gvm install go1.20.2 -B
            gvm use go1.20.2
        else
            echo "Please install go1.20.2 manually using 'gvm install go1.20.2' or 'gvm install go1.20.2 -B'."
            exit 1
        fi
    fi

    # 克隆仓库
    git clone https://github.com/a3165458/ceremonyclient.git

    # 构建Qclient
    cd ceremonyclient/client
    GOEXPERIMENT=arenas go build -o qclient main.go || {
        echo "Failed to build qclient. Check the logs in ceremonyclient/client for details."
        exit 1
    }
    sudo cp $HOME/ceremonyclient/client/qclient /usr/local/bin

    # 进入ceremonyclient/node目录
    cd <span class="math-inline">HOME
cd ceremonyclient/node
git switch release
\# 赋予执行权限
chmod \+x release\_autorun\.sh
\# 创建一个screen会话并运行命令
screen \-dmS Quili bash \-c '\./release\_autorun\.sh'
echo \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\= 安装完成 \=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=\=
\}
\# 节点安装功能 \(macOS\)
function install\_node\_mac\(\) \{
\# 安装 Homebrew 包管理器（如果尚未安装）
if \! command \-v brew &\> /dev/null; then
echo "Homebrew 未安装。正在安装 Homebrew\.\.\."
/bin/bash \-c "</span>(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # 更新 Homebrew 并安装必要的软件包
    brew update
    brew install wget git screen bison gcc make

    # 安装 gvm
    if ! command -v gvm &> /dev/null; then
        echo "gvm is not installed."
        read -p "Do you want to install gvm? (y/n): " choice
        if [ "$choice" = "y" ]; then
            bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
            source <span class="math-inline">HOME/\.gvm/scripts/gvm
</0\>else
echo "Please install gvm manually\."
exit 1
fi
fi
\# 获取系统架构
ARCH\=</span>(uname -m)

    # 安装并使用 go1.4 作为 bootstrap
    gvm install go1.4 -B
    gvm use go1.4
    export GOROOT_BOOTSTRAP=$GOROOT

    # 根据系统架构安装相应的 Go 版本
    if [ "$ARCH" = "x86_64" ]; then
      gvm install go1.17.13
      gvm use go1.17.13
      export GOROOT_BOOTSTRAP=$GOROOT

      gvm install go1.20.2
      gvm use go1.20.2
    elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
      gvm install go1.17.13 -B
      gvm use go1.17.13
      export GOROOT_BOOTSTRAP=$GOROOT

      gvm install go1.20.2 -B
      gvm use go1.20.2
    else
      echo "无法支持的版本: $ARCH"
      exit 1
    fi

    # 克隆仓库
    git clone https://github.com/a3165458/ceremonyclient.git

    # 进入 ceremonyclient/node 目录
    cd $HOME
    cd ceremonyclient/node
    git switch release

    # 赋予执行权限
    chmod +x release_autorun.sh

    # 创建一个 screen 会话并运行命令
    screen -dmS Quili bash -c './release_autorun.sh'


    # 构建 Qclient
    cd ceremonyclient/client
    GOEXPERIMENT=arenas go build -o qclient main.go
    sudo cp $HOME/ceremonyclient/client/qclient /usr/local/bin


    echo ====================================== 安装完成 =========================================

}

# 查看常规版本节点日志
function check_service_status() {
    screen -r Quili
   
}

# 独立启动
function run_node() {
    screen -dmS Quili bash -c "source /root/.gvm/scripts/gvm && gvm use go1.20.2 && cd ~/ceremonyclient/node && ./release_autorun.sh"

    echo "=======================已启动quilibrium 挖矿 请使用screen 命令查询状态========================================="
}

function add_snapshots() {
wget http://94.16.31.160/store.tar.gz
tar -xzf store.tar.gz
cd ~/ceremonyclient/node/.config
rm -rf store
cd ~
mv store ~/ceremonyclient/node/.config

screen -dmS Quili bash -c 'source /root/.gvm/scripts/gvm && gvm use go1.20.2 && cd ~/ceremonyclient/node &&
