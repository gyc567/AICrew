# DreameClaw Crew 品牌重命名 - 用户故事与测试计划

## 一、用户故事 (User Stories)

### 用户故事 1: 配置文件品牌重命名

**作为** 系统管理员  
**我希望** 将所有配置文件中的 "DreameClaw Crew" 重命名为 "DreameClaw Crew"  
**以便** 品牌统一，提升产品形象

#### 验收标准 (AC)

- [ ] `pyproject.toml` 中的项目名称从 "DreameClaw Crew" 改为 "DreameClaw Crew"
- [ ] `docker-compose.yml` 中的网络名称和服务标签已更新
- [ ] `backend/app/config.py` 中的应用名称已更新
- [ ] `backend/alembic.ini` 中的配置已更新

---

### 用户故事 2: 后端代码品牌重命名

**作为** 后端开发者  
**我希望** 将后端代码中的品牌标识统一更新  
**以便** 代码库品牌一致

#### 验收标准 (AC)

- [ ] `backend/app/main.py` 中的应用标题和版本已更新
- [ ] `backend/app/services/agent_tools.py` 中的日志和消息已更新
- [ ] `backend/app/services/agent_manager.py` 中的相关文本已更新
- [ ] `backend/app/services/mcp_client.py` 中的相关文本已更新
- [ ] `backend/app/services/tool_seeder.py` 中的相关文本已更新
- [ ] `backend/app/services/resource_discovery.py` 中的相关文本已更新
- [ ] `backend/app/services/heartbeat.py` 中的相关文本已更新
- [ ] `backend/app/api/gateway.py` 中的相关文本已更新
- [ ] `backend/app/api/upload.py` 中的相关文本已更新

---

### 用户故事 3: 前端代码品牌重命名

**作为** 前端开发者  
**我希望** 将前端界面中的品牌标识统一更新  
**以便** 用户界面品牌一致

#### 验收标准 (AC)

- [ ] `frontend/index.html` 中的页面标题已更新
- [ ] `frontend/package.json` 中的项目名称已更新
- [ ] `frontend/src/pages/Login.tsx` 中的品牌文字已更新
- [ ] `frontend/src/pages/AgentCreate.tsx` 中的品牌文字已更新
- [ ] `frontend/src/pages/Layout.tsx` 中的品牌文字已更新
- [ ] `frontend/src/pages/EnterpriseSettings.tsx` 中的品牌文字已更新
- [ ] `frontend/src/i18n/en.json` 中的翻译已更新
- [ ] `frontend/src/i18n/zh.json` 中的翻译已更新
- [ ] `frontend/src/index.css` 中的品牌文字已更新

---

### 用户故事 4: Shell 脚本品牌重命名

**作为** DevOps 工程师  
**我希望** 将部署脚本中的品牌标识统一更新  
**以便** 部署流程品牌一致

#### 验收标准 (AC)

- [ ] `setup.sh` 中的项目名称和变量已更新
- [ ] `restart.sh` 中的项目名称已更新
- [ ] `backend/entrypoint.sh` 中的项目名称已更新

---

### 用户故事 5: 文档品牌重命名

**作为** 技术文档工程师  
**我希望** 将所有文档中的品牌标识统一更新  
**以便** 文档与产品品牌一致

#### 验收标准 (AC)

- [ ] `README.md` 中的项目名称已更新
- [ ] `README_zh-CN.md` 中的项目名称已更新
- [ ] `README_ja.md` 中的项目名称已更新
- [ ] `README_ko.md` 中的项目名称已更新
- [ ] `README_es.md` 中的项目名称已更新
- [ ] `CONTRIBUTING.md` 中的项目名称已更新
- [ ] `ARCHITECTURE_SPEC.md` 中的项目名称已更新
- [ ] `docs/TUTORIAL.md` 中的项目名称已更新
- [ ] `docs/DEPLOYMENT.md` 中的项目名称已更新

---

## 二、测试用例设计

### 测试策略

采用**黑盒测试**方法，通过文件系统扫描验证品牌名称的一致性。

### 测试用例列表

| TC ID | 测试名称 | 测试方法 | 预期结果 |
|-------|---------|---------|---------|
| TC-001 | 配置文件中无DreameClaw Crew残留 | grep搜索 | 0个匹配 |
| TC-002 | 前端文件中无DreameClaw Crew残留 | grep搜索 | 0个匹配 |
| TC-003 | 后端文件中无DreameClaw Crew残留 | grep搜索 | 0个匹配 |
| TC-004 | 脚本文件中无DreameClaw Crew残留 | grep搜索 | 0个匹配 |
| TC-005 | 文档中无DreameClaw Crew残留 | grep搜索 | 0个匹配 |
| TC-006 | 新品牌名称正确存在 | grep搜索AICrew | >0个匹配 |

---

## 三、重命名映射表

| 原名称 | 新名称 |
|--------|--------|
| DreameClaw Crew | DreameClaw Crew |
| dreameclaw-crew | dreameclaw-crew |
| DREAMECLAW_CREW | DREAMECLAW_CREW |

---

## 四、执行计划

### Phase 1: 编写测试 (红色阶段)
1. 创建测试脚本验证 DreameClaw Crew 存在
2. 运行测试确认失败（因为现在是DreameClaw Crew）

### Phase 2: 实现修改 (绿色阶段)
1. 批量替换配置文件
2. 批量替换代码文件
3. 批量替换文档

### Phase 3: 验证测试 (蓝色阶段)
1. 运行测试验证通过
2. 检查无遗漏

### Phase 4: 代码审查
1. 提交代码审查
2. 修复发现的问题
3. 合并代码
