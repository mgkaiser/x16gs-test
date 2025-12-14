.p816
.A16
.I16

.include "mac.inc"
.include "kernalstruct.inc"

.segment "MAIN"

; Define exports for all public functions in this module
.export registers: far
.export kernal_fn: far
.export call_kernal
.export bsout_far: far 
.export setlfs_far: far
.export setnam_far: far
.export open_far: far
.export clrchn_far: far
.export close_far: far

; A place to store registers for Kernal calls
registers:  .res .sizeof(registers)

; A place to store the filename in bank $00 for kernal calls
kernal_fn:  .res 32

.proc close_far : far
    sta registers + registers::a_reg    
    lda #CLOSE    
    sta registers + registers::kernal_call
    jmp call_kernal                                    
.endproc

.proc clrchn_far : far
    lda #CLRCHN
    sta registers + registers::kernal_call
    jmp call_kernal                                    
.endproc

.proc open_far : far
    lda #OPEN
    sta registers + registers::kernal_call
    jmp call_kernal                                    
.endproc

.proc setnam_far : far
    sta registers + registers::a_reg    
    txa
    sta registers + registers::x_reg    
    tya 
    sta registers + registers::a_reg    
    lda #SETNAM    
    sta registers + registers::kernal_call
    jmp call_kernal                                    
.endproc

.proc setlfs_far : far
    sta registers + registers::a_reg    
    txa
    sta registers + registers::x_reg    
    tya 
    sta registers + registers::a_reg    
    lda #SETLFS    
    sta registers + registers::kernal_call
    jmp call_kernal                                    
.endproc

.proc bsout_far : far
    sta registers + registers::a_reg    
    lda #BSOUT    
    sta registers + registers::kernal_call
    jmp call_kernal                                    
.endproc

.proc call_kernal : far
    
    ; Remember Direct Page    
    phd                                     

    ; Set stack to Kernal Stack
    ldx #$0000                                  
    lda #extapi::enter_kernal_stack
    jsr EXTAPI16

    ; Set Direct Page to $0000
    lda #$0000                              
    tcd    

    ; Real mode
    modeEmulation

    ; Get the real mode register values
    lda registers + registers::a_reg        
    ldx registers + registers::x_reg
    ldy registers + registers::y_reg

    ; Call Kernal
    jsr call_kernal_indirect

    ; Back into Native mode                               
    modeNative
    mode16

    ; Back to our Stack
    ldx #$0000                              
    lda #extapi::leave_kernal_stack
    jsr EXTAPI16

    ; Back to our DP
    pld     

    rtl
.endproc

call_kernal_indirect: jmp (registers + registers::kernal_call)