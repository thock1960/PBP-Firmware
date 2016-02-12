' PicBasic Pro program to blink 3 LEDS in sequence

' Define LOADER_USED to allow use of the boot loader.
' This will not affect normal program operation.
'Define	LOADER_USED	1
define OSC 20

i       var     byte		' Define loop variable

LEDS    var     PORTB		' Alias PORTB to LEDS


	TRISB = %00000000       ' Set PORTB to all output

loop:   LEDS = 1		' First LED on
        Pause 500		' Delay for .5 seconds

        For i = 1 To 2          ' Go through For..Next loop 2 times
                LEDS = LEDS << 1        ' Shift on LED one to left
                Pause 500       ' Delay for .5 seconds
        Next i

        Goto loop		' Go back to loop and blink LED forever
        End

