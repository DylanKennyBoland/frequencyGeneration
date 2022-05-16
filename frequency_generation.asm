; Written for ADuC841 evaluation board, with UCD extras.
; Generates square waves on P3.6 depending on the switch values 
; at Port 2.
; Authors: Dylan Boland & Cuan De Burca
; Digital and Embedded Systems: Laboratory 2
; Include the ADuC841 SFR definitions
;
$NOMOD51
$INCLUDE (MOD841)
	
SOUND	EQU  	P3.6		; P3.6 will drive a transducer
LED		EQU		P3.4		; P3.4 is an LED

CSEG
		ORG		0000h		; set origin at start of code segment
		JMP		MAIN		; jump to start of main program
		
		ORG		002Bh		; timer 2 overflow interrupt address
		JMP		TF2ISR		; jump to interrupt service routine

		ORG		0060h		; set origin above interrupt addresses	
MAIN:	
; ------ Setup part - happens once only ----------------------------
; ====== Set switch for simulator ======
		MOV     T2CON, #84h ; using timer 2. Capture mode disabled.
		MOV     IE, #0A0h   ; enabling interrupts for timer 2.
		
; ------ Loop forever (in this example, doing nothing) -------------
LOOP:	CALL	LOAD		; load in relevant frequency into timer 2
		CPL		LED			; complement led
		CALL	DELAY		; call delay subroutine
		JMP		LOOP		; repeat - waiting for interrupt


LOAD:
		MOV		A,P2		        ; move value from port 2 to the accumulator
		ANL		A,#00000111b        ; AND the accumulator to disregard all but 3 least sig bits
FREQ1:	CJNE	A,#00000000b,FREQ2	; if the last 3 bits of the accumulator are not 000 - jump to the next check 		
		MOV     RCAP2H, #0E7h       ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #74h        ; loading in the lower Byte.
		MOV		P0, #11111110b	    ; setting LEDs on port 0 to one-hot code for frequency 1
		RET
		
FREQ2:	CJNE	A,#00000001b,FREQ3	; if the last 3 bits of the accumulator are not 001 - jump to the next check 		
		MOV     RCAP2H, #0EBh       ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #5Ch        ; loading in the lower Byte.
		MOV		P0, #11111101b	    ; setting LEDs on port 0 to one-hot code for frequency 2
		RET

FREQ3:	CJNE	A,#00000010b,FREQ4	; if the last 3 bits of the accumulator are not 010 - jump to the next check 		
		MOV     RCAP2H, #0EFh       ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #9Eh        ; loading in the lower Byte.
		MOV		P0, #11111011b	    ; setting LEDs on port 0 to one-hot code for frequency 3
		RET
		
FREQ4:	CJNE	A,#00000011b,FREQ5	; if the last 3 bits of the accumulator are not 011 - jump to the next check 		
		MOV     RCAP2H, #0F2h       ; loading in the upper Byte. Adding a leading 0 as "F" is not a digit.
		MOV     RCAP2L, #39h        ; loading in the lower Byte.
		MOV		P0, #11110111b	    ; setting LEDs on port 0 to one-hot code for frequency 4
		RET
		
FREQ5:	CJNE	A,#00000100b,FREQ6	; if the last 3 bits of the accumulator are not 100 - jump to the next check 		
		MOV     RCAP2H, #0F5h       ; loading in the upper Byte. Adding a leading 0 as "F" is not a digit.
		MOV     RCAP2L, #11h        ; loading in the lower Byte.
		MOV		P0, #11101111b	    ; setting LEDs on port 0 to one-hot code for frequency 5
		RET
	
FREQ6:	CJNE	A,#00000101b,FREQ7	; if the last 3 bits of the accumulator are not 101 - jump to the next check 		
		MOV     RCAP2H, #0F6h       ; loading in the upper Byte. Adding a leading 0 as "F" is not a digit.
		MOV     RCAP2L, #0CEh       ; loading in the lower Byte.
		MOV		P0, #11011111b	    ; setting LEDs on port 0 to one-hot code for frequency 6
		RET
		
FREQ7:	CJNE	A,#00000110b,FREQ8	; if the last 3 bits of the accumulator are not 110 - jump to the next check 		
		MOV     RCAP2H, #0F8h       ; loading in the upper Byte. Adding a leading 0 as "F" is not a digit.
		MOV     RCAP2L, #45h        ; loading in the lower Byte.
		MOV		P0, #10111111b	    ; setting LEDs on port 0 to one-hot code for frequency 7
		RET
		
FREQ8:	CJNE	A,#00000111b,NONE	; if the last 3 bits of the accumulator are not 111 - jump to the next check 		
		MOV     RCAP2H, #0F9h       ; loading in the upper Byte. Adding a leading 0 as "F" is not a digit.
		MOV     RCAP2L, #0DDh       ; loading in the lower Byte.
		MOV		P0, #01111111b	    ; setting LEDs on port 0 to one-hot code for frequency 8
		RET

NONE:	RET

DELAY:	; delay for time A x 10 ms. A is not changed. 
	   	MOV		R5, #020		    ; outer loop repeats 20 times         
DLY2:	MOV 	R6,	#144            ; load 144 into R6
DLY1:	MOV		R7, #255		    ; load 255 into R7     
		DJNZ	R7, $		        ; inner loop 255
		DJNZ	R6, DLY1
		DJNZ	R5, DLY2
		RET				            
		
; ------ Interrupt service routine ---------------------------------	
TF2ISR:	; timer 2 overflow interrupt service routine
		CPL		SOUND ; change state of output pin
		CLR     TF2 ; clearing the overflow bit as this is not automatically done for timer 2.
		RETI ; return from interrupt
; ------------------------------------------------------------------	
		
END