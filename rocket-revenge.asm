%include "/usr/local/share/csc314/asm_io.inc"

%define TICK 100000 ; 1/10th of a second

; the file that stores the initial state
%define BOARD_FILE 'board.txt'

; how to represent everything
%define WALL_CHAR '#'
%define PLAYER_CHAR '0'
%define TEAM_ROCKET 176
%define CANDY_CHAR '^'
%define GRASS '*'
%define EMPTY_CHAR ' '

; the size of the game screen in characters
%define HEIGHT 40
%define WIDTH 100

; the player starting position.
; top left is considered (0,0)
%define STARTX 1
%define STARTY 1

; these keys do things
%define EXITCHAR 'x'
%define UPCHAR 'w'
%define LEFTCHAR 'a'
%define DOWNCHAR 's'
%define RIGHTCHAR 'd'
%define TACKLE	't'
%define THUNDERBOLT 'b'
%define	RUN 'r'

segment .data

	; used to fopen() the board file defined above
	board_file			db BOARD_FILE,0

	; used to change the terminal mode
	mode_r				db "r",0
	raw_mode_on_cmd		db "stty raw -echo",0
	raw_mode_off_cmd	db "stty -raw echo",0

	; called by system() to clear/refresh the screen
	clear_screen_cmd	db "clear",0

	; things the program will print
	intro_str			db 13,10,"Help! a TEAM ROCKET GRUNT stole all of the RARE CANDY and hid it in the grass!",13,10,10,0
	help_str			db 13,10,"Controls: ", \
							UPCHAR,"=UP / ", \
							LEFTCHAR,"=LEFT / ", \
							DOWNCHAR,"=DOWN / ", \
							RIGHTCHAR,"=RIGHT / ", \
							EXITCHAR,"=EXIT", \
							13,10,10,0

	candy_fmt			db 'Rare Candy Needed: %d',13,10,10,0
	encounter_fmt		db 'Total Pokemon Encounters: %d',13,10,10,0


	battle_str			db 'Oh no! You encountered a wild MAGIKARP!',13,10,0
	battle_fmt			db 'MAGIKARP health: %d',13,10,10,0
	magikarp_art		db	"                                        -/s.                                    ",13,10, \
							"                                      `+:`+-                                    ",13,10, \
							"                          `          //```/-                                    ",13,10, \
							"                          s//      .o-````:/                                    ",13,10, \
							"                          y..o.   /+``````:o                                    ",13,10, \
							"                          +:``+/`o:..`````/:                                    ",13,10, \
							"                          .o...:y-..```...o-                                    ",13,10, \
							"                           s...---........o+//////o                             ",13,10, \
							"                          .s:.............-...../o`                             ",13,10, \
							"                        :s+/++-..............-/y:                               ",13,10, \
							"                .::/+oo+o+///+ho++++/-..---:/s/                                 ",13,10, \
							"            ./+o+/::::::::////+s////+sooo/+s/                                   ",13,10, \
							"          //:..:::::::://+++++/yoo++o/::/oy/`                                   ",13,10, \
							"        :s/-.-::::///:/+//++++++y/+so::---:/so.                                 ",13,10, \
							"       s+:::::::+-`    `/o//////y///+s++//:/:/oo.                               ",13,10, \
							"    `:os///////o`   `    ++/////y+///oo++//////+h:                              ",13,10, \
							"   `y.../o+////o         .o/////os//oo++++//////sos`            `:/++ooyyhh+    ",13,10, \
							"     -ys:.o////o.        ++///++sdsshsoooooooooosooy.       `/oyyso++/:-:o      ",13,10, \
							"      .dy.:o////+/:.` `-/+/+oo+++++++++++//////+sooyy`   -+yysso/:-.``` +.      ",13,10, \
							"       hy/-s//++o/++o++//+o+++/.``      `````:++ososss`+yysyo/-.``      s       ",13,10, \
							"       ydo.s/+o-./o++//os++o:`.--........`.+o/++yyssshdssyo-.```..-----/:       ",13,10, \
							"     .sho/.s+//+o/.o+++y+ys:--.         .+o/++oohsssssyys:--....``    -+        ",13,10, \
							"    `yy::.+s/++//oo-s++++h/--..`       /o++ooooohoooosh+.           `/:         ",13,10, \
							"    -yhoyshsoo++++oo:s++/+o/- `...`   +oooooooohsooooy+`          `::           ",13,10, \
							"    -yy :yssysooooos-soooooooso:`    `yoooooossyoooooh.          -+.            ",13,10, \
							"    -hh` `+yossysosy-osssssssshyyo:` .yssssssshssssyy//`        `o              ",13,10, \
							"     yos   `/ssosyyh:/ysssssyyssshss+-yssssssyosysdsy- :`       /.              ",13,10, \
							"     .ys/     .+sssy//yyyyhhsssyyyssssyssssyhyo/` sys/  -.      o               ",13,10, \
							"      -ys-        .s/+hhydhhyyyssssssyyysoo/.     .hsy`  .-`    s               ",13,10, \
							"       .yh-        .+:msssssyyyyyyyhy:             /yso    .-`  y               ",13,10, \
							"        `yh.       `s-o//+++ooooooo++so`            oyy/     --+:               ",13,10, \
							"         .hy.      -y/:o///////////::::o-            oss-    `::                ",13,10, \
							"          :yy`    .yoy:++//++//:::---...//            +oo: `::`                 ",13,10, \
							"           so+    -/``s-+/s:/o:----+/:-..-+.           :yooo`                   ",13,10, \
							"           -so        .s-o/   +o--/:`-:///+h`            /os                    ",13,10, \
							"           .sy`        `s:+:   `s+o                                             ",13,10, \
							"           :++           /+:+-   ``                                             ",13,10, \
							"          .s+             `:/:/:`                                               ",13,10, \
							"          `.                `/////:.                                            ",13,10, \
							"                               ./::/ooo                                         ",13,10,10,0


	poke1				db "PIKACHU",13,0
	poke2				db "MAGIKARP",13,0

	wait_text			db "What will you do?",13,10," t = TACKLE | b = THUNDERBOLT | r = RUN AWAY",13,10,0
	attack1				db "PIKACHU used TACKLE",13,10,0
	attack2				db "PIKACHU used THUNDERBOLT!",13,10,0
	attack3				db "You tried to flee!",13,10,0
	attack4				db "MAGIKARP used splash...",13,10,0

	result1				db "But nothing happened...",13,10,0
	result2				db "It's SUPER effective!",13,10,0
	result3				db "PIKACHU's attack missed!",13,10,0
	result4				db "You couldn't escape!",13,10,0
	result5				db "Congratulations! The wild MAGIKARP has fainted!",13,10,0
	result6				db	"You got away safely!",13,10,0


	text_box			db "____________________________________________________________________________",13,10,10, \
							" %s",13, \
							"___________________________________________________________________________",13,10,10,0

	pokemon_logo		db	"                                    ,'\",13,10, \
							"        _.----.        ____         ,'  _\   ___    ___     ____",13,10, \
							"    _,-'       `.     |    |  /`.   \,-'    |   \  /   |   |    \  |`.     ",13,10, \
							"    \      __    \    '-.  | /   `.  ___    |    \/    |   '-.   \ |  |    ",13,10, \
							"     \.    \ \   |  __  |  |/    ,','_  `.  |          | __  |    \|  |    ",13,10, \
							"       \    \/   /,' _`.|      ,' / / / /   |          ,' _`.|     |  |    ",13,10, \
							"        \     ,-'/  /   \    ,'   | \/ / ,`.|         /  /   \  |     |    ",13,10, \
							"         \    \ |   \_/  |   `-.  \    `'  /|  |    ||   \_/  | |\    |    ",13,10, \
							"          \    \ \      /       `-.`.___,-' |  |\  /| \      /  | |   |    ",13,10, \
							"           \    \ `.__,'|  |`-._    `|      |__| \/ |  `.__,'|  | |   |    ",13,10, \
							"            \_.-'       |__|    `-._ |              '-.|     '-.| |   |    ",13,10, \
							"                                    `'                            '-._|    ",13,10, \
							"___________________________________________________________________________",13,10, \
							"                      _______ _______ _______ _______                      ",13,10, \
							"                         |    |______ |_____| |  |  |                      ",13,10, \
							"                         |    |______ |     | |  |  |                      ",13,10, \
							"     ____ ____ ____ _  _ ____ ___   ____ ____ _  _ ____ _  _ ____ ____     ",13,10, \
							"     |__/ |  | |    |_/  |___  |    |__/ |___ |  | |___ |\ | | __ |___     ",13,10, \
							"     |  \ |__| |___ | \_ |___  |    |  \ |___  \/  |___ | \| |__] |___     ",13,10,10, \
							"                          ",27,"[5m[PRESS ANY KEY TO BEGIN]",27,"[0m",13,10,10,0

	oak_face			db	"                        `+-                                                     ",13,10, \
							"                         -s+//.                                                 ",13,10, \
							"                    `..-::/y-.///-                           ",27,"[100m Professor Oak ",27,"[0m      ",13,10, \
							"                  os/:-..........-+///:.`                                       ",13,10, \
							"                 `./h+................-://////:-.`                              ",13,10, \
							"               ./yds/...........................-::/::---`                      ",13,10, \
							"            .::://-.....................................-/:-                    ",13,10, \
							"        `o//-..............................................-/.                  ",13,10, \
							"         :y-................................................./+                 ",13,10, \
							"          sy-..........//////:..................:///:/........:s                ",13,10, \
							"        .` /+........./o......::::::/...-///://:-.`...s+.....-.-+               ",13,10, \
							"        `sh+oy-......-s...`````````.o/.hh-..```````.../+s:..+ys/+-              ",13,10, \
							"         `-s+.-......y-..```````````.s-s-s..```````...://o+/yyyyyy              ",13,10, \
							"         +m+/-.......y`.````````````..oy....````````..:///shyyyyym              ",13,10, \
							"          `++.......-h`.``````````````.:`..````````...:///+dyyyyym`             ",13,10, \
							"            -s-......h`.`````````````````````````````.-///odyyyyym.             ",13,10, \
							"              ++.....y...oo-.....``````````````..``..:////sdyyyyym.             ",13,10, \
							"               .s+:-:h.oNMMMmo...```````````````.-odMMMds/sdhhhhhN`             ",13,10, \
							"                 os/.dmMMMMMMMNy-....`.`o......+dMMMMMMMMdhdhhhhhN`             ",13,10, \
							"                :o:+od.-/smNMMMMMy:.-+.`h....oNMMMMNhhyo///smddhym`             ",13,10, \
							"               /+.--.h`.`.o `-/yMNMh:s``y..oNMMddh`   s////omh--/+y.            ",13,10, \
							"              .o.:o+sd`.`:+  | +h`:/oo..:+oo/::.yy  | o////ym/oss/+h            ",13,10, \
							"              ++../oyd`..:o  | +y`..````.......`y+  | s////d+sh////d`           ",13,10, \
							"              :+...s+h``o++:::://:/-```````..-/-:----/o+/////+do//+h            ",13,10, \
							"               +/..`oh...::....:/:......```...:+o/...`/o/////+hs/+o`            ",13,10, \
							"                -+/.-s..````.`..```...y``````..``..``...:/+ysm+/o:              ",13,10, \
							"                  ./y+.`````````````:dh.``````````````..///d++oo`               ",13,10, \
							"                    s-``````````````.od/:-````````````..///No:.                 ",13,10, \
							"                    d.``````````.``...---....`````````.-///d                    ",13,10, \
							"                    -o/..``````.:oo+++//////+++++.```.:///s/                    ",13,10, \
							"                      .+o:..````....`.........`..``.://os/`                     ",13,10, \
							"                         -++:....``.:+ooooo+-.....-/+yo.                        ",13,10, \
							"                           .yhs-`.`....-:-......-/shd`                          ",13,10, \
							"                         :yhssNoo/...```.```..-+ss/sNd:                         ",13,10, \
							"                     `-o+oysssm.-/so+++++++++oss///hNmNs//-                     ",13,10, \
							"                 .-::+s`oyssssd....:///////////////hNmmm--o////-`               ",13,10, \
							"           `----.   .o`yysssssd..``..:////////::::odhhhyh`.+   .:///:`          ",13,10, \
							"      `::::.       .o`yysssssyd..`````.----......oysssssyy`.o       `:///:.     ",13,10, \
							" `-///-`          .o.hysssssssyo.....``````..../yysssssssys .s           `-////-",13,10, \
							"/o.              .o.hyssssssssssyo-.````````.-syssssssssssyo -o                .",13,10, \
							"________________________________________________________________________________",13,10,10, \
							" %s",13,10, \
							"________________________________________________________________________________",13,10,10,0


	opentext1			db	"Welcome to the world of Pokemon! But alas we have no time for that!",13,10,0
	opentext2			db	"Team Rocket has stolen ALL of the RARE CANDY and hid it in the tall grass!",13,10,0
	opentext3			db	"Use WASD to move! Look for ^ (RARE CANDY) and try to avoid fighting too...",13,10,0
	opentext4			db	"...many Pokemon, they are usually hiding in the * (TALL GRASS)!",13,10,0
	opentext5			db	"This is you ->0<- Good luck! You're adventure awaits!",13,10,0

	closetext1			db	"Congratulations! You got enough of the stolen RARE CANDY!",13,10,0
	closetext2			db	"There will always be rare candy to find! Why don't you go outside and en...",13,10,0
	closetext3			db	"...joy the weather!",13,10,0



segment .bss

	; this array stores the current rendered gameboard (HxW)
	board	resb	(HEIGHT * WIDTH)

	; these variables store the current player position
	xpos	resd	1
	ypos	resd	1

	;Team Rocket
	grt1x	resd	1
	grt1y	resd	1

	;keep track of candy
	candy_count	resd	1

	encounter_count	resd	1
	magikarp_health	resd	1

	;battle stuff
	loaded_str	resd	0

segment .text

	global	asm_main
	extern	system
	extern	putchar
	extern	getchar
	extern	printf
	extern	fopen
	extern	fread
	extern	fgetc
	extern	fclose
	extern	rand
	extern	time
	extern	srand
	extern	usleep
	extern	fcntl

asm_main:
	enter	0,0
	pusha
	;***************CODE STARTS HERE***************************
	; srand(time(NULL))
	push	0
	call	time
	add		esp, 4

	push	eax
	call	srand
	add		esp, 4

	; put the terminal in raw mode so the game works nicely
	call	raw_mode_on

	; read the game board file into the global variable
	call	init_board

	; eax = rand()
	wall_check:
		;Set x
		call	rand
		cdq
		mov		ebx, WIDTH
		idiv	ebx
		mov		DWORD [xpos], edx

		;Set y
		call	rand
		cdq
		mov		ebx, HEIGHT
		idiv	ebx
		mov		DWORD [ypos], edx

	mov		eax, WIDTH
	mul		DWORD [ypos]
	add		eax, [xpos]
	lea		eax, [board + eax]
	cmp		BYTE [eax], WALL_CHAR
	je		wall_check

	;set grunts position
	mov		DWORD [grt1x], 5
	mov		DWORD [grt1y], 5

	; set the player at the proper start position
	;mov		DWORD [xpos], STARTX
	;mov		DWORD [ypos], STARTY
	mov		DWORD [candy_count], 10
	mov		DWORD [encounter_count], 0
	mov		DWORD [magikarp_health], 100



	;PRINT THE LOADING SCREEN
	call	do_loading_thing


	; the game happens in this loop
	; the steps are...
	;   1. render (draw) the current board
	;   2. get a character from the user
	;	3. store current xpos,ypos in esi,edi
	;	4. update xpos,ypos based on character from user
	;	5. check what's in the buffer (board) at new xpos,ypos
	;	6. if it's a wall, reset xpos,ypos to saved esi,edi
	;	7. otherwise, just continue! (xpos,ypos are ok)
	game_loop:

		push	TICK
		call	usleep
		add		esp, 4

		; draw the game board
		call	render


		;Test to see if all rare candy is gone
		mov		eax, DWORD [candy_count]
		cmp		eax, 0
		jg		not_enough_candy
			call	end_screen
			jmp		game_loop_end
		not_enough_candy:

		; get an action from the user
		;call	nonblocking_getchar
		bad_input_mn:
		call	getchar

		; store the current position
		; we will test if the new position is legal
		; if not, we will restore these
		mov		esi, [xpos]
		mov		edi, [ypos]

		; choose what to do
		cmp		eax, EXITCHAR
		je		game_loop_end
		cmp		eax, UPCHAR
		je 		move_up
		cmp		eax, LEFTCHAR
		je		move_left
		cmp		eax, DOWNCHAR
		je		move_down
		cmp		eax, RIGHTCHAR
		je		move_right
		jmp		bad_input_mn			; force good input before screen update

		; move the player according to the input character
		move_up:
			dec		DWORD [ypos]
			jmp		input_end
		move_left:
			dec		DWORD [xpos]
			jmp		input_end
		move_down:
			inc		DWORD [ypos]
			jmp		input_end
		move_right:
			inc		DWORD [xpos]
		input_end:

		; (W * y) + x = pos

		; compare the current position to the wall character
		mov		eax, WIDTH
		mul		DWORD [ypos]
		add		eax, [xpos]
		lea		eax, [board + eax]
		cmp		BYTE [eax], WALL_CHAR
		jne		valid_move
			; opps, that was an invalid move, reset
			mov		DWORD [xpos], esi
			mov		DWORD [ypos], edi
		valid_move:

		;check for candy
		cmp BYTE [eax], CANDY_CHAR
		jne	not_candy
			dec	DWORD [candy_count]
			mov	BYTE [eax], EMPTY_CHAR
		not_candy:


		;Check for Grass
		cmp BYTE [eax], GRASS
		jne	not_grass
			;There is a 1 out of 7 chance for an encounter
			call	rand
			cdq
			mov		ebx, 7
			idiv	ebx
			cmp		edx, 1
			jne		not_grass
				inc	DWORD [encounter_count]
				call battle_screen
		not_grass:

	jmp		game_loop
		; run the battle board
		call	battle_screen

		; get an action from the user
		;call	nonblocking_getchar
		call	getchar

	jmp		game_loop
	game_loop_end:

	; restore old terminal functionality
	call raw_mode_off

	;***************CODE ENDS HERE*****************************
	popa
	mov		eax, 0
	leave
	ret

; === FUNCTION ===
raw_mode_on:

	push	ebp
	mov		ebp, esp

	push	raw_mode_on_cmd
	call	system
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; === FUNCTION ===
raw_mode_off:

	push	ebp
	mov		ebp, esp

	push	raw_mode_off_cmd
	call	system
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; === FUNCTION ===
init_board:

	push	ebp
	mov		ebp, esp

	; FILE* and loop counter
	; ebp-4, ebp-8
	sub		esp, 8

	; open the file
	push	mode_r
	push	board_file
	call	fopen
	add		esp, 8
	mov		DWORD [ebp-4], eax

	; read the file data into the global buffer
	; line-by-line so we can ignore the newline characters
	mov		DWORD [ebp-8], 0
	read_loop:
	cmp		DWORD [ebp-8], HEIGHT
	je		read_loop_end

		; find the offset (WIDTH * counter)
		mov		eax, WIDTH
		mul		DWORD [ebp-8]
		lea		ebx, [board + eax]

		; read the bytes into the buffer
		push	DWORD [ebp-4]
		push	WIDTH
		push	1
		push	ebx
		call	fread
		add		esp, 16

		; slurp up the newline
		push	DWORD [ebp-4]
		call	fgetc
		add		esp, 4

	inc		DWORD [ebp-8]
	jmp		read_loop
	read_loop_end:

	; close the open file handle
	push	DWORD [ebp-4]
	call	fclose
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; === FUNCTION ===
render:

	push	ebp
	mov		ebp, esp

	; two ints, for two loop counters
	; ebp-4, ebp-8
	sub		esp, 8

	; clear the screen
	push	clear_screen_cmd
	call	system
	add		esp, 4

	; print the help information
	push	intro_str
	call	printf
	add		esp, 4

	; print the help information
	push	help_str
	call	printf
	add		esp, 4


	;print how much candy we have
	push	DWORD [candy_count]
	push	candy_fmt
	call	printf
	add	esp,8

	;print how much candy we have
	push	DWORD [encounter_count]
	push	encounter_fmt
	call	printf
	add	esp,8


	; outside loop by height
	; i.e. for(c=0; c<height; c++)
	mov		DWORD [ebp-4], 0
	y_loop_start:
	cmp		DWORD [ebp-4], HEIGHT
	je		y_loop_end

		; inside loop by width
		; i.e. for(c=0; c<width; c++)
		mov		DWORD [ebp-8], 0
		x_loop_start:
		cmp		DWORD [ebp-8], WIDTH
		je 		x_loop_end

			; check if (xpos,ypos)=(x,y)
			mov		eax, [xpos]
			cmp		eax, DWORD [ebp-8]
			jne		print_board
			mov		eax, [ypos]
			cmp		eax, DWORD [ebp-4]
			jne		print_board
				; if both were equal, print the player
				push	PLAYER_CHAR
				jmp		print_end
			print_board:
				; otherwise print whatever's in the buffer
				mov		eax, [ebp-4]
				mov		ebx, WIDTH
				mul		ebx
				add		eax, [ebp-8]
				mov		ebx, 0
				mov		bl, BYTE [board + eax]
				push	ebx
			print_end:
			call	putchar
			add		esp, 4

		inc		DWORD [ebp-8]
		jmp		x_loop_start
		x_loop_end:

		; write a carriage return (necessary when in raw mode)
		push	0x0d
		call 	putchar
		add		esp, 4

		; write a newline
		push	0x0a
		call	putchar
		add		esp, 4

	inc		DWORD [ebp-4]
	jmp		y_loop_start
	y_loop_end:

	mov		esp, ebp
	pop		ebp
	ret


; === RENDER BATTLE ===
	battle_screen:
	push	TICK
	call	usleep
	add		esp, 4

	push	ebp
	mov		ebp, esp

	; ebp-4 - to be used as a sub counter
	sub		esp, 8

	mov		DWORD [ebp - 4], 8
	push 	battle_str


	; clear the screen
	push	clear_screen_cmd
	call	system
	add		esp, 4

	; print the MAGIKARP health information
	push	DWORD [magikarp_health]
	push	battle_fmt
	call	printf
	add		esp, 8

	push	magikarp_art
	call	printf
	add		esp, 4

	;print the battle status
	push	text_box
	call	printf
	add		esp, DWORD [ebp - 4]

	call	getchar

	push	wait_text

	battle_screen_tp:

	; clear the screen
	push	clear_screen_cmd
	call	system
	add		esp, 4

	; print the MAGIKARP health information
	push	DWORD [magikarp_health]
	push	battle_fmt
	call	printf
	add		esp, 8

	push	magikarp_art
	call	printf
	add		esp, 4

	;print the battle status
	push	text_box
	call	printf
	add		esp, DWORD [ebp - 4]

	invalid_char:
	call	getchar
	cmp		eax, TACKLE
	jne		not_tackle

		call	rand
		mov		ebx, 10		;90% chance of hitting
		cdq
		idiv	ebx
		cmp		edx, 1
		jne		not_miss_tackle
			;FAILED TO TACKLE
			push	result3		;Missed attack
			mov		DWORD [ebp - 4], 8

			jmp		end_turn
		not_miss_tackle:
		push	attack1
		mov		DWORD [ebp - 4], 8

		;PRINT PLAYER'S ATTACK
		; clear the screen
		push	clear_screen_cmd
		call	system
		add		esp, 4

		; print the MAGIKARP health information
		push	DWORD [magikarp_health]
		push	battle_fmt
		call	printf
		add		esp, 8

		push	magikarp_art
		call	printf
		add		esp, 4

		;print the battle status
		push	text_box
		call	printf
		add		esp, DWORD [ebp - 4]

		sub		DWORD [magikarp_health], 10
		push	result2
		jmp		end_turn
	not_tackle:
	cmp		eax, THUNDERBOLT
	jne		not_bolt

		call	rand
		mov		ebx, 12		;about 80% chance of hitting
		cdq
		idiv	ebx
		cmp		edx, 1
		jne		not_miss_thunderbolt
			;FAILED TO THUNDERBOLT
			push	result3		;Missed attack
			mov		DWORD [ebp - 4], 8

			jmp		end_turn
		not_miss_thunderbolt:
		push	attack2
		mov		DWORD [ebp - 4], 8

		;PRINT PLAYER'S ATTACK
		; clear the screen
		push	clear_screen_cmd
		call	system
		add		esp, 4

		; print the MAGIKARP health information
		push	DWORD [magikarp_health]
		push	battle_fmt
		call	printf
		add		esp, 8

		push	magikarp_art
		call	printf
		add		esp, 4

		;print the battle status
		push	text_box
		call	printf
		add		esp, DWORD [ebp - 4]

		sub		DWORD [magikarp_health], 20

		push	result2
		jmp		end_turn
	not_bolt:
	cmp		eax, RUN
	jne		not_run
		call	rand
		cdq
		mov		ebx, 3		;one in 3 chance of running away succesfully
		idiv	ebx
		cmp		edx, 1
		je		add_flee_message
			push	attack3
			mov		DWORD [ebp - 4],8

			;PRINT PLAYER'S RUN
			; clear the screen
			push	clear_screen_cmd
			call	system
			add		esp, 4

			; print the MAGIKARP health information
			push	DWORD [magikarp_health]
			push	battle_fmt
			call	printf
			add		esp, 8

			push	magikarp_art
			call	printf
			add		esp, 4

			;print the battle status
			push	text_box
			call	printf
			add		esp, DWORD [ebp - 4]

			push	result4

			jmp		end_turn
	add_flee_message:
		mov		DWORD [ebp - 4], 8
		push	result6

		;PRINT GOT AWAY
		; clear the screen
		push	clear_screen_cmd
		call	system
		add		esp, 4

		; print the MAGIKARP health information
		push	DWORD [magikarp_health]
		push	battle_fmt
		call	printf
		add		esp, 8

		push	magikarp_art
		call	printf
		add		esp, 4

		;print the battle status
		push	text_box
		call	printf
		add		esp, DWORD [ebp - 4]

		call	getchar
		jmp		end_battle

	not_run:
	mov		DWORD [ebp - 4], 4
	push	wait_text
	jmp		invalid_char


	end_turn:	;This is the place the correct input goes to

	cmp		DWORD [magikarp_health], 0
	jle		winner_winner_chicken_dinner

		call	getchar
		;PRINT PLAYER'S RESULT
		; clear the screen
		push	clear_screen_cmd
		call	system
		add		esp, 4

		; print the MAGIKARP health information
		push	DWORD [magikarp_health]
		push	battle_fmt
		call	printf
		add		esp, 8

		push	magikarp_art
		call	printf
		add		esp, 4

		;print the battle status
		push	text_box
		call	printf
		add		esp, DWORD [ebp - 4]

		call	getchar

		;TAKE MAGIKARP'S TURN
		; clear the screen
		push	clear_screen_cmd
		call	system
		add		esp, 4

		; print the MAGIKARP health information
		push	DWORD [magikarp_health]
		push	battle_fmt
		call	printf
		add		esp, 8

		push	magikarp_art
		call	printf
		add		esp, 4

		;print the battle status
		mov		DWORD [ebp - 4], 8
		push	attack4
		push	text_box
		call	printf
		add		esp, DWORD [ebp - 4]

		call	getchar


		;MAGIKARP RESULT
		; clear the screen
		push	clear_screen_cmd
		call	system
		add		esp, 4

		; print the MAGIKARP health information
		push	DWORD [magikarp_health]
		push	battle_fmt
		call	printf
		add		esp, 8

		push	magikarp_art
		call	printf
		add		esp, 4

		;print the battle status
		mov		DWORD [ebp - 4], 8
		push	result1
		push	text_box
		call	printf
		add		esp, DWORD [ebp - 4]

		call	getchar

		push	wait_text
		mov		DWORD [ebp - 4], 8

	jmp		battle_screen_tp


	winner_winner_chicken_dinner:
		;MAGIKARP RESULT
		; clear the screen
		push	clear_screen_cmd
		call	system
		add		esp, 4

		; print the MAGIKARP health information
		push	0
		push	battle_fmt
		call	printf
		add		esp, 8

		push	magikarp_art
		call	printf
		add		esp, 4

		;print the battle status
		mov		DWORD [ebp - 4], 8
		push	result5
		push	text_box
		call	printf
		add		esp, DWORD [ebp - 4]

		call	getchar

	end_battle:
	;Set magikarp health to 100 for next encounter
	mov		DWORD [magikarp_health], 100


	; write a carriage return (necessary when in raw mode)
	push	0x0d
	call 	putchar
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret


; === FUNCTION ===
nonblocking_getchar:
; returns -1 on no-data
; returns char on succes

; magic values
%define F_GETFL 3
%define F_SETFL 4
%define O_NONBLOCK 2048
%define STDIN 0

	push	ebp
	mov		ebp, esp

	; single int used to hold flags
	; single character (aligned to 4 bytes) return
	sub		esp, 8
	; get current stdin flags
	; flags = fcntl(stdin, F_GETFL, 0)
	push	0
	push	F_GETFL
	push	STDIN
	call	fcntl
	add		esp, 12
	mov		DWORD [ebp-4], eax

	; set non-blocking mode on stdin
	; fcntl(stdin, F_SETFL, flags | O_NONBLOCK)
	or		DWORD [ebp-4], O_NONBLOCK
	push	DWORD [ebp-4]
	push	F_SETFL
	push	STDIN
	call	fcntl
	add		esp, 12

	call	getchar
	mov		DWORD [ebp-8], eax

	; restore blocking mode
	; fcntl(stdin, F_SETFL, flags ^ O_NONBLOCK
	xor		DWORD [ebp-4], O_NONBLOCK
	push	DWORD [ebp-4]
	push	F_SETFL
	push	STDIN
	call	fcntl
	add		esp, 12

	mov		eax, DWORD [ebp-8]

	mov		esp, ebp
	pop		ebp
	ret

;=== FUNCTION ===
do_loading_thing:
	push	ebp
	mov		ebp, esp

	push	clear_screen_cmd
	call	system
	add		esp, 4

	push	pokemon_logo
	call	printf
	add		esp, 4
	call	getchar

	;RUN THE INTRO
	push	clear_screen_cmd
	call	system
	add		esp, 4
	push	opentext1
	push	oak_face
	call	printf
	add		esp, 8
	call	getchar

	push	clear_screen_cmd
	call	system
	add		esp, 4
	push	opentext2
	push	oak_face
	call	printf
	add		esp, 8
	call	getchar

	push	clear_screen_cmd
	call	system
	add		esp, 4
	push	opentext3
	push	oak_face
	call	printf
	add		esp, 8
	call	getchar

	push	clear_screen_cmd
	call	system
	add		esp, 4
	push	opentext4
	push	oak_face
	call	printf
	add		esp, 8
	call	getchar

	push	clear_screen_cmd
	call	system
	add		esp, 4
	push	opentext5
	push	oak_face
	call	printf
	add		esp, 8
	call	getchar


	mov		esp, ebp
	pop		ebp
	ret

;=== FUNCTION ===
end_screen:
	push	ebp
	mov		ebp, esp

	push	clear_screen_cmd
	call	system
	add		esp, 4
	push	closetext1
	push	oak_face
	call	printf
	add		esp, 8
	call	getchar

	push	clear_screen_cmd
	call	system
	add		esp, 4
	push	closetext2
	push	oak_face
	call	printf
	add		esp, 8
	call	getchar

	push	clear_screen_cmd
	call	system
	add		esp, 4
	push	closetext3
	push	oak_face
	call	printf
	add		esp, 8
	call	getchar

	mov		esp, ebp
	pop		ebp
	ret
