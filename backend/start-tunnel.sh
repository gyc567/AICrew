#!/usr/bin/env bash
# ============================================================
# AI Crew 本地后端 + Cloudflare Tunnel 部署脚本
# ============================================================
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKEND_PORT=${1:-8008}
TUNNEL_NAME="aicrew-backend"

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  AI Crew Backend Tunnel Setup${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# 1. 检查 cloudflared
echo -e "${YELLOW}[1/5]${NC} 检查 cloudflared..."
if command -v cloudflared &>/dev/null; then
    CLOUDFLARED_VERSION=$(cloudflared --version)
    echo -e "${GREEN}已安装: $CLOUDFLARED_VERSION${NC}"
else
    echo -e "${RED}cloudflared 未安装${NC}"
    echo "请运行以下命令安装:"
    echo "  macOS: brew install cloudflare/cloudflare/cloudflared"
    echo "  Linux: curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared"
    exit 1
fi

# 2. 检查本地后端
echo -e "${YELLOW}[2/5]${NC} 检查本地后端..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT/api/health | grep -q "200"; then
    echo -e "${GREEN}本地后端运行正常 (端口 $BACKEND_PORT)${NC}"
else
    echo -e "${YELLOW}警告: 本地后端未运行或健康检查失败${NC}"
    echo "请确保后端运行在端口 $BACKEND_PORT"
    echo "是否继续? (Ctrl+C 退出)"
    read -p ""
fi

# 3. 创建 tunnel
echo -e "${YELLOW}[3/5]${NC} 创建/检查 Cloudflare Tunnel..."
mkdir -p ~/.cloudflared

if cloudflared tunnel list 2>/dev/null | grep -q "$TUNNEL_NAME"; then
    echo -e "${GREEN}Tunnel '$TUNNEL_NAME' 已存在${NC}"
else
    echo -e "${CYAN}创建新 Tunnel...${NC}"
    cloudflared tunnel create "$TUNNEL_NAME"
fi

# 获取 tunnel ID
TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
echo -e "${GREEN}Tunnel ID: $TUNNEL_ID${NC}"

# 4. 创建配置文件
echo -e "${YELLOW}[4/5]${NC} 创建 tunnel 配置文件..."
cat > ~/.cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: ~/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: localhost
    service: http://localhost:$BACKEND_PORT
  - service: http_status:404
EOF
echo -e "${GREEN}配置文件已创建: ~/.cloudflared/config.yml${NC}"

# 5. 启动 tunnel
echo -e "${YELLOW}[5/5]${NC} 启动 Cloudflare Tunnel..."
echo ""
echo -e "${CYAN}启动隧道服务...${NC}"
echo -e "${YELLOW}按 Ctrl+C 停止隧道${NC}"
echo ""

# 启动 cloudflared tunnel
cloudflared tunnel --no-autoupdate run "$TUNNEL_NAME"
