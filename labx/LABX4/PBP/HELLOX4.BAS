' PICBASIC PRO program to send "Hello World" on serial port (and LCD)

Include "modedefs.bas"	' Mode definitions for Serout

TX	Var	GPIO.1


	ANSEL = 0	' Set all digital
	CMCON0 = 7	' Analog comparators off


loop:   Serout TX, T2400, ["Hello", 10, 13]	' Display "Hello", next line
        Pause 500	' Wait .5 second

        Serout TX, T2400, ["World", 10, 13, 10, 13]	' Display "World", skip a line
        Pause 500	' Wait .5 second

        Goto loop	' Do it forever

        End
