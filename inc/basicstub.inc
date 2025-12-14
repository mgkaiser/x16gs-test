.segment "LOADADDR"
    .word $0801             ; Load address for BASIC stub

.segment "STARTUP"
    .byte $0C, $08          ; Link to next BASIC line (at $080C)
    .byte $0A, $00          ; Line number 10 (little endian)
    .byte $9E               ; Token for the BASIC command SYS
    .byte $20               ; Space character
    .byte $32, $30, $36, $34; ASCII representation of the address "2068"
    .byte $00               ; End of BASIC line marker
    .byte $00, $00          ; End of BASIC program marker

.IMPORT __STACK_START__,  __STACK_SIZE__

.segment "MAIN"

; Do the basic startup code here then call "main" the first "formal" function.
startup:

    ; Remember ROM bank
    lda $01
    pha
    
    ; Go to native mode
    modeNative    

    ; Move stack to the larger '816' stack area    
    SetRomBank #$00
    StackPush __STACK_START__ + __STACK_SIZE__ - 1    
    
    ; Call main procedure
    jsr main

    ; Return stack to the original location
    SetRomBank #$00
    StackPop
    
    ; Back to emulation mode and exit to BASIC
    mode8
    modeEmulation

    ; Put ROM bank back where we found it
    pla
    sta $01

rts    