' PicBasic Pro program to blink an LED connected to PORTB.4 about once a second

LED     var     PORTB.4 ' Alias PORTB.4 to LED

loop:   High LED        ' Turn on LED connected to PORTB.4
        Pause 500	' Delay for .5 seconds

        Low LED         ' Turn off LED connected to PORTB.4
        Pause 500	' Delay for .5 seconds

        Goto loop	' Go back to loop and blink LED forever

        End
