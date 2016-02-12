'  LCD clock program using On Interrupt
'  Uses TMR0 and prescaler.  Watchdog Timer should be
'  set to off at program time and Nap and Sleep should not be used.
'  Buttons may be used to set hours and minutes

'  18F452, PBP 2.43, LAB-X1 Experimenter Board

DEFINE  LCD_DREG        PORTD   ' Define LCD connections
DEFINE  LCD_DBIT        4
DEFINE  LCD_RSREG       PORTE
DEFINE  LCD_RSBIT       0
DEFINE  LCD_EREG        PORTE
DEFINE  LCD_EBIT        1

hour    VAR     BYTE    ' Define hour variable
dhour   VAR     BYTE    ' Define display hour variable
minute  VAR     BYTE    ' Define minute variable
second  VAR     BYTE    ' Define second variable
ticks   VAR     BYTE    ' Define pieces of seconds variable
update  VAR     BYTE    ' Define variable to indicate update of LCD
i       VAR     BYTE    ' Debounce loop variable

        ADCON1 = 7      ' PORTA and E digital
        Low PORTE.2     ' LCD R/W low = write
        Pause 100       ' Wait for LCD to startup

        hour = 0        ' Set initial time to 00:00:00
        minute = 0
        second = 0
        ticks = 0

        update = 1      ' Force first display

' Set TMR0 to interrupt every 16.384 milliseconds
		INTCON2.7 = 0			' Enable internal pullups on PORTB
		T0CON = %11010101		' Set TMR0 on, prescaler 1:64
		
        INTCON = $a0            ' Enable TMR0 interrupts
		
        ON INTERRUPT GoTo tickint


' Main program loop - in this case, it only updates the LCD with the time
mainloop:
        PORTB = 0       ' PORTB lines low to read buttons
        TRISB = $f0     ' Enable all buttons

        ' Check any button pressed to set time
        IF PORTB.7 = 0 Then decmin
        IF PORTB.6 = 0 Then incmin      ' Last 2 buttons set minute
        IF PORTB.5 = 0 Then dechr
        IF PORTB.4 = 0 Then inchr       ' First 2 buttons set hour

        ' Check for time to update screen
chkup:  IF update = 1 Then
                LCDOut $fe, 1   ' Clear screen

                ' Display time as hh:mm:ss
                dhour = hour    ' Change hour 0 to 12
                IF (hour // 12) = 0 Then
                        dhour = dhour + 12
                EndIF

                ' Check for AM or PM
                IF hour < 12 Then
                        LCDOut DEC2 dhour, ":", DEC2 minute, ":", DEC2 second, " AM"
                Else
                        LCDOut DEC2 (dhour - 12), ":", DEC2 minute, ":", DEC2 second, " PM"
                EndIF

                update = 0      ' Screen updated
        EndIF

        GoTo mainloop   ' Do it all forever


' Increment minutes
incmin: minute = minute + 1
        IF minute >= 60 Then
                minute = 0
        EndIF
        GoTo debounce

' Increment hours
inchr:  hour = hour + 1
        IF hour >= 24 Then
                hour = 0
        EndIF
        GoTo debounce

' Decrement minutes
decmin: minute = minute - 1
        IF minute >= 60 Then
                minute = 59
        EndIF
        GoTo debounce

' Decrement hours
dechr:  hour = hour - 1
        IF hour >= 24 Then
                hour = 23
        EndIF

' Debounce and delay for 250ms
debounce: For i = 1 TO 25
        Pause 10        ' 10ms at a time so no interrupts are lost
        Next i

        update = 1      ' Set to update screen

        GoTo chkup


' Interrupt routine to handle each timer tick
        Disable         ' Disable interrupts during interrupt handler
tickint: ticks = ticks + 1      ' Count pieces of seconds
        IF ticks < 61 Then tiexit       ' 61 ticks per second (16.384ms per tick)

' One second elasped - update time
        ticks = 0
        second = second + 1
        IF second >= 60 Then
                second = 0
                minute = minute + 1
                IF minute >= 60 Then
                        minute = 0
                        hour = hour + 1
                        IF hour >= 24 Then
                                hour = 0
                        EndIF
                EndIF
        EndIF

        update = 1      ' Set to update LCD

tiexit: INTCON.2 = 0    ' Reset timer interrupt flag
        Resume

        End
