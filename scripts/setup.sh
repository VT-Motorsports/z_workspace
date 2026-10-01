#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd -- "$workspace_dir"

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    ca-certificates git cmake ninja-build gperf device-tree-compiler wget \
    python3-dev python3-venv xz-utils file make gcc g++

python3 -m venv .venv-linux
source .venv-linux/bin/activate
export PIP_CACHE_DIR="$workspace_dir/.pip-cache/linux"
export ZEPHYR_BASE="$workspace_dir/deps/zephyr"

python -m pip install --upgrade pip west

mkdir -p .west
touch .west/config
west config --local manifest.path .
west config --local manifest.file west.yml
west config --local zephyr.base deps/zephyr
west config --local update.narrow true
west update

python -m pip install \
    -r deps/zephyr/scripts/requirements-base.txt \
    -r deps/zephyr/scripts/requirements-build-test.txt \
    tabulate natsort
west zephyr-export

sdk_version="$(tr -d '\r\n' < deps/zephyr/SDK_VERSION)"
sdk_base="$workspace_dir/sdk/linux"
sdk_dir="$sdk_base/zephyr-sdk-$sdk_version"

if [[ -f "$sdk_dir/sdk_version" ]]; then
    (cd -- "$sdk_dir" && ./setup.sh -t arm-zephyr-eabi -h -c)
else
    env -u ZEPHYR_SDK_INSTALL_DIR ZEPHYR_TOOLCHAIN_VARIANT=host \
        west sdk install --version "$sdk_version" \
        --install-base "$sdk_base" -t arm-zephyr-eabi
fi

west config --local build.cmake-args -- \
    "\"-DZEPHYR_SDK_INSTALL_DIR=$sdk_dir\" -DZEPHYR_TOOLCHAIN_VARIANT=zephyr"

printf '\nSetup complete. Run: source .venv-linux/bin/activate\n'
