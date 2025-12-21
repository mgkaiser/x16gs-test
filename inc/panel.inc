.if !.xmatch(current_file, "panel.s")
    .import panel_create : far
    .import panel_init : far
    .import panel_done : far
    .import panel_destroy : far
    .import panel_draw : far
    .import panel_get_bounds : far
.endif

.struct wi_bounds
    xpos        .word   ; X position of the panel
    ypos        .word   ; Y position of the panel
    w           .word   ; Width of the panel
    h           .word   ; Height of the panel    
.endstruct

.macro wi_panel_contents
    ; Parent
    parent      .dword  ; The panel which is the parent of this panel

    ; Panel specific data
    wnd_id      .word   ; The window ID of this panel
    xpos        .word   ; X position of the panel
    ypos        .word   ; Y position of the panel
    w           .word   ; Width of the panel
    h           .word   ; Height of the panel    
    character   .word   ; Character in the low byte, color in the high byte for the panel
    children    .dword  ; Linked list of child panels
    application .dword  ; Pointer to the application this panel belongs to

    ; Panel specific function pointers - All virtual functions have a base_ version which is the default implementation
    ; and a normal version which is the current implementation (which may be overridden)
    base_draw       .dword  ; Function pointer to the draw function for this panel
    draw            .dword  ; Function pointer to the draw function for this panel
    base_insert     .dword  ; Function pointer to the insert function for this panel
    insert          .dword  ; Function pointer to the insert function for this panel
    base_getbounds  .dword  ; Function pointer to the getbounds function for this panel
    getbounds       .dword  ; Function pointer to the getbounds function for this panel
    base_doevents   .dword  ; Function pointer to the doevents function for this panel
    doevents        .dword  ; Function pointer to the doevents function for this panel
    base_mousemove  .dword  ; Function pointer to the mousemove function for this panel
    mousemove       .dword  ; Function pointer to the mousemove function for this panel
    base_mouseup    .dword  ; Function pointer to the mouseup function for this panel
    mouseup         .dword  ; Function pointer to the mouseup function for this panel
    base_mousedown  .dword  ; Function pointer to the mousedown function for this panel
    mousedown       .dword  ; Function pointer to the mousedown function for this panel
    base_gotfocus   .dword  ; Function pointer to the gotfocus function for this panel
    gotfocus        .dword  ; Function pointer to the gotfocus function for this panel
    base_lostfocus  .dword  ; Function pointer to the lostfocus function for this panel
    lostfocus       .dword  ; Function pointer to the lostfocus function for this panel
    base_clicked    .dword  ; Function pointer to the clicked function for this panel
    clicked         .dword  ; Function pointer to the clicked function for this panel
.endmacro

.struct wi_panel

    ; Inherited from ll_node
    ll_node_contents    

    ; Panel specific contents
    wi_panel_contents
    
.endstruct

; Panel_Create
.macro Panel_Create xpos, ypos, w, h, character, retval
    .out "Panel_Create"
    SetRetValL    
    SetParam xpos
    SetParam ypos
    SetParam w
    SetParam h
    SetParam character
    jsl panel_create
    FreeParams 5
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta retval
    stx retval + 2
.endmacro

; Panel_Init
.macro Panel_Init panel, xpos, ypos, w, h, character, retval
    .out "Panel_Create"    
    SetParamL panel
    SetParam xpos
    SetParam ypos
    SetParam w
    SetParam h
    SetParam character
    jsl panel_init
    FreeParams 7        
.endmacro

; Panel_Done
.macro Panel_Done panel
    .out "Panel_Done"    
    SetParamL panel
    jsl panel_done
    FreeParams 2
.endmacro   

; Panel_Destroy
.macro Panel_Destroy panel
    .out "Panel_Destroy"    
    SetParamL panel
    jsl panel_destroy
    FreeParams 2
.endmacro

; Panel_Draw
.macro Panel_Draw panel
    .out "Panel_Draw"
    SetParamL panel
    jsl panel_draw
    FreeParams 2
.endmacro

.macro Panel_Draw_Ptr panel, bounds_ptr, func_ptr
    .out "Panel_Draw_Full"
    SetParamL panel
    SetParamL bounds_ptr
    jsl_ptr func_ptr
    FreeParams 3    
.endmacro

; Panel_Get_Bounds
.macro Panel_Get_Bounds panel, bounds_ptr
    .out "Panel_Get_Bounds"
    SetParamL panel
    SetParamL bounds_ptr
    jsl panel_get_bounds
    FreeParams 3
.endmacro

.macro Panel_Get_Bounds_Ptr panel, bounds_ptr, func_ptr
    .out "Panel_Get_Bounds"
    SetParamL panel
    SetParamL bounds_ptr
    jsl_ptr func_ptr
    FreeParams 3
.endmacro



