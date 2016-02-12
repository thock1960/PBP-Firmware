' PicBasic Pro upper case serial filter.

        Include "modedefs.bas"	' Include serial modes

SO      var     PORTB.2         ' Define serial out pin
SI      var     PORTB.1         ' Define serial in pin

B0      var     byte

loop:   Serin SI,T2400,B0	' B0 = input character
        If (B0 < "a") or (B0 > "z") Then print  ' If lower case, convert to upper
	B0 = B0 - $20
print:  Serout SO,T2400,[B0]	' Send character
        Goto loop		' Forever

	End
