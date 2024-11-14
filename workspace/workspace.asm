main:
li $t0, 0
jal simple
li $t0, 1
j end_of_main

simple:
li $t0, 2
jr $ra

end_of_main: