    ---

```markdown
# Common Lisp GUI Application

A lightweight, cross-platform Graphical User Interface (GUI) application built with **Common Lisp** utilizing the **LTK (Lisp Toolkit)** framework.

---

## 🛠️ Prerequisites & Installation

Before running or compiling the application, your system needs a Common Lisp environment, the Tcl/Tk graphic engine components, and a properly configured code editor.

### 1. Core Requirements & Environment Variables
* **SBCL (Steel Bank Common Lisp):** 1. Download and run the official Windows MSI installer from the [SBCL Downloads Page](http://www.sbcl.org/platform-table.html).
  2. **Important Environment Path Configuration:** During installation, ensure you check the box that says **"Add SBCL to the system PATH environment variable"**. 
  
  *If you missed this step during the installer wizard, you must add it manually:*
  * Search for **"Edit the system environment variables"** in your Windows Start Menu.
  * Click the **Environment Variables...** button at the bottom right.
  * Under the *System variables* list, find and select **Path**, then click *Edit...*.
  * Click *New* on the right side and type or paste the absolute path to your SBCL installation directory (e.g., `C:\Program Files\Steel Bank Common Lisp\`).
  * Click *OK* to save and exit out of all option windows. **Restart your open terminals or VS Code** to let the environment update.

* **Tcl/Tk:** Required by the LTK interface engine. For modern Windows 10/11 machines, open PowerShell as an Administrator and execute:
    ```powershell
    winget install ActiveState.ActiveTcl
    ```

### 2. Download & Bootstrap Quicklisp
Quicklisp manages downloading library packages for Common Lisp projects.

1. Open a **new** command prompt (`cmd`), change out of system folders to your project workspace directory, and fetch the installer script:
   ```cmd
   curl -o quicklisp.lisp [https://beta.quicklisp.org/quicklisp.lisp](https://beta.quicklisp.org/quicklisp.lisp)

```

2. Load and boot the installation target file directly inside your newly mapped global SBCL environment:
```cmd
sbcl --load quicklisp.lisp

```


3. At the active Lisp listener prompt (`*`), input the following setup hooks sequentially:
```lisp
(quicklisp-quickstart:install)
(ql:add-to-init-file)

```


⚠️ **Troubleshooting Note:** If you get a debugger error stating *"Quicklisp has already been installed"*, don't panic! It means Quicklisp is already configured on your machine. Handle it with these commands at the debugger prompt:
* Type `1` and press **Enter** to abort the crashed installer and return to the normal `*` prompt.
* Type `(ql:add-to-init-file)` and press **Enter** to ensure your configurations link up.


4. Press **Enter** in the terminal console when prompted to confirm writing the default initialization file (`.sbclrc`).
5. Terminate and exit the interactive Lisp execution frame cleanly:
```lisp
(sb-ext:exit)

```



### 3. Editor Setup (VS Code + Alive Extension)

To ensure VS Code always knows exactly how to spin up your dynamic SBCL server environment, we explicitly track it via your global user settings.

1. Launch **VS Code** and open the Extensions view layout block (`Ctrl+Shift+X`).
2. Search for, select, and install the **Alive** (*Active Lisp Interactive Development Environment*) package extension.
3. Open the VS Code Settings in JSON mode:
* Press `Ctrl+Shift+P`.
* Type and select: **Preferences: Open User Settings (JSON)**.


4. Inside the curly braces `{ ... }` of your `settings.json` file, paste the following explicit server environment initialization configurations:
```json
"alive.lsp.startCommand": [
    "sbcl",
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


5. Open your project folder workspace directory within the editor.
6. Press `Ctrl+Shift+P` to drop down the Command Palette and run: **Alive: Start REPL And Attach**.
7. An active side-panel REPL section will populate your workspace layout, confirming successful hooks into your manually spun-up SBCL backend server.

---

### 4. Code Execution Verification & Testing

Create a baseline test script file named `hello.lisp` inside your working workspace directory wrapper.

```lisp
(print "hello world")

;; Evaluation Verification Tests
;;137
(print (+ 135 2))
;;137.5
(print (float (+ 135 2 1/2))) 

;;run on the terminal: sbcl --script hello.lisp
```


```



```

```