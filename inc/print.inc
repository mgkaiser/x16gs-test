.import tohex: far
.import print: far
.import debug_print: far

.macro ToHex value, ptr
    ;.out "ToHex"        
    SetParam value    
    SetParamL ptr    
    jsl tohex
    FreeParams 3
.endmacro

.macro ToHexL value, ptr
    ;.out "ToHexL"        
    ToHex *value+2, #ptr
    ToHex *value, #ptr+4    
.endmacro

.macro Print value
    ;.out "Print"            
    SetParamL value
    jsl print
    FreeParams 2
.endmacro

.macro PrintCR
    ;.out "PrintCR" 
    .a16               
    lda #$000d
    jsl bsout_far
.endmacro

.macro DebugPrint value
    ;.out "Print"            
    SetParamL value
    jsl debug_print
    FreeParams 2
.endmacro

.macro DebugPrintCR
    ;.out "PrintCR" 
    mode8
    lda #$0a
    sta f:x16_debug::debug_print
    mode16
.endmacro

.macro DebugPrintHexLWithCR str, value, buffer
    ToHexL value, buffer
    DebugPrint #str
    DebugPrint #buffer    
    DebugPrintCR
.endmacro

