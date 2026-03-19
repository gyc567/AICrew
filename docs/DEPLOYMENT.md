# DreameClaw Crew 部署文档

> 本文档提供 DreameClaw Crew 项目的详细部署指南，从环境准备到生产部署，每一步都有清晰说明。

---

## 一、环境要求

### 1.1 硬件要求

| 场景 | CPU | 内存 | 磁盘 | 说明 |
|------|-----|------|------|------|
| 个人试用/Demo | 1 核 | 2 GB | 20 GB | 使用 SQLite，跳过智能体容器 |
| 完整体验 (1-2 智能体) | 2 核 | 4 GB | 30 GB | ✅ 推荐入门配置 |
| 小团队 (3-5 智能体) | 2-4 核 | 4-8 GB | 50 GB | 使用 PostgreSQL |
| 生产环境 | 4+ 核 | 8+ GB | 50+ GB | 多租户、高并发 |

### 1.2 软件要求

| 软件 | 版本要求 | 说明 |
|------|---------|------|
| Python | 3.12+ | 后端运行时 |
| Node.js | 20+ | 前端构建 |
| PostgreSQL | 15+ | 生产数据库 |
| Docker | Latest | 容器化部署 |
| Docker Compose | Latest | 编排工具 |

> **注意**：DreameClaw Crew 不在本地运行任何 AI 模型，所有 LLM 推理由外部 API 提供商（OpenAI、Anthropic 等）处理。

### 1.3 网络要求

- 能够访问 LLM API 端点（如 OpenAI、Anthropic）
- 能够访问 GitHub（用于技能导入）
- 国内用户可能需要配置镜像加速

---

## 二、快速开始（推荐方式）

### 2.1 克隆项目

```bash
# 完整克隆
git clone https://github.com/dataelement/DreameClaw Crew.git

# 或者浅克隆（仅下载最新提交，推荐国内用户）
git clone --depth 1 https://github.com/dataelement/DreameClaw Crew.git

cd DreameClaw Crew
```

### 2.2 运行安装脚本

```bash
# 生产模式安装（仅安装运行时依赖，约 1 分钟）
bash setup.sh

# 开发模式安装（额外安装 pytest 和测试工具，约 3 分钟）
bash setup.sh --dev
```

安装脚本会自动完成以下步骤：

1. ✅ 创建 `.env` 配置文件（从 `.env.example`）
2. ✅ 设置 PostgreSQL（如有现有实例则使用，否则自动下载启动本地 PostgreSQL）
3. ✅ 安装后端依赖（Python venv + pip）
4. ✅ 安装前端依赖（npm）
5. ✅ 创建数据库表并初始化数据（默认公司、模板、技能等）

### 2.3 启动服务

```bash
bash restart.sh
```

服务启动后：
- **前端**: http://localhost:3008
- **后端**: http://localhost:8008
- **API 文档**: http://localhost:8008/docs

### 2.4 首次登录

1. 打开浏览器访问 http://localhost:3008
2. 点击 "Register" 注册
3. 第一个注册用户自动成为**平台管理员**

---

## 三、Docker 部署（生产推荐）

### 3.1 基础部署

```bash
# 1. 克隆项目
git clone https://github.com/dataelement/DreameClaw Crew.git
cd DreameClaw Crew

# 2. 复制环境变量文件
cp .env.example .env

# 3. 启动所有服务
docker compose up -d

# 4. 访问应用
# → http://localhost:3000
```

### 3.2 环境变量配置

在运行之前，需要编辑 `.env` 文件配置必要的环境变量：

```bash
# 编辑环境变量
nano .env
```

关键配置项：

```env
# ===================
# 必需配置
# ===================

# 数据库连接（Docker 内部使用）
DATABASE_URL=postgresql+asyncpg://dreameclaw-crew:dreameclaw-crew@postgres:5432/dreameclaw-crew

# Redis 连接
REDIS_URL=redis://redis:6379/0

# 安全密钥（生产环境必须修改！）
SECRET_KEY=your-super-secret-key-change-this
JWT_SECRET_KEY=your-jwt-secret-key-change-this

# ===================
# 可选配置 - LLM 提供商
# ===================

# OpenAI
OPENAI_API_KEY=sk-...

# Anthropic (Claude)
ANTHROPIC_API_KEY=sk-ant-...

# ===================
# 可选配置 - 飞书集成
# ===================
FEISHU_APP_ID=your_app_id
FEISHU_APP_SECRET=your_app_secret

# ===================
# 可选配置 - 前端端口
# ===================
FRONTEND_PORT=3008
```

### 3.3 更新部署

```bash
# 拉取最新代码
git pull

# 重新构建并启动
docker compose up -d --build
```

---

## 四、手动部署（高级用户）

如果你需要更精细的控制，可以手动部署各组件。

### 4.1 数据库设置

#### 4.1.1 使用 PostgreSQL（推荐生产环境）

```bash
# 1. 安装 PostgreSQL
# macOS
brew install postgresql@15
brew services start postgresql@15

# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# 2. 创建数据库和用户
sudo -u postgres psql

# 在 psql 中执行：
CREATE USER dreameclaw-crew WITH PASSWORD 'dreameclaw-crew';
CREATE DATABASE dreameclaw-crew OWNER dreameclaw-crew;
GRANT ALL PRIVILEGES ON DATABASE dreameclaw-crew TO dreameclaw-crew;
\q
```

#### 4.1.2 使用 SQLite（仅用于测试）

如果只想快速测试，可以跳过 PostgreSQL 安装，DreameClaw Crew 会自动使用 SQLite。

### 4.2 后端部署

```bash
# 1. 进入后端目录
cd backend

# 2. 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate  # Windows

# 3. 安装依赖
pip install -e .

# 4. 配置环境变量
cp ../.env.example ../.env
nano ../.env  # 编辑配置

# 5. 运行数据库迁移
alembic upgrade head

# 6. 初始化数据
python seed.py

# 7. 启动后端服务
uvicorn app.main:app --host 0.0.0.0 --port 8008 --reload
```

### 4.3 前端部署

```bash
# 1. 进入前端目录
cd frontend

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.example .env
nano .env

# API 配置（开发环境）
VITE_API_URL=http://localhost:8000

# 4. 启动开发服务器
npm run dev

# 或构建生产版本
npm run build
```

---

## 五、中国用户特殊配置

### 5.1 Docker 镜像加速

如果 `docker compose up -d` 超时，配置 Docker 镜像加速：

```bash
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://docker.1panel.live",
    "https://hub.rat.dev",
    "https://dockerpull.org"
  ]
}
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker
```

然后重新运行：
```bash
docker compose up -d
```

### 5.2 PyPI 镜像加速

后端安装使用 pip 时，如需使用镜像加速：

```bash
export DREAMECLAW_CREW_PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
export DREAMECLAW_CREW_PIP_TRUSTED_HOST=pypi.tuna.tsinghua.edu.cn
```

然后运行安装脚本或 docker build。

### 5.3 Debian apt 镜像（构建失败修复）

如果 `docker compose up -d --build` 在 `apt-get update` 失败（无法访问 deb.debian.org），在 `backend/Dockerfile` 中添加：

```dockerfile
# 在两个 WORKDIR /app 后添加（deps 和 production 两个阶段）
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources
```

---

## 六、常用操作命令

### 6.1 Docker 命令

```bash
# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f backend
docker compose logs -f frontend

# 停止服务
docker compose down

# 停止并删除数据卷（重置）
docker compose down -v

# 重启特定服务
docker compose restart backend
```

### 6.2 直接运行命令

```bash
# 启动后端
bash backend/entrypoint.sh

# 或使用 uvicorn
cd backend
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8008

# 启动前端
cd frontend
npm run dev
```

---

## 七、验证部署

### 7.1 健康检查

```bash
# 后端健康检查
curl http://localhost:8008/api/health

# 预期返回：
{"status":"ok","version":"x.x.x"}
```

### 7.2 登录测试

1. 打开 http://localhost:3008 （或配置的端口）
2. 点击 "Register" 创建账户
3. 第一个用户自动成为平台管理员

### 7.3 创建第一个智能体

1. 登录后，点击侧边栏 "+" 创建智能体
2. 按照创建向导完成 5 步：
   - 基础信息 & 模型选择
   - 人格 & 边界
   - 技能选择
   - 权限配置
   - 渠道配置（飞书/Discord/Slack/Teams）
3. 创建完成后开始与智能体对话

---

## 八、故障排除

### 8.1 常见问题

#### 问题：数据库连接失败

```bash
# 检查 PostgreSQL 是否运行
docker compose ps postgres
# 或
pg_isready -U dreameclaw-crew -h localhost
```

#### 问题：端口被占用

```bash
# 查找占用端口的进程
lsof -i :3008
lsof -i :8008

# 停止占用的进程或修改端口
```

#### 问题：npm install 失败

```bash
# 清理缓存重试
cd frontend
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

### 8.2 网络问题

如果 `git clone` 慢或超时：

| 解决方案 | 命令 |
|---------|------|
| 浅克隆 | `git clone --depth 1 https://github.com/dataelement/DreameClaw Crew.git` |
| 下载发布包 | 访问 Releases 下载 .tar.gz |
| 使用 git 代理 | `git config --global http.proxy socks5://127.0.0.1:1080` |

---

## 九、安全配置（生产必读）

### 9.1 必需的安全措施

1. **修改默认密钥**
   ```env
   SECRET_KEY=随机字符串-必须修改
   JWT_SECRET_KEY=随机字符串-必须修改
   ```

2. **启用 HTTPS**
   - 使用 Nginx/Caddy 配置 SSL 证书
   - 或使用云负载均衡器

3. **使用 PostgreSQL**
   - SQLite 仅用于开发测试
   - 生产必须使用 PostgreSQL

4. **定期备份**
   - 备份数据库
   - 备份 agent_data 目录

5. **限制 Docker socket 访问**
   - 不要将 docker.sock 暴露给不必要的容器

### 9.2 可选增强

- 配置防火墙规则
- 启用防火墙
- 配置入侵检测
- 定期更新安全补丁

---

## 十、数据目录说明

### 10.1 智能体数据存储

智能体的工作空间文件（soul.md、memory、技能、工作空间文件）存储在：
```
./backend/agent_data/<agent-id>/
```

每个智能体一个目录，通过 UUID 命名。

### 10.2 Docker 卷挂载

```yaml
volumes:
  - ./backend/agent_data:/data/agents
```

这使得智能体数据直接从本地文件系统可访问。

---

## 十一、总结

本部署文档涵盖了 DreameClaw Crew 的多种部署方式：

| 部署方式 | 适用场景 | 难度 |
|---------|---------|------|
| 一键脚本 | 开发/快速测试 | ⭐ |
| Docker Compose | 小规模生产 | ⭐⭐ |
| 手动部署 | 大规模/定制 | ⭐⭐⭐ |

建议按照以下顺序选择：
1. **首次试用** → 使用 `bash setup.sh` 一键部署
2. **小规模部署** → 使用 Docker Compose
3. **大规模生产** → 手动部署 + Kubernetes

如遇问题，请查看官方文档或加入社区 Discord 获取帮助。
