----------------------------------

Author: github.com/ChefYeshpal
Date: 25 july 2024

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

----------------------------------
basic info:
	1. this program takes reading in increments of 60 seconds, in order to change that you must go to the 'batterylogger.sh' file and change the following line [on line 20, as of 27 july 2024]
	
	sleep 60 

you can change it to any time you prefer and it will take readins in that timing increments, remember to input the number in seconds

----------------------------------

I hope this program helps you in any way possible
