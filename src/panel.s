.p816
.A16
.I16

.include "mac.inc"
.include "malloc.inc"
.include "linkedlist_struct.inc"
.include "linkedlist.inc"
.include "panel_struct.inc"

; Define exports for all public functions in this module
.export panel_create
.export panel_init
.export panel_done
.export panel_destroy
.export panel_draw
    
.segment "OVERLAY1"

.proc panel_create: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam character, 0                               ; This is a uint16_t parameter
    DeclareParam h, 1                                       ; This is a uint16_t parameter
    DeclareParam w, 2                                       ; This is a uint16_t parameter
    DeclareParam ypos, 3                                    ; This is a uint16_t parameter
    DeclareParam xpos, 4                                    ; This is a uint16_t parameter
    DeclareParam r_retVal, 5                                ; uint32_t 
    
    ; Setup stack frame
    SetupStackFrame     

    ; Create and init the panel structure
    FarMalloc #.sizeof(wi_panel), r_retVal              
    SetParamL *r_retVal
    SetParam *xpos
    SetParam *ypos
    SetParam *w
    SetParam *h
    SetParam *character
    jsl panel_init
    FreeParams 7  
    
    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc  

.proc panel_init: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam character, 0                               ; This is a uint16_t parameter
    DeclareParam h, 1                                       ; This is a uint16_t parameter
    DeclareParam w, 2                                       ; This is a uint16_t parameter
    DeclareParam ypos, 3                                    ; This is a uint16_t parameter
    DeclareParam xpos, 4                                    ; This is a uint16_t parameter    
    DeclareParam panel, 5                                   ; This is a uint32_t parameter

    ; Setup stack frame
    SetupStackFrame     
    
    ; panel->xpos = xpos;
    ldy #wi_panel::xpos
    lda xpos
    sta [panel], y

    ; panel->ypos = ypos;
    ldy #wi_panel::ypos
    lda ypos
    sta [panel], y

    ; panel->w = w;
    ldy #wi_panel::w
    lda w
    sta [panel], y
    
    ; panel->h = h;
    ldy #wi_panel::h
    lda h
    sta [panel], y

    ; panel->character = character;
    ldy #wi_panel::character
    lda character
    sta [panel], y

    ; panel->destructor = panel_destroy;
    ldy #wi_panel::destructor
    lda #.loword(panel_destroy)
    sta [panel], y
    ldy #wi_panel::destructor+2
    lda #.hiword(panel_destroy)
    sta [panel], y

    ; panel->draw = panel_draw;
    ldy #wi_panel::draw
    lda #.loword(panel_draw)
    sta [panel], y
    ldy #wi_panel::draw+2
    lda #.hiword(panel_draw)
    sta [panel], y    

    ; panel->get_bounds = panel_get_bounds;
    ldy #wi_panel::getbounds
    lda #.loword(panel_get_bounds)
    sta [panel], y
    ldy #wi_panel::getbounds+2
    lda #.hiword(panel_get_bounds)
    sta [panel], y
    
    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc  

.proc panel_done: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 2                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam panel, 0                                   ; This is a uint32_t parameter

    ; Setup stack frame
    SetupStackFrame    

    ; l_temp = (uint32_t)panel->children;
    ldy #wi_panel::children
    lda [panel], y
    sta l_temp
    ldy #wi_panel::children+2
    lda [panel], y
    sta l_temp+2
    
    ; Clear and free the children linked list
    LL_Clear *l_temp
    FarFree *l_temp
    
    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    

.proc panel_destroy: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        

    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters   
    DeclareParam panel, 0                                   ; This is a uint32_t parameter

    ; Setup stack frame
    SetupStackFrame     

    ; Clean up any children of the panel here (if any)
    SetParamL *panel
    jsl panel_done
    FreeParams 2
    
    ; Free the panel structure
    FarFree *panel

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    

.proc panel_draw: far
        
    ProcPrefix 
    ProcFar                                                 ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters 
    DeclareLocalL l_p_func, 9                               ; This is a uint32_t local variable       
    DeclareLocal l_DP, 8                                    ; This is a uint16_t local variable        
    DeclareLocalS l_bounds, 0, .sizeof(wi_bounds)/2         ; This is a wi_bounds local variable
    SetLocalCount 11                                        ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam panel, 0                                   ; This is a uint32_t parameter

    ; Setup stack frame
    SetupStackFrame

    ; Store l_DP = DP
    tdc
    sta l_DP

    ; l_p_func = panel->get_bounds;
    ldy #wi_panel::getbounds
    lda [panel], y
    sta l_p_func
    ldy #wi_panel::getbounds+2
    lda [panel], y
    sta l_p_func+2
    
    ; Get the bounds.
    clc             
    SetParamL *panel        ; Pointer to panel
    lda l_DP
    adc #l_bounds
    pha                     ; Pointer to real address of local variable
    jsl_ptr l_p_func
    pla   
    pla
    pla 

    ; Do the draw here

    ; Exit the procedure
    FreeLocals
    ProcSuffix

    ; Return from "near" procedure with "rts"; from "far" procedure with "
    rtl
.endproc

; Pass a pointer to wi_bounds instead of individual parameters...
.proc panel_get_bounds: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters 
    DeclareLocal l_DP, 11                                   ; This is a uint16_t local variable           
    DeclareLocalL l_p_func, 9                               ; This is a uint32_t local variable
    DeclareLocalL l_p_parent, 8                             ; This is a uint32_t local variable
    DeclareLocalS l_parent_bounds, 0, .sizeof(wi_bounds)/2  ; This is a wi_bounds local variable    
    SetLocalCount 12                                        ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters        
    DeclareParam bounds, 0                                  ; This is a uint16_t parameter    
    DeclareParam panel, 1                                   ; This is a uint32_t parameter    

    ; Setup stack frame
    SetupStackFrame    

    ; Set data bank to $00 and use short addressing 
    mode8
    phb
    lda #$00
    pha
    plb
    mode16

    ; if (panel->wi_panel::parent != NULL) goto l1
    ldy #wi_panel::parent
    lda [panel], y
    beq l1

        ;bounds->xpos = panel->xpos
        ldy #wi_panel::xpos
        lda [panel], y        
        sta (bounds), y

        ;bounds->ypos = panel->ypos
        ldy #wi_panel::ypos
        lda [panel], y
        sta (bounds), y

        ;bounds->w = panel->w
        ldy #wi_panel::w
        lda [panel], y
        sta (bounds), y
        
        ;bounds->h = panel->h
        ldy #wi_panel::h
        lda [panel], y
        sta (bounds), y

        brl l2

    ; Get the parent's bounds
    l1: ; else

        ; l_p_parent = (uint32_t)panel->wi_panel::parent;
        ldy #wi_panel::parent
        lda [panel], y
        sta l_p_parent
        ldy #wi_panel::parent+2
        lda [panel], y
        sta l_p_parent+2
        
        ; l_p_func = panel->wi_panel->get_bounds;
        ldy #wi_panel::getbounds
        lda [l_p_parent], y
        sta l_p_func
        ldy #wi_panel::getbounds+2
        lda [l_p_parent], y
        sta l_p_func+2

        ; Store l_DP = DP
        tdc
        sta l_DP
        
        ; Get parent's bounds into l_parent_bounds                
        SetParamL *l_p_parent       ; Pointer to parent panel
        lda l_DP
        adc #l_parent_bounds    
        pha                         ; Pointer to real address of local variable
        jsl_ptr l_p_func
        pla   
        pla
        pla 

        ;bounds->xpos = l_parent_bounds->xpos + panel->xpos;
        ldy #wi_bounds::xpos
        lda (l_parent_bounds), y        
        clc
        ldy #wi_panel::xpos
        adc [panel], y
        ldy #wi_bounds::xpos
        sta [bounds], y

        ;bounds->ypos = l_parent_bounds->ypos + panel->ypos;
        ldy #wi_bounds::ypos
        lda (l_parent_bounds), y
        clc
        ldy #wi_panel::ypos
        adc [panel], y
        ldy #wi_bounds::ypos
        sta (bounds), y        
        
        ; if l_parent_bounds.h < panel->h goto l12
        ldy #wi_bounds::h
        lda (l_parent_bounds), y
        ldy #wi_panel::h
        cmp [panel], y
        bcc l12

            ;bounds->h = panel->h;
            ldy #wi_panel::h
            lda [panel], y
            ldy #wi_bounds::h
            sta (bounds), y
            
            brl l22

        l12:
            
            ;bounds->h = l_parent_bounds.h;
            ldy #wi_bounds::h
            lda (l_parent_bounds), y
            sta (bounds), y

        l22:

        ; if l_parent_bounds.w < panel->w goto l13
        ldy #wi_bounds::w
        lda (l_parent_bounds), y
        ldy #wi_panel::w
        cmp [panel], y
        bcc l13

            ;bounds->w = panel->w;
            ldy #wi_panel::w
            lda [panel], y
            ldy #wi_bounds::w
            sta (bounds), y
            
            brl l23

        l13:
            
            ;bounds->w = l_parent_bounds.w;
            ldy #wi_bounds::w
            lda (l_parent_bounds), y
            sta (bounds), y

        l23:
    
    l2: ; endif

    ; Restore the data bank
    plb
    
    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc
