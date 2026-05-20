        ; add 6 and 7 together
        lli 6
        cp acc,r1
        lli 7
        add r1
        ; acc should contain 15
        halt

.start
        ; test labels for the assembler
        cp      r5,acc
        sub     r3
        cp      r7,acc
        sub     r8

        halt
