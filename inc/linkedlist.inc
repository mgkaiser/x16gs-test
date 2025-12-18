; Only import these if you are not in the linkedlist.s source file itself
.if !.xmatch(current_file, "linkedlist.s")

    .import ll_init : far
    .import ll_insert_head : far
    .import ll_insert_tail : far   
    .import ll_get_head : far
    .import ll_get_tail : far
    .import ll_remove : far
    ;.import ll_move_to_top : far
    ;.import ll_move_to_bottom : far
    ;.import ll_move_up : far
    ;.import ll_move_down : far
    .import ll_get_next : far
    .import ll_get_prev : far
    .import ll_is_empty : far
    .import ll_get_count : far
    .import ll_clear : far

.endif

.macro ll_node_contents
    prev        .dword 
    next        .dword
    destructor  .dword  ; function pointer to destructor function that takes the node as parameter
.endmacro

.struct ll_node
    ll_node_contents
.endstruct

.struct linkedlist
    head        .dword 
    tail        .dword 
    count       .dword    
.endstruct  

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

.macro LL_GetHead list, retval
    .out "LL_GetHead"
    SetRetValL        
    SetParamL list
    jsl ll_get_head
    FreeParams 2
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta retval
    stx retval + 2
.endmacro

.macro LL_Remove list, node
    .out "LL_Remove"    
    SetParamL list
    SetParamL node
    jsl ll_remove
    FreeParams 4    
.endmacro

.macro LL_GetTail list, retval
    .out "LL_GetTail"
    SetRetValL        
    SetParamL list
    jsl ll_get_tail
    FreeParams 2
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta retval
    stx retval + 2
.endmacro

.macro LL_GetNext list, node, retval
    .out "LL_GetNext"
    SetRetValL        
    SetParamL list
    SetParamL node
    jsl ll_get_next
    FreeParams 4
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta retval
    stx retval + 2
.endmacro

.macro LL_GetPrev list, node, retval
    .out "LL_GetPrev"
    SetRetValL        
    SetParamL list
    SetParamL node
    jsl ll_get_prev
    FreeParams 4
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta retval
    stx retval + 2
.endmacro

.macro LL_IsEmpty list, retval
    .out "LL_IsEmpty"
    SetRetValL        
    SetParamL list
    jsl ll_is_empty
    FreeParams 2
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta retval
    stx retval + 2
.endmacro

.macro LL_GetCount list, retval
    .out "LL_GetCount"
    SetRetValL        
    SetParamL list
    jsl ll_get_count
    FreeParams 2
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta retval
    stx retval + 2
.endmacro

.macro LL_Clear list
    .out "LL_Clear"        
    SetParamL list
    jsl ll_clear
    FreeParams 2
.endmacro