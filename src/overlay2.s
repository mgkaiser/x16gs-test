.p816
.A16
.I16

.include "mac.inc"

.export overlay2_signature

.segment "OVERLAY2"

overlay2_signature:     .byte "OVERLAY2", $00
