# Verification plan

This folder contains the reviewable G0 plan for the RISC-V CPU cluster verification campaign. It is planning material only; no new simulation or coverage run has been performed.

- `verification_plan.md`: scope and proposed methodology.
- `requirements.txt`: active HDS and protocol-clause inventory for traceability.
- `vplan.csv`: planned tests, checkers, assertions and coverage obligations.
- `scope_matrix.json`: hart/width/parameter configurations and scenario dimensions.
- `active_rtl_source_scope.json`: hashed RTL filelist closure and hashed active RTL closure and minimum code-coverage denominator; third-party candidates require pinned-source diff audit.
- `coverage_contract.json`: metric thresholds, source denominator, exclusions and evidence rules.

The external ACE profile is deferred. Run the plan checker using the skill script linked in the project verification instructions. A passing plan check is not verification closure.
