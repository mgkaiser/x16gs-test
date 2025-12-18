.import panel_create : far
.import panel_init : far
.import panel_done : far
.import panel_destroy : far
.import panel_draw : far
.import panel_get_bounds : far

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

.macro Panel_Get_Bounds panel, bounds_ptr, func_ptr
    .out "Panel_Get_Bounds"
    SetParamL panel
    SetParamL bounds_ptr
    jsl_ptr func_ptr
    FreeParams 3
.endmacro



