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



############################## Part 3: your code ends here ###
jr $ra

