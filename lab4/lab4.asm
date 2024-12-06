#                         ICS 51, Lab #4
#
#      IMPORTANT NOTES:
#
#      Write your assembly code only in the marked blocks.
#
#      DO NOT change anything outside the marked blocks.
#
###############################################################
#                           Text Section
.text

###############################################################
###############################################################
#                       PART 1 (Image Thresholding)
#a0: input buffer address
#a1: output buffer address
#a2: image dimension (Image will be square sized, i.e., number of pixels = a2*a2)
#a3: threshold value 
###############################################################
threshold:
############################## Part 1: your code begins here ###
li $t0, 0 # index for the current pixel
mul $t1, $a2, $a2 # Total number of pixels for the image

loop_threshold:
	beq $t0, $t1, done_threshold
	# calculate input pixel address
	add $t2, $a0, $t0
	lbu $t3, 0($t2) # load the pixel value (8 bits = 1 byte)
	
	# compare to the threshold
	sltu $t4, $t3, $a3 # use a3 to compare the threshold and set $t4 to 1 if pixel < threshold
	beq $t4, $zero, bright
	
	# set the pixel to dark otherwise
	# dark hex value: (0x00)
	li $t5, 0x00
	add $t6, $a1, $t0 # $t6 = output buffer
	sb $t5, 0($t6) # store dark value in output buffer
	j next_pixel
bright:
	# set values to bright values if the threshold is not met
	# bright hex value: (0xFF)
	li $t5, 0xFF # Bright value
	add $t6, $a1, $t0
	sb $t5, 0($t6)

next_pixel:
	addi $t0, $t0, 1 # go to the next pixel
	j loop_threshold # repeat loop

done_threshold: # all done processing pixels
############################## Part 1: your code ends here ###
jr $ra

###############################################################
###############################################################
#                           PART 2 (Matrix Transform)
#a0: input buffer address
#a1: output buffer address
#a2: transform matrix address
#a3: image dimension  (Image will be square sized, i.e., number of pixels = a3*a3)
###############################################################
transform:
############################### Part 2: your code begins here ##
# Outer loop: iterate over rows (y)
    li $t6, 0               # $t6 = y (initialize row index)
Outer_Loop:
    bge $t6, $a3, Exit_Loop # Exit if y >= image dimension

    # Inner loop: iterate over columns (x)
    li $t7, 0               # $t7 = x (initialize column index)

Inner_Loop:
    bge $t7, $a3, Next_Row  # Exit if x >= image dimension

    # Calculate x' = M[0][0]*x + M[0][1]*y + M[0][2]
    lw $t3, 0($a2)          # Load M[0][0]
    mul $t8, $t3, $t7       # $t8 = M[0][0] * x

    lw $t3, 4($a2)          # Load M[0][1]
    mul $t9, $t3, $t6       # $t9 = M[0][1] * y
    add $t8, $t8, $t9       # $t8 += $t9 (M[0][0]*x + M[0][1]*y)

    lw $t3, 8($a2)          # Load M[0][2]
    add $t8, $t8, $t3       # $t8 += M[0][2] (x')

    # Calculate y' = M[1][0]*x + M[1][1]*y + M[1][2]
    lw $t3, 12($a2)         # Load M[1][0]
    mul $t9, $t3, $t7       # $t9 = M[1][0] * x

    lw $t3, 16($a2)         # Load M[1][1]
    mul $t2, $t3, $t6       # $t2 = M[1][1] * y
    add $t9, $t9, $t2       # $t9 += $t2 (M[1][0]*x + M[1][1]*y)

    lw $t3, 20($a2)         # Load M[1][2]
    add $t9, $t9, $t3       # $t9 += M[1][2] (y')

    # Check if x' and y' are within bounds
    bltz $t8, Skip_Pixel     # Skip if x' < 0
    bltz $t9, Skip_Pixel     # Skip if y' < 0
    bge $t8, $a3, Skip_Pixel # Skip if x' >= image dimension
    bge $t9, $a3, Skip_Pixel # Skip if y' >= image dimension

    # Compute input buffer address for (x', y')
    mul $t2, $t9, $a3        # $t2 = y' * image dimension
    add $t2, $t2, $t8        # $t2 += x'
    mul $t2, $t2, 1
    
    addu $t2, $a0, $t2        # $t2 = input buffer address + $t2

    # Load pixel value from input buffer
    lbu $t3, 0($t2)          # $t3 = input_pixel_value (byte load)

    sb $t3, 0($a1)           # Store pixel in output buffer (byte store)
    j jump_pixel

Skip_Pixel:
	li $t3, 0
	sb $t3, ($a1)
	j jump_pixel

jump_pixel:
    addi $t7, $t7, 1         # Increment x (column index)
    addi $a1, $a1, 1
    j Inner_Loop             # Repeat for next column

Next_Row:
    addi $t6, $t6, 1         # Increment y (row index)
    j Outer_Loop             # Repeat for next row

Exit_Loop:
############################### Part 2: your code ends here  ##
jr $ra
###############################################################
