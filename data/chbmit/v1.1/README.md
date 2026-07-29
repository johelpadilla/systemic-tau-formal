# P1-EEG v1.1.0 artifacts

**Protocol freeze:** [`docs/P1_EEG_CHBMIT_v1.1.md`](../../../docs/P1_EEG_CHBMIT_v1.1.md)  
**Status:** design freeze only — **not scored**.

Do **not** copy or overwrite v1.0.0 files from `data/chbmit/` (parent).  
Do **not** use `../last_p1_eeg_score.json` or `../last_c1_eeg.json` to choose parameters.

## Expected files (after implementation)

| File | When |
|------|------|
| `precondition_diagnostic.json` | after `precondition` CLI; **required before lock** |
| `endpoints.json` | pre-registered clinical \(t_{\mathrm{obs}}\) + frozen_params 1.1.0 |
| `protocol_lock.json` | SHA lock including diagnostic hash |
| `last_p1_eeg_score.json` | after one locked score |
| `last_c1_eeg.json` | after C1 panel |

## Hard rule

Precondition gates G1–G4 (interictal occupancy) must pass before lock.  
If they fail → no score under v1.1; open design v1.2.
