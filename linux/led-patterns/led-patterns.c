#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/io.h>
#include <linux/mutex.h>
#include <linux/miscdevice.h>
#include <linux/types.h>
#include <linux/fs.h>
#include <linux/kstrtox.h>


#define HPS_LED_CONTROL_OFFSET 0x0
#define BASE_PERIOD_OFFSET 0x4
#define LED_REG_OFFSET 0x8
#define SPAN 0x10


/**
 * struct led_patterns_dev - Private LED patterns device struct.
 * @base_addr: pointer to component's base address
 * @hps_led_control: Address of hps_led_control register
 * @base_period: Address of base_period register
 * @led_reg: Address of LED register
 * 
 * created for each led patterns component
 */
struct led_patterns_dev {
    void __iomem *base_addr;
    void __iomem *hps_led_control;
    void __iomem *base_period;
    void __iomem *led_reg;
    struct miscdevice miscdev;
    struct mutex lock;
};

/**
 * led_reg_show() - Return led_reg value to user-space via sysfs.
 * @dev: Device structure for led_patterns component.
 *       this device struct is embedded in the led_patterns's
 *         device sturct
 * @attr: unused
 * @buf: Buffer that gets reterned to user space
 * 
 * Return: number of bytes read
 */
static ssize_t led_reg_show(struct device *dev,
    struct device_attribute *attr, char *buf)
{
    u8 led_reg;
    struct led_patterns_dev *priv = dev_get_drvdata(dev);

    led_reg = ioread32(priv->led_reg);

    return scnprintf(buf, PAGE_SIZE, "%u\n", led_reg);
}

/**
 * led_reg_store() - Store for the led_reg value.
 *  @dev: Device structure for led_patterns component. This 
 *        device struct is embedded in the led_patterns'
 *        platform device struct.
 *  @attr: unused
 *  @buf: Buffer that contains the led_reg balue being written
 *  @size:  The number of bytes stored
 * 
 *  Return: number of bytes stored
 */ 
static ssize_t led_reg_store(struct device *dev,
    struct device_attribute *attr, const char *buf, size_t size)
{
    u8 led_reg;
    int ret;
    struct led_patterns_dev *priv = dev_get_drvdata(dev);

    //Parse string we recieved as a u8
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtou8(buf, 0, &led_reg);
    if (ret<0) {
        return ret;
    }

    iowrite32(led_reg, priv->led_reg);

    //Write was successful, so return number of bytes written
    return size;
}   

/**
 * hps_led_control_show() - Return hps_led_control value to user-space via sysfs.
 * @dev: Device structure for led_patterns component.
 *       this device struct is embedded in the led_patterns's
 *         device sturct
 * @attr: unused
 * @buf: Buffer that gets reterned to user space
 * 
 * Return: number of bytes read
 */
static ssize_t hps_led_control_show(struct device *dev,
    struct device_attribute *attr, char *buf)
{
    bool hps_control;

    struct led_patterns_dev *priv = dev_get_drvdata(dev);

    hps_control = ioread32(priv->hps_led_control);

    return scnprintf(buf, PAGE_SIZE, "%u\n", hps_control);
}

/**
 * hps_led_control_store() - Store for the led_reg value.
 *  @dev: Device structure for led_patterns component. This 
 *        device struct is embedded in the led_patterns'
 *        platform device struct.
 *  @attr: unused
 *  @buf: Buffer that contains the led_reg balue being written
 *  @size:  The number of bytes stored
 * 
 *  Return: number of bytes stored
 */ 
static ssize_t hps_led_control_store(struct device *dev,
    struct device_attribute *attr, const char *buf, size_t size)
{
    u8 hps_control;
    int ret;
    struct led_patterns_dev *priv = dev_get_drvdata(dev);

    //Parse string we recieved as a u8
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtou8(buf, 0, &hps_control);
    if (ret<0) {
        return ret;
    }

    iowrite32(hps_control, priv->hps_led_control);

    //Write was successful, so return number of bytes written
    return size;
}

/**
 * base_period_show() - Return base_period value to user-space via sysfs.
 * @dev: Device structure for led_patterns component.
 *       this device struct is embedded in the led_patterns's
 *         device sturct
 * @attr: unused
 * @buf: Buffer that gets reterned to user space
 * 
 * Return: number of bytes read
 */
static ssize_t base_period_show(struct device *dev,
    struct device_attribute *attr, char *buf)
{
    u8 base_period;

    struct led_patterns_dev *priv = dev_get_drvdata(dev);

    base_period = ioread32(priv->base_period);

    return scnprintf(buf, PAGE_SIZE, "%u\n", base_period);
}

/**
 * base_period_store() - Store for the led_reg value.
 *  @dev: Device structure for led_patterns component. This 
 *        device struct is embedded in the led_patterns'
 *        platform device struct.
 *  @attr: unused
 *  @buf: Buffer that contains the led_reg balue being written
 *  @size:  The number of bytes stored
 * 
 *  Return: number of bytes stored
 */ 
static ssize_t base_period_store(struct device *dev,
    struct device_attribute *attr, const char *buf, size_t size)
{
    u8 base_period;
    int ret;
    struct led_patterns_dev *priv = dev_get_drvdata(dev);

    //Parse string we recieved as a u8
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtou8(buf, 0, &base_period);
    if (ret<0) {
        return ret;
    }

    iowrite32(base_period, priv->base_period);

    //Write was successful, so return number of bytes written
    return size;
}

// Define sysfs attributes
static DEVICE_ATTR_RW(hps_led_control);
static DEVICE_ATTR_RW(base_period);
static DEVICE_ATTR_RW(led_reg);

//Crate an attribute group to export attributes
static struct attribute *led_patterns_attrs[] = {
    &dev_attr_hps_led_control.attr,
    &dev_attr_base_period.attr,
    &dev_attr_led_reg.attr,
    NULL,
};
ATTRIBUTE_GROUPS(led_patterns);



/**
 * led_patterns_read() - Read method for led_patterns char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value into.
 * @count: number of bytes being requested.
 * @offset: Byte offset in the file being read from.
 * 
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number.
 * On error, negative error value is returned. 
 */ 
static ssize_t led_patterns_read(struct file *file, char __user *buf, size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    /*
     * Get device's private data from the file struct's private_data field.
     * The private_data field is equal to the miscdev field in the
     * led_patterns_dev struct. container_of returns the 
     * led_patterns_dev struct that contains the miscdev in private_data.
     */
    struct led_patterns_dev *priv = container_of(file->private_data, struct led_patterns_dev, miscdev);

    // Check file offset to make sure we are reading from a valid location
    if (*offset < 0) {
        // Can't read from negative file position
        return -EINVAL;
    }
    if (*offset >= SPAN) {
        // Can't read from position past the end of our device.
        return 0;
    }
    if ((*offset % 0x4) != 0) {
        // Can't read from unaligned address
        pr_warn("led_patterns_read: unaligned access\n");
        return -EFAULT;
    }

    val = ioread32(priv->base_addr + *offset);

    //Copy value to userspace.
    ret = copy_to_user(buf, &val, sizeof(val));
    if(ret == sizeof(val)) {
        pr_warn("led_patterns_read: nothing copied\n");
        return -EFAULT;
    }

    //Increment the file offset by the number of bytes read
    *offset = *offset + sizeof(val);

    return sizeof(val);
}


/**
 * led_patterns_write() - Write method for led_patterns char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value from.
 * @count: number of bytes being requested.
 * @offset: Byte offset in the file being written to.
 * 
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number.
 * On error, negative error value is returned. 
 */ 
static ssize_t led_patterns_write(struct file *file, const char __user *buf, size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    /*
     * Get device's private data from the file struct's private_data field.
     * The private_data field is equal to the miscdev field in the
     * led_patterns_dev struct. container_of returns the 
     * led_patterns_dev struct that contains the miscdev in private_data.
     */
    struct led_patterns_dev *priv = container_of(file->private_data, struct led_patterns_dev, miscdev);

    // Check file offset to make sure we are reading from a valid location
    if (*offset < 0) {
        // Can't read from negative file position
        return -EINVAL;
    }
    if (*offset >= SPAN) {
        // Can't read from position past the end of our device.
        return 0;
    }
    if ((*offset % 0x4) != 0) {
        // Can't read from unaligned address
        pr_warn("led_patterns_read: unaligned access\n");
        return -EFAULT;
    }

    mutex_lock(&priv->lock);

    //Get value from userspace
    ret = copy_from_user(&val, buf, sizeof(val));
    if (ret != sizeof(val)) {
        iowrite32(val, priv -> base_addr + *offset);

        //Increment the file offset by the number of bytes written
        *offset = *offset + sizeof(val);

        // Return the number of bytes written
        ret = sizeof(val);
    }
    else {
        pr_warn("led_patterns_write: nothing copied from user space\n");
        ret = -EFAULT;
    }

    mutex_unlock(&priv->lock);
    return ret;
}


/**
 * led_patterns_fops - File operations supported by the 
 *                          led_patterns driver
 * @owner: The led_patterns driver owns the file operations.
 *         Ensures the driver can't be removed while character
 *         device is in use.
 * @read: Read function
 * @write: Write function
 * @llseek: We use the kernel's default_llseek() function; allows
 *          users to change what position they are reading/writing.
 */
static const struct file_operations led_patterns_fops = {
    .owner = THIS_MODULE,
    .read = led_patterns_read,
    .write = led_patterns_write,
    .llseek = default_llseek,
};

/**
 * led_patterns_probe() - When match found, initialize
 * @pdev: platform device associated with led patterns device
 *        automatically crated by the driver core from 
 *        led patterns device tree node
 */

static int led_patterns_probe(struct platform_device *pdev)
{
    struct led_patterns_dev *priv;
    size_t ret;

    /*
     * Allocate kernel memory for led patterns device, set it to 0
     * GFP_KERNEL indicates normal kernel RAM.
     * Automatically freed when the device is removed
     */
    priv = devm_kzalloc(&pdev->dev, sizeof(struct led_patterns_dev), GFP_KERNEL);
    if(!priv) {
        pr_err("Failed to allocate memory\n");
        return -ENOMEM;
    }

    // Initialize misc device parameters
    priv->miscdev.minor = MISC_DYNAMIC_MINOR;
    priv->miscdev.name = "led_patterns";
    priv->miscdev.fops = &led_patterns_fops;
    priv->miscdev.parent = &pdev->dev;

    //Register misc device; creates a char dev at /dev/led_patterns
    ret = misc_register(&priv->miscdev);
    if (ret) {
        pr_err("Failed to register misc device");
        return ret;
    }

    /*
     * Attach the led patterns's private data to the platform device's struct.
     * This lets us access our state container in other functions
     */
    platform_set_drvdata(pdev, priv);

    /*
     * Request and remap device's memory region. Request region to 
     * make sure nothing else can use that memory. The memory is 
     * remapped into kernel's virtual address space, since there's
     * no access to physical memory locations.
     */
    priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(priv->base_addr)) {
        pr_err("Failed to request/remap platform device resource\n");
        return PTR_ERR(priv->base_addr);
    }

    //Set memory addresses for each register
    priv->hps_led_control = priv->base_addr + HPS_LED_CONTROL_OFFSET;
    priv->base_period = priv->base_addr + BASE_PERIOD_OFFSET;
    priv->led_reg = priv->base_addr + LED_REG_OFFSET;

    //Enable software control mode, turn all LEDs on (for fun)
    iowrite32(1, priv->hps_led_control);
    iowrite32(0xff, priv->led_reg);

    /* Attach the led patterns's private data to the platform device's struct.
     * This lets us access our state container in other functions
     */
    platform_set_drvdata(pdev, priv);

    pr_info("led_patterns_probe successful\n");

    return 0;
}

/**
 * led_patterns_remove() - Remove led patterns device.
 * @pdev: Platform device structure associated with led patterns device
 * 
 * Called when device or driver is removed
 */
static int led_patterns_remove(struct platform_device *pdev)
{
    //Get the led paterns's private data from the platform device.
    struct led_patterns_dev *priv = platform_get_drvdata(pdev);

    //Disable software-control mode (for fun)
    iowrite32(0, priv->hps_led_control);

    //Deregister misc device and remove /dev/led_patterns file
    misc_deregister(&priv->miscdev);

    pr_info("led_patterns_remove successful\n");

    return 0;
}

/*
 * Define compatible property to match devices to this driver,
 * then add device ID structure to kernel's table. For a device
 * to be matched, its device tree node must use this compatible
 * string.
 */
static const struct of_device_id led_patterns_of_match[] = {
    { .compatible = "girardot,led_patterns", },
    { }
};

/** 
 * struct led_patterns_driver - Platform driver struct for the led-patterns driver
 * @probe: Function called when device found
 * @remove: Function called when device removed
 * @driver.owner: Module that owns the driver
 * @driver.name: Name of driver
 * @driver.of_match_table: Device tree match table
 */
static struct platform_driver led_patterns_driver = {
    .probe = led_patterns_probe,
    .remove = led_patterns_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name = "led_patterns",
        .of_match_table = led_patterns_of_match,
        .dev_groups = led_patterns_groups,
    },
};

// NOTE: macro automatically handles init/exit
module_platform_driver(led_patterns_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Colter Girardot");
MODULE_DESCRIPTION("led_patterns driver");
MODULE_DEVICE_TABLE(of, led_patterns_of_match);