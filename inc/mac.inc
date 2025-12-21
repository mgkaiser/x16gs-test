
; Represent all segments for syntax checking purposes
.segment "ZP"
.segment "GOLDEN"
.segment "BANKS"
.segment "STACK"
.segment "MAIN"
.segment "LOADADDR"
.segment "STARTUP"
.segment "OVERLAY1"
.segment "OVERLAY2"

.macro SetRomBank bank
	mode8
    lda bank
    sta ROMBANK   
	mode16
.endmacro

.macro breakpoint
	;.byte $ea
	.byte $db
.endmacro

.macro ProcPrefix
	pha  
    phx
    phy
    phd	
.endmacro

.macro ProcSuffix
	pld
    ply
    plx
    pla
.endmacro

.macro SetupStackFrame		
	tsc
    tcd
.endmacro

.macro RestoreStackFrame
	pla
	tcd
.endmacro

.macro DeclareLocal lname, position
	lname = (position * 2) + 1	
	pha
.endmacro

.macro DeclareLocalL lname, position
	lname = (position * 2) + 1	
	pha
	pha
.endmacro

.macro DeclareLocalS lname, position, size
	lname = (position * 2) + 1	
	.repeat size
		pla
	.endrepeat
.endmacro

.macro DeclareLocalWithValue lname, value, position
	lname = (position * 2) + 1	
	lda value
	pha
.endmacro

.macro DeclareLocalPointerWithValue lname, value, position
	lname = (position * 2) + 1	
	per value	
.endmacro

.macro ProcNear
	farOffset=0
.endmacro

.macro ProcFar
	farOffset=1
.endmacro

.macro DeclareParam lname, position
	lname = (position * 2) + 11 + farOffset + (lcount * 2)
.endmacro

.macro FreeLocals
	; Make this smart and move SP rather than a mess of PLA when lcount > 2
	; 1 local 			= 4 cycles
	; 2 locals 			= 8 cycles
	; 3 or more locals 	= 9 cycles	
	;.if lcount > 2
	;	clc
	;	tsc
	;	adc #lcount*2
	;	tcs
	;.else
		.repeat lcount
			pla
		.endrepeat
	;.endif
.endmacro

.macro FreeParams count
	; Make this smart and move SP rather than a mess of PLA when count > x
	; 1 param 			= 4 cycles
	; 2 params 			= 8 cycles
	; 3 or more params 	= 9 cycles
	;.if count > 2
	;	clc
	;	tsc
	;	adc #count*2
	;	tcs
	;.else	
		.repeat count
			pla
		.endrepeat
	;.endif
.endmacro

.macro GetRetVal
	pla
.endmacro

.macro GetRetValL
	pla	
	plx	
.endmacro

.macro SetLocalCount count
	lcount = count
.endmacro

; # TODO: Document these
; Push Params, detect type
; PER = label				param is an offset, but pushes the resolved value onto the stack
; PEA = Absloute Value		param is the actual 16-bit value to push on the stack
; PEI = Pointer 			param is a DP address to be used as a pointer.  The value it points to is pushed on the stack
.macro SetParam arg	
	.if (.match (.left (1, {arg}), #))
		;.out "-- PEA --"
		.byte $f4
		.byte <(.right (.tcount ({arg})-1, {arg}))		
		.byte >(.right (.tcount ({arg})-1, {arg}))		
	.else
		.if (.match (.left (1, {arg}), *))
			;.out "-- PEI --"
			pei (.right (.tcount ({arg})-1, {arg}))
		.else			
			.if (.match (.left (2, {arg}), ^A))
				;.out "-- A --"
				pha
			.else
				.if (.match (.left (2, {arg}), ^D))
					;.out "-- D --"					
					phd
				.else
					.if (.match (.left (2, {arg}), ^Y))
						;.out "-- Y --"					
						phy
					.else
						.if (.match (.left (2, {arg}), ^X))
							;.out "-- X --"					
							phx
						.else
							.if (.match (.left (2, {arg}), ^^))
								;.out "-- ^^ --"
								.byte $a5	
								.byte <(.right (.tcount ({arg})-2, {arg}))
								pha
							.else																																								
								;.out "-- PER --"
								per arg														
							.endif												
						.endif
					.endif
				.endif
			.endif
		.endif
	.endif
.endmacro

.macro SetParamL arg
	;.out "-- f:PEA --"
	.if (.match (.left (1, {arg}), #))
		.byte $f4
		.byte ^(.right (.tcount ({arg})-1, {arg}))
		.byte $00
		.byte $f4
		.byte <(.right (.tcount ({arg})-1, {arg}))
		.byte >(.right (.tcount ({arg})-1, {arg}))
	.else
		.if (.match (.left (1, {arg}), *))
			;.out "-- PEI --"
			lda .right (.tcount ({arg})-1, {arg}) + 2
			pha
			lda .right (.tcount ({arg})-1, {arg})
			pha
		.else 
			.byte $f4
			.byte ^(.right (.tcount ({arg})-1, {arg}))
			.byte $00
			.byte $f4
			.byte <(.right (.tcount ({arg})-1, {arg}))		
			.byte >(.right (.tcount ({arg})-1, {arg}))				
		.endif
	.endif
.endmacro	

.macro SetRetVal
	;.out "-- SetRetVal --"
	pha
.endmacro

.macro SetRetValL
	;.out "-- SetRetValL --"
	pha
	pha
.endmacro

.macro rjsr arg		; Rework to push return addr, push jsr addr, rts		
	per @+-1
	brl arg
	@:
.endmacro

.macro rjsl arg		; Rework to push bank + return addr, push bank + jsl addr, rtl		
	phk
	per @+-1
	brl arg
	@:
.endmacro

.macro il_jsl arg		
	phk
	per @+-1
	jml [arg]
	@:
.endmacro

.macro il_jsr arg	
	.local continue	
	per @+-1
	jmp [arg]
	@:
.endmacro

.macro modea8x16
	.A8
	.I16
	sep #$20 
	rep #$10	
.endmacro

.macro mode16
	.A16
    .I16
    rep #$30 
.endmacro

.macro mode8
	.A8
    .I8
    sep #$30 
.endmacro

.macro modeEmulation
	sec             
    xce    
.endmacro

.macro modeNative
	clc
    xce    
.endmacro

.macro bge value
	bcs value
.endmacro

.macro blt value
	bcc value
.endmacro

.macro beql addr
    bne :+
    brl addr
:   
.endmacro

.macro bnel addr
    beq :+
    brl addr
:    
.endmacro

.macro jsl_ptr addr
	phk
	per @+-1
	jml [addr]	
	@:
.endmacro

.macro StructElementToVar struc, elem, variable    
    ; Load the element value
    ldy #elem
    lda (struc),y
    sta variable
    ldy #elem + 2
    lda (struc),y
    sta variable + 2
.endmacro

.macro StructElementToVarL struc, elem, variable    
    ; Load the element value	
    ldy #elem
    lda [struc],y
    sta variable
    ldy #elem + 2
    lda [struc],y
    sta variable + 2
.endmacro

