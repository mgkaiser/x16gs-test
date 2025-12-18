.p816
.A16
.I16

.scope
.define current_file "file.s"

.include "mac.inc"
.include "kernal.inc"

.segment "MAIN"

; Define exports for all public functions in this module
.export load

.proc load: far

    ProcPrefix
    ProcFar

    ; Create local variable - Number in descending order, skip 2 for long parameters        
    DeclareLocal l_p_temp, 0                                ; This is a uint16_t local variable    
    SetLocalCount 1                                         ; Number of (16 bit) local variables declared                   

    ; Declare parameters - reverse order of the called parameters, skip 2 for long parameters
    DeclareParam address, 0                                ; uint32_t size
    DeclareParam filename, 2                               ; uint32_t size
    DeclareParam snd, 4                                    ; uint16_t ptr
    DeclareParam dev, 5                                    ; uint16_t ptr
    DeclareParam lfn, 6                                    ; uint16_t ptr    

    ; Setup stack frame
    SetupStackFrame    

    ; Create the file Handle    
    lda lfn
    ldx dev
    ldy snd    
    jsl setlfs_far    

    ; If HIWORD of FileName Pointer isn't $0000 copy it to bank $00  
    lda filename+2
    beq filename_location_else

        ; Copy the filename to buffer in bank $00        
        ldy #$001f
        filename_location_loop:
            lda [filename],y
            sta kernal_fn,y
            dey
            bne filename_location_loop
        
        ; Use the buffer in bank $00 for filename
        lda #.LOWORD(kernal_fn)
        sta l_p_temp

        bra filename_location_endif
    ; else just copy the low word of the pointer if near
filename_location_else:    
        lda filename
        sta l_p_temp        
    ; endif 
filename_location_endif:

    ; Get the length of the filename
    ldy #$0000    
load_count_top:
        lda (l_p_temp),y
        beq load_count_exit
        iny
        bra load_count_top
load_count_exit: 

    ; Set the filename
    mode8    
    tya    
    ldx l_p_temp    
    ldy l_p_temp+1    
    mode16
    jsl setnam_far    

    ; Open the file 
    jsl open_far    

    ; Load the file here
    lda address
    sta a:R0
    lda address+2
    sta a:R1    
    HBLoad

    ; Clear the channel
    jsl clrchn_far

    ; Close the file handle
    lda lfn    
    jsl close_far    

    FreeLocals  
    ProcSuffix

    rtl
.endproc

.endscope