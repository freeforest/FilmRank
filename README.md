# FilmRank

Full-stack FilmRank project using Node.js + Express + MySQL with a Vue 3 frontend.

## Structure
- server: Express API and recommendation batch generator
- client: Vue app
- ??: project guidance documents

## Prerequisites
- Node.js 18+
- MySQL 8+

## Database setup
1) Create schema:
   - Run `server/src/db/schema.sql` in your MySQL client.
2) Create an admin user (optional):
   - Register via API or UI, then run:
     `UPDATE users SET role='admin' WHERE username='your_admin';`

## Backend
1) Copy env:
   - `server/.env.example` -> `server/.env`
2) Install deps:
   - `cd server`
   - `npm install`
3) Run:
   - `npm run dev`

## Frontend
1) Install deps:
   - `cd client`
   - `npm install`
2) Run:
   - `npm run dev`

## API Notes
- Health check: `GET /health`
- Auth: `POST /api/auth/register`, `POST /api/auth/login`
- Movies: `GET /api/movies`, `GET /api/movies/:id`
- Recommendations: `GET /api/recommendations`
- Admin generate batch: `POST /api/admin/recommendations/generate`

## Docker (x86)
1) Build images and start containers:
   - `docker compose up -d --build`
2) Initialize schema:
   - `docker exec -i filmrank-db mysql -uroot -pfilmrank_root filmrank < server/src/db/schema.sql`
3) Open:
   - Frontend: `http://<server-ip>/`
   - Backend: `http://<server-ip>:3000/health`
