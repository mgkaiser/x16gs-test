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