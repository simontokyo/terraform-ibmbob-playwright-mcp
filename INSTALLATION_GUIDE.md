# Installation Guide - Terraform Playwright MCP Automation

## Step-by-Step Installation Instructions

### Prerequisites Check

Before starting, verify you have:

1. **Terraform installed** (v1.49.0+)
   ```bash
   terraform version
   ```
   If not installed, download from: https://www.terraform.io/downloads

2. **Internet connection** for downloading packages

3. **Platform-specific requirements:**
   - **Windows**: PowerShell 5.1+ (check: `$PSVersionTable.PSVersion`)
   - **macOS**: No special requirements (will use Homebrew if available, otherwise nvm)
   - **Ubuntu**: curl for nvm installation (usually pre-installed)

---

## Installation Steps

### Step 1: Download/Clone the Project

```bash
# Option A: Clone from repository
git clone <repository-url>
cd terraform-playwright-mcp

# Option B: Download and extract ZIP
# Then navigate to the extracted directory
```

### Step 2: Review Configuration (Optional)

Create a custom configuration file if you want to change defaults:

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your preferred settings
# Windows: notepad terraform.tfvars
# macOS/Linux: nano terraform.tfvars
```

**Common configurations:**

```hcl
# Node.js version (default: 24.15.0)
nodejs_min_version = "24.15.0"

# Force reinstall everything
force_reinstall = true

# Enable verbose output
verbose_output = true
```

### Step 3: Initialize Terraform

This downloads required Terraform providers:

```bash
terraform init
```

**Expected output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/local versions matching "~> 2.0"...
- Finding hashicorp/null versions matching "~> 3.0"...
Terraform has been successfully initialized!
```

### Step 4: Review the Execution Plan

See what Terraform will do without making changes:

```bash
terraform plan
```

**Review the output carefully:**
- Check detected OS
- Verify configuration paths
- Confirm installation steps

### Step 5: Apply the Configuration

Execute the automation:

```bash
terraform apply
```

**You will be prompted:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

Type `yes` and press Enter.

### Step 6: Monitor Installation

Watch the output for:
- ✅ OS detection
- ✅ Node.js version check
- ✅ Node.js installation (if needed)
- ✅ Playwright installation
- ✅ MCP configuration deployment

**Installation time:**
- With existing Node.js: ~2-5 minutes
- Fresh installation: ~5-10 minutes

### Step 7: Verify Installation

After successful completion, verify:

**1. Check Node.js:**
```bash
node --version
# Should show v18.x.x or newer
```

**2. Check npm:**
```bash
npm --version
```

**3. Check Playwright:**
```bash
npx playwright --version
```

**4. Check MCP configuration:**

**Windows:**
```powershell
type $env:USERPROFILE\.bob\settings\mcp_settings.json
```

**macOS/Linux:**
```bash
cat ~/.bob/settings/mcp_settings.json
```

**Expected content:**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### Step 8: Restart IBM Bob IDE

**Important:** Restart IBM Bob to load the new MCP configuration.

1. Close all IBM Bob windows
2. Reopen IBM Bob
3. Verify Playwright MCP is available in the MCP servers list

---

## Platform-Specific Notes

### Windows Installation

**If you encounter execution policy errors:**

```powershell
# Check current policy
Get-ExecutionPolicy

# Temporarily allow script execution (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**If Node.js installation requires admin privileges:**
- Right-click PowerShell
- Select "Run as Administrator"
- Navigate to project directory
- Run `terraform apply` again

### macOS Installation

**Installation Methods:**

The script automatically detects and uses the best method:
1. **If Homebrew is installed**: Uses `brew install node@24`
2. **If Homebrew is not installed**: Uses nvm to install Node.js v24

**No Xcode Command Line Tools required!**

**If you prefer Homebrew and don't have it:**

```bash
# Optional: Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**If you get permission errors with nvm:**

```bash
# nvm installs to user directory, no sudo needed
# Just follow the prompts
```

### Ubuntu/Debian Installation

**Update package lists first:**

```bash
sudo apt-get update
```

**If you encounter GPG key errors:**

```bash
# The script handles this automatically
# But if issues persist, manually update:
sudo apt-get install -y ca-certificates curl gnupg
```

---

## Troubleshooting Common Issues

### Issue: "Terraform not found"

**Solution:**
1. Install Terraform from https://www.terraform.io/downloads
2. Add to PATH
3. Verify: `terraform version`

### Issue: Node.js installation fails

**Windows:**
- Run PowerShell as Administrator
- Check antivirus isn't blocking downloads
- Verify internet connection

**macOS:**
- Install Xcode CLI Tools
- Try with Homebrew: `brew install node`

**Ubuntu:**
- Check sudo access: `sudo -v`
- Update packages: `sudo apt-get update`

### Issue: Playwright installation fails

**Check Node.js first:**
```bash
node --version
npm --version
```

**Manual installation:**
```bash
npx playwright install chrome
```

**Check disk space:**
- Playwright browsers need ~500MB
- Check: `df -h` (Unix) or `Get-PSDrive` (Windows)

### Issue: Configuration not applied

**Verify file exists:**

**Windows:**
```powershell
Test-Path $env:USERPROFILE\.bob\settings\mcp_settings.json
```

**macOS/Linux:**
```bash
ls -la ~/.bob/settings/mcp_settings.json
```

**Check file contents:**
```bash
# Should show valid JSON with playwright configuration
```

**Restart IBM Bob:**
- Configuration is loaded on startup
- Must restart after applying Terraform

### Issue: "Permission denied" errors

**Windows:**
- Run as Administrator
- Check execution policy

**macOS/Linux:**
- Scripts will prompt for sudo password when needed
- Ensure user has sudo privileges

---

## Verification Checklist

After installation, verify:

- [ ] Terraform apply completed without errors
- [ ] Node.js v18+ is installed (`node --version`)
- [ ] npm is working (`npm --version`)
- [ ] Playwright is installed (`npx playwright --version`)
- [ ] MCP config file exists at correct path
- [ ] MCP config contains playwright server definition
- [ ] IBM Bob IDE has been restarted
- [ ] Playwright MCP appears in Bob's MCP servers list

---

## Next Steps

1. **Test Playwright MCP:**
   ```bash
   npx @playwright/mcp@latest --help
   ```

2. **Explore Playwright features in IBM Bob**

3. **Review documentation:**
   - [README.md](README.md) - Full documentation
   - [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
   - [Playwright Docs](https://playwright.dev/)

---

## Uninstallation

To remove the MCP configuration:

```bash
terraform destroy
```

**Note:** This removes the MCP config but NOT Node.js or Playwright.

**To fully uninstall:**

**Node.js:**
- Windows: Settings → Apps → Node.js → Uninstall
- macOS: `brew uninstall node` or remove from `/usr/local`
- Ubuntu: `sudo apt-get remove nodejs`

**Playwright:**
```bash
npx playwright uninstall
```

---

## Getting Help

If you encounter issues:

1. Check this guide's troubleshooting section
2. Review Terraform output for error messages
3. Check script logs (verbose mode is enabled by default)
4. Verify all prerequisites are met
5. Try manual installation steps to isolate the issue

---

## Success!

Once installation is complete and verified, you're ready to use Playwright MCP with IBM Bob IDE!

Enjoy automated browser testing and web automation! 🎭✨