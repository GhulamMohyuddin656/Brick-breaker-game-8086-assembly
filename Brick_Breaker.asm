org 0x100

jmp start

;=========================
; BLOCKS VARIABLES
;=========================


Fsrow dw 0  ;HOLDS INTIAL VALUE OF STARTING ROW
srow dw 5
scol dw 2
Icol dw 2 ; Intermediate COLUMN
erow dw 13		;BY INCREASING OR DECREASING IT I CAN CHANGE THE NUMBER OF BLOCKS LINE
ecol dw 78
Blen dw 6		;Block Length
colors db 0xA0,0xB0,0xC0,0xE0,0      ; I Can Change Color From Here
BlockCount dw 0
Won dw 0
;=========================
; PADDLE VARIABLES
;=========================
PaddleRow dw 23		;Constant Through the Game
PaddleScol dw 0		;80/2 40-length/2
PaddleEcol dw 0
PaddleLength dw 9
PaddleLengthTemp dw 0
paddleColor db 0x10


;================================================
; SCORE ,LIVES AND OTHER VARIABLES
;================================================
GAMEOVER dw 0
Text2 db 'GAME OVER!',0
Text2Row dw 17
Text2Col dw 36
lives dw 3
livesText db 'Lives :  ',0
livesRow dw 1
livesCol dw 4
livesIndex dw 0
livesIndexCount dw 0
ScoreText db 'Score :  ',0
ScoreRow dw 1
ScoreCol dw 64
ScoreIndex dw 0
ScoreIndexCount dw 0

Text1 db 'Press Enter To Continue!',0
TextCount dw 0
Text1Row dw 18
Text1Col dw 29
TextIndex dw 0
text3 db 'YOU WON!',0
text3row dw 17
text3col dw 36
score dw 0
;=========================
; BALL VARIABLES
;=========================
ballsr dw 15
ballsc dw 0
ball_old_c dw 0
ball_old_r dw 0
ball_new_c dw 0
ball_new_r dw 0
dir_x dw 1
dir_y dw -1
Intialized dw 1
index dw 0



BallSpeed dw 100          ; Lower = faster (frames between moves)
SpeedDecrease dw 2        ; Subtract this from BallSpeed periodically
MinSpeed dw 20            ; Minimum speed (fastest possible)
FrameCounter dw 0         ; Counts frames
SpeedIncreaseInterval dw 1000  ; Increase speed every 500 frames

;=========================
; BORDER VARIABLES
;=========================
BorderColor db 0x70
BorderStartr dw 3
BorderEndr dw 24
BorderStartc dw 0
BorderEndc dw 79


;============================
;MAIN MENU VARIABLES
;============================
title:       db '*** Atari Breakout Arcade Game ***',0
Instruct db 'INSTRUCTIONS:',0
line1:       db '-> Break bricks using the ball and paddle movement.',0
line2:       db '-> Move the paddle to keep the ball alive.',0
scoreL:       db '-> Score increases by breaking bricks',0
livesL:       db '-> Lives Available: 3',0
Controls db 'CONTROLS:',0


leftKey:     db '-> Move Left by Arrow Key : <- key',0
rightKey:    db '-> Move Right by Arrow Key : -> key',0
PauseG:      db '-> Pause the Game by Pressing : p',0
ExitG:       db '-> Exit the Game by Pressing : e',0

pressEnter:  db 'Press Enter -> Start Game...',0
HighScore:   db 'Press S -> HighScore...',0
pressE:      db 'Press E -> Exit Game...',0




;============================
;SAVE SCORE VARIABLES
;============================
High times 10 db 0          
LoadHigh times 10 db 0     
StringSize dw 0
FileName db 'HiScore.DAT',0
FileHandle dw 0
FileExists db 0
HighScoreText db 'HIGH SCORE',0
NoHighScoreText db 'No HIGH SCORE TILL NOW!',0
PressEtoExitMenu db 'Press E -> Exit to Menu...',0
;----------------------------
; CLEAR SCREEN
;----------------------------
clr:
push ax
push di
mov ax,0xb800
mov es,ax
mov di,0
A1:
mov word[es:di],0x0020
add di,2
cmp di,4000
jne A1
pop di
pop ax

ret
;=============================
;	MAKE BORDER
;=============================
Border:
push ax
push di
push cx
push dx
push si

mov ax,[BorderStartr]
mov bx,80
mul bx
add ax,[BorderStartc]
shl ax,1
mov di,ax

mov ax,[BorderEndr]
mul bx
add ax,[BorderStartc]
shl ax,1
mov si,ax

mov ax,[BorderEndc]
sub ax,[BorderStartc]
mov cx,ax
inc cx ; values are 0 indexed

mov dh,[BorderColor]
mov dl,0x20
push dx

First:
push di
call PrintBorder
pop di


push si
call PrintBorder
pop si


add di,2
add si,2
dec cx
cmp cx,0
jne First



mov ax,[BorderEndr]
sub ax,[BorderStartr]
mov cx,ax
inc cx ; values are 0 indexed

mov ax,[BorderStartr]
mov bx,80
mul bx
add ax,[BorderStartc]
shl ax,1
mov di,ax

mov ax,[BorderStartr]
mov bx,80
mul bx
add ax,[BorderEndc]
shl ax,1
mov si,ax

Second:

push di
call PrintBorder
pop di


push si
call PrintBorder
pop si


add di,160
add si,160
dec cx
cmp cx,0
jne Second

pop dx

pop si
pop dx
pop cx
pop di
pop ax
ret




PrintBorder:
push bp
mov bp,sp
push ax
push dx
push di
mov di,[bp+4]
mov dx,[bp+6]
mov ax,0xb800
mov es,ax
mov word[es:di],dx
pop di
pop dx
pop ax
pop bp
ret


;=================================================================================================


;	 ███  █      ████  ████ █  █	█	  █████  ██████ █████ █████
;	 █  █ █     █    █ █    █ █		█     █   █  █        █   █
;	 ███  █     █    █ █    ██		█     █   █  █        █   █
;	 █  █ █     █    █ █    █ █		█     █   █  █   ██   █   █
;	 ███  █████  ████  ████ █  █    █████ █████  ██████ █████ █████    


;=================================================================================================


;-----------------------------
; MAKE BLOCKS ON SCREEN
;-----------------------------

OneBlock:
push bp
mov bp,sp
push cx
push ax
push bx
push dx
push di
mov ax,[srow]
mov bx,80
mul bx
add ax,[Icol]
shl ax,1
xor dx,dx
mov dx,[bp+4]
mov cx,[Blen]			;IT CAN CHANGE WIDTH OF A SINGLE BLOCK

mov di,ax
push dx
call DisplayBlock
pop dx

pop di
pop dx
pop bx
pop ax
pop cx
pop bp

ret
;=============================
; DISPLAY A SINGLE BLOCK
;=============================

DisplayBlock:
push bp
mov bp,sp
push ax
push di
push cx
mov ax,0xb800
mov es,ax
mov dx,[bp+4]
mov ax,[ecol]
Print:
mov word[es:di],dx
add di,2
add word[Icol],1
cmp [Icol],ax
jge skip1

loop Print


skip1:
pop cx
pop di
pop ax
pop bp

ret

;=============================
; CALL ONEBLOCK MULTIPLE TIME
;=============================
MultiBlock:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push di
push si
mov bx,colors     ;CHANGING COLOR THROUGH BX
mov dl,0x20
mov dh,[bx]
mov ax,[srow]


RowLoop:
cmp ax,[erow]
jge end
push dx
mov cx,[scol]
mov [Icol],cx


ColLoop:
mov cx,[Icol]
call OneBlock
add word[Icol],1
mov cx,[Icol]
cmp cx,[ecol]
jnge ColLoop


pop dx
inc bx			;UPDATING COLOR BY INCREMENTING ONE BYTE IN BX
cmp byte[bx],0		;LOGIC IF COLORS DEFINED IN colors reached limit
jne skip
mov bx,colors		; THEN IT WILL MOVE TO STARTING INDEX AGAIN IN THIS WAY I CAN DYNAMICALLY CHNAGE COLOR OF BRICKS

skip:
mov dh,[bx]

add ax,2
mov [srow],ax
jmp RowLoop



end:
pop si
pop di
pop dx
pop cx
pop bx
pop ax
pop bp
ret

;CheckBlocks:
CheckBlocks:
pusha
mov word[Won],1
mov ax,[srow]
RowCheck:
cmp ax,[erow]
jge endCheck
mov bx,[scol]
ColCheck:
push ax
push bx
call CheckPos
add bx,word[Blen]
inc bx
cmp word[Won],0
je endCheck
cmp bx,[ecol]
jl ColCheck
add ax,2
jmp RowCheck


endCheck:
popa
ret

CheckPos:
push bp
mov bp,sp
push ax
push bx
push di
push dx
mov ax,[bp+6]
mov bx,80
mul bx
add ax,[bp+4]
shl ax,1
mov di,ax
mov ax,0xb800
mov es,ax
mov ax,word[es:di]
cmp ah,0x00
je BlockNotFound
mov word[Won],0

BlockNotFound:
pop dx
pop di
pop bx
pop ax
pop bp
ret 4
;=========================================================================================
;   _  _  _  _    _          _  _   _
;  |_||_|| || || |_      |  | ||  ||
;  |  | ||_||_||_|_      |_ |_||_|||_

;==========================================================================================


;=========================
;Find Index And Display
;=========================

PaddleBlock:
push bp
mov bp,sp
push cx
push ax
push bx
push dx
push di
mov ax,[bp+10]
mov bx,80
mul bx
add ax,[bp+8]
shl ax,1
xor dx,dx
mov dx,[bp+4]
mov cx,[bp+6]			

mov di,ax
push dx
call DisplayPaddle
pop dx

pop di
pop dx
pop bx
pop ax
pop cx
pop bp

ret 8


;=============================
; DISPLAY A Paddle
;=============================

DisplayPaddle:
push bp
mov bp,sp
push ax
push di
push cx
mov ax,0xb800
mov es,ax
mov dx,[bp+4]

Print2:
mov word[es:di],dx
add di,2

loop Print2



pop cx
pop di
pop ax
pop bp

ret

;=====================================================
;Intialize Intial Value of Rows and Columns of Paddle
;=====================================================


IntializePaddle:
push ax
push bx
push dx

mov ax,80
shr ax,1
mov bx,[PaddleLength]
shr bx,1
mov [ballsc],ax
sub ax,bx
mov [PaddleScol],ax
add ax,[PaddleLength]
mov [PaddleEcol],ax

pop dx
pop bx
pop ax

ret

;===================================
; Function To push Parameters
;===================================
PaddleLogic:
push ax
push dx

mov ax,[PaddleRow]
push ax
mov ax,[PaddleScol]
push ax
mov ax,[PaddleLength]
push ax
mov dh,[paddleColor]
mov dl,0x20
push dx
call PaddleBlock

pop dx
pop ax

ret

;====================================
;	ERASE PADDLE
;====================================


ERASEPADDLE:
push ax
push dx

mov ax,[PaddleRow]
push ax
mov ax,[PaddleScol]
push ax
mov ax,[PaddleLength]
push ax
mov dx,0x0020
push dx
call PaddleBlock


pop dx
pop ax
ret


;=====================================
;	PADDLE	MOVEMENT
;=====================================


;==================
;LEFT
;==================
MOVLEFT:

push ax

mov ax,[PaddleScol]
cmp ax,1
jle Skip2
dec ax
mov [PaddleScol],ax
mov ax,[PaddleEcol]
dec ax
mov [PaddleEcol],ax

Skip2:

pop ax

ret


;==================
;RIGHT
;==================

MOVRIGHT:
push ax

mov ax,[PaddleEcol]
cmp ax,79
jge Skip3
inc ax
mov [PaddleEcol],ax
mov ax,[PaddleScol]
inc ax
mov [PaddleScol],ax

Skip3:

pop ax

ret


;=========================================================================================
;   ████   ███  █     █        █      █████ █████ █████ █████ 
;   █   █ █   █ █     █        █      █   █ █       █   █
;   ████  █████ █     █        █      █   █ █       █   █
;   █   █ █   █ █     █        █      █   █ █  ██   █   █
;   ████  █   █ █████ █████    █████  █████ █████ █████ █████
;=========================================================================================
;==============================================
;	SETS INTIAL POSITION OF BALL
;==============================================

IntializeBall:
push ax
push bx
push dx
push di

xor dx,dx
mov ax,[ballsr]
mov bx,80
mul bx
add ax,[ballsc]
shl ax,1
mov di,ax
mov ax,[ballsr]
mov [ball_old_r],ax
mov [ball_new_r],ax
mov ax,[ballsc]
mov [ball_old_c],ax
mov [ball_new_c],ax
mov word[dir_x],1
mov word[dir_y],-1
push di
mov ax,0xF000
push ax
call DisplayBall
pop ax
pop di

pop di
pop dx
pop bx
pop ax
ret

;==============================================
;	ERASE BALL FROM PREVIOUS POSITION
;==============================================


EraseBall:
push ax
push bx
push dx
push di
mov ax,[ball_old_r]
mov bx,80
mul bx
add ax,[ball_old_c]
shl ax,1
mov di,ax
push di
mov ax,0000
push ax
call DisplayBall
pop ax
pop di



pop di
pop dx
pop bx
pop ax
ret

;==============================================
;	       PRINT NEW BALL
;==============================================


PrintNewBall:
push ax
push bx
push dx
push di
mov ax,[ball_new_r]
mov bx,80
mul bx
add ax,[ball_new_c]
shl ax,1
mov di,ax
push di
mov ax,0xF000
push ax
call DisplayBall
pop ax
pop di

pop di
pop dx
pop bx
pop ax
ret


;====================================================
;CHECKS DIRECTION OF X AND DO OPERATION RESPECTIVELY
;====================================================




CheckX:
push ax
xor ax,ax
mov ax,[dir_x]
cmp ax,-1
je LeftCol
cmp ax,1
je RightCol
cmp ax,0
je EqualCol
jmp endCol
LeftCol:
call DecreaseX
jmp endCol
RightCol:
call IncreaseX
jmp endCol
EqualCol:
call EqualX
endCol:
pop ax
ret

EqualX:
push ax
push bx
mov ax,[ball_new_c]
mov [ball_old_r],ax
pop bx
pop ax
ret

IncreaseX:
push ax
push bx
mov ax,[ball_new_c]
mov bx,ax
inc ax
cmp ax,word[BorderEndc]
jne IncrementX
call SoundWall
mov ax,bx
dec ax
push ax
push bx
push dx
mov bx,-1
mov ax,[dir_x]
mul bx
mov [dir_x],ax
pop dx
pop bx
pop ax
IncrementX:
mov [ball_old_c],bx
mov [ball_new_c],ax

pop bx
pop ax
ret


DecreaseX:
push ax
push bx
mov ax,[ball_new_c]
mov bx,ax
dec ax
cmp ax,word[BorderStartc]
jne decrementX
call SoundWall
mov ax,bx
inc ax
push ax
push bx
push dx
mov bx,-1
mov ax,[dir_x]
mul bx
mov [dir_x],ax
pop dx
pop bx
pop ax
decrementX:
mov [ball_old_c],bx
mov [ball_new_c],ax

pop bx
pop ax
ret



;====================================================
;CHECKS DIRECTION OF Y AND DO OPERATION RESPECTIVELY
;====================================================




CheckY:
push ax
xor ax,ax
mov ax,[dir_y]
cmp ax,-1
je Down
cmp ax,1
je Up
jmp endRow
Down:
call DecreaseY
jmp endRow
Up:
call IncreaseY
endRow:
pop ax
ret

IncreaseY:           ;moves upward
push ax
push bx
mov ax,[ball_new_r]
mov bx,ax
dec ax
cmp ax,word[BorderStartr]

jne incrementY
call SoundWall
mov ax,bx
inc ax
push ax
push bx
push dx
mov bx,-1
mov ax,[dir_y]
mul bx
mov [dir_y],ax
pop dx
pop bx
pop ax
incrementY:
mov [ball_old_r],bx
mov [ball_new_r],ax

pop bx
pop ax
ret

DecreaseY:
push ax
push bx
mov ax,[ball_new_r]
mov bx,ax
inc ax
cmp ax,word[BorderEndr]
jne decrementY
call SoundWall
sub word[lives],1
push bx
mov bx,[ball_old_c]
call IntializeBall
mov word[Intialized],1

call ResetSpeed 
call ERASEPADDLE
call IntializePaddle
call PaddleLogic
mov [ball_old_c],bx
pop bx
jmp endY
decrementY:

mov [ball_new_r],ax

endY:
mov [ball_old_r],bx
pop bx
pop ax
ret


;====================================================
;         DISPLAY THE BALL ON GIVEN POSITION
;====================================================




DisplayBall:
push bp
mov bp,sp
push ax
push di
mov ax,0xb800
mov es,ax
mov ax,[bp+4]
mov di,[bp+6]
mov word[es:di],ax
pop di
pop ax
pop bp
ret



;====================================================
;		DELAY FOR BALL MOVEMENT
;====================================================

DelaySmall:
push ax
push bx
push cx
push dx

; Don't move ball if waiting for Enter
cmp word[Intialized], 1
je NoMove

; Increment frame counter
inc word[FrameCounter]

; Check if it's time to move the ball
mov ax, [FrameCounter]
mov bx, [BallSpeed]
xor dx, dx
div bx                    ; AX = FrameCounter / BallSpeed, DX = remainder

cmp dx, 0                 ; If remainder is 0, time to move
jne CheckSpeedIncrease

; Time to move the ball
call MoveBall

CheckSpeedIncrease:
; Check if we should increase speed
mov ax, [FrameCounter]
cmp ax, [SpeedIncreaseInterval]
jb NoSpeedIncrease

; Reset frame counter
mov word[FrameCounter], 0

; Decrease BallSpeed (make it faster)
mov ax, [BallSpeed]
sub ax, [SpeedDecrease]
cmp ax, [MinSpeed]
jl NoSpeedIncrease        ; Don't go below minimum
mov [BallSpeed], ax

NoSpeedIncrease:

; Small delay for consistent frame rate
mov cx, 1
DelayLoop1:
    push cx
    mov cx, 5000
    DelayLoop2:
        loop DelayLoop2
    pop cx
    loop DelayLoop1

NoMove:
pop dx
pop cx
pop bx
pop ax
ret

;====================================================
; RESET SPEED (call when game restarts)
;====================================================
ResetSpeed:
push ax
mov word[BallSpeed], 100
mov word[FrameCounter], 0
pop ax
ret

;====================================================
;		COLLISION DETECTION
;====================================================
CollisonDetection:
push ax
push bx
push cx
push dx
push di
push si
mov ax,0xb800
mov es,ax

call CheckX
call GetDi
mov di,[index]
mov ax,[es:di]
cmp ah,0x00
je NoCollisonX
mov bx,[dir_x]
cmp bx,0
je NoCollisonX

cmp ah,[BorderColor]
je NoCollisonX


cmp ah,[paddleColor]
je NoCollisonX


;Since if only x changes then it does not collide with paddle so it means it collides with the block

;=========================================
; X Collison Check
;=========================================
call SoundBrick
mov dx,[ball_old_c]
mov [ball_new_c],dx
push ax
push bx
push dx
mov bx,-1
mov ax,[dir_x]
mul bx
mov [dir_x],ax
pop dx
pop bx
pop ax
call FindScore

call DeleteBlock

NoCollisonX:


;=========================================
; Y Collison Check
;=========================================


call CheckY
call GetDi
mov di,[index]
mov ax,[es:di]
cmp word[Intialized],1
je NoCollisonY

cmp ah,0x00
je NoCollisonY
cmp ah,[BorderColor]
je NoCollisonY
cmp ah,[paddleColor]
jne BrickCollison
call PaddleCollison

mov dx,[ball_old_r]
mov [ball_new_r],dx
jmp NoCollisonY
BrickCollison:
call SoundBrick
push ax
push bx
push dx
mov bx,-1
mov ax,[dir_y]
mul bx
mov [dir_y],ax
pop dx
pop bx
pop ax
call FindScore
call DeleteBlock
mov dx,[ball_old_c]
mov [ball_new_c],dx
NoCollisonY:


pop si
pop di
pop dx
pop cx
pop bx
pop ax

ret

;====================
; FIND SCORE
;====================
FindScore:
push ax
push bx
push di

mov bx,colors
mov di,[index]
mov ax,[es:di]


cmp ah,[BorderColor]
je NoScore
cmp ah,[paddleColor]
je NoScore
cmp ah,0x00
je NoScore

add word[score],40
Find:
cmp ah,[bx]
je Found
sub word[score],10
inc bx
cmp byte[bx],0
jnz Find

Found:

call UpdateScore

NoScore:
pop di
pop bx
pop ax
ret




GetDi:
push ax
push bx
push dx


mov ax,[ball_new_r]
mov bx,80
mul bx
add ax,[ball_new_c]
shl ax,1
mov [index],ax


pop dx
pop bx
pop ax


ret



;======================================
; DELETE BLOCK ON COLLISON
;======================================


DeleteBlock:
push ax
push di
mov ax,0xb800
mov es,ax
mov di,[index]
mov ax,[es:di]

; Save the original block color to know when to stop
mov bh,ah

DeleteLeft:
cmp ah,0x00
je endDL
cmp ah,[BorderColor]   
je endDL
cmp ah,bh              
jne endDL
mov word[es:di],0x0000
sub di,2
mov ax,[es:di]
jmp DeleteLeft

endDL:
mov di,[index]
add di,2
mov ax,[es:di]

DeleteRight:
cmp ah,0x00
je endDR
cmp ah,[BorderColor]   
je endDR
cmp ah,bh              
jne endDR
mov word[es:di],0x0000
add di,2
mov ax,[es:di]
jmp DeleteRight


endDR:
add word[BlockCount],1
call CheckBlocks
pop di
pop ax
ret


;====================================
; 	PADDLE COLLISON
;====================================

PaddleCollison:
push ax
push bx
push cx
push dx
push di

mov ax,[PaddleLength]
shr ax,1

mov bx,ax
inc bx
add ax,[PaddleScol]
add bx,[PaddleScol]
mov dx,[ball_new_c]
cmp ax,dx
jl paddleLeft
je paddleEqual
cmp bx,dx
jg paddleRight
je paddleEqual


paddleLeft:
mov word[dir_x],1
mov ax,[dir_y]
mov bx,-1
mul bx
mov [dir_y],ax

jmp paddleCollisonEnd
paddleRight:
mov word[dir_x],-1
mov ax,[dir_y]
mov bx,-1
mul bx
mov [dir_y],ax


jmp paddleCollisonEnd
paddleEqual:
call EraseBall
mov word[dir_x],0
mov ax,[ball_new_c]
mov [ball_old_c],ax
mov ax,[dir_y]
mov bx,-1
mul bx
mov [dir_y],ax

paddleCollisonEnd:
call SoundPaddle
pop di
pop dx
pop cx
pop bx
pop ax
ret





;==========================================================================================
;       
;       █████████ ██     ██ █████████ ███████    █████████  
;       █          ██   ██      █     █      █   ██     ██ 
;       █           ██ ██       █     █      █   ██     ██
;       █████████    ███        █     ███████    █████████ 
;       █           ██ ██       █     █   ██     ██     ██
;       █          ██   ██      █     █    ██    ██     ██
;       █████████ ██     ██     █     █     ██   ██     ██
;
;==========================================================================================

DisplayText:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push di
mov ax,[bp+4]
mov bx,80
mul bx
add ax,[bp+6]
shl ax,1
xor dx,dx
mov bx,[bp+8]
mov di,ax
mov ax,0xb800
mov es,ax
mov cx,0
mov al,[bx]
PrintText:
cmp al,0
je Printed
mov ah,0x0F

inc cx
mov word[es:di],ax
add di,2
inc bx
mov al,[bx]
JMP PrintText



Printed:
sub di,2
mov [TextIndex],di
mov [TextCount],cx
pop di
pop dx
pop cx
pop bx
pop ax
pop bp
ret 6

EraseText:
push bp
mov bp,sp
push ax
push bx
push cx
push di
mov cx,[TextCount]
mov di,[TextIndex]
mov ax,0xb800
mov es,ax
Erase:
mov word[es:di],0x0020
sub di,2
dec cx
cmp cx,0
jnz Erase

pop di
pop cx 
pop bx
pop ax
pop bp
ret

;=================================================================================
;   
;   ████  █████ █    █ ███      █ ██████
;   █     █   █ █    █ █ ██     █ █     █
;   █     █   █ █    █ █  ██    █ █     █
;   ████  █   █ █    █ █   ██   █ █     █
;      █  █   █ █    █ █    ██  █ █     █
;      █  █   █ █    █ █     ██ █ █     █
;   ████  █████ ██████ █      ███ ██████
;=================================================================================

; Sound for hitting paddle
SoundPaddle:
push ax
push bx
push cx

; Frequency ~800 Hz
mov al, 182
out 43h, al
mov ax, 1493  ; divisor for ~800Hz
out 42h, al
mov al, ah
out 42h, al

; Turn on speaker
in al, 61h
or al, 03h
out 61h, al

; Short delay
mov cx, 1000
.delay1:
    push cx
    mov cx, 100
    .inner1:
        loop .inner1
    pop cx
    loop .delay1

; Turn off speaker
in al, 61h
and al, 0FCh
out 61h, al

pop cx
pop bx
pop ax
ret

; Sound for hitting brick
SoundBrick:
push ax
push bx
push cx

; Frequency ~600 Hz
mov al, 182
out 43h, al
mov ax, 1989  ; divisor for ~600Hz
out 42h, al
mov al, ah
out 42h, al

; Turn on speaker
in al, 61h
or al, 03h
out 61h, al

; Short delay
mov cx, 800
.delay2:
    push cx
    mov cx, 100
    .inner2:
        loop .inner2
    pop cx
    loop .delay2

; Turn off speaker
in al, 61h
and al, 0FCh
out 61h, al

pop cx
pop bx
pop ax
ret

; Sound for hitting wall
SoundWall:
push ax
push bx
push cx

; Frequency ~400 Hz
mov al, 182
out 43h, al
mov ax, 2984  ; divisor for ~400Hz
out 42h, al
mov al, ah
out 42h, al

; Turn on speaker
in al, 61h
or al, 03h
out 61h, al

; Very short delay
mov cx, 400
.delay3:
    push cx
    mov cx, 100
    .inner3:
        loop .inner3
    pop cx
    loop .delay3

; Turn off speaker
in al, 61h
and al, 0FCh
out 61h, al

pop cx
pop bx
pop ax
ret

SoundKey:
push ax
push bx
push cx

; Frequency ~1000 Hz
mov al, 182
out 43h, al
mov ax, 1193   ; divisor for 1000 Hz
out 42h, al
mov al, ah
out 42h, al

; Turn ON speaker
in al, 61h
or al, 03h
out 61h, al

; VERY short delay (click)
mov cx, 300
.delayKey:
    loop .delayKey

; Turn OFF speaker
in al, 61h
and al, 0FCh
out 61h, al

pop cx
pop bx
pop ax
ret

; Sound when moving paddle left/right
SoundMove:
push ax
push bx
push cx

; Frequency ~250 Hz
mov al, 182
out 43h, al
mov ax, 4772      ; divisor for ~250 Hz
out 42h, al
mov al, ah
out 42h, al

; Turn ON speaker
in al, 61h
or al, 03h
out 61h, al

; Ultra-short movement tick
mov cx, 150
.delayMove:
    loop .delayMove

; Turn OFF speaker
in al, 61h
and al, 0FCh
out 61h, al

pop cx
pop bx
pop ax
ret


; Dramatic descending Game Over sound
SoundGameOver:
push ax
push bx
push cx
push dx

mov bx, 1193        ; start at ~1000 Hz
mov cx, 20          ; number of descending steps

NextTone:
    ; Program PIT channel 2
    mov al, 182
    out 43h, al

    mov ax, bx
    out 42h, al
    mov al, ah
    out 42h, al

    ; Turn on speaker
    in al, 61h
    or al, 03h
    out 61h, al

    ; Short delay for each tone
    mov dx, 500
.delayPart:
    dec dx
    jnz .delayPart

    ; Decrease frequency = deeper sound
    add bx, 500      ; increase divisor → lower pitch

    loop NextTone

; Turn speaker OFF
in al, 61h
and al, 0FCh
out 61h, al

pop dx
pop cx
pop bx
pop ax
ret


;============================
;	PADDLE LOOP
;============================
MoveBall:
    call CollisonDetection
    call EraseBall
    call PrintNewBall
    ret

PaddleLoop:
    push ax
    push bx

Outer:
    ;---------------------
    ; 1. UPDATE PADDLE
    ;---------------------
    
    cmp word[BlockCount],10 ; UPDATE PADDLE LENGHT IF 10 Blocks are Destroyed
    jne SkipDoubleLength
    call ERASEPADDLE
    call SoundGameOver
    add word[BlockCount],1
    mov ax,[PaddleLength]
    mov [PaddleLengthTemp],ax
    shl ax,1
    mov [PaddleLength],ax
    
    call IntializePaddle
    mov word[Intialized],1
    SkipDoubleLength:
    
    cmp word[BlockCount],20  ;After Destroying 9 more blocks Paddle Length will be normal
    jne SkipUpdateLength
    call SoundGameOver
    call ERASEPADDLE
    mov ax,[PaddleLengthTemp]
    mov [PaddleLength],ax
    mov word[BlockCount],0
    
    call IntializePaddle
    mov word[Intialized],1
    SkipUpdateLength:
    call PaddleLogic

    ;---------------------
    ; 2. CHECK IF WAITING FOR START
    ;---------------------
    cmp word[Intialized], 1
    jne NormalGameplay

    ;---------------------
    ; WAITING FOR ENTER - DON'T MOVE BALL
    ;---------------------
    call UpdateLives
    mov bx, Text1
    push bx
    mov bx, [Text1Col]
    push bx
    mov bx, [Text1Row]
    push bx
    call DisplayText

wait_for_enter:
    ; Small delay to prevent CPU spinning
    push cx
    mov cx, 1000
    .wait_delay:
        loop .wait_delay
    pop cx

    ; Check for key press (non-blocking)
    mov ah, 01h
    int 16h
    jz wait_for_enter     ; No key, keep waiting

    ; Key available, read it
    mov ah, 00h
    int 16h

    cmp al, 13            ; Enter key?
    jne wait_for_enter 
    call SoundKey
    cmp word[GAMEOVER],1
    je near end2
    cmp word[Won],1
    je near end2
    ; Enter pressed!
    call EraseText
    mov word[Intialized], 0
    jmp Outer

NormalGameplay:
    ;---------------------
    ; 3. MOVE BALL (if it's time)
    ;---------------------
    call DelaySmall
    
    cmp word[lives],0
    jne CheckWin
    mov word[GAMEOVER],1
    call SoundGameOver
    mov bx,Text2
    push bx
    mov bx,[Text2Col]
    push bx
    mov bx,[Text2Row]
    push bx
    
    call DisplayText
    jmp pause_game
    
    CheckWin:
    cmp word[Won],1
    jne TakeInput
    call SoundGameOver
    mov bx,text3
    push bx
    mov bx,[text3col]
    push bx
    mov bx,[text3row]
    push bx
    call DisplayText
    jmp pause_game
    ;---------------------
    ; 4. NON-BLOCKING KEY CHECK
    ;---------------------
    TakeInput:
    mov ah, 01h
    int 16h
    jz ContinueLoop

    ; Key available
    mov ah, 00h
    int 16h

KeyHandler:
    push ax
    call ERASEPADDLE
    pop ax

    cmp ah, 0x4B
    je left

    cmp ah, 0x4D
    je right

    cmp al, 'e'
    je end2

    cmp al, 'E'
    je end2

    cmp al, 'P'
    je pause_game

    cmp al, 'p'
    je pause_game

    jmp ContinueLoop

left:
    call MOVLEFT
    call SoundMove
    jmp Outer

right:
    call MOVRIGHT
    call SoundMove
    jmp Outer

pause_game:
    mov word[Intialized], 1
    jmp Outer

end2:
    pop bx
    pop ax
    ret

ContinueLoop:
    jmp Outer


;=====================================
;           LIVES
;=====================================


DisplayLives:
push bx
mov bx,livesText
push bx
mov bx,[livesCol]
push bx
mov bx,[livesRow]
push bx
call DisplayText
mov bx,[TextIndex]
add bx,2
mov [livesIndex],bx
pop bx

ret

UpdateLives:
push ax
push bx
push dx
push di
push cx
mov di,word[livesIndex]
mov ax,0xb800
mov es,ax
mov cx,[livesIndexCount]

ErasePrev:
cmp cx,0
jle skipErasePrev
mov word[es:di],0x0020
sub di,2
mov [livesIndex],di
dec cx
mov [livesIndexCount],cx
jmp ErasePrev
skipErasePrev:
mov ax,[lives]
mov bx,10
mov cx,0
DivLives:
xor dx,dx
div bx
add dl,'0'
mov dh,0x0F
push dx
inc cx
cmp ax,0
jg DivLives
mov ax,0xb800
mov es,ax
mov di,[livesIndex]
DisplayNewLives:
pop dx
dec cx
add word[livesIndexCount],1
mov word[es:di],dx
add di,2
mov word[livesIndex],di
cmp cx,0
jnz DisplayNewLives
pop cx
pop di
pop dx
pop bx
pop ax
ret



;=========================================
;           SCORE
;=========================================

DisplayScore:
push bx
mov bx,ScoreText
push bx
mov bx,[ScoreCol]
push bx
mov bx,[ScoreRow]
push bx
call DisplayText
mov bx,[TextIndex]
add bx,2
mov [ScoreIndex],bx
pop bx

ret

UpdateScore:
push ax
push bx
push dx
push di
push cx
mov di,word[ScoreIndex]
mov ax,0xb800
mov es,ax
mov cx,[ScoreIndexCount]

ErasePrevScore:
cmp cx,0
jle skipErasePrevScore
mov word[es:di],0x0020
sub di,2
mov [ScoreIndex],di
dec cx
mov [ScoreIndexCount],cx
jmp ErasePrevScore
skipErasePrevScore:
mov ax,[score]
mov bx,10
mov cx,0
DivScore:
xor dx,dx
div bx
add dl,'0'
mov dh,0x0F
push dx
inc cx
cmp ax,0
jg DivScore
mov ax,0xb800
mov es,ax
mov di,[ScoreIndex]
DisplayNewScore:
pop dx
dec cx
add word[ScoreIndexCount],1
mov word[es:di],dx
add di,2
mov word[ScoreIndex],di
cmp cx,0
jnz DisplayNewScore
pop cx
pop di
pop dx
pop bx
pop ax
ret





;==========================================================================

;   ██          ██ █████ █████ ██     █      ██          ██ 
;   █ █        █ █ █   █   █   █ █    █      █ █        █ █ ██████ ██    █ █     █
;   █  █      █  █ █   █   █   █  █   █      █  █      █  █ █      █ █   █ █     █
;   █   █    █   █ █████   █   █   █  █      █   █    █   █ ██████ █  █  █ █     █
;   █    █  █    █ █   █   █   █    █ █      █    █  █    █ █      █   █ █ █     █
;   █     ██     █ █   █ █████ █     ██      █     ██     █ ██████ █    ██  █████
;   

;===========================================================================


Main_Menu:
pusha
call clr
mov ax,word[BorderStartc]
mov bx,word[BorderStartr]
push ax
push bx
mov word[BorderStartc],0
mov word[BorderStartr],0
call Border
pop bx
pop ax
mov word[BorderStartc],ax
mov word[BorderStartr],bx
;----------------------
; Top border
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 2
mov dl, 10
int 10h

mov al, '='
mov ah, 09h
mov bl, 0x1F         ; white on blue
mov cx, 60
int 10h


;----------------------
; Title Box
;----------------------
mov ah, 02h
mov bh, 0           ; page 0
mov dh, 3           ; row 2
mov dl, 24          ; column 10
int 10h

; Title text: bright yellow on blue
mov si, title
print_title:
    lodsb
    cmp al, 0
    je title_done
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x1E      ; yellow text (E) on blue background (1)
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_title
title_done:

;----------------------
; Top border
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 4
mov dl, 10
int 10h

mov al, '='
mov ah, 09h
mov bl, 0x1F         ; white on blue
mov cx, 60
int 10h

;===================
;Instruction Label
;===================
mov ah,02h
mov bh,0
mov dh,6
mov dl,12
int 10h
mov si,Instruct
print_Instruct:
 lodsb
 cmp al,0
 je done_Instruct
 mov ah,02h
 mov bh,0
 int 10h
 mov ah,09h
 mov bl,0x0C
 mov cx,1
 int 10h
 inc dl
 jmp print_Instruct
 done_Instruct:
;----------------------
; Instructions Section - Line 1
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 7
mov dl, 14
int 10h

mov si, line1
print_line1:
    lodsb
    cmp al, 0
    je done_line1
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0F     ; white on black
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_line1
done_line1:

;----------------------
; Line 2
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 8
mov dl, 14
int 10h

mov si, line2
print_line2:
    lodsb
    cmp al, 0
    je done_line2
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0F
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_line2
done_line2:

;----------------------
; Lives
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 9
mov dl, 14
int 10h

mov si, livesL
print_lives:
    lodsb
    cmp al, 0
    je done_lives
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0F
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_lives
done_lives:

;----------------------
; Score
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 10
mov dl, 14
int 10h

mov si, scoreL
print_score:
    lodsb
    cmp al, 0
    je done_score
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0F     ; cyan
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_score
done_score:

;=====================
;Control Label
;=====================
mov ah,02h
mov bh,0
mov dh,11
mov dl,12
int 10h
mov si,Controls
print_Control:
lodsb
cmp al,0
je done_Control
mov ah,02h
mov bh,0
int 10h
mov ah,09h
mov bl,0x02
mov cx,1
int 10h
inc dl
jmp print_Control

done_Control:
;----------------------
; Left Key
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 12
mov dl, 14
int 10h

mov si, leftKey
print_left:
    lodsb
    cmp al, 0
    je done_left
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0E     ; yellow
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_left
done_left:

;----------------------
; Right Key
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 13
mov dl, 14
int 10h

mov si, rightKey
print_right:
    lodsb
    cmp al, 0
    je done_right
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0E
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_right
done_right:

;----------------------
; Pause
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 14
mov dl, 14
int 10h

mov si, PauseG
print_pause:
    lodsb
    cmp al, 0
    je done_pause
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0E
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_pause
done_pause:
;=====================
;Exit
;=====================
mov ah,02h
mov bh,0
mov dh,15
mov dl,14
int 10h
mov si,ExitG
print_ExitG:
lodsb
cmp al,0
je done_ExitG
mov ah,02h
mov bh,0
int 10h
mov ah,09h
mov bl,0x0E
mov cx,1
int 10h
inc dl
jmp print_ExitG
done_ExitG:


;========================
;Border For Enter Key
;========================
mov ah,02h
mov bh,0
mov dh,17
mov dl,16
int 10h
mov al,'='
mov ah,09h
mov bl,0x1F
mov cx,40
int 10h

;----------------------
; High Score
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 19
mov dl, 20
int 10h

mov si, HighScore
print_hs:
    lodsb
    cmp al, 0
    je done_hs
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0E     ; bright yellow
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_hs
done_hs:

;----------------------
; Press Enter
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 18
mov dl, 20
int 10h

mov si, pressEnter
print_enter:
    lodsb
    cmp al, 0
    je done_enter
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0A     ; bright green
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_enter
done_enter:

;----------------------
; Press E to Exit
;----------------------
mov ah, 02h
mov bh, 0
mov dh, 20
mov dl, 20
int 10h

mov si, pressE
print_exit:
    lodsb
    cmp al, 0
    je done_exit
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x0C     ; bright red
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_exit
done_exit:

;========================
;Border For Enter Key
;========================
mov ah,02h
mov bh,0
mov dh,21
mov dl,16
int 10h
mov al,'='
mov ah,09h
mov bl,0x1F
mov cx,40
int 10h
;----------------------
; Wait for Enter key to start
;----------------------
waitE:
    mov ah, 00h
    int 16h           ; keyboard interrupt
    cmp al, 13
    je go_Game
    cmp al,'s'
    je go_Score
    cmp al,'S'
    je go_Score
    cmp al,'e'
    je go_Exit
    cmp al,'E'
    je go_Exit
    jne waitE
go_Score:
call ShowSaveScore
popa
jmp Main_Menu
go_Game:
call GameLoop
popa
jmp Main_Menu

go_Exit:

popa
ret




;============================
; GAME LOOP
;============================
GameLoop:
push ax
mov word[PaddleLength],9
mov word[lives],3
mov word[GAMEOVER],0
mov word[score],0
mov word[Won], 0 
call clr
call Border

mov ax,[srow]
mov [Fsrow],ax
call MultiBlock
mov [srow],ax
call IntializePaddle
call IntializeBall
call DisplayLives
call UpdateLives
call DisplayScore
call UpdateScore
call PaddleLoop
call SaveScore
pop ax
ret






;=============================
;SAVE SCORE ON A FILE
;=============================



ConvertScoretoString:
    pusha
    mov ax,[score]
    mov bx,10
    xor dx,dx
    mov cx,0
    
Multiply_Loop:
    xor dx,dx
    div bx
    inc cx
    push dx
    cmp ax,0
    jne Multiply_Loop
    
    mov [StringSize],cx
    mov bx,High
    
StoreScore:
    pop dx
    add dl,'0'
    mov byte[bx],dl
    inc bx
    loop StoreScore
    
    mov byte[bx],0
    popa
    ret

CreateFile:
    push bp
    mov bp,sp
    pusha
    
    mov ah,3Ch
    mov cx,0
    mov dx,[bp+4]
    int 21h
    jc CreateFailed
    
    mov [FileHandle],ax
    jmp CreateDone
    
CreateFailed:
    mov word[FileHandle],0
    
CreateDone:
    popa
    pop bp
    ret 2

WriteFile:
    push bp
    mov bp,sp
    pusha
    
    mov ah,40h
    mov bx,[FileHandle]
    mov dx,[bp+4]
    mov cx,9
    int 21h
    
    popa
    pop bp
    ret 2

CloseFile:
    push bp
    mov bp,sp
    pusha
    
    mov ah,3Eh
    mov bx,[bp+4]
    int 21h
    
    popa
    pop bp
    ret 2


TryOpenFile:
    push bp
    mov bp,sp
    pusha
    
    mov ah,3Dh
    mov al,2
    mov dx,[bp+4]
    int 21h
    jc FileDoesNotExist ; If carry set, file doesn't exist
    
    ; File exists
    mov [FileHandle],ax
    mov byte[FileExists],1
    jmp OpenDone
    
FileDoesNotExist:
    mov byte[FileExists],0
    
OpenDone:
    popa
    pop bp
    ret 2

LoadScore:
    push bp
    mov bp,sp
    pusha
    
    mov ah,3Fh
    mov bx,[bp+4]
    mov cx,9
    mov dx,LoadHigh
    int 21h
    
    popa
    pop bp
    ret 2

ClearHighBuffer:
    pusha
    mov di,High
    mov cx,10
    mov al,0
ClearLoop:
    mov byte[di],al
    inc di
    loop ClearLoop
    popa
    ret

CompareScores:
    pusha
    
    mov si,LoadHigh
    mov cx,0
    
CheckHighScoreSize:
    lodsb
    cmp al,0
    je End_CheckHighScoreSize
    cmp al,'0'          ; Validate it's a digit
    jb End_CheckHighScoreSize
    cmp al,'9'
    ja End_CheckHighScoreSize
    inc cx
    jmp CheckHighScoreSize
    
End_CheckHighScoreSize:
    ; If loaded score is empty, current score is the new high score
    cmp cx,0
    je End_CompareScores
    
    ; Compare sizes (more digits = higher score)
    cmp cx,[StringSize]
    jl End_CompareScores    ; Loaded < New (new has more digits, keep new)
    jg ChangeHigh           ; Loaded > New (loaded has more digits, keep loaded)
    
    ; Same size, compare digit by digit
Continue_CompareScores:
    mov si,LoadHigh
    mov di,High
    mov cx,[StringSize]
    
CompareLoop:
    lodsb               ; Load byte from LoadHigh (old high score)
    mov bl,al
    mov al,[di]         ; Load byte from High (new score)
    inc di
    cmp al,bl
    jb ChangeHigh       ; New < Loaded (keep loaded as high score)
    ja End_CompareScores ; New > Loaded (keep new as high score)
    loop CompareLoop
    ; If we reach here, scores are equal - keep either one (we'll keep new)
    jmp End_CompareScores
    
ChangeHigh:
    ; Replace new score with loaded high score
    mov cx,10
    mov si,LoadHigh
    mov di,High
    rep movsb
    
End_CompareScores:
    popa
    ret
    
SaveScore:
    pusha
    
    ; Clear both buffers first
    call ClearHighBuffer
    
    ; Clear LoadHigh buffer
    mov di,LoadHigh
    mov cx,10
    mov al,0
ClearLoadHigh:
    mov byte[di],al
    inc di
    loop ClearLoadHigh
    
    ; Convert current score to string
    call ConvertScoretoString

    ; Try to open existing file
    mov bx,FileName
    push bx
    call TryOpenFile
    
    ; Check if file exists
    cmp byte[FileExists],1
    je FileFound
    
    ; File doesn't exist, create it
    mov bx,FileName
    push bx
    call CreateFile
    jmp WriteScore
    
FileFound:
    ; Load existing high score
    mov bx,[FileHandle]
    push bx
    call LoadScore
    
    ; Close file (we'll reopen for writing if needed)
    mov bx,[FileHandle]
    push bx
    call CloseFile
    
    ; Compare scores
    call CompareScores
    
    ; Reopen file for writing
    mov bx,FileName
    push bx
    call TryOpenFile
    
WriteScore:
    ; Write high score
    mov bx,High
    push bx
    call WriteFile
    
    ; Close file
    mov bx,[FileHandle]
    push bx
    call CloseFile
    
    popa
    ret

;=============================
;SHOW SAVED SCORE
;=============================
ShowSaveScore:
pusha
call clr
mov ax,word[BorderStartc]
mov bx,word[BorderStartr]
push ax
push bx
mov word[BorderStartc],0
mov word[BorderStartr],0
call Border
pop bx
pop ax
mov word[BorderStartc],ax
mov word[BorderStartr],bx
mov bx,FileName
push bx
call TryOpenFile
cmp byte[FileExists],1
jne NoHighScore
mov bx,[FileHandle]
push bx
call LoadScore
mov bx,[FileHandle]
push bx
call CloseFile

mov ah, 02h
mov bh, 0
mov dh, 11
mov dl, 28
int 10h

mov si, HighScoreText
print_HighScoreText:
    lodsb
    cmp al, 0
    je done_HighScoreText
    
    mov ah, 02h
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov bl, 0x02
    mov cx, 1
    int 10h
    
    inc dl
    jmp print_HighScoreText
done_HighScoreText:

    mov ah,02h
    mov bh,0
    mov dh,13
    mov dl,30
    int 10h
    mov si,LoadHigh
    print_LoadHigh:
        lodsb
        cmp al,0
        je done_LoadHigh
        mov ah,02h
        mov bh,0
        int 10h
        mov ah,09h
        mov bl,0x0F
        mov cx,1
        int 10h
        inc dl
        jmp print_LoadHigh

    done_LoadHigh:
jmp WaitForExitKey
NoHighScore:
mov ah,02h
mov bh,0
mov dh,11
mov dl,30
mov si,NoHighScoreText
print_NoHighScoreText:
    lodsb
    cmp al,0
    je done_NoHighScoreText
    mov ah,02h
        mov bh,0
        int 10h
        mov ah,09h
        mov bl,0x02
        mov cx,1
        int 10h
        inc dl
        jmp print_NoHighScoreText
    done_NoHighScoreText:

WaitForExitKey:
mov ah,02h
mov bh,0
mov dh,15
mov dl,28
mov si,PressEtoExitMenu
print_WaitForExitKey:
    lodsb
    cmp al,0
    je done_WaitForExit
    mov ah,02h
        mov bh,0
        int 10h
        mov ah,09h
        mov bl,0x0F
        mov cx,1
        int 10h
        inc dl
        jmp print_WaitForExitKey
    done_WaitForExit:

    
WaitForExitKeyInt:
    mov ah,00h
    int 16h
    cmp al,'E'
    je ExitShowSaveScore
    cmp al,'e'
    je ExitShowSaveScore

    jne WaitForExitKeyInt

ExitShowSaveScore:
popa 
ret
;============================
; 	MAIN LOOP
;============================


start:
mov ax,0x1003			;FOR ACCESSING ALL 16 BACKGROUND COLORS BY DISABLING BLINKING BIT
mov bx,0x00
int 0x10

call Main_Menu

mov ax,0x4c00
int 0x21