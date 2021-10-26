ifeq ($(ISP_PREFIX),)
$(error ISP_PREFIX is not set)
endif
PLATFORM ?= vcu118
XLEN ?= 64
CPU_CLOCK_HZ ?= 100000000

ifeq ($(XLEN),32)
ARCH=rv32ima
ABI=ilp32
else
ARCH=rv64imafd
ABI=lp64d
endif

RISCV_CC ?= $(ISP_PREFIX)/bin/clang --target=riscv$(XLEN)-unknown-elf
DEFINES=-DRV$(XLEN) -DCPU_CLOCK_HZ=$(CPU_CLOCK_HZ) -DALIGN_UART
CFLAGS += -mcmodel=medany -march=$(ARCH) -mabi=$(ABI) -std=gnu11 -mno-relax -ffunction-sections -fdata-sections -fno-builtin-printf --sysroot=$(ISP_PREFIX)/clang_sysroot/riscv64-unknown-elf
LDFLAGS += -L$(BSP) -Tlink.ld -nostartfiles -fuse-ld=lld -Wl,--wrap=isatty -Wl,--wrap=printf -Wl,--wrap=puts -Wl,--wrap=read -Wl,--wrap=write -Wl,--wrap=malloc -Wl,--wrap=free -Wl,--undefined=pvPortMalloc -Wl,--undefined=pvPortFree

BSP ?= bsp
SRC=$(shell find . -name "*.c") $(shell find . -name "*.S")
INCLUDES=$(BSP) $(BSP)/wrap $(BSP)/xilinx $(BSP)/xilinx/common $(BSP)/xilinx/uartns550 $(ISP_PREFIX)/include

.PHONY: hello
hello: $(BSP) $(SRC)
	$(RISCV_CC) $(CFLAGS) $(DEFINES) $(INCLUDES:%=-I%) $(LDFLAGS) -o $@ $(SRC)

$(BSP): $(ISP_PREFIX)/$(PLATFORM)_bsp
	mkdir -p $@
	cp -R $</* $@

POLICY ?= rwx
ISP_DIR=isp-run-hello-$(POLICY)
ISP_COMMAND=isp_run_app hello -r bare -s $(PLATFORM) -p $(POLICY) -a rv$(XLEN)
isp: hello
	$(ISP_COMMAND) -t

isp-debug: hello
	$(ISP_COMMAND) -t -d -D

ifeq ($(XLEN),32)
PROCESSOR=P1
else
PROCESSOR=P2
endif
run-isp: hello
	$(ISP_COMMAND) -e +processor $(PROCESSOR) +bitstream $(BITSTREAM)

run-isp-debug: hello
	$(ISP_COMMAND) -d -D -e +processor $(PROCESSOR) +bitstream $(BITSTREAM)

clean:
	rm -rf hello bsp isp-run-hello-*