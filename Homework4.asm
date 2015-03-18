TITLE Adam's Awesome Primes Project			(Homework4.asm)

; Program Description: A program that calculates and prints the first n prime numbers based on a user defined integer [1-200]
; Author: Adam Cankaya
; Date Due:  Feb 16, 2014
; Last Modification Date: Feb 16, 2014
; Bonus: Efficiency improved by usng square root for the dividend in prime calculation

 INCLUDE Irvine32.inc
 
 ; CONSTANTS 
 	LOW_LIM		=	1	; lower limit for n
	UPP_LIM		=	200	; upper limit for n

 .data

 ; VARIABLES
	
	; User input
		buffer		BYTE	21	DUP(0)	; input buffer
		byteCount	DWORD	0			; holds counter
		userName	DWORD	0			; name entered by user
		n			DWORD	0			; integer [0,200] entered

	; Program output text
		intro_0		BYTE	"Hello ", 0
		intro_1		BYTE	"Welcome to Adam Cankaya's CS 271 Homework 4 program, written in MASM!", 0
		prompt_1	BYTE	"What is your name?", 0
		intro_2		BYTE	", nice to meet you.", 0
		intro_3		BYTE	"Enter an integer 1 to 200 inclusive and I will calculate that number of primes!", 0
		comma		BYTE	", ", 0
		theTab		BYTE	"   ", 0
		intro_5		BYTE	"Here we go...", 0
		error_1		BYTE	"I'm sorry, you entered a number that isn't an integer between 1 and 200 inclusive. Please try again.", 0
		exit_0		BYTE	"Goodbye ", 0
		exit_1		BYTE	"Thanks for playing with me!", 0

	
	; Loop and calculation variables
		i			DWORD	1	; count of numbers up to n
		isqrt		DWORD	0	; the square root of i
		isPrimeBoo	DWORD	1	; 0 if a number is prime, else 1
		x			DWORD	1	; dividend value for checking prime status
		loopEAX		DWORD	0	; backup of loop counter from eax
		perLine		DWORD	0	; counter to print 10 terms per line
		repromptBin	DWORD	0	; Incremented if a reprompt is required

.code
main PROC

	call	introduction
	call	getUserData
	call	showPrimes
	call	farewell

	exit					; exit to operating system
main ENDP

; Procedure to ask user for their name and greet them using it
; receives: user input, global variables intro_0, intro_1, intro_2, prompt_1, userName, byteCount
; returns: saves user name input to userName and prints greetings using user's name
; preconditions: string variables must be predefined
; registers changed: edx, ecx
	introduction	PROC
		; Display Program title and author's name
			mov		edx, OFFSET intro_1			
			call	WriteString
			call	CrLf
	
		; Prompt user to enter their name
			mov		edx, OFFSET prompt_1
			call	WriteString
	
		; Read in user's name
			mov		edx, OFFSET buffer
			mov		ecx, SIZEOF	buffer
			call	ReadString
			mov		userName, edx
			mov		byteCount, eax
		
		; Greet user using their name
			mov		edx, OFFSET intro_0
			call	WriteString			; print 'Hello'
			mov		edx, userName
			call	WriteString			; print user's name
			mov		edx, OFFSET intro_2
			call	WriteString
			call	CrLf
	
		ret
	introduction	ENDP

; Procedure to ask user to enter an integer 1 to 200 inclusive
; receives: user input, global variable intro_3
; returns: sets n based on user input
; preconditions: global variables are pre-defined
; registers changed: edx, eax
	getUserdata		PROC
	
	getData:
			mov		repromptBin, 0	; resets reprompt counter

		; Prompt user to enter a number [1-200]
			mov		edx, OFFSET intro_3
			call	WriteString
			call	CrLf

		Prompt:
			call	ReadInt
			mov		n, eax
			call	validate
			cmp		repromptBin, 0		; checks if repromptBin has been incremented, indicating a reprompt
			jg		getData				; if so then starts the getUserData proc over again without calling it
			ret							; else returns to main

		; Procedure to validate user input is integer in range [1,200]
		; receives: global variable n and global constants LOW_LIM, UPP_LIM
		; returns: none
		; preconditions: global variables are pre-defined
		; registers changed: eax
			validate	PROC
				; Validate user input is integer [1,200]
				mov		eax, n
				cmp		eax, LOW_LIM
				jl		Reprompt			; reprompt user if n < lower limit
				cmp		eax, UPP_LIM
				jg		Reprompt			; reprompt user if n > upper limit
				ret

				Reprompt:
				mov		n, 0
				mov		eax, 0
				inc		repromptBin
				ret

			validate	ENDP

	getUserdata		ENDP

; Procedure to print n primes based on user entered integer n
; receives: global variables x, n, isPrimeBoo, comma, theTab, i, isqrt
; returns: prints out set of prime numbers
; preconditions: global variables are pre-defined
; registers changed: ecx, eax, edx, ebx
showPrimes		PROC

	mov		eax, 0				; reset eax to 0

	Primes:
		mov		loopEAX, eax	; backs up loop count from eax
		mov		x,1				; reset to x = 1
		inc		i
		mov		ecx, n
		call	isPrime
		cmp		isPrimeBoo, 0	; if = 0 then i is prime
		je		Print			; prints if i is prime
		jmp		PrimeLoop		; else skips printing

	Print:
		; code to print out i
		mov		eax, loopEAX
		cmp		eax, n 
		jge		PrimeEnd		; jumps to end if loopEAX >= n
		mov		eax, i
		call	WriteDec
		inc		loopEAX
		mov		edx, OFFSET theTab
		call	WriteString

		; code to check if new line is needed
		inc		perLine
		cmp		perLine, 10
		jl		PrimeLoop		; returns to loop if no new line is needed
		call	Crlf			; else prints new line
		mov		perLine, 0		; resets perLine counter to 0
		jmp		PrimeLoop		; and then returns to loop

	PrimeLoop:
		mov		eax, loopEAX	; returns previously backed up loop counter
		loop	Primes

	; Procedure to calculate n primes, a user entered integer
	; receives: isPrimeBoo, i, isqrt, x, isPrimeBoo
	; returns: sets isPrimeBoo = 0 if i is prime, else sets equal to 1
	; preconditions: global variables are pre-defined
	; registers changed: ebx, edx, eax
	isPrime		PROC

		fild i				 ;push i on to ST(0)
		fsqrt				 ;pop i and compute square root and push back to ST(0)
		fistp isqrt			 ;pop ST(0) and store to memory in variable isqrt
		
		xInc:
			; Code to check if x >= sqrt(i)
			inc		x
			mov		eax, x
			mov		ebx, isqrt
			cmp		eax, ebx
			jg		Done			; jumps to end of function if x > sqrt(i)

			; Code to check if i / x has zero remainder or not
			mov		eax, i
			mov		ebx, x
			cmp		ebx, i			; checks if x = i
			je		xInc			; if so then jumps to increment x again and avoid i / x = 1
			cdq
			div		ebx				; divide i by x
			cmp		edx, 0			; check if remainder is 0
			jne		xInc			; if remainder is not 0 then i might be prime, continue checking
			mov		isPrimeBoo, 1	; else stop checking because i is not prime
			jmp		TheEnd

		TheEnd:
			mov		isPrimeBoo, 1	; i is not prime
			ret

		Done:
			mov		isPrimeBoo,0	; i is prime
			ret

	isPrime		ENDP

	PrimeEnd:
		ret

showPrimes		ENDP

	; Procedure to say goodbye to user
	; receives: global variables exit_0, userName, comma, exit_1
	; returns: Prints goodbye message using user's name
	; preconditions: global variables are pre-defined
	; registers changed: edx
farewell		PROC

	; Display parting message that includes user's name
		call	CrLf
		call	CrLf
		mov		edx, OFFSET exit_0		
		call	WriteString
		mov		edx, userName
		call	WriteString
		mov		edx, OFFSET comma
		call	WriteString
		mov		edx, OFFSET exit_1
		call	WriteString
		call	CrLf
		call	CrLf
		call	WaitMsg
	ret

farewell		ENDP

END main