#!/usr/bin/env bash
# ============================================================
# AI Crew 本地后端 + Ngrok 部署脚本（备选方案）
# ============================================================
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKEND_PORT=${1:-8008}
NGROK_AUTH_TOKEN=${2:-""}

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  AI Crew Backend + Ngrok Setup${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# 1. 检查 ngrok
echo -e "${YELLOW}[1/6]${NC} 检查 ngrok..."
if command -v ngrok &>/dev/null; then
    NGROK_VERSION=$(ngrok version 2>/dev/null | head -1)
    echo -e "${GREEN}已安装: $NGROK_VERSION${NC}"
else
    echo -e "${RED}ngrok 未安装${NC}"
    echo "请运行以下命令安装:"
    echo "  macOS: brew install ngrok"
    echo "  或下载: https://ngrok.com/download"
    exit 1
fi

# 2. 检查 ngrok 配置
echo -e "${YELLOW}[2/6]${NC} 检查 ngrok 配置..."
if [ -n "$NGROK_AUTH_TOKEN" ]; then
    echo -e "${CYAN}配置 Ngrok Auth Token...${NC}"
    ngrok config add-authtoken "$NGROK_AUTH_TOKEN"
elif ! ngrok config check &>/dev/null; then
    echo -e "${RED}错误: Ngrok 未配置 Auth Token${NC}"
    echo ""
    echo "请到 https://ngrok.com 注册并获取 Authtoken"
    echo "然后运行: ngrok config add-authtoken <your-token>"
    echo ""
    echo "或者直接运行此脚本并传入 token:"
    echo "  ./start-ngrok.sh 8008 <your-ngrok-token>"
    exit 1
fi

# 3. 检查本地后端
echo -e "${YELLOW}[3/6]${NC} 检查本地后端..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT/api/health | grep -q "200"; then
    echo -e "${GREEN}本地后端运行正常 (端口 $BACKEND_PORT)${NC}"
else
    echo -e "${YELLOW}警告: 本地后端未运行或健康检查失败${NC}"
    echo "请确保后端运行在端口 $BACKEND_PORT"
fi

# 4. 获取临时 URL（不需要账户）
echo -e "${YELLOW}[4/6]${NC} 启动 Ngrok (临时 URL)..."
echo ""

# 在后台启动 ngrok
ngrok http $BACKEND_PORT --log=stdout > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!

# 等待 ngrok 启动
sleep 5

# 获取 URL
if [ -f /tmp/ngrok.log ]; then
    echo -e "${CYAN}Ngrok 日志:${NC}"
    tail -20 /tmp/ngrok.log
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Ngrok 已启动${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}查看 Ngrok Web UI:${NC}"
echo "  curl http://localhost:4040/api/tunnels"
echo ""
echo -e "${YELLOW}获取公网 URL:${NC}"
echo "  curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'"
echo ""
echo -e "${RED}按 Ctrl+C 停止 Ngrok${NC}"
echo ""

# 等待用户中断
wait $NGROK_PID
