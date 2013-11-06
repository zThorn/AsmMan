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

;///////////////////////////////////////////
;Strings for the Title Bar                 ;
;///////////////////////////////////////////

scoreTitle byte "Score: ",0
livesTitle byte "Lives: ",0
mainTitle byte "ASM-MAN        {* *} {* *} {* *}  < * * * * * * *",0

;///////////////////////////////////////////
;Variables for Game Logic                  ;
;///////////////////////////////////////////

score byte 0	;Keeps track of player score
lives byte 3	;PlayerLives

;//////////////////////////;
;Variables for Ghost Logic ;
;//////////////////////////;
ghostX byte 20
ghostY byte 20


;//////////////////////////;
;Variables for Player Logic;
;//////////////////////////;
playerX byte 35
playerY byte 13

.code

main PROC
	Call Clrscr
	Call ClearRegs
	Call InitialSetup
	Call InitGhost
	MOV ECX,-1

	GameLoop:
		Call DrawTitleBar
		mov eax,0

		Call ReadChar
		Call HandleInput
		Call GhostLogic
		
		;mov eax,75
		;Call Delay
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


;//////////////////////////////
;/////////////////////////////;
;							  ;
;  Main Procedure that places ;
;   pacmans initial position  ;       
;  Uses Registers             ;
;  EAX, EDX                   ;
;							  ;
;/////////////////////////////;
;//////////////////////////////

initialSetup proc
	mov dh,13
	mov dl,35
	Call GotoXY
	mov al,'<'
	Call WriteChar
ret
initialSetup ENDP

initGhost PROC uses edx eax 
	mov dh,20
	mov dl,20
	Call GotoXY

	mov al,'G'
	Call WriteChar
ret
initGhost ENDP

ghostLogic PROC
	mov dh,ghostY
	mov dl,ghostX

	cmp dh,playerY
	jl ghostIsBelowPlayer
	jge ghostIsAbovePlayer

	ghostIsBelowPlayer:
		inc dh
		inc ghostY
		mov dh,ghostY
		mov dl,ghostX

		mov ghostY,dh
		jmp checkX

	ghostIsAbovePlayer:
		dec dh
		dec ghostY
		mov dh,ghostY
		mov dl,ghostX

		mov ghostY,dh
		jmp checkX

	checkX:
		cmp dl,playerX
		jg ghostIsRightOfPlayer
		jle ghostIsLeftOfPlayer

	ghostIsRightOfPlayer:
		dec dl
		dec ghostX
		mov dl,ghostX
		mov dh,ghostY
		Call GotoXY

		mov al,'G'
		Call WriteChar
		mov ghostX,dl
		jmp checkIfPlayerKilled

	ghostIsLeftOfPlayer:
		inc dl
		inc ghostX
		mov dl,ghostX
		mov dh,ghostY
		Call GotoXY

		mov al,'G'
		Call WriteChar
		mov ghostX,dl
		jmp checkIfPlayerKilled

		checkIfPlayerKilled:
			cmp dh,playerY
			je checkPlayerGhostX
			jmp eProc

		checkPlayerGhostX:
			cmp dl,playerX
			je playerDead
			jmp eProc

		playerDead:
			dec lives

			cmp lives,0
			je gameover
			jmp eProc
		gameover:
			exit
		eProc:


ret
ghostLogic ENDP

;//////////////////////////////
;/////////////////////////////;
;							  ;
;  Main Procedure that handles;
;  Player input               ;
;  Uses Registers             ;
;  EAX, EDX                   ;
;							  ;
;/////////////////////////////;
;//////////////////////////////

HandleInput proc uses eax edx
	
	cmp al,61h	;if(inp=='a') moveleft else checkright
	je MoveLeft
	jmp CheckRight

	CheckRight:
		cmp al,64h	;if(inp=='d') moveright else checkdown
		je MoveRight
		jmp CheckDown

	CheckDown:
		cmp al,73h	;if(inp=='s') movedown else checkup
		je MoveDown
		jmp CheckUp

	CheckUp:
		cmp al,77h	;if(inp=='w') moveup else exit
		je MoveUp
		jmp exitInp

	MoveDown:
		inc dh
		inc playerY
		mov dh,playerY
		mov dl,playerX
		Call ClrScr
		Call GotoXY
		mov al,'^'	
		mov playerY,dh
		Call writechar
		Call IncrementScore
		jmp exitInp

	MoveUp:
		dec dh
		dec playerY
		mov dh,playerY
		mov dl,playerX
		Call ClrScr
		Call GotoXY
		mov al,'V'
		mov playerY,dh
		Call WriteChar
		Call IncrementScore
		jmp exitInp

	MoveRight:
		inc dl
		inc playerX
		mov dh,playerY
		mov dl,playerX
		Call ClrScr
		Call GotoXY
		mov al,'<'
		mov playerX,dl
		Call WriteChar
		Call IncrementScore
		jmp exitInp

	MoveLeft:
		dec dl
		dec playerX
		mov dh,playerY
		mov dl,playerX
		Call ClrScr
		Call GotoXY
		mov al,'>'
		mov playerX,dl

		Call WriteChar
		Call IncrementScore
		jmp exitInp

	exitInp:
		
ret
HandleInput ENDP



;//////////////////////////////
;/////////////////////////////;
;							  ;
;  Main Procedure draws the   ;
;   players current score     ;
;  Uses Registers             ;
;  EAX, EDX                   ;
;							  ;
;/////////////////////////////;
;//////////////////////////////

displayScore PROC USES edx eax
	mov eax,0
	mov dh,0
	mov dl,69

	Call GotoXY
	mov al,score
	mov edx,offset scoreTitle
	Call WriteString
	Call WriteInt
ret
displayScore ENDP


;//////////////////////////////
;/////////////////////////////;
;							  ;
;  Main Procedure displays    ;
;  the players current lives  ;
;  Uses Registers             ;
;  EAX, EDX                   ;
;							  ;
;/////////////////////////////;
;//////////////////////////////

displayLives PROC uses eax edx
	mov eax,0
	mov dh,0
	mov dl,55
	Call GotoXY

	mov al,lives
	mov edx,offset livesTitle

	Call WriteString
	Call WriteInt

ret
displayLives ENDP


;//////////////////////////////
;/////////////////////////////;
;							  ;
;  Main Procedure that draws  ;
;  the title bar boundaries,  ;
;  as well as the title bar   ;
;  text                       ;
;  Uses Registers             ;
;  EAX, ECX, EDX              ;
;							  ;
;/////////////////////////////;
;//////////////////////////////
drawTitleBar PROC uses eax ecx edx
	mov eax,'-'
	mov dh,1
	mov ecx,79
	
	L1:
		mov dl,cl
		Call GotoXY
		Call WriteChar

	loop L1

	mov dh,0
	mov dl,0
	Call GotoXY

	mov edx,offset mainTitle
	Call writestring

	Call displayLives
	Call displayScore
ret
drawTitleBar ENDP


;/////////////////////////////////;
;Wrapper for inc, increments Score;
;/////////////////////////////////;
IncrementScore PROC
	inc score
	ret
IncrementScore ENDP


;/////////////////////////////////;
;Wrapper for inc, increments Lives;
;/////////////////////////////////;
playerDeath PROC
	dec lives
	ret
playerDeath ENDP

END main