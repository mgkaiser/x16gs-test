.import ll_init : far
.import ll_insert_head : far
.import ll_insert_tail : far    

.macro LL_Init list
    .out "LL_Init"        
    SetParamL list
    jsl ll_init
    FreeParams 2
.endmacro

.macro LL_InsertHead list, node
    .out "LL_InsertHead"        
    SetParamL list
    SetParamL node
    jsl ll_insert_head
    FreeParams 4
.endmacro

.macro LL_InsertTail list, node
    .out "LL_InsertTail"        
    SetParamL list
    SetParamL node
    jsl ll_insert_tail
    FreeParams 4
.endmacro