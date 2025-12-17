.p816
.A16
.I16

.include "mac.inc"
.include "malloc.inc"
.include "linkedlist_struct.inc"
.include "panel_struct.inc"

; Define exports for all public functions in this module
.export panel_create
.export panel_init
;.export panel_done
;.export panel_destroy
    
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
    DeclareParam panel, 5                                   ; This is a uint32_t parameter
    DeclareParam r_retVal, 6                                ; uint32_t 
    
    ; Setup stack frame
    SetupStackFrame     

    ; Do the work of the procedure here
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

    ; Setup stack frame
    SetupStackFrame     

    ; Do the work of the procedure here

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc  