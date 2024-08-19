.setcpu "65C02"
.debuginfo

.zeropage
                .org ZP_START0
READ_PTR:       .res 1
WRITE_PTR:      .res 1

.segment "INPUT_BUFFER"
INPUT_BUFFER:   .res $100

.segment "BIOS"

ACIA_DATA       = $5000
ACIA_STATUS     = $5001
ACIA_CMD        = $5002
ACIA_CTRL       = $5003

; VIA Registers
VIA_PORTB = $6000
VIA_PORTA = $6001
VIA_DDRB = $6002
VIA_DDRA = $6003

; LCD Signals
LCD_E  = %10000000
LCD_RW = %01000000
LCD_RS = %00100000


LOAD:
                rts

SAVE:
                rts


; Input a character from the serial interface.
; On return, carry flag indicates whether a key was pressed
; If a key was pressed, the key value will be in the A register
;
; Modifies: flags, A
MONRDKEY:
CHRIN:
                phx
                jsr     BUFFER_SIZE
                beq     @no_keypressed
                jsr     READ_BUFFER
                jsr     CHROUT                  ; echo
                plx
                sec
                rts
@no_keypressed:
                plx
                clc
                rts


; Output a character (from the A register) to the serial interface.
;
; Modifies: flags
MONCOUT:
CHROUT:
                PHA                    ; Save A.
@LOOP:          LDA     ACIA_STATUS
                AND     #$10           ; Check TX Data Register
                BEQ     @LOOP           ; Loop if TX buffer is full
                PLA                    ; Restore A.
                STA       ACIA_DATA
                RTS                    ; Return.

; Initialize the circular input buffer
; Modifies: flags, A
INIT_BUFFER:
                lda READ_PTR
                sta WRITE_PTR
                rts

; Write a character (from the A register) to the circular input buffer
; Modifies: flags, X
WRITE_BUFFER:
                ldx WRITE_PTR
                sta INPUT_BUFFER,x
                inc WRITE_PTR
                rts

; Read a character from the circular input buffer and put it in the A register
; Modifies: flags, A, X
READ_BUFFER:
                ldx READ_PTR
                lda INPUT_BUFFER,x
                inc READ_PTR
                rts

; Return (in A) the number of unread bytes in the circular input buffer
; Modifies: flags, A
BUFFER_SIZE:
                lda WRITE_PTR
                sec
                sbc READ_PTR
                rts


; Interrupt request handler
IRQ_HANDLER:
                pha
                phx
                lda     ACIA_STATUS
                ; For now, assume the only source of interrupts is incoming data
                lda     ACIA_DATA
                jsr     WRITE_BUFFER
                plx
                pla
                rti

lcd_init:
  lda #%11111111 ; Set all pins on port B to output
  sta VIA_DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta VIA_DDRA

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
lcd_clear:
  lda #$00000001 ; Clear display
  jsr lcd_instruction_nowait
  jsr delay
  rts

lcd_print_woz:
  jsr lcd_clear
  ldx #0
@woz_loop:
  lda message_woz,x
  beq lcd_print_end
  jsr print_char
  inx
  jmp @woz_loop

lcd_print_end:
  rts

message_woz: .asciiz "Wozmon running"

lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta VIA_DDRB
lcdbusy:
  lda #LCD_RW
  sta VIA_PORTA
  lda #(LCD_RW | LCD_E)
  sta VIA_PORTA
  jsr short_delay  ; extend enable pulse to satisfy datasheet (>450ns)
  lda VIA_PORTB
  and #%10000000
  bne lcdbusy

  lda #LCD_RW
  sta VIA_PORTA
  lda #%11111111  ; Port B is output
  sta VIA_DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
lcd_instruction_nowait:
  sta VIA_PORTB
  lda #0         ; Clear RS/RW/E bits
  sta VIA_PORTA
  lda #LCD_E         ; Set E bit to send instruction
  sta VIA_PORTA
  jsr short_delay  ; extend pulse width to meet datasheet (>450ns)
  lda #0         ; Clear RS/RW/E bits
  sta VIA_PORTA
  rts

print_char:
  jsr lcd_wait
print_char_nowait:
  sta VIA_PORTB
  lda #LCD_RS         ; Set RS; Clear RW/E bits
  sta VIA_PORTA
  lda #(LCD_RS | LCD_E)   ; Set E bit to send instruction
  sta VIA_PORTA
  jsr short_delay ; extend pulse width to meet datasheet (>450ns)
  lda #LCD_RS         ; Clear E bits
  sta VIA_PORTA
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



.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00           ; NMI vector
                .word   RESET           ; RESET vector
                .word   IRQ_HANDLER     ; IRQ vector

