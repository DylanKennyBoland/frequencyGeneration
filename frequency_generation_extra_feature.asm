; Authors: Dylan Boland and Cuan De Burca (5th Year Students)
; Includes the ADuC841 SFR definitions
; Digital and Embedded Systems
; Laboratory 2

; NOTE:
; This file contains some extra code in sections in order to facilitate
; the testing of the INT0 pushbutton in the debugger. When loading onto the
; hardware some sections should be commented out or removed completely.
; Such section have comments beside them saying: "USED FOR SIMULATING IN DEBUGGING"

$NOMOD51
$INCLUDE (MOD841)
	
SOUND	EQU  	P3.6		; P3.6 will drive a transducer
LED		EQU		P3.4		; P3.4 is an LED

CSEG
		ORG		0000h		; set origin at start of code segment
		JMP		MAIN		; jump to start of main program
		
		ORG     0003H       ; external interrupt 0 address...
		JMP     IE0ISR 
		
		ORG		002Bh		; timer 2 overflow interrupt address
		JMP		TF2ISR		; jump to interrupt service routine

		ORG		0060h		; set origin above interrupt addresses	
MAIN:	
; ------ Setup part - happens once only as we only need to configure timer 2 once at the start ----------------------------
		MOV     T2CON, #84h ; using timer 2. Capture mode disabled
		MOV     IE, #0A1h ; the lower nibble is a "1" as we want to enable external interrupts...
		SETB    IE0 ; enabling external interrupt 0 (INT0 flag)... this bit is in the TCON register
		SETB    IT0 ; setting IE0 trigger type so interrupt fires on high-to-low transition... this bit is in the TCON register.
		SETB    P3.2 ; making sure P3.2 is configured to be an input...
		CLR     F0 ; clearing this flag bit during the setup stage...
		CLR     P2.0 ; USED FOR SIMULATING IN DEBUGGING
		CLR     P2.1 ; USED FOR SIMULATING IN DEBUGGING
		CLR     P2.2 ; USED FOR SIMULATING IN DEBUGGING
		MOV     R0, #255 ; USED FOR SIMULATING IN DEBUGGING: loading in the max value possible into this 8-bit register - this is used in simulating a button (INT0) press
		
; ------ The main loop -------------
LOOP:	CALL	LOAD
        CALL    DEC2ZERO ; USED FOR SIMULATING IN DEBUGGING: this subroutine is used to eventually simulate a button press
        JB      F0, LOOP ; if F0 is set (1), then loop back and don't flash the LED...
	    CALL    FLASHLED ; only flash the LED if F0 is not set (0)...
		JMP     LOOP

; DEC2ZERO USED FOR SIMULATING IN DEBUGGING ;
DEC2ZERO: CALL DELAY
	      DEC R0
	      MOV A, R0
	      JZ  PUSHBUTTON ; if the accumulator is at 0 then jump to the PUSHBUTTON subroutine
	      RET
	   
FLASHLED: CPL LED ; complement the LED
		  CALL DELAY ; call the delay... in this way the LED does not flash too quickly
		  RET

LOAD:   MOV		A, P2		; move value from port 2 to the accumulator
		ANL		A, #00000111b; AND the contents of A with this 8-bit sequence to suppress the 5 MSBs of the contents of A...
FREQ1:	CJNE	A, #00000000b, FREQ2 ; if the last 3 bits of the accumulator are not 000 - jump to the next check 		
		MOV     RCAP2H, #0E7h ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #74h ; loading in the lower Byte.
		MOV		P0, #11111110b	; setting LEDs on port 0 to one-hot code for 1
		RET
		
FREQ2:	CJNE	A, #00000001b, FREQ3 ; if the last 3 bits of the accumulator are not 001 - jump to the next check 		
		MOV     RCAP2H, #0EBh ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #5Ch ; loading in the lower Byte.
		MOV		P0, #11111101b	; setting LEDs on port 0 to one-hot code for 2
		RET

FREQ3:	CJNE	A, #00000010b, FREQ4 ; if the last 3 bits of the accumulator are not 010 - jump to the next check 		
		MOV     RCAP2H, #0EFh ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #9Eh ; loading in the lower Byte.
		MOV		P0, #11111011b	; setting LEDs on port 0 to one-hot code for 1
		RET
		
FREQ4:	CJNE	A, #00000011b, FREQ5 ; if the last 3 bits of the accumulator are not 011 - jump to the next check 		
		MOV     RCAP2H, #0F2h ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #39h ; loading in the lower Byte.
		MOV		P0, #11110111b	; setting LEDs on port 0 to one-hot code for 1
		RET
		
FREQ5:	CJNE	A, #00000100b, FREQ6 ; if the last 3 bits of the accumulator are not 100 - jump to the next check 		
		MOV     RCAP2H, #0F5h ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #11h ; loading in the lower Byte.
		MOV		P0, #11101111b	; letting LEDs on port 0 to one-hot code for 1
		RET
	
FREQ6:	CJNE	A, #00000101b, FREQ7 ; if the last 3 bits of the accumulator are not 101 - jump to the next check 		
		MOV     RCAP2H, #0F6h ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #0CEh ; loading in the lower Byte.
		MOV		P0, #11011111b	; letting LEDs on port 0 to one-hot code for 1
		RET
		
FREQ7:	CJNE	A, #00000110b, FREQ8 ; if the last 3 bits of the accumulator are not 110 - jump to the next check 		
		MOV     RCAP2H, #0F8h ; loading in the upper Byte. Adding a leading 0 as "E" is not a digit.
		MOV     RCAP2L, #45h ; loading in the lower Byte.
		MOV		P0, #10111111b	; Setting LEDs on port 0 to one-hot code for 1
		RET
		
FREQ8:	CJNE	A, #00000111b, LOAD	; if the last 3 bits of the accumulator are not 111 - jump to the next check 		
		MOV     RCAP2H, #0F9h ; loading in the upper Byte. Adding a leading 0 as "F" is not a digit.
		MOV     RCAP2L, #0DDh ; loading in the lower Byte.
		MOV		P0, #01111111b	; setting LEDs on port 0 to one-hot code for 1
		RET

DELAY: ; This subroutine aids in turning on and off the LED with a 50 % duty cycle
	   	MOV		R5, #020         
DLY2:	MOV 	R6,	#144
DLY1:	MOV		R7, #255     
		DJNZ	R7, $		
		DJNZ	R6, DLY1		
		DJNZ	R5, DLY2
		RET

; ------ PUSHBUTTON USED FOR SIMULATING IN DEBUGGING: this subroutine is to simulate the pressing of the INT0 button (linked to P3.2) ------
PUSHBUTTON: CLR P3.2
            NOP
			NOP
			NOP
			SETB P3.2
			RET
			
; ------ Interrupt service routines --------------------------------	
TF2ISR:		; timer 2 overflow interrupt service routine
		CPL		SOUND ; change the state of the output pin
		CLR     TF2 ; clearing the overflow bit as this is not automatically done for timer 2.
		RETI ; return from the interrupt service routine

IE0ISR: CPL F0 ; complement the flag bit
        SETB LED ; turn the LED off
		MOV R0, #100 ; USED FOR SIMULATING IN DEBUGGING: change this value in order to change the delay between the first and second time the INT0 (P3.2) button is pressed...
		RETI	

END