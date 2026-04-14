---

# 🛠 Step-by-Step GitHub Repo Setup

### 1. Authenticate GitHub CLI

```bash
gh auth login
```

* Choose: **GitHub.com → HTTPS → Paste Token / Browser Login**
* If you already logged in before, skip this.

---

### 2. Create GitHub Repo

```bash
gh repo create leximagine.com --public
```

* Select **private** repo (since you said private).
* Don’t add any files (README, .gitignore, etc.) here — we’ll add locally.

---

### 3. Initialize Git Repo Locally

Go to the directory where you extracted `hitmeupai-voice-app.zip`:

```bash
cd ~/path/to/leximagine.com
git init
```

---

### 4. Create `.gitignore`

A good starter for Node + frontend + Amplify:

```bash
cat > .gitignore << 'EOF'
# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Logs
logs/
*.log
*.log.*

# AWS SAM / Lambda build artifacts
.lambda/
.env
.env.*

# Mac/OSX
.DS_Store

# Amplify
amplify/#current-cloud-backend
dist/
build/

# PWA caches
frontend/.cache/
EOF
```

---

### 5. Add & Commit

```bash
git add .
git commit -m "Initial commit: leximagine.com index.html"
```

---

### 6. Link Remote Repo

```bash
git branch -M main
git remote add origin https://github.com/ashokrs/leximagine.com.git
```

*(replace `<your-username>` with your actual GitHub username)*

---

### 7. Push to GitHub

```bash
git push -u origin main
```

---
