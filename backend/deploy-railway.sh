#!/usr/bin/env bash
# ============================================================
# AI Crew Backend - Railway 部署脚本
# ============================================================
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="/Users/eric/dreame/code/Clawith-main/backend"

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  AI Crew Backend - Railway Deploy${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# 1. 检查 Railway CLI
echo -e "${YELLOW}[1/6]${NC} 检查 Railway CLI..."
if command -v railway &>/dev/null; then
    RAILWAY_VERSION=$(railway --version)
    echo -e "${GREEN}已安装: $RAILWAY_VERSION${NC}"
else
    echo -e "${RED}Railway CLI 未安装${NC}"
    echo "请运行以下命令安装:"
    echo "  npm install -g @railway/cli"
    exit 1
fi

# 2. 检查登录状态
echo -e "${YELLOW}[2/6]${NC} 检查 Railway 登录状态..."
if ! railway whoami &>/dev/null; then
    echo -e "${YELLOW}需要登录 Railway${NC}"
    railway login
fi
echo -e "${GREEN}已登录${NC}"

# 3. 初始化 Railway 项目
echo -e "${YELLOW}[3/6]${NC} 初始化 Railway 项目..."
cd "$PROJECT_DIR"

if [ -f ".railway.json" ]; then
    echo -e "${GREEN}Raily 项目已存在${NC}"
else
    echo -e "${CYAN}创建新的 Railway 项目...${NC}"
    railway init
fi

# 4. 添加 PostgreSQL
echo -e "${YELLOW}[4/6]${NC} 添加 PostgreSQL 数据库..."
echo -e "${CYAN}运行 'railway add' 来添加 PostgreSQL 和 Redis${NC}"
echo -e "${YELLOW}或者手动在 Railway Dashboard 中添加${NC}"
echo ""
read -p "是否现在添加数据库? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    railway add
fi

# 5. 配置环境变量
echo -e "${YELLOW}[5/6]${NC} 配置环境变量..."
echo -e "${CYAN}设置必要的安全配置...${NC}"

# 生成随机密钥
SECRET_KEY=$(openssl rand -hex 32)
JWT_SECRET_KEY=$(openssl rand -hex 32)

# 设置环境变量
railway variables set SECRET_KEY "$SECRET_KEY"
railway variables set JWT_SECRET_KEY "$JWT_SECRET_KEY"
railway variables set DEBUG "false"
railway variables set CORS_ORIGINS '["*"]'

# 如果数据库已连接，Railway 会自动设置 DATABASE_URL
# 如果需要手动设置
echo ""
echo -e "${YELLOW}如果 DATABASE_URL 未自动设置，请手动配置:${NC}"
echo "  railway variables set DATABASE_URL 'postgresql://...'"

# 6. 部署
echo -e "${YELLOW}[6/6]${NC} 部署到 Railway..."
echo ""
railway up

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  部署完成！${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}查看部署状态:${NC}"
echo "  railway status"
echo ""
echo -e "${CYAN}查看日志:${NC}"
echo "  railway logs"
echo ""
echo -e "${CYAN}获取公网 URL:${NC}"
echo "  railway domain"
echo ""
