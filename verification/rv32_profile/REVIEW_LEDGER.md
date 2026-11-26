# RV32 testbench - engineer review ledger (rule R-097)

Human review is pending for every row: the engineer opens the waveform, compares each checkpoint with the specification and fills Reviewer, Date, Findings and Disposition. The tool did not review any waveform.

| Testcase | Source | Run | Waveform | Waveform SHA-256 (prefix) | Checker outcome | Fault result | Reviewer | Date | Findings | Disposition |
|---|---|---|---|---|---|---|---|---|---|---|
| TC-01 | tests.py tc01 | runs/TC-01_rv32_2h_p0 | wave.vcd | f397354c426d1ffc | PASS 34/0 | fault 1 detected | pending | | | |
| TC-02 | tests.py tc02 | runs/TC-02_rv32_2h_p0 | wave.vcd | 111daae32555885c | PASS 78/0 | fault 6 detected | pending | | | |
| TC-03 | tests.py tc03 | runs/TC-03_rv32_2h_p0 | wave.vcd | 2997c045e9a76c8c | PASS 76/0 (after DEC-106) | fault 7 detected | pending | | Was FAIL 14/8 before DEC-106 (spec Section 14.5) | |
| TC-04 | tests.py tc04 | runs/TC-04_rv32_2h_p0 | wave.vcd | 5b9f044a34fec875 | PASS 12/0 | fault 4 detected | pending | | | |
| TC-05 | tests.py tc05 | runs/TC-05_rv32_2h_p0 | wave.vcd | 494931516246205b | PASS 9/0 | fault 3 detected | pending | | | |
| TC-06 | tests.py tc06 | runs/TC-06_rv32_2h_p0 | wave.vcd | 3d124d10d57d742e | PASS 17/0 | fault 8 detected | pending | | | |
| TC-07 | tests.py tc07 | runs/TC-07_rv32_2h_p0 | wave.vcd | 02f63ec29d91a59e | PASS 15/0 | fault 5 detected | pending | | | |
| TC-08 | tests.py tc08 | runs/TC-08_rv32_2h_p0 | wave.vcd | d1d24238439dde19 | PASS 18/0 | fault 9 detected | pending | | | |
| TC-09 | tests.py tc09 | runs/TC-09_rv32_2h_p0 | wave.vcd | 55f17ec8b819c2e4 | PASS 7/0 | fault 10 detected | pending | | | |
| TC-10 | tests.py tc10 | runs/TC-10_rv32_2h_p0 | wave.vcd | 13589b9b5321ae6c | PASS 6/0 | fault 2 and BOOT_HI=1 detected | pending | | | |
