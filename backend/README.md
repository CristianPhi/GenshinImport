# Genshin Import Backend

## Penting — Port

| Setting | Port | Fungsi |
|---|---|---|
| `PORT` di `.env` | **3007** | Server API (Express) |
| `DB_PORT` di `.env` | **3307** | MySQL |

**Jangan samakan PORT dengan DB_PORT.** Kalau PORT=3307, backend bentrok dengan MySQL dan tidak bisa jalan.

## Cara jalanin

```bash
npm install
npm run seed    # sekali, kalau DB masih kosong
npm run dev
```

Server harus muncul: `Server running on http://localhost:3007`

## Akun demo

- Admin: `admin@genshinimport.com` / `admin123`
- User: `user@genshinimport.com` / `admin123`
