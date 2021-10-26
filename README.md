# Example ISP Project

This project requires [hope-src](https://github.com/draperlaboratory/hope-src) to be installed and `ISP_PREFIX` to be set and pointing to your ISP installation directory.

To build the example binary, run `make` in the project root.  The resulting `hello` RISC-V binary can be tagged by running `make isp` to produce tag data in a directory named
isp-run-hello-rwx.  Assuming an FPGA (Xilinx VCU118 by default) is connected and Vivado is installed and on your `PATH`, the program can be run with ISP enabled using `make
run-isp BITSTREAM=/path/to/fpga/bitstream`.  AP and PEX UART output will be placed in isp-run-hello-rwx/uart.log and isp-run-hello-rwx/pex.log, respectively.

Build variables:
- `PLATFORM` (default: vcu118): change the FPGA to produce tag info for
- `XLEN` (default: 64): address/data width of the AP
- `CPU_CLOCK_HZ` (default: 100000000): clock rate of the ISP in Hz
- `POLICY`: policy to enforce when running the binary
