

set mem 80m
set matsize 800
set more off

log using kansas_log.log, replace

clear
insheet using kansas.txt, tab
reshape long y, i(county var) j(year)
reshape wide y, i(county year) j(var)

rename y2 wwheat_a
rename y3 wwheat_y
rename y10 corn_a
rename y11 corn_y
rename y14 oats_a
rename y15 oats_y
gen lnwheat_p = ln(wwheat_y/wwheat_a)
gen lncorn_p = ln(corn_y/corn_a)
gen lnoats_p = ln(oats_y/oats_a)

sort county
merge county using timber.dta, uniqusing
keep if _merge==3
drop _merge
keep lnwheat_p lncorn_p lnoats_p timber county year

rename lnwheat_p p1
rename lncorn_p p2
rename lnoats_p p3
reshape long p, i(county year) j(crop)

gen double year_crop = year*10+crop
gen double county_crop = county*10+crop
tab county_crop, gen(cc_)

gen t = timber
gen s = timber^2
gen c = timber^3
gen q = timber^4

foreach i of numlist 1874(1)1936 {
gen y_`i'_t = t*(year==`i')
gen y_`i'_s = s*(year==`i')
gen y_`i'_c = c*(year==`i')
gen y_`i'_q = q*(year==`i')
}

drop y_1874_t y_1874_c y_1874_s y_1874_q
areg p y_* cc_*, absorb(year_crop) cluster(county)
foreach i of numlist 1875(1)1936 {
nlcom (d_`i': -.06*_b[y_`i'_t] - .0036*_b[y_`i'_s] - .000216*_b[y_`i'_c] - .00001296*_b[y_`i'_q])
}

areg p y_* cc_* if crop==1, absorb(year_crop) cluster(county)
foreach i of numlist 1875(1)1936 {
nlcom (d_`i': -.06*_b[y_`i'_t] - .0036*_b[y_`i'_s] - .000216*_b[y_`i'_c] - .00001296*_b[y_`i'_q])
}

areg p y_* cc_* if crop==2, absorb(year_crop) cluster(county)
foreach i of numlist 1875(1)1936 {
nlcom (d_`i': -.06*_b[y_`i'_t] - .0036*_b[y_`i'_s] - .000216*_b[y_`i'_c] - .00001296*_b[y_`i'_q])
}

areg p y_* cc_* if crop==3, absorb(year_crop) cluster(county)
foreach i of numlist 1875(1)1936 {
nlcom (d_`i': -.06*_b[y_`i'_t] - .0036*_b[y_`i'_s] - .000216*_b[y_`i'_c] - .00001296*_b[y_`i'_q])
}

log close
