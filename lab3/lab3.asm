#                         ICS 51, Lab #3
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
###############################################################
#                           PART 1 (fib_recur)
# $a0: input number
###############################################################
fib_recur:
############################### Part 1: your code begins here ##
# Compute and return fibonacci number
beqz $a0, zero_base_case	# if n == 0, go to zero_base_case (return 0)
beq $a0,1, one_base_case	# if n == 1, go to one_base_case (return 1)

# Save return address on stack before recursive call for fib(n-1)
addi $sp,$sp,-4  # Allocate space on the stack for return address
sw $ra,0($sp)  # Save return address to the stack

# Prepare for recursive call to calculate fib(n-1)
addi $a0,$a0,-1  
jal fib_recur # Jump to fib_recur to calculate fib(n-1)
add $a0,$a0,1         

# Restore return address from the stack
lw $ra,0($sp)            
add $sp,$sp,4            

# Save result of fib(n-1) on stack
addi $sp,$sp,-4         
sw $v0,0($sp) # Store result of fib(n-1)

# Save return address on stack before recursive call for fib(n-2)
addi $sp,$sp,-4         
sw $ra,0($sp) # Save return address to the stack

# Prepare for recursive call to calculate fib(n-2)
addi $a0,$a0,-2 # Set argument to n-2
jal fib_recur 
add $a0,$a0,2 # Restore original value of $a0 after returning

# Restore return address from the stack
lw $ra,0($sp)           
add $sp,$sp,4            

# Load result of fib(n-1) from the stack
lw $s7,0($sp)         
add $sp,$sp,4         

# Calculate fib(n) = fib(n-1) + fib(n-2) and return
add $v0,$v0,$s7
jr $ra                   

# Base case for n = 0
zero_base_case:
    li $v0, 0 # Set $v0 to 0 for base case n = 0
    jr $ra  # Return to caller

# Base case for n = 1
one_base_case:
    li $v0, 1 # Set $v0 to 1 for base case n = 1
    jr $ra  # Return to caller
############################### Part 1: your code ends here  ##
jr $ra

###############################################################
###############################################################
###############################################################
#                           PART 2 (catalan_recur)
# $a0: input number
###############################################################
catalan_recur:
############################### Part 2: your code begins here ##
	# need to make 5 registry spaces so that we can store and save values we need to remember
	sub $sp, $sp, 20
	sw $t3, 16($sp)
	sw $a0, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	li $t0, 1
	li $s1, 0
	ble $a0, $t0, return_one_base_case
	li $t3, 0
loop_start_catalan:
	blt $t3, $a0, recursive_calculations
	j end_loop
recursive_calculations:
	move $a0, $t3
	jal catalan_recur
	move $s0, $v0
	lw $a0, 12($sp)
	sub $a1, $a0, $t3
	addi $a1, $a1, -1
	move $a0, $a1
	jal catalan_recur
	mul $s0, $s0, $v0
	add $s1, $s1, $s0
	lw $a0, 12($sp)
	addi $t3, $t3, 1
	j loop_start_catalan
end_loop:
	move $v0, $s1
	j restore_pointers
return_one_base_case:
	li $v0, 1
# ran into memory issues so we have to clean up after the fact
restore_pointers:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $a0, 12($sp)
	lw $t3, 16($sp)
	addi $sp, $sp, 20
	jr $ra
############################### Part 2: your code ends here  ##
jr $ra

###############################################################
###############################################################
###############################################################
#                           PART 3A (SYSCALL: file read, ASCII to Integer)
#
# $a0: the address of the string that represents the input file name
# $a1: the base address of an integer array that will be used to store distances
# data_buffer : the buffer that you use to hold data for file read (MAXIMUM: 300 bytes)
load_pts_file:
############################### Part 3A: your code begins here ##

li   $v0, 13       # system call for open file
# a0 is already ready for file name
li   $a1, 0        # Open for reading (flags are 0: read, 1: write)
li   $a2, 0        # mode is ignored
syscall            # open a file (file descriptor returned in $v0)
move $t0, $v0      # save the file descriptor 

li   $v0, 14       # system call for read file
move $a0, $t0      # file descriptor 
la   $a1, data_buffer   # address of buffer from which to read
li   $a2, 300       # max hardcoded buffer length
syscall            # read file

li $v0, 16 # close file
move $a0, $t0 # file descrip to close
syscall

# +------------
# sample code stuff we can change
la $s1, data_buffer
li $t4, 0 # index in integer array
li $t5, 0 # store current number
li $t6, 0 # variable to signal if we are reading first or second
li $t7, 0 # store second number
loop3a:
	lb $t0, ($s1) # loading the byte from data_buffer
	beqz $t0, end3
	beq $t0, 0x0A, process
	beq $t0, 0x20, process
	
	# converting ASCII to Integer
	addi $t0, $t0, -48
	
	mul $t5, $t5, 10
	add $t5, $t5, $t0
	j next
process:
	beq $t6, 0, store_first # if reading the first number $t6 will be 0 so jump there
	move $t7, $t5
	sub $t8, $t7, $t9 # calculate the distance (second - first)
	
	# negative distance handling
	bltz $t8, make_positive
	j store_distance
make_positive:
	neg $t8, $t8
store_distance:
	sw $t8, 0($a1)
	addi $a1, $a1, 4
	li $t6, 0
	li $t5, 0
	addi $t4, $t4, 1
	j next
store_first:
	move $t9, $t5 # store the first num
	li $t6, 1 # we stored the first num so now $t6 is 1
	li $t5, 0
	j next
next:
	addi $s1, $s1, 1 # move to next char
	j loop3a
end3:
	move $v0, $t4 # return the num of distance calculated
############################### Part 3A: your code ends here   ##
jr $ra

###############################################################
###############################################################
###############################################################
#                           PART 3B (SYSCALL: file write, Integer to ASCII)
#
# $a0: the address of the string that represents the output file name
# $a1: the base address of an integer array that stores distances
# $a2: the number of valid distances to the integer array
# data_buffer : the buffer that you use to hold data for file read (MAXIMUM: 300 bytes)
save_dist_list:
############################### Part 3B: your code begins here ##

############################### Part 3B: your code ends here   ##
jr $ra
