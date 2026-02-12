# Quick Reference

Common commands for daily development with Zephyr.

---

## Workspace Management

### Initialize Workspace
```powershell
# First time setup
west init -l .          # Initialize workspace from west.yml
west update             # Fetch Zephyr and modules (~5-10 min)

# Install Zephyr's Python dependencies (required)
pip install -r zephyr\scripts\requirements.txt

# Export Zephyr CMake package (required)
west zephyr-export
```

### Update Workspace
```powershell
# Pull latest Zephyr changes
cd C:\FORMULA\Code\formula-workspace
west update

# Update specific project
west update zephyr
west update hal_stm32
```

### Check Workspace Status
```powershell
# List all projects and their versions
west list

# Show detailed status
west status

# Show Zephyr version
west list zephyr
```

---

## Building

### Basic Build
```powershell
# From app directory
cd vcu
west build -b vcu_board .

# From workspace root
west build -b vcu_board -s vcu
```

### Clean Builds
```powershell
# Pristine build (cleans first)
west build -b vcu_board . -p

# Or manually
rm -r build
west build -b vcu_board .
```

### Build Configurations
```powershell
# Debug build (default)
west build -b vcu_board .

# Release build (optimized)
west build -b vcu_board . -- -DCONFIG_DEBUG=n -DCONFIG_SIZE_OPTIMIZATIONS=y

# Verbose build output
west build -b vcu_board . -v
```

### Build for Different Boards
```powershell
# Build for VCU
west build -b vcu_board .

# Build for BMS (example)
west build -b bms_board .

# List available boards
west boards
```

---

## Configuration

### Menuconfig (Interactive Config)
```powershell
cd vcu
west build -t menuconfig

# Make changes in the TUI, save, and rebuild
west build
```

### Edit Configuration Files
```powershell
# Application config
notepad vcu\prj.conf

# Board-specific config
notepad vcu\boards\arm\vcu_board\vcu_board_defconfig
```

### View Current Configuration
```powershell
cd vcu\build
cat zephyr\.config | Select-String "CONFIG_SOME_OPTION"
```

---

## Flashing

### Using West
```powershell
cd vcu
west flash

# Flash with specific runner
west flash --runner openocd
west flash --runner jlink
```

### Manual Flash (STM32CubeProgrammer)
1. Build firmware: `west build -b vcu_board .`
2. Binary location: `build\zephyr\zephyr.bin`
3. Open STM32CubeProgrammer
4. Connect to ST-Link
5. Load binary, flash to `0x08000000`

### Using st-flash (Command Line)
```powershell
# Install st-link tools
# Download from: https://github.com/stlink-org/stlink/releases

cd vcu\build\zephyr
st-flash write zephyr.bin 0x08000000
```

---

## Debugging

### Using GDB + OpenOCD
```powershell
# Terminal 1: Start OpenOCD
cd vcu
openocd -f interface/stlink.cfg -f target/stm32h7x.cfg

# Terminal 2: Start GDB
cd vcu
arm-zephyr-eabi-gdb build\zephyr\zephyr.elf

# In GDB:
(gdb) target remote :3333
(gdb) monitor reset halt
(gdb) load
(gdb) break main
(gdb) continue
```

### Common GDB Commands
```gdb
break main              # Set breakpoint at main
break file.c:123        # Set breakpoint at line
continue                # Resume execution
next                    # Step over
step                    # Step into
backtrace               # Show call stack
info registers          # Show register values
print variable          # Print variable value
x/16x 0x20000000        # Examine memory
```

### Using VS Code Cortex-Debug
1. Install Cortex-Debug extension
2. Create `.vscode/launch.json`:
   ```json
   {
     "configurations": [{
       "name": "Debug VCU",
       "type": "cortex-debug",
       "request": "launch",
       "executable": "${workspaceFolder}/build/zephyr/zephyr.elf",
       "servertype": "openocd",
       "configFiles": [
         "interface/stlink.cfg",
         "target/stm32h7x.cfg"
       ]
     }]
   }
   ```
3. Press F5 to debug

---

## Serial Console

### Connect to Console
```powershell
# Using PuTTY
# Port: COM3 (check Device Manager)
# Baud: 115200
# Data: 8 bits, No parity, 1 stop bit

# Using PowerShell (Windows 11+)
python -m serial.tools.miniterm COM3 115200

# Install pyserial if needed
pip install pyserial
```

### Common Console Output
```
*** Booting Zephyr OS build v4.2.0 ***
[00:00:00.000,000] <inf> main: VCU started
[00:00:00.100,000] <dbg> can: CAN bus initialized
...
```

---

## Git Workflow

### Working on an App
```powershell
# Clone app
git clone https://github.com/YOUR-ORG/vcu
cd vcu

# Create feature branch
git checkout -b feature/my-feature

# Make changes, commit
git add .
git commit -m "Add feature description"

# Push to remote
git push origin feature/my-feature
```

### Updating App
```powershell
cd vcu
git pull origin main

# Rebuild if dependencies changed
rm -r build
west build -b vcu_board .
```

---

## File Locations

### Important Paths
```
C:\FORMULA\Code\formula-workspace\
├── zephyr\              # Zephyr RTOS source
├── modules\             # HAL modules
│   ├── hal\stm32\      # STM32 HAL
│   └── ...
├── vcu\                 # Your VCU app
│   ├── src\            # Source code
│   ├── boards\         # Board definitions
│   ├── build\          # Build output
│   │   └── zephyr\
│   │       ├── zephyr.elf   # Debug binary
│   │       ├── zephyr.bin   # Flash binary
│   │       └── zephyr.hex   # Hex format
│   ├── prj.conf        # App configuration
│   └── CMakeLists.txt  # Build script
└── west.yml            # Workspace manifest
```

### SDK Location
```
C:\zephyr-sdk-0.16.5-1\
├── arm-zephyr-eabi\     # ARM toolchain
│   └── bin\
│       ├── arm-zephyr-eabi-gcc.exe
│       ├── arm-zephyr-eabi-gdb.exe
│       └── ...
└── cmake\              # CMake integration
```

---

## Useful Checks

### Verify Toolchain
```powershell
# GCC version
arm-zephyr-eabi-gcc --version

# SDK location
echo $env:ZEPHYR_SDK_INSTALL_DIR

# CMake can find toolchain
cd vcu
west build -b vcu_board . --dry-run
```

### Check Build Size
```powershell
cd vcu\build

# See memory usage
cat zephyr\zephyr.stat

# Or from build output (end of build log)
```

### Examine Binary
```powershell
cd vcu\build\zephyr

# See sections and sizes
arm-zephyr-eabi-size zephyr.elf

# Dump symbols
arm-zephyr-eabi-nm zephyr.elf | Select-String "main"

# Disassemble
arm-zephyr-eabi-objdump -d zephyr.elf > disassembly.txt
```

---

## Performance Tips

### Faster Builds
```powershell
# Use ninja (default, fastest)
west build -b vcu_board .

# Parallel builds (adjust based on CPU cores)
west build -b vcu_board . -- -j8

# Incremental builds (only rebuild changed files)
# Just run west build again, no clean needed
west build
```

### Reduce Build Size
```ini
# In prj.conf
CONFIG_SIZE_OPTIMIZATIONS=y
CONFIG_LTO=y                    # Link-time optimization
CONFIG_DEBUG=n
CONFIG_ASSERT=n
CONFIG_LOG_MODE_MINIMAL=y
```

---

## Common Workflows

### Daily Development
```powershell
# 1. Pull latest code
cd vcu
git pull

# 2. Make changes
notepad src\main.c

# 3. Build
west build

# 4. Flash
west flash

# 5. Monitor console
# (in another window)
python -m serial.tools.miniterm COM3 115200
```

### Adding New Source File
```powershell
# 1. Create file
notepad vcu\src\new_module.c

# 2. Add to CMakeLists.txt
notepad vcu\CMakeLists.txt
# Add: target_sources(app PRIVATE src/new_module.c)

# 3. Rebuild
cd vcu
west build
```

### Changing Zephyr Version
```powershell
# 1. Edit manifest
cd C:\FORMULA\Code\formula-workspace
notepad west.yml
# Change: revision: v4.3.0

# 2. Update workspace
west update

# 3. Clean rebuild all apps
cd vcu
rm -r build
west build -b vcu_board .
```

---

## Emergency Commands

### "Everything is broken, start fresh"
```powershell
# Delete workspace
cd C:\FORMULA\Code
rm -r formula-workspace

# Re-clone
git clone https://github.com/YOUR-ORG/formula-workspace
cd formula-workspace
west init -l .
west update
```

### "Build is corrupted"
```powershell
cd vcu
rm -r build
west build -b vcu_board . -p
```

### "West is confused"
```powershell
# Remove west metadata
cd C:\FORMULA\Code\formula-workspace
rm -r .west

# Re-initialize
west init -l .
west update
```

---

## Resources

- **Zephyr Docs:** https://docs.zephyrproject.org/
- **West Guide:** https://docs.zephyrproject.org/latest/develop/west/index.html
- **Kconfig Reference:** https://docs.zephyrproject.org/latest/build/kconfig/index.html
- **Devicetree Guide:** https://docs.zephyrproject.org/latest/build/dts/index.html
- **API Docs:** https://docs.zephyrproject.org/latest/doxygen/html/index.html