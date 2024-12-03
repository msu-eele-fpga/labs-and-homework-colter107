# Lab 11: Linux Device Drivers

## Overview
This Lab covered establishing and using a Linux device driver to control our led_patterns component. This involved creating a Platform device driver, modifying the device tree to add the LED_patterns device, setting up a state container for the device, and adding a miscdevice to the container in order to use the character driver API. From this point, device attributes were created and exported to sysfs, where they can be modifed by echoing to the attributes from the command line. Finally, bash scripts were created to modify these attributes automatically.

## Deliverables
### Questions 
>  What is the purpose of the platform bus?

The platform bus is used to connect to hardware devices that aren't discoverable. Because our led-patterns device doesn't connect over USB/PCIe, the platform bus must be used to let the OS know about our device.

> Why is the device driver’s compatible property important?

The compatible property is important because it tells the device driver what devices it can be bound to. In our case, our led-patterns node on the device tree and the led-patterns driver needed maching compatible properties so they could be bound together.

> What is the probe function’s purpose?

The probe function is called when a device is found by the driver, and typically runs all of the functions that set up and configure the device. In the case of the LED_Patterns component, it allocates memory for the kernel to store the state container, remaps the addresses of the device to virtual addresses the kernel can use, and attatches the state container to the device. It also initializes, registers, and attatches the misc device. Finally, it turns on all LEDs and prints to dmesg that the device was added.

> How does your driver know what memory addresses are associated with your device?

In the probe function, the code requests the device's memory region, and remaps it to virtual addresses in the kernel's virtual address space. This means that the kernel now has virtual addresses it can modify which will be reflected to the device's physical memory.

> What are the two ways we can write to our device’s registers? In other words, what subsystems do
we use to write to our registers?

We use the misc subsystem under the character driver and sysfs/device attributes to write to the device's registers.
 
> What is the purpose of our struct led_patterns_dev state container?

The state container keeps track of what state our device is in. It stores things like the addresses of registers, the values of those registers, and anything else the device should track while it is running. It is created separately for each device (to allow multiple devices to run at once) and is passed to any function that needs to read or change the state of the device.

