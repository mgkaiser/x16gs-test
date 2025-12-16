; Goes in .inc
.macro FarMalloc_Header_Dump
    .out "FarMalloc_Header_Dump"    
    jsl farmalloc_header_dump
.endmacro

.macro FarMalloc_Chain_Dump root, value
    .out "FarMalloc_Chain_Dump"
    SetParamL f:root    
    SetParamL value
    jsl farmalloc_chain_dump
    FreeParams 4
.endmacro

.import farmalloc_chain_dump: far
.import farmalloc_header_dump: far

; Goes in .s

.export farmalloc_header_dump
.export farmalloc_chain_dump

.proc farmalloc_header_dump: far

    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocal l_p_pm, 2                                  ; This is a uint16_t local variable
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable    
    SetLocalCount 3                                         ; Number of (16 bit) local variables declared                   
    
    ; Setup stack frame
    SetupStackFrame  

    ; Store a pointer to pm in l_p_pm (a local variable in DP)
    lda #.LOWORD(pm)
    sta l_p_pm  

    ; Print the delimiter
    DebugPrint #malloc_delimiter_str
    DebugPrintCR  

    ; Print the available    
    StructElementToVar l_p_pm, pmalloc::available, l_temp
    DebugPrintHexLWithCR malloc_available_str, l_temp, malloc_buffer                 

    ; Print the assigned    
    StructElementToVar l_p_pm, pmalloc::assigned, l_temp
    DebugPrintHexLWithCR malloc_assigned_str, l_temp, malloc_buffer                     

    ; Print the freemem
    StructElementToVar l_p_pm, pmalloc::freemem, l_temp
    DebugPrintHexLWithCR malloc_freemem_str, l_temp, malloc_buffer         

    ; Print the totalmem
    StructElementToVar l_p_pm, pmalloc::totalmem, l_temp
    DebugPrintHexLWithCR malloc_totalmem_str, l_temp, malloc_buffer             

    ; Print the totalnodes
    StructElementToVar l_p_pm, pmalloc::totalnode, l_temp
    DebugPrintHexLWithCR malloc_totalnodes_str, l_temp, malloc_buffer                         

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl

.endproc    

.proc farmalloc_chain_dump : far

    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocalL l_p_temp, 2                               ; This is a uint32_t local variable
    DeclareLocalL l_p_current, 0                            ; This is a uint32_t local variable
    SetLocalCount 4                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters        
    DeclareParam value, 0                                    ; uint32_t ptr                                 
    DeclareParam root, 2                                    ; uint32_t ptr                                 

    ; Setup stack frame
    SetupStackFrame  

    DebugPrint #malloc_delimiter_str
    DebugPrintCR
    DebugPrint *value    

    ; Bail if root == NULL
    lda root
    beql FarMalloc_Chain_Dump_Exit

    ; current = root
    ldy #$0002
    lda [root]
    sta l_p_current
    lda [root], y   
    sta l_p_current + 2

FarMalloc_Chain_Dump_Loop:
        ; if (current == NULL) goto FarMalloc_Chain_Dump_Exit;        
        lda l_p_current + 2
        ora l_p_current
        beql FarMalloc_Chain_Dump_Exit

        ; Print current address
        ToHexL l_p_current, malloc_buffer
        DebugPrint #malloc_buffer
        DebugPrint #malloc_colon_str

        ; Print prev
        ldy #pmalloc_item::prev
        lda [l_p_current],y
        sta l_p_temp
        ldy #pmalloc_item::prev+2
        lda [l_p_current],y
        sta l_p_temp + 2
        ToHexL l_p_temp, malloc_buffer
        DebugPrint #malloc_buffer
        DebugPrint #malloc_colon_str

        ; Print next
        ldy #pmalloc_item::next
        lda [l_p_current],y
        sta l_p_temp
        ldy #pmalloc_item::next+2
        lda [l_p_current],y
        sta l_p_temp + 2
        ToHexL l_p_temp, malloc_buffer
        DebugPrint #malloc_buffer
        DebugPrint #malloc_colon_str

        ; Print size
        ldy #pmalloc_item::size
        lda [l_p_current],y
        sta l_p_temp
        ldy #pmalloc_item::size+2
        lda [l_p_current],y
        sta l_p_temp + 2
        ToHexL l_p_temp, malloc_buffer
        DebugPrint #malloc_buffer
        DebugPrintCR

        ; temp = current->pmalloc_item::next
        ldy #pmalloc_item::next
        lda [l_p_current],y
        sta l_p_temp
        ldy #pmalloc_item::next+2
        lda [l_p_current],y
        sta l_p_temp + 2     

        ; current = temp        
        lda l_p_temp
        sta l_p_current         
        lda l_p_temp + 2
        sta l_p_current + 2
        
        brl FarMalloc_Chain_Dump_Loop

FarMalloc_Chain_Dump_Exit:

    ;DebugPrint #malloc_delimiter_str
    ;DebugPrintCR

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc

malloc_buffer: 
    .repeat 32
        .byte $00
    .endrepeat

malloc_delimiter_str:           .byte "------------------------", $00
malloc_available_str:           .byte "AVAILABLE:  ", $00
malloc_assigned_str:            .byte "ASSIGNED:   ", $00
malloc_freemem_str:             .byte "FREEMEM:    ", $00
malloc_totalmem_str:            .byte "TOTALMEM:   ", $00    
malloc_totalnodes_str:          .byte "TOTALNODES: ", $00
malloc_colon_str:               .byte " : ", $00    
