;			  PPPPPPPPPPPPPPPPP        AAA                  CCCCCCCCCCCCC
;			  P::::::::::::::::P      A:::A              CCC::::::::::::C
;			  P::::::PPPPPP:::::P    A:::::A           CC:::::::::::::::C
;			  PP:::::P     P:::::P  A:::::::A         C:::::CCCCCCCC::::C
;			    P::::P     P:::::P A:::::::::A       C:::::C       CCCCCC
;			    P::::P     P:::::PA:::::A:::::A     C:::::C              
;			    P::::PPPPPP:::::PA:::::A A:::::A    C:::::C              
;			    P:::::::::::::PPA:::::A   A:::::A   C:::::C              
;			    P::::PPPPPPPPP A:::::A     A:::::A  C:::::C              
;			    P::::P        A:::::AAAAAAAAA:::::A C:::::C              
;			    P::::P       A:::::::::::::::::::::AC:::::C              
;			    P::::P      A:::::AAAAAAAAAAAAA:::::AC:::::C       CCCCCC
;			  PP::::::PP   A:::::A             A:::::AC:::::CCCCCCCC::::C
;			  P::::::::P  A:::::A               A:::::ACC:::::::::::::::C
;			  P::::::::P A:::::A                 A:::::A CCC::::::::::::C
;			  PPPPPPPPPPAAAAAAA                   AAAAAAA   CCCCCCCCCCCCC
;MMMMMMMM               MMMMMMMM               AAA               NNNNNNNN        NNNNNNNN
;M:::::::M             M:::::::M              A:::A              N:::::::N       N::::::N
;M::::::::M           M::::::::M             A:::::A             N::::::::N      N::::::N
;M:::::::::M         M:::::::::M            A:::::::A            N:::::::::N     N::::::N
;M::::::::::M       M::::::::::M           A:::::::::A           N::::::::::N    N::::::N
;M:::::::::::M     M:::::::::::M          A:::::A:::::A          N:::::::::::N   N::::::N
;M:::::::M::::M   M::::M:::::::M         A:::::A A:::::A         N:::::::N::::N  N::::::N
;M::::::M M::::M M::::M M::::::M        A:::::A   A:::::A        N::::::N N::::N N::::::N
;M::::::M  M::::M::::M  M::::::M       A:::::A     A:::::A       N::::::N  N::::N:::::::N
;M::::::M   M:::::::M   M::::::M      A:::::AAAAAAAAA:::::A      N::::::N   N:::::::::::N
;M::::::M    M:::::M    M::::::M     A:::::::::::::::::::::A     N::::::N    N::::::::::N
;M::::::M     MMMMM     M::::::M    A:::::AAAAAAAAAAAAA:::::A    N::::::N     N:::::::::N
;M::::::M               M::::::M   A:::::A             A:::::A   N::::::N      N::::::::N
;M::::::M               M::::::M  A:::::A               A:::::A  N::::::N       N:::::::N
;M::::::M               M::::::M A:::::A                 A:::::A N::::::N        N::::::N
;MMMMMMMM               MMMMMMMMAAAAAAA                   AAAAAAANNNNNNNN         NNNNNNN

; Program		: Pacman
; Date Created	: 11.4.2013
; Last Updated	: 12.2.2013
; Authors		: Zach Thornton
;				: Steven Fortier
;				: Bryan Young
; Description	: 

TITLE PACMAN					(main.asm)
INCLUDE Irvine32.inc

.data
testCoordinateSystem byte 0

;-----------------------------------------------------------------------------;
;                             Environment Variables		 ;
;-----------------------------------------------------------------------------;
maxX	db	80
maxY	db	58

pregameTitle	db	"Action Required",0
pregameMessage	db	"Please maximize the screen!",0

mainMenuBoxXOne	db	0	; 1/3 maxX
mainMenuBoxYOne	db	0	; 1/4 maxY
mainMenuBoxXTwo	db	0
mainMenuBoxYTwo db	0
mainMenuYInc	db	0

divisorOneThird	db	3

defaultCursorColor	dw	white + (black * 16) ; White with black text

;-----------------------------------------------------------------------------;
;                                 Debug Info				 ;
;-----------------------------------------------------------------------------;
displayMainMenuBox		db	"Main Menu Box ",0
displayMainMenuBoxXOne	db	"X1: ",0
displayMainMenuBoxYOne	db	"Y1: ",0
displayMainMenuBoxXTwo	db	"X2: ",0
displayMainMenuBoxYTwo	db	"Y2: ",0
displayMainMenuYInc		db	"Y Increment: ",0

warningMessage	db	"WARNING! ",0
errorMessage	db	"ERROR! ",0

fileLoadErrorMsg	db	"Error loading file!",0


;-----------------------------------------------------------------------------;
;	Map Data					 ;
;-----------------------------------------------------------------------------;
buffer_size = 838

filename byte "map.txt",0
fileHandle handle ?

mapData byte buffer_size dup('*')
mapDataBufferSize word 0
outerEcx byte 0
iterations byte 0

;-----------------------------------------------------------------------------;
;	  Title Bar Strings				 ;
;-----------------------------------------------------------------------------;
scoreTitle byte "Score: ",0
livesTitle byte "Lives: ",0
mainTitle byte "ASM-MAN",0


;-----------------------------------------------------------------------------;
;                            Game Logic Variables		 ;
;-----------------------------------------------------------------------------;
score dword 0	;Keeps track of player score
scoreToEnd word 292		;Once 0, game restarts
level byte 1	;What level you are on
levelName byte "Level: ",0
lives byte 3	;PlayerLives
gameOverStr byte "YOU HAVE DIED",0
currentPacOrientation byte '<'
pelletMode byte 0
cherryMode byte 0
upChar byte 'w',0
leftChar byte 'a',0
rightChar byte 'd',0
downChar byte 's',0

;-----------------------------------------------------------------------------;
;                           Ghost Logic Variables			 ;
;-----------------------------------------------------------------------------;
ghostLife byte 4 DUP(1)
ghostX byte 6,10,17,20
ghostY byte 4 DUP(11)
spaceOccupied byte 0 	;Treating this like a boolean
currentSelectedGhost byte 0
currentGhostOrientation byte 4 DUP(0)
ghostSpawnCounter byte 4 DUP(10)
ghostColor byte 3,4,5,7
;-----------------------------------------------------------------------------;
;                          Player Logic Variables			 ;
;-----------------------------------------------------------------------------;
playerX byte 13
playerY byte 17


;-----------------------------------------------------------------------------;
;                              Pause Variables		                ;
;-----------------------------------------------------------------------------;
pauseStr1 byte "[ Spacebar to Pause ]",0
pauseStr2 byte "[Spacebar to UnPause]",0
escapeStr1 byte "                     ",0
escapeStr2 byte "[ ESC to Leave Game ]",0
pauseChecker byte 0  	; Used to keep track of pause state


;-----------------------------------------------------------------------------;
;                     Game State Controller Variables		 ;
;-----------------------------------------------------------------------------;
gameState	db	2	; Default to Splash Screen

stateWarning	db	"WARNING! Unexpected state change encountered: ",0
stateError		db	"ERROR! Encountered an error in state change: ",0


;-----------------------------------------------------------------------------;
;		Splash Screen Variables	                ;
;-----------------------------------------------------------------------------;
splashScreenFile	db		"splashMarquee.txt",0
splashScreenBuffer	db		2384	DUP(0)

splashScreenBufferSize	dd	0


;-----------------------------------------------------------------------------;
;	Settings Screen Variables			 ;
;-----------------------------------------------------------------------------;
settingsMenuTitle	db	"SETTINGS",0
settingsMenuUp		db	"Enter a key for UP: ",0
settingsMenuLeft	db	"Enter a key for LEFT: ",0
settingsMenuRight	db	"Enter a key for RIGHT: ",0
settingsMenuDown	db  "Enter a key for DOWN: ",0


;-----------------------------------------------------------------------------;
;	 Credits Screen Variables			 ;
;-----------------------------------------------------------------------------;
creditsScreenTitle		db	"CREDITS",0
creditsSteven			db	"Steven Fortier",0
creditsBryan			db  "Bryan Young",0
creditsZach				db	"Zach Thornton",0


;-----------------------------------------------------------------------------;
;	 Main Menu Variables				 ;
;-----------------------------------------------------------------------------;
backgroundHeaderFile	db	"backgroundHeader.txt",0
backgroundFooterFile	db	"backgroundFooter.txt",0

backgroundHeaderBuffer	db	1282	DUP(0)
backgroundFooterBuffer	db	1282	DUP(0)

backgroundHeaderBufferSize	dd	0
backgroundFooterBufferSize	dd	0

mainPlayOption		db	"PLAY",0
mainSettingsOption	db	"SETTINGS",0
mainCreditsOption	db	"CREDITS",0
mainExitOption		db	"QUIT",0
mainMenuSelection	db	0
mainMenuItems		db	4		

mainMenuSelectionXY	dw	0

menuBoxY	db	0
menuBoxX	db	0

mainMenuSelectionError	db	"ERROR! Invalid selection: ",0


;-----------------------------------------------------------------------------;
;	Code Segment				 ;
;-----------------------------------------------------------------------------;
.code

main PROC
	Call	Randomize
	
	mov		ebx, OFFSET pregameTitle
	mov		edx, OFFSET pregameMessage
	call	msgBox

	Call	Clrscr
	Call	ClearRegs
	call	initVariables


	call	gameStateController

	exit
main ENDP

; Procedure		: initVariables
; Date Created	: 11.30.2013
; Last Updated	: 11.30.2013
; Authors		: Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Startup procedure that initializes environment values and 
;		performs calculations for environment based variables used by the 
;		program.

initVariables PROC USES eax ebx ecx edx
	mov		al, maxY
	mov		dl, maxX
	mov		cl, dl

	shr		al, 2					; Divide by 4
	mov		mainMenuBoxYOne, al
	mov		mainMenuBoxYTwo, al
	add		mainmenuBoxYTwo, al
	add		mainMenuBoxYTwo, 1		; correct for padding

	mov		bl, mainMenuItems
	inc		bl
	div		bl
	mov		mainMenuYInc, al
	add		mainMenuYInc, 1		; add current line, correct for padding
	xor		eax, eax
	
	mov		al, cl
	div		divisorOneThird
	mov		mainMenuBoxXOne, al
	mov		mainMenuBoxXTwo, al
	add		mainMenuBoxXTwo, al

	mov		edx, OFFSET splashScreenFile
	mov		ecx, LENGTHOF splashScreenBuffer
	mov		ebx, OFFSET splashScreenBuffer
	call	loadBufferFromFile
	mov		splashScreenBufferSize, eax

	mov		edx, OFFSET backgroundHeaderFile
	mov		ecx, LENGTHOF backgroundHeaderBuffer
	mov		ebx, OFFSET backgroundHeaderBuffer
	call	loadBufferFromFile
	mov		backgroundHeaderBufferSize, eax

	mov		edx, OFFSET backgroundFooterFile
	mov		ecx, LENGTHOF backgroundFooterBuffer
	mov		ebx, OFFSET backgroundFooterBuffer
	call	loadBufferFromFile
	mov		backgroundFooterBufferSize, eax

;	mov		edx, OFFSET creditsScreenFile
;	mov		ecx, LENGTHOF creditsScreenBuffer
;	mov		ebx, OFFSET creditsScreenBuffer
;	call	loadBufferFromFile
;	mov		creditsScreenBufferSize, eax

	ret
initVariables ENDP

; Procedure		: gameStateController
; Date Created	: 11.29.2013
; Last Updated	: 11.29.2013
; Authors		: Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Compares the gameState variable to expected values and 
;		controls program flow based on current state value. Error states
;		are negative values and the default state is 2 which displays the
;		splash screen and continues through to the main menu. 

gameStateController PROC
	stateController:
		cmp		gameState, 1
		je		playState

		cmp		gameState, 2
		je		splashScreenState

		cmp		gameState, 3
		je		mainMenu

		cmp		gameState, 4
		je		settingsMenu

		cmp		gameState, 5
		je		creditsScreenState

		cmp		gameState, 0
		jg		warning		; If positive and non-normal state, terminte
		jl		error		; If negative, error terminates execution
		jmp		done		; If 0, program exiting normally

	stateChange:
		call	clrscr
		cmp		gameState, 1
		je		initializeGame
		jmp		stateController

	initializeGame:
		call	initPlayState
		jmp		stateController

	playState:
		call	playStateController
		cmp		gameState, 1
		jne		stateChange
		jmp		stateController

	splashScreenState:
		call	splashScreen
		jmp		stateChange

	mainMenu:
		call	mainMenuStateController
		cmp		gameState, 3
		jne		stateChange
		jmp		stateController

	settingsMenu:
		call	settingsMenuStateController
		cmp		gameState, 4
		jne		stateChange
		jmp		stateController

	creditsScreenState:
		call	creditsScreen
		jmp		stateChange

	warning:
		mov		edx, OFFSET stateWarning
		call	writeString
		movzx	eax, gameState
		call	writeInt
		jmp		done

	error:
		mov		edx, OFFSET stateError
		call	writeString
		movzx	eax, gameState
		call	writeInt

done:
	ret
gameStateController ENDP

; Procedure		: splashScreen
; Date Created	: 11.29.2013
; Last Updated	: 11.29.2013
; Authors		: Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Draws the splash screen.

splashScreen PROC USES edx
	call	clrscr

	mov		bh, 16
	mov		bl, 149
	mov		cl, 0
	mov		dh, 14
	mov		dl, 79
	mov		esi, OFFSET splashScreenBuffer

scrollBuffer:
	mov		eax, 25
	call	delay
	push	ecx		; Preserve ecx (cl and ch) (current index)
	push	edx		; Preserve edx (dl and dh) (current location of cursor)
	

	printBufferSegment:
		call	gotoXY
		.IF cl > 146
			jg		printBlank
		.ENDIF
		call	printBufferCol
		inc		dl
		inc		cl
		cmp		dl, 79
		jle		printBufferSegment
		jmp		next
	
	printBlank:
		call	printBlankCol
		inc		dl
		inc		cl
		cmp		dl, 79
		jle		printBufferSegment

next:
	pop		edx
	pop		ecx
	cmp		dl, 0
	je		incBuffer

	dec		dl
	jmp		scrollBuffer

incBuffer:
	inc		cl
	.IF cl <= bl
		jmp		scrollBuffer
	.ENDIF

	; Print blank screen?

	mov		gameState, 3	; Set to main menu state
	ret
splashScreen ENDP

; Procedure		: mainMenuStateController
; Date Created	: 11.29.2013
; Last Updated	: 11.30.2013
; Authors		: Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Controller for the main menu game state. Call's normal menu
;		functions and tests for state change. Returns to game state controller
;		on game state change. 

mainMenuStateController PROC USES eax edx
	xor		edx, edx
	call	gotoXY

	call	drawMainMenu
	call	readChar

	cmp		al, 0Dh		; 'ENTER', selection made
	je		makeSelection

	cmp		al, upChar
	je		previous

	cmp		al, downChar
	je		next
	jmp		done		; No usable input entered, ignore

	makeSelection:
		cmp		mainMenuSelection, 0
		je		enterPlayGameState

		cmp		mainMenuSelection, 1
		je		enterSettingsMenuGameState

		cmp		mainMenuSelection, 2
		je		enterCreditsGameState

		cmp		mainMenuSelection, 3
		je		exitGameState

		mov		edx, OFFSET mainMenuSelectionError
		call	writeString
		mov		al, mainMenuSelection
		call	writeInt
		mov		gameState, -2		; Invalid main menu selection error code
		jmp		done

	previous:
		mov		al, mainMenuSelection
		cmp		al, 0
		jle		done
		dec		al
		mov		mainMenuSelection, al
		jmp		done

	next:
		mov		al, mainMenuSelection
		cmp		al, mainMenuItems
		jge		done
		inc		al
		mov		mainMenuSelection, al
		jmp		done

	enterPlayGameState:
		mov		gameState, 1
		jmp		done

	enterSettingsMenuGameState:
		mov		gameState, 4
		jmp		done

	enterCreditsGameState:
		mov		gameState, 5
		jmp		done

	exitGameState:
		mov		gameState, 0

done:
	ret
mainMenuStateController ENDP

; Procedure		: drawMainMenu
; Date Created	: 11.29.2013
; Last Updated	: 11.30.2013
; Authors		: Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Draws the main menu centered and to scale with the buffer.
;		Highlights the current menu item selection

drawMainMenu PROC
	
	; Draw background
;	mov		edx, OFFSET menuBackgroundHeader
;	call	writeString
;
;	mov		dh, maxY
;	sub		dh, 16
;	call	gotoXY
;	
;	mov		edx, OFFSEt menuBackgroundFooter
;	call	writeString

	; Draw Menu Box
	mov		cl, mainMenuBoxXOne
	mov		bl, mainmenuBoxYOne
	mov		dh, bl
	mov		dl, cl

	printRow:
		call	gotoXY
		printColumn:
			edge:
				mov		al, '#'
				call	writeChar
				inc		dl
				jmp		next

			inner:
				mov		al, ' '
				call	writeChar
				inc		dl
				jmp		next

			checkYBorder:
				cmp		dh, mainMenuBoxYOne
				je		edge
				cmp		dh, mainMenuBoxYTwo
				je		edge
				jne		inner

			next:
				cmp		dl, mainMenuBoxXTwo
				jl		checkYBorder
				je		edge

		mov		dl, mainMenuBoxXOne
		inc		dh
		cmp		dh, mainMenuBoxYTwo
		jle		printRow

	; Draw menu
	mov		bh, mainMenuBoxYOne
	xor		ecx, ecx
	
	mov		edx, OFFSET mainExitOption
	push	edx
	mov		edx, OFFSET mainCreditsOption
	push	edx
	mov		edx, OFFSET mainSettingsOption
	push	edx
	mov		edx, OFFSET mainPlayOption
	push	edx

	do:
		pop		edx			; Get next string
		push	ebx			; Preserve previous XY position offsets
		call	strLength	; Get size of current string
		mov		bl, maxX	; Get max X of screen buffer
		sub		bl, al		; Subtract length of string
		shr		bl, 1		; Half remainder for X offset
		mov		al, bl		; Store in EAX

		pop		ebx			; Get previous XY position offsets
		push	edx			; Store current string to apply XY offsets
		mov		bl, al		; Set current X offset
		add		bh, mainMenuYInc	; Add Y increment to previous Y offset
		mov		edx, ebx	

		cmp		cl, mainMenuSelection
		jne		draw
		mov		ax, black + (white * 16)
		call	setTextColor		; Change text color to negative highlight

	draw:
		call	gotoXY		; Move to current XY offset
		pop		edx			; Get current string
	call	writeString
		mov		ax, defaultCursorColor
		call	setTextColor			; Reset text color

		inc		cl
		cmp		cl, mainMenuItems
		jl		do
		

	ret
drawMainMenu ENDP

; Procedure		: settingsMenuController
; Date Created	: 11.29.2013
; Last Updated	: 11.29.2013
; Authors		: Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Controller for the settings menu game state. Calls the
;		settings menu draw procedure and handles user input. Also tests for
;		game state change, returning to the game state controller.

settingsMenuStateController PROC USES edx
	call	drawSettingsMenu
	mov		gameState, 3		; Reset to menu state
	ret
settingsMenuStateController ENDP

; Procedure		: drawSettingsMenu
; Date Created	: 11.29.2013
; Last Updated	: 12.2.2013
; Authors		: Steven Fortier, Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Draws the settings menu to standard output.

drawSettingsMenu PROC
; Draw Menu Box
	mov		cl, mainMenuBoxXOne
	mov		bl, mainmenuBoxYOne
	mov		dh, bl
	mov		dl, cl

	printRow:
		call	gotoXY
		printColumn:
			edge:
				mov		al, '#'
				call	writeChar
				inc		dl
				jmp		next

			inner:
				mov		al, ' '
				call	writeChar
				inc		dl
				jmp		next

			checkYBorder:
				cmp		dh, mainMenuBoxYOne
				je		edge
				cmp		dh, mainMenuBoxYTwo
				je		edge
				jne		inner

			next:
				cmp		dl, mainMenuBoxXTwo
				jl		checkYBorder
				je		edge

		mov		dl, mainMenuBoxXOne
		inc		dh
		cmp		dh, mainMenuBoxYTwo
		jle		printRow

	mov dh, 17
	mov dl, 36
	call gotoxy
	mov edx, offset settingsMenuTitle
	call writestring
	
	mov dh, 19
	mov dl, 28
	call gotoxy
	mov edx, offset settingsMenuUp
	call writestring
	call readchar
	mov upChar, al

	mov dh, 21
	mov dl, 28
	call gotoxy
	mov edx, offset settingsMenuLeft
	call writestring
	call readchar
	mov leftChar, al

	mov dh, 23
	mov dl, 28
	call gotoxy
	mov edx, offset settingsMenuRight
	call writestring
	call readchar
	mov rightChar, al

	mov dh, 25
	mov dl, 28
	call gotoxy
	mov edx, offset settingsMenuDown
	call writestring
	call readchar
	mov downChar, al

	ret
drawSettingsMenu ENDP

; Procedure		: creditsScreen
; Date Created	: 11.29.2013
; Last Updated	: 12.2.2013
; Authors		: Steven Fortier, Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Draws the credits to the screen before returning back to the
;		game state controller, changing to the main menu game state. 

creditsScreen PROC USES edx
; Draw Menu Box
	mov		cl, mainMenuBoxXOne
	mov		bl, mainmenuBoxYOne
	mov		dh, bl
	mov		dl, cl

	printRow:
		call	gotoXY
		printColumn:
			edge:
				mov		al, '#'
				call	writeChar
				inc		dl
				jmp		next

			inner:
				mov		al, ' '
				call	writeChar
				inc		dl
				jmp		next

			checkYBorder:
				cmp		dh, mainMenuBoxYOne
				je		edge
				cmp		dh, mainMenuBoxYTwo
				je		edge
				jne		inner

			next:
				cmp		dl, mainMenuBoxXTwo
				jl		checkYBorder
				je		edge

		mov		dl, mainMenuBoxXOne
		inc		dh
		cmp		dh, mainMenuBoxYTwo
		jle		printRow

	mov		dh, 17
	mov		dl, 36
	call	gotoxy
	mov		edx, OFFSET creditsScreenTitle
	call	writeString

	mov		dh, 20
	mov		dl, 34
	call	gotoxy
	mov		edx, OFFSET creditsBryan
	call	writeString

	mov		dh, 22
	mov		dl, 33
	call	gotoxy
	mov		edx, OFFSET creditsSteven
	call	writeString

	mov		dh, 24
	mov		dl, 33
	call	gotoxy
	mov		edx, OFFSET creditsZach
	call	writeString

	mov		gameState, 3
	mov		eax, 3000
	call	delay
	ret
creditsScreen ENDP

; Procedure		: initPlayState
; Date Created	: 12.1.2013
; Last Updated	: 12.1.2013
; Authors		: Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Calls all first time procedures to initialize the game state

initPlayState PROC
	call	mapToFile
	call	initialSetup
	call	printMap
	call 	initGhost
	ret
initPlayState ENDP

; Procedure		: playStateController
; Date Created	: 12.1.2013
; Last Updated	: 12.1.2013
; Authors		: Bryan Young, Steven Fortier
; Inputs		: 
; Outputs		:
; Affected		: 
; Description	: Controller for the play game state. Manages a single game loop
;		for updates and rendering.

playStateController PROC
	cmp scoreToEnd, 0
	je RestartGame
	call	drawPacMan
	call	cherryCreator
	call	handleInput
	call 	ghostLogicLoop
	call	printMap
	Call    drawGhosts
	call	drawTitleBar
	mov eax,25
	Call Delay
	jmp eProc
RestartGame:
	call	initPlayState
	inc		level
eProc:
	ret
playStateController ENDP


; Procedure		: DrawPacMan
; Date Created	: 11.29.2013
; Last Updated	: 11.29.2013
; Authors		: Zach Thornton, Steven Fortier
; Inputs		: 
; Outputs		:
; Affected		: EAX EDX
; Description	: Draws PacMan to the screen, pseudo DB

DrawPacMan PROC USES EAX EDX
	cmp playerX, 0
	je CheckY
	cmp playerX, 26
	je CheckY
	jmp eProc

	CheckY:
		cmp playerY, 14
		je Teleporter
		jmp eProc
	Teleporter:
		call teleportPacMan
	eProc:
		Call DrawPacColor
		mov al,currentPacOrientation
		mov dl,playerX
		mov dh,playerY
		Call GotoXY
		Call WriteChar
	ret
DrawPacMan ENDP


; Procedure		: initialSetup
; Date Created	: 11.4.2013
; Last Updated	: 11.18.2013
; Authors		: Zach Thornton
; Inputs		: 
; Outputs		:
; Affected		: EAX, EDX
; Description	: initializes the x and y location of Pacman

initialSetup proc USES eax edx
	mov ghostX[0], 6
	mov ghostX[1], 10
	mov ghostX[2], 17
	mov ghostX[3], 20
	mov ghostY[0], 11
	mov ghostY[1], 11
	mov ghostY[2], 11
	mov ghostY[3], 11
	mov ghostLife[0], 1
	mov ghostLife[1], 1
	mov ghostLife[2], 1
	mov ghostLife[3], 1
	mov lives, 3
	mov playerX, 13
	mov playerY, 17
	mov dh,playerX
	mov dl,playerY
	mov scoreToEnd, 292
	Call GotoXY
	Call DrawPacColor
	mov al,'<'
	Call WriteChar
ret
initialSetup ENDP

; Procedure		: initGhost
; Date Created	: 11.4.2013
; Last Updated	: 11.18.2013
; Authors		: Zach Thornton
; Inputs		: 
; Outputs		:
; Affected		: EAX, EDX
; Description	: initializes a new ghost at screen location 20,20

initGhost PROC USES ecx edx eax 

		mov ebx,0
		mov ecx,4
	l2:
		mov dl,ghostX[bx]
		mov dh,ghostY[bx]

		Call GotoXY
		Call DrawGhostColor
		Mov al,'G'
		Call WriteChar
		inc ebx
	loop l2
	
ret
initGhost ENDP

; Procedure		: ghostLogicLoop
; Date Created	: 11.4.2013
; Last Updated	: 12.1.2013
; Authors		: Zach Thornton
; Inputs		: 
; Outputs		:
; Affected		: EBX ECX
; Description	: Contains the main loop for all ghost logic, ghost AI code is under GhostLogic

ghostLogicLoop PROC USES EBX ECX
	mov ecx,4
	mov ebx,0

	L1:
		mov dl,ghostX[bx]
		mov dh,ghostY[bx]
		Call GhostLogic
		inc bx
		inc iterations

		.IF iterations>=15
			ret
		.ENDIF
	loop L1

ret
ghostLogicLoop ENDP

drawGhosts PROC USES EAX EBX ECX
		mov ebx,0
		mov ecx,4
		mov iterations,0
	l2:
		cmp ghostLife[bx], 0
		je eProc
		mov dl,ghostX[bx]
		mov dh,ghostY[bx]

		cmp dl, 0
		je CheckY
		cmp dl, 26
		je CheckY
		jmp Next
	CheckY:
		cmp dh, 14
		je Teleporter
		jmp Next
	Teleporter:
		call teleportGhost
	Next:
		Call GotoXY
		Call DrawGhostColor
		Mov al,'G'
		Call WriteChar
	eProc:
		inc ebx

	loop l2

ret
drawGhosts ENDP

ghostLogic PROC USES eax ecx
		mov edi,0
		mov iterations,0
		Call CheckGhostCollision
		;Ghost is to the left of the player
		mov dl,ghostX[bx]
		mov dh,ghostY[bx]
		mov eax,3
		mov cl,currentGhostOrientation[bx]
			L1:
				inc iterations
				.IF iterations>=10
					ret
				.ENDIF
				.IF cl == 0
					inc dh
					inc ghostY[bx]
					mov currentGhostOrientation[bx],al
					Call CheckGhostCollision

					.IF edi==1
						dec dh
						dec ghostY[bx]
						JMP L2
					.ENDIF

				.ELSEIF cl == 1
					dec dh
					dec ghostY[bx]
					mov currentGhostOrientation[bx],al
					Call CheckGhostCollision
					.IF edi==1
						inc dh
						inc ghostY[bx]
						JMP L2
					.ENDIF

				.ELSEIF cl == 2
					inc dl
					inc ghostX[bx]
					mov currentGhostOrientation[bx],al
					Call CheckGhostCollision
					.IF edi==1
						dec dl
						dec ghostX[bx]
						JMP L2
					.ENDIF

				.ELSEIF cl == 3
					dec dl
					dec ghostX[bx]
					mov currentGhostOrientation[bx],al
					Call CheckGhostCollision
					.IF edi==1
						inc dl
						inc ghostX[bx]
						JMP l2
					.ENDIF
				.ENDIF
				.IF iterations>=15
							ret
					.ENDIF
				
				
				.IF edi==1
					L2:
						mov eax,3
						Call RandomRange
						inc iterations
						CMP al,cl
						JE L2
						mov edi,0
						mov cl,al
						jmp L1

					

				.ENDIF

				


		eProc:
			Call drawGhosts
			ret
ghostLogic ENDP

CheckGhostCollision PROC USES EAX EBX ECX EDX

	mov iterations,0
	cmp dl, playerX
	je CheckY
	jmp Skip
CheckY:
	cmp dh, playerY
	je KillPlayer
	jmp Skip
KillPlayer:
	cmp pelletMode, 0
	jg KillGhost
	Call playerDeath
	.IF lives <=0
		mov gamestate, 3
	.ENDIF
	jmp Skip

KillGhost: 
	mov ghostLife[bx], 0
	jmp eProc
Skip:
	mov currentSelectedGhost,bl
	mov ecx,27
	mov al,dh
	MUL cl
	mov bx,ax
	add bl,dl
	mov al,'X'
	mov ecx,4

	CMP al,mapdata[bx]
	JE CollisionOccurred
	.if iterations>15
				ret
	.endif
	JNE testGhostCollision


	CollisionOccurred:
		mov EDI,1
		ret

	testGhostCollision:

		mov ecx, 4
		mov ebx, 0
		inc iterations
		L3:
			inc iterations
			.IF currentSelectedGhost == bl
				JMP e
			.ENDIF

			.IF dl == ghostX[bx]
				.IF dh == ghostY[bx]
					mov EDI,1
					ret
				.ENDIF
			.ENDIF
		e:
			inc ebx
			.if iterations>15
				ret
			.endif
		loop L3

	eProc:

		ret
CheckGhostCollision ENDP

;dl=x dh=y


; Procedure		: checkScore
; Date Created	: 11.29.2013
; Last Updated	: 11.30.2013
; Authors		: Zach Thornton, Steven Fortier
; Inputs		: 
; Outputs		:
; Affected		: EAX EBX ECX EDX ESI
; Description	: Checks if pacman is eating a pellet, if yes remove pellet; 
;		increment score

checkScore PROC
	mov esi, offset mapData
	mov ecx,27
	mov dh,0
	mov al,playerY
	MUL cl
	mov bx,ax
	add bx,dx
	mov cl,'*'

	CMP cl,mapdata[bx]
	JE PelletCheck

	mov cl, 'o'
	CMP cl,mapdata[bx]
	JE LargePelletCheck

	mov cl, 'C'
	CMP cl, mapdata[bx]
	JE CherryCheck
	JNE exitp

	PelletCheck:
		Call IncrementScore
		dec scoreToEnd
		mov al,0h
		mov mapdata[bx],0h
		call WriteChar
		jmp exitp

	LargePelletCheck:
		Call IncrementScore
		dec scoreToEnd
		mov al,0h
		mov mapdata[bx],0h
		call WriteChar
		mov pelletMode, 20
		jmp exitp
	CherryCheck:
		add score, 100
		mov al, 0h
		mov mapdata[bx],0h
		call WriteChar
		mov cherryMode, 0
	exitp:
		mov dh,playerY


ret
checkScore ENDP

; Procedure		: checkBoundariesPositiveX
; Date Created	: 11.29.2013
; Last Updated	: 11.29.2013
; Authors		: Zach Thornton
; Inputs		: 
; Outputs		:
; Affected		: EAX EBX ECX EDX
; Description	: Handles Collisions for the player heading in the
; positive X direction

checkBoundariesPositiveX PROC USES EAX EBX ECX 
	mov esi, offset mapData
	mov ecx,27
	mov al,dh
	MUL cl
	mov bx,ax
	add bl,dl
	mov cl,'X'

	CMP cl,mapdata[bx]
	JE XCollision
	JNE exitp

	XCollision:
		dec dl
		dec playerX
		jmp exitp
	exitp:

ret
checkBoundariesPositiveX ENDP

; Procedure		: checkBoundariesNegativeX
; Date Created	: 11.29.2013
; Last Updated	: 11.29.2013
; Authors		: Zach Thornton
; Inputs		: 
; Outputs		:
; Affected		: EAX EBX ECX EDX
; Description	: Handles Collisions for the player heading in the
; negative X direction

checkBoundariesNegativeX PROC USES EAX EBX ECX
	mov ecx,27
	mov al,dh
	MUL cl
	mov bx,ax
	add bl,dl
	mov cl,'X'

	CMP cl,mapdata[bx]
	JE XCollision
	JNE exitp

	XCollision:
		inc dl
		inc playerX
		jmp exitp
	exitp:
ret
checkBoundariesNegativeX ENDP

; Procedure		: checkBoundariesPositiveY
; Date Created	: 11.29.2013
; Last Updated	: 11.29.2013
; Authors		: Zach Thornton
; Inputs		: 
; Outputs		:
; Affected		: EAX EBX ECX EDX
; Description	: Handles Collisions for the player heading in the
; positive Y direction(down)

checkBoundariesPositiveY PROC USES EAX EBX ECX 
	mov esi, offset mapData
	mov dh,0
	mov ecx,27
	movsx ax,playerY
	MUL cl
	mov bx,ax
	add bx,dx
	mov cx,'X'

	mov al,mapData[bx]

	CMP cl,al
	JE YCollision
	JNE exitp

	YCollision:
		dec playerY
		mov dh,playerY
		jmp exitp
	exitp:
		mov dh,playerY
	ret
checkBoundariesPositiveY ENDP

; Procedure		: checkBoundariesNegativeY
; Date Created	: 11.29.2013
; Last Updated	: 11.29.2013
; Authors		: Zach Thornton
; Inputs		: 
; Outputs		:
; Affected		: EAX EBX ECX EDX
; Description	: Handles Collisions for the player heading in the
; negative Y direction(up)

checkBoundariesNegativeY PROC USES EAX EBX ECX 
	mov esi, offset mapData
	mov dh,0
	mov ecx,27
	movsx ax,playerY
	MUL cl
	mov bx,ax
	add bx,dx
	mov cx,'X'

	mov al,mapData[bx]

	CMP cl,al
	JE YCollision
	JNE exitp

	YCollision:
		inc  playerY
		mov dh,playerY
		jmp exitp
	exitp:
		mov dh,playerY

ret
checkBoundariesNegativeY ENDP

; Procedure		: DrawPacColor
; Date Created	: 11.18.2013
; Last Updated	: 11.18.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX
; Description	: Sets Pacmans color to yellow

DrawPacColor PROC USES eax
	mov eax,yellow +(black*16)
	Call SetTextColor
	ret
DrawPacColor ENDP

; Procedure		: DrawGhostColor
; Date Created	: 11.18.2013
; Last Updated	: 11.18.2013
; Authors		: Zach Thornton, Steven Fortier
; Inputs		:
; Outputs		:
; Affected		: EAX
; Description	: Sets Ghost color to red

DrawGhostColor PROC USES eax
	mov al,ghostColor[bx]
	Call SetTextColor
	ret
DrawGhostColor ENDP

; Procedure		: HandleInput
; Date Created	: 11.4.2013
; Last Updated	: 11.29.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX, EDX
; Description	: Handles player input (key presses), Handles Pausing

HandleInput proc USES eax edx
	Start:
		call readChar
		dec pelletMode
		cmp pelletMode, 0
		jle setPelletMode
		jg NextStep
	setPelletMode:
		mov pelletMode, 0
	NextStep:
		cmp al,leftChar	;if(inp=='a') moveleft else checkright
		je MoveLeft
		jmp CheckRight
	
	CheckRight:
		cmp al,rightChar	;if(inp=='d') moveright else checkdown
		je MoveRight
		cmp al,downChar	;if(inp=='s') movedown else checkup
		je MoveDown
		cmp al,upChar	;if(inp=='w') moveup else exit
		je MoveUp
		cmp al,20h
		je Spacebar
		jmp Start	;So the ghosts don't move when other characters are pressed

	MoveDown:
		Call removePreviousPacMan

		inc dh
		inc playerY
		Call checkBoundariesPositiveY

		Call DrawPacColor
		Call GotoXY
		mov al,'^'	
		mov currentPacOrientation,'^'
		mov playerY,dh
		Call writechar
		jmp exitInp

	MoveUp:
		call removePreviousPacMan

		dec dh
		dec playerY
		Call CheckBoundariesNegativeY

		Call DrawPacColor
		Call GotoXY
		mov al,'V'
		mov currentPacOrientation,'V'
		mov playerY,dh
		Call WriteChar
		jmp exitInp

	MoveRight:
		Call removePreviousPacMan

		inc dl
		inc playerX
		Call checkBoundariesPositiveX

		Call DrawPacColor
		Call GotoXY
		mov al,'<'
		mov currentPacOrientation,'<'
		mov playerX,dl
		Call WriteChar
		jmp exitInp

	MoveLeft:
		Call removePreviousPacMan

		dec dl
		dec playerX
		Call CheckBoundariesNegativeX

		Call DrawPacColor
		Call GotoXY
		mov al,'>'
		mov currentPacOrientation,'>'
		mov playerX,dl

		Call WriteChar
		jmp exitInp

	Spacebar:
		CMP pauseChecker, 0
		jmp paused
		jmp unpaused

		paused:
			Call displayUnpause
			mov pauseChecker,1
			
			pauseLoop:
				
				Call ReadChar
				cmp al,20h
				je unpaused
				cmp al,1Bh
				je quit
				jmp pauseLoop
				
			unpaused:
				Call displayPause
				mov pausechecker,0
				jmp start
			quit:
				mov score, 0
				mov level, 1
				mov gamestate, 3

	exitInp:
		Call checkScore
		mov eax,lightGray+(black*16)
		Call SetTextColor
		
ret
HandleInput ENDP

; Procedure		: TeleportPacMan
; Date Created	: 11.30.2013
; Last Updated	: 11.30.2013
; Authors		: Steven Fortier
; Inputs		:
; Outputs		:
; Affected		: 
; Description	: Sends Pacman through the tunnel
teleportPacMan PROC
	cmp playerX, 0
	je TeleportToRight
	cmp playerX, 26
	je TeleportToLeft
	jmp eProc
TeleportToRight:
	mov playerX, 26
	mov playerY, 14
	jmp eProc
TeleportToLeft:
	mov playerX, 0
	mov playerY, 14
eProc:
	ret
teleportPacMan ENDP

; Procedure		: TeleportGhost
; Date Created	: 12.2.2013
; Last Updated	: 12.2.2013
; Authors		: Steven Fortier
; Inputs		:
; Outputs		:
; Affected		: 
; Description	: Sends Ghosts through the tunnel
teleportGhost PROC
	cmp GhostX[bx], 0
	je TeleportToRight
	cmp GhostX[bx], 26
	je TeleportToLeft
	jmp eProc
TeleportToRight:
	mov GhostX[bx], 26
	mov GhostY[bx], 14
	jmp eProc
TeleportToLeft:
	mov GhostX[bx], 0
	mov GhostY[bx], 14
eProc:
	ret
teleportGhost ENDP

; Procedure		: RemovePreviousPacMan
; Date Created	: 11.27.2013
; Last Updated	: 11.27.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX, EDX
; Description	: Removes Pacman from the screen
removePreviousPacMan PROC
		mov dh,playerY
		mov dl,playerX
		Call GotoXY
		mov al,0h
		Call WriteChar
ret
removePreviousPacMan ENDP

; Procedure		: removeGhost
; Date Created	: 11.27.2013
; Last Updated	: 11.27.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX, EDX
; Description	: Removes a Ghost from the screen
removeGhost PROC USES EDX
	mov dh,ghostY
	mov dl,ghostX
	Call GotoXY
	mov al,0h
	Call WriteChar
ret
removeGhost ENDP

; Procedure		: displayScore
; Date Created	: 11.4.2013
; Last Updated	: 11.6.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX, EDX
; Description	: Draws the player's current score to the screen
displayScore PROC USES eax edx
	mov eax,0
	mov dh,0
	mov dl,69

	Call GotoXy
	mov cl, level
	mov eax,score
	mov edx,offset scoreTitle
	Call WriteString
	Call WriteInt
ret
displayScore ENDP

; Procedure		: displayLives
; Date Created	: 11.4.2013
; Last Updated	: 11.6.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX, EDX
; Description	: Draws the player's current lives to the screen

displayLives PROC USES eax edx
	mov eax,0
	mov dh,1
	mov dl,69
	Call GotoXY

	mov al,lives
	mov edx,offset livesTitle
	Call WriteString
	Call WriteInt
ret
displayLives ENDP

; Procedure		: displayLevel
; Date Created	: 12.1.2013
; Last Updated	: 12.1.2013
; Authors		: Steven Fortier
; Inputs		:
; Outputs		:
; Affected		: EAX, EDX
; Description	:
displayLevel PROC USES eax edx
	mov eax, 0
	mov dh, 2
	mov dl, 69
	call gotoxy
	mov al, level
	mov edx, offset levelName
	call writestring
	call writeint
	ret
displayLevel ENDP

; Procedure		: displayPacCoordinates
; Date Created	: 11.4.2013
; Last Updated	: 11.6.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX, EDX
; Description	:

displayPacCoordinates PROC
	mov eax,0
	mov dh,5
	mov dl,69
	Call GotoXY

	mov al,playerX
	Call WriteDec
	mov al,20h
	Call WriteChar
	mov al,playerY
	Call WriteDec
	mov dh,6
	Call GotoXY
	mov al,mapData[781]
	Call WriteChar
ret
displayPacCoordinates ENDP

; Procedure		: cherryCreator
; Date Created	: 12.1.2013
; Last Updated	: 12.1.2013
; Authors		: Steven Fortier
; Inputs		:
; Outputs		:
; Affected		: EAX
; Description	:
cherryCreator PROC USES eax
	cmp cherryMode, 0
	jle RandomCherry
	jmp SpawnCherry
RandomCherry:
	mov cherryMode, 0
	mov mapData[472], ' '
	mov eax, 1000
	call randomrange
	cmp eax, 1
	jle CreateCherry
	jmp eProc
CreateCherry:
	mov cherryMode, 20
	jmp spawnCherry
SpawnCherry:
	dec cherryMode
	mov mapData[472], 'C'
eProc:
	ret
cherryCreator ENDP

; Procedure		: drawTitleBar
; Date Created	: 11.6.2013
; Last Updated	: 11.27.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX, ECX, EDX
; Description	: Draws the title bar boundaries and contents to the screen

drawTitleBar PROC USES eax ecx edx

	mov eax,green +(black*16)
	Call SetTextColor


	Call displayLives
	Call displayScore
	Call displayLevel
	Call displayPause
	;Call displayPacCoordinates
ret
drawTitleBar ENDP

; Procedure		: displayPause
; Date Created	: 11.27.2013
; Last Updated	: 11.27.2013
; Authors		: Zach Thornton, Steven Fortier
; Inputs		:
; Outputs		:
; Affected		: EDX
; Description	: Displays the pause string

displayPause PROC
	mov dh,20
	mov dl,55
	Call GotoXY

	mov edx,offset pauseStr1
	Call WriteString
	mov dh, 21
	mov dl, 55
	call gotoxy
	mov edx,offset escapeStr1
	Call WriteString
ret
displayPause ENDP

; Procedure		: displayUnpause
; Date Created	: 11.27.2013
; Last Updated	: 11.27.2013
; Authors		: Zach Thornton, Steven Fortier
; Inputs		:
; Outputs		:
; Affected		: EDX
; Description	: Displays the unpause string

displayUnpause PROC
	mov dh,20
	mov dl,55
	Call GotoXY

	mov edx,offset pauseStr2
	Call WriteString
	mov dh, 21
	mov dl, 55
	call gotoxy
	mov edx,offset escapeStr2
	Call WriteString
ret
displayUnpause ENDP

; Procedure		: IncrementScore
; Date Created	: 11.4.2013
; Last Updated	: 11.6.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: 
; Description	: Wapper for inc, for score

IncrementScore PROC
	inc score
	ret
IncrementScore ENDP

; Procedure		: playerDeath
; Date Created	: 11.4.2013
; Last Updated	: 11.6.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: 
; Description	: wrapper for inc, for lives

playerDeath PROC
	dec lives

	.IF lives<=0
		mov gamestate, 3
	.ENDIF
	ret
playerDeath ENDP

; Procedure		: mapToFile
; Date Created	: 11.6.2013
; Last Updated	: 11.6.2013
; Authors		: Textbook
; Inputs		:
; Outputs		:
; Affected		: EAX, ECX, EDX
; Description	: Reads map.txt to generate a map
mapToFile PROC USES eax ecx edx
	mov edx, offset filename
	call openinputfile
	mov filehandle, eax

	cmp eax, INVALID_HANDLE_VALUE	;Error when opening?
	jne file_ok

	jmp quit

file_ok:
	mov edx, offset mapData
	mov ecx, buffer_size
	call readfromfile

	jnc check_buffer_size			;Error reading file?

	jmp close_file

check_buffer_size:
	mov mapDataBufferSize,ax
	cmp eax, buffer_size			;Buffer large enough?
	jb buf_size_ok
	jmp quit

buf_size_ok:
	mov dh,0
	mov dl,0
	Call GotoXY
	mov mapData[eax], 0

close_file:
	mov eax, filehandle
	call closefile
quit:

	ret
mapToFile ENDP

; Procedure		: PrintMap
; Date Created	: 11.15.2013
; Last Updated	: 11.27.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EDX
; Description	: Sets proper position for map, then calls the display method
PrintMap PROC USES EDX
	mov dh,0
	mov dl,0
	Call GotoXY
	Call displayMap
	ret
PrintMap ENDP

; Procedure		: displayMap
; Date Created	: 11.25.2013
; Last Updated	: 11.27.2013
; Authors		: Zach Thornton, Steven Fortier
; Inputs		:
; Outputs		:
; Affected		: EAX EBX ECX EDX
; Description	: Scans through the array, then sets the color for each 
;		map character

displayMap PROC USES EAX EBX ECX EDX
	mov ecx, 31
	mov edx,offset mapData
	mov eax,0b
	mov ebx,0
	mov esi,0
		L1:
				push ecx
				mov ecx,27
				MainLoop:
					mov bl, mapData[esi]
					cmp bl, 'X'
					je printX
					cmp bl, 'C'
					je printCherry
					mov eax, 14
					call settextcolor
					jmp Printer
				printX:
					cmp pelletMode, 0
					jg printXGhost
					mov eax, 9
					call settextcolor
					jmp Printer
				printXGhost:
					mov eax, 15
					call settextcolor
					jmp Printer
				printCherry:
					mov eax, 2
					call settextcolor
				Printer:
					mov ax, bx
					call writechar
				
					inc edx
					inc esi
				loop MainLoop
				Call Crlf
				pop ecx
				
		loop L1

	ret
displayMap endp

;-----------------------------------------------------------------------------;
;                              Utility Procedures							  ;
;-----------------------------------------------------------------------------;

; Procedure		: ClearRegs
; Date Created	: 11.4.2013
; Last Updated	: 11.29.2013
; Authors		: Zach Thornton
;				: Bryan Young
; Inputs		: 
; Outputs		:
; Affected		: EAX, EBX, ECX, EDX, ESI, EDI
; Description	: Resets registers to 0
ClearRegs proc
	xor		eax, eax
	xor		ebx, ebx
	xor		ecx, ecx
	xor		edx, edx
	xor		esi, esi
	xor		edi, edi

ret
ClearRegs ENDP

; Procedure		: printBufferCol
; Date Created	: 12.2.2013
; Last Updated	: 12.2.2013
; Authors		: Bryan Young
; Inputs		: BH  - # of rows in buffer (max Y)
;				: BL  - # of cols in buffer (max X)
;				: CL  - Index (offset from row start)
;				: DH  - Screen Y location
;				: DL  - Screen X location
;				: ESI - Start index of the buffer
; Outputs		:
; Affected		: 
; Description	: Prints a single column of a buffer given buffer length and
;		line length value for line breaks
printBufferCol PROC USES ebx ecx edx esi
	movzx	eax, cl
	add		esi, eax
do:
	mov		al, [esi]
	call	writeChar
	inc		dh
	call	gotoXY
	movzx	eax, bl
	add		esi, eax
	dec		bh
	cmp		bh, 0
	jg		do
	
	ret
printBufferCol ENDP

; Procedure		: printBlankCol
; Date Created	: 12.2.2013
; Last Updated	: 12.2.2013
; Authors		: Bryan Young
; Inputs		:
; Outputs		:
; Affected		: 
; Description	: Prints a column of whitespace characters

printBlankCol PROC USES ebx ecx edx esi
	mov		al, ' '
do:
	call	writeChar
	inc		dh
	call	gotoXY
	dec		bh
	cmp		bh, 0
	jg		do

	ret
printBlankCol ENDP

; Procedure		: loadBufferFromFile
; Date Created	: 12.1.2013
; Last Updated	: 12.1.2013
; Authors		: Bryan Young
; Inputs		: EBX - OFFSET of buffer to fill
;				: ECX - Max bytes to read (LENGTHOF buffer)
;				: EDX - OFFSET of filename to open
; Outputs		: EAX - Returns the number of bytes read into the buffer
; Affected		: 
; Description	: Takes a file name, buffer, and the size limit of the buffer. 
;		Opens the file and reads the data within the limit) into the given buffer. 
;		Returns the	number of bytes read from the file and written to the buffer.

loadBufferFromFile PROC USES ebx ecx edx
	push	ecx
	call	openInputFile
	pop		ecx
	push	eax
	cmp		eax, INVALID_HANDLE_VALUE
	je		error

	mov		edx, ebx
	call	readFromFile
	jc		sysError

	mov		ecx, eax
	pop		eax
	push	ecx
	call	closeFile
	jmp		done

sysError:
	call	writeWindowsMsg
	exit

error:
	mov		ebx, OFFSET errorMessage
	mov		edx, OFFSET fileLoadErrorMsg
	call	msgBox
	exit

done:
	pop		eax
	ret
loadBufferFromFile ENDP

;-----------------------------------------------------------------------------;
;                               Debug Procedures							  ;
;-----------------------------------------------------------------------------;

; Procedure		: printEnvironmentVariables
; Date Created	: 11.30.2013
; Last Updated	: 11.30.2013
; Authors		: Bryan Young
; Inputs		:
; Outputs		:
; Affected		: 
; Description	: Prints environment variables, waits 30 seconds
;	Variables Printed:
;			mainMenuBoxXOne			mainMenuBoxYOne
;			mainMenuBoxXTwo			mainMenuBoxYTwo
printEnvironmentVariables PROC USES eax edx
	xor		eax, eax
	mov		edx, OFFSET displayMainMenuBox
	push	edx
	call	writeString
	mov		edx, OFFSET displayMainMenuBoxXOne
	call	writeString
	mov		al, mainMenuBoxXOne
	call	writeInt
	call	crlf
	pop		edx
	push	edx
	call	writeString
	mov		edx, OFFSET displayMainMenuBoxYOne
	call	writeString
	mov		al, mainMenuBoxYOne
	call	writeInt
	call	crlf
	pop		edx
	push	edx
	call	writeString
	mov		edx, OFFSET displayMainMenuBoxXTwo
	call	writeString
	mov		al, mainMenuBoxXTwo
	call	writeInt
	call	crlf
	pop		edx
	push	edx
	call	writeString
	mov		edx, OFFSET displayMainMenuBoxYTwo
	call	writeString
	mov		al, mainMenuBoxYTwo
	call	writeInt
	call	crlf
	pop		edx
	call	writeString
	mov		edx, OFFSET displayMainMenuYInc
	call	writeString
	mov		al, mainMenuYInc
	call	writeInt

	mov		eax, 30000
	call	delay
	ret
printEnvironmentVariables ENDP

; Procedure		: debugCollision
; Date Created	: 11.4.2013
; Last Updated	: 11.6.2013
; Authors		: Zach Thornton
; Inputs		:
; Outputs		:
; Affected		: EAX, EDX
; Description	:

DebugCollision PROC USES EDX
	mov dl,69
	mov dh,6
	Call GotoXY
	mov al,mapdata[bx]
	Call WriteChar

	mov dh,50
	Call GotoXY
	Call DumpRegs

ret
DebugCollision ENDP

; Procedure		: debugSandbox
; Date Created	: 12.1.2013
; Last Updated	: 12.1.2013
; Authors		: Bryan Young
; Inputs		:
; Outputs		:
; Affected		: 
; Description	:
debugSandbox PROC USES eax ebx ecx edx esi edi

	mov		ecx, eax
	mov		esi, OFFSET	splashScreenBuffer
	xor		eax, eax
do:
	mov		al, [esi]
	call	writeChar
	inc		esi
	dec		ecx
	cmp		ecx, 0
	jge		do

	exit
	ret
debugSandbox ENDP

END main