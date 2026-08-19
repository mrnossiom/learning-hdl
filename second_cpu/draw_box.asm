        #let screen_width = 8
        #let screen_height = 8

        ld 0            ; base_x
        cp r2,acc
        ld 1            ; length_x
        add r2          ; end_x
        cp r3,acc
        ld 2            ; base_y
        cp r4,acc
        ld 3            ; length_y
        mul $screen_width
        sub r4          ; end_y
        cp r5,acc

        cp r6,0xF       ; char used to fill a cell

.y_loop
        cp acc,r4
        cp r0,acc
.x_loop
        cp acc,r2
        cp r1,acc
        st r6           ; (acc) = r6
        inc acc
        cmp r3
        b.neq .x_loop

        cp acc,r0
        add.i $screen_width
        b.neq .y_loop
