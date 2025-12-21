.p816
.A16
.I16

.scope
.define current_file "linkedlist.s"

.include "mac.inc"
.include "malloc.inc"
.include "linkedlist.inc"

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
.export ll_is_empty
.export ll_get_count
.export ll_clear
    
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
    DeclareParam node, 0                                     ; uint32_t ptr
    DeclareParam list, 2                                     ; uint32_t ptr

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
    sta [node],y

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
    DeclareParam node, 0                                     ; uint32_t ptr
    DeclareParam list, 2                                     ; uint32_t ptr

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
    lda #$0000
    ldy #ll_node::next
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
    sta [node],y
    
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
    clc
    ldy #linkedlist::count
    lda [list],y    
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
    DeclareParam node, 0                                     ; uint32_t ptr
    DeclareParam list, 2                                     ; uint32_t ptr

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

.proc ll_is_empty : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam list, 0                                    ; uint32_t                                  
    DeclareParam r_retVal, 2                                ; uint32_t 

    ; Setup stack frame
    SetupStackFrame   

    ; if (list == NULL) return 1;
    lda list
    ora list+2
    bne l1
        lda #$0001
        sta r_retVal
        lda #$0000
        sta r_retVal+2
        bra LL_IsEmpty_Exit

l1: ; Return (list->head == NULL) ? 1 : 0;
    ldy #linkedlist::head
    lda [list],y
    ldy #linkedlist::head+2
    ora [list],y
    beq l2
        lda #$0000
        sta r_retVal
        lda #$0000
        sta r_retVal+2
        bra LL_IsEmpty_Exit
l2: ;    
        lda #$0001
        sta r_retVal
        lda #$0000
        sta r_retVal+2

LL_IsEmpty_Exit:    

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    

.proc ll_get_count : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam list, 0                                    ; uint32_t                                  
    DeclareParam r_retVal, 2                                ; uint32_t 

    ; Setup stack frame
    SetupStackFrame   

    ; if (list == NULL) return 0;
    lda list
    ora list+2
    bne l1
        lda #$0000
        sta r_retVal
        lda #$0000
        sta r_retVal+2
        bra LL_GetCount_Exit    

l1: ; Return list->count
    ldy #linkedlist::count
    lda [list],y
    sta r_retVal
    ldy #linkedlist::count+2
    lda [list],y
    sta r_retVal+2

LL_GetCount_Exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc

.proc ll_clear : far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    DeclareLocalL l_func, 4                                 ; This is a uint32_t local variable
    DeclareLocalL l_next, 2                                 ; This is a uint32_t local variable
    DeclareLocalL l_current, 0                              ; This is a uint32_t local variable
    SetLocalCount 6                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam list, 0                                    ; uint32_t                                  

    ; Setup stack frame
    SetupStackFrame   

    ; if (list == NULL) return;
    lda list
    ora list+2
    beql LL_Clear_Exit 

    ; if (list->head == NULL) return;
    ldy #linkedlist::head
    lda [list],y
    ldy #linkedlist::head+2
    ora [list],y
    beq LL_Clear_Exit

    ; while (l_current != NULL)
l1:

        ; l_current = list->head;
        ldy #linkedlist::head
        lda [list],y
        sta l_current
        ldy #linkedlist::head+2
        lda [list],y
        sta l_current+2

        ; l_next = l_current->next;
        ldy #ll_node::next
        lda [l_current],y
        sta l_next
        ldy #ll_node::next+2
        lda [l_current],y
        sta l_next+2

        ;current = next;
        lda l_next
        sta l_current
        lda l_next+2
        sta l_current+2

        ; ll_remove(list, node);
        SetParamL *list
        SetParamL *l_current
        jsl ll_remove
        FreeParams 4         

        ; if node->ll_node::destructor == null goto l2;
        ldy #ll_node::destructor
        lda [l_current],y
        ldy #ll_node::destructor+2
        ora [l_current],y
        beq l2

            ; l_func = node->ll_node::destructor;
            ldy #ll_node::destructor
            lda [l_current],y
            sta l_func
            ldy #ll_node::destructor+2
            lda [l_current],y
            sta l_func+2

            ; Call destructor function            
            SetParamL *l_current
            jsl_ptr l_func
            FreeParams 2
        
l2:     ; endif

        ; if (current != null) goto l1;
        lda l_current
        ora l_current+2
        bne l1
    ; End while

LL_Clear_Exit:  

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc

.endscope