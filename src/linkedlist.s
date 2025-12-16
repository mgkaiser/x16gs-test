.p816
.A16
.I16

.include "mac.inc"
.include "linkedlist_struct.inc"

; Define exports for all public functions in this module
.export ll_init
.export ll_insert_head
.export ll_insert_tail
.export ll_remove
;.export ll_move_to_top
;.export ll_move_to_bottom
;.export ll_move_up
;.export ll_move_down
.export ll_get_head
.export ll_get_tail
.export ll_get_next
.export ll_get_prev
;.export ll_is_empty
;.export ll_get_size
;.export ll_clear
;.export ll_iterate_forward
;.export ll_iterate_backward
    
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

.proc ll_remove : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 2                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam node, 0                                    ; uint32_t    
    DeclareParam list, 2                                    ; uint32_t                                  
    DeclareParam r_retVal, 4                                ; uint32_t 

    ; Setup stack frame
    SetupStackFrame   

    ; if (list == NULL || node == null) return NULL;
    lda list
    ora list+2
    beql LL_Remove_Exit
    lda node
    ora node+2      
    beql LL_Remove_Exit

    ; if (node->prev == NULL)
    ldy #ll_node::prev
    lda [node],y
    ldy #ll_node::prev+2
    ora [node],y
    beq l01

        ; l_temp = node->prev;
        ldy #ll_node::prev
        lda [node],y
        sta l_temp
        ldy #ll_node::prev+2
        lda [node],y
        sta l_temp+2

        ; l_temp->next = node->next;
        ldy #ll_node::next
        lda [node],y        
        sta [l_temp],y        
        ldy #ll_node::next+2
        lda [node],y        
        sta [l_temp],y

        bra l02
l01: ;else

        ; list->head = node->next;
        ldy #ll_node::next
        lda [node],y
        ldy #linkedlist::head
        sta [list],y
        ldy #ll_node::next+2
        lda [node],y
        ldy #linkedlist::head+2
        sta [list],y

l02: ;endif

    ; if (node->next == NULL)
    ldy #ll_node::next
    lda [node],y
    ldy #ll_node::next+2
    ora [node],y
    beq l11

        ; l_temp = node->next;
        ldy #ll_node::next
        lda [node],y
        sta l_temp
        ldy #ll_node::next+2
        lda [node],y
        sta l_temp+2

        ; l_temp->prev = node->prev;
        ldy #ll_node::prev
        lda [node],y
        sta [l_temp],y
        ldy #ll_node::prev+2
        lda [node],y
        sta [l_temp],y

        bra l12
l11: ;else     

        ; list->tail = node->prev;
        ldy #ll_node::prev
        lda [node],y
        ldy #linkedlist::tail
        sta [list],y
        ldy #ll_node::prev+2
        lda [node],y

l12: ;endif

LL_Remove_Exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
    
.endproc

.proc ll_get_head : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam list, 0                                    ; uint32_t                                  
    DeclareParam r_retVal, 2                                ; uint32_t 

    ; Setup stack frame
    SetupStackFrame   

    ; if (list == NULL) return NULL;
    lda list
    ora list+2
    beql LL_GetHead_Exit 

    ; Return list->head
    ldy #linkedlist::head
    lda [list],y
    sta r_retVal
    ldy #linkedlist::head+2
    lda [list],y
    sta r_retVal+2

LL_GetHead_Exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    

.proc ll_get_tail : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam list, 0                                    ; uint32_t                                  
    DeclareParam r_retVal, 2                                ; uint32_t 

    ; Setup stack frame
    SetupStackFrame   

    ; if (list == NULL) return NULL;
    lda list
    ora list+2
    beql LL_GetTail_Exit 

    ; Return list->head
    ldy #linkedlist::tail
    lda [list],y
    sta r_retVal
    ldy #linkedlist::tail+2
    lda [list],y
    sta r_retVal+2

LL_GetTail_Exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    

.proc ll_get_next : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam node, 0                                    ; uint32_t    
    DeclareParam list, 2                                    ; uint32_t                                  
    DeclareParam r_retVal, 4                                ; uint32_t 

    ; Setup stack frame
    SetupStackFrame   

    ; if (list == NULL || node == null) return NULL;
    lda list
    ora list+2
    beql LL_GetNext_Exit 
    lda node
    ora node+2
    beql LL_GetNext_Exit    

    ; Return node->next
    ldy #ll_node::next
    lda [node],y
    sta r_retVal
    ldy #ll_node::next+2
    lda [node],y
    sta r_retVal+2

LL_GetNext_Exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    

.proc ll_get_prev : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam node, 0                                    ; uint32_t    
    DeclareParam list, 2                                    ; uint32_t                                  
    DeclareParam r_retVal, 4                                ; uint32_t 

    ; Setup stack frame
    SetupStackFrame   

    ; if (list == NULL || node == null) return NULL;
    lda list
    ora list+2
    beql LL_GetPrev_Exit 
    lda node
    ora node+2
    beql LL_GetPrev_Exit    

    ; Return node->prev
    ldy #ll_node::prev
    lda [node],y
    sta r_retVal
    ldy #ll_node::prev+2
    lda [node],y
    sta r_retVal+2
    
LL_GetPrev_Exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    