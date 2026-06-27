*======================================================================
* 01_make_data.do
*
* Simulate TWO separate raw data sources that share a firm identifier:
*   data/raw/firm_registry.dta  -- firm characteristics (industry, region,
*                                   capital)
*   data/raw/firm_survey.dta    -- firm outcomes (employment, revenue),
*                                   with a few firms missing (non-response)
*
* These two files are intentionally kept apart so that 02_merge.do has a
* real merge to perform. The random draws are reproducible because the
* seed is fixed in main.do.
*======================================================================

clear
set obs 500
gen long firm_id = _n

* ---- latent firm attributes (used to build both sources) -------------
gen byte   industry = 1 + int(runiform()*5)            // sector 1..5
gen byte   region   = 1 + int(runiform()*4)            // region 1..4
gen double lcapital = rnormal(10, 1)                   // log capital stock
gen double lemp     = 0.6*lcapital + rnormal(0, 0.5)   // log employment

* industry-specific productivity shifter
gen double ind_fe = 0
forvalues k = 1/5 {
    replace ind_fe = 0.10*`k' if industry == `k'
}

* outcome: log revenue (this is the relationship 03_analysis recovers)
gen double lrevenue = 2 + 0.5*lcapital + 0.4*lemp + ind_fe + rnormal(0, 0.4)

* ---- Source A: firm registry (characteristics) ----------------------
preserve
    keep firm_id industry region lcapital
    rename lcapital log_capital
    label var firm_id     "Firm identifier"
    label var industry    "Industry sector (1-5)"
    label var region      "Region code (1-4)"
    label var log_capital "Log of capital stock"
    label data "Source A: firm registry (simulated)"
    save "$rawdata/firm_registry.dta", replace
restore

* ---- Source B: firm survey (outcomes) -------------------------------
preserve
    keep firm_id lemp lrevenue
    rename lemp     log_employment
    rename lrevenue log_revenue
    * simulate ~5% survey non-response -> these firms are missing in B
    drop if runiform() < 0.05
    label var firm_id        "Firm identifier"
    label var log_employment "Log of employment"
    label var log_revenue    "Log of revenue"
    label data "Source B: firm survey (simulated)"
    save "$rawdata/firm_survey.dta", replace
restore

display as result "01_make_data.do: created firm_registry.dta and firm_survey.dta"
