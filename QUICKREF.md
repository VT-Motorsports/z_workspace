# Quick Reference

## Container Commands

```bash
# Open workspace in container
code .
# Then: Ctrl+Shift+P → "Dev Containers: Reopen in Container"

# Rebuild container (after config changes)
# Ctrl+Shift+P → "Dev Containers: Rebuild Container"

# Exit container
# Ctrl+Shift+P → "Dev Containers: Reopen Folder Locally"
```

## West Commands

```bash
# Initialize workspace (done automatically by container)
west init -l .

# Fetch/update Zephyr and modules
west update

# Build application
west build -b <board> .              # from app directory
west build -b <board> -s <app>       # from workspace root

# Clean build
west build -b <board> . -p           # pristine build

# Flash firmware
west flash

# Debug
west debug
```

## Git Workflow

```bash
# Clone an application
git clone https://github.com/your-org/vcu

# Update application
cd vcu
git pull

# Create a branch
git checkout -b feature/my-feature

# Commit changes
git add .
git commit -m "Description of changes"

# Push to remote
git push origin feature/my-feature
```

## Build Commands

```bash
# Build VCU
cd vcu
west build -b vcu_board .

# Build BMS
cd bms
west build -b bms_board .

# Build with verbose output
west build -b vcu_board . -v

# Build with specific configuration
west build -b vcu_board . -- -DCONFIG_OPTION=y
```

## Troubleshooting

```bash
# Clean build directory
rm -rf build/

# Check west configuration
west config -l

# Check Zephyr version
west list zephyr

# Verbose build for debugging
west build -b vcu_board . -v

# Check board is found
west boards | grep vcu_board
```

## File Locations

```
/workspace/              → Your workspace root (mounted from host)
/workspace/zephyr/       → Zephyr RTOS
/workspace/modules/      → HAL modules
/workspace/vcu/          → Your app
/workspace/vcu/build/    → Build artifacts
```

## VS Code Shortcuts

```
Ctrl + `               → Open terminal
Ctrl + Shift + P       → Command palette
Ctrl + Shift + B       → Build (if tasks configured)
F5                     → Debug (if launch configured)
Ctrl + K, Ctrl + O     → Open folder
```
