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
add $sp,$sp, 4            

# Save result of fib(n-1) on stack
addi $sp,$sp, -4         
sw $v0,0($sp) # Store result of fib(n-1)

# Save return address on stack before recursive call for fib(n-2)
addi $sp,$sp, -4         
sw $ra,0($sp) # Save return address to the stack

# Prepare for recursive call to calculate fib(n-2)
addi $a0,$a0,-2 # Set argument to n-2
jal fib_recur 
add $a0,$a0,2 # Restore original value of $a0 after returning

# Restore return address from the stack
lw $ra,0($sp)           
add $sp,$sp,4            

# Load result of fib(n-1) from the stack
lw $t7,0($sp)         
add $sp,$sp,4         

# Calculate fib(n) = fib(n-1) + fib(n-2) and return
add $v0,$v0,$t7
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
# Save $s registers to the stack
addi $sp, $sp, -12      # Allocate space on the stack
sw $s1, 0($sp)          # Save $s1 (data buffer pointer)
sw $s0, 4($sp)          # Save $s0 (distance array pointer)
sw $s2, 8($sp)          # Save $s2 (any additional $s register used)

la $s1, data_buffer     # Load the data buffer pointer
li $t1, 0               # Temporary register for current number
li $t9, 0               # Flag for negative number
la $s0, dist_array      # Load the distance array pointer
li $v0, 0               # Counter for number of distances calculated

loop3a:
    lb $t0, ($s1)        # Load the current byte
    beqz $t0, end3       # If null terminator (end of buffer), exit loop
    beq $t0, 0x0A, end_of_line   # Branch on newline
    beq $t0, 0x20, next  # Branch on space
    beq $t0, 0x2D, flag_neg # Branch on '-' (negative flag)

    # Convert ASCII digit to integer and update $t1
    addi $t0, $t0, -48   # ASCII to integer
    mul $t1, $t1, 10     # Multiply $t1 by 10
    add $t1, $t1, $t0    # Add the digit
    addi $s1, $s1, 1     # Move to the next byte
    j loop3a

flag_neg:
    li $t9, 1            # Set negative flag
    addi $s1, $s1, 1     # Move to the next byte
    j loop3a

next:
    # Check if the number is negative and finalize the first/second number
    bne $t9, 0, make_neg # If negative flag is set, negate $t1
    move $t2, $t1        # Store the current number in $t2
    li $t1, 0            # Reset $t1 for the next number
    j incre_loop

make_neg:
    sub $t1, $zero, $t1  # Negate $t1
    li $t9, 0            # Clear the negative flag
    j next

end_of_line:
    # Check if the last number in the line is negative
    bne $t9, 0, make_neg_eol

    # Calculate distance
    sub $t2, $t1, $t2    # $t1 (current number) - $t2 (previous number)
    bgez $t2, store_dist 
    sub $t2, $zero, $t2  
    j store_dist

make_neg_eol:
    sub $t1, $zero, $t1  
    li $t9, 0            
    j end_of_line

store_dist:
    sw $t2, ($s0)        
    addi $s0, $s0, 4     
    addi $v0, $v0, 1     
    li $t1, 0            
    li $t2, 0           
    addi $s1, $s1, 1     
    j loop3a

incre_loop:
    li $t1, 0            # Reset $t1
    addi $s1, $s1, 1     # Increment pointer
    j loop3a

end3:
    # Restore $s registers from the stack
    lw $s1, 0($sp)       # Restore $s1
    lw $s0, 4($sp)       # Restore $s0
    lw $s2, 8($sp)       # Restore $s2
    addi $sp, $sp, 12    # Deallocate stack space
    jr $ra               # Return to caller


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
# Save $s registers (callee-saved)
    addi $sp, $sp, -12      # Allocate stack space
    sw $s0, 0($sp)          # Save $s0 (distance array pointer)
    sw $s1, 4($sp)          # Save $s1 (data_buffer pointer)
    sw $s2, 8($sp)          # Save $s2 (counter)

    # Initialize pointers and counters
    move $s0, $a1           # $s0: pointer to distance array
    la   $s1, data_buffer   # $s1: pointer to data_buffer
    move $s2, $a2           # $s2: number of distances to save

convert_loop:
    beqz $s2, conversion_done  # If $s2 == 0, we're done
    lw   $t0, 0($s0)           # Load next distance from array
    addi $s0, $s0, 4           # Move to next integer in array
    addi $s2, $s2, -1          # Decrement number of distances to save

    # Handle zero explicitly
    bnez $t0, convert_nonzero

    # If zero, store '0' and newline
    li   $t3, 48               # ASCII '0'
    sb   $t3, ($s1)
    addi $s1, $s1, 1
    li   $t3, 0x0A             # ASCII newline
    sb   $t3, ($s1)
    addi $s1, $s1, 1
    j    convert_loop

convert_nonzero:
    # Prepare for conversion
    addi $sp, $sp, -40         # Allocate space for digits (max 10 digits)
    move $t4, $sp              # $t4 points to digit storage
    li   $t1, 0                # $t1: digit count

convert_digits:
    bgtz $t0, extract_digit    # If $t0 > 0, extract digit
    j     output_digits        # Else, output digits

extract_digit:
    li   $t5, 10
    div  $t0, $t5              # Divide $t0 by 10
    mfhi $t2                   # $t2: remainder
    mflo $t0                   # $t0: quotient

    addi $t2, $t2, 48          # Convert digit to ASCII
    subi $t4, $t4, 1           # Decrement $t4 to store digit in reverse order
    sb   $t2, ($t4)            # Store digit
    addi $t1, $t1, 1           # Increment digit count
    j    convert_digits

output_digits:
    # Adjust $t4 to point to the first digit
    move $t5, $t4              # $t5 points to the first digit stored
    add  $t4, $t4, $t1         # Reset $t4 to the position after all digits

output_digit_loop:
    beqz $t1, store_newline    # If no more digits, store newline
    lb   $t2, 0($t5)           # Load digit from reversed storage
    sb   $t2, ($s1)            # Store digit in data_buffer
    addi $s1, $s1, 1           # Increment data_buffer pointer
    addi $t5, $t5, 1           # Move to the next digit
    addi $t1, $t1, -1          # Decrement digit count
    j    output_digit_loop

store_newline:
    addi $sp, $sp, 40          # Deallocate digit storage
    li   $t3, 0x0A             # ASCII newline
    sb   $t3, ($s1)
    addi $s1, $s1, 1           # Increment data_buffer pointer
    j    convert_loop          # Process next integer

conversion_done:
    # Open the output file
    li   $v0, 13               # syscall: open file
    move $a0, $a0              # Output file name in $a0
    li   $a1, 1                # Flags: 1 (write)
    li   $a2, 0                # Mode: 0 (ignored)
    syscall
    move $t0, $v0              # File descriptor in $t0

    # Calculate number of bytes to write
    la   $t1, data_buffer      # Start of data_buffer
    subu $a2, $s1, $t1         # $a2 = number of bytes to write

    # Write to file
    li   $v0, 15               # syscall: write to file
    move $a0, $t0              # File descriptor
    la   $a1, data_buffer      # Buffer to write
    # $a2 already contains number of bytes
    syscall

    # Close the file
    li   $v0, 16               # syscall: close file
    move $a0, $t0              # File descriptor
    syscall

    # Restore $s registers and return
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    addi $sp, $sp, 12          # Deallocate stack space
    li   $v0, 0                # Success
    jr   $ra
############################### Part 3B: your code ends here   ##
jr $ra
