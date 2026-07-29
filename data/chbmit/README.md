# CHB-MIT P1-EEG data (local)

**Protocol:** [`docs/P1_EEG_CHBMIT.md`](../../docs/P1_EEG_CHBMIT.md) v1.0.0  
**Dataset DOI:** [10.13026/C2K01R](https://doi.org/10.13026/C2K01R)  
**License:** ODC-By-1.0 (PhysioNet)

## Layout

```text
data/chbmit/
  README.md                      # this file
  endpoints.example.json         # schema sample (no real scores)
  protocol_lock.example.json     # lock schema sample
  endpoints.json                 # gitignored — your pre-registered list
  protocol_lock.json             # gitignored — integrity lock
  last_*.json                    # gitignored — local run artifacts
  raw/                           # gitignored EDFs + summaries
    chb01/
      chb01-summary.txt
      chb01_03.edf
      ...
```

## Download pilot (chb01 only)

```bash
mkdir -p data/chbmit/raw
wget -r -N -c -np -nH --cut-dirs=3 -P data/chbmit/raw \
  https://physionet.org/files/chbmit/1.0.0/chb01/

# or
aws s3 sync --no-sign-request \
  s3://physionet-open/chbmit/1.0.0/chb01/ \
  data/chbmit/raw/chb01/
```

## Serious workflow

```bash
cd python && pip install -e ".[dev,eeg]"
cd ..

python notebooks/12_chbmit_p1_eeg.py parse \
  --raw data/chbmit/raw --case chb01 \
  --out data/chbmit/endpoints_candidates.json

# Review candidates → copy to endpoints.json, set pre_registered true
# ONLY THEN:
python notebooks/12_chbmit_p1_eeg.py lock \
  --endpoints data/chbmit/endpoints.json \
  --lock data/chbmit/protocol_lock.json

python notebooks/12_chbmit_p1_eeg.py score \
  --endpoints data/chbmit/endpoints.json \
  --lock data/chbmit/protocol_lock.json \
  --raw data/chbmit/raw \
  --out data/chbmit/last_p1_eeg_score.json

python notebooks/12_chbmit_p1_eeg.py report \
  --score data/chbmit/last_p1_eeg_score.json
```

## Citations

- Guttag, J. (2010). CHB-MIT Scalp EEG Database (version 1.0.0). PhysioNet. https://doi.org/10.13026/C2K01R  
- Shoeb, A. (2009). PhD Thesis, MIT.  
- Pollard et al. (PhysioNet platform citation as required by PhysioNet).

## Honesty

This track is **`[EMPÍRICO]` C3 neuro** with clinical seizure onset.  
It does **not** discharge Aedes/dengue P1 (4–6 weeks).
