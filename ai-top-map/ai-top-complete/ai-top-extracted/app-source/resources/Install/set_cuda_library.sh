#!/bin/bash
echo "Export cuda c++ library "
export LIBRARY_PATH="/usr/local/cuda-12.4/lib64:$LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH"

echo "Echo the variables to confirm they were set correctly"
echo "LIBRARY_PATH is set to: $LIBRARY_PATH"
echo "LD_LIBRARY_PATH is set to: $LD_LIBRARY_PATH"

echo "Finish."
