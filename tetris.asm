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
WHITE:
    .word 0xffffff
#Tetronimo colors
WHITE:
    .word 0xfffffc
RED:
    .word 0xb1495b
ORANGE:
    .word 0xf26825
YELLOW:
    .word 0xf9c846
MINT_GREEN:
    .word 0xb2dbbf
BLUE:
    .word 0x00798c
PURPLE:
    .word 0x390040
INDIGO:
    .word 0x610f7f

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
    .word 0

BLOCK_ORIENTATION:
    .word 0:200

# BLOCK POSITION TO UPDATE
BLOCK_POSITION:
    .word 0 # on the grid

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


    jal draw_border # set border
    
    jal draw_grid # set grid
    j game_loop
# END of loop func
END: 
    jr $ra

# BORDER
draw_border:
    lw $t0, ADDR_DSPL
    lw $t1, GRID_START
    lw $t2, WHITE
    # push to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    #draw down and set counters to 0
    addi $t5, $t1, -4 # set the value to start drawing at
    add $t4, $t0, $t5
    addi $t3, $zero, 0 # reset iterator
    jal draw_border_vertical
    
    

    addi $t5, $t1, 40 # set the value to start drawing at
    add $t4, $t0, $t5 #
    addi $t3, $zero, 0 # reset iterator
    jal draw_border_vertical
    

    
    addi $t5, $t1, 2684 # set the value to start drawing at
    add $t4, $t0, $t5 # where on the screen
    addi $t3, $zero, 0 # reset iterator
    jal draw_border_bottom

    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    

    jr $ra
    
     

draw_border_vertical:
    beq $t3, 21, END
        sw $t2, ($t4)
        addi $t4, $t4, 128
        addi $t3, $t3, 1
        
    j draw_border_vertical
        
    
draw_border_bottom:
    beq $t3, 12, END
        sw $t2, ($t4)
        addi $t4, $t4, 4
        addi $t3, $t3, 1
    j draw_border_bottom
    


# GRID FUNCTION
draw_grid:
    lw $t0, ADDR_DSPL
    lw $s0, LIGHT_GRAY
    lw $s1, DARK_GRAY

    #intiate where we will put the grid
    lw $t1 GRID_START
    lw $t2 GRID_END 
    lw $t3 GRID_WIDTH
    
    # Adding values to for grid placement
    add $t1, $t1, $t0 # GRID_START + ADDR_DISP
    add $t2, $t2, $t0 # GRID_END + ADDR_DISP
    add $t3, $t3, $t1 # GRID_WIDTH + GRID_START + ADDR_DISP
    addi $t4, $zero, 0 # set a register for swapping purposes
    # push to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    jal grid_loop
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4

    jr $ra

grid_loop:

    bge $t1, $t2, END
        sw $s0, ($t1) # color 
        addi $t1, $t1, 4
        sw $s1, ($t1) # color 
        addi $t1, $t1, 4
        bge $t1, $t3, grid_new_line # if value is at width now swap
    j grid_loop
    

grid_new_line:
    addi $t3, $t1, 128 # add 128
    addi $t1, $t1, 88 # add 
    # swap colors
    move $t4, $s0
    move $s0, $s1
    move $s1, $t4
    # go back to the loop
    j grid_loop


# DRAW SHAPE FUNCTION 
draw_shape:
    # save current to stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    
    jal draw_grid
    li $t7, 5
    beq $t7, 0, draw_o
    beq $t7, 1, draw_l
    beq $t7, 2, draw_j
    beq $t7, 3, draw_z
    beq $t7, 4, draw_s
    beq $t7, 5, draw_i
    beq $t7, 6, draw_t
    jr $ra

# DRAW_O FUNCTION
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
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra

draw_l:
    # gridstart is temporary
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION # offset of the block_position
    lw $t2 ORANGE
    
    # s2 is our current position
    add $t3, $t0, $t1
    sw $t2, ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    addi $t3, $t3, 124  
    sw $t2 ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra   

draw_j:
    # gridstart is temporary
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION # offset of the block_position
    lw $t2 RED
    
    # s2 is our current position
    add $t3, $t0, $t1
    sw $t2, ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    addi $t3, $t3, 124  
    sw $t2 ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra   

draw_t:
    # gridstart is temporary
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION # offset of the block_position
    lw $t2 PURPLE
    
    # s2 is our current position
    add $t3, $t0, $t1
    sw $t2, ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    addi $t3, $t3, 124  
    sw $t2 ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra   

draw_z:
    # gridstart is temporary
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION # offset of the block_position
    lw $t2 MINT_GREEN
    
    # s2 is our current position
    add $t3, $t0, $t1
    sw $t2, ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    addi $t3, $t3, 124  
    sw $t2 ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra

draw_s:
    # gridstart is temporary
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION # offset of the block_position
    lw $t2 INDIGO
    
    # s2 is our current position
    add $t3, $t0, $t1
    sw $t2, ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    addi $t3, $t3, 124  
    sw $t2 ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra

draw_i:
    # gridstart is temporary
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION # offset of the block_position
    lw $t2 BLUE
    
    # s2 is our current position
    add $t3, $t0, $t1
    sw $t2, ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    addi $t3, $t3, 124  
    sw $t2 ($t3)
    addi $t3, $t3, 4
    sw $t2 ($t3)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra

tick:
    # push value to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    li $v0, 32 # syscall for sleep
    li $a0, 100 # 100 millisecond sleep = 10 frames per second
    syscall 
    
    # pop
    lw $ra, ($sp)
    addi $sp, $sp 4
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


    jal collision
    jal draw_shape
    jal tick # sleep


    
    b game_loop

# COLLISION CHECK FUNCTION
# 1. go thru loop
# 2. if value are equal to one stop and drop and draw a new shape
# 3. global variable changes

collision:
    # randomize what shape to draw
    li $v0 42
    li $a1 7
    li $a0 0
    syscall
    
    add $t7, $zero, $a0
    jr $ra
    

# KEYBOARD CHECK FUNCTION
keyboard_main:
	li 		$v0, 32
	li 		$a0, 1
	syscall
    
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    jr $ra


keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
    beq $a0, 0x77, respond_to_w     # Check if the key w was pressed
    beq $a0, 0x1b, END_GAME
    jr $ra

    

# move left
respond_to_A:
    lw $t3, BLOCK_POSITION
    addi $t3, $t3, -4
    sw $t3, BLOCK_POSITION
    li $v0, 1                       # ask system to print $a0
    syscall
    
    # print newline
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra
    

# move right
respond_to_D:
    lw $t3, BLOCK_POSITION
    addi $t3, $t3, 4
    sw $t3, BLOCK_POSITION
    
    # print $a0
    li $v0, 1
    syscall
    
    # print newline
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra

# move down
respond_to_S:
    lw $t3, BLOCK_POSITION
    addi $t3, $t3, 128
    sw $t3, BLOCK_POSITION
    
    # print $a0
    li $v0, 1                       # ask system to print $a0
    syscall
    
    # print newline
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra

respond_to_w:
    lw $t3, BLOCK_POSITION
    addi $t3, $t3, 128
    sw $t3, BLOCK_POSITION
    
    # print $a0
    li $v0, 1                       # ask system to print $a0
    syscall
    
    # print newline
    li $v0, 11
    li $a0, 10
    syscall
    
    # goes back to wherever.
    jr $ra

END_GAME: # rip