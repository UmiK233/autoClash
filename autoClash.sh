#!/bin/bash
# 注意：本脚本仅用于技术学习，请勿用于非法网络代理配置！

if [ "$USER" = "root" ]; then
    echo "警告：请以普通用户执行本脚本" >&2
    return 1
fi

CURRENT_DIR=$(pwd)
HOME_DIR="$HOME"
CLASH_USER_CONFIG="${HOME_DIR}/.config/clash"
CLASH_SYSTEM_CONFIG="/etc/clash"  # 需 root 权限
# 特别检查
if [ -z "$(cat "config.yaml")" ]; then
    echo "请配置config.yaml后再执行本脚本!" >&2
    return 1
fi

# 检查必要文件
check_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "错误：文件 $file 不存在！" >&2
        exit 1 # main函数中的check_file函数使用return只能结束check_file,故使用exit 1结束终端(如果使用source)
    fi
}

mkdir -p "$CLASH_USER_CONFIG"

check_file "config.yaml" && cp "config.yaml" "$CLASH_USER_CONFIG/config.yaml" && echo "已复制配置到用户目录：$CLASH_USER_CONFIG"
check_file "Country.mmdb" && cp "Country.mmdb" "$CLASH_USER_CONFIG/Country.mmdb"
check_file "clash" && [ ! -x "clash" ] && { sudo chmod +x clash; }


# 以下为需要 root 权限的系统级操作（需 sudo）
if [ "$(id -u)" -ne 0 ]; then
    sudo -v || { echo "错误：获取 sudo 权限失败！" >&2; return 1; }
fi

sudo mkdir -p "$CLASH_SYSTEM_CONFIG"
sudo cp -r "$CLASH_USER_CONFIG"/* "$CLASH_SYSTEM_CONFIG/"

if [ ! -f "/usr/local/bin/clash" ]; then
    sudo cp "clash" "/usr/local/bin/clash"
fi

sudo touch /etc/systemd/system/clash.service
sudo chmod a+w /etc/systemd/system/clash.service
sudo cat > /etc/systemd/system/clash.service <<EOF
[Unit]
Description=Clash Daemon
After=network-online.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/local/bin/clash -d ${CLASH_SYSTEM_CONFIG}

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now clash
echo "系统服务已安装，状态："
sudo systemctl status clash

# 添加代理函数到 .bashrc（带去重标记）
MARKER="# ADDED_AT_$(date +'%Y-%m-%d %H:%M:%S')"
PROXY_FUNCTION=$"function proxy_on() {\nexport http_proxy=http://127.0.0.1:7890\nexport https_proxy=http://127.0.0.1:7890\nexport no_proxy=127.0.0.1,localhost\necho -e \"\033[32m[√] system proxy have opened\033[0m\" \n}\n\nfunction proxy_off(){\nunset http_proxy\nunset https_proxy\nunset no_proxy\necho -e \"\033[31m[×] system proxy have closed\033[0m\"\n}"
sudo chown $USER:$USER ~/.bashrc
if ! grep -q "proxy_on" ~/.bashrc; then
	cp ~/.bashrc "${HOME_DIR}/.bashrc_$(date +'%Y-%m-%d %H:%M:%S').bak"
    echo -e "\n${MARKER}\n${PROXY_FUNCTION}" >> ~/.bashrc
    echo "已添加代理函数到 .bashrc"
    exec bash  # 重启当前Shell，会丢失当前会话的其他状态
else
    echo "代理函数已存在，无需重复添加"
fi

