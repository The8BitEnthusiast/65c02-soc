.SEGMENT "MYCODE"
.org $8000

PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

reset:
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  ; perform initialization by instruction as per datasheet
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction_nowait
  jsr delay
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction_nowait
  jsr delay
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction_nowait
  jsr delay

  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction_nowait
  jsr delay
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction_nowait
  jsr delay
  lda #$00000001 ; Clear display
  jsr lcd_instruction_nowait
  jsr delay

  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  ;jsr short_delay    ; short delay to make sure busy flag is available
  ;jsr short_delay
  inx
  jmp print

loop:
  jmp loop

message: .asciiz "Hello, world!"

lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  jsr short_delay  ; extend enable pulse to satisfy datasheet (>450ns)
  lda PORTB
  and #%10000000
  bne lcdbusy

  lda #RW
  sta PORTA
  lda #%11111111  ; Port B is output
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
lcd_instruction_nowait:
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  jsr short_delay  ; extend pulse width to meet datasheet (>450ns)
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait
print_char_nowait:
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  jsr short_delay ; extend pulse width to meet datasheet (>450ns)
  lda #RS         ; Clear E bits
  sta PORTA
  rts

delay:
  ldx #$FF
  ldy #$FF
delay_loop1:
  dey
  beq end_delay
delay_loop2:
  dex              ; 2 clock cycles
  beq delay_loop1  ; 2 clock cycles (when not taken)
  jmp delay_loop2  ; 2 clock cycles
end_delay:
  rts

short_delay:
  ldy #$05
short_delay_loop:
  dey
  beq end_short_delay
  jmp short_delay_loop
end_short_delay:
  rts

.SEGMENT "RESETVEC"
.org $FFFA

    .word $0000    ; NMI
    .word reset    ; RESET
    .word $0000    ; BRK
