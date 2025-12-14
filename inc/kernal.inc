.import registers: far
.import kernal_fn: far
.import call_kernal: far
.import bsout_far: far
.import setlfs_far: far

; Wrapper to return to real mode, call a Kernal routine, and go back to native mode 
.macro CallKernal address    
    lda #address    
    sta registers + registers::kernal_call
    jsl call_kernal                                
.endmacro



