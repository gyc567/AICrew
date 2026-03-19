#!/usr/bin/env bash
# ============================================================
# AI Crew Backend - Fly.io 部署脚本（完全免费方案）
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
echo -e "${CYAN}  AI Crew Backend - Fly.io Deploy${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# 1. 检查 flyctl
echo -e "${YELLOW}[1/7]${NC} 检查 Fly.io CLI..."
if command -v flyctl &>/dev/null; then
    FLY_VERSION=$(flyctl version)
    echo -e "${GREEN}已安装: $FLY_VERSION${NC}"
else
    echo -e "${RED}Fly.io CLI 未安装${NC}"
    echo "请运行以下命令安装:"
    echo "  macOS: brew install flyctl/tap/flyctl"
    echo "  Linux: curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# 2. 检查登录状态
echo -e "${YELLOW}[2/7]${NC} 检查 Fly.io 登录状态..."
if ! flyctl auth whoami &>/dev/null; then
    echo -e "${YELLOW}需要登录 Fly.io${NC}"
    flyctl auth login
fi
echo -e "${GREEN}已登录${NC}"

# 3. 初始化 Fly.io 项目
echo -e "${YELLOW}[3/7]${NC} 初始化 Fly.io 项目..."
cd "$PROJECT_DIR"

if [ -f "fly.toml" ]; then
    echo -e "${GREEN}Fly.io 项目已存在${NC}"
else
    echo -e "${CYAN}创建新的 Fly.io 项目...${NC}"
    flyctl launch --no-deploy
fi

# 4. 创建 Fly.io 配置文件
echo -e "${YELLOW}[4/7]${NC} 配置 Fly.io..."
cat > fly.toml << 'EOF'
app = "aicrew-backend"

[build]
  dockerfile = "Dockerfile"

[env]
  PORT = "8080"
  HOST = "0.0.0.0"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = false
  auto_start_machines = true
  min_machines_running = 1

[[vm]]
  memory = "512mb"
  cpu_kind = "shared"
  cpus = 1
  snapshot_retention = 5

[metrics]
  port = 9090
  path = "/metrics"
EOF

echo -e "${GREEN}fly.toml 已创建${NC}"

# 5. 设置机密环境变量
echo -e "${YELLOW}[5/7]${NC} 设置环境变量..."
echo -e "${CYAN}生成安全密钥...${NC}"

SECRET_KEY=$(openssl rand -hex 32)
JWT_SECRET_KEY=$(openssl rand -hex 32)

flyctl secrets set SECRET_KEY="$SECRET_KEY"
flyctl secrets set JWT_SECRET_KEY="$JWT_SECRET_KEY"
flyctl secrets set DEBUG="false"
flyctl secrets set CORS_ORIGINS='["*"]'

# 6. 配置数据库
echo -e "${YELLOW}[6/7]${NC} 配置 PostgreSQL..."
echo ""
echo -e "${CYAN}推荐使用 Supabase 免费 PostgreSQL:${NC}"
echo "  1. 访问 https://supabase.com 注册"
echo "  2. 创建新项目"
echo "  3. 在 Settings → Connection String 获取 URL"
echo "  4. 运行以下命令:"
echo "     flyctl secrets set DATABASE_URL='postgresql://postgres:xxx@db.xxx.supabase.co:5432/postgres'"
echo ""
echo -e "${CYAN}或者使用 Railway 的 PostgreSQL（带 $5 免费额度）:${NC}"
echo "  1. 访问 https://railway.app 注册"
echo "  2. 创建 PostgreSQL 数据库"
echo "  3. 复制 Connection URL"
echo "  4. 运行:"
echo "     flyctl secrets set DATABASE_URL='postgresql://...'"
echo ""

# 7. 部署
echo -e "${YELLOW}[7/7]${NC} 部署到 Fly.io..."
echo ""
read -p "是否立即部署? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    flyctl deploy
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  部署配置完成！${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}查看状态:${NC}"
echo "  flyctl status"
echo ""
echo -e "${CYAN}查看日志:${NC}"
echo "  flyctl logs"
echo ""
echo -e "${CYAN}获取公网 URL:${NC}"
echo "  flyctl apps list"
echo "  flyctl info"
echo ""
