#!/bin/bash
set -ex

# Install NCCL
apt install -y build-essential devscripts debhelper fakeroot
NCCL_VERSION="2.12.7-1"
TARBALL="v${NCCL_VERSION}.tar.gz"
NCCL_DOWNLOAD_URL=https://github.com/NVIDIA/nccl/archive/refs/tags/${TARBALL}
pushd /tmp
wget ${NCCL_DOWNLOAD_URL}
tar -xvf ${TARBALL}

pushd nccl-${NCCL_VERSION}
make -j src.build
make pkg.debian.build
pushd build/pkg/deb/
dpkg -i libnccl2_${NCCL_VERSION}+cuda11.6_amd64.deb
sudo apt-mark hold libnccl2
dpkg -i libnccl-dev_${NCCL_VERSION}+cuda11.6_amd64.deb
sudo apt-mark hold libnccl-dev
popd
popd

# Install the nccl rdma sharp plugin
mkdir -p /usr/local/nccl-rdma-sharp-plugins
apt install -y zlib1g-dev
git clone https://github.com/Mellanox/nccl-rdma-sharp-plugins.git
pushd nccl-rdma-sharp-plugins
./autogen.sh
./configure --prefix=/usr/local/nccl-rdma-sharp-plugins --with-cuda=/usr/local/cuda
make
make install
popd
popd

# Build the nccl tests
source /etc/profile.d/modules.sh
module load mpi/hpcx
git clone https://github.com/NVIDIA/nccl-tests.git
pushd nccl-tests
make MPI=1 MPI_HOME=${HPCX_MPI_DIR} CUDA_HOME=/usr/local/cuda
popd
mv nccl-tests /opt/.
module unload mpi/hpcx

# NCCL-Tests Preset Run Config
cat << EOF >> /etc/nccl.conf
NCCL_IB_PCI_RELAXED_ORDERING=1
CUDA_DEVICE_ORDER=PCI_BUS_ID
NCCL_TOPO_FILE=/opt/microsoft/ndv4-topo.xml
NCCL_SOCKET_IFNAME=eth0
EOF

$COMMON_DIR/write_component_version.sh "NCCL" ${NCCL_VERSION}

# Remove installation files
rm -rf /tmp/${TARBALL}
rm -rf /tmp/nccl-${NCCL_VERSION}
