.import load: far

.macro Load lfn, dev, snd, filename, address
    .out "Load"        
    SetParam lfn    
    SetParam dev
    SetParam snd
    SetParamL filename    
    SetParamL address
    jsl load
    FreeParams 7
.endmacro