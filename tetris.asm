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

# Set grid start and end dimensions
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
    .word 0:4

NEW_SHAPE_FLAG:
    .word 1
#invidual blocks of the tetronimo

BLOCK_POSITION:
    .word 0:4 


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

    # randomize what shape to draw
    li $v0 42
    li $a1 7
    li $a0 0
    syscall
    
    sw $a0, BLOCK_SHAPE
    
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



## DRAW SHAPE FUNCTION ##
draw_shape:
    # save current to stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal draw_grid
    
    # set registers for new shape and paint shape
    lw $t0 ADDR_DSPL
    la $t1 BLOCK_POSITION # offset of the block_position
    la $t3 NEW_SHAPE_FLAG
    lw $t6, GRID_START
    lw $t4, ($t3) # the address of the flag value
    lw $t7, BLOCK_SHAPE # the shape
    
    # if 0, then ...
    beq $t4, 1, new_shape # initialize the shape
    # assuming #t2 is stored
    jal draw_grid_state
    j paint_shape
    
draw_grid_state:

paint_yellow:
paint_blue:
paint_orange:
paint_mint_green:
paint_red:

# PAINT THE SHAPE
paint_shape:
    add $t6, $t0, $t6 # grid start + addr display
    # draw the blocks that make the shape
    lw $t5, ($t1) # get block position
    add $t7, $t6, $t5 
    sw $s3, ($t7)
    
    lw $t5, 4($t1)
    add $t7, $t6, $t5 
    sw $s3, ($t7)
    
    lw $t5, 8($t1)
    add $t7, $t6, $t5 
    sw $s3, ($t7)
    
    lw $t5, 12($t1)
    add $t7, $t6, $t5 
    sw $s3, ($t7)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra


# NEW SHAPE
new_shape:
    # push stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    # set the new shape flag to 0
    li $t4, 0
    sw $t4, ($t3)
    
    beq $t7, 1, draw_o
    beq $t7, 2, draw_l
    beq $t7, 3, draw_j
    beq $t7, 4, draw_z
    beq $t7, 5, draw_s
    beq $t7, 6, draw_i
    beq $t7, 7, draw_t
    


    
# these shapes are initialized
draw_o:
    lw $s3 YELLOW

    # s2 is our current position
    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 4
    sw $t5, 4($t1)
    
    addi $t5, $t5, 124
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
    sw $t5, 12($t1)
    

    
    j paint_shape


draw_l:
    # gridstart is temporary
    lw $s3 ORANGE

    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 128
    sw $t5, 4($t1)
    
    addi $t5, $t5, 128
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
    sw $t5, 12($t1)
    

    
    j paint_shape

draw_j:
    # gridstart is temporary

    lw $s3 RED

    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 128
    sw $t5, 4($t1)
    
    addi $t5, $t5, 124
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
    sw $t5, 12($t1)

    
    j paint_shape

draw_t:
    # gridstart is temporary
    lw $s3 PURPLE


    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 128
    sw $t5, 4($t1)
    
    addi $t5, $t5, -4
    sw $t5, 8($t1)
    
    addi $t5, $t5, 8
    sw $t5, 12($t1)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    j paint_shape

draw_z:
    # gridstart is temporary
    lw $s3 MINT_GREEN

    # s2 is our current position

    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 4
    sw $t5, 4($t1)
    
    addi $t5, $t5, 128
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
    sw $t5, 12($t1)

    j paint_shape


draw_s:
    # gridstart is temporary
    lw $s3 INDIGO

    # s2 is our current position
    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 4
    sw $t5, 4($t1)
    
    addi $t5, $t5, 124
    sw $t5, 8($t1)
    
    addi $t5, $t5, -4
    sw $t5, 12($t1)

    j paint_shape

draw_i:
    # gridstart is temporary
    lw $s3 BLUE

    # s2 is our current position
    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 128
    sw $t5, 4($t1)
    
    addi $t5, $t5, 128
    sw $t5, 8($t1)
    
    addi $t5, $t5, 128
    sw $t5, 12($t1)
    

    j paint_shape


## UPDATE FRAMES AND SLEEPER FUNCTION

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

generate_tetronimo:
    # randomize what shape to draw
    li $v0 42
    li $a1 7
    li $a0 0
    syscall
    sw $a0, BLOCK_SHAPE
    
    jr $ra

# COLLISION CHECK FUNCTION
# 1. go thru loop
# 2. if value are equal to one stop and drop and draw a new shape
# 3. global variable changes

collision:
    # here if tetronimo is at the bottom OR
    # if it is ontop of another tetronimo
    # how do we check it?
    # call GRID_STATE
    # push to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    la $t0, BLOCK_POSITION

    li $t2 , 0 # iterate counter
    li $t3, -4 # count
    jal check_left_border
    
    li $t2 , 0 # iterate counter
    li $t3, 40 # count
    jal check_right_border

    jal check_bottom_border
    
    jal check_landed_on_block
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra

check_left_border:
    # end condition:
    beq $t2, 20, END
        # if this value is on the border push it back
        lw $t1, ($t0)
        beq $t1, $t3, push_right
        lw $t1, 4($t0)
        beq $t1, $t3, push_right
        lw $t1, 8($t0)
        beq $t1, $t3, push_right
        lw $t1, 12($t0)
        beq $t1, $t3, push_right
        addi $t3, $t3, 128
        addi $t2, $t2, 1
    j check_left_border

push_right:
    lw $t1, 0($t0)
    addi $t1, $t1, 4
    sw $t1, ($t0)
    
    lw $t1, 4($t0)
    addi $t1, $t1, 4
    sw $t1, 4($t0)
    
    lw $t1, 8($t0)
    addi $t1, $t1, 4
    sw $t1, 8($t0)
    
    lw $t1, 12($t0)
    addi $t1, $t1, 4
    sw $t1, 12($t0)
    
    jr $ra
    

check_right_border:
    # end condition:
    beq $t2, 20, END
        # if this value is on the border push it back
        lw $t1, ($t0)
        beq $t1, $t3, push_left
        lw $t1, 4($t0)
        beq $t1, $t3, push_left
        lw $t1, 8($t0)
        beq $t1, $t3, push_left
        lw $t1, 12($t0)
        beq $t1, $t3, push_left
        addi $t3, $t3, 128
        addi $t2, $t2, 1
    j check_right_border

push_left:
    lw $t1, 0($t0)
    addi $t1, $t1, -4
    sw $t1, ($t0)
    
    lw $t1, 4($t0)
    addi $t1, $t1, -4
    sw $t1, 4($t0)
    
    lw $t1, 8($t0)
    addi $t1, $t1, -4
    sw $t1, 8($t0)
    
    lw $t1, 12($t0)
    addi $t1, $t1, -4
    sw $t1, 12($t0)
    
    jr $ra



check_bottom_border:
    # if this tetris piece at the bottom we must
    # 1) update grid state and place the tetronimo 
    # 2) generate a new piece
    # 3) reset the the piece position to the origin

    lw $t1, ($t0)
    bge $t1, 2688, place_block
    lw $t1, 4($t0)
    bge $t1, 2688, place_block
    lw $t1, 8($t0)
    bge $t1, 2688, place_block
    lw $t1, 12($t0)
    bge $t1, 2688, place_block
    
    jr $ra
    

check_landed_on_block:
    # checks if landed in block
    # if there is a block underneath another block
    # t2 and t3 are free to use
    la $t4, GRID_STATE
    la $t5, BLOCK_POSITION
    
    # if any of our blocks are on top of another one
    lw $t6, ($t5)
    addi $t4, $t4, 40
    
    add $t7, $t6, $t4

    
    lw $t6, 4($t5)
    add $t7, $t6, $t4

    
    lw $t6, 8($t5)
    add $t7, $t6, $t4

    
    lw $t6, 12($t5)
    add $t7, $t6, $t4

    

    

check_line:
    # check each line if there are values greater than 1
    # if there is set to 0,
    # redraw grid
    # drops the tetronimo down
    

place_block:
    #push to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    la $t4, NEW_SHAPE_FLAG
    li $t5, 1
    sw $t5, ($t4)
    j generate_tetronimo
    # update blocks in the grid
    jal update_state_grid
    
    #pop
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra

update_state_grid:
    #set values 
    # t2, t3 is free to use
    la $t4, GRID_STATE
    la $t5, BLOCK_POSITION
    lw $t8, BLOCK_SHAPE
    
    # convert the block position to position
    # on the grid
    
    # divide it by 128...
    # store quotient
    # store remainder1
    # remainder1 divide it by 4
    # quotient mult it by 10
    # should be a quotient*10 + remainder1 should be a value 0:200
    # (quotient*10 + remainder1)*4
     
    lw $t6, ($t5)
    li $t2, 128
    divu $t6, $t2
    li $t2, 40
    multu $t2, $t2
    #how ever manyi divided this into
    
    
    add $t7, $t6, $t4
    sw $t8, ($t7)
    
    lw $t6, 4($t5)
    add $t7, $t6, $t4
    sw $t8, ($t7)
    
    lw $t6, 8($t5)
    add $t7, $t6, $t4
    sw $t8, ($t7)
    
    lw $t6, 12($t5)
    add $t7, $t6, $t4
    sw $t8, ($t7)
    
    #pop
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
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
    la $t3, BLOCK_POSITION
    
    lw $t4, 0($t3)
    addi $t4, $t4, -4
    sw $t4, 0($t3)
    
    lw $t4, 4($t3)  
    addi $t4, $t4, -4
    sw $t4, 4($t3)
    
    lw $t4, 8($t3)
    addi $t4, $t4, -4
    sw $t4, 8($t3)
    
    lw $t4, 12($t3)
    addi $t4, $t4, -4
    sw $t4, 12($t3)
    
    li $v0, 1                       # ask system to print $a0
    syscall
    
    # print newline
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra
    

# move right
respond_to_D:
    la $t3, BLOCK_POSITION

    lw $t4, 0($t3)
    addi $t4, $t4, 4
    sw $t4, 0($t3)
    
    lw $t4, 4($t3)  
    addi $t4, $t4, 4
    sw $t4, 4($t3)
    
    lw $t4, 8($t3)
    addi $t4, $t4, 4
    sw $t4, 8($t3)
    
    lw $t4, 12($t3)
    addi $t4, $t4, 4
    sw $t4, 12($t3)
    
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
    la $t3, BLOCK_POSITION
    
    lw $t4, 0($t3)
    addi $t4, $t4, 128
    sw $t4, 0($t3)
    
    lw $t4, 4($t3)  
    addi $t4, $t4, 128
    sw $t4, 4($t3)
    
    lw $t4, 8($t3)
    addi $t4, $t4, 128
    sw $t4, 8($t3)
    
    lw $t4, 12($t3)
    addi $t4, $t4, 128
    sw $t4, 12($t3)
    
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