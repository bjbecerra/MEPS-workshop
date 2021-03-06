**********************************************************************************
*
*PROGRAM:      C:\work\MEPS_workshop\programs\Ex3.do
*
*DESCRIPTION:  THIS PROGRAM ILLUSTRATES HOW TO POOL MEPS DATA FILES FROM DIFFERENT YEARS TO FORM A LARGE CROSS SECTION
*              THE EXAMPLE USED IS POPULATION AGE 26-30 WHO ARE UNINSURED BUT HAVE HIGH INCOME
*
*	         		 DATA FROM 2016 AND 2017 ARE POOLED.
*
*              VARIABLES WITH YEAR-SPECIFIC NAMES MUST BE RENAMED BEFORE COMBINING FILES.  
*              IN THIS PROGRAM THE INSURANCE COVERAGE VARIABLES 'INSCOV16' AND 'INSCOV17' ARE RENAMED TO 'INSCOV'.
*
*	         	SEE HC-036 (1996-2015 POOLED ESTIMATION FILE) FOR
*              	INSTRUCTIONS ON POOOLING AND CONSIDERATIONS FOR VARIANCE
*	         	ESTIMATION FOR PRE-2002 DATA.
*
*INPUT FILE:   (1) C:\MEPS\STATA\DATA\H192.dta (2016 FULL-YEAR FILE)
*	           (2) C:\MEPS\STATA\DATA\H201.dta (2017 FULL-YEAR FILE)
*
*********************************************************************************

clear
set more off
capture log close
log using C:\work\MEPS_workshop\Ex3.log, replace
cd C:\work\MEPS_workshop\

// rename year specific variables prior to combining files
use dupersid inscov16 perwt16f varstr varpsu povcat16 agelast totslf16 using h192, clear
*import sasxport5 h192.ssp
*keep dupersid inscov16 perwt16f varstr varpsu povcat16 agelast totslf16
rename inscov16 inscov
rename perwt16f perwt 
rename povcat16 povcat 
rename totslf16 totslf
tempfile yr1
save "`yr1'"

use dupersid inscov17 perwt17f varstr varpsu povcat17 agelast totslf17 using h201, clear
*import sasxport5 h201.ssp
*keep dupersid inscov17 perwt17f varstr varpsu povcat17 agelast totslf17

rename inscov17 inscov
rename perwt17f perwt 
rename povcat17 povcat 
rename totslf17 totslf

append using "`yr1'", generate(yearnum)

gen poolwt=perwt/2
gen wealthy_unins=(agelast>=26 & agelast<=30 & inscov==3 & povcat==5)

tab1 agelast inscov povcat if wealthy_unins==1, m
tab wealthy_unins yearnum, m
summarize

svyset [pweight=poolwt], strata(varstr) psu(varpsu) vce(linearized) singleunit(missing)

// weighted estimate on totslf for combined data w/age=26-30, uninsured whole year, and high income
svy, subpop(wealthy_unins): mean totslf


