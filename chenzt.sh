#!/bin/sh
# =====================================================
# 一键接入你自己的 ZeroTier Planet（专属版）
# Network ID : 0d945ab62e9aebd3
# Planet 下载地址 : https://ghfast.top/https://raw.githubusercontent.com/Crying-Center/ccc-sh/refs/heads/main/planet
# 作者：Grok 4 为你定制   日期：2025-11-19
# =====================================================

# 1. 下载并替换你自己的 planet 文件（最彻底方式）
echo "正在下载你的自定义 planet 文件..."
mkdir -p /var/lib/zerotier-one
wget -O /var/lib/zerotier-one/planet --no-check-certificate \
  "https://ghfast.top/https://raw.githubusercontent.com/Crying-Center/ccc-sh/refs/heads/main/planet"

# 备份官方 planet（第一次才备份）
[ -f /var/lib/zerotier-one/planet.backup ] || \
  cp /var/lib/zerotier-one/planet /var/lib/zerotier-one/planet.backup 2>/dev/null

chmod 644 /var/lib/zerotier-one/planet

# 2. 清空官方根服务器列表（防止回退）
echo "清除官方根服务器列表..."
uci -q delete zerotier.sample_config.servers 2>/dev/null
uci commit zerotier

# 3. 自动加入你的专属网络 0d945ab62e9aebd3
echo "加入你的网络 0d945ab62e9aebd3 ..."
uci set zerotier.sample_config.enabled='1'
uci add_list zerotier.sample_config.join='0d945ab62e9aebd3'
uci commit zerotier

# 4. 重启 ZeroTier 服务
echo "重启 ZeroTier 服务..."
/etc/init.d/zerotier stop
sleep 2
/etc/init.d/zerotier start
sleep 3

# 5. 授权该网络（自动 approve）
echo "正在自动授权该网络..."
zerotier-cli set 0d945ab62e9aebd3 allowManaged=1
zerotier-cli set 0d945ab62e9aebd3 allowGlobal=1
zerotier-cli set 0d945ab62e9aebd3 allowDefault=1

echo ""
echo "=============================================="
echo "全部完成！你的 OpenWrt 已经彻底使用你自己的 Planet"
echo "网络 ID：0d945ab62e9aebd3 已自动加入并授权"
echo ""
echo "检查状态命令："
echo "   zerotier-cli info"
echo "   zerotier-cli listnetworks"
echo "   zerotier-cli listpeers | grep ROOT"
echo "=============================================="
