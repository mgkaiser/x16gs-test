.import pm
.import farmalloc_init: far
.import farmalloc_addblock: far
.import farmalloc_addblock: far
.import farmalloc: far
.import farfree: far

; Define Macros to call these functions from assembly
.macro FarMalloc_Init
    ;.out "FarMalloc_Init"    
    jsl farmalloc_init
.endmacro

.macro FarMalloc_AddBlock ptr, size
    ;.out "FarMalloc_AddBlock"        
    SetParamL ptr
    SetParamL size    
    jsl farmalloc_addblock
    FreeParams 4
.endmacro

.macro FarMalloc size, ptr
    ;.out "FarMalloc"
    SetRetValL        
    SetParamL size
    jsl farmalloc
    FreeParams 2
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta ptr
    stx ptr + 2
.endmacro

.macro FarFree ptr
    ;.out "FarFree"
    SetParamL ptr
    jsl farfree
    FreeParams 2
.endmacro

