----------------------------------

Author: github.com/ChefYeshpal
Date of creation: 25 july 2024

----------------------------------

Purpose:
	to create a graph that logs your battery percentage per time in order to find out the efficiency of your battery and/or your laptop. Made for machines that do not have a software to map battery drainage times

currently this is only tested upon ubuntu systems and works only with machines that run on battery power [eg; laptop]

----------------------------------


To do:
	1. make shell logplotter functional, not working currently [27 july 2024]
	2. make it so that when machine is discharging the colour of the line is yellow and when charging it is green, when the battery level is at critical low levels then the colour od the line should be red 
	3. try to get it to show the data within the teminal itself without opening any other windows [like with matplotlib]
	4. try to make it so that it also logs down which program used most battery [optional due to security risks]

----------------------------------

You may need to install the following packages

	pip3 install matplotlib pandas

	sudo apt-get install gnuplot


Make the .sh files executable

	chmod +x batterylogger.sh

	chmod +x batterylogplot.sh

Then to run the .sh file you can

	nohup ./batterylogger.sh

Then press ctrl+z [to stop the process, cache it to background]

	bg
or
	disown

You can use disown to make the program run even if you close your working shell

When you want to see the data, you can run

	python3 batterylogplot.py
or
	./batterylogplot.sh


Note: the 'batterylogplot.sh' (shell file) has bugs that need to be fixed

----------------------------------
basic info:
	1. this program takes reading in increments of 60 seconds, in order to change that you must go to the 'batterylogger.sh' file and change the following line [on line 20, as of 27 july 2024]
	
	sleep 60 

you can change it to any time you prefer and it will take readins in that timing increments, remember to input the number in seconds
	2. when you run upower -i $(upower -e | grep BAT) on you machine it will probably show something like this - 

	  native-path:          XXXX
 	 vendor:               XXX
 	 model:                X00X0XX0
 	 serial:               00000
 	 power supply:         yes/no
 	 updated:              TIME
 	 has history:          yes/no
 	 has statistics:       yes/no
 	 battery
 	   present:             yes/no
 	   rechargeable:        yes/no
 	   state:               charging/discharging
 	   warning-level:       none/find out
 	   energy:              00.00 Wh
 	   energy-empty:        0 Wh
 	   energy-full:         00.00 Wh
 	   energy-full-design:  00 Wh
 	   energy-rate:         00.000 W
 	   voltage:             0.000 V
 	   charge-cycles:       N/A
 	   time to full:        00.0 minutes
 	   percentage:          00%
 	   capacity:            00.0000%
 	   technology:          BATT-TYPE
 	   icon-name:          'ICON-NAME'
 	 History (charge):
 	   00000000	PERCENTAGE	STATUS
 	 History (rate):
 	   00000000	PERCENTAGE	STATUS
	
The things here are
	1. native-path, system specific path for the power source
	2. power supply, indicates wether or not the powersupply is a battery or not
	3. has history, yes/no, indicates is the device has data being tracked by upower or not
	4. has statistics, yes/no, indicates if statistical info is being tracked for this device
	5. line-power, provides info specific to the line power device [like adapters]
	6. warning-level, indicates current warning level
	7. online, yes/no, indicates wether the power source is connected or not
	8. icon-name, used by system to represent powersource in GUI

----------------------------------

I hope this program helps you in any way possible
