# Universal Command Enforcer

A powerful tool that prevents unintentional package manager usage by enforcing a specific package manager across your entire development environment.

## 🎯 What It Does

This project solves a common problem in development teams: **accidentally using the wrong package manager**. When multiple developers work on a project, some might use `npm`, others `yarn`, and others `pnpm` - leading to:

- Inconsistent lock files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`)
- Dependency conflicts
- "Works on my machine" issues
- Broken CI/CD pipelines

## 🛡️ How It Prevents Unintentional Commands

The Universal Command Enforcer creates a **multi-layered defense system**:

### 1. **Shell-Level Interception**
- Automatically configures your shell (`.zshrc` or `.bashrc`) with aliases
- Intercepts `npm` and `yarn` commands before they execute
- Shows helpful error messages with clear instructions

### 2. **Universal Command Checker**
- Detects package manager commands in real-time
- Allows system commands (`git`, `ls`, `node`, etc.) to pass through
- Provides beautiful, informative error boxes when violations occur

### 3. **Installation-Time Detection**
- Runs during package installation to catch violations early
- Uses multiple detection methods for maximum reliability
- Prevents dependency installation with wrong package managers

### 4. **Visual Error Prevention**
When someone tries to use the wrong package manager, they see:
```
❌ Package Manager Error

🔍 Detected: "npm" (via universal checker)
📦 Required: "pnpm"
🚫 Command: npm install

💡 Solutions:
   1. Install pnpm: npm install -g pnpm
   2. Use pnpm commands: pnpm install, pnpm run build, etc.
   3. Run: pnpm run check-pm (to verify)

🔗 Learn more: https://pnpm.io/installation
```

## 🚀 Quick Start

1. **Clone and setup the project:**
   ```bash
   git clone <repository-url>
   cd universal-command-enforcer
   pnpm run setup-project
   ```

2. **Reload your shell for current changes:**
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```
   
   **⚠️ Important:** After running the `setup-project` script, you must reload your shell for the changes to take effect in your current terminal session.

3. **Test the enforcement:**
   ```bash
   npm install      # ❌ Should show custom error
   yarn add react   # ❌ Should show custom error
   pnpm install     # ✅ Should work normally
   ```

## ⚙️ Configuration

### Changing the Default Package Manager

By default, this project enforces `pnpm`. To configure it for a different package manager:

#### Option 1: Environment Variable
```bash
export REQUIRED_PM="yarn"
export UNIVERSAL_PM_CHECK_ENABLED=1
```

#### Option 2: Modify the Scripts

1. **Update `scripts/universal.sh`:**
   ```bash
   # Change line 12 from:
   REQUIRED_PM="pnpm"
   # To:
   REQUIRED_PM="yarn"
   ```

2. **Update `scripts/detect.js`:**
   ```javascript
   // Change line 12 from:
   const REQUIRED_PM = "pnpm";
   // To:
   const REQUIRED_PM = "yarn";
   ```

3. **Update `scripts/setup.sh`:**
   ```bash
   # Change line 95-99 from:
   echo "alias npm='check_package_manager \"npm\" \"\$*\" && npm \"\$@\"'" >> "$shell_config"
   echo "alias yarn='check_package_manager \"yarn\" \"\$*\" && yarn \"\$@\"'" >> "$shell_config"
   # To:
   echo "alias npm='check_package_manager \"npm\" \"\$*\" && npm \"\$@\"'" >> "$shell_config"
   echo "alias pnpm='check_package_manager \"pnpm\" \"\$*\" && pnpm \"\$@\"'" >> "$shell_config"
   ```

### Customizing Allowed Commands

Edit the `ALLOWED_COMMANDS` array in `scripts/universal.sh` to permit additional commands:

```bash
ALLOWED_COMMANDS=("pnpm" "node" "git" "ls" "cat" "echo" "cd" "pwd" "find" "grep" "chmod" "mkdir" "rm" "cp" "mv" "touch" "which" "whereis" "type" "command" "hash" "alias" "unalias" "export" "unset" "source" "." "your-custom-command")
```

## 🔧 Available Scripts

- `pnpm run setup-project` - Configure the enforcement system
- `pnpm run check-pm` - Verify package manager compliance
- `pnpm run preinstall` - Automatic check during installation

## 🎛️ Control Commands

- **Enable enforcement:** `export UNIVERSAL_PM_CHECK_ENABLED=1`
- **Disable temporarily:** `unset UNIVERSAL_PM_CHECK_ENABLED`
- **Check status:** `echo $UNIVERSAL_PM_CHECK_ENABLED`

## 🏗️ Project Structure

```
universal-command-enforcer/
├── scripts/
│   ├── setup.sh          # Main setup script
│   ├── universal.sh      # Core enforcement logic
│   └── detect.js         # Package manager detection
├── package.json          # Project configuration
└── README.md            # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with different package managers
5. Submit a pull request

## 📝 License

ISC License - see package.json for details.

## 🔗 Related Links

- [pnpm Documentation](https://pnpm.io/)
- [npm Documentation](https://docs.npmjs.com/)
- [Yarn Documentation](https://yarnpkg.com/)

---

## 🚀 Advanced: Universal Solution for All Project Architectures

### Why This Solution is Superior

Unlike npm packages that fail to validate package managers in complex architectures, this **shell-based solution works universally** across all project types:

- ✅ **Normal projects** (single package.json)
- ✅ **Monorepos** (multiple packages, workspaces)
- ✅ **Micro-frontends** (complex dependency trees)
- ✅ **Multi-package libraries** (complex build systems)
- ✅ **Any project architecture** (just configure and see the magic!)

### Making It Even More Powerful with Git Hooks

Combine this solution with git hooks to create a **bulletproof enforcement system**:

#### 1. **Post-Merge Hook** (`.git/hooks/post-merge`)
```bash
#!/bin/bash
# Automatically re-enable enforcement after git operations
export UNIVERSAL_PM_CHECK_ENABLED=1
echo "✅ Package manager enforcement re-enabled after merge"
```

#### 2. **Post-Checkout Hook** (`.git/hooks/post-checkout`)
```bash
#!/bin/bash
# Ensure enforcement is active when switching branches
if [ -z "$UNIVERSAL_PM_CHECK_ENABLED" ]; then
    export UNIVERSAL_PM_CHECK_ENABLED=1
    echo "✅ Package manager enforcement activated for this branch"
fi
```

#### 3. **Pre-Push Hook** (`.git/hooks/pre-push`)
```bash
#!/bin/bash
# Verify no wrong package manager files are being pushed
if git diff --name-only HEAD~1 | grep -q "package-lock\.json\|yarn\.lock"; then
    echo "❌ Error: Wrong lock files detected!"
    echo "This project uses pnpm. Please remove package-lock.json and yarn.lock"
    exit 1
fi
```

### Setup Git Hooks Automatically

Add this to your `scripts/setup.sh`:

```bash
# Setup git hooks for universal enforcement
setup_git_hooks() {
    local hooks_dir=".git/hooks"
    
    # Post-merge hook
    cat > "$hooks_dir/post-merge" << 'EOF'
#!/bin/bash
export UNIVERSAL_PM_CHECK_ENABLED=1
echo "✅ Package manager enforcement re-enabled after merge"
EOF
    chmod +x "$hooks_dir/post-merge"
    
    # Post-checkout hook
    cat > "$hooks_dir/post-checkout" << 'EOF'
#!/bin/bash
if [ -z "$UNIVERSAL_PM_CHECK_ENABLED" ]; then
    export UNIVERSAL_PM_CHECK_ENABLED=1
    echo "✅ Package manager enforcement activated for this branch"
fi
EOF
    chmod +x "$hooks_dir/post-checkout"
    
    # Pre-push hook
    cat > "$hooks_dir/pre-push" << 'EOF'
#!/bin/bash
if git diff --name-only HEAD~1 | grep -q "package-lock\.json\|yarn\.lock"; then
    echo "❌ Error: Wrong lock files detected!"
    echo "This project uses pnpm. Please remove package-lock.json and yarn.lock"
    exit 1
fi
EOF
    chmod +x "$hooks_dir/pre-push"
    
    echo "✅ Git hooks configured for universal enforcement"
}
```

### Why This Approach is Revolutionary

1. **Universal Coverage**: Works in any project structure, no matter how complex
2. **Shell-Level Enforcement**: Bypasses all npm package limitations
3. **Git Integration**: Ensures enforcement persists across all git operations
4. **Zero Dependencies**: No external packages required, just shell scripts
5. **Customizable**: Easy to adapt for any package manager preference

### Real-World Benefits

- **Monorepo Teams**: No more "which package manager should I use?" confusion
- **CI/CD Pipelines**: Consistent package manager usage across all environments
- **Onboarding**: New developers automatically use the correct tools
- **Code Reviews**: Prevents wrong lock files from being committed
- **Production Safety**: Eliminates "works on my machine" package manager issues

---

**Note:** This tool is designed to be helpful and educational, not restrictive. It guides developers toward best practices while preventing common mistakes that can cause project issues.