.SEGMENT "MYCODE"
.org $8000

reset:
  lda #$ff
  sta $6002

  lda #$50
  sta $6000

loop:
  ror
  sta $6000

  jmp loop

.SEGMENT "RESETVEC"
.org $FFFA

    .word $0000    ; NMI
    .word reset    ; RESET
    .word $0000    ; BRK
