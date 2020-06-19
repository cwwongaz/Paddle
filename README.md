Hello, my name is Ronald. I am currently a MPhil student (in department of MATH) from Hong Kong.

This is my final project of CS50x. In this project, I used Lua (LÖVE) to program the classic paddle game. 

In this game, it has single player mode and 2 players mode, the purpose of this game is to reflect the ball by a Paddle controlled by the player(s), and break all the tiles on the screen. After all the tiles are gone, the players won. And if all the balls are off the stage (player failed to catch the ball), the player(s) lose.

The game has 3 stages, the 'start' stage, the 'play' stage, and the finish stage. The player can always end the game by pressing 'esc'



'start' stage: 

In this stage, player choose the difficulty and playing mode (single / double player). After pressing enter / return, the game stage entered the 'play' stage. 



'play' stage: 

The player enter the play stage by an entering sound. In the 'play' stage, player(1) will serve the ball, by pressing 'space'. The player control the paddle by these keys:

Player 1: 

A --- left
D --- Right
W --- Fire a rocket: 1
S --- Double the Paddle size (unlimit use)
Left Shift --- Summand balls: 1 (Maximal 10 on the stage)

Player 2: 

'left' --- left
'right' --- Right
'up' --- Fire a rocket: 1
'down' --- Double the Paddle size (unlimit use)
Right Shift --- Summand balls: 1 (Maximal 10 on the stage)

And after serving the ball, 'space' is to enter slow motion mode for 10 seconds (unlimit use with another 10 seconds cool down).

When player successfully break a block, it has 5% chance to drop an item, which gives either an extra rocket / extra ball summand.

(NOTE: When the item drops and both paddles collide to get the item, they both have 50% chance to get the item since the player:update(dt) function of player1 and player 2 (in main update) has updating order of 50% player 1 go first and 50% player 2 go first.)

Difficulty: player can choose difficulty in the beginning stage, it has 3 difficulty for player to choose. The easy mode, normal mode, and difficulty mode.

Easy mode: brick has 1 hp, which require only 1 hit of the ball to break it.

Normal mode: brick has 3 hps, which require 3 hits to break it.

Hard mode: brick has 5 hps.

Rocket can break the block with only 1 hit.

The transparency of the block will change by the hp.



'finish' stage: 

In the finish stage, if the player won, the screen will display a winning message, and display the victory sound. If the player lose, the screen will display a losing message and a losing sound.

When pressing enter / return, the game will be back to the 'start' stage.

Hope you enjoy the game.# Paddle
