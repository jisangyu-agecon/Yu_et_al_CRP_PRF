*TWFE 2009
clear all
cd "/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/"

use main_sample.dta, clear

keep if g==2009 | g==0
forval i=2007/2015{
	gen prfx`i'=0
	replace prfx`i'=1 if g==2009 & year==`i'
}
reghdfe crp_share prfx*, absorb(fips year) cluster(fips)
forval i=2007/2015{
	label var prfx`i' "`i'"
}
coefplot, keep(prfx2007 prfx2008 prfx2009 prfx2010 prfx2011 prfx2012 prfx2013 prfx2014 prfx2015) vertical graphregion(color(white)) title("Group 2009 vs Control") yline(0) xline(3, lpattern(dash))
graph export twfe2009.eps, replace

*TWFE 2009 long
clear all
cd "/Users/jisangyu/Dropbox/PRF_CRP/codes_and_data/"

use main_sample_long.dta, clear
keep if year>2001

*balanced panel
bys fips: gen noyears=_N
tab noyears
keep if noyears==14

keep if g==2009 | g==0
forval i=2003/2015{
	gen prfx`i'=0
	replace prfx`i'=1 if g==2009 & year==`i'
}
reghdfe crp_share prfx*, absorb(fips year) cluster(fips)
forval i=2003/2015{
	label var prfx`i' "`i'"
}
coefplot, keep(prfx*) vertical graphregion(color(white)) title("Group 2009 vs Control") yline(0) xline(7, lpattern(dash))
graph export twfe2009_long.eps, replace


*Visualize permutation test
clear all

import delimited "randomization_rep5000.csv"

rename x beta

gr tw kdensity beta, graphregion(color(white)) xline(-0.0082) title("Placebo test", size(small)) range(-0.01 0.01) ///
text(400 -0.0082 "{&beta}=-0.0082 (p-value=0.000)", place(se)) ytitle("Density") xtitle("Coefficients")
graph export placebo.eps, replace
