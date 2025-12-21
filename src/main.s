.p816

.scope
.define current_file "main.s"

.include "mac.inc"
.include "kernal.inc"
.include "x16.inc"
.include "linkedlist.inc"
.include "panel.inc"
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
    DeclareLocalL l_p4, 8                                   ; This is a uint32_t local variable
    DeclareLocalL l_p3, 6                                   ; This is a uint32_t local variable
    DeclareLocalL l_p2, 4                                   ; This is a uint32_t local variable
    DeclareLocalL l_p1, 2                                   ; This is a uint32_t local variable
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 10                                         ; Number of (16 bit) local variables declared                   

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

    .A16
    .I16
    StructElementToVarL l_p1, linkedlist::head, l_temp
    DebugPrintHexLWithCR str_linked_list_head, l_temp, buffer
    StructElementToVarL l_p1, linkedlist::tail, l_temp
    DebugPrintHexLWithCR str_linked_list_tail, l_temp, buffer
    StructElementToVarL l_p1, linkedlist::count, l_temp
    DebugPrintHexLWithCR str_linked_list_count, l_temp, buffer
    DebugPrint #str_delimiter

    FarMalloc #.sizeof(ll_node) + 8, l_p2    
    lda l_p2
    adc #.loword(.sizeof(ll_node))
    sta l_temp
    lda l_p2 + 1
    adc #.hiword(.sizeof(ll_node))
    sta l_temp + 1
    ToHex #$0001, *l_temp
    ldy #$0004
    lda #$0000
    sta [l_temp], y
    LL_InsertTail *l_p1, *l_p2

    .A16
    .I16
    StructElementToVarL l_p1, linkedlist::head, l_temp
    DebugPrintHexLWithCR str_linked_list_head, l_temp, buffer
    StructElementToVarL l_p1, linkedlist::tail, l_temp
    DebugPrintHexLWithCR str_linked_list_tail, l_temp, buffer
    StructElementToVarL l_p1, linkedlist::count, l_temp
    DebugPrintHexLWithCR str_linked_list_count, l_temp, buffer
    DebugPrint #str_delimiter

    FarMalloc #.sizeof(ll_node) + 8, l_p3
    lda l_p3
    adc #.loword(.sizeof(ll_node))
    sta l_temp
    lda l_p3 + 1
    adc #.hiword(.sizeof(ll_node))
    sta l_temp + 1
    ToHex #$0002, *l_temp
    ldy #$0004
    lda #$0000
    sta [l_temp], y
    LL_InsertTail *l_p1, *l_p3

    .A16
    .I16
    StructElementToVarL l_p1, linkedlist::head, l_temp
    DebugPrintHexLWithCR str_linked_list_head, l_temp, buffer
    StructElementToVarL l_p1, linkedlist::tail, l_temp
    DebugPrintHexLWithCR str_linked_list_tail, l_temp, buffer
    StructElementToVarL l_p1, linkedlist::count, l_temp
    DebugPrintHexLWithCR str_linked_list_count, l_temp, buffer    
    DebugPrint #str_delimiter

    FarMalloc #.sizeof(ll_node) + 8, l_p4
    lda l_p4
    adc #.loword(.sizeof(ll_node))
    sta l_temp
    lda l_p4 + 1
    adc #.hiword(.sizeof(ll_node))
    sta l_temp + 1
    ToHex #$0003, *l_temp
    ldy #$0004
    lda #$0000
    sta [l_temp], y
    LL_InsertHead *l_p1, *l_p4

    .A16
    .I16
    StructElementToVarL l_p1, linkedlist::head, l_temp
    DebugPrintHexLWithCR str_linked_list_head, l_temp, buffer
    StructElementToVarL l_p1, linkedlist::tail, l_temp
    DebugPrintHexLWithCR str_linked_list_tail, l_temp, buffer
    StructElementToVarL l_p1, linkedlist::count, l_temp
    DebugPrintHexLWithCR str_linked_list_count, l_temp, buffer    
    DebugPrint #str_delimiter

    LL_GetTail *l_p1, l_temp
l1: DebugPrintHexLWithCR str_linked_list_elem, l_temp, buffer

    LL_GetPrev *l_p1, *l_temp, l_temp

    lda l_temp
    ora l_temp + 2
    bne l1

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

str_linked_list_head:   .byte "Linked List Head:  ", $00
str_linked_list_tail:   .byte "Linked List Tail:  ", $00
str_linked_list_count:  .byte "Linked List Count: ", $00 
str_linked_list_elem:   .byte "Element: ", $00 
str_delimiter:          .byte "------------------------", $0a, $00

.endscope