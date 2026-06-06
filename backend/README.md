# Genshin Import Backend

## Setup

1. Copy `.env` dan sesuaikan DB (port MySQL kamu).
2. `npm install`
3. `npm run seed` — buat tabel auth_tokens + data demo
4. `npm run dev`

## Akun demo

- Admin: `admin@genshinimport.com` / `admin123`
- User: `user@genshinimport.com` / `admin123`

## Endpoints

- `GET /api/health`
- `POST /api/auth/login`
- `GET /api/weapons`
- `GET /api/weapons/:id`
- `POST /api/weapons` (Bearer token, admin)
- `PUT /api/weapons/:id` (Bearer token, admin)
- `DELETE /api/weapons/:id` (Bearer token, admin)
- `GET /api/orders/user/:userId` (Bearer token)
- `POST /api/orders` (Bearer token)

## Flutter API URL

- Windows / iOS simulator: `localhost:3007`
- Android emulator: `10.0.2.2:3007` (sudah otomatis di `api_service.dart`)
