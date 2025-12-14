.import tohex: far
.import print: far

.macro ToHex value, ptr
    .out "ToHex"        
    SetParam value    
    SetParamL ptr    
    jsl tohex
    FreeParams 3
.endmacro

.macro ToHexL value, ptr
    .out "ToHexL"        
    ToHex *value+2, #ptr
    ToHex *value, #ptr+4    
.endmacro

.macro Print value
    .out "Print"            
    SetParamL value
    jsl print
    FreeParams 2
.endmacro