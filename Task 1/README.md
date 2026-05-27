
# Task 1 - Environment Setup and RISC-V Reference Bring-Up

## Objective
Set up the GitHub Codespace environment, run the reference RISC-V design successfully, and run the VSDFPGA labs in the same environment.
# Step 1: Set up GitHub Codespace

## Environment Used
- Platform: GitHub Codespace
- Reference repository: `vsd-riscv2`
- Labs repository: `vsdfpgalabs`

## Work Completed
1. Forked the `vsd-riscv2` repository.
2. Launched GitHub Codespace from the fork.
3. Built and ran the reference RISC-V program by following the repository README.
4. Cloned the `vsdfpgalabs` repository inside the same Codespace.
5. Ran the basic labs that do not require FPGA hardware.

# Step 2: Verify RISC-V Reference Flow
## Execution Proof
## RISC-V Reference Program


### Step 1. Open the Repository

Go to:  
[https://github.com/vsdip/vsd-riscv2](https://github.com/vsdip/vsd-riscv2)

---

### Step 2. Create a Codespace

1. Log in with your GitHub account.
2. Click the green **Code** button.
3. Select **Open with Codespaces** → **New codespace**.
4. Wait while the environment builds. (First time may take 10–15 minutes.)
![RV_CP](/images/RV_CP.png)

---

### Step 3. Verify the Setup

In the terminal that opens, type:

```bash
riscv64-unknown-elf-gcc --version
spike --version
iverilog -V
````

You should see version information for each tool.
![RV_CP1](/images/RV_CP1.png)

---

### Step 4. Run Your First Program

1. Go to the `samples` folder.
2. Compile the program:

   ```bash
   riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c
   ```
3. Run it with Spike:

   ```bash
   spike pk sum1ton.o
   ```

Expected output:

```text
Sum from 1 to 9 is 45
```
![RV_CP3](/images/RV_CP3.png)
---

### Step 5. Next Steps

* You can edit and run your own C programs.
![RV_CP2](/images/RV_CP2.png)
# Step 3: Clone and Run VSDFPGA Labs 
- clone the FPGA labs repository inside the same Codespace:

```bash
git clone https://github.com/vsdip/vsdfpga_labs.git
cd vsdfpga_labs
```
![FP_CP](/images/FP_CP.png)
- Follow the README instructions in vsdfpga_labs
- Install the following tools before proceeding:

### General dependencies

```
sudo apt-get install git vim autoconf automake autotools-dev curl libmpc-dev \
libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
patchutils bc zlib1g-dev libexpat1-dev gtkwave picocom -y
```


### FPGA toolchain (Yosys/NextPNR/IceStorm)
```
sudo apt-get install yosys nextpnr-ice40 icestorm iverilog -y
```
### RISC-V Toolchain (GCC 8.3.0)

```
cd ~
mkdir -p riscv_toolchain && cd riscv_toolchain
wget "https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz"
tar -xvzf riscv64-unknown-elf-gcc-*.tar.gz
echo 'export PATH=$HOME/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```
## Building & Running

### Building the file

```
git clone https://github.com/vsdip/vsdfpga_labs.git
cd vsdfpga_labs/basicRISCV/Firmware
nano riscv_logo.c
make riscv_logo.bram.hex
```
![Codespace Build](/images/flash.png)

Compiling and Running the file

```
riscv64-unknown-elf-gcc -o riscv_logo riscv_logo.c
spike pk riscv_logo
```
![Codespace Build](/images/main.png)

# Step 4: Local Machine Preparation
Clone both repositories locally: <br>
```vsd-riscv2``` &  ```vsdfpga_labs```

```bash
git clone https://github.com/vsdip/vsdfpga_labs.git
cd vsdfpga_labs
```
![LC_DV](/images/LC_DV.png)
![LC_DV](/images/LC_DV1.png)
![LC_DV](/images/LC_DV2.png)
![LC_DV](/images/LC_DV3.png)
---

## Understanding Questions

### 1. Where is the RISC-V program located in the `vsd-riscv2` repository?
The RISC-V program is located in the samples/ directory of the vsd-riscv2 repository.
It contains:
- samples/sum1ton.c       → main C program (sum of 1 to n)
- samples/arithmetic_progression.c   → custom Program
- samples/load.S          → assembly routine (the actual load/loop logic)
- samples/Makefile        → build script

### 2. How is the program compiled and loaded into memory?
The program is compiled using the RISC-V cross-compiler toolchain (riscv64-unknown-elf-gcc). The Makefile in samples/ shows the compilation step:
```
riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c
```
the sum1ton program, the C source (sum1ton.c) is compiled along with the assembly startup file (load.S) into an ELF binary. The ELF binary contains the compiled machine code and data sections (.text, .data, .bss). This binary is then loaded into the simulated memory of the RISC-V system in the Codespace/simulation environment, a tool like spike (the RISC-V ISA simulator) or a testbench reads the ELF and maps it into the address space, placing the program into instruction memory starting at the reset vector so the core can fetch and execute it.
### 3. How does the RISC-V core access memory and memory-mapped I/O?
The RISC-V core uses load (lw, lb, lh) and store (sw, sb, sh) instructions to access both regular memory and memory-mapped I/O (MMIO). There is no separate I/O instruction set in RISC-V - peripherals are placed at specific fixed addresses in the same address space as RAM.

When the CPU executes a load/store to a particular address:

- If the address falls within RAM range → the memory controller services the request.

- If the address falls within a peripheral's address range (e.g., a UART or GPIO register at 0x10000000) → the bus/address decoder routes the transaction to that peripheral's register interface.

The SoC uses a simple address decoder (typically in the top-level SoC Verilog) that checks the upper bits of the address and asserts a chip-select to the matching peripheral. This is the standard memory-mapped bus model used in this VSDSquadron RISC-V SoC.

### 4. Where would a new FPGA IP block logically integrate in this system?
A new FPGA IP block (e.g., GPIO, Timer, SPI) would integrate at three levels:

- RTL level - A new Verilog module is created for the IP with a memory-mapped register interface (a set of read/write registers at defined offsets).

- SoC top-level - The IP module is instantiated in the SoC top-level file, where:

   - Its bus signals (address, data, write-enable, read-enable) are connected to the main CPU bus.

   - An address decoder is updated to assign a base address (e.g., 0x20000000) to the new IP, so CPU load/store instructions targeting that range are routed to the IP.

- Software level - The C firmware running on the RISC-V core accesses the IP by reading/writing to its base address using pointer dereferences:
```
#define MY_IP_BASE 0x20000000
volatile unsigned int *reg = (volatile unsigned int *) MY_IP_BASE;
*reg = 0x1; // write to IP register
```
In short, the integration point is the SoC top-level address decoder + bus interconnect, sitting between the CPU and the peripheral modules.


## Conclusion
Task 1 environment setup and reference execution completed successfully in GitHub Codespace.