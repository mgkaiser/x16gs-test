; Inheritance: Panel -> Window

.macro wi_window_contents
    draw_border:    .word   ; Boolean: whether to draw a border around the window
    border_color:   .word   ; Color of the border         
.endmacro

.struct wi_window

    ; Inherited from ll_node
    ll_node_contents    

    ; Inherited from panel
    wi_panel_contents

    ; Window specific contents
    wi_window_contents
    
.endstruct
