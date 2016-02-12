' PicBasic Pro program that demonstrates the use of the Timer1
' interrupt for a real-time clock.  Written for the LAB-X1
' experimenter board with an 18F452

' Define interrupt handler
DEFINE  INTHAND myint


wsave	VAR	BYTE bankA system	' Saves W
ssave	VAR	BYTE bankA system	' Saves STATUS

TICK	VAR	BYTE bankA	' make sure that the variables are in bank 0 if they are to be used in the interrupt handler

seconds VAR BYTE	' Elapsed seconds
minutes VAR WORD	' Elapsed minutes
	
minutes = 0			' Clear time
seconds = 0

T1CON = $01			' Turn on Timer1, prescaler = 1
INTCON 	= $C0		' Enable global interrupts, peripheral interrupts
PIE1 = $01			' Enable TMR1 overflow interrupt

 
GoTo main	' jump over the interrupt handler and sub
 
' Assembly language interrupt handler
Asm
myint 

; Save the state of critical registers
	movwf	wsave			; Save W
	swapf	STATUS, W		; Swap STATUS to W (swap avoids changing STATUS)
	clrf	STATUS			; Clear STATUS
	movwf	ssave			; Save swapped STATUS


; Set the high register of Timer1 to cause an interrupt every
; 16384 counts (65536-16384=49152 or $C000). At 4MHz, prescale
; set to 1, this equates to a tick every 16384uS.  This works
; out to about 61 ticks per second, with a slight error.  The
; error could be reduced substantially by setting the TMR1L
; register and playing with different values for the prescaler
; and the ticks per second.

	movlw	0C0h			; Prepare to set TMR1 high register
	movwf	TMR1H			; Set TMR1H to C0h
	incf	_TICK,F			; INCREMENT TICK COUNT
  	bcf     PIR1, 0			; Clear interrupt flag
	

	swapf	ssave, W		; Retrieve the swapped STATUS value (swap to avoid changing STATUS)
	movwf	STATUS			; Restore it to STATUS
	swapf	wsave, F		; Swap the stored W value
	swapf	wsave, W		; Restore it to W (swap to avoid changing STATUS)
     retfie   			; Return from interrupt
EndAsm

' PicBasic subroutine to update the minutes and seconds variables
get_time:
 	' Update the time when needed. The TICK variable will
 	' overflow if you don't update within 4 seconds.  This could
 	' be done in the interrupt handler, but it's easier to do
 	' it in PicBasic, and you usually want the interrupt handler
 	' to be as short and fast as possible.
 	
	PIE1 = 0				' Mask the interrupt while we're messing with TICK
	seconds = seconds + (tick/61)	' Add the accumulated seconds
	tick = tick // 61		' Retain the left-over ticks
	PIE1 = $01				' Interrupt on again
	minutes = minutes + (seconds / 60)	' Add the accumulated minutes
	seconds = seconds // 60	' Retain the left-over seconds
Return						' Return to the main program


 
main	
' **************************************************************
' Begin program code here.  The minutes and seconds variables can
' be used in your code.  The time will be updated when you call the
' get_time routine. Disable interrupts while executing timing-critical
' commands, like serial communications.

DEFINE  LCD_DREG        PORTD
DEFINE  LCD_DBIT        4
DEFINE  LCD_RSREG       PORTE
DEFINE  LCD_RSBIT       0
DEFINE  LCD_EREG        PORTE
DEFINE  LCD_EBIT        1


ADCON1 = 7			' Set PORTA and PORTE for digital operation
	
Low PORTE.2			' Enable the LCD
	
Pause 150			' Pause to allow LCD to initialize
LCDOut $fe,1		' Clear LCD

loops	VAR WORD
loops = 0


loop:
	
	loops = loops + 1
	LCDOut $fe,$C0,"Loops Counted: ", DEC5 loops
	

	GoSub get_time	' Update minutes and seconds
	LCDOut $fe, 2, "Time: ",DEC5 minutes, ":", DEC2 seconds ' Display the elapsed time


	GoTo loop 		' Repeat main loop
	
	End	



