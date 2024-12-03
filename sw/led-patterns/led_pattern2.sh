#!/bin/bash
HPS_LED_CONTROL="/sys/devices/platform/ff200000.led_patterns/hps_led_control"
BASE_PERIOD="/sys/devices/platform/ff200000.led_patterns/base_period"
LED_REG="/sys/devices/platform/ff200000.led_patterns/led_reg"

# Enable software-control mode
echo 1 > $HPS_LED_CONTROL

led_val=0x0F;
new_base_period_val=0xF0;



for n in {1..20};
do
    echo $led_val > $LED_REG
    sleep 0.25
    # left shift led_val with wrap-around at 0xff
    led_val=$(((led_val << 1) % 0xff))
done

echo $new_base_period_val > $BASE_PERIOD
echo 0 > $HPS_LED_CONTROL