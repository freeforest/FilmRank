# FilmRank

基于 Node.js + Express + MySQL 的全栈 FilmRank 项目，前端为 Vue 3。

## 结构
- server: Express API 与推荐批处理生成器
- client: Vue 应用
- 指导: 项目指导文档

## 前置要求
- Node.js 18+
- MySQL 8+

## 数据库设置
1) 创建 schema：
   - 在你的 MySQL 客户端中运行 `server/src/db/schema.sql`。
2) 创建管理员用户（可选）：
   - 通过 API 或 UI 注册后执行：
     `UPDATE users SET role='admin' WHERE username='your_admin';`

## 后端
1) 复制 env：
   - `server/.env.example` -> `server/.env`
2) 安装依赖：
   - `cd server`
   - `npm install`
3) 运行：
   - `npm run dev`

## 前端
1) 安装依赖：
   - `cd client`
   - `npm install`
2) 运行：
   - `npm run dev`

## API 说明
- 健康检查：`GET /health`
- 认证：`POST /api/auth/register`, `POST /api/auth/login`
- 电影：`GET /api/movies`, `GET /api/movies/:id`
- 推荐：`GET /api/recommendations`
- 管理员生成批次：`POST /api/admin/recommendations/generate`

## Docker（x86）
1) 构建镜像并启动容器：
   - `docker compose up -d --build`
2) 初始化 schema：
   - `docker exec -i filmrank-db mysql -uroot -pfilmrank_root filmrank < server/src/db/schema.sql`
3) 打开：
   - 前端：`http://<server-ip>/`
   - 后端：`http://<server-ip>:3000/health`
