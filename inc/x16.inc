.enum x16_debug
    debug_print = $009FBB
.endenum

.enum vera_dcsel
    VERA_DCSEL0                 = 0 << 1
    VERA_DCSEL1                 = 1 << 1
    VERA_DCSEL2                 = 2 << 1
    VERA_DCSEL3                 = 3 << 1
    VERA_DCSEL4                 = 4 << 1
    VERA_DCSEL5                 = 5 << 1
    VERA_DCSEL6                 = 6 << 1
    VERA_DCSEL63                = 63 << 1
.endenum

.enum vera_step
    VERA_DEC_0                  = ((0 << 1) | 1) << 3
    VERA_DEC_1                  = ((1 << 1) | 1) << 3
    VERA_DEC_2                  = ((2 << 1) | 1) << 3
    VERA_DEC_4                  = ((3 << 1) | 1) << 3
    VERA_DEC_8                  = ((4 << 1) | 1) << 3
    VERA_DEC_16                 = ((5 << 1) | 1) << 3
    VERA_DEC_32                 = ((6 << 1) | 1) << 3
    VERA_DEC_64                 = ((7 << 1) | 1) << 3
    VERA_DEC_128                = ((8 << 1) | 1) << 3
    VERA_DEC_256                = ((9 << 1) | 1) << 3
    VERA_DEC_512                = ((10 << 1) | 1) << 3
    VERA_DEC_40                 = ((11 << 1) | 1) << 3
    VERA_DEC_80                 = ((12 << 1) | 1) << 3
    VERA_DEC_160                = ((13 << 1) | 1) << 3
    VERA_DEC_320                = ((14 << 1) | 1) << 3
    VERA_DEC_640                = ((15 << 1) | 1) << 3
    VERA_INC_0                  = ((0 << 1) | 0) << 3
    VERA_INC_1                  = ((1 << 1) | 0) << 3
    VERA_INC_2                  = ((2 << 1) | 0) << 3
    VERA_INC_4                  = ((3 << 1) | 0) << 3
    VERA_INC_8                  = ((4 << 1) | 0) << 3
    VERA_INC_16                 = ((5 << 1) | 0) << 3
    VERA_INC_32                 = ((6 << 1) | 0) << 3
    VERA_INC_64                 = ((7 << 1) | 0) << 3
    VERA_INC_128                = ((8 << 1) | 0) << 3
    VERA_INC_256                = ((9 << 1) | 0) << 3
    VERA_INC_512                = ((10 << 1) | 0) << 3
    VERA_INC_40                 = ((11 << 1) | 0) << 3
    VERA_INC_80                 = ((12 << 1) | 0) << 3
    VERA_INC_160                = ((13 << 1) | 0) << 3
    VERA_INC_320                = ((14 << 1) | 0) << 3
    VERA_INC_640                = ((15 << 1) | 0) << 3
.endenum

.struct vera
    address             .word
    address_hi          .byte
    data0               .byte
    data1               .byte
    data2               .byte
    control             .byte    
    irq_enable          .byte
    irq_flags           .byte
    irq_raster          .byte
    .union 
        ; dc0
        .struct 
            video       .byte
            hscale      .byte
            vscale      .byte
            border      .byte 
        .endstruct
        ;dc1
        .struct 
            hstart      .byte
            hstop       .byte
            vstart      .byte
            vstop       .byte
        .endstruct
        ;dc2
        .struct
            fxctrl      .byte
            fxtilebase  .byte
            fxmapbase   .byte
            fxmult      .byte
        .endstruct
        ;dc3
        .struct
            fxxincrl    .byte
            fxxincrh    .byte   
            fxyincrl    .byte
            fxyincrh    .byte
        .endstruct
        ;dc4
        .struct
            fxxpossl    .byte
            fxyposs     .byte
            fxpolyfilll .byte
            fxpolyfillh .byte
        .endstruct
        ;dc5
        .struct
            sprctl      .byte
            sprbase     .byte
            sprlink     .byte
            sprmult     .byte
        .endstruct
        ;dc6
        .struct
            fxcachel    .byte
            fxcachem    .byte
            fxcacheh    .byte
            fxcacheu    .byte
        .endstruct
    .endunion 
    l1_config           .byte
    l1_mapbase          .byte
    l1_tilebase         .byte
    l1_hscroll          .word
    l1_vscroll          .word  
    l2_config           .byte
    l2_mapbase          .byte
    l2_tilebase         .byte
    l2_hscroll          .word
    l2_vscroll          .word  
    audio_control       .byte
    audio_rate          .byte
    audio_data0         .byte
    audio_data1         .byte
    spi_data            .byte
    spi_control         .byte
.endstruct

VERA_BASE = $009F20


