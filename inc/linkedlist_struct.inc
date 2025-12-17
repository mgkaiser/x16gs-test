.struct ll_node
    prev        .dword 
    next        .dword
    destructor  .dword  ; function pointer to destructor function that takes the node as parameter
.endstruct

.struct linkedlist
    head        .dword 
    tail        .dword 
    count       .dword    
.endstruct  