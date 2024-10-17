#                                           ICS 51, Lab #1
# 
#                                          IMPORTATNT NOTES:
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
#                            PART 1 (Swap Bits)
# 
# You are given an 32-bits integer stored in $a0. You need swap the bits
# at odd and even positions. i.e. b31 <-> b30, b29 <-> b28, ... , b1 <-> b0
# 
# Implementation details:
# The integer is stored in register $a0. You need to store the answer 
# into register $v0 in order to be returned by the function to the caller.
swap_bits:
############################## Part 1: your code begins here ###

# Utilize "masks" for the AND operator to extract the even and odd bits that are present in our number
# shift the bits around -> use OR operator to combine both even and odd bits thereafter

# 32 bit numebr = 4 bytes = 2 hex numbers per byte = 4 bits per hex number
li $t0, 0xAAAAAAAA # Extract the odd bits (binary: 10101010101010101010101010101010)
li $t1, 0x55555555 # Extract the even bits (binary: the opposite of above)

# Isolate and extract the even/odd bits
# %$a0 is the default input register for arguments

and $t2, $a0, $t0 # $t2 will now have the extracted odd bits
and $t3 $a0, $t1 # t3 will now have the extraced even bits

#shifting time
srl $t2, $t2, 1 # shift the odd bits to the right
sll $t3, $t3, 1 # shift the even bits to the left

# combine
or $v0, $t2, $t3

############################## Part 1: your code ends here ###
jr $ra

###############################################################
###############################################################
###############################################################
#                           PART 2 (Triple Range)
# 
# You are given three integers. You need to find the smallest 
# one and the largest one and multiply their sum by three and return it.
# 
# Implementation details:
# The three integers are stored in registers $a0, $a1, and $a2. You 
# need to store the answer into register $v0 in order to be returned by 
# the function to the caller.
triple_range:
############################### Part 2: your code begins here ##

# find smallest and largest numbers 
# need branching to determine what to do after comparing values
slt $t0, $a0, $a1 # If $a0 < $a1, %t0 = 1, else $t0 = 0
beq $t0, $zero, else_a1_smaller # if $t0 is 0, it means $a1 is smaller, so skip
move $t1, $a0 # case for when $a0 is smaller of the two
j compare_to_a2 # jump to compare whatever value we have against $a2

else_a1_smaller:
move $t1, $a1 #a1 is the smaller number here so we want to set $t1 to the smaller number

compare_to_a2:
slt $t0, $a2, $t1 # case for if $a2 is the smallest
beq $t0, $zero, find_largest # case for when $a2 is not the smallest, therefore we don't want to update $t1 with $a2's value
move $t1, $a2 # a2 is smallest number here so let's store it

# $t1 is the final register for the smallest number

#find the largest number now
find_largest:
slt $t0, $a0, $a1 # if $a0 < $a1 -> $t0 = 1
beq $t0, $zero, else_a0_larger # if $a0 is larger, then $t0 will have value 0
move $t2, $a1 # a1 is larger in this case so store it to compare to $a2
j compare_to_a2_largest

else_a0_larger:
move $t2, $a0

compare_to_a2_largest:
slt $t0, $t2, $a2 # if (largest so far) < $a2 -> $t0 = 1
beq $t0, $zero, after_comparison # (largest so far) > $a2
move $t2, $a2 # a2 is largest in this case so store it

after_comparison: # a2 was smaller so no updating needed, we already found the largest number

# t2 is the final register for the largest number

# sum and multiply numbers together
add $t3, $t1, $t2
li $t0, 3 # load 3 for multiplication
mul $v0, $t3, $t0 # store the final result


############################### Part 2: your code ends here  ##
jr $ra

###############################################################
###############################################################
###############################################################
#                            PART 3 (Determinant)
# 
# You are given a 2x2 matrix and each element is a 16-bit 
# signed integer. Calculate its determinant.
# 
# Implementation details:
# The four 16-bit integers are stored in registers $a0, $a1. 
# You need to store the answer into register $v0 in order to 
# be returned by the function to the caller.
determinant:
############################## Part 3: your code begins here ###

# determinant from linera algebra follows det(A) = ad - bc
# a b -> $a0 upper and lower bits
# c d -> $a1 uper and lower bits
# sign extension is important here to perseve sign bits!!! 

# extract each variable by using bitwise operations like shifting
sra $t0, $a0, 16 # shift $a0 right by 16 bits -> value of 'a'
andi $t1, $a0, 0xFFFF # binary(1111 1111 1111 1111) only 2 bytes since we want the lower half of the number -> value of 'b'
sll $t1, $t1, 16       # Shift left 16 bits
sra $t1, $t1, 16       # Sign-extend lower 16 bits for 'b'


sra $t2, $a1 16 # value of 'c'
andi $t3, $a1, 0xFFFF # value of 'd'
sll $t3, $t3, 16       # Shift left 16 bits
sra $t3, $t3, 16       # Sign-extend lower 16 bits for 'd'

mul $t4, $t0, $t3 # a * d -> $t4
mul $t5, $t1, $t2 # b * c -> $t5

sub $v0, $t4, $t5


############################## Part 3: your code ends here ###
jr $ra

