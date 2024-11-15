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
beqz $a0,zero_base_case   #if n=0 return 0
beq $a0,1,one_base_case   #if n=1 return 1


addi $sp,$sp,-4  
sw $ra,0($sp)

addi $a0,$a0,-1   
jal fib_recur     
add $a0,$a0,1

lw $ra,0($sp)   
add $sp,$sp,4


addi $sp,$sp,-4  
sw $v0,0($sp)

addi $sp,$sp,-4   
sw $ra,0($sp)

addi $a0,$a0,-2  
jal fib_recur     
add $a0,$a0,2

lw $ra,0($sp)   
add $sp,$sp,4
lw $s7,0($sp)   
add $sp,$sp,4

add $v0,$v0,$s7 
jr $ra

zero_base_case:
	li $v0, 0
	jr $ra
one_base_case:
	li $v0, 1
	jr $ra
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
	addi $sp, $sp, -20   # Allocate space on stack for 5 items: $ra, $s0, $s1, $a0, and loop counter
	sw $ra, 0($sp)       # Save return address
	sw $s0, 4($sp)       # Save $s0 (we will use it for temporary storage)
	sw $s1, 8($sp)       # Save $s1 (used for accumulating result)
	sw $a0, 12($sp)      # Save original argument $a0 (n)
	sw $t2, 16($sp)      # Save $t2 if used before calling this function

	li $t0, 1            # Load immediate 1 into $t0 for comparison
	li $s1, 0            # Initialize accumulator for result in $s1

	ble $a0, $t0, return_one # If n <= 1, return 1 as Catalan number

    # Initialize loop counter, $t2 = 0
	li $t2, 0

loop_start:
	blt $t2, $a0, recursive_part # If $t2 < n, continue recursion
	j end_loop                   # Else, end loop

recursive_part:
	move $a0, $t2                # Prepare first argument for recursive call
	jal catalan_recur            # Recursive call catalan_recur(i)
	move $s0, $v0                # Store the result of catalan_recur(i) in $s0

	lw $a0, 12($sp)              # Restore $a0 (n) for calculation of n-i-1
	sub $a1, $a0, $t2            # n - i
	addi $a1, $a1, -1            # n - i - 1
	move $a0, $a1                # Prepare second argument for recursive call
	jal catalan_recur            # Recursive call catalan_recur(n-i-1)

	mul $s0, $s0, $v0            # Multiply results: catalan_recur(i) * catalan_recur(n-i-1)
	add $s1, $s1, $s0            # Accumulate in $s1

	lw $a0, 12($sp)              # Restore $a0 for next iteration
	addi $t2, $t2, 1             # Increment loop counter
	j loop_start                 # Jump back to start of loop

end_loop:
	move $v0, $s1                # Move accumulated result to $v0
	j cleanup                    # Jump to cleanup

return_one:
	li $v0, 1                    # Set return value to 1 for base case

# I kept running into memory overflow issues so I implemented some clean up
cleanup:
	lw $ra, 0($sp)               # Restore $ra
	lw $s0, 4($sp)               # Restore $s0
	lw $s1, 8($sp)               # Restore $s1
	lw $a0, 12($sp)              # Restore $a0
	lw $t2, 16($sp)              # Restore $t2
	addi $sp, $sp, 20            # Went down 20 so go up 20 to restore stack
	jr $ra                       # Return
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

la $s1, data_buffer
loop3a:
lb $t0, ($s1)
beqz $t0, end3
beq $t0, 0x0A, next
beq $t0, 0x20, next
addi $t1, $t0, -48
mul $t1, $t1, 10
add $t1, $t1, $t0
j loop3a
next:
end3:
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
