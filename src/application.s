.p816
.A16
.I16

.scope
.define current_file "application.s"

.include "mac.inc"
.include "kernal.inc"
.include "malloc.inc"
.include "linkedlist.inc"
.include "application.inc"

; Define exports for all public functions in this module
.export application_create
.export application_init
.export application_done
.export application_destroy
.export application_run
;.export application_insert
;.export application_postmessage
;.export application_bringfront
;.export application_invaidate

; Private methods
;application_pollmouse
;application_pollkb

.segment "OVERLAY1"

.proc application_create: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        
    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam character, 0                               ; This is a uint16_t parameter    
    DeclareParam r_retVal, 1                                ; uint32_t 
    
    ; Setup stack frame
    SetupStackFrame     

    ; Create and init the panel structure
    FarMalloc #.sizeof(wi_application), r_retVal  
    Application_Init *r_retVal, *character                            
    
    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc  

.proc application_init: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 2                                         ; Number of (16 bit) local variables declared                              

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam character, 0                               ; This is a uint16_t parameter    
    DeclareParam application, 1                             ; This is a uint32_t parameter

    ; Setup stack frame
    SetupStackFrame 

    ; Clear the entire application structure to $00
    ClearStruct application, wi_application    

    ; Setup the desktop

    ; Setup the properties
    ldy #wi_application::application_done
    lda #$0001
    sta [application],y

    ; Setup the methods
    ldy #wi_application::run
    lda #.loword(application_run)
    sta [application],y
    ldy #wi_application::run+2
    lda #.hiword(application_run)
    sta [application],y
    

    ; Initialize the event queue
    FarMalloc #.sizeof(linkedlist), l_temp
    LL_Init *l_temp
    VarToStructElementL l_temp, application, wi_application::eventqueue

    ; Turn on the mouse cursor    
    jsl mouse_config

    ; Push the first draw event to desktop
        
    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc  

.proc application_done: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        
    DeclareLocalL l_temp, 0                                 ; This is a uint32_t local variable
    SetLocalCount 2                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters    
    DeclareParam application, 0                             ; This is a uint32_t parameter

    ; Setup stack frame
    SetupStackFrame    

    ; Free the desktop structure    
    StructElementToVarL application, wi_application::desktop, l_temp        ; Get pointer to desktop
    FarFree *l_temp                                                         ;farfree(application->desktop);
    
    ; Free the event queue
    StructElementToVarL application, wi_application::eventqueue, l_temp     ; Get pointer to event queue    
    LL_Clear *l_temp                                                        ;ll_clear(application->eventqueue);
    FarFree *l_temp                                                         ;farfree(application->eventqueue);    
    
    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    

.proc application_destroy: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        

    SetLocalCount 0                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters   
    DeclareParam application, 0                             ; This is a uint32_t parameter

    ; Setup stack frame
    SetupStackFrame     

    ; Clean up any children of the panel here (if any)
    Application_Done *application    
    
    ; Free the panel structure
    FarFree *application

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc    

.proc application_run: far
        
    ProcPrefix 
    ProcFar                                                ; This is "near" if called with "jsr" and "far" if called with "jsl"     
    
    ; Create local variable - Number in descending order, skip 2 for long parameters        
    DeclareLocalL l_event, 2                                ; This is a uint32_t local variable
    DeclareLocalL l_eventqueue, 0                           ; This is a uint32_t local variable
    SetLocalCount 4                                         ; Number of (16 bit) local variables declared                              

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters        
    DeclareParam application, 0                             ; This is a uint32_t parameter

    ; Setup stack frame
    SetupStackFrame 

    ; l_eventqueue = application->eventqueue
    StructElementToVarL application, wi_application::eventqueue, l_eventqueue

    ; Main event loop
application_loop_top:

    ; Check if application->application_done is set
    ldy #wi_application::application_done    
    lda [application],y
    beql application_loop_exit

    ; Poll the mouse

    ; Poll the keyboard
    
    ; Pop a message from the queue
    LL_GetHead *l_eventqueue, l_event

    ; if l_event == NULL then goto application_loop_top
    lda l_event
    ora l_event + 2
    beq application_loop_top

        ; Do events

        ; Free the event
        ;Event_Destroy *l_event
        LL_Remove *l_eventqueue, *l_event

    brl application_loop_top

application_loop_exit:

    ; Exit the procedure
    FreeLocals
    ProcSuffix  

    ; Return from "near" procedure with "rts"; from "far" procedure with "rtl"
    rtl
.endproc  


.endscope
