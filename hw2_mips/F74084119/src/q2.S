main:
    addi $a0, $zero, 10 # n = 10
    addi $a1, $zero, 5  # m = 5
    jal pascal          # call pascal(10, 5)
    j exit

pascal:
    bne $a1,$zero,other_pascal	    # if(a1!=0) goto other_pascal
    #bne $a0,$a1,pascal_recurse      # if(a0!=a1) goto pascal_recurse
    addi $v0,$zero,1	# return 1
    jr $ra
other_pascal:
    bne $a0,$a1,pascal_recurse      # if(a0!=a1) goto pascal_recurse
    addi $v0,$zero,1
    jr $ra
pascal_recurse:
    addi $sp, $sp, -16
    sw $ra, 0x0($sp)    # Save $ra register into stack
    sw $a0,0x4($sp)	# Save a0
    sw $a1,0x8($sp)	# Save a1
    
    addi $a0,$a0,-1	# n-1
    addi $a1,$a1,-1	# m-1
    jal pascal  
    lw $a0,0x4($sp)
    lw $a1,0x8($sp)
    sw $v0,12($sp)
    
    addi $a0,$a0,-1	# n-1
    add $a1,$a1,$zero	# m-0
    jal pascal
    
    lw $t0,12($sp)
    add $v0,$t0,$v0
    
    lw $ra, 0x0($sp)    # Load $ra register from stack
    addi $sp, $sp, 16
    jr $ra

exit:
