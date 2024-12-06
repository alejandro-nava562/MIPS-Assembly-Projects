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

# Registers needed:

#t0 = x (current column)
#t1 = y (current row)
# t2 = address of input pixel (input buffer)
# t3 = address of output pixel (output buffer)
# t4 = x' (transformed coordinate)
# t5 = y' (transformed coordinate)
# t6 = temp for matrix element
# t7 = temp for pixel value
# t8 = image dimension

transform:
############################### Part 2: your code begins here ##
    li $t0, 0            # Initialize x (column index)
    li $t1, 0            # Initialize y (row index)
    move $t8, $a3        # Store image dimension in $t8 (DO NOT OVERWRITE)

outer_loop:              # Loop over rows (y)
    beq $t1, $t8, done_transform  # Exit if all rows processed
    li $t0, 0            # Reset x (column index) at the start of a new row

inner_loop:              # Loop over columns (x)
    beq $t0, $t8, next_row # Exit if all columns in the row are processed

    # Calculate x' = M[0][0]*x + M[0][1]*y + M[0][2]
    lw $t4, 0($a2)        # Load M[0][0]
    mul $t4, $t4, $t0     # M[0][0] * x

    lw $t5, 4($a2)        # Load M[0][1]
    mul $t5, $t5, $t1     # M[0][1] * y
    add $t4, $t4, $t5     # Add M[0][0]*x + M[0][1]*y

    lw $t6, 8($a2)        # Load M[0][2]
    add $t4, $t4, $t6     # Add M[0][2] to x'

    # Calculate y' = M[1][0]*x + M[1][1]*y + M[1][2]
    lw $t7, 12($a2)       # Load M[1][0]
    mul $t7, $t7, $t0     # M[1][0] * x

    lw $t9, 16($a2)       # Load M[1][1]
    mul $t9, $t9, $t1     # M[1][1] * y
    add $t7, $t7, $t9     # Add M[1][0]*x + M[1][1]*y

    lw $t9, 20($a2)       # Load M[1][2]
    add $t7, $t7, $t9     # Add M[1][2] to y'

    # Check if x' and y' are within bounds
    bltz $t4, skip_pixel    # Skip if x' < 0
    bltz $t7, skip_pixel    # Skip if y' < 0
    bge $t4, $t8, skip_pixel # Skip if x' >= a3 ($t8)
    bge $t7, $t8, skip_pixel # Skip if y' >= a3 ($t8)

    # Load pixel value from input buffer
    mul $t6, $t7, $t8       # y' * dimension
    add $t6, $t6, $t4       # y' * dimension + x'
    sll $t6, $t6, 2         # Multiply by 4 (pixel size in bytes)
    add $t6, $a0, $t6       # Address of input pixel
    lbu $t9, 0($t6)         # Load pixel value into $t9

    # Store pixel value in output buffer
    mul $t6, $t1, $t8       # y * dimension
    add $t6, $t6, $t0       # y * dimension + x
    sll $t6, $t6, 2         # Multiply by 4 (pixel size in bytes)
    add $t6, $a1, $t6       # Address of output pixel
    sb $t9, 0($t6)          # Store pixel value in output buffer

skip_pixel:
    addi $t0, $t0, 1        # Increment x (column index)
    j inner_loop            # Repeat for next column

next_row:
    addi $t1, $t1, 1        # Increment y (row index)
    j outer_loop            # Repeat for next row

done_transform:
############################### Part 2: your code ends here  ##
jr $ra
###############################################################
