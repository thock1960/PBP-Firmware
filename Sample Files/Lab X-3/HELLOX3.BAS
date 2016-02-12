' PicBasic Pro program to send "Hello World" on serial port

'Include "modedefs.bas"	' Mode definitions for Serout
 define osc 4

loop:   Serout2 PORTB.2,813,["Hello ",13,10]  ' Display "Hello", next line
        Pause 500	' Wait .5 second

        Serout2 PORTB.2,813,["World", 13,10,13,10]  ' Display "World", skip a line
        Pause 500	' Wait .5 second

        Goto loop	' Do it forever
        End
