

---

```markdown
# Common Lisp Environment Setup & Installation Guide

This guide provides a comprehensive, step-by-step walkthrough for setting up a modern Common Lisp development environment on Windows using Steel Bank Common Lisp (SBCL), VS Code (with the Alive extension), and Tcl/Tk (via LTK for GUI development).

---

## 📋 Prerequisites & Core Software Installation

### 1. Install Steel Bank Common Lisp (SBCL)
1. Download the latest Windows MSI installer from the official [SBCL Download Page](http://www.sbcl.org/platform.html).
2. Run the installer and follow the prompts. By default, it installs to `C:\Program Files\Steel Bank Common Lisp\`.

### 2. Configure Windows Environment Variables
To run SBCL from any terminal session, you must add its installation directory to your system's `PATH` environment variable:
1. Open the Windows Start Menu, search for **"Edit the system environment variables"**, and select it.
2. In the System Properties window, click the **Environment Variables...** button.
3. Under **System variables**, locate the variable named `Path`, select it, and click **Edit...**.
4. Click **New** and paste the path to your SBCL installation folder (e.g., `C:\Program Files\Steel Bank Common Lisp\`).
5. Click **OK** to close all windows and save the changes.
6. Verify the installation by opening a *new* PowerShell or Command Prompt window and typing:
   ```cmd
   sbcl --version

```

### 3. Install Tcl/Tk (For GUI Projects via LTK)

Windows requires a native Tcl/Tk framework backend to render user interface elements constructed via the `LTK` library:

1. Download a compatible Tcl/Tk distribution for Windows (such as the [Magicsplat Tcl/Tk installer](https://www.magicsplat.com/tcl-installer/index.html)).
2. Run the installer and ensure it appends its binary folder (containing `wish.exe`) to your system `PATH` environment variable automatically during installation.

---

## 🗂️ Quicklisp Package Manager Installation

### ⚠️ Critical Working Directory Warning

Before downloading files or running configuration scripts, **always change directories out of `C:\Windows\System32\**`. Windows blocks file creation in this directory for system security. Move safely to your user profile directory by running:

```cmd
cd %userprofile%

```

### Step 1: Download `quicklisp.lisp`

Choose **one** of the following options to download the setup script:

* **Option A: Using `curl` (Recommended inside standard Command Prompt)**
Modern versions of Windows Command Prompt have `curl` built-in. Run:
```cmd
curl -o quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp

```


* **Option B: Using a Web Browser**
1. Direct your browser to `https://beta.quicklisp.org/quicklisp.lisp`.
2. Right-click anywhere on the code page and choose **Save As...**.
3. Save the file into your active development directory as `quicklisp.lisp`.



### Step 2: Initialize the Installer Environment

Launch SBCL with the installer configuration script loaded into active memory:

```cmd
sbcl --load quicklisp.lisp

```

Your terminal will drop you directly into an active Common Lisp REPL prompt, indicated by a single asterisk (`*`).

### Step 3: Run the Internal Installation Routines

Execute the following commands sequentially at the REPL prompt:

1. **Deploy Core System Files:**
```lisp
(quicklisp-quickstart:install)

```


*This unpacks the Quicklisp ecosystem into `C:\Users\<Your-Username>\quicklisp\`.*
2. **Configure Automatic Bootstrap Loading:**
```lisp
(ql:add-to-init-file)

```


*This appends startup parameters to your Lisp init file (`.sbclrc`) so Quicklisp automatically boots up every time SBCL or your IDE REPL initializes.*
3. **Confirm Actions & Exit:**
Press **Enter** a final time in your terminal console to confirm updating your configuration file when prompted. Afterward, safely close the standalone REPL using:
```lisp
(sb-ext:exit)

```



---

## ⚡ IDE Integration: VS Code & Alive Extension

The **Alive** extension transforms VS Code into a professional, fully interactive Common Lisp IDE featuring real-time REPL evaluations, code completions, and document diagnostics.

### 1. Extension Installation

1. Open VS Code.
2. Press `Ctrl + Shift + X` to open the Extensions Marketplace pane.
3. Search for **Alive** (by Reiner030) and click **Install**.

### 2. Configure `settings.json`

To connect Alive automatically to your native Windows SBCL compiler and enforce correct Lisp indentations, add the following parameters to your VS Code settings file:

1. Press `Ctrl + Shift + P` to open the Command Palette.
2. Type **"Preferences: Open User Settings (JSON)"** and select it.
3. Merge these definitions inside your global configuration JSON braces:

```json
"alive.lsp.startCommand": [
    "sbcl",
    "--noinform",
    "--userinit",
    "~/.sbclrc",
    "--eval",
    "(require :asdf)",
    "--eval",
    "(asdf:load-system :alive-lsp)",
    "--eval",
    "(alive/server:start)"
],
"[lisp]": {
    "editor.tabSize": 2,
    "editor.insertSpaces": true
}

```
