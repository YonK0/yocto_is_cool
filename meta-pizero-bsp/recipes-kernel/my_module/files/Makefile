obj-m += hello.o

all: 
	make -C $(KERNEL_SRC) M=$(PWD) modules
clean:
	make -C $(KERNEL_SRC) M=$(PWD) clean
	
modules_install:
	make -C $(KERNEL_SRC) M=$(PWD) INSTALL_MOD_PATH=$(DESTDIR) modules_install