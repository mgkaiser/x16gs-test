.p816
.A16
.I16

.scope
.define current_file "kernal.s"

.include "mac.inc"
.include "kernal.inc"

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
.export mouse_config: far
.export mouse_get: far

; A place to store registers for Kernal calls
registers:  .res .sizeof(registers)

; A place to store the filename in bank $00 for kernal calls
kernal_fn:  .res 32

.proc close_far : far
    sta registers + registers::a_reg    
    lda #CLOSE    
    sta registers + registers::kernal_call
    stz registers + registers::flags
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
    sta registers + registers::y_reg    
    lda #SETNAM    
    sta registers + registers::kernal_call
    stz registers + registers::flags
    jmp call_kernal                                    
.endproc

.proc setlfs_far : far
    sta registers + registers::a_reg    
    txa
    sta registers + registers::x_reg    
    tya 
    sta registers + registers::y_reg    
    lda #SETLFS    
    sta registers + registers::kernal_call
    stz registers + registers::flags
    jmp call_kernal                                    
.endproc

.proc bsout_far : far
    sta registers + registers::a_reg    
    lda #BSOUT    
    sta registers + registers::kernal_call
    stz registers + registers::flags
    jmp call_kernal                                    
.endproc

.proc mouse_config : far
    lda #$0001
    sta registers + registers::flags
    lda #80
    sta registers + registers::x_reg
    lda #24
    sta registers + registers::y_reg
    lda #$ff5f
    sta registers + registers::kernal_call
    jsl call_kernal

    lda #$0001
    sta registers + registers::a_reg
    lda #$ff68
    sta registers + registers::kernal_call
    jmp call_kernal
.endproc 

.proc mouse_get : far
    lda #$0018
    sta registers + registers::a_reg
    lda #$ff6b
    sta registers + registers::kernal_call
    jsl call_kernal
    lda f:$000018
    xba
    and #$00ff
    tax
    lda f:$00001a
    xba
    and #$00ff
    tay
    rtl
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
    lda registers + registers::flags
    bne l1
    clc 
    bra l2
l1: sec 
l2: lda registers + registers::a_reg        
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

.endscope