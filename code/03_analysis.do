*======================================================================
* 03_analysis.do
*
* Analysis on data/derived/analysis_sample.dta:
*   (1) OLS of log revenue on log capital, log employment, industry FE
*   (2) a regression table written to output/tables/table1_regression.txt
*   (3) a scatter + linear-fit figure in output/figures/figure1_*.png
*
* Only built-in Stata commands are used (regress, twoway, graph export,
* file write), so the package needs no SSC/ado downloads and runs on any
* recent Stata version inside the SIVACOR container.
*======================================================================

use "$derived/analysis_sample.dta", clear

*----------------------------------------------------------------------
* (1) Regression
*----------------------------------------------------------------------
regress log_revenue log_capital log_employment i.industry

local nobs = e(N)
local r2   = e(r2)

*----------------------------------------------------------------------
* (2) Version-robust regression table (plain text, built-in file write)
*----------------------------------------------------------------------
* Note: in `file write`, a %fmt width applies to an expression in
* parentheses, not to a bare quoted literal -- so column labels are
* wrapped in (...) to make them pad and align.
file open tab using "$tables/table1_regression.txt", write replace text
file write tab "Table 1. OLS regression of log revenue on firm inputs" _n
file write tab "Dependent variable: log_revenue" _n
file write tab "------------------------------------------------------" _n
file write tab %-24s ("Variable") %12s ("Coef.") %12s ("Std. Err.") _n
file write tab "------------------------------------------------------" _n
foreach v in log_capital log_employment {
    file write tab %-24s ("`v'") %12.4f (_b[`v']) %12.4f (_se[`v']) _n
}
file write tab %-24s ("Constant") %12.4f (_b[_cons]) %12.4f (_se[_cons]) _n
file write tab "------------------------------------------------------" _n
file write tab "Industry fixed effects: Yes" _n
file write tab %-24s ("Observations") %12.0f (`nobs') _n
file write tab %-24s ("R-squared") %12.4f (`r2') _n
file close tab

display as result "03_analysis.do: wrote $tables/table1_regression.txt"

*----------------------------------------------------------------------
* (3) Figure: log revenue vs log capital, with linear fit
*----------------------------------------------------------------------
twoway (scatter log_revenue log_capital, msize(small) mcolor(navy))      ///
       (lfit    log_revenue log_capital, lcolor(maroon) lwidth(medthick)), ///
       title("Revenue and capital across firms")                          ///
       subtitle("Simulated data, matched registry + survey sample")       ///
       xtitle("Log capital") ytitle("Log revenue")                        ///
       legend(order(1 "Firms" 2 "Linear fit"))                            ///
       graphregion(color(white)) plotregion(color(white))

graph export "$figures/figure1_revenue_capital.png", replace width(1600)

display as result "03_analysis.do: wrote $figures/figure1_revenue_capital.png"
