#!/bin/bash

# Skip installation of NCCL RDMA sharp plugin for CX-3 pro
sed -i '25,33 s/^/#/' $UBUNTU_COMMON_DIR/install_nccl.sh
$UBUNTU_COMMON_DIR/install_nccl.sh
