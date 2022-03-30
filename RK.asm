.data
    message1:  .asciiz "Enter initial condition\nx0 = "
    message2:  .asciiz "y0 = "
    message3:  .asciiz "Enter calculation point xn = "
    message4:  .asciiz "Enter number of steps n = "
    message5:  .asciiz "x0      y0      yn\n"
    message6:  .asciiz "      "
    message7:  .asciiz "\n"
    message8:  .asciiz "The result is:\nxn = "
    message9:  .asciiz "yn = "
    var_a:     .float  0.0  # var_a is used as the first transmitted parameter for the derivative procedure
    var_b:     .float  0.0  # var_b is used as the second transmitted parameter for the derivative procedure
    x0:        .float  0.0
    x0_half_h: .float 0.0   # x0_half_h = x0 + h / 2
    y0:        .float  0.0
    xn:        .float  0.0
    yn:        .float  0.0
    h:         .float  0.0
    half_h:    .float  0.0  # half_h = h / 2
    k1:        .float  0.0
    k2:        .float  0.0
    k3:        .float  0.0
    k4:        .float  0.0
    k:         .float  0.0
    zero:      .float  0.0
    two:       .float  2.0
    six:       .float  6.0
    n:         .word   0
    i:         .word   0
.text
    # Display message1
    li $v0, 4    
    la $a0, message1
    syscall
    
    # Read float value for x0
    li $v0, 6
    syscall       # x0 is stored in f0
    swc1 $f0, x0  # x0 = f0
    
    # Print float from x0
    #li $v0, 2
    #lwc1 $f0, x0          # f0 = x0
    #lwc1 $f1, zero        # f1 = 0.0
    #add.s $f12, $f0, $f1  # f12 = f0
    #syscall
    
    # Display message2
    li $v0, 4
    la $a0, message2
    syscall
    
    # Read float value for y0
    li $v0, 6
    syscall         # y0 is stored in f0
    swc1 $f0, y0    # y0 = f0
    
    # Display message3
    li $v0, 4
    la $a0, message3
    syscall
    
    # Read float value xn
    li $v0, 6
    syscall        # xn is stored in f0
    swc1 $f0, xn   # xn = f0
    
    # Display message4
    li $v0, 4
    la $a0, message4
    syscall
    
    # Read integer value n
    li $v0, 5
    syscall       # n is stored in v0
    sw $v0, n     # n = v0
    
    # Display message5
    li $v0, 4
    la $a0, message5
    syscall

    # Calculates h
    lwc1 $f0, xn            # f0 = xn
    lwc1 $f1, x0            # f1 = x0
    lw $t0, n               # t0 = n
    sub.s $f2, $f0, $f1     # f2 = xn - x0
    mtc1 $t0, $f3           # Converts n integer into float, by setting coproc1 register $f3 to value in $t0
    cvt.s.w $f3, $f3        # Sets $f3 to single precision
    div.s $f2, $f2, $f3     # f2 = (xn - x0) / n
    swc1 $f2, h             # h = (xn - x0) / n
    
    loop:     lwc1 $f0, x0         # f0 = x0
              lwc1 $f1, y0         # f1 = y0
              lwc1 $f2, h          # f2 = h
              
              # Calculates f(x0, y0). The result is stored in $f3.
              swc1 $f0, var_a      # var_a = x0
              swc1 $f1, var_b      # var_b = y0
              jal f
              
              # Calculates k1
              mul.s $f3, $f3, $f2  # f3 = h * f(x0, y0)
              swc1 $f3, k1         # k1 = h * f(x0, y0)
              
              # Calculates h / 2
              lwc1 $f4, two        # f4 = 2.0
              div.s $f5, $f2, $f4  # f5 = h / 2
              swc1 $f5, half_h     # half_h = h / 2
              
              # Calculates x0 + h / 2 and stores the result in var_a
              lwc1 $f4, half_h     # f4 = h / 2
              add.s $f5, $f0, $f4  # f5 = x0 + h / 2
              swc1 $f5, var_a      # var_a = x0 + h / 2
              swc1 $f5, x0_half_h  # x0_half_h = x0 + h / 2
              
              # Calculates y0 + k1 / 2 and stores the result in var_b
              lwc1 $f4, k1         # f4 = k1
              lwc1 $f5, two        # f5 = 2
              div.s $f6, $f4, $f5  # f6 = k1 / 2
              add.s $f6, $f6, $f1  # f6 = y0 + k1 / 2
              swc1 $f6, var_b      # var_b = y0 + k1 / 2
              
              # Calculates f(x0 + h / 2, y0 + k1 / 2). The result is stored in $f3.
              jal f
              
              # Calculates k2 and stores the result in k2
              mul.s $f3, $f3, $f2  # f3 = h * f(x0 + h / 2, y0 + k1 / 2)
              swc1 $f3, k2         # k2 = h * f(x0 + h / 2, y0 + k1 / 2)
              
              # Stores x0 + h / 2 and stores the result in var_a
              lwc1 $f4, x0_half_h  # f4 = x0 + h / 2
              swc1 $f4, var_a      # var_a = x0 + h / 2
              
              # Calculates y0 + k2 / 2 and stores the result in var_b
              lwc1 $f5, k2         # f5 = k2
              lwc1 $f6, two        # f6 = 2
              div.s $f5, $f5, $f6  # f5 = k2 / 2
              add.s $f5, $f5, $f1  # f5 = y0 + k2 / 2
              swc1 $f5, var_b      # var_b = y0 + k2 / 2
              
              # Calculates f(x0 + h / 2, y0 + k2 / 2). The result is stored in $f3.
              jal f
              
              # Calculates k3 and stores the result in k3
              mul.s $f3, $f3, $f2  # f3 = h * f(x0 + h / 2, y0 + k2 / 2)
              swc1 $f3, k3         # k3 = h * f(x0 + h / 2, y0 + k2 / 2)
              
              # Calculates x0 + h and stores the result in var_a
              add.s $f4, $f0, $f2  # f4 = x0 + h
              swc1 $f4, var_a      # var_a = x0 + h
              
              # Calculates y0 + k3 and stores the result in var_b
              lwc1 $f4, k3         # f4 = k3
              add.s $f5, $f1, $f4  # f5 = y0 + k3
              swc1 $f5, var_b      # var_b = y0 + k3
              
              # Calculates f(x0 + h, y0 + k3) and stores the result in $f3
              jal f
              
              # Calculates k4 and stores the result in k4
              mul.s $f3, $f3, $f2  # f3 = h * f(x0 + h, y0 + k3)
              swc1 $f3, k4         # k4 = h * f(x0 + h, y0 + k3)
              
              # Calculates k and stores the result in k
              lwc1 $f0, two        # f0 = 2
              
              lwc1 $f1, k1         # f1 = k1
              
              lwc1 $f2, k2         # f2 = k2
              mul.s $f2, $f2, $f0  # f2 = 2 * k2
              
              lwc1 $f3, k3         # f3 = k3
              mul.s $f3, $f3, $f0  # f3 = 2 * k3
              
              lwc1 $f4, k4         # f4 = k4
              
              lwc1 $f5, six        # f5 = 6
              
              add.s $f1, $f1, $f2  # f1 = k1 + 2 * k2
              add.s $f1, $f1, $f3  # f1 = k1 + 2 * k2 + 2 * k3
              add.s $f1, $f1, $f4  # f1 = k1 + 2 * k2 + 2 * k3 + k4
              div.s $f1, $f1, $f5  # f1 = (k1 + 2 * k2 + 2 * k3 + k4) / 6
              swc1 $f1, k          # k = (k1 + 2 * k2 + 2 * k3 + k4) / 6
              
              # Update yn, where yn = y0 + k
              lwc1 $f0, y0         # f0 = y0
              lwc1 $f1, k          # f1 = k
              add.s $f0, $f0, $f1  # f0 = y0 + k
              swc1 $f0, yn         # yn = y0 + k
              
              # Display x0, y0 and yn
              jal display_x0_y0_yn
              
              # Update x0, where x0 = x0 + h
              lwc1 $f0, x0         # f0 = x0
              lwc1 $f1, h          # f1 = h
              add.s $f0, $f0, $f1  # f0 = x0 + h
              swc1 $f0, x0         # x0 = x0 + h
              
              # Update y0, where y0 = yn
              lwc1 $f0, yn         # f0 = yn
              swc1 $f0, y0         # y0 = yn
              
              # Increment i
              lw $t0, i            # t0 = i
              addi $t0, $t0, 1     # t0 = i + 1
              sw $t0, i            # i = i + 1
              
              lw $t1, n            # t1 = n
              
              blt $t0, $t1, loop   # if i < n, repeat loop
              j end_loop           # else, exit loop
    end_loop:
    
    # Display message8
    li $v0, 4
    la $a0, message8
    syscall
    
    # Display xn
    li $v0, 2
    lwc1 $f12, xn    # f12 = xn
    syscall
    
     # Display message7
    li $v0, 4
    la $a0, message7
    syscall
    
    # Display message9
    li $v0, 4
    la $a0, message9
    syscall
    
    # Display yn
    li $v0, 2
    lwc1 $f12, yn    # f12 = yn
    syscall
    
    # Display message7
    li $v0, 4
    la $a0, message7
    syscall
    
    #exit program
    li $v0, 10
    syscall
    
    # f is the derivative function, which computes f(var_a, var_b), and returns the result in $f3
    # The derivative formula, chosen in our case is (var_a - var_b) / 2
    f:
        lwc1 $f3, var_a       # f3 = var_a
        lwc1 $f4, var_b       # f4 = var_b
        lwc1 $f5, two         # f5 = 2.0
        sub.s $f3, $f3, $f4   # f3 = var_a - var_b
        div.s $f3, $f3, $f5   # f5 = (var_a - var_b) / 2
        jr $ra
    
    display_x0_y0_yn:
        # display x0
        li $v0, 2
        lwc1 $f0, x0          # f0 = x0
        lwc1 $f1, zero        # f1 = 0.0
        add.s $f12, $f0, $f1  # f12 = f0
        syscall
        
        # display space
        li $v0, 4
        la $a0, message6
        syscall
        
        # display y0
        li $v0, 2
        lwc1 $f0, y0          # f0 = y0
        lwc1 $f1, zero        # f1 = 0.0
        add.s $f12, $f0, $f1  # f12 = f0
        syscall
        
        # display space
        li $v0, 4
        la $a0, message6
        syscall
        
        # display yn
        li $v0, 2
        lwc1 $f0, yn          # f0 = yn
        lwc1 $f1, zero        # f1 = 0.0
        add.s $f12, $f0, $f1  # f12 = f0
        syscall
        
        # display endline
        li, $v0, 4
        la $a0, message7
        syscall
        
        jr $ra