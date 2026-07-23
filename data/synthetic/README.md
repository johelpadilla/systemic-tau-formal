# Synthetic data

**Label:** `[OPERACIONAL]` lab series for CI and demos — not field claims.

## Committed fixtures

| File | Construction | Expected ordinal structure |
|------|--------------|----------------------------|
| `sync_seasonal.csv` | Shared seasonal driver + light noise | High τₛ / stable band |
| `anti_sync.csv` | Alternating ±sin drivers | Suppressed / negative τₛ |
| `independent_noise.csv` | IID Gaussian columns | Mostly chaotic band \|τ\| < 0.41 |
| `regime_switch.csv` | Sync then noise at `t_switch` | Early stable → later chaos-like |
| `regime_switch_meta.json` | Switch index metadata | — |

Regenerate (deterministic seeds):

```bash
cd python && python scripts/export_fixtures.py
```

Generators: `python/core/synthetic.py`.
