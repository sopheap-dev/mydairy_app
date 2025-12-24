# VS Code Debug Configuration

## Setting Up API Key for Debugging

The launch configurations in `launch.json` use the `args` property to pass `--dart-define` flags to Flutter.

### Option 1: Direct Configuration in launch.json (Simplest)

1. Open `.vscode/launch.json`
2. Replace `YOUR_GROQ_API_KEY_HERE` with your actual API key in each configuration:
   ```json
   "args": [
     "--dart-define=GROQ_API_KEY=gsk_your_actual_api_key_here"
   ]
   ```
3. **Important**: 
   - Make sure `.vscode/launch.json` is NOT committed with your actual API key
   - The current `launch.json` uses a placeholder `YOUR_GROQ_API_KEY_HERE` - replace it with your real key
   - Consider adding `.vscode/launch.json` to `.gitignore` if you're sharing the repo

### Option 2: Using Environment Variable with VS Code Tasks (Advanced)

If you want to use environment variables, you can create a VS Code task:

1. Create `.vscode/tasks.json`:
   ```json
   {
     "version": "2.0.0",
     "tasks": [
       {
         "label": "flutter: run with api key",
         "type": "shell",
         "command": "flutter",
         "args": [
           "run",
           "--dart-define=GROQ_API_KEY=${env:GROQ_API_KEY}"
         ],
         "problemMatcher": []
       }
     ]
   }
   ```

2. Set the environment variable in your shell (see Option 3)

3. Run the task instead of using launch configurations

### Option 3: Set Environment Variable in Shell

**macOS/Linux (zsh/bash):**
```bash
export GROQ_API_KEY=your_groq_api_key_here
```

Add this to your `~/.zshrc` or `~/.bashrc` to make it permanent:
```bash
echo 'export GROQ_API_KEY=your_groq_api_key_here' >> ~/.zshrc
source ~/.zshrc
```

**Windows (PowerShell):**
```powershell
$env:GROQ_API_KEY="your_groq_api_key_here"
```

**Windows (Command Prompt):**
```cmd
set GROQ_API_KEY=your_groq_api_key_here
```

Then use Option 2's task configuration, or manually edit `launch.json` to use the environment variable (if your VS Code supports `${env:...}` in args).

### Option 4: Use Command Line Instead

If you prefer not to modify `launch.json`, you can run from the terminal:

```bash
flutter run --dart-define=GROQ_API_KEY=your_groq_api_key_here
```

### Option 3: VS Code Settings (User-specific)

You can also set it in VS Code's user settings:

1. Open VS Code Settings (Cmd/Ctrl + ,)
2. Search for "dart define"
3. Add to your `settings.json`:
   ```json
   {
     "dart.env": {
       "GROQ_API_KEY": "your_api_key_here"
     }
   }
   ```

## Available Debug Configurations

- **Launch development** - Debug mode with API key
- **Launch staging** - Debug mode for staging testing
- **Launch production** - Release mode build

All configurations will automatically use the `GROQ_API_KEY` environment variable if set.

