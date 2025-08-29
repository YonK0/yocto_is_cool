#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("AEROO");
MODULE_DESCRIPTION("HELLO FROM AEROO");



static int  __init mymod_init(void)
{
    printk(KERN_INFO "hello , this is my second kernel module \n");
    return 0;
}

static void __exit mymod_exit(void)
{
    printk(KERN_INFO "bye bye  T_T \n");
}

module_init(mymod_init);
module_exit(mymod_exit);