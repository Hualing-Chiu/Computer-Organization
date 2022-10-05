main:
    addi $a0, $zero, 19654 # a0= 19654
    addi $a1, $zero, 100654  # a1=100654
    addi $a2, $zero, 10065  # a2= 10065
    jal average     # call average
    j exit

average:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)    # Save $ra register into stack

    add $t1,$a0,$a1
    add $t0,$t1,$a2 # add three numbers
    #addi $t2,$zero,3 # t2=3
    addi $t4,$zero,0 # quotient=t0=0 
    Loop:
    	sub $t0,$t0,3
    	addi $t4,$t4,1
    	slti $t2,$t0,3 #if(t0<3) $t2=1
    	add $v0,$t4,$zero # load in $v0 
    	beq $t2,1,Exit
    	j Loop
    Exit:	
    lw $ra, 0x0($sp)    # Load $ra register from stack
    addi $sp, $sp, 4
    jr $ra

exit:
