# 本地后端 + Vercel 前端 部署方案

## 概述

本文档说明如何将 AI Crew 前端部署到 Vercel，后端部署在本地，通过内网穿透让前端访问本地后端 API。

---

## 方案一：Cloudflare Tunnel（推荐 - 免费、稳定）

### 优点
- ✅ 完全免费
- ✅ 无需开放防火墙端口
- ✅ 自动 HTTPS
- ✅ 稳定可靠
- ✅ 支持固定域名（可选）

### 部署步骤

#### Step 1: 安装 cloudflared

```bash
# macOS
brew install cloudflare/cloudflare/cloudflared

# Linux
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
```

#### Step 2: 登录 Cloudflare（仅需一次）

```bash
cloudflared tunnel login
```
浏览器会打开，按提示授权创建隧道。

#### Step 3: 创建隧道

```bash
cloudflared tunnel create aicrew-backend
```

记下返回的 Tunnel ID，例如：`a1b2c3d4-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

#### Step 4: 配置 DNS（可选固定域名）

如果使用固定域名，在 Cloudflare DNS 添加：
```
Type: CNAME
Name: api
Target: a1b2c3d4-xxxx-xxxx-xxxx-xxxxxxxxxxxx.cfargotunnel.com
Proxy status: DNS only (灰色云)
```

#### Step 5: 创建配置文件

```bash
# 编辑 ~/.cloudflared/config.yml
tunnel: <your-tunnel-id>
credentials-file: /root/.cloudflared/<your-tunnel-id>.json

ingress:
  - hostname: api.yourdomain.com  # 如果使用固定域名
    service: http://localhost:8008
  - service: http_status:404
```

#### Step 6: 启动隧道

```bash
cloudflared tunnel run aicrew-backend
```

#### Step 7: 获取公网 URL

```bash
cloudflared tunnel url
# 输出: https://xxxx.trycloudflare.com
```

#### Step 8: 配置 Vercel 环境变量

在 Vercel 项目 Dashboard → Settings → Environment Variables 添加：

| Name | Value |
|------|-------|
| `VITE_API_URL` | `https://xxxx.trycloudflare.com` |

#### Step 9: 更新前端 vercel.json

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "env": {
    "VITE_API_URL": "@aicrew-api-url"
  }
}
```

#### Step 10: 重新部署前端

```bash
cd frontend
vercel --prod
```

---

## 方案二：Ngrok（简单快速）

### 优点
- ✅ 配置简单
- ✅ 快速启动
- ✅ 免费额度

### 缺点
- ❌ 免费版 URL 每次重启会变化
- ❌ 需要注册账号获取 Auth Token

### 部署步骤

#### Step 1: 安装 ngrok

```bash
# macOS
brew install ngrok

# 或下载: https://ngrok.com/download
```

#### Step 2: 注册并获取 Token

1. 访问 https://ngrok.com 注册账号
2. 复制 Authtoken
3. 配置：`ngrok config add-authtoken <your-token>`

#### Step 3: 启动隧道

```bash
ngrok http 8008
```

#### Step 4: 获取 URL

终端会显示：
```
Forwarding  https://xxxx-xx-xx.ngrok-free.app -> http://localhost:8008
```

#### Step 5: 配置 Vercel

同方案一 Step 8-10，使用 ngrok 提供的 URL。

---

## 方案三：固定域名 + 云服务器（生产环境推荐）

### 适用场景
- 需要固定不变的 API 地址
- 高流量、高稳定性需求
- 有预算购买域名和云服务器

### 架构
```
用户浏览器 → Vercel CDN → 固定域名 → 云服务器 → 本地后端
```

### 推荐配置
- **云服务器**: 阿里云/腾讯云/ AWS EC2（最便宜约 20元/月）
- **域名**: .com 域名约 50元/年
- **反向代理**: Nginx + SSL

---

## 安全建议

### 必做
1. ✅ 使用 HTTPS（Cloudflare/ngrok 自动提供）
2. ✅ 设置 API 密钥验证
3. ✅ 启用速率限制
4. ✅ 定期查看访问日志

### 建议
1. 配置 Cloudflare 的 WAF 规则
2. 使用 Cloudflare Access 限制访问（可选）
3. 设置 IP 白名单（如果 IP 固定）

---

## 故障排除

### Cloudflare Tunnel 不工作

```bash
# 查看日志
cloudflared tunnel run aicrew-backend --loglevel debug

# 检查配置
cloudflared tunnel ingress validate
```

### Ngrok 显示 502 Bad Gateway

确保本地后端正在运行：
```bash
curl http://localhost:8008/api/health
```

### Vercel 读取不到环境变量

1. 检查环境变量名称是否正确
2. 确认重新部署（环境变量变更需要重新部署）
3. 检查浏览器控制台 Network 面板

---

## 快速启动脚本

项目已包含以下脚本：

```bash
# Cloudflare Tunnel 方式
./backend/start-tunnel.sh

# Ngrok 方式
./backend/start-ngrok.sh 8008 <your-ngrok-token>
```

---

## 总结

| 方案 | 适合场景 | 成本 |
|------|----------|------|
| Cloudflare Tunnel | 开发/测试/小规模生产 | 免费 |
| Ngrok | 快速测试/临时演示 | 免费/付费 |
| 固定域名 + 云服务器 | 正式生产环境 | 约 30元/月 |
