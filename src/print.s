.p816
.A16
.I16

.include "mac.inc"
.include "kernalstruct.inc"
.include "kernal.inc"

.segment "OVERLAY1"

; Define exports for all public functions in this module
.export tohex
.export print

hextemplate:
    .byte "0123456789ABCDEF"

.proc tohex: far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters
    DeclareParam ptr, 0                                    ; uint32_t size
    DeclareParam value, 2                                  ; uint16_t ptr

    ; Setup stack frame
    SetupStackFrame    

    ; We start with rightmost digit
    ldy #$0003

    ; A = value
    lda value

tohex_loop:    

        ; Remember A
        pha

        ; X = A and $000f        
        and #$000f
        tax        

        ; Convert the digit to ascii and store at pointer
        mode8
        lda f:hextemplate,X
        sta [ptr],y
        mode16
        
        ; Restore A
        pla    

        ; Rotate right 4 bits
        .repeat 4
            lsr a
        .endrepeat        

        ; Y = Y - 1
        dey

    ; Continue if Y did't go negative
    bpl tohex_loop

    FreeLocals  
    ProcSuffix

    rtl
.endproc

.proc print: far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters
    DeclareParam string, 0                                  ; uint32_t size    

    ; Setup stack frame
    SetupStackFrame   

    ; if string == NULL exit
    lda string
    ora string+2
    beq PrintExit 

PrintLoop:

    ; if *string == NULL exit
    lda [string]    
    beq PrintExit

    ; Output character    
    jsl bsout_far

    ; string++
    clc
    lda string
    adc #$0001
    sta string
    lda string+2    
    adc #$0000  
    sta string+2

    ; Next
    bra PrintLoop

PrintExit:

    FreeLocals  
    ProcSuffix

    rtl
.endproc