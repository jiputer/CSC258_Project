################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: John Ma, 1004274037
# Student 2: Name, Student Number (if applicable)
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

# Set grid colors
LIGHT_GRAY:
    .word 0x454545
DARK_GRAY:
    .word 0x1b1b1b

#Tetronimo colors

YELLOW:
    .word 0xffd966
BLUE:
    .word 0xffd966

# Set grid dimensions
GRID_START:
    .word 904
GRID_END:
    .word 3504 # 904 + 128*20 + 40
GRID_WIDTH:
    .word 40
    


##############################################################################s
# Mutable Data
##############################################################################
# Set grid initialization
GRID_STATE:
    .word 0:200

BLOCK_SHAPE:
    .word 4

# BLOCK POSITION TO UPDATE
BLOCK_POSITION:
    .word 4 # on the grid
##############################################################################
# Code
##############################################################################
	.text
	.globl main


main:
    
    # set intial block position at top
    la $t0, BLOCK_POSITION
    lw $t1, GRID_START
    add $t3, $t1, 16
    sw $t3, ($t0)
    # set the grid
    j set_grid
    j game_loop
    

# GRID FUNCTION
set_grid:
    lw $t0, ADDR_DSPL
    lw $s0, LIGHT_GRAY
    lw $s1, DARK_GRAY

    #intiate where we will put the grid
    lw $t1 GRID_START
    lw $t2 GRID_END 
    lw $t3 GRID_WIDTH
    
    add $t1, $t1, $t0 # GRID_START + ADDR_DISP
    add $t2, $t2, $t0 # GRID_END + ADDR_DISP
    add $t3, $t3, $t1 # GRID_WIDTH + GRID_START + ADDR_DISP
    addi $t6, $zero, 0 # set a register to swap 
    jal grid_loop
    # done!
    jr $ra

grid_loop:
    bge $t1, $t2, game_loop
        sw $s0, ($t1) # color 
        addi $t1, $t1, 4
        sw $s1, ($t1) # color 
        addi $t1, $t1, 4
        bge $t1, $t3, grid_new_line # if value is at width now swap
    j grid_loop
    jr $ra

grid_new_line:
    addi $t3, $t1, 128 # add 128
    addi $t1, $t1, 88 # add 
    # swap colors
    move $t6, $s0
    move $s0, $s1
    move $s1, $t6
    # go back to the loop
    b grid_loop


# DRAW SHAPE FUNCTION
draw_shape:
    #jal set_grid
    addi $t2, $zero, 0
    beq $t2, 0, draw_o
    jr $ra

draw_o:
    # gridstart is temporary
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION # offset of the block_position
    lw $t2 YELLOW
    
    # s2 is our current position
    add $t3, $t0, $t1
    sw $t2, ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    addi $t3, $t3, 124  
    sw $t2 ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)

tick:
    # push value to stack
    li $v0, 32 # syscall for sleep
    li $a0, 100 # 100 millisecond sleep = 10 frames per second
    syscall 
    jr $ra

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
    # 5. Go back to 1
    
    
    #info to store here
    # 1) position of the shape in terms of pixel on screen
    # 2) the shape 
    # 3. GRID STATE (ARRAY BEING STORED) -- how to store this array?
    
    jal keyboard_main
    # remove value from register 
    # clean up
    jal collision
    jal draw_shape
    jal tick # sleep


    
    b game_loop

# COLLISION CHECK FUNCTION
# 1. go thru loop
# 2. if value are equal to one stop and drop and draw a new shape
# 3. global variable changes

collision:
    
    jr $ra
    

# KEYBOARD CHECK FUNCTION
keyboard_main:
	li 		$v0, 32
	li 		$a0, 1
	syscall
    
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    


keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x74, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
    
    li $v0, 1                       # ask system to print $a0
    syscall
    
    # print newline
    li $v0, 11
    li $a0, 10
    syscall
    
    jr $ra

    

# move left
respond_to_A:
    la $t0, BLOCK_POSITION
    addi $t0, $t0, -4
    sw $t0, BLOCK_POSITION
    b keyboard_input

# move right
respond_to_D:
    la $t0, BLOCK_POSITION
    addi $t0, $t0, 4
    sw $t0, BLOCK_POSITION
    b keyboard_input

# move down
respond_to_S:
    addi $a1, $a1, 128

    b keyboard_input
