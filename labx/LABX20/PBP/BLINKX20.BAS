' PICBASIC PRO program to blink an LED connected to PORTA.4 about once a second

LED	Var	PORTA.4	' Alias PORTA.4 to LED


loop:	High LED	' Turn on LED connected to PORTA.4
	Pause 500	' Delay for .5 seconds

	Low LED		' Turn off LED connected to PORTA.4
	Pause 500	' Delay for .5 seconds

	Goto loop	' Go back to loop and blink LED forever

	End
