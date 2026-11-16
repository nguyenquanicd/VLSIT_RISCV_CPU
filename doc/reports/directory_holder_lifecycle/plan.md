# A-04 plan / Kế hoạch A-04

Authorized by the A-04 request; retain approved DEC-013 conservative-directory architecture. / Theo yêu cầu A-04 và kiến trúc directory bảo thủ DEC-013 đã duyệt.

1. CCU fabric accepts a correctly tagged/phased error-free PREPARE-I as proof that a conservatively recorded holder no longer has a resident line. It satisfies the no-dirty-data obligation without claiming an AXI transfer. Actual M still requires successful writeback. Capture I through ABORT/COMMIT; remove absent holders from the candidate mask, committing only after all COMMIT ACKs. Normalize an empty committed holder mask to I. Keep all ACK eligibility checks.
2. Native cache probe engine ACKs COMMIT for an absent line with I for every target; it never creates a new S/E line or writes a missing tag. PREPARE errors still ABORT; tag/line/target mismatches remain errors.
3. Test real CPUs: clean and dirty L1 replacements followed by peer reads/upgrades; failed refill followed by a peer retry and maintenance. Check actual absent-I probes and committed directory masks, not injected CPU completion. Add focused protocol negatives and empty-mask maintenance tests. Replay AMO/LR-SC, CBO/FENCE.I, A-03 retention and TOP lint 2/4 harts.

No DROP channel is added: stale-positive holders may remain until a subsequent locked probe; successful transactions prune them. Aborted transactions may conservatively retain old bits. No false-negative holders are allowed. An A-03 failed dirty eviction remains busy/M until reset and cannot use the absent-I shortcut. / Không thêm kênh DROP; holder dư chỉ được prune khi probe/COMMIT thành công. ABORT được giữ metadata bảo thủ; không cho phép bỏ sót holder thật.
