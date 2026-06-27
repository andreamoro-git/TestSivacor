*======================================================================
* main.do  --  SIVACOR test replication package (single controller script)
*
* Designate THIS file as the main do-file when submitting to SIVACOR.
* SIVACOR sets the working directory to the folder that contains the
* main do-file, so every path below is built relative to that location
* through the global $rootdir. No absolute / hardcoded paths are used.
*
* Pipeline:
*   01_make_data.do  -> simulate two separate raw data sources
*   02_merge.do      -> merge them on firm_id into an analysis sample
*   03_analysis.do   -> regression + table + figure
*======================================================================

clear all
set more off
version 14            // conservative: runs on Stata 14 and every later version

*----------------------------------------------------------------------
* Root = folder containing this main.do (the SIVACOR working directory)
*----------------------------------------------------------------------
global rootdir "`c(pwd)'"

global code     "$rootdir/code"
global rawdata  "$rootdir/data/raw"
global rawconf  "$rootdir/data/raw-confidential"
global derived  "$rootdir/data/derived"
global tables   "$rootdir/output/tables"
global figures  "$rootdir/output/figures"

* Create output folders if missing (idempotent: safe to re-run)
cap mkdir "$rootdir/data"
cap mkdir "$rawdata"
cap mkdir "$rawconf"
cap mkdir "$derived"
cap mkdir "$rootdir/output"
cap mkdir "$tables"
cap mkdir "$figures"

*----------------------------------------------------------------------
* Raw data are PROVIDED with the package and treated as given inputs:
*   data/raw/firm_registry.dta             public
*   data/raw-confidential/firm_survey.dta  confidential -- excluded from
*        the redistributed output by .sivacorignore, but present during
*        the run so the code executes normally.
* Both are built by make_data.do at the package root, which is documented
* for transparency but is NOT part of this reproducible pipeline.
*----------------------------------------------------------------------
do "$code/02_merge.do"
do "$code/03_analysis.do"

display as result "==> SIVACOR test package completed successfully."
