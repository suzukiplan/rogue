; Bit-7	Bit-6	Bit-5	Bit-4	Bit-3	Bit-2	Bit-1	Bit-0
; Up	Down	Left	Right	Start	Select	A	    B
.joypad_update
    ld a, (joypad)
    ld (joypad_prev), a
    in a, ($a0)
    ld (joypad), a
    ret
