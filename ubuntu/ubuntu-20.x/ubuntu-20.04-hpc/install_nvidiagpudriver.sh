#!/bin/bash
set -ex

$UBUNTU_COMMON_DIR/install_nvidiagpudriver.sh 2004 "f1b48828dc3233e769a5bb1518e8d8d120de5d8dd336bccc1f547b8c05887ebd"
$UBUNTU_COMMON_DIR/install_nv_peer_memory.sh

# Install gdrcopy
sudo apt install -y build-essential devscripts debhelper check libsubunit-dev fakeroot pkg-config dkms
GDRCOPY_VERSION="2.3"
TARBALL="v${GDRCOPY_VERSION}.tar.gz"
GDRCOPY_DOWNLOAD_URL=https://github.com/NVIDIA/gdrcopy/archive/refs/tags/${TARBALL}
wget $GDRCOPY_DOWNLOAD_URL
tar -xvf $TARBALL

pushd gdrcopy-${GDRCOPY_VERSION}/packages/
CUDA=/usr/local/cuda ./build-deb-packages.sh 
sudo dpkg -i gdrdrv-dkms_${GDRCOPY_VERSION}-1_amd64.Ubuntu20_04.deb
sudo apt-mark hold gdrdrv-dkms
sudo dpkg -i libgdrapi_${GDRCOPY_VERSION}-1_amd64.Ubuntu20_04.deb
sudo apt-mark hold libgdrapi
sudo dpkg -i gdrcopy-tests_${GDRCOPY_VERSION}-1_amd64.Ubuntu20_04.deb
sudo apt-mark hold gdrcopy-tests
sudo dpkg -i gdrcopy_${GDRCOPY_VERSION}-1_amd64.Ubuntu20_04.deb
sudo apt-mark hold gdrcopy
popd

$COMMON_DIR/write_component_version.sh "GDRCOPY" ${GDRCOPY_VERSION}

# Install nvidia fabric manager (required for ND96asr_v4)
$UBUNTU_COMMON_DIR/install_nvidia_fabric_manager.sh 2004
