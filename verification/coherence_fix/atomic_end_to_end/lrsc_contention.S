# Program overlay for the shared-counter phase; remaining program is unchanged.
# x11 = shared X, x20 = remaining successful increments.
# The old-value checkpoint is reached only after SC returns zero.
0x80000050: j 0x800005e0
0x80000058: addi x14,x14,0  # architectural old-value checkpoint
0x8000005c: addi x20,x20,-1
0x80000060: bnez x20,0x80000600
0x800005e0: addi x20,x0,8
0x800005e4: j 0x80000600
0x80000600: lr.d.aqrl x14,(x11)
0x80000604: addi x13,x14,1
0x80000608: sc.d.aqrl x16,x13,(x11)
0x8000060c: bnez x16,0x80000600
0x80000610: j 0x80000058
