.if !.xmatch(current_file, "desktop.s")
    
.endif

; Inheritance: Panel -> Desktop  

.macro wi_desktop_contents
    ; Currently Desktop only changes behaviour of panel - no extra data needed
.endmacro

.struct wi_desktop

    ; Inherited from ll_node
    ll_node_contents    

    ; Inherited from panel
    wi_panel_contents

    ; Desktop specific contents
    wi_desktop_contents 
    
.endstruct
