' PICBASIC PRO program to blink an LED connected to GPIO.0 about once a second

LED	Con	0	' Alias GPIO.0 to LED


	ANSEL = 0	' Set all digital
	CMCON0 = 7	' Analog comparators off


loop:	Low LED		' Turn on LED connected to GPIO.0
	Pause 500	' Delay for .5 seconds

	High LED	' Turn off LED connected to GPIO.0
	Pause 500	' Delay for .5 seconds

	Goto loop	' Go back to loop and blink LED forever

	End
