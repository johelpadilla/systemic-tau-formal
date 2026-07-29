"""Minimal Systemic Tau + RECD reference core."""

from .constants import DELTA, THETA_CHAOS, THETA_STABLE
from .tau import compute_taus, kendall_tau
from .recd import accumulate_time, gate_function, compute_recd_increments
from .golden import gate_rat, golden_payload
from .io_data import load_matrix_csv, save_matrix_csv
from .aedes_io import AedesLoadResult, discover_matrix_csvs, load_aedes_sites
from .regimes import (
    p3_noise_scan,
    regime_agreement,
    regime_fracs,
    regime_vector,
)
from .p4_sync import (
    p4_baseline_metrics,
    p4_clock_metrics,
    p4_field_scan,
    p4_nearest_baseline,
    p4_series_report,
    pairwise_corr_stats,
)
from .empirical_board import build_empirical_board
from .field_return import (
    chaos_band_runs,
    field_return_report,
    multi_site_field_return,
)
from .first_return import (
    first_return_crossing,
    first_return_from_local_maxima,
    nonneg_pred,
    return_pairs,
    section_values,
)
from .p1_endpoints import exploratory_lead_scan, trap_surge_t_obs
from .p1_aedes import (
    FROZEN_PARAMS as P1_AEDES_FROZEN_PARAMS,
    PROTOCOL_ID as P1_AEDES_PROTOCOL_ID,
    PROTOCOL_VERSION as P1_AEDES_PROTOCOL_VERSION,
    make_protocol_lock as make_aedes_protocol_lock,
    propose_endpoints_from_incidence,
    score_locked_endpoints as score_locked_aedes_endpoints,
)
from .p1_ili import (
    FROZEN_PARAMS as P1_ILI_FROZEN_PARAMS,
    PROTOCOL_ID as P1_ILI_PROTOCOL_ID,
    PROTOCOL_VERSION as P1_ILI_PROTOCOL_VERSION,
    make_protocol_lock as make_ili_protocol_lock,
    propose_endpoints_from_flusurv,
    score_locked_endpoints as score_locked_ili_endpoints,
)
from .p1_eeg import (
    FROZEN_PARAMS as P1_EEG_FROZEN_PARAMS,
    PROTOCOL_ID as P1_EEG_PROTOCOL_ID,
    PROTOCOL_VERSION as P1_EEG_PROTOCOL_VERSION,
    build_candidates_document,
    make_protocol_lock,
    score_endpoints_eeg,
    score_seizure_matrix,
)
from .p1_synthetic import (
    FROZEN_PARAMS as P1_SYN_FROZEN_PARAMS,
    PROTOCOL_ID as P1_SYN_PROTOCOL_ID,
    PROTOCOL_VERSION as P1_SYN_PROTOCOL_VERSION,
    evaluate_gates as evaluate_syn_gates,
    make_protocol_lock as make_syn_protocol_lock,
    run_full_pipeline as run_syn_full_pipeline,
    score_locked_endpoints as score_locked_syn_endpoints,
)
from .report import format_report, pipeline_report
from .synthetic import (
    add_column_noise,
    aedes_proxy_two_sites,
    anti_synchronized,
    coupled_logistic,
    eeg_like_channels,
    finance_like_returns,
    grid_like_loads,
    independent_noise,
    p1_canonical_null_noise,
    p1_canonical_null_sync,
    p1_canonical_panel,
    regime_switch,
    synchronized_seasonal,
)

__all__ = [
    "DELTA",
    "THETA_CHAOS",
    "THETA_STABLE",
    "kendall_tau",
    "compute_taus",
    "gate_function",
    "compute_recd_increments",
    "accumulate_time",
    "gate_rat",
    "golden_payload",
    "load_matrix_csv",
    "save_matrix_csv",
    "AedesLoadResult",
    "discover_matrix_csvs",
    "load_aedes_sites",
    "regime_vector",
    "regime_agreement",
    "regime_fracs",
    "p3_noise_scan",
    "pairwise_corr_stats",
    "p4_clock_metrics",
    "p4_baseline_metrics",
    "p4_nearest_baseline",
    "p4_series_report",
    "p4_field_scan",
    "build_empirical_board",
    "chaos_band_runs",
    "field_return_report",
    "multi_site_field_return",
    "exploratory_lead_scan",
    "trap_surge_t_obs",
    "P1_AEDES_FROZEN_PARAMS",
    "P1_AEDES_PROTOCOL_ID",
    "P1_AEDES_PROTOCOL_VERSION",
    "make_aedes_protocol_lock",
    "propose_endpoints_from_incidence",
    "score_locked_aedes_endpoints",
    "P1_ILI_FROZEN_PARAMS",
    "P1_ILI_PROTOCOL_ID",
    "P1_ILI_PROTOCOL_VERSION",
    "make_ili_protocol_lock",
    "propose_endpoints_from_flusurv",
    "score_locked_ili_endpoints",
    "P1_EEG_FROZEN_PARAMS",
    "P1_EEG_PROTOCOL_ID",
    "P1_EEG_PROTOCOL_VERSION",
    "build_candidates_document",
    "make_protocol_lock",
    "score_endpoints_eeg",
    "score_seizure_matrix",
    "P1_SYN_FROZEN_PARAMS",
    "P1_SYN_PROTOCOL_ID",
    "P1_SYN_PROTOCOL_VERSION",
    "make_syn_protocol_lock",
    "score_locked_syn_endpoints",
    "evaluate_syn_gates",
    "run_syn_full_pipeline",
    "p1_canonical_panel",
    "p1_canonical_null_sync",
    "p1_canonical_null_noise",
    "first_return_crossing",
    "first_return_from_local_maxima",
    "nonneg_pred",
    "return_pairs",
    "section_values",
    "add_column_noise",
    "aedes_proxy_two_sites",
    "anti_synchronized",
    "coupled_logistic",
    "eeg_like_channels",
    "finance_like_returns",
    "grid_like_loads",
    "independent_noise",
    "regime_switch",
    "synchronized_seasonal",
    "pipeline_report",
    "format_report",
]

__version__ = "0.1.7"
