; Only import these if you are not in the linkedlist.s source file itself
.if !.xmatch(current_file, "application.s")
    .import application_create : far
    .import application_init : far
    .import application_done : far
    .import application_destroy : far
    ;.import application_run : far
    ;.import application_insert : far
    ;.import application_postmessage : far
    ;.import application_bringfront : far    
    ;.import application_invaidate : far 
.endif

.macro wi_application_contents
    desktop                 .dword
    eventqueue              .dword
    last_mouse_button       .byte
    last_mouse_x            .word 
    last_mouse_y            .word
    run                     .dword  
    insert                  .dword
    postmessage             .dword
    bringfront              .dword
    invaidate               .dword
.endmacro

.struct wi_application
    wi_application_contents
.endstruct

; Application_Create
.macro Application_Create character, retval   
    SetRetValL        
    SetParam character
    jsl application_create
    FreeParams 1
    GetRetValL          ; RetVal lands in A-LoWord, X-HiWord
    sta retval
    stx retval + 2
.endmacro

; application_Init
.macro Application_Init application, character    
    SetParamL application    
    SetParam character
    jsl application_init
    FreeParams 3        
.endmacro

; application_Done
.macro Application_Done application    
    SetParamL application
    jsl application_done
    FreeParams 2
.endmacro   

; application_Destroy
.macro Application_Destroy application    
    SetParamL application
    jsl application_destroy
    FreeParams 2
.endmacro