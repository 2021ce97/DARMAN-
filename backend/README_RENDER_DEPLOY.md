Render deploy helper
====================

This folder contains helper scripts to upload environment variables and secret files to Render using the Render CLI. They are convenience wrappers — they do not store or transmit secrets to this repository.

Files
- [backend/scripts/render-deploy.ps1](backend/scripts/render-deploy.ps1) — PowerShell helper for Windows users.
- [backend/scripts/render-deploy.sh](backend/scripts/render-deploy.sh) — Bash helper (requires `jq`).

Usage (PowerShell)
------------------

Set the Render API key (or run `render login`):

```powershell
$Env:RENDER_API_KEY = "YOUR_RENDER_API_KEY"
```

Run the script (example):

```powershell
.\backend\scripts\render-deploy.ps1 -ServiceName darman-api -EnvFile .\.env.production -SecretFile .\backend\serviceAccountKey.json -Deploy
```

Usage (Bash)
------------

```bash
export RENDER_API_KEY="YOUR_RENDER_API_KEY"
./backend/scripts/render-deploy.sh darman-api .env.production backend/serviceAccountKey.json true
```

Notes
- Do not commit your `.env.production` or secret files to git.
- Scripts call `render services update` and `render deploys create` — ensure the Render CLI is installed and you have appropriate permissions.
- These scripts assume the service name is `darman-api`. Adjust the `-ServiceName` or first positional argument if different.
