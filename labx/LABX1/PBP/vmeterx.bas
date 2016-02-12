' PICBASIC PRO program to measure voltage (0-5VDC)
' and display on LCD with 2 decimal places
'
' This program uses the */ operator to scale the
' ADC result from 0-1023 to 0-500.  The */ performs
' a divide by 256 automatically, allowing math which
' would normally exceed the limit of a word variable.
'
' Connect analog input to channel-0 (RA0)

' Define LOADER_USED to allow use of the boot loader.
' This will not affect normal program operation.
Define	LOADER_USED	1

' Define LCD registers and bits
DEFINE  LCD_DREG        PORTD
DEFINE  LCD_DBIT        4
DEFINE  LCD_RSREG       PORTE
DEFINE  LCD_RSBIT       0
DEFINE  LCD_EREG        PORTE
DEFINE  LCD_EBIT        1

' Define ADCIN parameters
DEFINE  ADC_BITS        10     	' Set number of bits in result
DEFINE  ADC_CLOCK       3     	' Set clock source (3=rc)
DEFINE  ADC_SAMPLEUS    50    	' Set sampling time in uS

adval	Var	Word		' Create adval to store result


	TRISA = %11111111	' Set PORTA to all input
	ADCON1 = %10000010	' Set PORTA analog and right justify result
	Low PORTE.2		' LCD R/W line low (W)

	Pause 500       	' Wait .5 second

loop:	Adcin 0, adval		' Read channel 0 to adval (0-1023)

	adval = (adval */ 500)>>2	' Equates to: (adval * 500)/1024

	LCDOut $fe, 1   	' Clear LCD
	LCDOut "DC Volts= ",DEC (adval/100),".", DEC2 adval	' Display the decimal value  

	Pause 100       	' Wait .1 second

	Goto loop       	' Do it forever

	End
