clear
set mem 50m
set more off
set graphics off

use "pig iron.dta"
sort year_month
merge year_month using "steel rail.dta", unique
drop _merge
sort year_month
merge year_month using "steel billet.dta", unique
drop _merge
sort year_month
merge year_month using "barbed wire.dta", unique
drop _merge
sort year_month
merge year_month using "barbed_wire_4.dta", unique
drop _merge
sort year_month
merge year_month using "general_price.dta", unique
drop _merge
sort year_month

gen barbed_wire_2 = 22.4*barbed_wire
replace barbed_wire_4 = barbed_wire_4*2240

gen barbed_wire_3 = 10 if year==1880&month==6
replace barbed_wire_3 = 4.2 if year==1885&month==6
replace barbed_wire_3 = 3.45 if year==1890&month==6
replace barbed_wire_3 = 1.8 if year==1897&month==6
replace barbed_wire_3 = 20 if year==1874&month==6
replace barbed_wire_3 = barbed_wire_3*22.4

gen barbed_wire_final = barbed_wire_4 if year<1890
replace barbed_wire_final = barbed_wire_2 if year>=1890
replace barbed_wire_final = barbed_wire_3 if year==1874

gen steel = steel_rail if year<1890
replace steel = steel_billet if year>=1890

replace year = year + (month-1)/12

twoway (line steel year if year<=1910&year>=1850, scheme(s2mono) xsize(7) ysize(4) graphregion(fcolor(white) lstyle(solid)) ylabel(, nogrid) xlabel(1850 1860 1870 1880 1890 1900 1910,nogrid) ytitle("Price, dollars per ton") clpattern(shortdash)) (line pig_iron year if year<=1910&year>=1850, clpattern(dot)) (line barbed_wire_final year if year<=1910&year>=1877, clpattern(solid) legend(order(2 1 3) rows(1) label(1 "Steel") label(2 "Iron") label(3 "Barbed Wire")))
graph save Figure1, replace

*Include earlier observations
twoway (line steel year if year<=1910&year>=1850, scheme(s2mono) xsize(7) ysize(4) graphregion(fcolor(white) lstyle(solid)) ylabel(, nogrid) xlabel(1850 1860 1870 1880 1890 1900 1910,nogrid) ytitle("Price, dollars per ton") clpattern(shortdash)) (line pig_iron year if year<=1910&year>=1850, clpattern(dot)) (scatter barbed_wire_final year if year<=1910&year>=1874, clpattern(solid) msymbol(x) mcolor(black) msize(small) legend(order(2 1 3) rows(1) label(1 "Steel") label(2 "Iron") label(3 "Barbed Wire")))

*Compare iron and general prices
replace pig_iron = log(pig_iron)
replace general_price = log(general_price)
twoway (line pig_iron year if year<=1910&year>=1850, scheme(s2mono) xsize(7) ysize(4) graphregion(fcolor(white) lstyle(solid)) ylabel(, nogrid) xlabel(1850 1860 1870 1880 1890 1900 1910,nogrid) ytitle("") clpattern(dash)) (line general_price year if year<=1910&year>=1850, clpattern(solid) legend(order(1 2) rows(1) label(1 "Iron Price per Ton") label(2 "General Price Level")))

