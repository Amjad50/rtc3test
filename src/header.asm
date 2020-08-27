Crash:
	ld b, b
	xor a
	ldh [rIE], a
.loop
	halt
	nop
	jr .loop

WaitVBlank:
	push af
	ld a, 1
	ldh [rIE], a
	xor a
	jr WaitVBlankLoop

Print:
	ld a, [hli]
	cp "@"
	ret z
	ld [de], a
	inc de
	jr Print

ClearScreen:
	; turns off the LCD as well
	rst WaitVBlank
	xor a
	ldh [rLCDC], a
	dec a
	jr LoadScreenData

JumpHL:
	jp hl

EnableScreen:
	xor a
	ldh [rIF], a
	ld a, $99
	ldh [rLCDC], a
	ret

NextLine:
	push af
	ld a, e
	or $1f
	ld e, a
	inc de
	pop af
	ret

	ds $10

	assert @ == $40
VBlank:
	; clear zero flag
	rla
	rra
	reti

LoadScreenData:
	push hl
	ld hl, $9c00
.loop
	ld [hli], a
	bit 5, h
	jr z, .loop
	pop hl
	ret

	ds 2

	assert @ == $50
Timer:
	scf
	reti

WaitVBlankLoop:
	ldh [rIF], a
.loop
	halt
	nop
	jr z, .loop
	ldh [rIE], a
	pop af
	ret

LoadFont:
	; in: de: address, b: palette mode
	ld hl, Font
	ld c, 0
	call .load ;$100 twice = $40 * 8
.load
	rept 2
		rrc b
		sbc a
		and [hl]
		ld [de], a
		inc de
	endr
	inc hl
	dec c
	jr nz, .load
	ret

StringLength:
	push hl
.loop
	ld a, [hli]
	inc a
	jr nz, .loop
	ld a, l
	dec a
	pop hl
	sub l
	ret

PrintResult:
	; a: color, hl: string, de: destination (end of line)
	push bc
	ld b, a
	call StringLength
	; if the subtraction overflows, the string is too long anyway
	cpl
	inc a
	add a, e
	ld e, a
	ld a, [hli]
.loop
	or b
	ld [de], a
	inc de
	ld a, [hli]
	cp "@"
	jr nz, .loop
	pop bc
	ret

	ds 11

Init:
	ld a, 0
	ldh [rIF], a
	ldh [rIE], a
	ei
	rst WaitVBlank
	ldh [rLCDC], a
	ldh [rSCX], a
	ldh [rSCY], a
	jr nz, .no_color
	ld a, $80
	ldh [rBCPS], a
	rlca
	ldh [rVBK], a
	xor a
	call LoadScreenData
	ldh [rVBK], a
	; 0: white
	dec a
	ldh [rBCPD], a
	ldh [rBCPD], a
	; 1: green (80%)
	ld a, LOW(25 << 5)
	ldh [rBCPD], a
	ld a, HIGH(25 << 5)
	ldh [rBCPD], a
	; 2: red
	ld a, 31
	ldh [rBCPD], a
	xor a
	ldh [rBCPD], a
	; 3: black
	ldh [rBCPD], a
	ldh [rBCPD], a
.no_color
	ld de, $8000
	ld b, %11111111
	call LoadFont
	ld b, %01010101
	call LoadFont
	ld b, %10101010
	call LoadFont
	ld c, FontExtra.end - FontExtra
	ld h, d
	ld l, e
	ld de, FontExtra
.extra_font_loop
	ld a, [de]
	inc de
	ld [hli], a
	ld [hli], a
	dec c
	jr nz, .extra_font_loop
	xor a
.clear_tiles_loop
	ld [hli], a
	bit 4, h
	jr z, .clear_tiles_loop
	dec a
	call LoadScreenData
	rst EnableScreen
	jr MainMenu

	assert @ == $100
EntryPoint:
	cp $11
	jr Init
	ds $4c