.import farmalloc_init: far
.import farmalloc_addblock: far
.import farmalloc_addblock: far
.import farmalloc: far
.import farfree: far
.import farmalloc_chain_dump: far

.import farmalloc_header_dump: far

; Define Macros to call these functions from assembly
.macro FarMalloc_Init
    .out "FarMalloc_Init"    
    jsl farmalloc_init
.endmacro

.macro FarMalloc_AddBlock ptr, size
    .out "FarMalloc_AddBlock"        
    SetParamL ptr
    SetParamL size    
    jsl farmalloc_addblock
    FreeParams 4
.endmacro

.macro FarMalloc size
    .out "FarMalloc"
    SetRetValL        
    SetParamL size
    jsl farmalloc
    FreeParams 2
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
.endmacro

.macro FarFree ptr
    .out "FarFree"
    SetParamL ptr
    jsl farfree
    FreeParams 2
.endmacro

.macro FarMalloc_Header_Dump
    .out "FarMalloc_Header_Dump"    
    jsl farmalloc_header_dump
.endmacro