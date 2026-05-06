# Fixing Claude Code extension issues (quick guide)

This repo includes a VS Code command id `claudeCode.allowDangerouslySkipPermissions` which is part of some Claude/Anthropic VS Code extensions. If you tried to run it in the terminal it will fail — it's a Command Palette command, not a shell program.

Quick fixes you can do locally:

1) Run the command from VS Code Command Palette
- Open VS Code in this workspace.
- Press `Ctrl+Shift+P` (Windows) to open the Command Palette.
- Type `Claude` and look for commands like `Claude Code: Allow Dangerously Skip Permissions` or `Allow Dangerously Skip Permissions` and run it.

2) Set the workspace setting manually (recommended)
- Open Command Palette → `Preferences: Open Workspace Settings (JSON)`.
- Add the following entry and save:

```json
{
  "claudeCode.allowDangerouslySkipPermissions": true
}
```

Note: this change is local to your machine. `.vscode/` is commonly git-ignored to avoid sharing personal settings.

3) Provide your API key (Anthropic / Claude)
- Many Claude extensions read an API key from an environment variable `ANTHROPIC_API_KEY` or from the extension settings.
- To set the environment variable for PowerShell (current session):

```powershell
$env:ANTHROPIC_API_KEY = 'sk-...'
```

- To set it persistently (Windows):

```powershell
setx ANTHROPIC_API_KEY "sk-..."
```

After setting the key, restart VS Code.

4) If the extension still does not appear or command isn't available
- Ensure the extension is installed (search the Extensions view for "Claude Code" or "Anthropic").
- Restart VS Code and try again.

5) Security note
- `allowDangerouslySkipPermissions` disables interactive permission prompts; enable it only for trusted workspaces.

If you want, I can:
- Add a `CLAUDE_FIX.md` (this file) with these steps to the repo (done).
- Create a script that prints the exact Command Palette steps for you to follow.
- Or, if you prefer, I can attempt to force-add a `.vscode/settings.json` to the repo (not recommended because your repo already ignores it and workspace settings are private).

Tell me which of the above you want me to do next, or paste the exact error message you saw and I will dig deeper.
