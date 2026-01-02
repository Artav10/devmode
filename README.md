# DevMode 🛠️

DevMode is a PowerShell script designed to **quickly launch a complete development environment** from a single profile.

The goal is to automate common developer workflows by launching multiple applications, opening folders, and running custom commands (Git, terminal commands, Visual Studio Code, etc.) using a simple JSON configuration file.

---

## ✨ Current Features

- Launch multiple applications automatically
- Open specific URLs (documentation, tools, dashboards, etc.)
- Open folders in Visual Studio Code
- Execute custom shell commands
- Automatically execute shell commands INTO Visual Studio Code Terminal (using a tasks.json)
- Run Git commands (`pull`, `status`, etc.)
- Execute commands inside specific directories
- Support for profile arguments (e.g. `devmode discord personnal_bot`)
- Fully JSON-based configuration (`profiles.json`)

> ✅ The execution layer is **functional**.

---

## 📦 How It Works

DevMode reads a `profiles.json` file that describes:
- Which applications to launch
- Which paths to open
- Which commands to execute
- How profile arguments should be injected dynamically

Example command:

```powershell
devmode minecraft mypack
```
This will open a development environment as defined in the minecraft profile inside profiles.json.
For more information, please check the profiles.json file — it contains a complete example.
A GUI to make profile creation easier will be added later.

---

## ⬇️ Installation

For now, installation is very simple:
- Download or clone the repository
- Place the folder anywhere you want on your machine
- Add the folder path to your system PATH environment variable

Once done, you’ll be able to run devmode from any directory in your terminal
