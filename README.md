# Brick-breaker-game-8086-assembly
Brick Breaker Game 8086 Assembly
🎮 8086 Assembly Brick Breaker Game

A fully playable Brick Breaker–style game written entirely in Intel 8086 Assembly Language, running on DOS/DOSBox.
This project demonstrates real-time game logic, hardware interrupts, PIT-based sound, text-mode graphics, and file-based high score saving.

📸 Screenshot
<img width="641" height="401" alt="image" src="https://github.com/user-attachments/assets/b8e54813-65f7-4a14-8a35-06155ee72ee6" />
<img width="642" height="433" alt="image" src="https://github.com/user-attachments/assets/31d44957-5e1d-4857-a3ae-940364a856e2" />



🚀 Features
🎯 Core Game Features

Real-time paddle and ball movement

Smooth, non-blocking keyboard input

Multi-color bricks with different score values

Brick destruction, wall bouncing, and paddle reflection

Life system (game ends when lives reach zero)

Win screen when all bricks are cleared

Increasing ball speed as levels progress

⭐ Bonus Features (Implemented)

🧱 Double-length paddle mode

🎨 Different color bricks with different score values

⚡ Level progression with speed increase

💾 High score saving and loading using a file

🧠 Learning Outcomes

This project helped me understand:

Low-level system programming

BIOS interrupts (INT 10h, INT 16h)

DOS interrupts (INT 21h)

File handling using registers & buffers

Timing using loop counters

Text-mode graphics using B800h memory

PC speaker sound using PIT ports (42h, 43h, 61h)

Managing large Assembly codebases and game loops

🕹️ Gameplay Overview

The player controls a paddle at the bottom of the screen using left/right arrow keys

The ball moves continuously and bounces off walls, the paddle, and bricks

Each brick has a color that determines its score value

When the ball hits a brick, the brick is deleted and score is updated

When ball falls below paddle → lose a life

Clear all bricks → you win the level

If score is greater than saved high score → it updates the HiScore.dat file

Game can return to main menu from any screen

🧩 Functions & Their Purpose
Main_Menu

Shows menu, handles keyboard input (Play Game, Show Score, Exit).

GameLoop

Starts the game, initializes ball, paddle, walls, bricks, and main variables.

PADDLELOOP

Main loop controlling:

paddle movement

ball movement

collision checks

render updates

MoveBall

Updates ball position and decides the next movement direction.

COLLISIONDETECTION

Detects:

Walls

Paddle hits

Brick collisions

Game-over conditions

DISPLAYBLOCK / DISPLAYPADDLE / DISPLAYBALL

Draws game objects directly to B800h video memory.

DELETEBLOCK

Removes a brick when hit and updates counters.

FINDSCORE

Calculates score based on brick color.

SaveScore / LoadScore

Handles high score file I/O using DOS interrupts.

SHOWSAVESCORE

Displays saved high score and waits for keyboard return.

Sound Routines

Generate beeps/shock sounds using PIT + speaker ports.

🖥️ Interrupts & Hardware Used
INT 10h – Video Services

Printing characters

Cursor control

Changing attributes

Clearing screen

INT 16h – Keyboard Input

Blocking input (menu)

Non-blocking input (game loop)

INT 21h – DOS Services

File open

File read

File write

File create

Program termination

PIT + Speaker Ports

43h → Mode control

42h → Frequency sending

61h → Speaker ON/OFF
Used for ball hit sounds and brick breaking effects.

Direct Video Memory Writes

Video segment: B800h

Used to render bricks, paddle, ball, borders




Much faster than interrupts

