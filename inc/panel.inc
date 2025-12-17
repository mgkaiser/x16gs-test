.import panel_create : far
.import panel_init : far
;.import panel_done : far
;.import panel_destroy : far

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
; Panel_Destroy
