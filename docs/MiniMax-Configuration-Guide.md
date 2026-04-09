# MiniMax 模型配置教程

## 概述

本文档记录在 Hermes Agent 中配置 MiniMax 模型的完整流程和经验教训。

## 环境信息

- **Hermes 版本**: v0.7+
- **配置文件**: `~/.hermes/config.yaml`
- **环境变量**: `~/.hermes/.env`

---

## 常见问题与解决方案

### 问题 1: 404 Not Found

**错误信息**:
```
<html><head><title>404 Not Found</title></head>...
```

**原因**: API Endpoint 路径错误

**解决方案**: 
- 使用 `/v1` 路径 (chat_completions 模式)，不要使用 `/anthropic`
- 正确: `https://api.minimaxi.com/v1`
- 错误: `https://api.minimaxi.com/anthropic`

---

### 问题 2: unknown model 'm2.7-highspeed'

**错误信息**:
```
HTTP 400: invalid params, unknown model 'm2.7-highspeed' (2013)
```

**原因**: 模型名称不完整

**解决方案**:
- 使用完整的模型名称: `MiniMax-M2.7-highspeed`
- 不要使用简写: `M2.7-highspeed` 或 `m2.7-highspeed`

---

### 问题 3: 401 Authentication Error

**错误信息**:
```
HTTP 401: invalid api key
```

**原因**: API Key 未正确传递

**解决方案**:
1. **方案 A (推荐)**: 使用内置 provider
   ```yaml
   model:
     provider: minimax-cn
     default: MiniMax-M2.7-highspeed
   ```

2. **方案 B**: 使用 custom provider 并直接写入 api_key
   ```yaml
   custom_providers:
     - name: minimax
       base_url: https://api.minimaxi.com/v1
       api_key: sk-xxx-xxx  # 直接写入，不要用 api_key_env
       api_mode: chat_completions
       model: MiniMax-M2.7-highspeed
   ```

**注意**: `api_key_env` 字段在 custom_providers 中不生效，因为 Hermes 不会读取它。

---

### 问题 4: Provider 选择

**Provider 区别**:
- `minimax` (国际版): 端点 `https://api.minimax.io/anthropic`
- `minimax-cn` (中国版): 端点 `https://api.minimaxi.com/v1`

**推荐**: 使用 `minimax-cn`，它更稳定且与中国区 API 兼容。

---

## 完整配置示例

### 推荐配置 (minimax-cn)

```yaml
model:
  default: MiniMax-M2.7-highspeed
  provider: minimax-cn
  base_url: https://api.minimaxi.com/v1

telegram:
  enabled: true
  allow_from: '*'
```

环境变量 `.env`:
```bash
MINIMAX_CN_API_KEY=sk-xxx-xxx
TELEGRAM_BOT_TOKEN=xxx:xxx
```

---

### 自定义配置 (custom)

```yaml
model:
  default: MiniMax-M2.7-highspeed
  provider: custom
  base_url: https://api.minimaxi.com/v1

custom_providers:
  - name: minimax
    base_url: https://api.minimaxi.com/v1
    api_key: sk-xxx-xxx  # 直接写入
    api_mode: chat_completions
    model: MiniMax-M2.7-highspeed
```

---

## 验证命令

测试模型是否正常工作:
```bash
cd ~/.hermes
source .env
hermes chat -q "hello" --provider minimax-cn -Q
```

---

## 关键教训

1. **模型名称**: 必须使用完整名称 `MiniMax-M2.7-highspeed`
2. **API 路径**: 使用 `/v1` 而非 `/anthropic`
3. **Provider**: 推荐使用 `minimax-cn` 而非自定义
4. **API Key**: 在 custom_providers 中直接写入，不要依赖 api_key_env
5. **启动脚本**: 使用 `set -a` 确保环境变量正确导出

---

## 启动 Hermes Gateway

```bash
#!/bin/bash
set -a
source /home/admin/.hermes/.env
set +a
exec /home/admin/.hermes/hermes-agent/venv/bin/python -m hermes_cli.main gateway run --replace
```

---

*文档版本: 1.0*
*更新日期: 2026-04-09*