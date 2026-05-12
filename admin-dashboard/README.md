# DARMAN Admin Dashboard

This Next.js admin dashboard is currently retired from production because the expected Vercel URL returns 404.

Current production admin access is through the Flutter app:

- URL: https://mediconnect-4b155.web.app/admin
- Role required: `admin`

The Next.js dashboard still builds successfully and can be deployed later when a Vercel project is connected.

## Local Development

```bash
npm install
npm run dev
```

Local URL:

```text
http://localhost:3001
```

## Production Re-enable Checklist

1. Create or connect a Vercel project with root directory `admin-dashboard`.
2. Set `NEXT_PUBLIC_API_URL=https://darman-api.onrender.com/api/v1`.
3. Add Firebase client/admin env vars if server-side admin actions are added.
4. Protect admin routes with Firebase Auth and admin role checks.
5. Add the final Vercel domain to backend CORS if the generic Vercel preview rule is removed.
