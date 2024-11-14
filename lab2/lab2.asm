#                                           ICS 51, Lab #2
# 
#                                          IMPORTANT NOTES:
# 
#                       Write your assembly code only in the marked blocks.
# 
#                       DO NOT change anything outside the marked blocks.
#
#

###############################################################
#                           Text Section
.text

###############################################################
###############################################################
###############################################################
#                            PART 1 (Fibonacci)
#
# 	The Fibonacci Sequence is the series of integer numbers:
#
#		0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...

#	The next number is found by adding up the two numbers before it.
	
#	The `2` is found by adding the two numbers before it (1+1)
#	The `3` is found by adding the two numbers before it (1+2),
#	And the `5` is (2+3),
#	and so on!
#
# You should compute N ($a0) number of elements of fibonacci and put
# in array, named fib_array.
# 
fibonacci:

# $a0: Number of elements. 
# fib_array: The destination array.
################## Part 1: your code begins here ###############
	# Input:
	#   $a0 - Number of Fibonacci elements to compute
	# Output:
	#   Stores the Fibonacci sequence up to N elements in fib_array

	# Initialize the first two Fibonacci values
	li $t0, 0 # $t0 holds F0, which is 0
	li $t1, 1 # $t1 holds F1, which is 1
	la $t2, fib_array

	sw $t0, 0($t2)
	sw $t1, 4($t2)

	# Handle case when N <= 2, as we've already set F0 and F1
	li $t3, 2 # Load 2 into $t3 for comparison
	ble $a0, $t3, finish # If N <= 2, skip the loop and finish

	# Prepare loop variables
	addi $t4, $zero, 2 # $t4 will act as the index starting at 2
	addi $t2, $t2, 8 # Move $t2 to point to fib_array[2]

loop:
	# Calculate the next Fibonacci value
	lw $t5, -4($t2) # Load the previous Fibonacci value (fib[i-1])
	lw $t6, -8($t2) # Load the value before that (fib[i-2])
	add $t7, $t5, $t6 # Add the last two values to get the next Fibonacci number
	sw $t7, 0($t2) # Store the new Fibonacci number in fib_array[i]

	# Update pointers and index
	addi $t2, $t2, 4
	addi $t4, $t4, 1
	blt $t4, $a0, loop     # Continue if we haven’t reached N elements
    
finish:
############################## Part 1: your code ends here   ###
jr $ra

###############################################################
###############################################################
###############################################################
#                  PART 2 (local maximum points)
# Write a function in MIPS assembly that takes an array of 
# integers and finds local maximum points. i.e., points that if 
# the input entry is larger than both adjacent entries. The 
# output is an array of the same size of the input array. The 
# output point is 1 if the corresponding input entry is a 
# relative maximum, otherwise 0. (You should ignore the output
# array's boundary items, set to 0.) 
# 
# For example,
# 
# the input array of integers is {1, 3, 2, 4, 6, 5, 7, 8}. Then,
# the output array of integers should be {0, 1, 0, 0, 1, 0, 0, 0}
# 
# (Note: The first/last entry of the output array is always 0
#  since it's ignored, never be a local maximum.)
# $a0: The base address of the input array
# $a1: The base address of the output array with local maximum points
# $a2: Size of array
find_local_maxima:
############################ Part 2: your code begins here ###
	sw $zero, 0($a1)
	addi $t0, $a2, -1 # get the last element (N - 1 )
	sll $t1, $t0, 2 # multiply by 4 to get the byte offset
	sw $zero, 0($a1)
	
	# set up the loop
	addi $t2, $a0, 4
	addi $t3, $a1, 4
	addi $t4, $a2, -2 # loop counter to (N - 2) so that we iterate from index 1 to N - 2
	
loop_find_local_maxima:
	# 3 elements being loaded: current, previous, and next element
	lw $t5, 0($t2)
	lw $t6, -4($t2)
	lw $t7, 4($t2)

	# Check if current element is greater than both neighbors
	ble $t5, $t6, not_max # If input[i] <= input[i-1], not a local maximum
	ble $t5, $t7, not_max # If input[i] <= input[i+1], not a local maximum

	# If it is a local maximum, set output[i] = 1
	li $t8, 1
	sw $t8, 0($t3)
	j next

not_max:
	# Otherwise, set output[i] = 0
	sw $zero, 0($t3)

next:
	# Move to the next elements
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	addi $t4, $t4, -1
	bgtz $t4, loop_find_local_maxima

############################ Part 2: your code ends here ###
jr $ra

###############################################################
###############################################################
###############################################################
#                       PART 3 (Change Case)
# Complete the change_case function that takes a Null-terminated
# string and converts the lowercase characters (a-z) to 
# uppercase and convert the uppercase ones (A-Z) to lower case. 
# Your function should also ignore non-alphabetical characters. 
# For example, "L!A##b@@3" should be converted to "laB". 
# In null-terminated strings, end of the string is specified 
# by a special null character (i.e., value of 0).

#a0: The base address of the input array
#a1: The base address of the output array
###############################################################
change_case:
############################## Part 3: your code begins here ###
    lb $t0, 0($a0)

# Loop until we reach the null character
loop_change_case:
	beq $t0, $zero, end_loop  # If current character is null (0) we are done

        # Check if character is uppercase (A-Z)
	li $t1, 65                
	li $t2, 90                
        blt $t0, $t1, check_lower # If char < 'A', check if it's lowercase
        bgt $t0, $t2, check_lower # If char > 'Z', check if it's lowercase

        # Convert uppercase to lowercase
        addi $t0, $t0, 32 # Add 32 to convert to lowercase
        j store_char # Store the converted character

check_lower:
        # Check if character is lowercase (a-z)
        li $t1, 97
        li $t2, 122
        blt $t0, $t1, next_char
        bgt $t0, $t2, next_char

        # Convert lowercase to uppercase
        subi $t0, $t0, 32 # Subtract 32 to convert to uppercase

store_char:
        sb $t0, 0($a1)
        addi $a1, $a1, 1

next_char:
        addi $a0, $a0, 1
        lb $t0, 0($a0)
        j loop_change_case

end_loop:
        sb $zero, 0($a1) # Append null character to the end of the output str
############################## Part 3: your code ends here ###
jr $ra
