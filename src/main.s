.p816

.include "mac.inc"
.include "kernalstruct.inc"
.include "kernal.inc"
.include "malloc.inc"
.include "print.inc"
.include "file.inc"
.include "basicstub.inc"    ; ONLY include this in main.s.  MUST be last include

.import overlay1_signature
.import overlay2_signature

.segment "MAIN"

.proc main: near

    ; Save working registers
    ProcPrefix 
    ProcNear                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocalL l_p, 0                                    ; This is a uint32_t local variable
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 4                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    

    ; Setup stack frame
    SetupStackFrame   
    
    Load #1, #8, #0, #overlay1_filename, #$100000
    Load #1, #8, #0, #overlay2_filename, #$110000
    
    ; Initialize the malloc system
    FarMalloc_Init
    FarMalloc_AddBlock #$010000, #$040000    

    ; Test Farmalloc    
    FarMalloc #$000400
    sta l_p
    stx l_p+2    

    ; Convert result to PETSCII
    ToHexL l_p, buffer    

    breakpoint

    ; Print it
    Print #buffer

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rts

.endproc

buffer: 
    .repeat 32
        .byte $00
    .endrepeat

overlay1_filename: .byte "X16GS-TEST.OV1.BIN", $00
overlay2_filename: .byte "X16GS-TEST.OV2.BIN", $00