# Tool qualification notes (planning only)

- Verilator candidate: 5.053 development build (`v5.052-119-g014c9820d (mod)`). It supports line, expression and toggle coverage in this environment; it does not provide a distinct condition-coverage metric. The designer selected expression coverage instead. Exact executable hash and option behavior must be captured in qualification and run manifests before credited runs.
- Questa 10.4c was attempted earlier and failed at process startup with “Illegal System DLL Relocation”; it is not selected.
- Formal candidates: SymbiYosys 0.69, Yosys 0.69+154, and Z3 4.15.5 (64-bit). This is a version probe only. The front-end subset, assertions, memories and parameterized harness have not yet been proven compatible; no formal run was performed.
- Historical lint/simulation results are not current source-bound evidence.
