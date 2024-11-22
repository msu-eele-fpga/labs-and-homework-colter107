# Lab 10: Device Trees

## Overview
The purpose of this lab was to practice creating and modifying device trees for the embedded linux running on the DE-10 nano's hps. sysfs was first used to modify the user-defined LED on the de-10 nano. Then, the kernel was recompiled with the heartbeat led trigger enabled. In addition, a custom device tree was used to set the user led to display the heartbeat indicator, as well as the correct color and function labels for the sysfs directory. 

### Questions 

> What is the purpose of a device tree?

A device tree is used to give linux information on all the devices connected, so that we don't need to manually initialize all of these devices. In example, there is no way to scan for connected devices over I2C. Instead, the device tree contains the information such as addresses and number of registers that are needed for external devices to function.
