# Formula SAE Zephyr Workspace

Shared Zephyr workspace for all Formula SAE embedded applications.

## Overview

This workspace provides a common Zephyr RTOS environment for all Formula SAE embedded projects. Applications (VCU, BMS, Dashboard, etc.) are separate Git repositories that you clone into this workspace as needed.

**Everything runs in a Docker container** — no manual tool installation required. Just install Docker + VS Code and you're ready to develop.

**Architecture:**
```
formula-workspace/          # This repo (shared workspace)
├── .devcontainer/         # Dev container config (Docker setup)
├── zephyr/                # Fetched by west (shared Zephyr RTOS)
├── modules/               # Fetched by west (HALs, drivers, etc.)
├── vcu/                   # Your cloned app repos
├── bms/                   # (clone as needed)
└── dashboard/             # (clone as needed)
```

---

## Quick Start (Recommended - 10 Minutes)

### Prerequisites (One-time install)

**You only need 3 things:**
1. **[Docker Desktop](https://www.docker.com/products/docker-desktop)** (Windows/Mac/Linux)
2. **[VS Code](https://code.visualstudio.com/)**
3. **[Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)**

**That's it.** No CMake, no Python, no Zephyr SDK to install manually.

---

### Setup Steps

**1. Install Docker Desktop**
- Download and install from https://www.docker.com/products/docker-desktop
- Start Docker Desktop and make sure it's running

**2. Install VS Code + Dev Containers Extension**
```bash
# Install VS Code, then add the extension:
# In VS Code: Ctrl+Shift+X → Search "Dev Containers" → Install
# Or: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
```

**3. Clone This Workspace**
```bash
git clone https://github.com/your-org/formula-workspace
cd formula-workspace
```

**4. Open in VS Code**
```bash
code .
```

**5. Reopen in Container**
- VS Code will prompt: **"Reopen in Container"** → Click it
- Or manually: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
- **First time**: Container builds (~5-10 minutes, downloads ~2-3GB)
- **After first time**: Opens in seconds (cached)

**6. Wait for Zephyr to Download**
- The container automatically runs `west update` in the background
- Check the terminal output to see progress
- This takes 5-10 minutes (only happens once)

**✅ Done!** You're now inside a Linux container with:
- Zephyr SDK installed
- CMake, Ninja, Python, west
- All dependencies configured
- Your workspace code mounted and editable

---

## Adding and Building Applications

**You're now working inside the container.** All commands run in the containerized Linux environment.

### Available Applications

- **VCU** (Vehicle Control Unit): `https://github.com/your-org/vcu`
- **BMS** (Battery Management System): `https://github.com/your-org/bms`
- **Dashboard** (Driver Display): `https://github.com/your-org/dashboard`

### Clone an Application

```bash
# From the workspace root (inside container)
git clone https://github.com/your-org/vcu
```

### Build an Application

```bash
# Option 1: Build from inside the app directory
cd vcu
west build -b vcu_board .

# Option 2: Build from workspace root
west build -b vcu_board -s vcu
```

### Flash to Hardware

**Note:** USB device passthrough varies by OS.

#### Windows/Mac
Docker Desktop supports USB passthrough. Make sure your ST-Link/J-Link is connected.

```bash
cd vcu
west flash
```

#### Linux
Direct USB access works:
```bash
cd vcu
west flash
```

If flash fails, you can build and copy the binary to flash externally:
```bash
west build -b vcu_board .
# Binary is in: build/zephyr/zephyr.bin
# Copy to host and flash with STM32CubeProgrammer or st-flash
```

---

## Working with Multiple Applications

```bash
# Clone multiple apps (inside container)
git clone https://github.com/your-org/vcu
git clone https://github.com/your-org/bms

# Build VCU
cd vcu
west build -b vcu_board .
cd ..

# Build BMS
cd bms
west build -b bms_board .
cd ..
```

Each application maintains its own `build/` directory.

---

## Typical Workflow

```bash
# 1. Open VS Code and reopen in container (if not already)
# 2. Inside container terminal:

# Update workspace (pull latest Zephyr changes)
west update

# Pull latest app changes
cd vcu
git pull
cd ..

# Build
cd vcu
west build -b vcu_board .

# Flash to hardware
west flash
```

---

## VS Code Tips

### Terminal in Container
- Open terminal: `Ctrl + `` (backtick)
- All terminals run inside the container automatically

### Rebuilding Container
If you need to rebuild the container (e.g., after updating .devcontainer config):
- `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

### Exiting Container
- `Ctrl+Shift+P` → "Dev Containers: Reopen Folder Locally"
- This closes the container and opens the workspace on your host

---

## Helper Scripts (Optional)

Convenience scripts are provided:

**Linux/Mac:**
```bash
./scripts/build-app.sh vcu vcu_board
./scripts/build-app.sh bms bms_board
```

**Windows (PowerShell inside container):**
```bash
./scripts/build-app.ps1 vcu vcu_board
```

---

## Troubleshooting

### "Cannot connect to Docker daemon"
- Make sure Docker Desktop is running
- On Windows: Check that WSL 2 backend is enabled

### "Reopen in Container" button doesn't appear
- Install the Dev Containers extension
- Or manually: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

### Container build is slow
- First build downloads ~2-3GB (Zephyr Docker image)
- Subsequent builds use cache (seconds)
- `west update` inside container takes 5-10 minutes first time

### "Board 'xyz' not found"
- Make sure the application repository contains the board definition in `boards/arm/xyz/`

### Build errors after pulling new code
```bash
cd vcu
rm -rf build
west build -b vcu_board .
```

### Can't flash hardware (USB passthrough issues)
- Windows/Mac: Ensure Docker Desktop has USB device access
- Alternative: Copy binary from `build/zephyr/zephyr.bin` and flash externally

---

## Advanced: Native Setup (Not Recommended)

If you absolutely need native builds (not containerized), see [NATIVE_SETUP.md](docs/NATIVE_SETUP.md).

**Why container is better:**
- ✅ No SDK installation (~2GB, 20 minutes)
- ✅ No Python environment conflicts
- ✅ No CMake version mismatches
- ✅ Works identically on Windows/Mac/Linux
- ✅ New members onboard in 10 minutes vs 2 hours

---

## Directory Structure

```
formula-workspace/
├── .devcontainer/
│   └── devcontainer.json    # Dev container config
├── .west/                   # West metadata (auto-generated)
├── west.yml                 # Manifest (Zephyr version + modules)
├── .gitignore              # Excludes dependencies and apps
├── README.md               # This file
├── scripts/                # Helper scripts
│
# Fetched by west update:
├── zephyr/                 # Zephyr RTOS v4.2.0
├── modules/                # HALs (hal_stm32, etc.)
├── bootloader/             # MCUboot (if needed)
│
# Cloned by developers:
├── vcu/                    # Vehicle Control Unit app
├── bms/                    # Battery Management System app
└── dashboard/              # Driver Display app
```

---

## Updating Zephyr Version

To update to a new Zephyr version:

1. Edit `west.yml` and change the revision:
   ```yaml
   revision: v4.3.0  # or desired version
   ```

2. Update `.devcontainer/devcontainer.json` if needed (change Docker image version)

3. Rebuild container:
   - `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

4. Inside container:
   ```bash
   west update
   ```

---

## What's in the Container?

The dev container uses Zephyr's official Docker image which includes:
- **Zephyr SDK 0.16.5**: ARM, RISC-V, x86 toolchains
- **CMake 3.27+**
- **Ninja build system**
- **Python 3.11** with west and dependencies
- **Device tree compiler (dtc)**
- **GDB** for debugging
- **OpenOCD** for flashing/debugging
- **Git, curl, wget** and other utilities

---

## Resources

- [Zephyr Documentation](https://docs.zephyrproject.org/)
- [West User Guide](https://docs.zephyrproject.org/latest/develop/west/index.html)
- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

---

## Support

For issues with:
- **Workspace/container setup**: Contact the embedded systems lead
- **Application code**: Open an issue in the specific app repository
- **Zephyr RTOS**: Check Zephyr documentation or GitHub discussions
- **Docker/VS Code**: Check official documentation links above
