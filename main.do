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
global derived  "$rootdir/data/derived"
global tables   "$rootdir/output/tables"
global figures  "$rootdir/output/figures"

* Create output folders if missing (idempotent: safe to re-run)
cap mkdir "$rootdir/data"
cap mkdir "$rawdata"
cap mkdir "$derived"
cap mkdir "$rootdir/output"
cap mkdir "$tables"
cap mkdir "$figures"

* Fixed seed for full reproducibility
set seed 20260627

*----------------------------------------------------------------------
* Run the pipeline in order
*----------------------------------------------------------------------
do "$code/01_make_data.do"
do "$code/02_merge.do"
do "$code/03_analysis.do"

display as result "==> SIVACOR test package completed successfully."
