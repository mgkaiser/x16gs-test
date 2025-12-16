.import ll_init : far

.macro LL_Init list
    .out "LL_Init"        
    SetParamL list
    jsl ll_init
    FreeParams 2
.endmacro

.macro LL_InsertTail list, node
    .out "LL_InsertTail"        
    SetParamL list
    SetParamL node
    jsl ll_insert_tail
    FreeParams 4
.endmacro