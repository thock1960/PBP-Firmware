' PicBasic Pro program to send and receive from the hardware serial port
' LEDs count characters and flash error if none received for 10 seconds

Define hser_baud    4800
char	var	byte		' Storage for serial character
cnt	    var	byte		' Storage for character counter


	TRISB = %11001111	' Set PORTB.4,5 to outputs
	PORTB = 0		' Turn off LEDs
	cnt = 0			' Zero character counter

loop:   Hserin 10000,allon,[char]	' Get a char from serial port
        SEROUT2 PORTB.3, 16572 ,[char]
        'Hserout [char]		' Send char out serial port

	cnt = cnt + 1		' Increment character count
	PORTB = cnt << 4	' Send count to LED

	Goto loop		' Do it all over again

allon:	PORTB = %00110000	' Error - no character received
	Pause 500		' Blink all LEDs
	PORTB = 0
	Pause 500
	Goto allon

        End

