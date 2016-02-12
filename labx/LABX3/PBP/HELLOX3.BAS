' PICBASIC PRO program to send "Hello World" on serial port

Include	"modedefs.bas"		' Mode definitions for Serout


loop:	Serout PORTB.2, T2400, ["Hello", 10, 13]	' Display "Hello", next line
	Pause 500		' Wait .5 second

	Serout PORTB.2, T2400, ["World", 10, 13, 10, 13]	' Display "World", skip a line
	Pause 500		' Wait .5 second

	Goto loop		' Do it forever

	End
