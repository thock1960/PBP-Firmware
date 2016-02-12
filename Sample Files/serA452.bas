' PicBasic Pro program to demonstrate an interrupt-driven
' input buffer for hardware USART receive using Assembly
' language interrupt. 
' Pin definitions compatible with LAB-X1 and PIC18F452


' Defines for LCD
DEFINE  LCD_DREG        PORTD
DEFINE  LCD_DBIT        4
DEFINE  LCD_RSREG       PORTE
DEFINE  LCD_RSBIT       0
DEFINE  LCD_EREG        PORTE
DEFINE  LCD_EBIT        1

' Define interrupt handler
DEFINE INTHAND myint

' Configure internal registers
ADCON1 = 7				' Set PortA and E to digital operation
RCSTA = $90				' Enable USART receive
TXSTA = $24				' Set USART parameters
SPBRG = 25				' Set baud rate to 9600 (4MHz clock)

LED		VAR	PORTD.0		' Alias LED to PORTD.0
CREN	VAR RCSTA.4		' Alias CREN (Serial receive enable)

'Variables for saving state in interrupt handler
wsave	VAR	BYTE bankA system	' Saves W
ssave	VAR	BYTE bankA system	' Saves STATUS
fsave	VAR	WORD bankA system	' Saves FSR0

buffer_size	CON	64			' Sets size of ring buffer (max 127)
buffer	VAR	BYTE[buffer_size]	' Array variable for holding received characters
index_in	VAR	BYTE bankA	' Pointer - next empty location in buffer
index_out	VAR	BYTE bankA	' Pointer - location of oldest character in buffer
errflag	VAR	BYTE bankA 		' Error flag

bufchar	VAR	BYTE		' Stores the character retrieved from the buffer
col		VAR	BYTE		' Stores location on LCD for text wrapping
i		VAR	BYTE		' Loop counter


GoTo start	' Skip around interrupt handler


' Assembly language INTERRUPT handler
Asm
myint

; Save the state of critical registers
		movwf	wsave			; Save W
		swapf	STATUS, W		; Swap STATUS to W (swap avoids changing STATUS)
		clrf	STATUS			; Clear STATUS
		movwf	ssave			; Save swapped STATUS

; Save the FSR value because it gets changed below	
		movf	Low FSR0, W		; Move FSR0 lowbyte to W
		movwf	fsave			; Save FSR0 lowbyte
		movf	High FSR0, W	; Move FSR0 highbyte to W
		movwf	fsave+1			; Save FSR0 highbyte
		
; Check for hardware overrun error
		btfsc	RCSTA,OERR		; Check for usart overrun
		GoTo 	usart_err		; jump to assembly error routine

		
; Test for buffer overrun		
		incf	_index_in, W	; Increment index_in to W
		subwf	_index_out, W	; Subtract indexes to test for buffer overrun
		btfsc	STATUS,Z		; check for zero (index_in = index_out)
		GoTo	buffer_err		; jump to error routine if zero

; Increment the index_in pointer and reset it if it's outside the ring buffer
		incf	_index_in, F	; Increment index_in to index_in
		movf	_index_in, W	; Move new index_in to W
		sublw	_buffer_size-1	; Subtract index_in from buffer_size-1
		btfss	STATUS,C		; If index_in => buffer_size
		clrf	_index_in		; Clear index_in

; Set FSR0 with the location of the next empty location in buffer
		movlw	Low _buffer		; Move lowbyte of buffer[0] address to W
		movwf	FSR0L			; Move W to lowbyte of FSR0
		movlw	High _buffer	; Move highbyte of buffer[0] address to W
		movwf	FSR0H			; Move W to highbyte of FSR0

; Read and store the character from the USART		
		movf	_index_in, W	; W must hold the offset value for the next empty location
		movff	RCREG, PLUSW0	; Move the character in RCREG to address (FSR0+W)
		

; Restore FSR, PCLATH, STATUS and W registers
finished
		movf	fsave, W		; retrieve FSR0 lowbyte value
		movwf	Low FSR0		; Restore it to FSR0 lowbyte
		movf	fsave+1, W		; retrieve FSR0 highbyte value
		movwf	High FSR0		; Restore it to FSR0 highbyte
		swapf	ssave, W		; Retrieve the swapped STATUS value (swap to avoid changing STATUS)
		movwf	STATUS			; Restore it to STATUS
		swapf	wsave, F		; Swap the stored W value
		swapf	wsave, W		; Restore it to W (swap to avoid changing STATUS)
		retfie					; Return from the interrupt

; Error routines	
buffer_err						; Jump here on buffer error
		bsf		_errflag,1		; Set the buffer flag
usart_err						; Jump here on USART error
		bsf		_errflag,0		; Set the USART flag
		movf	RCREG, W		; Trash the received character
		GoTo	finished		; Restore state and return to program

EndAsm


start:

' Initialize variables
index_in = 0
index_out = 0
col = 1
errflag = 0

INTCON = %11000000		' Enable interrupts
PIE1.5 = 1				' Enable interrupt on USART

Low PORTE.2             ' LCD R/W line low (W)
Pause 100               ' Wait for LCD to start

LCDOut $fe,1			' Clear LCD


' Main program starts here - blink an LED at 1Hz

loop:   
	High LED        	' Turn on LED connected to PORTD.0
	Pause 500   		' Pause 500mS
	Low LED     		' Turn off LED connected to PORTD.0
	Pause 500			' Pause 500mS

display:				' dump the buffer to the LCD
	IF errflag Then error	' Goto error routine if needed
	IF index_in = index_out Then loop	' loop if nothing in buffer
		
	GoSub getbuf		' Get a character from buffer	
	LCDOut $FE,($7F+col),bufchar,$FE,$C0,DEC index_out," : ",DEC index_in 		' Send the character to LCD
	
	
	col = col + 1		' Increment LCD location
	IF col > 20 Then	' Check for end of line
		col = 1			' Reset LCD location
		LCDOut $fe,$c0,REP " "\20	' Clear any error on line-2 of LCD
		LCDOut $FE,2	' Tell LCD to return home
	EndIF

GoTo display			' Check for more characters in buffer


' Subroutines

' Get a character from the buffer
getbuf:					' Move the next character in buffer to bufchar
	intcon = 0			' Disable interrupts while reading buffer
	index_out = index_out + 1	' Increment index_out pointer (0 to 63)
	IF index_out => buffer_size Then index_out = 0	' Reset pointer if outside buffer
	bufchar = buffer[index_out]	' Read buffer location(index_out)
	INTCON = %11000000	' Enable interrupts
Return

' Display an error
error:					' Display error message
	INTCON = 0			' Disable interrupts while in the error routine
	IF errflag.1 Then	' Determine the error
		LCDOut $FE,$c0,"Buffer Overrun"	' Display buffer error on line-2
	Else
		LCDOut $FE,$c0,"USART Overrun"	' Display usart error on line_2
	EndIF
	
	LCDOut $fe,2		' Send the LCD cursor back to line-1 home
	For i = 2 TO col	' Loop for each column beyond 1
		LCDOut $fe,$14	' Put the cursor back where it was
	Next i
	
	errflag = 0			' Reset the error flag
	CREN = 0			' Disable continuous receive to clear hardware error
	CREN = 1			' Enable continuous receive
	INTCON = %11000000	' Enable interrupts

	GoTo display		' Carry on
	
End




