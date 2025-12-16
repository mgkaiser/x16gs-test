.p816

.include "mac.inc"
.include "kernalstruct.inc"
.include "kernal.inc"
.include "x16.inc"
.include "malloc.inc"
.include "print.inc"
.include "file.inc"
.include "basicstub.inc"    ; ONLY include this in main.s.  MUST be last include

.segment "MAIN"

; Define symbolic constants
OVERLAY1_LOAD_ADDR  = $100000
OVERLAY2_LOAD_ADDR  = $110000
MALLOC_START        = $010000
MALLOC_SIZE	        = $040000
BUFFER_SIZE         = 32

.proc main: near

    ; Save working registers
    ProcPrefix 
    ProcNear                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocalL l_p3, 6                                   ; This is a uint32_t local variable
    DeclareLocalL l_p2, 4                                   ; This is a uint32_t local variable
    DeclareLocalL l_p1, 2                                   ; This is a uint32_t local variable
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 8                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    

    ; Setup stack frame
    SetupStackFrame               
    
    ; Load the overlays
    Load #1, #8, #0, #overlay1_filename, #OVERLAY1_LOAD_ADDR
    Load #1, #8, #0, #overlay2_filename, #OVERLAY2_LOAD_ADDR
    
    ; Initialize the malloc system
    DebugPrintCR
    DebugPrint #header_str
    DebugPrint #after_init_str
    DebugPrint #header_str    

    FarMalloc_Init    
    FarMalloc_AddBlock #MALLOC_START, #MALLOC_SIZE	        

    FarMalloc_Header_Dump     
    FarMalloc_Chain_Dump pm + $0000, #available_str
    FarMalloc_Chain_Dump pm + $0004,  #assigned_str 

    ; Test Farmalloc                  
    DebugPrintCR
    DebugPrint #header_str
    DebugPrint #after_malloc_str
    DebugPrint #header_str  

    FarMalloc #$000010
    sta l_p1
    stx l_p1+2  

    FarMalloc_Header_Dump 
    FarMalloc_Chain_Dump pm + $0000, #available_str
    FarMalloc_Chain_Dump pm + $0004,  #assigned_str     

    ; Convert result to PETSCII    
    ToHexL l_p1, buffer 
    DebugPrint #l_p1_str
    DebugPrint #buffer            
    DebugPrintCR

    ; Test Farmalloc                  
    DebugPrintCR
    DebugPrint #header_str
    DebugPrint #after_malloc_str
    DebugPrint #header_str  
    
    FarMalloc #$000010
    sta l_p2
    stx l_p2+2  

    FarMalloc_Header_Dump   
    FarMalloc_Chain_Dump pm + $0000, #available_str
    FarMalloc_Chain_Dump pm + $0004,  #assigned_str     

    ; Convert result to PETSCII    
    ToHexL l_p2, buffer 
    DebugPrint #l_p2_str
    DebugPrint #buffer            
    DebugPrintCR

    ; Test Farmalloc                  
    DebugPrintCR
    DebugPrint #header_str
    DebugPrint #after_malloc_str
    DebugPrint #header_str  
    
    FarMalloc #$000010
    sta l_p3
    stx l_p3+2  

    FarMalloc_Header_Dump   
    FarMalloc_Chain_Dump pm + $0000, #available_str
    FarMalloc_Chain_Dump pm + $0004,  #assigned_str     

    ; Convert result to PETSCII    
    ToHexL l_p3, buffer 
    DebugPrint #l_p3_str
    DebugPrint #buffer            
    DebugPrintCR

    ; Let p3 be freed    
    DebugPrintCR    
    DebugPrint #header_str
    DebugPrint #after_free_str
    DebugPrint #header_str

    ; Convert result to PETSCII    
    ToHexL l_p3, buffer 
    DebugPrint #l_p3_str
    DebugPrint #buffer            
    DebugPrintCR

    FarFree *l_p3

    FarMalloc_Header_Dump   
    FarMalloc_Chain_Dump pm + $0000, #available_str
    FarMalloc_Chain_Dump pm + $0004,  #assigned_str     

    ; Test Farmalloc                  
    DebugPrintCR
    DebugPrint #header_str
    DebugPrint #after_malloc_str
    DebugPrint #header_str  
    
    FarMalloc #$000010
    sta l_p3
    stx l_p3+2  

    FarMalloc_Header_Dump   
    FarMalloc_Chain_Dump pm + $0000, #available_str
    FarMalloc_Chain_Dump pm + $0004,  #assigned_str     

    ; Convert result to PETSCII    
    ToHexL l_p3, buffer 
    DebugPrint #l_p3_str
    DebugPrint #buffer            
    DebugPrintCR

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

l_p1_str:          .byte "POINTER 1:  ", $00
l_p2_str:          .byte "POINTER 2:  ", $00
l_p3_str:          .byte "POINTER 3:  ", $00 
header_str:        .byte "**************************************", $0a, $00
after_init_str:    .byte "** AFTER INIT:", $0a, $00
after_malloc_str:  .byte "** AFTER MALLOC:", $0a, $00
after_free_str:    .byte "** AFTER FREE:", $0a, $00
available_str:     .byte "AVAILABLE: ", $0a, $00
assigned_str:      .byte "ASSIGNED:  ", $0a, $00

