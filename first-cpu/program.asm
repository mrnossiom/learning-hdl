        lli 0x6
        cp acc,r1
        lli 0x7
        add r1
        halt

.start
        cp      r5,acc
        sub     r3
        cp      r7,acc
        sub     r8

        halt
