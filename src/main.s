.p816

.include "mac.inc"
.include "kernal_struct.inc"
.include "kernal.inc"
.include "x16.inc"
.include "linkedlist_struct.inc"
.include "linkedlist.inc"
.include "panel_struct.inc"
.include "panel.inc"
.include "desktop_struct.inc"
.include "desktop.inc"
.include "malloc.inc"
.include "print.inc"
.include "file.inc"
.include "basicstub.inc"    ; ONLY include this in main.s.  MUST be last include

.segment "MAIN"

; Load addresses of the overlays
OVERLAY1_LOAD_ADDR  = $100000
OVERLAY2_LOAD_ADDR  = $110000

; Allocate the heap as MALLOC_SIZE bytes starting at MALLOC_START
MALLOC_START        = $010000
MALLOC_SIZE	        = $040000

; Size of buffer for converted hex string
BUFFER_SIZE         = 32

.proc main: near

    ; Save working registers
    ProcPrefix 
    ProcNear                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    DeclareLocalL l_p1, 2                                   ; This is a uint32_t local variable
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 4                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    

    ; Setup stack frame
    SetupStackFrame               
    
    ; Load the overlays
    Load #1, #8, #0, #overlay1_filename, #OVERLAY1_LOAD_ADDR
    Load #1, #8, #0, #overlay2_filename, #OVERLAY2_LOAD_ADDR   

    ; Initialize memory allocation system
    FarMalloc_Init    
    FarMalloc_AddBlock #MALLOC_START, #MALLOC_SIZE	        

    ; Allocate and free a memory block
    FarMalloc #.sizeof(linkedlist), l_p1        

    ; Initialize linked list        
    LL_Init *l_p1   

    ; Free the allocated block
    FarFree *l_p1            

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rts

.endproc

; Linked List
linked_list: .res .sizeof(linkedlist)   

; Workspace to hold converted hex string
buffer: 
    .repeat BUFFER_SIZE
        .byte $00
    .endrepeat

; String Constants
overlay1_filename: .byte "X16GS-TEST.OV1.BIN", $00
overlay2_filename: .byte "X16GS-TEST.OV2.BIN", $00