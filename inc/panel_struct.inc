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

    ; Panel specific function pointers
    draw        .dword  ; Function pointer to the draw function for this panel
    insert      .dword  ; Function pointer to the insert function for this panel
    getbounds   .dword  ; Function pointer to the getbounds function for this panel
    doevents    .dword  ; Function pointer to the doevents function for this panel
    mousemove   .dword  ; Function pointer to the mousemove function for this panel
    mouseup     .dword  ; Function pointer to the mouseup function for this panel
    mousedown   .dword  ; Function pointer to the mousedown function for this panel
    gotfocus    .dword  ; Function pointer to the gotfocus function for this panel
    lostfocus   .dword  ; Function pointer to the lostfocus function for this panel
    clicked     .dword  ; Function pointer to the clicked function for this panel
.endmacro

.struct wi_panel

    ; Inherited from ll_node
    ll_node_contents    

    ; Panel specific contents
    wi_panel_contents
    
.endstruct
