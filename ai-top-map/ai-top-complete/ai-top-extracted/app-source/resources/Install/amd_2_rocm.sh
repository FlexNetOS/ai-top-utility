#!/bin/bash

sudo amdgpu-install -y

export PATH=$PATH:/opt/rocm-6.3.0/bin:/opt/rocm-6.3.0/opencl/bin
/opt/rocm/bin/rocminfo
rocm-smi

echo "Finish."
exit 0
