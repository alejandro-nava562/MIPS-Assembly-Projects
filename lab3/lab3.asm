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
	# need to make 5 registry spaces so that we can store and save values we need to remember
	sub $sp, $sp, 20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $a0, 12($sp)
	sw $t2, 16($sp)
	li $t0, 1
	li $s1, 0
	ble $a0, $t0, return_one_base_case
	li $t2, 0
loop_start_catalan:
	blt $t2, $a0, recursive_calculations
	j end_loop
recursive_calculations:
	move $a0, $t2
	jal catalan_recur
	move $s0, $v0
	lw $a0, 12($sp)
	sub $a1, $a0, $t2
	addi $a1, $a1, -1
	move $a0, $a1
	jal catalan_recur
	mul $s0, $s0, $v0
	add $s1, $s1, $s0
	lw $a0, 12($sp)
	addi $t2, $t2, 1
	j loop_start_catalan
end_loop:
	move $v0, $s1
	j cleanup_memory
return_one_base_case:
	li $v0, 1
# ran into memory issues so we have to clean up after the fact
cleanup_memory:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $a0, 12($sp)
	lw $t2, 16($sp)
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
