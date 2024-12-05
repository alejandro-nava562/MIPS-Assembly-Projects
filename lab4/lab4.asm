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

############################### Part 2: your code ends here  ##
jr $ra
###############################################################
