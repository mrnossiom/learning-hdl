        lli 0
        cp acc,r0 ; result
        lli 5
        cp acc,r1 ; loop end
        lli 1 ; loop start
.loop
        cp acc,r2 ; save counter
        add r0
        cp acc,r0
        cp r2,acc ; restore counter
        inc
        cmp r1 ; cmp to loop end
        beq loop
        halt
