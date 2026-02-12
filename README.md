# Virginia Tech Formula SAE - Zephyr Workspace

**Native setup guide for VCU and other embedded applications.**

This workspace uses Zephyr RTOS 4.2.0 with the official Zephyr SDK. No Docker, no containers, just straightforward native development.

---

## ⏱️ Total Setup Time: ~30 Minutes

- Prerequisites install: ~20 minutes (mostly downloads)
- Workspace setup: ~10 minutes
- **One-time setup, then you're done**

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Install Zephyr SDK](#install-zephyr-sdk)
3. [Install Python and West](#install-python-and-west)
4. [Install Build Tools](#install-build-tools)
5. [Set Up Workspace](#set-up-workspace)
6. [Build Your First App](#build-your-first-app)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

**What you need:**
- Windows 10/11 (64-bit)
- ~5 GB free disk space
- Internet connection
- Administrator access

**Recommended:**
- VS Code (for editing)
- Git for Windows

---

## Install Zephyr SDK

The Zephyr SDK contains all the ARM toolchains (GCC, GDB, etc.) needed to build firmware.

### Step 1: Download Zephyr SDK

**Direct download link (v0.16.5-1, ~500 MB):**
https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5-1/zephyr-sdk-0.16.5-1_windows-x86_64.7z

**Or manually:**
1. Go to: https://github.com/zephyrproject-rtos/sdk-ng/releases
2. Find **v0.16.5-1**
3. Download: `zephyr-sdk-0.16.5-1_windows-x86_64.7z`

### Step 2: Extract SDK

**Extract to a path WITHOUT spaces:**
```
✅ Good: C:\zephyr-sdk-0.16.5-1
✅ Good: D:\tools\zephyr-sdk-0.16.5-1
❌ Bad:  C:\Program Files\zephyr-sdk-0.16.5-1  (has spaces)
```

**Using 7-Zip (if you don't have it, install from https://www.7-zip.org/):**
```powershell
# Right-click the .7z file → 7-Zip → Extract to "zephyr-sdk-0.16.5-1\"
# Move the extracted folder to C:\
```

### Step 3: Run SDK Setup

**Open PowerShell as Administrator:**
```powershell
cd C:\zephyr-sdk-0.16.5-1
.\setup.cmd
```

**This installs:**
- ARM GCC compiler
- Device tree compiler (dtc)
- CMake integration files
- Windows USB drivers (for ST-Link, J-Link, etc.)

**Expected output:**
```
Zephyr SDK 0.16.5-1 Setup

Installing drivers for:
[*] ST-Link
[*] J-Link
...
Setup complete!
```

### Step 4: Verify SDK Installation

```powershell
# Check ARM GCC is accessible
C:\zephyr-sdk-0.16.5-1\arm-zephyr-eabi\bin\arm-zephyr-eabi-gcc.exe --version

# Should show:
# arm-zephyr-eabi-gcc (Zephyr SDK 0.16.5-1) 12.2.0
```

### Step 5: Set Environment Variables

**Set these permanently so CMake can find the SDK:**

**Option A: Using PowerShell (Permanent)**
```powershell
# Set SDK location
[System.Environment]::SetEnvironmentVariable('ZEPHYR_SDK_INSTALL_DIR', 'C:\zephyr-sdk-0.16.5-1', 'User')

# Set toolchain variant
[System.Environment]::SetEnvironmentVariable('ZEPHYR_TOOLCHAIN_VARIANT', 'zephyr', 'User')

# Restart PowerShell for changes to take effect
```

**Option B: Using GUI (Easier)**
1. Press Windows key
2. Search "Environment Variables"
3. Click "Edit environment variables for your account"
4. Under "User variables", click "New"
5. Add:
   - Variable: `ZEPHYR_SDK_INSTALL_DIR`
   - Value: `C:\zephyr-sdk-0.16.5-1`
6. Click "New" again
7. Add:
   - Variable: `ZEPHYR_TOOLCHAIN_VARIANT`
   - Value: `zephyr`
8. Click OK

**Verify (in a NEW PowerShell window):**
```powershell
echo $env:ZEPHYR_SDK_INSTALL_DIR
# Should show: C:\zephyr-sdk-0.16.5-1

echo $env:ZEPHYR_TOOLCHAIN_VARIANT
# Should show: zephyr
```

✅ **Checkpoint:** SDK installed and environment variables set

---

## Install Python and West

West is Zephyr's meta-tool for managing the workspace and building projects.

### Step 1: Install Python

**Download Python 3.11.x (recommended for Zephyr 4.2.0):**

https://www.python.org/downloads/release/python-31110/

**Scroll down to "Files" and download:**
- **Windows installer (64-bit)**: `python-3.11.10-amd64.exe`

**Note:** Python 3.12+ may work but is not extensively tested with Zephyr 4.2.0. We recommend 3.11.x for maximum compatibility.

**During installation:**
- ✅ **CHECK "Add Python to PATH"** (critical!)
- ✅ Click "Install Now"

### Step 2: Verify Python

**Open a NEW PowerShell window:**
```powershell
python --version
# Should show: Python 3.11.10 (or similar)

pip --version
# Should show: pip 24.x.x from ...
```

⚠️ **If "python is not recognized":**
- You didn't check "Add Python to PATH" during install
- Re-run installer, choose "Modify", check "Add Python to environment variables"

### Step 3: Install West

```powershell
pip install west
```

**Verify:**
```powershell
west --version
# Should show: West version: v1.2.0 (or similar)
```

✅ **Checkpoint:** Python and West installed

---

## Install Build Tools

### Step 1: Install CMake

**Download CMake 3.20+:**
https://cmake.org/download/

**Get "Windows x64 Installer":**
- Latest release: `cmake-3.31.5-windows-x86_64.msi`

**During installation:**
- ✅ **Select "Add CMake to the system PATH for all users"**
- Click Next → Install

### Step 2: Install Ninja

**Option A: Using Chocolatey (easiest)**

If you have Chocolatey:
```powershell
choco install ninja
```

**Option B: Manual Install**

1. Download: https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip
2. Extract `ninja.exe` to: `C:\tools\ninja\` (create folder)
3. Add to PATH:
   ```powershell
   # Open System Environment Variables:
   # Windows key → Search "Environment Variables" → Edit system environment variables
   # → Environment Variables → System Variables → Path → Edit
   # → New → C:\tools\ninja → OK
   ```

### Step 3: Install Device Tree Compiler (dtc)

**Option A: Using Chocolatey**
```powershell
choco install dtc-msys2
```

**Option B: Using MSYS2**

1. Install MSYS2: https://www.msys2.org/
2. In MSYS2 terminal:
   ```bash
   pacman -S dtc
   ```
3. Add MSYS2 bin to PATH: `C:\msys64\usr\bin`

### Step 4: Verify All Tools

**Open a NEW PowerShell window:**
```powershell
cmake --version
# CMake version 3.31.5

ninja --version
# 1.12.1

dtc --version
# Version: DTC 1.7.0
```

✅ **Checkpoint:** All build tools installed

---

## Set Up Workspace

### Prerequisites Check

Before setting up the workspace, configure Git for Windows long paths:

```powershell
# Enable long path support in Git
git config --global core.longpaths true
```

**Why:** Zephyr has deeply nested module paths that can exceed Windows' default 260-character limit.

### Step 1: Create Workspace Directory

```powershell
# Choose a location (no spaces in path)
cd C:\FORMULA\Code
mkdir formula-workspace
cd formula-workspace
```

**Note:** This directory will contain Zephyr, modules, and your manifest repo.

### Step 2: Initialize Workspace from GitHub

**Use west to fetch your manifest repo and set up the workspace:**

```powershell
# Initialize workspace pointing to your manifest repo
west init -m https://github.com/VT-Motorsports/z_workspace .
```

**What this does:**
- Fetches your manifest repo (README, west.yml, etc.)
- Creates `.west/` metadata in current directory
- Sets up workspace structure

**Expected output:**
```
=== Initializing in C:\FORMULA\Code\formula-workspace
--- Cloning manifest repository from https://github.com/VT-Motorsports/z_workspace
...
=== Initialized. Now run "west update".
```

**After this completes, your directory structure will be:**
```
formula-workspace/
├── .west/                      ← West metadata
└── z_workspace/                ← Manifest repo (cloned by west)
    ├── README.md
    ├── west.yml
    └── ...
```

**Note:** The manifest repo is cloned as a subdirectory named `z_workspace`.

### Step 3: Fetch Zephyr and Modules

```powershell
west update
```

**This downloads:**
- Zephyr RTOS source (~500 MB)
- HAL modules (STM32, NXP, etc.)
- Other dependencies

⏱️ **Takes 5-10 minutes depending on internet speed**

**Expected output:**
```
=== updating zephyr (zephyr):
--- zephyr: initializing
Initialized empty Git repository in C:/FORMULA/Code/formula-workspace/zephyr/.git/
...
=== updating hal_stm32 (modules/hal/stm32):
...
=== update completed successfully.
```

### Step 4: Install Zephyr's Python Requirements

**After `west update` completes, install Zephyr's build dependencies:**

```powershell
pip install -r zephyr\scripts\requirements.txt
```

**This installs:**
- PyYAML (devicetree and Kconfig processing)
- pyelftools (binary analysis)
- canopen (CAN utilities)
- packaging (version handling)
- progress (build progress bars)
- psutil (system utilities)
- Other build-time Python tools

⏱️ **Takes ~1 minute**

**Expected output:**
```
Collecting PyYAML>=5.1
  Downloading PyYAML-6.0-cp311-cp311-win_amd64.whl
...
Successfully installed PyYAML-6.0 pyelftools-0.29 ...
```

⚠️ **This is required** - without these packages, builds will fail with Python import errors.

### Step 5: Export Zephyr CMake Package

**Run west zephyr-export to set up CMake integration:**

```powershell
west zephyr-export
```

**This creates:**
- CMake package files for Zephyr
- Allows CMake to find Zephyr modules
- Required for IDE integration and proper builds

**Expected output:**
```
Zephyr (c:\formula\code\formula-workspace\zephyr)
has been added to the user package registry in:
C:\Users\YourName\.cmake\packages\Zephyr
```

✅ **Checkpoint:** Zephyr Python dependencies installed, CMake package exported

### Step 6: Verify Workspace

```powershell
# Check what was fetched
west list

# Should show:
# manifest     z_workspace                                 HEAD                    N/A
# zephyr       zephyr                                      v4.2.0                  https://github.com/zephyrproject-rtos/zephyr
# hal_stm32    modules/hal/stm32                           <commit>                https://github.com/zephyrproject-rtos/hal_stm32
# ... (many more modules)
```

**Check folders exist:**
```powershell
dir

# You should see:
# .west/                   ← West metadata
# z_workspace/             ← Manifest repo (documentation, west.yml)
# zephyr/                  ← Zephyr RTOS source
# modules/                 ← HAL modules
# bootloader/              ← MCUboot (maybe)
# tools/                   ← Additional tools
```

**Verify Python requirements:**
```powershell
python -c "import yaml; import elftools; print('Python deps OK')"
# Should print: Python deps OK
```

✅ **Checkpoint:** Workspace set up, Zephyr downloaded, Python requirements installed, CMake package exported

---

## Understanding the Workspace Architecture

### How Zephyr Workspaces Work

**A Zephyr workspace contains:**
1. **Zephyr RTOS** - The core operating system (`zephyr/`)
2. **HAL Modules** - Hardware abstraction layers for different MCUs (`modules/`)
3. **Applications** - Your firmware projects (like `z_vcu/`)
4. **Manifest Repo** - Documentation and workspace configuration (`z_workspace/`)

**Key concept:** Multiple applications can share the same Zephyr RTOS and modules installation.

```
workspace/
├── .west/                 ← West metadata
├── z_workspace/           ← Documentation, setup guides
├── zephyr/                ← Zephyr RTOS (shared by all apps)
├── modules/               ← Hardware drivers (shared by all apps)
├── z_vcu/                 ← VCU application
├── z_bms/                 ← BMS application (example)
└── my_custom_app/         ← Your new application
```

### Benefits of This Architecture

✅ **One Zephyr installation** - All apps use the same RTOS version (no conflicts)  
✅ **Shared modules** - Don't re-download STM32 HAL for each project  
✅ **Consistent environment** - Everyone on the team has identical setup  
✅ **Easy experimentation** - Fork an app, make changes, build alongside original  

---

## Working with Applications

### Using the VCU Application

The **z_vcu** repo contains firmware for the Vehicle Control Unit running on STM32H753VIT6.

**To work on VCU:**
```powershell
# Clone into workspace (see "Build Your First App" below)
git clone https://github.com/VT-Motorsports/z_vcu
cd z_vcu
west build -b vcu_stm32 .
```

### Creating a New Application Based on VCU

**If you're starting a new project using the STM32H753VIT6:**

1. **Fork the z_vcu repository on GitHub**
   - Go to: https://github.com/VT-Motorsports/z_vcu
   - Click "Fork" → Create your own copy

2. **Clone your fork into the workspace**
   ```powershell
   cd C:\FORMULA\Code\formula-workspace
   git clone https://github.com/YOUR-USERNAME/z_vcu my_project_name
   cd my_project_name
   ```

3. **Customize for your project**
   - Edit `CMakeLists.txt` to set your project name
   - Modify source code in `src/`
   - Adjust configuration in `prj.conf`
   - Update board definition in `boards/arm/vcu_stm32/` if needed

4. **Build your application**
   ```powershell
   west build -b vcu_stm32 .
   ```

**Why fork z_vcu?**
- ✅ Starts with working STM32H753VIT6 configuration
- ✅ Board definition already set up
- ✅ Device tree configured for your hardware
- ✅ Basic peripherals (CAN, ADC, GPIO) already initialized
- ✅ Less setup, more building

### Working on Multiple Applications Simultaneously

**You can have multiple apps in the same workspace:**

```powershell
cd C:\FORMULA\Code\formula-workspace

# Clone VCU
git clone https://github.com/VT-Motorsports/z_vcu

# Clone your custom project
git clone https://github.com/YOUR-USERNAME/my_custom_app

# Build VCU
cd z_vcu
west build -b vcu_stm32 .

# Build your custom app (uses same Zephyr installation!)
cd ../my_custom_app
west build -b vcu_stm32 .
```

**Both applications share:**
- Same Zephyr RTOS in `../zephyr/`
- Same STM32 HAL in `../modules/hal/stm32/`
- Same toolchain (Zephyr SDK)

**Each application has:**
- Independent source code
- Independent Git repository
- Independent build configuration
- Independent build output in `build/`

---

## Build Your First App

### Step 1: Clone the VCU Application

**Clone into the workspace root (sibling to `zephyr/` folder):**

```powershell
# Make sure you're in the workspace root (where .west/ is)
cd C:\FORMULA\Code\formula-workspace

# Clone VCU app here
git clone https://github.com/VT-Motorsports/z_vcu

# Your structure should now be:
# formula-workspace/
# ├── .west/               ← West metadata
# ├── z_workspace/         ← Manifest repo (docs, west.yml)
# ├── zephyr/              ← Zephyr RTOS
# ├── modules/             ← HAL modules
# └── z_vcu/               ← VCU application
```

**Important:** Apps must be cloned as siblings to `zephyr/` so west can find dependencies.

### Step 2: Build

```powershell
# Navigate into the app directory
cd z_vcu

# Build
west build -b vcu_stm32 .
```

**What this does:**
- Configures CMake for `vcu_stm32` (custom STM32H753VIT6 board)
- Compiles your application code
- Links against Zephyr RTOS
- Generates firmware binaries

⏱️ **First build: ~2-3 minutes. Incremental builds: ~10-30 seconds**

**Expected output:**
```
-- west build: generating a build system
Loading Zephyr default modules (Zephyr base).
...
-- Configuring done
-- Generating done
-- Build files written to: C:/FORMULA/Code/formula-workspace/z_vcu/build
[1/234] Preparing syscall dependency handling
...
[234/234] Linking C executable zephyr\zephyr.elf
Memory region         Used Size  Region Size  %age Used
           FLASH:      123456 B       2 MB      5.88%
             RAM:       45678 B     512 KB      8.71%
        IDT_LIST:          0 GB         2 KB      0.00%
```

### Step 3: Find Your Binaries

```powershell
cd build\zephyr

dir

# You'll see:
# zephyr.elf    ← ELF file (for debugging)
# zephyr.bin    ← Raw binary (for flashing)
# zephyr.hex    ← Intel HEX format
```

✅ **Checkpoint:** Successfully built firmware!

---

## Flash to Hardware

### Using STM32CubeProgrammer (Recommended)

1. **Install STM32CubeProgrammer:** https://www.st.com/en/development-tools/stm32cubeprog.html
2. **Connect ST-Link to your board**
3. **Open STM32CubeProgrammer**
4. **Select "ST-LINK" interface → Connect**
5. **Open file:** `build/zephyr/zephyr.bin`
6. **Start address:** `0x08000000` (or your flash base address)
7. **Click "Start Programming"**

### Using West Flash (If OpenOCD Configured)

```powershell
cd vcu
west flash
```

**Note:** Requires OpenOCD configuration in your board definition.

---

## Troubleshooting

### "west: command not found"

**Cause:** Python Scripts folder not in PATH

**Fix:**
```powershell
# Find where pip installed west
pip show west
# Look for "Location: C:\Users\<you>\AppData\Local\Programs\Python\Python311\Lib\site-packages"

# Add to PATH:
# The Scripts folder is one level up: C:\Users\<you>\AppData\Local\Programs\Python\Python311\Scripts

# Add via System Environment Variables or:
$env:Path += ";C:\Users\<you>\AppData\Local\Programs\Python\Python311\Scripts"
```

### "CMake Error: could not find toolchain"

**Cause:** SDK not found or not set up correctly

**Fix:**
```powershell
# Verify SDK location
dir C:\zephyr-sdk-0.16.5-1

# Re-run setup
cd C:\zephyr-sdk-0.16.5-1
.\setup.cmd

# Set environment variable (if needed)
$env:ZEPHYR_SDK_INSTALL_DIR = "C:\zephyr-sdk-0.16.5-1"
```

### "Board 'vcu_board' not found"

**Cause:** Board definition not in your app repo

**Fix:**
- Ensure `vcu/boards/arm/vcu_board/` exists with:
  - `vcu_board.dts` (devicetree)
  - `vcu_board_defconfig` (Kconfig)
  - `vcu_board.yaml` (metadata)

### "west update" is slow or fails

**Cause:** Large download, network issues

**Fix:**
```powershell
# Use shallow clone (faster, smaller)
west update --fetch-opt=--depth=1

# Or if stuck, delete and retry
rm -r zephyr modules
west update
```

### Build fails with "ninja: error: ..."

**Cause:** Interrupted build, corrupted build cache

**Fix:**
```powershell
# Clean build
cd z_vcu
rm -r build
west build -b vcu_stm32 .
```

---

## Next Steps

**For your team:**
1. Share this README
2. Have everyone run through setup (30 min)
3. Build VCU app together
4. Flash and verify on hardware

**For development:**
- See [QUICKREF.md](QUICKREF.md) for common commands
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed fixes
- Check Zephyr docs: https://docs.zephyrproject.org/

---

## Getting Help

**Common resources:**
- Zephyr Docs: https://docs.zephyrproject.org/
- Zephyr Discord: https://discord.gg/zephyr-rtos
- West Guide: https://docs.zephyrproject.org/latest/develop/west/index.html

**Internal:**
- **Embedded Systems Lead:** Pujan Patel  
  - Email: pujan@vt.edu
  - Phone: (469) 325-8817
- Formula SAE team Slack: #embedded channel

---

## Updating Zephyr Version (Future)

**To update to a new Zephyr release: (DO NOT DO WITHOUT APPROVAL)** 

1. Edit `west.yml`:
   ```yaml
   revision: v4.3.0  # Update this line
   ```

2. Update workspace:
   ```powershell
   west update
   ```

3. Rebuild all apps:
   ```powershell
   cd vcu
   rm -r build
   west build -b vcu_board .
   ```

**Pin versions to avoid drift between team members.**

---

## License

[Your license info]

---

## Contributing

[Your contribution guidelines]