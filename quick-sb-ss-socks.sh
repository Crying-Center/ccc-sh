#!/bin/bash

# 1. 自动安装 expect 工具（用于模拟键盘输入）
echo "正在安装必要组件..."
if [ -f /etc/debian_version ]; then
    apt-get update && apt-get install -y expect wget
elif [ -f /etc/redhat-release ]; then
    yum install -y expect wget
else
    echo "不支持的系统类型，请手动安装 expect"
    exit 1
fi

# 2. 生成随机五位数端口和随机密码/用户名
RANDOM_PORT_SS=$(shuf -i 10000-65535 -n 1)
RANDOM_PORT_SOCKS=$(shuf -i 10000-65535 -n 1)
# 确保两个端口不重复
while [ "$RANDOM_PORT_SS" -eq "$RANDOM_PORT_SOCKS" ]; do
    RANDOM_PORT_SOCKS=$(shuf -i 10000-65535 -n 1)
done

RANDOM_PASS_SS=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 12)
RANDOM_USER_SOCKS=$(tr -dc 'a-z' < /dev/urandom | head -c 6)
RANDOM_PASS_SOCKS=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 12)

echo "----------------------------------------"
echo "生成的随机数据如下："
echo "SS 端口: $RANDOM_PORT_SS | 密码: $RANDOM_PASS_SS"
echo "Socks5 端口: $RANDOM_PORT_SOCKS | 用户名: $RANDOM_USER_SOCKS | 密码: $RANDOM_PASS_SOCKS"
echo "----------------------------------------"

# 3. 运行你提供的 sing-box 安装脚本
echo "开始安装 sing-box..."
bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)

# 检查 sb 命令是否安装成功
if ! command -v sb &> /dev/null; then
    echo "错误：sing-box 脚本似乎没有安装成功，找不到 'sb' 命令。"
    exit 1
fi

# 4. 使用 expect 自动化添加 SS 节点
# 步骤：sb -> 1 -> 8 -> 端口 -> 密码
echo "正在自动添加 Shadowsocks (SS) 节点..."
expect <<EOF
set timeout 30
spawn sb
expect "请输入数字" { send "1\r" }
expect "请输入数字" { send "8\r" }
expect "请输入端口" { send "$RANDOM_PORT_SS\r" }
expect "请输入密码" { send "$RANDOM_PASS_SS\r" }
expect eof
EOF

echo "----------------------------------------"

# 5. 使用 expect 自动化添加 Socks5 节点
# 步骤：sb -> 1 -> 21 -> 端口 -> 用户名 -> 密码
echo "正在自动添加 Socks5 节点..."
expect <<EOF
set timeout 30
spawn sb
expect "请输入数字" { send "1\r" }
expect "请输入数字" { send "21\r" }
expect "请输入端口" { send "$RANDOM_PORT_SOCKS\r" }
expect "请输入用户名" { send "$RANDOM_USER_SOCKS\r" }
expect "请输入密码" { send "$RANDOM_PASS_SOCKS\r" }
expect eof
EOF

echo "----------------------------------------"
echo "所有节点添加完成！"
echo "你可以运行 'sb' 命令来查看、管理或获取完整的节点链接。"
echo "----------------------------------------"