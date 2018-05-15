
use Figure5.dta

set graphics off

twoway (line coef level if year==1880, clcolor(black) clpat(solid)) (line max level if year==1880, clcolor(black) clpat(dash)) (line min level if year==1880, clcolor(black) clpat(dash) title("From  1870  To  1880") scheme(s2mono) ysize(2.5) ysc(r(-.2 .1)) ytitle("Estimated Relative Change, +/- 2 SE") ylabel(-.2 -.15 -.1 -.05 0 .05 .1, nogrid) xsize(2) xtitle(Woodland Level) xlabel(0 .02 .04 .06 .08 .10 .12, nogrid) graphregion(fcolor(white) lstyle(solid)) legend(off))
graph save Figure5_a, replace

twoway (line coef level if year==1890, clcolor(black) clpat(solid)) (line max level if year==1890, clcolor(black) clpat(dash)) (line min level if year==1890, clcolor(black) clpat(dash) title("From  1880  To  1890") scheme(s2mono) ysize(2.5) ysc(r(-.2 .1)) ytitle("Estimated Relative Change, +/- 2 SE") ylabel(-.2 -.15 -.1 -.05 0 .05 .1, nogrid) xsize(2) xtitle(Woodland Level) xlabel(0 .02 .04 .06 .08 .10 .12, nogrid) graphregion(fcolor(white) lstyle(solid)) legend(off))
graph save Figure5_b, replace

twoway (line coef level if year==1900, clcolor(black) clpat(solid)) (line max level if year==1900, clcolor(black) clpat(dash)) (line min level if year==1900, clcolor(black) clpat(dash) title("From  1890  To  1900") scheme(s2mono) ysize(2.5) ysc(r(-.2 .1)) ytitle("Estimated Relative Change, +/- 2 SE") ylabel(-.2 -.15 -.1 -.05 0 .05 .1, nogrid) xsize(2) xtitle(Woodland Level) xlabel(0 .02 .04 .06 .08 .10 .12, nogrid) graphregion(fcolor(white) lstyle(solid)) legend(off))
graph save Figure5_c, replace

twoway (line coef level if year==1910, clcolor(black) clpat(solid)) (line max level if year==1910, clcolor(black) clpat(dash)) (line min level if year==1910, clcolor(black) clpat(dash) title("From  1900  To  1910") scheme(s2mono) ysize(2.5) ysc(r(-.2 .1)) ytitle("Estimated Relative Change, +/- 2 SE") ylabel(-.2 -.15 -.1 -.05 0 .05 .1, nogrid) xsize(2) xtitle(Woodland Level) xlabel(0 .02 .04 .06 .08 .10 .12, nogrid) graphregion(fcolor(white) lstyle(solid)) legend(off))
graph save Figure5_d, replace




