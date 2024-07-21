.SEGMENT "MYCODE"
.org $8000

RESET:
LOOP:
    LDA #$69
    JSR MYSUB
    JMP LOOP

MYSUB:
    STA $1000
    LDA $1000
    RTS

.SEGMENT "RESETVEC"
.org $FFFA

    .word $0000    ; NMI
    .word RESET    ; RESET
    .word $0000    ; BRK
