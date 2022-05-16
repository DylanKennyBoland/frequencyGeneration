;********************************************************************
; Example program for Analog Devices EVAL-ADuC841 board.
; Based on example code from Analog Devices.
; Authors: Dylan Boland & Cuan De Burca
; Date: January 2022
;
; Hardware: ADuC841 with clock frequency 11.0592 MHz
;
; Description: Generates 1200 Hz Square Wave on P3.6
;
;********************************************************************

$NOMOD51			; for Keil uVision - do not pre-define 8051 SFRs
$INCLUDE (MOD841)	; load this definition file instead

SOUND		EQU	P3.6		; P3.6 is where the square wave output goes

;____________________________________________________________________
		; MAIN PROGRAM
CSEG		                ; working in code segment - program memory

		ORG	0000h		    ; starting at address 0
		
OSC:	CPL 	SOUND		; change state of output    (1 clk cycles)
		CALL	DELAY   	; call software delay routine (4 clk cycles)
		JMP		OSC			; repeat indefinately (3 clk cycles)

;____________________________________________________________________
		; SUBROUTINES
DELAY:  MOV		R6, #8		; outer loop repeats 8 times  (2 clk cycles)       
DLY1:	MOV		R7, #189	; load in 189     
		DJNZ	R7, $		; inner loop, delay of (189*3 + 2 + 5 = 574 clk cycles)
		NOP
		NOP
		DJNZ	R6, DLY1	; outer loop, (8*574 + 2 = 4594 clk cycles)
		NOP
		NOP
		RET					; return from subroutine (4 clk cycles)
		
;_____________________________________________________________________

END