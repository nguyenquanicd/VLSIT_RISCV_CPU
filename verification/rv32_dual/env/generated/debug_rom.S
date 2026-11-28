# AI-GENERATED debug ROM (Q-G0-07 A); base 0x800 = RV32 HDS 8.2 HaltAddress
        j    halt_entry                 # 0x800 HaltAddress
        nop                             # 0x804
exc_entry:                              # 0x808 ExceptionAddress
        csrw dscratch0, t0
        csrw dscratch1, t1
        csrr t0, mhartid
        slli t0, t0, 2
        lui  t1, 0x10000
        add  t1, t1, t0                 # t1 = 0x10000000 + 4*hart
        li   t0, 1
        sw   t0, 0x500(t1)              # DBG_EXC[hart] = 1
exc_park:
        j    exc_park
halt_entry:
        csrw dscratch0, t0
        csrw dscratch1, t1
        csrr t0, mhartid
        slli t0, t0, 2
        lui  t1, 0x10000
        add  t1, t1, t0                 # t1 = 0x10000000 + 4*hart
        li   t0, 1
        sw   t0, 0x400(t1)              # HALTED[hart] = 1
wait_resume:
        lw   t0, 0x300(t1)              # RESUME[hart]
        beqz t0, wait_resume
        sw   zero, 0x300(t1)            # consume the resume request
        sw   zero, 0x400(t1)            # HALTED[hart] = 0
        csrr t0, dscratch0
        csrr t1, dscratch1
        dret
