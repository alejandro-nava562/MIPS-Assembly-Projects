    .data
my_int: .word 0x00AF00AF      # Define my_int as a word with the value 0x00AF00AF

    .text
    .globl main
main:
    la $t0, my_int             # Load the address of my_int into $t0
    li $t1, 0xAAAAAAAA         # Initialize $t1 with 0xAAAAAAAA (for comparison purposes)
    
    lb $t1, 0($t0)             # Load byte from address in $t0 into $t1 with sign-extension

    # End of program (loop here to observe result in a simulator like MARS)
end:
    j end                      # Infinite loop to hold the program
