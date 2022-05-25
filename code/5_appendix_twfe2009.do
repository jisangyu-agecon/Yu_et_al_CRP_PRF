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
