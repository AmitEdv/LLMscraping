# setup.ps1 - PowerShell Setup Script for Web Scraper App
# Run with: .\setup.ps1

Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 69) -ForegroundColor Cyan
Write-Host "   Web Scraper App - Automated Setup (PowerShell)" -ForegroundColor Cyan
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 69) -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Python
Write-Host "Step 1: Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = & python --version 2>&1
    Write-Host "SUCCESS: Python found - $pythonVersion" -ForegroundColor Green
    $pythonCmd = "python"
} catch {
    try {
        $pythonVersion = & py --version 2>&1
        Write-Host "SUCCESS: Python found - $pythonVersion" -ForegroundColor Green
        $pythonCmd = "py"
    } catch {
        Write-Host "ERROR: Python not found!" -ForegroundColor Red
        Write-Host "Install Python 3.8+ from https://python.org" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}
Write-Host ""

# Step 2: Remove old venv if exists
if (Test-Path ".venv") {
    Write-Host "Step 2: Removing old virtual environment..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force .venv -ErrorAction SilentlyContinue
    Write-Host "SUCCESS: Old .venv removed" -ForegroundColor Green
} else {
    Write-Host "Step 2: No old virtual environment found" -ForegroundColor Yellow
}
Write-Host ""

# Step 3: Create virtual environment
Write-Host "Step 3: Creating virtual environment..." -ForegroundColor Yellow
& $pythonCmd -m venv .venv
if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Virtual environment created" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to create virtual environment" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Step 4: Activate virtual environment
Write-Host "Step 4: Activating virtual environment..." -ForegroundColor Yellow
$activateScript = ".\.venv\Scripts\Activate.ps1"

if (Test-Path $activateScript) {
    try {
        & $activateScript
        Write-Host "SUCCESS: Virtual environment activated" -ForegroundColor Green
    } catch {
        Write-Host "WARNING: Could not activate. You may need to run:" -ForegroundColor Yellow
        Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Gray
        Write-Host "Then run this script again." -ForegroundColor Gray
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "ERROR: Activation script not found" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Step 5: Upgrade pip
Write-Host "Step 5: Upgrading pip..." -ForegroundColor Yellow
& $pythonCmd -m pip install --upgrade pip --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Pip upgraded" -ForegroundColor Green
} else {
    Write-Host "WARNING: Pip upgrade had issues (might still work)" -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Install requirements
Write-Host "Step 6: Installing Python packages (this may take a few minutes)..." -ForegroundColor Yellow
if (Test-Path "requirements.txt") {
    & pip install -r requirements.txt
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Python packages installed" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Some packages may have failed to install" -ForegroundColor Yellow
    }
} else {
    Write-Host "ERROR: requirements.txt not found" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Step 7: Install Playwright browsers
Write-Host "Step 7: Installing Playwright browsers..." -ForegroundColor Yellow
& playwright install chromium
if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Playwright browsers installed" -ForegroundColor Green
} else {
    Write-Host "WARNING: Playwright installation had issues" -ForegroundColor Yellow
}
Write-Host ""

# Step 8: Check Ollama
Write-Host "Step 8: Checking Ollama installation..." -ForegroundColor Yellow
try {
    $ollamaVersion = & ollama --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Ollama found - $ollamaVersion" -ForegroundColor Green
        
        # Check if Ollama is running
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 2 -ErrorAction Stop
            Write-Host "SUCCESS: Ollama server is running" -ForegroundColor Green
            
            # Check models
            $data = $response.Content | ConvertFrom-Json
            $models = $data.models.name
            
            $requiredModels = @("phi3:mini", "nomic-embed-text")
            Write-Host "Checking required models:" -ForegroundColor Yellow
            foreach ($model in $requiredModels) {
                $found = $models | Where-Object { $_ -like "*$model*" }
                if ($found) {
                    Write-Host "  SUCCESS: $model found" -ForegroundColor Green
                } else {
                    Write-Host "  WARNING: $model missing" -ForegroundColor Yellow
                    Write-Host "    Install with: ollama pull $model" -ForegroundColor Gray
                }
            }
        } catch {
            Write-Host "WARNING: Ollama not running" -ForegroundColor Yellow
            Write-Host "  Start with: ollama serve (in a new terminal)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "WARNING: Ollama not found" -ForegroundColor Yellow
    Write-Host "  Install from: https://ollama.ai" -ForegroundColor Gray
}
Write-Host ""

# Step 9: Check Cursor AI Persona
Write-Host "Step 9: Checking Cursor AI persona configuration..." -ForegroundColor Yellow
$rulesPath = ".\.cursor\rules"
if (Test-Path $rulesPath) {
    $teamDevRules = Get-ChildItem -Path $rulesPath -Filter "team-dev*.mdc" -ErrorAction SilentlyContinue
    $ruleCount = ($teamDevRules | Measure-Object).Count
    
    if ($ruleCount -eq 0) {
        Write-Host "WARNING: No team-dev persona found!" -ForegroundColor Red
        Write-Host "  You should have exactly one persona rule active." -ForegroundColor Yellow
        Write-Host "  Expected files like: team-dev-tamar-pragmatic-deliverer.mdc" -ForegroundColor Gray
    } elseif ($ruleCount -gt 1) {
        Write-Host "WARNING: Multiple personas found ($ruleCount)!" -ForegroundColor Yellow
        Write-Host "  You should only have ONE active persona." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Available personas:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $teamDevRules.Count; $i++) {
            $ruleName = $teamDevRules[$i].Name -replace '^team-dev-', '' -replace '\.mdc$', ''
            Write-Host "  [$($i + 1)] $ruleName" -ForegroundColor White
        }
        Write-Host ""
        
        do {
            $choice = Read-Host "Select which persona to keep (1-$($teamDevRules.Count))"
            $choiceNum = 0
            $validChoice = [int]::TryParse($choice, [ref]$choiceNum) -and $choiceNum -ge 1 -and $choiceNum -le $teamDevRules.Count
            if (-not $validChoice) {
                Write-Host "Invalid choice. Please enter a number between 1 and $($teamDevRules.Count)" -ForegroundColor Red
            }
        } while (-not $validChoice)
        
        $keepIndex = $choiceNum - 1
        $keptRule = $teamDevRules[$keepIndex]
        
        # Delete the other rules
        for ($i = 0; $i -lt $teamDevRules.Count; $i++) {
            if ($i -ne $keepIndex) {
                Remove-Item -Path $teamDevRules[$i].FullName -Force
                $removedName = $teamDevRules[$i].Name -replace '^team-dev-', '' -replace '\.mdc$', ''
                Write-Host "  Removed: $removedName" -ForegroundColor Gray
            }
        }
        
        $activeName = $keptRule.Name -replace '^team-dev-', '' -replace '\.mdc$', ''
        Write-Host "SUCCESS: Active persona is now: $activeName" -ForegroundColor Green
    } else {
        # Exactly 1 rule found
        $activeName = $teamDevRules[0].Name -replace '^team-dev-', '' -replace '\.mdc$', ''
        Write-Host "SUCCESS: Active persona: $activeName" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: .cursor/rules directory not found" -ForegroundColor Yellow
    Write-Host "  Cursor AI rules may not be configured for this project." -ForegroundColor Gray
}
Write-Host ""

# Summary
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 69) -ForegroundColor Cyan
Write-Host "              SETUP COMPLETE!" -ForegroundColor Green
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 69) -ForegroundColor Cyan
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. If Ollama isn't running:" -ForegroundColor White
Write-Host "   ollama serve" -ForegroundColor Gray
Write-Host ""
Write-Host "2. If models are missing:" -ForegroundColor White
Write-Host "   ollama pull phi3:mini" -ForegroundColor Gray
Write-Host "   ollama pull nomic-embed-text" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Try the interactive scraper:" -ForegroundColor White
Write-Host "   python scraper_interactive.py" -ForegroundColor Gray
Write-Host ""

Write-Host "NOTE: Your venv is now activated in this session!" -ForegroundColor Green
Write-Host "The (.venv) prefix should appear in your prompt." -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to continue"
