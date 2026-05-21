#!/bin/bash

mkdir -p external
cd external

if [ ! -d "vsd-riscv2" ]; then
    git clone https://github.com/vsdip/vsd-riscv2.git
fi

if [ ! -d "vsdfpga_labs" ]; then
    git clone https://github.com/vsdip/vsdfpga_labs.git
fi

echo "Repositories cloned successfully."