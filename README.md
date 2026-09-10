# Virginia Tech Formula SAE — Zephyr Workspace

This repository is the **West manifest and development workspace**

## First-time setup

### 1\. Install Git

Git is the only tool required before cloning this repository.

### 2\. Clone the workspace

```
git clone https://github.com/VT-Motorsports/z_workspace.git
cd z_workspace
```

### 3\. Run setup

Open PowerShell and run:

```
.\scripts\setup.ps1
```

The script will:

*   install missing Windows host tools with `winget`
*   install Python 3.12 if needed
*   create the workspace-wide `.venv`
*   install West into that venv
*   download and verify the pinned Zephyr SDK
*   install the SDK under `sdk/`
*   initialize this repository as the West workspace
*   run `west update`
*   fetch `z_vcu`
*   install Zephyr's Python dependencies
*   register Zephyr with CMake

The setup script is safe to run again.

## Start working

At the beginning of a new PowerShell session:

```
. .\scripts\activate.ps1
```

This activates the workspace venv and configures the local Zephyr SDK.

Then:

```
cd z_vcu
west build -b vcu_stm32 .
```

The virtual environment is shared by every application in this workspace.

## Updating the workspace

Pull changes to this manifest repository normally:

```
git pull
```

Then update all West-managed repositories:

```
west update
```

If the manifest changes, `west update` will fetch the repositories and revisions specified by the new manifest.

## Building VCU

```
. .\scripts\activate.ps1
cd z_vcu
west build -b vcu_stm32 .
```

To start clean:

```
west build -p always -b vcu_stm32 .
```

## Development requirements

The supported development environment for this workspace is currently:

*   Windows 10/11 x86-64
*   PowerShell
*   Git
*   Python 3.12
*   CMake
*   Ninja
*   Device Tree Compiler
*   gperf
*   7-Zip
*   Zephyr 4.2.0
*   Zephyr SDK 0.16.5-1