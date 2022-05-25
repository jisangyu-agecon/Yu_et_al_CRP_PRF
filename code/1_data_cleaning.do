clear all

*PPI data
clear
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/ppi_allcommodities.txt", clear 
keep if year>1988
keep if period=="M13" | period=="M01"
drop if period=="M01" & year<2019
rename value ppi
keep year ppi
tempfile ppi
save `ppi', replace

*CRP acres
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/CRP_county_acres.csv", encoding(UTF-8) clear

reshape long acres, i(state county fips) j(year)
label var acres "CRP enrolled acres"

tempfile temp1
save `temp1', replace

*CRP rent
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/CRP_county_rent.csv", encoding(UTF-8) clear

reshape long rent, i(state county fips) j(year)
label var rent "Average CRP rent payment (USD/acre)"

tempfile temp2
save `temp2', replace

*1997 total cropland
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/totalcropland1997.csv", encoding(UTF-8) clear

gen fips=stateansi*1000+countyansi
rename value totalacre1997

keep fips totalacre1997
drop if fips==.

label var totalacre1997 "Total Cropland Acres (1997)"

tempfile temp3
save `temp3', replace

*2002 total cropland
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/totalcropland2002.csv", encoding(UTF-8) clear

gen fips=stateansi*1000+countyansi
rename value totalacre2002

keep fips totalacre2002
drop if fips==.

label var totalacre2002 "Total Cropland Acres (2002)"

tempfile temp4
save `temp4', replace

*2007 total cropland
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/totalcropland2007.csv", encoding(UTF-8) clear

gen fips=stateansi*1000+countyansi
rename value totalacre2007

keep fips totalacre2007
drop if fips==.

label var totalacre2007 "Total Cropland Acres (2007)"

tempfile temp5
save `temp5', replace

*2012 total cropland
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/totalcropland2012.csv", encoding(UTF-8) clear

gen fips=stateansi*1000+countyansi
rename value totalacre2012

keep fips totalacre2012
drop if fips==.

label var totalacre2012 "Total Cropland Acres (2012)"

tempfile temp6
save `temp6', replace

*2007 total pastureland
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/pastureland2007.csv", encoding(UTF-8) clear

gen fips=stateansi*1000+countyansi
rename value pastureland2007

keep fips pastureland2007
drop if fips==.

label var pastureland2007 "Total Pastureland Acres (2007)"

tempfile temp7
save `temp7', replace

*2002 total pastureland
import delimited "/Users/jisangyu/Dropbox/PRF_CRP/pastureland2002.csv", encoding(UTF-8) clear

gen fips=stateansi*1000+countyansi
rename value pastureland2002

keep fips pastureland2002
drop if fips==.

label var pastureland2002 "Total Pastureland Acres (2002)"

tempfile temp8
save `temp8', replace


*PRF availability
use "/Users/jisangyu/Dropbox/PRF_CRP/prf_availability.dta", clear

*merge with CRP and other data
merge 1:1 fips year using `temp1'
drop if _merge==1
drop _merge
merge 1:1 fips year using `temp2'
drop if _merge==1
drop _merge
merge m:1 fips using `temp3'
keep if _merge==3
drop _merge
merge m:1 fips using `temp4'
keep if _merge==3
drop _merge
merge m:1 fips using `temp5'
keep if _merge==3
drop _merge
merge m:1 fips using `temp6'
keep if _merge==3
drop _merge
merge m:1 fips using `temp7'
drop _merge
merge m:1 fips using `temp8'
drop _merge
merge 1:1 fips year using "/Users/jisangyu/Dropbox/PRF_CRP/PRISM_1981_2017_apr_sep.dta"
keep if _merge==3
drop _merge


*replace missing availability variables with zeros before 2014
replace rainfall=0 if rainfall==. & year<2016
replace vegetation=0 if vegetation==. & year<2016
replace rainfall=1 if rainfall==. & year>2015

gen prf_available=1
replace prf_available=0 if rainfall==0 & vegetation==0

xtset fips year
replace prf_available=l.prf_available if year==2014
replace prf_available=l.prf_available if year==2015

*gen share
gen crp_share=acres/totalacre1997
replace crp_share=acres/totalacre2002 if year>2001
replace crp_share=acres/totalacre2007 if year>2006
replace crp_share=acres/totalacre2012 if year>2011

*drop if the total acres are 0 or missing
drop if crp_share==.
drop if crp_share>1

preserve
tsset fips year
gen dacres=d.acres
gen dcrp_share=d.crp_share

tssmooth ma prec_ma10=prec_apr_sep, window(9,1,0)
tssmooth ma temp_ma10=tAvg, window(9,1,0)
tssmooth ma crpacres_ma10=acres, window(9,1,0)
tssmooth ma crpshare_ma10=crp_share, window(9,1,0)

gen year2006=0
replace year2006=1 if year==2006

gen precx2006=prec_ma10*year2006
gen tempx2006=temp_ma10*year2006
gen crpacresx2006=crpacres_ma10*year2006
gen crpsharex2006=crpshare_ma10*year2006

bys fips: egen prec2006=sum(precx2006)
bys fips: egen temp2006=sum(tempx2006)
bys fips: egen crpacres2006=sum(crpacresx2006)
bys fips: egen crpshare2006=sum(crpsharex2006)

drop if prec2006==.
drop if temp2006==.
drop if crpacres2006==.
drop if crpshare2006==.
replace pastureland2007=0 if pastureland2007==.
replace pastureland2002=0 if pastureland2002==.

gen pastureshare2007=pastureland2007/totalacre2007
drop if pastureshare2007==.

gen pastureshare2002=pastureland2002/totalacre2002
drop if pastureshare2002==.

*keep 2006 -- 2015
keep if year>2005
drop if year>2015

*balanced panel
bys fips: gen noyears=_N
tab noyears
drop if noyears!=10

*gen t and g
gen t=year
label var t "time"
gen temp_t_g=t*prf_available
replace temp_t_g=. if temp_t_g==0
bys fips: egen g=min(temp_t_g)
replace g=0 if g==.
label var g "group"

bys g: tab state
*drop if g>5

keep fips state county year t g acres crp_share dacres dcrp_share rainfall prf_available prec2006 temp2006 crpacres2006 crpshare2006 totalacre* pastureland2007 pastureshare2007 pastureland2002 pastureshare2002

*save
saveold "/Users/jisangyu/Dropbox/PRF_CRP/full_sample.dta", version(12) replace

*main sample
drop if g>2010

keep fips state county year t g acres crp_share dacres dcrp_share rainfall prf_available prec2006 temp2006 crpacres2006 crpshare2006 totalacre* pastureland2007 pastureshare2007 pastureland2002 pastureshare2002

*save
saveold "/Users/jisangyu/Dropbox/PRF_CRP/main_sample.dta", version(12) replace
restore


preserve
tsset fips year
gen dacres=d.acres
gen dcrp_share=d.crp_share

tssmooth ma prec_ma10=prec_apr_sep, window(9,1,0)
tssmooth ma temp_ma10=tAvg, window(9,1,0)
tssmooth ma crpacres_ma10=acres, window(9,1,0)
tssmooth ma crpshare_ma10=crp_share, window(9,1,0)

gen year2006=0
replace year2006=1 if year==2006

gen precx2006=prec_ma10*year2006
gen tempx2006=temp_ma10*year2006
gen crpacresx2006=crpacres_ma10*year2006
gen crpsharex2006=crpshare_ma10*year2006

bys fips: egen prec2006=sum(precx2006)
bys fips: egen temp2006=sum(tempx2006)
bys fips: egen crpacres2006=sum(crpacresx2006)
bys fips: egen crpshare2006=sum(crpsharex2006)

drop if prec2006==.
drop if temp2006==.
drop if crpacres2006==.
drop if crpshare2006==.
replace pastureland2007=0 if pastureland2007==.
replace pastureland2002=0 if pastureland2002==.

gen pastureshare2007=pastureland2007/totalacre2007
drop if pastureshare2007==.

gen pastureshare2002=pastureland2002/totalacre2002
drop if pastureshare2002==.

*keep before 2016
drop if year>2015

*gen t and g
gen t=year
label var t "time"
gen temp_t_g=t*prf_available
replace temp_t_g=. if temp_t_g==0
bys fips: egen g=min(temp_t_g)
replace g=0 if g==.
label var g "group"

bys g: tab state

*main sample
drop if g>2010

keep fips state county year t g acres crp_share dacres dcrp_share rainfall prf_available prec2006 temp2006 crpacres2006 crpshare2006 totalacre* pastureland2007 pastureshare2007 pastureland2002 pastureshare2002

*save
saveold "/Users/jisangyu/Dropbox/PRF_CRP/main_sample_long.dta", version(12) replace
restore


*subsample 1
*ppi
merge m:1 year using `ppi'
keep if _merge==3
drop _merge

*gen average rent (2003 real dollar)
gen avg_rent=138.1*(rent/ppi)

preserve
tsset fips year
gen dacres=d.acres
gen dcrp_share=d.crp_share

tssmooth ma prec_ma10=prec_apr_sep, window(9,1,0)
tssmooth ma temp_ma10=tAvg, window(9,1,0)
tssmooth ma crpacres_ma10=acres, window(9,1,0)
tssmooth ma crpshare_ma10=crp_share, window(9,1,0)
tssmooth ma crprent_ma10=avg_rent, window(9,1,0)

gen year2006=0
replace year2006=1 if year==2006

gen precx2006=prec_ma10*year2006
gen tempx2006=temp_ma10*year2006
gen crpacresx2006=crpacres_ma10*year2006
gen crpsharex2006=crpshare_ma10*year2006
gen crprentx2006=crprent_ma10*year2006

bys fips: egen prec2006=sum(precx2006)
bys fips: egen temp2006=sum(tempx2006)
bys fips: egen crpacres2006=sum(crpacresx2006)
bys fips: egen crpshare2006=sum(crpsharex2006)
bys fips: egen crprent2006=sum(crprentx2006)

drop if prec2006==.
drop if temp2006==.
drop if crpacres2006==.
drop if crpshare2006==.
drop if crprent2006==.
drop if crprent2006==0
replace pastureland2007=0 if pastureland2007==.
replace pastureland2002=0 if pastureland2002==.

gen pastureshare2007=pastureland2007/totalacre2007
drop if pastureshare2007==.

gen pastureshare2002=pastureland2002/totalacre2002
drop if pastureshare2002==.


*keep 2005 -- 2013
keep if year>2005
drop if year>2015

*balanced panel
bys fips: gen noyears=_N
tab noyears
drop if noyears!=10

*gen t and g
gen t=year
label var t "time"
gen temp_t_g=t*prf_available
replace temp_t_g=. if temp_t_g==0
bys fips: egen g=min(temp_t_g)
replace g=0 if g==.
label var g "group"

bys g: tab state
drop if g>2010

keep fips state county year t g acres crp_share avg_rent dacres dcrp_share rainfall prf_available prec2006 temp2006 crpacres2006 crpshare2006 crprent2006 totalacre* pastureland2007 pastureshare2007 pastureland2002 pastureshare2002

*save
saveold "/Users/jisangyu/Dropbox/PRF_CRP/rent_subsample.dta", version(12) replace
restore
