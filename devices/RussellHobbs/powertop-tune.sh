#!/bin/bash

echo '1500' > '/proc/sys/vm/dirty_writeback_centisecs';
echo '1' > '/sys/module/snd_hda_intel/parameters/power_save';
echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.6/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:14.2/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.5/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:14.3/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:04.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:08.0/power/control';
