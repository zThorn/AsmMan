;PPPPPPPPPPPPPPPPP        AAA                  CCCCCCCCCCCCCMMMMMMMM               MMMMMMMM               AAA               NNNNNNNN        NNNNNNNN
;P::::::::::::::::P      A:::A              CCC::::::::::::CM:::::::M             M:::::::M              A:::A              N:::::::N       N::::::N
;P::::::PPPPPP:::::P    A:::::A           CC:::::::::::::::CM::::::::M           M::::::::M             A:::::A             N::::::::N      N::::::N
;PP:::::P     P:::::P  A:::::::A         C:::::CCCCCCCC::::CM:::::::::M         M:::::::::M            A:::::::A            N:::::::::N     N::::::N
;  P::::P     P:::::P A:::::::::A       C:::::C       CCCCCCM::::::::::M       M::::::::::M           A:::::::::A           N::::::::::N    N::::::N
;  P::::P     P:::::PA:::::A:::::A     C:::::C              M:::::::::::M     M:::::::::::M          A:::::A:::::A          N:::::::::::N   N::::::N
;  P::::PPPPPP:::::PA:::::A A:::::A    C:::::C              M:::::::M::::M   M::::M:::::::M         A:::::A A:::::A         N:::::::N::::N  N::::::N
;  P:::::::::::::PPA:::::A   A:::::A   C:::::C              M::::::M M::::M M::::M M::::::M        A:::::A   A:::::A        N::::::N N::::N N::::::N
;  P::::PPPPPPPPP A:::::A     A:::::A  C:::::C              M::::::M  M::::M::::M  M::::::M       A:::::A     A:::::A       N::::::N  N::::N:::::::N
;  P::::P        A:::::AAAAAAAAA:::::A C:::::C              M::::::M   M:::::::M   M::::::M      A:::::AAAAAAAAA:::::A      N::::::N   N:::::::::::N
;  P::::P       A:::::::::::::::::::::AC:::::C              M::::::M    M:::::M    M::::::M     A:::::::::::::::::::::A     N::::::N    N::::::::::N
;  P::::P      A:::::AAAAAAAAAAAAA:::::AC:::::C       CCCCCCM::::::M     MMMMM     M::::::M    A:::::AAAAAAAAAAAAA:::::A    N::::::N     N:::::::::N
;PP::::::PP   A:::::A             A:::::AC:::::CCCCCCCC::::CM::::::M               M::::::M   A:::::A             A:::::A   N::::::N      N::::::::N
;P::::::::P  A:::::A               A:::::ACC:::::::::::::::CM::::::M               M::::::M  A:::::A               A:::::A  N::::::N       N:::::::N
;P::::::::P A:::::A                 A:::::A CCC::::::::::::CM::::::M               M::::::M A:::::A                 A:::::A N::::::N        N::::::N
;PPPPPPPPPPAAAAAAA                   AAAAAAA   CCCCCCCCCCCCCMMMMMMMM               MMMMMMMMAAAAAAA                   AAAAAAANNNNNNNN         NNNNNNN



TITLE PACMAN					(main.asm)
INCLUDE Irvine32.inc
.data

.code
main PROC
	Call Clrscr
	Call ClearRegs
	MOV ECX,-1

	GameLoop:
		mov eax,0
		Call HandleInput
		mov eax,75
		Call Delay
	loop GameLoop

	exit
main ENDP

ClearRegs proc

	mov eax,0
	mov ebx,0
	mov ecx,0
	mov edx,0
	mov esi,0
	mov edi,0

	ret
ClearRegs ENDP


;/////////////////////////////;
;							  ;
;  Main Procedure that handles;
;  Player input               ;
;  Uses Registers             ;
;  EAX, EDX                   ;
;							  ;
;/////////////////////////////;
HandleInput proc
	Call ReadChar

	cmp al,61h
	je MoveLeft
	jmp CheckRight

	CheckRight:
		cmp al,64h
		je MoveRight
		jmp CheckDown

	CheckDown:
		cmp al,73h
		je MoveDown
		jmp CheckUp

	CheckUp:
		cmp al,77h
		je MoveUp
		jmp exitInp

	MoveDown:
		inc dh
		call ClrScr
		call GotoXY
		mov al,'^'	
		call writechar
		jmp exitInp

	MoveUp:
		dec dh
		call ClrScr
		call GotoXY
		mov al,'V'
		call writechar
		jmp exitInp

	MoveRight:
		inc dl
		call ClrScr
		call GotoXY
		mov al,'<'
		call writechar
		jmp exitInp

	MoveLeft:
		dec dl
		call ClrScr
		call GotoXY
		mov al,'>'
		call writechar
		jmp exitInp

	exitInp:

ret
HandleInput ENDP



END main