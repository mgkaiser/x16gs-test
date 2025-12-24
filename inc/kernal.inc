.if !.xmatch(current_file, "kernal.s")
    .import registers: far
    .import kernal_fn: far
    .import call_kernal: far
    .import bsout_far: far
    .import setlfs_far: far
    .import setnam_far: far
    .import open_far: far
    .import clrchn_far: far
    .import close_far: far
    .import mouse_config: far
    .import mouse_get: far
.endif

; Define a structure to hold CPU register states
.struct registers
    a_reg       .word 
    x_reg       .word
    y_reg       .word  
    flags       .word
    kernal_call .word
.endstruct

; Extended API calls
.enum extapi
    test                = $00
    stack_push          = $01
    stack_pop           = $02 
    enter_kernal_stack  = $03
    leave_kernal_stack  = $04
    xmacptr             = $05
    xmxiout             = $06
    hbload              = $07   
    get_last_far_bank   = $08    
.endenum

; Kernal bank definitions
RAMBANK     = $00
ROMBANK     = $01

; Psuedo-registers for 65816 mode
R0          = $0002
R1          = R0 + $0002
R2          = R1 + $0002    
R3          = R2 + $0002
R4          = R3 + $0002
R5          = R4 + $0002
R6          = R5 + $0002
R7          = R6 + $0002
R8          = R7 + $0002
R9          = R8 + $0002
R10         = R9 + $0002
R11         = R10 + $0002
R12         = R11 + $0002
R13         = R12 + $0002
R14         = R13 + $0002
R15         = R14 + $0002

; 65816 Kernal calls
EXTAPI16    = $FEA8
SETLFS      = $FFBA   ; Set Logical File parameters
SETNAM      = $FFBD   ; Set File Name
OPEN        = $FFC0   ; Open File
CLOSE       = $FFC3   ; Close File
CHKIN       = $FFC6   ; Open channel for input
CHKOUT      = $FFC9   ; Open channel for output
CLRCHN      = $FFCC   ; Restore IO to Keyboard/Screen
CHRIN       = $FFCF   ; Input character from channel (byte-by-byte)
BSOUT       = $FFD2   ; Write byte in A to default output.
STATUS      = $FFB7   ; Get I/O status (ST)

.macro XMacPtr
    ; Remember Direct Page    
    phd                                     

    ; Set Direct Page to $0000
    lda #$0000                              
    tcd    
    
    ; Call it
    lda #extapi::xmacptr    
    jsr EXTAPI16

    ; Back to our DP
    pld    
.endmacro

.macro HBLoad
    ; Remember Direct Page    
    phd                                     

    ; Set Direct Page to $0000
    lda #$0000                              
    tcd    
    
    ; Call it
    lda #extapi::hbload    
    ldx #$0000
    jsr EXTAPI16

    ; Back to our DP
    pld   

    ; Back into 16 bit mode
    mode16 
.endmacro

; Adjust the stack pointer to a new location
.macro StackPush stackAddr
    lda #extapi::stack_push
    ldx #stackAddr
    jsr EXTAPI16
.endmacro   

; Adjust the stack pointer back to previous location
.macro StackPop
    lda #extapi::stack_pop    
    jsr EXTAPI16
.endmacro  

; Switch to the Kernal stack
.macro EnterKernalStack
    lda #extapi::enter_kernal_stack
    jsr EXTAPI16
.endmacro  

; Switch back from the Kernal stack
.macro LeaveKernalStack
    lda #extapi::leave_kernal_stack
    jsr EXTAPI16
.endmacro  

