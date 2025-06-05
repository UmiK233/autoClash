#!/bin/bash
# 注意：本脚本仅用于技术学习，请勿用于非法网络代理配置！

if [ "$USER" = "root" ]; then
    echo "警告：请以普通用户执行本脚本" >&2
    return 1
fi

CLASH_USER_CONFIG="${HOME_DIR}/.config/clash"
CLASH_SYSTEM_CONFIG="/etc/clash"
CLASH_SYSTEM_SERVICE="/etc/systemd/system/clash.service"
CLASH_USR_LOCAL="/usr/local/bin/clash"

sudo rm -rf $CLASH_USER_CONFIG
sudo rm -rf $CLASH_SYSTEM_CONFIG # 删除配置文件目录
sudo rm -f /etc/systemd/system/clash.service # 删除服务文件
sudo rm -f /usr/local/bin/clash #删除clash二进制执行文件


#停止服务
systemctl daemon-reload
systemctl stop clash.service

# 删除代理函数
# 从.bashrc中提取MARKER行（包含时间戳）
MARKER_LINE=$(grep '# ADDED_AT_' ~/.bashrc | tail -1)

if [ -z "$MARKER_LINE" ]; then
    echo "未找到代理配置标记，无需删除"
else
    sed -i.bak "/$(grep '# ADDED_AT_' ~/.bashrc | tail -1)/,/closed^\[\[0m\"}/d" ~/.bashrc
fi
sudo rm -f ~/.bashrc_*

echo "已成功卸载clash"
exec bash  # 重启当前Shell，会丢失当前会话的其他状态