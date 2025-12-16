.p816
.A16
.I16

.include "mac.inc"
.include "linkedlist_struct.inc"

; Define exports for all public functions in this module
.export ll_init
.export ll_insert_head
.export ll_insert_tail
    
.segment "OVERLAY1"

.proc ll_init: far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam list, 0                                     ; uint32_t ptr

    ; Setup stack frame
    SetupStackFrame    

    ; Initialize linked list system
    lda #$0000
    ldy #linkedlist::head
    sta [list],y    
    ldy #linkedlist::head+2
    sta [list],y

    ldy #linkedlist::tail
    sta [list],y
    ldy #linkedlist::tail+2
    sta [list],y

    ldy #linkedlist::count
    sta [list],y
    ldy #linkedlist::count+2
    sta [list],y

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc  

.proc ll_insert_head : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 2                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam node, 2                                     ; uint32_t ptr
    DeclareParam list, 0                                     ; uint32_t ptr

    ; Setup stack frame
    SetupStackFrame    

    ; if (list == NULL || node == NULL) return;
    lda list
    ora list+2
    beql LL_InsertHead_Exit
    lda node
    ora node+2
    beql LL_InsertHead_Exit  

    ; node->next = list->head;
    ldy #linkedlist::head
    lda [list],y
    ldy #ll_node::next
    sta [node],y
    ldy #linkedlist::head+2
    lda [list],y
    ldy #ll_node::next+2        

    ; node->prev = NULL;
    ldy #ll_node::prev
    lda #$0000
    sta [node],y
    ldy #ll_node::prev+2
    sta [node],y            
    
    ; if (list->tail == NULL)   
    ldy #linkedlist::head
    lda [list],y
    ldy #linkedlist::head+2
    ora [list],y
    beq l1

        ;list->tail->next = node;
        
        ; l_temp = list->head;
        ldy #linkedlist::head
        lda [list],y
        sta l_temp
        ldy #linkedlist::head+2
        lda [list],y
        sta l_temp+2

        ; l_temp->prev = node;
        ldy #ll_node::prev
        lda node
        sta [l_temp],y
        ldy #ll_node::prev+2
        lda node+2
        sta [l_temp],y

l1: ; list->head = node;
    ldy #linkedlist::head
    lda node
    sta [list],y
    ldy #linkedlist::head+2
    lda node+2
    sta [list],y

    ; if (list->tail != NULL)
    ldy #linkedlist::tail
    lda [list],y
    ldy #linkedlist::tail+2
    ora [list],y
    bne l2

        ; list->tail = node;
        ldy #linkedlist::tail
        lda node
        sta [list],y
        ldy #linkedlist::tail+2
        lda node+2
        sta [list],y        

l2: ; Increment the node count
    ldy #linkedlist::count
    lda [list],y
    clc
    adc #$0001
    sta [list],y
    ldy #linkedlist::count+2
    lda [list],y
    adc #$0000
    sta [list],y    
    
LL_InsertHead_Exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc 


.proc ll_insert_tail : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 2                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam node, 2                                     ; uint32_t ptr
    DeclareParam list, 0                                     ; uint32_t ptr

    ; Setup stack frame
    SetupStackFrame    

    ; if (list == NULL || node == NULL) return;
    lda list
    ora list+2
    beql LL_InsertTail_Exit
    lda node
    ora node+2
    beql LL_InsertTail_Exit  

    ; Add node to the end of the list
    ; node->next = NULL;
    ldy #ll_node::next
    lda #$0000
    sta [node],y
    ldy #ll_node::next+2
    sta [node],y        

    ; node->prev = list->tail;
    ldy #linkedlist::tail
    lda [list],y
    ldy #ll_node::prev
    sta [node],y
    ldy #linkedlist::tail+2
    lda [list],y
    ldy #ll_node::prev+2        
    
    ; if (list->tail == NULL)   
    ldy #linkedlist::tail
    lda [list],y
    ldy #linkedlist::tail+2
    ora [list],y
    beq l1

        ;list->tail->next = node;
        
        ; l_temp = list->tail;
        ldy #linkedlist::tail
        lda [list],y
        sta l_temp
        ldy #linkedlist::tail+2
        lda [list],y
        sta l_temp+2

        ; l_temp->next = node;
        ldy #ll_node::next
        lda node
        sta [l_temp],y
        ldy #ll_node::next+2
        lda node+2
        sta [l_temp],y

l1: ; list->tail = node;
    ldy #linkedlist::tail
    lda node
    sta [list],y
    ldy #linkedlist::tail+2
    lda node+2
    sta [list],y

    ; if (list->head != NULL)
    ldy #linkedlist::head
    lda [list],y
    ldy #linkedlist::head+2
    ora [list],y
    bne l2

        ; list->head = node;
        ldy #linkedlist::head
        lda node
        sta [list],y
        ldy #linkedlist::head+2
        lda node+2
        sta [list],y        

l2: ; Increment the node count
    ldy #linkedlist::count
    lda [list],y
    clc
    adc #$0001
    sta [list],y
    ldy #linkedlist::count+2
    lda [list],y
    adc #$0000
    sta [list],y    
    
LL_InsertTail_Exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc 
