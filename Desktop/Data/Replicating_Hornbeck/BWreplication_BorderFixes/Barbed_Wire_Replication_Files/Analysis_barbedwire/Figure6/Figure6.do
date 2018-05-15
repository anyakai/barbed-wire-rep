use Figure6.dta
set graphics off

twoway (scatter coef year if series==1&landuse==3, mc(black) msymbol(O) msiz(large)) (scatter coef year if series==2&landuse==3, mc(black) msymbol(Oh) msiz(large)), scheme(s2mono) ysize(3) ysc(r(0 .3)) ytitle("") ylabel(0 .1 .2 .3, nogrid) xsize(5) xtitle("") xsc(r(1870 1920)) xlabel(1870 1880 1890 1900 1910 1920, nogrid) graphregion(fcolor(white) lstyle(solid)) xline(1880, lpattern(dot)) xline(1900, lpattern(dot)) legend(order(1 2) rows(1) symplacement(left) label(1 "0% Woodland vs. 6% Woodland") label(2 "6% Woodland vs 12% Woodland"))
graph save Figure6, replace
