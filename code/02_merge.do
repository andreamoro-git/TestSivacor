*======================================================================
* 02_merge.do
*
* Merge the two raw sources on firm_id and build the analysis sample:
*   data/derived/analysis_sample.dta
*
* The registry (A) has every firm; the survey (B) is missing the ~5% of
* firms that did not respond, so a 1:1 merge yields _merge==1 (registry
* only) and _merge==3 (matched). We keep only matched firms.
*======================================================================

use "$rawdata/firm_registry.dta", clear

* firm_survey lives in the confidential folder (see .sivacorignore); it is
* present during the run, so the merge works normally.
merge 1:1 firm_id using "$rawconf/firm_survey.dta"

* report the merge outcome to the log, then keep matched firms only
tab _merge
keep if _merge == 3
drop _merge

* one small derived variable: capital per worker (in levels)
gen double capital_per_worker = exp(log_capital) / exp(log_employment)
label var capital_per_worker "Capital per worker (levels)"

label data "Analysis sample: registry + survey, matched firms"
compress
save "$derived/analysis_sample.dta", replace

display as result "02_merge.do: analysis_sample.dta has " _N " matched firms"
