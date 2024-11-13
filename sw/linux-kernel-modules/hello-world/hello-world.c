#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

static int __init hello_world(void){
    printk(KERN_INFO "Hello World :D\n");
    return 0;
}

static void __exit goodbye_world(void){
    printk("Goodbye Cruel World D:\n");
}

module_init(hello_world);
module_exit(goodbye_world);

MODULE_AUTHOR("Colter Girardot");

MODULE_LICENSE("Dual MIT/GPL");