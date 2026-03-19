#!/usr/bin/env bash
# ============================================================
# AI Crew Frontend Vercel Deployment Script
# ============================================================
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 项目配置
PROJECT_NAME="aicrew-frontend"
PROJECT_DIR="/Users/eric/dreame/code/Clawith-main/frontend"

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  AI Crew Frontend - Vercel Deploy${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# 1. 检查 Vercel CLI
echo -e "${YELLOW}[1/6]${NC} 检查 Vercel CLI..."
if ! command -v vercel &>/dev/null; then
    echo -e "${RED}Vercel CLI 未安装，正在安装...${NC}"
    npm install -g vercel
fi

# 2. 检查登录状态
echo -e "${YELLOW}[2/6]${NC} 检查 Vercel 登录状态..."
VERCEL_USER=$(vercel whoami 2>&1)
if echo "$VERCEL_USER" | grep -q "Error\|Not logged in"; then
    echo -e "${RED}未登录 Vercel，请先运行: vercel login${NC}"
    exit 1
fi
echo -e "${GREEN}已登录为: $VERCEL_USER${NC}"

# 3. 清理旧配置
echo -e "${YELLOW}[3/6]${NC} 清理旧配置文件..."
cd "$PROJECT_DIR"
rm -rf .vercel
rm -f vercel.json
echo -e "${GREEN}已清理 .vercel 和 vercel.json${NC}"

# 4. 创建新的 vercel.json
echo -e "${YELLOW}[4/6]${NC} 创建 vercel.json 配置..."
cat > vercel.json << 'EOF'
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "installCommand": "npm install",
  "framework": "vite",
  "rewrites": [
    {
      "source": "/api/(.*)",
      "destination": "http://localhost:8008/api/$1"
    },
    {
      "source": "/ws/(.*)",
      "destination": "ws://localhost:8008/ws/$1"
    }
  ]
}
EOF
echo -e "${GREEN}vercel.json 已创建${NC}"

# 5. 更新 package.json 中的项目名称
echo -e "${YELLOW}[5/6]${NC} 更新 package.json 项目名称..."
sed -i '' 's/"name": "ai-crew-crew-frontend"/"name": "aicrew-frontend"/g' package.json
echo -e "${GREEN}package.json 已更新${NC}"

# 6. 部署到 Vercel
echo -e "${YELLOW}[6/6]${NC} 部署到 Vercel..."
echo ""
echo -e "${CYAN}项目名称: ${PROJECT_NAME}${NC}"
echo ""

# 链接并部署（使用 --yes 自动确认）
vercel --yes --prod --name "$PROJECT_NAME"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  部署完成！${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}查看部署详情:${NC}"
echo "  vercel ls                    # 列出所有部署"
echo "  vercel inspect <url>         # 查看特定部署"
echo ""
