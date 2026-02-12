# Troubleshooting Guide

Common issues and their solutions when setting up or using the Zephyr workspace.

---

## Installation Issues

### Python/West Issues

#### "python is not recognized as an internal or external command"

**Symptoms:**
```powershell
PS> python --version
python : The term 'python' is not recognized...
```

**Cause:** Python not in PATH

**Solution:**
1. Re-run Python installer
2. Choose "Modify"
3. Check "Add Python to environment variables"
4. Click "Next" → "Install"
5. **Restart PowerShell**

**Verify:**
```powershell
python --version  # Should work now
```

---

#### "west: command not found" (or not recognized)

**Symptoms:**
```powershell
PS> west --version
west : The term 'west' is not recognized...
```

**Cause:** Python Scripts folder not in PATH

**Solution 1: Add Scripts to PATH**
```powershell
# Find Python location
python -c "import sys; print(sys.executable)"
# Example output: C:\Users\YourName\AppData\Local\Programs\Python\Python311\python.exe

# The Scripts folder is in the same directory
# Add to PATH via:
# Start → Search "Environment Variables" → Edit system environment variables
# → Environment Variables → User variables → Path → Edit → New
# Add: C:\Users\YourName\AppData\Local\Programs\Python\Python311\Scripts
```

**Solution 2: Reinstall West**
```powershell
pip uninstall west
pip install --user west
```

**Verify:**
```powershell
west --version
```

---

#### "pip install west" fails with permission error

**Symptoms:**
```
ERROR: Could not install packages due to an OSError: [WinError 5] Access is denied
```

**Solution:**
```powershell
# Install for current user only (no admin needed)
pip install --user west
```

---

### SDK Issues

#### "CMake Error: No CMAKE_C_COMPILER could be found"

**Symptoms:**
```
CMake Error at CMakeLists.txt:X (project):
  No CMAKE_C_COMPILER could be found.
```

**Cause:** Zephyr SDK not installed or not found

**Solution 1: Verify SDK installation**
```powershell
# Check SDK exists
dir C:\zephyr-sdk-0.16.5-1

# Check ARM GCC exists
C:\zephyr-sdk-0.16.5-1\arm-zephyr-eabi\bin\arm-zephyr-eabi-gcc.exe --version
```

**Solution 2: Re-run SDK setup**
```powershell
cd C:\zephyr-sdk-0.16.5-1
.\setup.cmd
```

**Solution 3: Set environment variables**
```powershell
# Set for current session
$env:ZEPHYR_SDK_INSTALL_DIR = "C:\zephyr-sdk-0.16.5-1"
$env:ZEPHYR_TOOLCHAIN_VARIANT = "zephyr"

# Or permanently via System Environment Variables (see README.md)
```

**Solution 4: Verify in new PowerShell window**
```powershell
# Open a NEW PowerShell window
echo $env:ZEPHYR_SDK_INSTALL_DIR
# Should show: C:\zephyr-sdk-0.16.5-1
```

---

#### "CMake Error: ZEPHYR_BASE not set"

**Symptoms:**
```
CMake Error: ZEPHYR_BASE environment variable is not set
```

**Cause:** Not running west from within workspace, or west metadata missing

**Solution:**
```powershell
# Make sure you're in the workspace
cd C:\FORMULA\Code\formula-workspace\vcu

# Verify .west exists in parent
dir ..\.west

# If missing, re-initialize
cd ..
west init -l .
```

---

#### SDK setup.cmd fails with USB driver errors

**Symptoms:**
```
Failed to install USB drivers
Error code: 2
```

**Cause:** Not running as Administrator, or drivers already installed

**Solution:**
```powershell
# Run PowerShell as Administrator
# Right-click PowerShell → Run as Administrator

cd C:\zephyr-sdk-0.16.5-1
.\setup.cmd
```

**If still fails:** Drivers might already be installed (check Device Manager for ST-Link / J-Link entries). This is usually safe to ignore.

---

### Build Tool Issues

#### "cmake: command not found"

**Symptoms:**
```powershell
PS> cmake --version
cmake : The term 'cmake' is not recognized...
```

**Cause:** CMake not installed or not in PATH

**Solution:**
1. Download CMake: https://cmake.org/download/
2. Run installer
3. **Select "Add CMake to system PATH for all users"**
4. Complete installation
5. **Restart PowerShell**

**Verify:**
```powershell
cmake --version
```

---

#### "ninja: command not found"

**Cause:** Ninja not installed

**Solution (Chocolatey):**
```powershell
# Install Chocolatey if you don't have it
# https://chocolatey.org/install

choco install ninja
```

**Solution (Manual):**
1. Download: https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip
2. Extract to `C:\tools\ninja\`
3. Add to PATH:
   - Start → "Environment Variables"
   - System variables → Path → Edit → New
   - Add: `C:\tools\ninja`
4. Restart PowerShell

---

## Workspace Issues

### "west init" or "west update" Issues

#### "FATAL ERROR: already initialized in X"

**Symptoms:**
```
FATAL ERROR: already initialized in C:\some\other\path, aborting.
```

**Cause:** West finds an existing workspace in a parent directory

**Solution 1: Remove conflicting .west folder**
```powershell
# Find where the conflict is
dir .west -Recurse -Force

# Remove it
rm -r path\to\.west
```

**Solution 2: Use a fresh directory**
```powershell
cd C:\
mkdir formula-workspace-clean
cd formula-workspace-clean
git clone https://github.com/YOUR-ORG/formula-workspace .
west init -l .
```

---

#### "west update" is extremely slow

**Cause:** Downloading large git repositories (Zephyr is ~500 MB)

**Solution 1: Use shallow clone**
```powershell
west update --fetch-opt=--depth=1
```

**Solution 2: Check network connection**
- Large repos take time
- Zephyr alone is ~500 MB
- Modules add another ~100-200 MB
- Expected time: 5-10 minutes on fast connection

**Solution 3: Use wired connection if on Wi-Fi**

---

#### "west update" fails partway through

**Symptoms:**
```
fatal: unable to access 'https://github.com/...': Failed to connect
```

**Cause:** Network issue, GitHub rate limiting, or interrupted download

**Solution 1: Retry**
```powershell
west update
# West will resume where it left off
```

**Solution 2: Delete partial downloads and retry**
```powershell
# Remove zephyr and modules
rm -r zephyr
rm -r modules

# Retry
west update
```

**Solution 3: Check GitHub status**
- Visit: https://www.githubstatus.com/

---

#### "west update" fails with "Filename too long"

**Symptoms:**
```
error: unable to create file [very long path]: Filename too long
fatal: unable to checkout working tree
```

**Cause:** Windows path length limit (260 characters) hit by nested Zephyr modules

**Solution 1: Enable long paths in Git**
```powershell
git config --global core.longpaths true
```

**Solution 2: Clone to shorter path**
```powershell
# Bad:  C:\Users\YourName\Documents\Projects\Formula\SAE\Embedded\workspace\...
# Good: C:\FORMULA\Code\workspace\...
```

**Solution 3: Enable long paths in Windows (requires admin)**
```powershell
# Run as Administrator
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

Restart your computer after this change.

---

### Build Issues

#### Build fails with "ModuleNotFoundError: No module named 'yaml'" (or similar)

**Symptoms:**
```
ModuleNotFoundError: No module named 'yaml'
ModuleNotFoundError: No module named 'elftools'
ModuleNotFoundError: No module named 'canopen'
```

**Cause:** Zephyr's Python requirements not installed

**Solution:**
```powershell
# Install Zephyr's Python dependencies
cd C:\FORMULA\Code\formula-workspace
pip install -r zephyr\scripts\requirements.txt

# Verify
python -c "import yaml; import elftools; print('Python deps OK')"
```

---

#### "Board 'vcu_board' not found"

**Symptoms:**
```
CMake Error: No board named 'vcu_board' found
```

**Cause:** Board definition files missing from your app repo

**Solution:**

Verify board files exist:
```powershell
cd vcu
dir boards\arm\vcu_board

# Should contain:
# vcu_board.dts           (devicetree)
# vcu_board_defconfig     (Kconfig defaults)
# vcu_board.yaml          (board metadata)
# board.cmake             (optional, for custom flash commands)
```

**If files are missing:** Check your VCU repo or contact the embedded lead.

---

#### Build fails with "region 'FLASH' overflowed"

**Symptoms:**
```
region `FLASH' overflowed by 12345 bytes
```

**Cause:** Compiled code is too large for the flash memory

**Solution 1: Enable optimizations**

Edit `prj.conf`:
```ini
CONFIG_SIZE_OPTIMIZATIONS=y
CONFIG_DEBUG_OPTIMIZATIONS=n
```

**Solution 2: Disable unused features**

Check `prj.conf` for features you don't need:
```ini
# Disable if not using:
CONFIG_LOG=n
CONFIG_PRINTK=n
CONFIG_SHELL=n
```

**Solution 3: Check flash size**

Verify your board definition has correct flash size in `vcu_board.dts`:
```dts
flash0: flash@8000000 {
    reg = <0x08000000 DT_SIZE_M(2)>;  // 2 MB flash
};
```

---

#### Build fails with "undefined reference to..."

**Symptoms:**
```
undefined reference to `some_function'
```

**Cause:** Missing Kconfig options or source files

**Solution 1: Enable required Kconfig**

Check what module provides the missing symbol:
```powershell
# Search Zephyr source
cd zephyr
git grep "some_function"
```

Then enable the corresponding CONFIG option in `prj.conf`.

**Solution 2: Add missing source file**

Ensure all `.c` files are listed in `CMakeLists.txt`:
```cmake
target_sources(app PRIVATE
    src/main.c
    src/missing_file.c  # Add this
)
```

---

#### "west build" fails with "ninja: error: loading 'build.ninja': ..."

**Cause:** Corrupted build directory

**Solution:**
```powershell
# Clean build
cd vcu
rm -r build

# Rebuild from scratch
west build -b vcu_board .
```

---

## Flash/Debug Issues

#### ST-Link not detected

**Symptoms:**
- STM32CubeProgrammer can't find ST-Link
- Device Manager shows unknown device

**Solution 1: Install ST-Link drivers**

Drivers should have been installed by Zephyr SDK setup. If not:

1. Download STM32 ST-LINK Utility: https://www.st.com/en/development-tools/stsw-link004.html
2. Run installer (includes drivers)

**Solution 2: Check USB connection**
- Try different USB port
- Try different USB cable
- Check Device Manager for "STMicroelectronics STLink"

**Solution 3: Update ST-Link firmware**

Use STM32CubeProgrammer → Firmware upgrade

---

#### "west flash" fails

**Symptoms:**
```
Error: unable to open CMSIS-DAP device
```

**Cause:** Board definition doesn't have flash runner configured, or OpenOCD can't find probe

**Solution 1: Use STM32CubeProgrammer**

Flash manually instead of `west flash`:
1. Open STM32CubeProgrammer
2. Connect to ST-Link
3. Load `build/zephyr/zephyr.bin`
4. Flash to address `0x08000000`

**Solution 2: Configure OpenOCD runner**

Add to `vcu/boards/arm/vcu_board/board.cmake`:
```cmake
board_runner_args(openocd --config interface/stlink.cfg --config target/stm32h7x.cfg)
include(${ZEPHYR_BASE}/boards/common/openocd.board.cmake)
```

---

## Runtime Issues

#### Code runs but nothing prints to serial

**Cause:** Console not configured, or wrong baud rate

**Solution 1: Check serial port settings**
- Baud rate: 115200 (Zephyr default)
- Data bits: 8
- Parity: None
- Stop bits: 1

**Solution 2: Enable printk in prj.conf**
```ini
CONFIG_PRINTK=y
CONFIG_UART_CONSOLE=y
```

**Solution 3: Verify devicetree console**

Check `vcu_board.dts` has:
```dts
chosen {
    zephyr,console = &usart1;  // or your UART
};
```

---

#### HardFault or crashes immediately

**Cause:** Stack overflow, uninitialized memory, clock misconfiguration

**Solution 1: Enable stack guards**
```ini
CONFIG_MPU_STACK_GUARD=y
```

**Solution 2: Increase stack sizes**
```ini
CONFIG_MAIN_STACK_SIZE=2048
CONFIG_IDLE_STACK_SIZE=1024
```

**Solution 3: Check clock configuration**

Verify HSE, PLL, and system clock settings in devicetree or board config.

**Solution 4: Debug with GDB**
```powershell
# Start OpenOCD
openocd -f interface/stlink.cfg -f target/stm32h7x.cfg

# In another terminal
arm-zephyr-eabi-gdb build/zephyr/zephyr.elf
(gdb) target remote :3333
(gdb) monitor reset halt
(gdb) continue
# Wait for crash
(gdb) backtrace
```

---

## Performance Issues

#### Build is very slow (>5 minutes)

**Cause:** Antivirus scanning, slow disk, or first build

**Solution 1: Exclude build folder from antivirus**

Add exclusions for:
- `C:\FORMULA\Code\formula-workspace\`
- `C:\zephyr-sdk-0.16.5-1\`

**Solution 2: Use SSD, not HDD**

**Solution 3: First builds are always slow**
- First build: 2-3 minutes (normal)
- Incremental: 10-30 seconds
- Clean rebuild: 2-3 minutes

---

## Version Mismatch Issues

#### "West version mismatch" warnings

**Symptoms:**
```
WARNING: west version X does not match manifest version Y
```

**Cause:** Old version of west

**Solution:**
```powershell
pip install --upgrade west
```

---

#### Strange build errors after updating Zephyr

**Cause:** Old build artifacts from previous Zephyr version

**Solution:**
```powershell
# Clean all build directories
cd vcu
rm -r build

cd ..\other-app
rm -r build

# Rebuild
cd ..\vcu
west build -b vcu_board .
```

---

## Getting More Help

### Check Logs

**West verbose output:**
```powershell
west -v update
west -v build -b vcu_board .
```

**CMake verbose output:**
```powershell
west build -b vcu_board . -v
```

### Search Zephyr Issues

**Common error messages often have GitHub issues:**
- https://github.com/zephyrproject-rtos/zephyr/issues

### Ask for Help

**Before asking:**
1. Copy the **full error message**
2. Note what command you ran
3. Note your Zephyr version: `west list zephyr`
4. Note your SDK version: `arm-zephyr-eabi-gcc --version`

**Where to ask:**
- Team Slack: #embedded
- Zephyr Discord: https://discord.gg/zephyr-rtos
- Embedded lead: [Your contact]

---

## Still Stuck?

**Nuclear option (fresh start):**

```powershell
# Delete everything
cd C:\FORMULA\Code
rm -r formula-workspace

# Start over
git clone https://github.com/YOUR-ORG/formula-workspace
cd formula-workspace
west init -l .
west update
```

This forces a completely clean slate.