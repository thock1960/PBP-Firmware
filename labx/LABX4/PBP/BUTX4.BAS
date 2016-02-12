' PICBASIC PRO program to show button press on LED

@	device	mclr_off

LED	Con	0		' Alias GPIO.0 to LED
PB	Var	GPIO.3		' Alias GPIO.3 to push button


	ANSEL = 0		' Set all digital
	CMCON0 = 7		' Analog comparators off


loop:   ' Button press turns on LED (MCLRE must not be enabled)
	If PB = 0 Then		' If button pressed...
		Low LED		' Turn on LED
	Else
		High LED	' Turn off LED
	Endif

	Goto loop		' Do it forever

	End
