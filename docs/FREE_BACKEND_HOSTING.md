# 免费后端服务器部署方案分析

## 后端技术栈分析

### 核心依赖

| 组件 | 技术 | 说明 |
|------|------|------|
| **语言** | Python 3.12 | ✅ 主流语言，主流平台支持 |
| **框架** | FastAPI + Uvicorn | ✅ Serverless 友好 |
| **数据库** | PostgreSQL | 需要外部服务 |
| **缓存** | Redis | 需要外部服务 |
| **WebSocket** | 原生支持 | ✅ FastAPI 内置 |
| **后台任务** | asyncio | ✅ 原生支持 |
| **文件存储** | 本地文件系统 | 需要持久化存储 |
| **容器支持** | Docker SDK | ⚠️ 需要 Docker Socket |

### 特殊依赖

| 依赖 | 用途 | 部署影响 |
|------|------|----------|
| `docker>=7.0.0` | Agent 容器管理 | ⚠️ 需要 Docker Socket（主流 Serverless 不支持） |
| `shadowsocks-libev` | Discord API 代理 | 可选，无代理可跳过 |
| `asyncpg` | PostgreSQL 异步驱动 | ✅ 原生支持 |

### ⚠️ 关键限制

**Docker SDK 功能**需要访问宿主机的 Docker Socket，这在大多数 Serverless 平台上是不可用的。

影响的功能：
- Agent 容器启动/停止
- Docker 网络配置

**可行方案**：将 Agent 功能作为可选模块，在不支持 Docker 的平台上禁用。

---

## 免费部署方案对比

| 平台 | 免费额度 | PostgreSQL | Redis | Docker | WebSocket | sleep 问题 | 推荐度 |
|------|----------|------------|-------|--------|-----------|------------|--------|
| **Railway** | $5/月信用额 | ✅ $0.03/小时 | ✅ $0.03/小时 | ❌ | ✅ | ❌ 无 | ⭐⭐⭐⭐ |
| **Render** | 750小时/月 | ✅ 免费 | ❌ | ✅ | ✅ | ⚠️ 15分钟无活动 | ⭐⭐⭐ |
| **Fly.io** | 3共享CPU | ❌ 需第三方 | ❌ 需第三方 | ✅ | ✅ | ❌ 无 | ⭐⭐⭐⭐ |
| **Zeabur** | $1/月免费额 | ✅ 免费 | ✅ 免费 | ✅ | ✅ | ❌ 无 | ⭐⭐⭐⭐ |
| **Northflank** | $3/月免费额 | ✅ 免费 | ✅ 免费 | ✅ | ✅ | ❌ 无 | ⭐⭐⭐⭐ |
| **Deta Space** | 免费 | ❌ | ❌ | ❌ | ❌ | ❌ 无 | ⭐ 不适合 |
| **Cyclic** | 免费 | ❌ | ❌ | ❌ | ✅ | ❌ 无 | ⭐ 不适合 |
| **Vercel** | 免费 | ❌ | ❌ | ❌ | ⚠️ 有限 | ❌ 无 | ⭐ 不适合 |

---

## 推荐方案

### 🥇 方案一：Railway（最佳体验）

**优点**：
- ✅ Python/FastAPI 原生支持
- ✅ 一键部署 PostgreSQL + Redis
- ✅ 自动 HTTPS
- ✅ 持久化存储
- ✅ $5/月信用额足够运行小项目

**缺点**：
- ❌ Docker Socket 不支持（Agent 容器功能需禁用）
- ❌ 超过额度需付费

**部署步骤**：

```bash
# 1. 安装 Railway CLI
npm install -g @railway/cli

# 2. 登录
railway login

# 3. 初始化项目
cd backend
railway init

# 4. 添加 PostgreSQL
railway add

# 5. 部署
railway up
```

**环境变量配置**：
```
DATABASE_URL = railway 提供的 URL
REDIS_URL = railway 提供的 URL
SECRET_KEY = 随机密钥
JWT_SECRET_KEY = 随机密钥
```

---

### 🥈 方案二：Fly.io（完全免费）

**优点**：
- ✅ 完全免费
- ✅ Docker 原生支持
- ✅ 持久化卷
- ✅ 全球 CDN
- ✅ WebSocket 支持

**缺点**：
- ❌ 需要自建/第三方 PostgreSQL
- ❌ 需要自建/第三方 Redis
- ⚠️ 配置相对复杂

**部署步骤**：

```bash
# 1. 安装 flyctl
brew install flyctl/tap/flyctl

# 2. 登录
fly auth login

# 3. 创建应用
cd backend
fly launch

# 4. 添加 PostgreSQL (第三方或自建)
# 推荐使用 Supabase 免费层

# 5. 配置环境变量
fly secrets set DATABASE_URL="postgresql://..."
fly secrets set REDIS_URL="redis://..."

# 6. 部署
fly deploy
```

---

### 🥉 方案三：Zeabur（国人友好）

**优点**：
- ✅ 中文界面
- ✅ $1/月免费额
- ✅ 一键 PostgreSQL + Redis
- ✅ Docker 支持
- ✅ 新加坡节点（国内速度快）

**缺点**：
- ❌ $1 额度有限
- ⚠️ Agent 功能可能受限

**部署步骤**：

1. 访问 https://zeabur.com 注册
2. 创建新服务 → 选择 GitHub 仓库
3. 添加服务 → PostgreSQL + Redis
4. 配置环境变量
5. 部署

---

### 方案四：Northflank（功能完整）

**优点**：
- ✅ $3/月免费额
- ✅ PostgreSQL + Redis 免费
- ✅ Docker 支持
- ✅ 持久化存储
- ✅ Agent 功能可运行

**部署步骤**：

1. 访问 https://northflank.com 注册
2. 创建项目 → 导入 GitHub
3. 添加 Addon → PostgreSQL + Redis
4. 配置环境变量
5. 部署

---

## 推荐架构组合

### 🏆 最佳免费组合（推荐）

| 服务 | 平台 | 费用 |
|------|------|------|
| **前端** | Vercel | 免费 |
| **后端** | Railway | $5/月信用额 |
| **数据库** | Railway (PostgreSQL) | 含在信用额 |
| **缓存** | Railway (Redis) | 含在信用额 |
| **域名** | 可选 | ~$10/年 |

### 💡 备选组合（中国大陆用户）

| 服务 | 平台 | 费用 |
|------|------|------|
| **前端** | Vercel | 免费 |
| **后端** | Zeabur（新加坡节点） | $1/月 |
| **数据库** | Zeabur PostgreSQL | 含在额度 |
| **缓存** | Zeabur Redis | 含在额度 |

---

## 特殊处理：禁用 Docker 功能

如果部署平台不支持 Docker Socket，需要修改代码禁用 Agent 容器功能。

### 修改 `backend/app/config.py`

```python
class Settings(BaseSettings):
    # 新增配置项
    ENABLE_AGENT_CONTAINERS: bool = True  # Docker Socket 支持
```

### 修改 `backend/app/services/agent_manager.py`

```python
from app.config import get_settings

settings = get_settings()

async def start_agent_container(agent_id: str):
    if not settings.ENABLE_AGENT_CONTAINERS:
        raise NotImplementedError("Agent containers not supported on this platform")
    # 原有逻辑...
```

---

## 总结建议

| 场景 | 推荐方案 |
|------|----------|
| **最佳体验** | Railway（$5信用额/月） |
| **完全免费** | Fly.io + Supabase |
| **国内用户** | Zeabur |
| **功能完整** | Northflank |
| **临时测试** | Railway |
| **正式生产** | Railway 付费 / VPS |

### 我的推荐

**对于你的情况**：

1. **快速体验**：使用 Railway，$5 信用额足够运行 1-2 个月
2. **降低成本**：Fly.io + Supabase 完全免费
3. **国内访问**：Zeabur 新加坡节点

**推荐步骤**：
1. 先用 Railway 快速部署测试
2. 确认功能正常后迁移到 Fly.io + Supabase 永久免费方案

---

## 附录：Supabase 免费 PostgreSQL 配置

Supabase 提供免费 PostgreSQL：

```bash
# 在 Railway 添加 PostgreSQL 时选择 Supabase
# 或直接使用 Supabase 免费项目
DATABASE_URL = postgresql://postgres:[PASSWORD]@db.[PROJECT_ID].supabase.co:5432/postgres
```

注意：Supabase 免费层有 500MB 存储限制。
