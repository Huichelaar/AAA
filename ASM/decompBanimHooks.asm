.thumb
@ Hooked at 0x59A44 and 0x59B28.
@ Decompresses compressed battle anim palettes and
@ avoids decompressing uncompressed battle anim palettes.
@ Registers:
@   r0: Battle anim struct address.
@   r1: Address to store uncompressed palette address in.
@   r2: Either 0 or 1. Indicates which address to return to.
@       Also used when calling 0x8059970
@       and determining where to decompress palette to.
@   r3: Free.
@   r4: Default RAM location to decompress battle palette to.
@   r5: Personal paletteID. -1 if generic.
@   r8: Unit's faction.

.global BA2_loadPal
.type BA2_loadPal, %function
BA2_loadPal:
push  {r5-r7}
mov   r6, r1
mov   r7, r2
ldr   r1, [r0, #0x8]        @ Animation Bitfield.
ldr   r0, [r0, #0x1C]       @ Generic palette address.


@ Generic vs personal palette.
mov   r2, #0x1
neg   r2, r2
cmp   r5, r2
beq   generic
  ldr   r0, =0x8059BFC      @ Pointer to character palettes should be here.
  ldr   r0, [r0]
  lsl   r2, r5, #0x4
  add   r0, r2
  ldr   r0, [r0, #0xC]      @ Personal palette address.
generic:
mov   r5, r1

@ 16-col palette vs 32-col palette.
mov   r12, r4               @ 16-colour palette RAM address.
mov   r3, r8
lsl   r2, r3, #0x5          @ 16-colour palette offset.
ldr   r3, =BA2_AB_2PALETTES
ldrb  r3, [r3]
mov   r1, #0x1
lsl   r1, r3
tst   r5, r1
beq   smallpal
  ldr   r3, =BA2_2PALETTERAM
  ldr   r3, [r3]
  mov   r12, r3
  mov   r3, #0xA0
  lsl   r3, #0x1
  mul   r3, r7
  add   r12, r3             @ 32-colour RAM address.
  lsl   r2, #0x1            @ 32-colour palette offset.
smallpal:

@ Compressed vs uncompressed.
add   r3, r2, r0
str   r3, [r6]
ldr   r3, =BA2_AB_UNCOMPPALDATA
ldrb  r3, [r3]
mov   r1, #0x1
lsl   r1, r3
tst   r5, r1
bne   uncomp
  mov   r3, r12
  add   r3, r2
  str   r3, [r6]
  mov   r1, r12
  swi   #0x11               @ Decompress.
  
  @ Vanilla calls this. We'll call it for
  @ compressed 16-colour banims as well.
  ldr   r3, =BA2_AB_2PALETTES
  ldrb  r3, [r3]
  mov   r1, #0x1
  lsl   r1, r3
  tst   r5, r1
  bne   uncomp
    mov   r0, r4
    mov   r1, r7
    ldr   r2, =0x8059971      @ Seems to copy independence (fifth) palette
    bl    GOTO_R2             @ over ally palette under circumstances.


@ Set return address.
uncomp:
cmp   r7, #0x0
bne   L1
  ldr   r1, =0x8059A6F
  b     L2
L1:
  ldr   r1, =0x8059B51
L2:

ldr   r0, [r6]
pop   {r5-r7}
bx    r1
GOTO_R2:
bx    r2
