PLATFORM=i386
KERN_PLATFORM=x86_64
ASSEMBLER=nasm
CC=gcc
LD=ld
OBJCOPY=objcopy
GDB=gdb
LLDB=lldb
KERN_TOOL_PREFIX=$(KERN_PLATFORM)-elf-
KERN_LOAD_ADDR=0x100000
KERN_VIRT_ADDR=0xFFFFFFFFC0000000
KERN_SECTOR_COUNT=wc -c < kernel.bin | awk '{printf("%.0f\n", ($$1+511)/512+1)}'
KERN_INCLUDE_DIR=kernel/include
KERN_HEADERS=		$(KERN_INCLUDE_DIR)/drivers/io/ports.h		\
					$(KERN_INCLUDE_DIR)/drivers/vga/vga.h		\
					$(KERN_INCLUDE_DIR)/inttypes.h				\
					$(KERN_INCLUDE_DIR)/mem/memcpy.h			\
					$(KERN_INCLUDE_DIR)/conf.h					\
					$(KERN_INCLUDE_DIR)/beemovie.h
KERN_SOURCE_DIR=kernel
KERN_C_SOURCES=		$(KERN_SOURCE_DIR)/drivers/io/ports.c		\
					$(KERN_SOURCE_DIR)/drivers/vga/vga.c		\
					$(KERN_SOURCE_DIR)/mem/memcpy.c				\
					$(KERN_SOURCE_DIR)/init.c
KERN_ARCH_DIR=kernel/arch/$(KERN_PLATFORM)
KERN_ASM_SOURCES= 	$(KERN_ARCH_DIR)/start.asm					\
					$(KERN_ARCH_DIR)/kernel_stub.asm
KERN_OBJECTS= 		${KERN_ASM_SOURCES:.asm=.o}					\
					${KERN_C_SOURCES:.c=.o}
OS_IMAGE_NAME=beeOS
CC_INCLUDE_DIRS=kernel/include/
CC_FLAGS=	-I$(CC_INCLUDE_DIRS) 	\
			-Wall				 	\
			-Wextra 				\
			-g 						\
			-O0 					\
			-mno-sse                \
			-mno-sse2               \
			-mno-sse3				\
			-mno-sse4				\
			-mno-mmx                \
			-mno-80387              \
			-mno-avx512f			\
			-mno-3dnow				\
			-mno-red-zone
ifeq ("$(KERN_PLATFORM)","x86_64")
	KERN_ASM_PLATFORM=elf64
	KERN_LD_PLATFORM=elf64-x86-64
	CC_FLAGS+= -m64 -mcmodel=kernel
else
	KERN_ASM_PLATFORM=elf32
	KERN_LD_PLATFORM=elf32-i386
	CC_FLAGS+= -m32 -mcmodel=kernel
endif
ifeq ("$(QEMU_REDIRECT_DEBUGCON)","1")
	QEMU_OPTIONS+= -debugcon $(QEMU_REDIRECT_DEBUGCON_DEVICE)
else ifeq ("$(QEMU_REDIRECT_SERIAL)","1")
	QEMU_OPTIONS+= -serial $(QEMU_REDIRECT_SERIAL_DEVICE)
endif
define write_kern_config_h
	echo "#ifndef _kern_conf_h\n#define _kern_conf_h" > $(KERN_INCLUDE_DIR)/conf.h
	echo "#define KERN_TARGET_$(KERN_PLATFORM)" >> $(KERN_INCLUDE_DIR)/conf.h
	echo "#define KERN_LOAD_ADDR $(KERN_LOAD_ADDR)" >> $(KERN_INCLUDE_DIR)/conf.h
	echo "#define KERN_VADDR $(KERN_VIRT_ADDR)" >> $(KERN_INCLUDE_DIR)/conf.h
	echo "#endif /* _kern_conf_h */" >> $(KERN_INCLUDE_DIR)/conf.h
endef
define write_kern_info_asm
	echo "%ifndef _boot_kern_info_asm" > bootloader/i386/kern_info.asm
	echo "%define _boot_kern_info_asm" >> bootloader/i386/kern_info.asm
	echo "%define KERN_LOAD_ADDR $(KERN_LOAD_ADDR)" >> bootloader/i386/kern_info.asm
	printf "%%define KERN_SECTOR_COUNT " >> bootloader/i386/kern_info.asm
	$(KERN_SECTOR_COUNT) >> bootloader/i386/kern_info.asm
	printf "%%define KERN_SEGMENT_ADDR " >> bootloader/i386/kern_info.asm
	printf $(KERN_LOAD_ADDR) | awk --non-decimal-data '{printf("0x%x\n", $$1/0x10)}' >> bootloader/i386/kern_info.asm
	printf "%%define KERN_SEGMENT_OFF " >> bootloader/i386/kern_info.asm
	printf $(KERN_LOAD_ADDR) | awk --non-decimal-data '{printf("%d", $$1 % 0x10)}' >> bootloader/i386/kern_info.asm
	echo "\n%define kernel_vaddr $(KERN_VIRT_ADDR)" >> bootloader/i386/kern_info.asm
	echo "%endif" >> bootloader/i386/kern_info.asm
endef
define preprocess_file
	gcc -E -x c $(2) $(1) | grep -v '^#' >$(3)
endef
define gen_kern_linker
	echo "#define KERN_LOAD_ADDR $(KERN_LOAD_ADDR)" > kernel_inc.gen
	echo "#define KERN_OFORMAT $(1)" >> kernel_inc.gen
	echo "#define KERN_VADDR $(KERN_VIRT_ADDR)" >> kernel_inc.gen
	$(call preprocess_file,kernel.ld.gen,,kernel.ld)
endef
define assemble_as_with_include
	$(ASSEMBLER) -I $(2) $(3) -f $(1) -o $(4)
endef
define assemble_as 
	$(ASSEMBLER) $(2) -f $(1) -o $(3)
endef
define link_with_prefix
	$(1)$(LD) -o $(2) $(3) -T$(5) $($(4))
endef
all: $(OS_IMAGE_NAME).bin
$(KERN_INCLUDE_DIR)/conf.h:
	$(call write_kern_config_h)
bootloader/i386/kern_info.asm:
	$(call write_kern_info_asm)
kernel/%.o: kernel/%.c ${KERN_HEADERS}
	$(KERN_TOOL_PREFIX)$(CC) $(CC_FLAGS) -ffreestanding -c $< -o $@ 
kernel/%.bin: kernel/%.real bootloader/i386/kern_info.asm
	$(call assemble_as,bin,$<,$@)
kernel/%.o: kernel/%.asm 
	$(call assemble_as,$(KERN_ASM_PLATFORM),$<,$@)
bootloader/%.o: %.asm
	$(call assemble_as_with_include,bin,bootloader/i386/,$<,$@)
boot.bin: bootloader/i386/boot.asm kernel.bin
	$(call write_kern_info_asm)
	$(call assemble_as_with_include,bin,bootloader/i386/,$<,$@)
kernel.bin: $(KERN_REAL_BINS) $(KERN_INCLUDE_DIR)/conf.h bootloader/i386/kern_info.asm ${KERN_OBJECTS}
	$(call gen_kern_linker,binary)
	$(call link_with_prefix,$(KERN_TOOL_PREFIX),$@,,KERN_OBJECTS,kernel.ld)
kernel.elf: ${KERN_OBJECTS}
	$(call gen_kern_linker,$(KERN_LD_PLATFORM))
	$(call link_with_prefix,$(KERN_TOOL_PREFIX),$@,,KERN_OBJECTS,kernel.ld)
$(OS_IMAGE_NAME).bin: boot.bin kernel.bin
	cat $^ > $@
clean:
	rm -rf *.bin *.o *.elf $(KERN_OBJECTS) bootloader/i386/*.o bootloader/i386/kern_info.asm kernel/arch/x86_64/*.o kernel.ld $(KERN_INCLUDE_DIR)/conf.h kernel_inc.gen $(KERN_REAL_BINS)
run: $(OS_IMAGE_NAME).bin
	qemu-system-x86_64 $(QEMU_OPTIONS) -hda $(OS_IMAGE_NAME).bin
crun: clean run
cbuild: clean $(OS_IMAGE_NAME).bin
build: $(OS_IMAGE_NAME).bin