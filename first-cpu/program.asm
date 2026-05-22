        ; add 6 and 7 together
        lli 6
        cp acc,r0
        lli 7
        add r0
        ; acc should contain 13
        halt

.test
        ; test labels for the assembler
        cp      r5,acc
        sub     r3
        cp      r7,acc
        sub     r8
        halt
