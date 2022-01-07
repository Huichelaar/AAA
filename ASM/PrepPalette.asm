@ Hooked at 0x59A44 and 0x59B28.
@ Decompresses compressed battle anim palettes and
@ avoids decompressing uncompressed battle anim palettes.
@ Registers:
@   r0: Battle anim struct address.
@   r1: Address to store uncompressed palette address in.
@   r2: Either 0 or 1. Indicates which address to return to.
@       Also used when calling 0x8059970.
@   r3: Free.
@   r4: RAM location to decompress battle palette to.
@   r5: Personal paletteID. -1 if generic.
@   r8: Unit's faction.
.thumb

push  {r6-r7}
mov   r6, r1
mov   r7, r2


ldr   r1, [r0, #0x8]
mov   r2, #0x1
and   r1, r2
lsr   r2, r5, #0x1F
lsl   r2, #0x1
orr   r2, r1
mov   r1, r4
cmp   r2, #0x0
beq   L1
  cmp   r2, #0x1
  beq   L2
    cmp   r2, #0x2
    beq   L3
      b     L4

@ Case 1, compressed character palette.
L1:
ldr   r0, =CharPalettes
lsl   r2, r5, #0x4
add   r0, r2
ldr   r0, [r0, #0xC]
swi   #0x11
mov   r0, r4
mov   r1, r7
ldr   r2, =0x8059971      @ Seems to copy independence (fifth) palette
bl    GOTO_R2             @ over ally palette under circumstances.
mov   r0, r8
lsl   r0, #0x5
add   r0, r4
b     L5

@ Case 2, uncompressed character palette.
L2:
ldr   r0, =CharPalettes
lsl   r2, r5, #0x4
add   r0, r2
ldr   r0, [r0, #0xC]
ldr   r1, =0x203E1DC      @ We'll mimic what 0x8059970 would do,
lsl   r2, r7, #0x1        @ but for uncompressed palettes.
ldsh  r1, [r1, r2]
cmp   r1, #0x0
bne   L6
  mov   r1, r8
  lsl   r1, #0x6
  add   r0, r1
  b     L5
L6:
  add   r0, #0x80         @ Independence (fifth) palette.
  b     L5

@ Case 3, compressed generic palette.
L3:
ldr   r0, [r0, #0x1C]
swi   #0x11
mov   r0, r8
lsl   r0, #0x5
add   r0, r4
b     L5

@ Case 4, uncompressed generic palette.
L4:
ldr   r0, [r0, #0x1C]
mov   r1, r8
lsl   r1, #0x6
add   r0, r1


@ Store pointer to un- or decompressed palette.
L5:
str   r0, [r6]

@ Set return address.
cmp   r7, #0x0
bne   L7
  ldr   r1, =0x8059A6F
  b     L8
L7:
  ldr   r1, =0x8059B51
L8:


pop   {r6-r7}
bx    r1
GOTO_R2:
bx    r2
