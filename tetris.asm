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
    .word 904 # offset from display address of where to start the grid
GRID_END:
    .word 3376 # 904 + 128*19 + 40 ;  offset from display address to end grid
GRID_WIDTH:
    .word 40 # width of the grid, in how many memory space it takes, 10 blocks in width 
    


##############################################################################s
# Mutable Data
##############################################################################
# Set grid initialization, 
GRID_STATE:
    .word 0:200 # grid state

BLOCK_SHAPE:
    .word 0 

BLOCK_ORIENTATION:
    .word 0:4

NEW_SHAPE_FLAG:
    .word 1

# 4 positions of the 4 invidual blocks of the tetronimo
# this is the offset where it will be placed from the 
# display address, 
BLOCK_POSITION:
    .word 0:4


##############################################################################
# Code
##############################################################################
	.text
	.globl main


main:
    # set intial block position at top
    
    la $t4 BLOCK_SHAPE
    # randomize what shape to draw
    li $v0 42
    li $a1 7
    li $a0 0
    syscall
    addi $a0, $a0, 2
    sw $a0, ($t4)     # set the position for the block

    jal init_new_shape
    jal draw_border # set border
    jal set_grid  #setup the grid

    j game_loop

# END of grid loop 
END_GRID_LOOP: 
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra

END:
    jr $ra

## DRAW BORDER FUNCTION
# Meant to draw the border of the game
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
    

    
    addi $t5, $t1, 2556 # set the value to start drawing at
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

## SET GRID FUNCITON ##
# Meant to inialize the grid state 
set_grid:
    # load values 
    li $s0, 0
    li $s1, 1
    #intiate where we will put the grid
    li $t1 0
    li $t2 800
    lw $t3 GRID_WIDTH
    
    la $t4 GRID_STATE
    
    addi $t0, $zero, 0 # set a register for swapping purposes
    
    # push to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    jal init_grid_loop
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4

    jr $ra

init_grid_loop:
    bge $t1, $t2, END
        # if this position in grid state is greater than 0
        sw $s0, ($t4) # store the value
        addi $t1, $t1, 4
        addi $t4, $t4, 4

        sw $s1, ($t4) # store the value to the grid
        addi $t1, $t1, 4
        addi $t4, $t4, 4
        bge $t1, $t3, init_grid_new_line # if value is at width now swap
    j init_grid_loop

init_grid_new_line:
    addi $t3, $t3, 40
    # swap colors
    move $t0, $s0
    move $s0, $s1
    move $s1, $t0
    # go back to the loop
    j init_grid_loop

## INIT SHAPE ## repeat function without the 
## SET NEW SHAPE
init_new_shape:
    # push stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    # set registers for new shape and paint shape
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION
    
    # set up grid start as a value on the addr_displ
    lw $t6, GRID_START
    add $t6, $t6, $t0
    
    # set the block position
    la $t1 BLOCK_POSITION # offset of the block_position
    la $t3 NEW_SHAPE_FLAG
    lw $t7 BLOCK_SHAPE # the shape

    # set the new shape flag to 0
    li $t4, 0
    sw $t4, ($t3)

    beq $t7, 2, init_draw_o 
    beq $t7, 3, init_draw_l
    beq $t7, 4, init_draw_j
    beq $t7, 5, init_draw_t
    beq $t7, 6, init_draw_i
    beq $t7, 7, init_draw_s
    beq $t7, 8, init_draw_z
    


    
# these shapes are initialized
init_draw_o:
    lw $s3 YELLOW


    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 4
    sw $t5, 4($t1)
    
    addi $t5, $t5, 124
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
    sw $t5, 12($t1)
    
    
    jr $ra


init_draw_l:
    # $t5 is a temporary value
    lw $s3 ORANGE

    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 128
    sw $t5, 4($t1)
    
    addi $t5, $t5, 128
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
    sw $t5, 12($t1)
    

    
    jr $ra

init_draw_j:
    # $t5 is a temporary value

    lw $s3 RED

    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 128
    sw $t5, 4($t1)
    
    addi $t5, $t5, 124
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
    sw $t5, 12($t1)

    jr $ra

init_draw_t:
    # $t5 is a temporary value
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
    
    jr $ra

init_draw_i:
    # $t5 is a temporary value
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
    
    jr $ra


init_draw_s:
    # $t5 is a temporary value
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
    
    jr $ra


init_draw_z:
    # $t5 is a temporary value
    lw $s3 MINT_GREEN


    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 4
    sw $t5, 4($t1)
    
    addi $t5, $t5, 128
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
    sw $t5, 12($t1)

    jr $ra




# GRID FUNCTION
draw_grid:
    lw $t0, ADDR_DSPL
    # load a color based on the pixel
    li $s0 0
    #intiate where we will put the grid
    lw $t1 GRID_START
    lw $t2 GRID_END
    lw $t3 GRID_WIDTH
    
    li $t6 0
    la $t5 GRID_STATE
    
    # Adding values to for grid placement
    add $t1, $t1, $t0 # GRID_START + ADDR_DISP
    add $t2, $t2, $t0 # GRID_END + ADDR_DISP
    add $t3, $t3, $t1 # GRID_WIDTH + GRID_START + ADDR_DISP
    
    li $t4, 0 # for swapping...
    
    # push to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    jal grid_loop
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4

    jr $ra

grid_loop:

    bge $t1, $t2, END_GRID_LOOP
        lw $s1, ($t5) # get the color
        jal set_color #set color
        sw $s0, ($t1)
        addi $t1, $t1, 4
        addi $t5, $t5, 4

        bge $t1, $t3, grid_new_line # if value is at width now swap
    j grid_loop
    

grid_new_line:
    addi $t3, $t1, 128 # add 128
    addi $t1, $t1, 88 # add 
    j grid_loop


set_color:
    beq $s1, 0, set_light_gray
    beq $s1, 1, set_dark_gray
    
    beq $s1, 2, set_yellow
    beq $s1, 3, set_orange
    beq $s1, 4, set_red
    beq $s1, 5, set_purple
    beq $s1, 6, set_blue
    beq $s1, 7, set_indigo
    beq $s1, 8, set_mint_green

    
    
set_light_gray:
    lw $s0 LIGHT_GRAY
    jr $ra 
set_dark_gray:
    lw $s0 DARK_GRAY
    jr $ra
set_yellow:
    lw $s0 YELLOW
    jr $ra 
set_orange:
    lw $s0 ORANGE
    jr $ra 
set_red:
    lw $s0 RED
    jr $ra 
set_purple:
    lw $s0 PURPLE
    jr $ra 
set_blue:
    lw $s0 BLUE
    jr $ra 
set_indigo:
    lw $s0 INDIGO
    jr $ra 
set_mint_green:
    lw $s0 MINT_GREEN
    jr $ra 



## DRAW FUNCTION ##
draw:
    # save current to stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal draw_grid
    
    # set registers for new shape and paint shape
    lw $t0 ADDR_DSPL
    lw $t1 BLOCK_POSITION
    
    # set up grid start as a value on the addr_displ
    lw $t6, GRID_START
    add $t6, $t6, $t0
    
    # set the block position
    la $t1 BLOCK_POSITION # offset of the block_position
    la $t3 NEW_SHAPE_FLAG
    lw $t4 ($t3) # the address of the flag value
    lw $t7 BLOCK_SHAPE # the shape

    # if 1, then initialize a new shape
    beq $t4, 1, new_shape # initialize the shape

    
    

## PAINT THE SHAPE
paint_shape:
    lw $t5, 0($t1) # load block position
    add $t8, $t6, $t5  # add to the offset
    sw $s3, ($t8) # draw here
    
    lw $t5, 4($t1) # load block position
    add $t8, $t6, $t5  # add to the offset
    sw $s3, ($t8)
    
    lw $t5, 8($t1)
    add $t8, $t6, $t5 
    sw $s3, ($t8)
    
    lw $t5, 12($t1)
    add $t8, $t6, $t5 
    sw $s3, ($t8)
    
    # pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra


## SET NEW SHAPE
new_shape:
    # push stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    # set the new shape flag to 0
    li $t4, 0
    sw $t4, ($t3)
    
    beq $t7, 2, draw_o 
    beq $t7, 3, draw_l
    beq $t7, 4, draw_j
    beq $t7, 5, draw_t
    beq $t7, 6, draw_i
    beq $t7, 7, draw_s
    beq $t7, 8, draw_z
    


    
# these shapes are initialized
draw_o:
    lw $s3 YELLOW


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
    # $t5 is a temporary value
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
    # $t5 is a temporary value

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
    # $t5 is a temporary value
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

draw_i:
    # $t5 is a temporary value
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


draw_s:
    # $t5 is a temporary value
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

draw_z:
    # $t5 is a temporary value
    lw $s3 MINT_GREEN


    addi $t5, $zero, 16
    sw $t5, 0($t1)
    
    addi $t5, $t5, 4
    sw $t5, 4($t1)
    
    addi $t5, $t5, 128
    sw $t5, 8($t1)
    
    addi $t5, $t5, 4
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



generate_tetronimo:
    # randomize what shape to draw
    li $v0 42
    li $a1 7
    li $a0 0
    syscall
    addi $a0, $a0, 2
    sw $a0, BLOCK_SHAPE

    # pop
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
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

    li $t2 , 0 #initiate iterate counter
    li $t3, -4 #left side count
    jal check_left_border
    
    li $t2 , 0 #intiate iterate counter
    li $t3, 40 #rightside count
    jal check_right_border
    
    jal check_bottom_border # if landed on
    
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
    bge $t1, 2480, place_block
    lw $t1, 4($t0)
    bge $t1, 2480, place_block
    lw $t1, 8($t0)
    bge $t1, 2480, place_block
    lw $t1, 12($t0)
    bge $t1, 2480, place_block
    
    jr $ra
    

check_landed_on_block:
    # checks if landed in block
    # if there is a block underneath another block
    # t0, t1 are not free to use
    
    ### TO DO: PUSH RIGHT, PUSH LEFT ARE BRANCHES .... WE NEED TO CHANGE THIS
    
    # push to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    la $t4, GRID_STATE
    la $t5, BLOCK_POSITION
    
    # check where the block position is, we write the position on grid as $t6
    
    lw $t6, ($t5) # get the position of the block
    jal convert_position_to_grid # convert it to a value onto the memory address
    # if there is a block on left...
    add $t6, $t6, -4
    lw $t7 ($t6)
    bge $t7, 3, push_right
    # if there is a block on right...
    add $t6, $t6, 8
    lw $t7 ($t6)
    bge $t7, 3, push_left
    # if there is a block on bottom...
    add $t6, $t6, 36
    lw $t7 ($t6)
    bge $t7, 3, place_block
    
    lw $t6, 4($t5) # get the position of the block
    jal convert_position_to_grid # convert it to a value onto the memory address
    # if block on left...
    add $t6, $t6, -4
    lw $t7 ($t6)
    bge $t7, 3, push_right
    # if block on right...
    add $t6, $t6, 8
    lw $t7 ($t6)
    bge $t7, 3, push_left
    # if block on bottom...
    add $t6, $t6, 36
    lw $t7 ($t6)
    bge $t7, 3, place_block
    
    lw $t6, 8($t5) # get the position of the block
    jal convert_position_to_grid # convert it to a value onto the memory address
    # if block on left...
    add $t6, $t6, -4
    lw $t7 ($t6)
    bge $t7, 3, push_right
    # if block on right...
    add $t6, $t6, 8
    lw $t7 ($t6)
    bge $t7, 3, push_left
    # if block on bottom...
    add $t6, $t6, 36
    lw $t7 ($t6)
    bge $t7, 3, place_block
    
    lw $t6, 12($t5) # get the position of the block
    jal convert_position_to_grid # convert it to a value onto the memory address
    # if block on left...
    add $t6, $t6, -4
    lw $t7 ($t6)
    bge $t7, 3, push_right
    # if block on right...
    add $t6, $t6, 8
    lw $t7 ($t6)
    bge $t7, 3, push_left
    # if block on bottom...
    add $t6, $t6, 36
    lw $t7 ($t6)
    bge $t7, 3, place_block
    
    #pop stack
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra

    

check_line:
    # check each line if there are values greater than 1
    # if there is set to 0,
    # redraw grid
    # drops the tetronimo down
    

place_block:
    #push to stack
    addi $sp, $sp, -4
    sw $ra, ($sp)
    
    # signal to create a new shape
    la $t4, NEW_SHAPE_FLAG
    li $t5, 1
    sw $t5, ($t4)
    

    # update blocks in the grid
    jal update_state_grid
    #if new 
    jal generate_tetronimo
    
    #pop
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    jr $ra

update_state_grid:
    #set values 
  
    la $t4, GRID_STATE
    la $t5, BLOCK_POSITION
    lw $t8, BLOCK_SHAPE 
    addi $sp, $sp, -4
    sw $ra, ($sp) 
    

    lw $t6, ($t5) # get the position of the block
    jal convert_position_to_grid # convert it to a value onto the memory address
    sw $t8, ($t6)

    lw $t6, 4($t5)
    jal convert_position_to_grid
    sw $t8, ($t6)
    
    lw $t6, 8($t5)
    jal convert_position_to_grid
    sw $t8, ($t6)
    
    lw $t6, 12($t5)
    jal convert_position_to_grid 
    sw $t8, ($t6)
    
    lw $ra, ($sp)
    add $sp, $sp, 4
    jr $ra

convert_position_to_grid:
    # this snippet tells us what position we are in the grid state
    # divide it by 128...
    # store quotient
    # store remainder1
    # remainder1 divide it by 4
    # quotient mult it by 10
    # should be a quotient*10 + remainder1 should be a value 0:200
    # (quotient*40) + remainder
    
    li $t2, 128
    addi $t6, $t6, -128
    div $t6, $t2
    
    mfhi $t3 #remainder
    mflo $t7 #quotient
    li $t2, 40
    mul $t6, $t7, $t2
    add $t6, $t3, $t6
    
    add $t6, $t6, $t4 #returns position on grid

    
    lw $ra ($sp)
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
    beq $a0, 0x71, END_GAME         # check if the key q was pressed if so, quit game
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
    #jal block_rotate
    
    # print $a0
    li $v0, 1                       # ask system to print $a0
    syscall
    
    # print newline
    li $v0, 11
    li $a0, 10
    syscall
    
    # goes back to wherever.
    jr $ra


game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
    # 5. Go back to 1
    
    
    jal keyboard_main # check input
    jal collision # check for collision
    jal draw # draw 
    jal tick # sleep


    
    b game_loop    



END_GAME: # rip
	li $v0, 1                   
    syscall 