.p816

.include "mac.inc"
.include "kernalstruct.inc"
.include "kernal.inc"
.include "malloc.inc"
.include "print.inc"
.include "file.inc"
.include "basicstub.inc"    ; ONLY include this in main.s.  MUST be last include

.segment "MAIN"

; Define symbolic constants
OVERLAY1_LOAD_ADDR  = $100000
OVERLAY2_LOAD_ADDR   = $110000
MALLOC_START        = $010000
MALLOC_SIZE	        = $040000
BUFFER_SIZE         = 32

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
    
    ; Load the overlays
    Load #1, #8, #0, #overlay1_filename, #OVERLAY1_LOAD_ADDR
    Load #1, #8, #0, #overlay2_filename, #OVERLAY2_LOAD_ADDR
    
    ; Initialize the malloc system
    FarMalloc_Init
    FarMalloc_AddBlock #MALLOC_START, #MALLOC_SIZE	    

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

; Workspace to hold converted hex string
buffer: 
    .repeat BUFFER_SIZE
        .byte $00
    .endrepeat

; String Constants
overlay1_filename: .byte "X16GS-TEST.OV1.BIN", $00
overlay2_filename: .byte "X16GS-TEST.OV2.BIN", $00