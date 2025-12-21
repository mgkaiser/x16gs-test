.p816
.A16
.I16

.scope
.define current_file "malloc.s"

.include "mac.inc"
.include "kernal.inc"
.include "x16.inc"
.include "print.inc"

; Define exports for all public functions in this module
.export farmalloc_init
.export farmalloc_addblock
.export farmalloc
.export farfree
.export pm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Internal structure definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.struct pmalloc_item
    prev        .dword 
    next        .dword 
    size        .word 
.endstruct

.struct pmalloc
    available   .dword 
    assigned    .dword 
    freemem     .dword 
    totalmem    .dword 
    totalnode   .dword 
.endstruct

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Private macros to call functions in this module
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define macros to call all private functions in this module
.macro FarMalloc_Item_Insert root, ptr  
    ;.out "FarMalloc_Item_Insert"        
    SetParamL f:root
    pei (ptr+2)
    pei (ptr)    
    jsl farmalloc_item_insert
    FreeParams 4
.endmacro

.macro FarMalloc_Item_Remove root, ptr  
    ;.out "FarMalloc_Item_Remove"        
    SetParamL f:root
    pei (ptr+2)
    pei (ptr)    
    jsl farmalloc_item_remove
    FreeParams 4
.endmacro

.macro FarMalloc_Merge node
    ;.out "FarMalloc_Merge"        
    pei (node+2)
    pei (node)   
    jsl farmalloc_merge
    FreeParams 2
.endmacro

.segment "MAIN"
pm: .res .sizeof(pmalloc)

.segment "OVERLAY1"

.proc farmalloc_init: far

    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocal l_p_pm, 0                                  ; This is a uint16_t local variable
    SetLocalCount 1                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    

    ; Setup stack frame
    SetupStackFrame   

    ; Store a pointer to pm in l_p_pm (a local variable in DP)
    lda #.LOWORD(pm)
    sta l_p_pm

    ; Initialize pmalloc structure 
    lda #$0000
    ldy #pmalloc::available
    sta (l_p_pm),y
    ldy #pmalloc::available+2
    sta (l_p_pm),y
    ldy #pmalloc::assigned
    sta (l_p_pm),y
    ldy #pmalloc::assigned+2
    sta (l_p_pm),y
    ldy #pmalloc::freemem
    sta (l_p_pm),y
    ldy #pmalloc::freemem+2
    sta (l_p_pm),y
    ldy #pmalloc::totalmem
    sta (l_p_pm),y
    ldy #pmalloc::totalmem+2
    sta (l_p_pm),y
    ldy #pmalloc::totalnode
    sta (l_p_pm),y
    ldy #pmalloc::totalnode+2
    sta (l_p_pm),y       

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl

.endproc

.proc farmalloc_addblock: far

    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocalL l_temp, 3                                 ; This is a uint32_t local variable
    DeclareLocal l_p_pm, 2                                  ; This is a uint16_t local variable
    DeclareLocalL l_usablesize, 0                           ; This is a uint32_t local variable
    SetLocalCount 5                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters
    DeclareParam size, 0                                    ; uint32_t size
    DeclareParam ptr, 2                                     ; uint32_t ptr

    ; Setup stack frame
    SetupStackFrame      

    ; Calculate the usable size of the block "l_usablesize = size - sizeof(pmalloc_item)"    
    sec
    lda size    
    sbc #.loword(.sizeof(pmalloc_item) )
    sta l_usablesize
    lda size+2
    sbc #.hiword(.sizeof(pmalloc_item) )
    sta l_usablesize+2

    ; Set the usable size of the block    
    lda l_usablesize
    ldy #pmalloc_item::size
    sta [ptr],y
    ldy #pmalloc_item::size + 2
    lda l_usablesize + 2
    sta [ptr],y
        
    ; Initialize the pmalloc_item::next and pmalloc_item::prev to NULL    
    lda #$0000
    ldy #pmalloc_item::next
    sta [ptr],y
    ldy #pmalloc_item::next+2    
    sta [ptr],y
    
    ldy #pmalloc_item::prev
    sta [ptr],y
    ldy #pmalloc_item::prev+2       
    sta [ptr],y

    ; Store a pointer to pm in l_p_pm (a local variable in DP)
    lda #.LOWORD(pm)
    sta l_p_pm

    ; Update freemem and totalmem "l_p_pm->freemem += l_usablesize; l_p_pm->totalmem += l_usablesize"
    clc
    ldy #pmalloc::freemem
    lda (l_p_pm),y
    adc l_usablesize
    sta (l_p_pm),y
    ldy #pmalloc::freemem+2
    lda (l_p_pm),y
    adc l_usablesize+2
    sta (l_p_pm),y

    clc
    ldy #pmalloc::totalmem
    lda (l_p_pm),y
    adc l_usablesize
    sta (l_p_pm),y
    ldy #pmalloc::totalmem+2
    lda (l_p_pm),y
    adc l_usablesize+2
    sta (l_p_pm),y
    
    ; Add it to the available heap
    FarMalloc_Item_Insert pm + pmalloc::available, ptr    
    ;FarMalloc_Chain_Dump pm + pmalloc::available, #malloc_available_str
    
    ; Update totalnodes "l_p_pm->totalnode++"    
    clc
    ldy #pmalloc::totalnode
    lda (l_p_pm),y
    adc #$0001
    sta (l_p_pm),y
    ldy #pmalloc::totalnode+2
    lda (l_p_pm),y
    adc #$0000
    sta (l_p_pm),y

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl

.endproc

.proc farmalloc: far

    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters    
    DeclareLocal l_p_pm, 6                                  ; This is a uint16_t local variable
    DeclareLocalL l_temp, 4                                 ; This is a uint32_t local variable
    DeclareLocalL l_newfree, 2                              ; This is a uint32_t local variable
    DeclareLocalL l_p_current, 0                            ; This is a uint32_t local variable
    SetLocalCount 7                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters        
    DeclareParam size, 0                                    ; uint32_t                                  
    DeclareParam r_retVal, 2                                ; uint32_t 

    ; Setup stack frame
    SetupStackFrame  

    ; Store a pointer to pm in l_p_pm (a local variable in DP)
    lda #.LOWORD(pm)
    sta l_p_pm

    ; current = pm->available
    ldy #pmalloc::available
    lda (l_p_pm),y
    sta l_p_current
    ldy #pmalloc::available+2
    lda (l_p_pm),y
    sta l_p_current + 2  

    ; Scan available list for a block large enough
farmalloc_loop:         
        ; if (current == NULL) goto not_found;        
        lda l_p_current + 2
        ora l_p_current
        beq farmalloc_loop_end
        
        ; if (l_p_current->pmalloc_item::size >= size) goto found;
        ldy #pmalloc_item::size+2        
        lda [l_p_current], y
        cmp size +2
        bne :+
        ldy #pmalloc_item::size
        lda [l_p_current], y
        cmp size
:       bcs farmalloc_loop_found
                
farmalloc_next_block:        
        ; current = current->pmalloc_item::next
        ldy #pmalloc_item::next
        lda [l_p_current],y
        sta l_p_current
        ldy #pmalloc_item::next+2
        lda [l_p_current],y
        sta l_p_current + 2        
        bra farmalloc_loop
farmalloc_loop_end:    

    ; If there is current == null then there's nothing available so we return null
    lda l_p_current
    sta r_retVal
    lda l_p_current + 2    
    sta r_retVal + 2
    brl farmalloc_exit

farmalloc_loop_found:    
    
    ; Remove it from available
    FarMalloc_Item_Remove pm + pmalloc::available, l_p_current       

    ; Add it to assigned    
    FarMalloc_Item_Insert pm + pmalloc::assigned,  l_p_current    
    
    ; if (current->pmalloc_item::size == size) { ... }
    ldy #pmalloc_item::size
    lda [l_p_current],y
    cmp size
    beql malloc_skip_split         
    ldy #pmalloc_item::size+2
    lda [l_p_current],y
    cmp size+2
    beql malloc_skip_split  
                
        ; newfree = current + .sizeof(pmalloc_item) + size;
        clc
        lda l_p_current
        adc #.LOWORD(.sizeof(pmalloc_item))        
        adc size
        sta l_newfree
        lda l_p_current + 2
        adc #.HIWORD(.sizeof(pmalloc_item))
        adc size+2  
        sta l_newfree + 2                

        ;newfree->pmalloc_item::size = current->pmalloc_item::size - size - .sizeof(pmalloc_item);
        
        ; Calculate current->pmalloc_item::size - size - .sizeof(pmalloc_item)
        sec
        ldy #pmalloc_item::size
        lda [l_p_current],y
        sbc size
        sbc #.LOWORD(.sizeof(pmalloc_item))
        sta l_temp
        ldy #pmalloc_item::size+2
        lda [l_p_current],y
        sbc size+2
        sbc #.HIWORD(.sizeof(pmalloc_item))
        sta l_temp + 2
        
        ; Store in newfree->pmalloc_item::size
        ldy #pmalloc_item::size
        lda l_temp
        sta [l_newfree],y
        ldy #pmalloc_item::size+2
        lda l_temp + 2
        sta [l_newfree],y

        ;l_newfree->pmalloc_item::next = l_p_current->pmalloc_item::next;    
        ldy #pmalloc_item::next
        lda [l_p_current],y
        sta [l_newfree],y
        ldy #pmalloc_item::next+2
        lda [l_p_current],y
        sta [l_newfree],y

        ; l_newfree->pmalloc_item::prev = NULL;
        ldy #pmalloc_item::prev
        lda #$0000
        sta [l_newfree],y
        ldy #pmalloc_item::prev+2
        sta [l_newfree],y

        ; l_p_current->pmalloc_item::size = size;
        ldy #pmalloc_item::size
        lda size
        sta [l_p_current],y
        ldy #pmalloc_item::size+2
        lda size+2
        sta [l_p_current],y

        ; Add newfree to available list
        FarMalloc_Item_Insert pm + pmalloc::available, l_newfree        

        ; l_p_pm->freemem -= .sizeof(pmalloc_item);
        sec
        ldy #pmalloc::freemem
        lda (l_p_pm),y
        sbc #.LOWORD(.sizeof(pmalloc_item))
        sta (l_p_pm),y
        ldy #pmalloc::freemem+2
        lda (l_p_pm),y
        sbc #.HIWORD(.sizeof(pmalloc_item))
        sta (l_p_pm),y
        
        ; Update totalnodes "l_p_pm->totalnode++"
        clc
        ldy #pmalloc::totalnode
        lda (l_p_pm),y        
        adc #$0001
        sta (l_p_pm),y
        ldy #pmalloc::totalnode+2
        lda (l_p_pm),y
        adc #$0000
        sta (l_p_pm),y

        ; Merge around newfree        
        FarMalloc_Merge l_newfree

malloc_skip_split:

    ; pm.freemem -= l_p_current->pmalloc_item::size;
    ldy #pmalloc_item::size
    lda [l_p_current],y
    sta l_newfree
    ldy #pmalloc_item::size+2
    lda [l_p_current],y
    sta l_newfree + 2 
    sec
    ldy #pmalloc::freemem
    lda (l_p_pm),y
    sbc l_newfree
    sta (l_p_pm),y
    ldy #pmalloc::freemem+2
    lda (l_p_pm),y
    sbc l_newfree + 2
    sta (l_p_pm),y

    ; r_retVal = current + sizeof(pmalloc_item);
    clc
    lda l_p_current
    adc #.LOWORD(.sizeof(pmalloc_item))
    sta r_retVal
    lda l_p_current + 2
    adc #.HIWORD(.sizeof(pmalloc_item))
    sta r_retVal + 2
        
farmalloc_exit:

    ;FarMalloc_Chain_Dump pm + pmalloc::available, #malloc_available_str
    ;FarMalloc_Chain_Dump pm + pmalloc::assigned, #malloc_assigned_str

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl

.endproc    

.proc farfree: far
    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocal l_p_pm, 2                                  ; This is a uint16_t local variable    
    DeclareLocalL l_node, 0                                 ; This is a uint32_t local variable
    SetLocalCount 3                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters        
    DeclareParam ptr, 0                                     ; uint32_t ptr                                 

    ; Setup stack frame
    SetupStackFrame       

    ;if (ptr == NULL) return;
    lda ptr
    ora ptr+2
    beql farfree_exit

    ; node = ptr - sizeof(pmalloc_item)
    sec
    lda ptr
    sbc #.LOWORD(.sizeof(pmalloc_item))
    sta l_node
    lda ptr+2
    sbc #.HIWORD(.sizeof(pmalloc_item))
    sta l_node+2

    ; Remove it from pm->assigned          
    FarMalloc_Item_Remove pm + pmalloc::assigned, l_node    
    ;FarMalloc_Chain_Dump pm + pmalloc::assigned, #malloc_assigned_str    
    
    ; Store a pointer to pm in l_p_pm (a local variable in DP)
    lda #.LOWORD(pm)
    sta l_p_pm

    ; Free memory increases by node size    
    clc
    ldy #pmalloc::freemem
    lda (l_p_pm),y
    ldy #pmalloc_item::size
    adc [l_node],y
    ldy #pmalloc::freemem
    sta (l_p_pm),y

    ldy #pmalloc::freemem+2
    lda (l_p_pm),y
    ldy #pmalloc_item::size+2
    adc [l_node],y
    ldy #pmalloc::freemem+2
    sta (l_p_pm),y

    ; Add it from pm->available            
    FarMalloc_Item_Insert pm + pmalloc::available, l_node    
    ;FarMalloc_Chain_Dump pm + pmalloc::available, #l_node    
    
    ; Merge around current    
    FarMalloc_Merge l_node

farfree_exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl

.endproc         


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Private functions

.proc farmalloc_merge: far

    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocal l_p_pm, 4                                  ; This is a uint16_t local variable
    DeclareLocalL l_temp2, 2                                ; This is a uint32_t local variable
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 5                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters        
    DeclareParam node, 0                                     ; uint32_t ptr                                 

    ; Setup stack frame
    SetupStackFrame     

    ; Scan backward for contiguous blocks
    ; while (node->pmalloc_item::pmalloc_item::next != NULL && node == node->pmalloc_item::prev + .sizeof(pmalloc_item) + node->pmalloc_item::prev->pmalloc_item::size ) { ... }
farmalloc_merge_loop:   

        ; if (node->pmalloc_item::next == NULL) break;
        ldy #pmalloc_item::prev
        lda [node],y
        ldy #pmalloc_item::prev+2
        ora [node],y
        beq farmalloc_merge_loop_end

        ; if (node == node->pmalloc_item::prev + .sizeof(pmalloc_item) + node->pmalloc_item::prev->pmalloc_item::size ) { ... }
        ; Calculate node->pmalloc_item::prev + .sizeof(pmalloc_item) + node->pmalloc_item::prev->pmalloc_item::size 

        ; l_temp2 = node->pmalloc_item::prev
        ldy #pmalloc_item::prev
        lda [node],y
        sta l_temp2
        ldy #pmalloc_item::prev+2
        lda [node],y
        sta l_temp2 + 2 
        
        ; l_temp = node->pmalloc_item::prev + .sizeof(pmalloc_item)
        clc

        ldy #pmalloc_item::prev
        lda [node],y
        ldy #pmalloc_item::size        
        adc [l_temp2],y        
        adc #.LOWORD(.sizeof(pmalloc_item))
        sta l_temp

        ldy #pmalloc_item::prev+2
        lda [node],y
        ldy #pmalloc_item::size+2        
        adc [l_temp2],y        
        adc #.HIWORD(.sizeof(pmalloc_item))
        sta l_temp + 2                              

        ; Compare with node
        lda node
        cmp l_temp + 0
        bne farmalloc_merge_loop_end        
        lda node + 2
        cmp l_temp + 2
        bne farmalloc_merge_loop_end        

        ; Merge blocks here 
        ; l_temp = node->pmalloc_item::prev
        ldy #pmalloc_item::prev
        lda [node],y
        sta l_temp
        ldy #pmalloc_item::prev+2
        lda [node],y
        sta l_temp + 2

        ; node = l_temp
        lda l_temp
        sta node
        lda l_temp + 2
        sta node + 2        

        bra farmalloc_merge_loop

    farmalloc_merge_loop_end:

    ; Scan forward and merge free blocks    
farmalloc_merge_forward_loop:    

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Original code did not have a null check
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; if (node->pmalloc_item::next == NULL) break;
    ;ldy #pmalloc_item::next
    ;lda [node],y
    ;ldy #pmalloc_item::next+2
    ;ora [node],y
    ;beq farmalloc_merge_forward_loop_end

    ; if (node->pmalloc_item::next == node + .sizeof(pmalloc_item) + node->pmalloc_item::size ) { ... }
    ; Calculate node + .sizeof(pmalloc_item)
    clc
    ldy #pmalloc_item::size
    lda node
    adc #.LOWORD(.sizeof(pmalloc_item))
    adc [node],y
    sta l_temp

    ldy #pmalloc_item::size + 2
    lda node+2
    adc #.HIWORD(.sizeof(pmalloc_item))
    adc [node],y
    sta l_temp+2    

    ; Compare with node->pmalloc_item::next
    ldy #pmalloc_item::next
    lda [node],y
    cmp l_temp
    bnel farmalloc_merge_forward_loop_end      
    ldy #pmalloc_item::next+2
    lda [node],y
    cmp l_temp+2
    bnel farmalloc_merge_forward_loop_end 

    ;l_temp = node->pmalloc_item::next;
        
    ; l_temp2 = node->pmalloc_item::next->pmalloc_item::size + sizeof(pmalloc_item);
    clc
    ldy #pmalloc_item::size     
    lda [l_temp],y
    adc #.LOWORD(.sizeof(pmalloc_item))    
    sta l_temp2
    ldy #pmalloc_item::size+2
    lda [l_temp],y
    adc #.HIWORD(.sizeof(pmalloc_item))
    sta l_temp2 + 2             

    ; Store a pointer to pm in l_p_pm (a local variable in DP)
    lda #.LOWORD(pm)
    sta l_p_pm

    ;l_p_pm->freemem += .sizeof(pmalloc_item);
    clc
    ldy #pmalloc::freemem
    lda (l_p_pm),y    
    adc #.LOWORD(.sizeof(pmalloc_item))
    sta (l_p_pm),y
    ldy #pmalloc::freemem+2
    lda (l_p_pm),y
    adc #.HIWORD(.sizeof(pmalloc_item))
    sta (l_p_pm),y      

    ; Call FarMalloc_Item_Remove(pm + pmalloc::available, node->pmalloc_item::next)    
    FarMalloc_Item_Remove pm + pmalloc::available, l_temp       
     
    ;l_p_pm->totalnodes--;
    sec
    ldy #pmalloc::totalnode
    lda (l_p_pm),y
    sbc #$0001
    sta (l_p_pm),y
    ldy #pmalloc::totalnode+2
    lda (l_p_pm),y
    sbc #$0000
    sta (l_p_pm),y
    
    ; node->pmalloc_item::size += l_temp;    
    clc
    ldy #pmalloc_item::size
    lda [node],y
    adc l_temp2
    sta [node],y
    ldy #pmalloc_item::size+2
    lda [node],y
    adc l_temp2 + 2
    sta [node],y

    brl farmalloc_merge_forward_loop

farmalloc_merge_forward_loop_end:

    ;FarMalloc_Chain_Dump pm + pmalloc::available, #malloc_available_str  

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl

.endproc

.proc farmalloc_item_remove:far

    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters        
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 2                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam node, 0                                    ; uint32_t ptr                                 
    DeclareParam root, 2                                    ; uint32_t root                               

    ; Setup stack frame
    SetupStackFrame  

    ; Remove the node
    ; if (node->pmalloc_item::prev != NULL) node->pmalloc_item::prev->pmalloc_item::next = node->pmalloc_item::next;
    ldy #pmalloc_item::prev
    lda [node],y
    ldy #pmalloc_item::prev + 2
    ora [node],y
    beq :+
        ; node->pmalloc_item::prev->pmalloc_item::next = node->pmalloc_item::next;
        ldy #pmalloc_item::prev
        lda [node],y
        sta l_temp
        ldy #pmalloc_item::prev+2
        lda [node],y
        sta l_temp + 2        

        ldy #pmalloc_item::next
        lda [node],y
        sta [l_temp],y
        ldy #pmalloc_item::next+2
        lda [node],y
        sta [l_temp],y    
    :

    ; if (node->pmalloc_item::next != NULL) node->pmalloc_item::next->pmalloc_item::prev = node->pmalloc_item::prev;
    ldy #pmalloc_item::next
    lda [node],y
    ldy #pmalloc_item::next + 2
    ora [node],y
    beq :+
        ; node->pmalloc_item::next->pmalloc_item::prev = node->pmalloc_item::prev;
        ldy #pmalloc_item::next
        lda [node],y
        sta l_temp
        ldy #pmalloc_item::next+2
        lda [node],y
        sta l_temp + 2

        ldy #pmalloc_item::prev
        lda [node],y
        sta [l_temp],y
        ldy #pmalloc_item::prev+2
        lda [node],y
        sta [l_temp],y
    :

    ; if (node == l_p_root)    
    ldy #$0002
    lda node
    cmp [root]
    bnel l2_endif
    lda node + 2    
    cmp [root],y
    bnel l2_endif     

        ; if (node->pmalloc_item::prev != NULL) l_p_root = node->pmalloc_item::prev; else l_p_root = node->pmalloc_item::next;
        ldy #pmalloc_item::prev
        lda [node],y
        ldy #pmalloc_item::prev+2
        ora [node],y
        beq l1_endif
            ; *root = node->pmalloc_item::prev;
            ldy #pmalloc_item::prev
            lda [node], y
            sta [root]
            ldy #pmalloc_item::prev+2
            lda [node]
            ldy #$0002
            sta [root], y
            bra l2_endif
        l1_endif:

        ldy #pmalloc_item::next
        lda [node],y
        ldy #pmalloc_item::next+2
        ora [node],y
        beq l3_endif
            ; *root = node->pmalloc_item::next;  
            ldy #pmalloc_item::next
            lda [node],y
            sta [root]
            ldy #pmalloc_item::next+2
            lda [node],y
            ldy #$0002
            sta [root], y   
            bra l2_endif 
        l3_endif: 

        ; If you get here, both prev and next are NULL  
        ; *root = NULL;
        ldy #$0002
        lda #$0000
        sta [root]
        sta [root],y    

    l2_endif:        

    ; node->next = NULL
    ldy #pmalloc_item::next
    lda #$0000
    sta [node],y
    ldy #pmalloc_item::next+2
    sta [node],y

	; node->prev = NULL
    ldy #pmalloc_item::prev
    lda #$0000
    sta [node],y
    ldy #pmalloc_item::prev+2
    sta [node],y

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl

.endproc     

.proc farmalloc_item_insert: far

    ; Save working registers
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl" 

    ; Create local variable - Number in descending order, skip 2 for long parameters
    DeclareLocalL l_temp, 10                                ; This is a uint32_t local variable
    DeclareLocalL l_p_oldnext, 8                            ; This is a uint32_t local variable
    DeclareLocalL l_p_current, 6                            ; This is a uint32_t local variable
    DeclareLocalL l_p_node, 4                               ; This is a uint32_t local variable
    DeclareLocalL l_p_oldroot, 2                            ; This is a uint32_t local variable
    DeclareLocalL l_p_root, 0                               ; This is a uint32_t local variable
    SetLocalCount 12                                        ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters
    DeclareParam ptr, 0                                     ; uint32_t ptr                                 
    DeclareParam root, 2                                    ; uint32_t root

    ; Setup stack frame
    SetupStackFrame    

    ; if (*root == NULL) { *root = ptr; return; }      
    lda [root]
    ldy #$0002
    ora [root],y
    bne :+

        ; *root = ptr
        lda ptr
        sta [root]
        sta l_p_root
        lda ptr+2
        ldy #$0002
        sta [root],y
        sta l_p_root + 2

        ; (*root)->prev = NULL
        lda #$0000
        ldy #pmalloc_item::prev
        sta [l_p_root],y
        ldy #pmalloc_item::prev+2
        sta [l_p_root],y
        
        ; (*root)->next = NULL  
        lda #$0000
        ldy #pmalloc_item::next
        sta [l_p_root],y
        ldy #pmalloc_item::next+2
        sta [l_p_root],y

        ; return
        brl farmalloc_item_insert_exit
:

    ; Where is the block in relation to root

    ; l_p_root = *root    
    lda [root]
    sta l_p_root
    ldy #$0002
    lda [root],y
    sta l_p_root + 2 

    ;if (ptr < l_p_root) { ... }        
    lda ptr+2
    cmp l_p_root+2
    bne o1
    lda ptr
    cmp l_p_root
o1: bcc o2
    bra o3

o2:     ; Code when true
        
        ; New block goes before root
        ;*l_p_oldroot = *l_p_root
        lda l_p_root
        sta l_p_oldroot
        lda l_p_root + 2
        sta l_p_oldroot + 2

        ; l_p_oldroot->prev = ptr
        ldy #pmalloc_item::prev
        lda ptr
        sta [l_p_oldroot],y
        ldy #pmalloc_item::prev+2
        lda ptr + 2
        sta [l_p_oldroot],y
                
        ; ptr->next = *l_p_oldroot
        ldy #pmalloc_item::next
        lda l_p_oldroot
        sta [ptr],y
        ldy #pmalloc_item::next+2
        lda l_p_oldroot+2   
        sta [ptr],y 

        ; *root = ptr
        lda ptr
        sta [root]
        ldy #$0002
        lda ptr+2
        sta [root],y

        brl farmalloc_item_insert_exit

    ; else

o3:     ; Code when false

        ; New block goes witin or at end of list

        ; current = *root
        lda l_p_root
        sta l_p_current
        lda l_p_root + 2
        sta l_p_current + 2 

        ; node = *ptr
        lda ptr
        sta l_p_node
        lda ptr + 2
        sta l_p_node + 2
        
        ;while(l_p_current->next != NULL && l_p_node > l_p_current->next) l_p_current = l_p_current->next;

farmalloc_item_insert_loop:

        ; if l_p_current->next == NULL goto exit
        ldy #pmalloc_item::next
        lda [l_p_current],y
        ldy #pmalloc_item::next+2
        ora [l_p_current],y
        beql f2
        
        ; l_p_node <= l_p_current->next        
        ldy #pmalloc_item::next+2
        lda [l_p_current],y
        cmp l_p_node + 2
        bne f1
        ldy #pmalloc_item::next
        lda [l_p_current],y
        cmp l_p_node
f1:     bcs f2
        beq f2

        ; l_p_current = l_p_current->next
        ldy #pmalloc_item::next
        lda [l_p_current],y
        sta l_temp
        ldy #pmalloc_item::next+2
        lda [l_p_current],y
        sta l_temp + 2
        lda l_temp
        sta l_p_current
        lda l_temp + 2
        sta l_p_current + 2                

        brl farmalloc_item_insert_loop
f2:
    ; if (l_p_current->next == NULL) { ... }
    ldy #pmalloc_item::next
    lda [l_p_current],y
    ldy #pmalloc_item::next+2
    ora [l_p_current],y
    bnel g1

        ; l_p_node->prev = l_p_current
        ldy #pmalloc_item::prev
        lda l_p_current
        sta [l_p_node],y        
        ldy #pmalloc_item::prev+2
        lda l_p_current + 2
        sta [l_p_node],y

        ; l_p_current->next = l_p_node
        ldy #pmalloc_item::next
        lda l_p_node
        sta [l_p_current],y
        ldy #pmalloc_item::next+2
        lda l_p_node + 2
        sta [l_p_current],y 
        
    bra g2

g1: ;else       

    ; l_p_oldnext = l_p_current->next
    ldy #pmalloc_item::next
    lda [l_p_current],y
    sta l_p_oldnext
    ldy #pmalloc_item::next+2
    lda [l_p_current],y
    sta l_p_oldnext + 2 

    ; l_p_current->next = l_p_node
    ldy #pmalloc_item::next
    lda l_p_node
    sta [l_p_current],y 
    ldy #pmalloc_item::next+2
    lda l_p_node + 2
    sta [l_p_current],y

    ; l_p_node->prev = l_p_current
    ldy #pmalloc_item::prev
    lda l_p_current
    sta [l_p_node],y
    ldy #pmalloc_item::prev+2
    lda l_p_current + 2
    sta [l_p_node],y

    ; l_p_node->next = l_p_oldnext
    ldy #pmalloc_item::next
    lda l_p_oldnext
    sta [l_p_node],y
    ldy #pmalloc_item::next+2
    lda l_p_oldnext + 2
    sta [l_p_node],y

    ; l_p_oldnext->prev = l_p_node
    ldy #pmalloc_item::prev
    lda l_p_node
    sta [l_p_oldnext],y
    ldy #pmalloc_item::prev+2
    lda l_p_node + 2
    sta [l_p_oldnext],y    

g2: ;endif 
    
farmalloc_item_insert_exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl

.endproc

.endscope