/*
Date:  Feb 1, 2010
Author:  Richard Hornbeck
Compatibility:  Stata 11

This do file replicates datasets for "Barbed Wire:  Property Rights and Agricultural Development" by Richard Hornbeck, 2010 QJE.

While the analysis originally used a web extract from the Great Plains Project (http://enceladus.icpsr.umich.edu/GPDB/), this file replicates the dataset from the ICPSR analog (04254).  These files appear to be mostly identical, but one noticed large difference concerns measurement of cattle stocks in 1900, which has been adjusted to follow the web extract (otherwise many counties are missing cattle data in 1900).
*/


clear
set mem 200m
set matsize 800
set more off

tempfile 1870 1880 1890_1 1890 1900_1 1900 1910_1 1910 1920 merged1920base1870 merged1910base1870 merged1900base1870 merged1890base1870 merged1880base1870 merged1920base1880 merged1910base1880 merged1900base1880 merged1890base1880 

***
*Create temporary dataset for 1870
***
use 04254-0001-Data.dta
*Run code to put in missing values
replace BAR_XH_B = . if (BAR_XH_B >= -15 & BAR_XH_B <= -1)
replace BWT_XH_B = . if (BWT_XH_B >= -15 & BWT_XH_B <= -1)
replace FLX_XH_P = . if (FLX_XH_P >= -15 & FLX_XH_P <= -1)
replace FLX_XH_B = . if (FLX_XH_B >= -15 & FLX_XH_B <= -1)
replace COT_XH_C = . if (COT_XH_C >= -15 & COT_XH_C <= -1)
replace PAB_XH_B = . if (PAB_XH_B >= -15 & PAB_XH_B <= -1)
replace FML_XX_A = . if (FML_XX_A >= -15 & FML_XX_A <= -1)
replace IML_XX_A = . if (IML_XX_A >= -15 & IML_XX_A <= -1)
replace UNL_XX_A = . if (UNL_XX_A >= -15 & UNL_XX_A <= -1)
replace WOD_XX_A = . if (WOD_XX_A >= -15 & WOD_XX_A <= -1)
replace UNL_XO_A = . if (UNL_XO_A >= -15 & UNL_XO_A <= -1)
replace ARE_XX_A = . if (ARE_XX_A >= -15 & ARE_XX_A <= -1)
replace FRM_XX_Q = . if (FRM_XX_Q >= -15 & FRM_XX_Q <= -1)
replace PRP_XX_V = . if (PRP_XX_V >= -15 & PRP_XX_V <= -1)
replace IMP_XX_V = . if (IMP_XX_V >= -15 & IMP_XX_V <= -1)
replace AFP_XX_V = . if (AFP_XX_V >= -15 & AFP_XX_V <= -1)
replace FRU_XX_V = . if (FRU_XX_V >= -15 & FRU_XX_V <= -1)
replace GDN_XX_V = . if (GDN_XX_V >= -15 & GDN_XX_V <= -1)
replace FST_XX_V = . if (FST_XX_V >= -15 & FST_XX_V <= -1)
replace STK_XR_V = . if (STK_XR_V >= -15 & STK_XR_V <= -1)
replace STK_XX_V = . if (STK_XX_V >= -15 & STK_XX_V <= -1)
keep NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V FST_XX_V
order NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V FST_XX_V
gen YEAR=1870
destring UNFIPS, replace
drop if UNFIPS==48327&FML_XX_A==.
sort UNFIPS
save `1870', replace
clear

*Create temporary dataset for 1880
use 04254-0002-Data.dta
*Run code to put in missing values
replace BAR_XH_A = . if (BAR_XH_A >= -15 & BAR_XH_A <= -1)
replace BAR_XH_B = . if (BAR_XH_B >= -15 & BAR_XH_B <= -1)
replace BWT_XH_A = . if (BWT_XH_A >= -15 & BWT_XH_A <= -1)
replace BWT_XH_B = . if (BWT_XH_B >= -15 & BWT_XH_B <= -1)
replace OAT_XH_A = . if (OAT_XH_A >= -15 & OAT_XH_A <= -1)
replace OAT_XH_B = . if (OAT_XH_B >= -15 & OAT_XH_B <= -1)
replace RYE_XH_A = . if (RYE_XH_A >= -15 & RYE_XH_A <= -1)
replace RYE_XH_B = . if (RYE_XH_B >= -15 & RYE_XH_B <= -1)
replace WHT_XH_A = . if (WHT_XH_A >= -15 & WHT_XH_A <= -1)
replace WHT_XH_B = . if (WHT_XH_B >= -15 & WHT_XH_B <= -1)
replace FLX_XH_B = . if (FLX_XH_B >= -15 & FLX_XH_B <= -1)
replace HAY_XH_A = . if (HAY_XH_A >= -15 & HAY_XH_A <= -1)
replace HAY_XH_T = . if (HAY_XH_T >= -15 & HAY_XH_T <= -1)
replace CRN_GH_A = . if (CRN_GH_A >= -15 & CRN_GH_A <= -1)
replace CRN_GH_B = . if (CRN_GH_B >= -15 & CRN_GH_B <= -1)
replace COT_XH_A = . if (COT_XH_A >= -15 & COT_XH_A <= -1)
replace COT_XH_C = . if (COT_XH_C >= -15 & COT_XH_C <= -1)
replace SRG_MH_G = . if (SRG_MH_G >= -15 & SRG_MH_G <= -1)
replace SRG_MH_P = . if (SRG_MH_P >= -15 & SRG_MH_P <= -1)
replace POT_XH_B = . if (POT_XH_B >= -15 & POT_XH_B <= -1)
replace BCN_XH_P = . if (BCN_XH_P >= -15 & BCN_XH_P <= -1)
replace PEA_XH_B = . if (PEA_XH_B >= -15 & PEA_XH_B <= -1)
replace BEA_XH_B = . if (BEA_XH_B >= -15 & BEA_XH_B <= -1)
replace FRM_XX_Q = . if (FRM_XX_Q >= -15 & FRM_XX_Q <= -1)
replace FRM_SA_Q = . if (FRM_SA_Q >= -15 & FRM_SA_Q <= -1)
replace FRM_SB_Q = . if (FRM_SB_Q >= -15 & FRM_SB_Q <= -1)
replace FRM_SC_Q = . if (FRM_SC_Q >= -15 & FRM_SC_Q <= -1)
replace FRM_SD_Q = . if (FRM_SD_Q >= -15 & FRM_SD_Q <= -1)
replace FRM_SE_Q = . if (FRM_SE_Q >= -15 & FRM_SE_Q <= -1)
replace FRM_UH_Q = . if (FRM_UH_Q >= -15 & FRM_UH_Q <= -1)
replace FRM_SI_Q = . if (FRM_SI_Q >= -15 & FRM_SI_Q <= -1)
replace FRM_SL_Q = . if (FRM_SL_Q >= -15 & FRM_SL_Q <= -1)
replace SIZ_AX_A = . if (SIZ_AX_A >= -15 & SIZ_AX_A <= -1)
replace FRM_OF_Q = . if (FRM_OF_Q >= -15 & FRM_OF_Q <= -1)
replace FRM_TC_Q = . if (FRM_TC_Q >= -15 & FRM_TC_Q <= -1)
replace FRM_TQ_Q = . if (FRM_TQ_Q >= -15 & FRM_TQ_Q <= -1)
replace FML_XX_A = . if (FML_XX_A >= -15 & FML_XX_A <= -1)
replace IML_XX_A = . if (IML_XX_A >= -15 & IML_XX_A <= -1)
replace CRP_XX_A = . if (CRP_XX_A >= -15 & CRP_XX_A <= -1)
replace PST_XV_A = . if (PST_XV_A >= -15 & PST_XV_A <= -1)
replace UNL_XX_A = . if (UNL_XX_A >= -15 & UNL_XX_A <= -1)
replace WOD_XX_A = . if (WOD_XX_A >= -15 & WOD_XX_A <= -1)
replace UNL_XO_A = . if (UNL_XO_A >= -15 & UNL_XO_A <= -1)
replace ARE_XX_A = . if (ARE_XX_A >= -15 & ARE_XX_A <= -1)
replace PRP_XX_V = . if (PRP_XX_V >= -15 & PRP_XX_V <= -1)
replace IMP_XX_V = . if (IMP_XX_V >= -15 & IMP_XX_V <= -1)
replace FEN_XX_V = . if (FEN_XX_V >= -15 & FEN_XX_V <= -1)
replace FRT_XX_V = . if (FRT_XX_V >= -15 & FRT_XX_V <= -1)
replace POL_CX_Q = . if (POL_CX_Q >= -15 & POL_CX_Q <= -1)
replace POL_DX_Q = . if (POL_DX_Q >= -15 & POL_DX_Q <= -1)
replace POL_XX_Q = . if (POL_XX_Q >= -15 & POL_XX_Q <= -1)
replace EGG_XX_D = . if (EGG_XX_D >= -15 & EGG_XX_D <= -1)
replace HON_XX_P = . if (HON_XX_P >= -15 & HON_XX_P <= -1)
replace WOL_XX_F = . if (WOL_XX_F >= -15 & WOL_XX_F <= -1)
replace WOL_XX_P = . if (WOL_XX_P >= -15 & WOL_XX_P <= -1)
replace HRS_XX_Q = . if (HRS_XX_Q >= -15 & HRS_XX_Q <= -1)
replace MUL_XG_Q = . if (MUL_XG_Q >= -15 & MUL_XG_Q <= -1)
replace CTL_OX_Q = . if (CTL_OX_Q >= -15 & CTL_OX_Q <= -1)
replace CTL_MX_Q = . if (CTL_MX_Q >= -15 & CTL_MX_Q <= -1)
replace CTL_GX_Q = . if (CTL_GX_Q >= -15 & CTL_GX_Q <= -1)
replace CTL_XX_Q = . if (CTL_XX_Q >= -15 & CTL_XX_Q <= -1)
replace SHP_XX_Q = . if (SHP_XX_Q >= -15 & SHP_XX_Q <= -1)
replace SWN_XX_Q = . if (SWN_XX_Q >= -15 & SWN_XX_Q <= -1)
replace MLK_TX_G = . if (MLK_TX_G >= -15 & MLK_TX_G <= -1)
replace BUT_XX_P = . if (BUT_XX_P >= -15 & BUT_XX_P <= -1)
replace CHS_XX_P = . if (CHS_XX_P >= -15 & CHS_XX_P <= -1)
replace GDN_TX_V = . if (GDN_TX_V >= -15 & GDN_TX_V <= -1)
replace STK_XX_V = . if (STK_XX_V >= -15 & STK_XX_V <= -1)
replace AFP_XX_V = . if (AFP_XX_V >= -15 & AFP_XX_V <= -1)

keep NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V FEN_XX_V CTL_XX_Q CRP_XX_A BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C
order NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V FEN_XX_V CTL_XX_Q CRP_XX_A BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C
gen YEAR=1880
destring UNFIPS, replace
sort UNFIPS
save `1880', replace
clear


*Create temporary dataset for 1890
use 04254-0003-Data.dta
*Run code to put in missing values
replace CER_XH_A = . if (CER_XH_A >= -15 & CER_XH_A <= -1)
replace BAR_XH_A = . if (BAR_XH_A >= -15 & BAR_XH_A <= -1)
replace BAR_XH_B = . if (BAR_XH_B >= -15 & BAR_XH_B <= -1)
replace BWT_XH_A = . if (BWT_XH_A >= -15 & BWT_XH_A <= -1)
replace BWT_XH_B = . if (BWT_XH_B >= -15 & BWT_XH_B <= -1)
replace OAT_XH_A = . if (OAT_XH_A >= -15 & OAT_XH_A <= -1)
replace OAT_XH_B = . if (OAT_XH_B >= -15 & OAT_XH_B <= -1)
replace RYE_XH_A = . if (RYE_XH_A >= -15 & RYE_XH_A <= -1)
replace RYE_XH_B = . if (RYE_XH_B >= -15 & RYE_XH_B <= -1)
replace WHT_XH_A = . if (WHT_XH_A >= -15 & WHT_XH_A <= -1)
replace WHT_XH_B = . if (WHT_XH_B >= -15 & WHT_XH_B <= -1)
replace FLX_XH_A = . if (FLX_XH_A >= -15 & FLX_XH_A <= -1)
replace FLX_XH_B = . if (FLX_XH_B >= -15 & FLX_XH_B <= -1)
replace HAY_XH_A = . if (HAY_XH_A >= -15 & HAY_XH_A <= -1)
replace HAY_XH_T = . if (HAY_XH_T >= -15 & HAY_XH_T <= -1)
replace CRN_GH_A = . if (CRN_GH_A >= -15 & CRN_GH_A <= -1)
replace CRN_GH_B = . if (CRN_GH_B >= -15 & CRN_GH_B <= -1)
replace COT_XH_A = . if (COT_XH_A >= -15 & COT_XH_A <= -1)
replace COT_XH_C = . if (COT_XH_C >= -15 & COT_XH_C <= -1)
replace SRG_MX_A = . if (SRG_MX_A >= -15 & SRG_MX_A <= -1)
replace BEA_XH_B = . if (BEA_XH_B >= -15 & BEA_XH_B <= -1)
replace PNT_XH_A = . if (PNT_XH_A >= -15 & PNT_XH_A <= -1)
replace PNT_XH_B = . if (PNT_XH_B >= -15 & PNT_XH_B <= -1)
replace POT_XH_A = . if (POT_XH_A >= -15 & POT_XH_A <= -1)
replace POT_XH_B = . if (POT_XH_B >= -15 & POT_XH_B <= -1)
replace POT_ZH_A = . if (POT_ZH_A >= -15 & POT_ZH_A <= -1)
replace POT_ZH_B = . if (POT_ZH_B >= -15 & POT_ZH_B <= -1)
replace FRM_XX_Q = . if (FRM_XX_Q >= -15 & FRM_XX_Q <= -1)
replace FRM_SR_Q = . if (FRM_SR_Q >= -15 & FRM_SR_Q <= -1)
replace FRM_SC_Q = . if (FRM_SC_Q >= -15 & FRM_SC_Q <= -1)
replace FRM_SD_Q = . if (FRM_SD_Q >= -15 & FRM_SD_Q <= -1)
replace FRM_SE_Q = . if (FRM_SE_Q >= -15 & FRM_SE_Q <= -1)
replace FRM_UH_Q = . if (FRM_UH_Q >= -15 & FRM_UH_Q <= -1)
replace FRM_SI_Q = . if (FRM_SI_Q >= -15 & FRM_SI_Q <= -1)
replace FRM_SL_Q = . if (FRM_SL_Q >= -15 & FRM_SL_Q <= -1)
replace SIZ_AX_A = . if (SIZ_AX_A >= -15 & SIZ_AX_A <= -1)
replace FRM_OF_Q = . if (FRM_OF_Q >= -15 & FRM_OF_Q <= -1)
replace FRM_TC_Q = . if (FRM_TC_Q >= -15 & FRM_TC_Q <= -1)
replace FRM_TQ_Q = . if (FRM_TQ_Q >= -15 & FRM_TQ_Q <= -1)
replace FML_XX_A = . if (FML_XX_A >= -15 & FML_XX_A <= -1)
replace IML_XX_A = . if (IML_XX_A >= -15 & IML_XX_A <= -1)
replace UNL_XX_A = . if (UNL_XX_A >= -15 & UNL_XX_A <= -1)
replace FML_IX_A = . if (FML_IX_A >= -15 & FML_IX_A <= -1)
replace FRM_IX_Q = . if (FRM_IX_Q >= -15 & FRM_IX_Q <= -1)
replace ARE_XX_A = . if (ARE_XX_A >= -15 & ARE_XX_A <= -1)
replace PRP_XX_V = . if (PRP_XX_V >= -15 & PRP_XX_V <= -1)
replace IMP_XX_V = . if (IMP_XX_V >= -15 & IMP_XX_V <= -1)
replace FRT_XX_V = . if (FRT_XX_V >= -15 & FRT_XX_V <= -1)
replace CTL_XX_Q = . if (CTL_XX_Q >= -15 & CTL_XX_Q <= -1)
replace CTL_MX_Q = . if (CTL_MX_Q >= -15 & CTL_MX_Q <= -1)
replace CTL_XS_Q = . if (CTL_XS_Q >= -15 & CTL_XS_Q <= -1)
replace MLK_XX_G = . if (MLK_XX_G >= -15 & MLK_XX_G <= -1)
replace BUT_XX_P = . if (BUT_XX_P >= -15 & BUT_XX_P <= -1)
replace CHS_XX_P = . if (CHS_XX_P >= -15 & CHS_XX_P <= -1)
replace HRS_XX_Q = . if (HRS_XX_Q >= -15 & HRS_XX_Q <= -1)
replace SWN_XX_Q = . if (SWN_XX_Q >= -15 & SWN_XX_Q <= -1)
replace SHP_XX_Q = . if (SHP_XX_Q >= -15 & SHP_XX_Q <= -1)
replace SHP_XS_Q = . if (SHP_XS_Q >= -15 & SHP_XS_Q <= -1)
replace WOL_XX_F = . if (WOL_XX_F >= -15 & WOL_XX_F <= -1)
replace WOL_XX_P = . if (WOL_XX_P >= -15 & WOL_XX_P <= -1)
replace STK_XX_V = . if (STK_XX_V >= -15 & STK_XX_V <= -1)
replace AFP_XX_V = . if (AFP_XX_V >= -15 & AFP_XX_V <= -1)
keep NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A
order NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A
gen YEAR=1890
destring UNFIPS, replace
drop if UNFIPS==40998
sort UNFIPS
save `1890_1', replace
clear

use 02896-0049-Data.dta
gen county_id = county/10
gen state_id = 8 if state==62
replace state_id = 19 if state==31
replace state_id = 27 if state==33
replace state_id = 20 if state==32
replace state_id = 31 if state==35
replace state_id = 48 if state==49
replace state_id = 30 if state==64
replace state_id = 35 if state==66
replace state_id = 38 if state==36
replace state_id = 40 if state==53
replace state_id = 46 if state==37
replace state_id = 56 if state==68
gen double UNFIPS = state_id*1000+county_id
drop if UNFIPS==.
drop if county_id==0
keep UNFIPS farmval
sort UNFIPS
merge UNFIPS using `1890_1', unique
drop _merge
sort UNFIPS
save `1890', replace
clear

*Create temporary dataset for 1900
use 04254-0004-Data.dta
*Run code to put in missing values
replace HAY_XH_T = . if (HAY_XH_T >= -15 & HAY_XH_T <= -1)
replace HAY_XH_A = . if (HAY_XH_A >= -15 & HAY_XH_A <= -1)
replace HAY_KT_A = . if (HAY_KT_A >= -15 & HAY_KT_A <= -1)
replace HAY_KT_T = . if (HAY_KT_T >= -15 & HAY_KT_T <= -1)
replace HAY_KV_A = . if (HAY_KV_A >= -15 & HAY_KV_A <= -1)
replace HAY_KV_T = . if (HAY_KV_T >= -15 & HAY_KV_T <= -1)
replace HAY_KL_A = . if (HAY_KL_A >= -15 & HAY_KL_A <= -1)
replace HAY_KL_T = . if (HAY_KL_T >= -15 & HAY_KL_T <= -1)
replace HAY_KR_A = . if (HAY_KR_A >= -15 & HAY_KR_A <= -1)
replace HAY_KR_T = . if (HAY_KR_T >= -15 & HAY_KR_T <= -1)
replace HAY_KW_T = . if (HAY_KW_T >= -15 & HAY_KW_T <= -1)
replace HAY_KW_A = . if (HAY_KW_A >= -15 & HAY_KW_A <= -1)
replace HAY_KY_T = . if (HAY_KY_T >= -15 & HAY_KY_T <= -1)
replace HAY_KY_A = . if (HAY_KY_A >= -15 & HAY_KY_A <= -1)
replace CRO_FP_T = . if (CRO_FP_T >= -15 & CRO_FP_T <= -1)
replace CRO_FP_A = . if (CRO_FP_A >= -15 & CRO_FP_A <= -1)
replace FLX_XH_A = . if (FLX_XH_A >= -15 & FLX_XH_A <= -1)
replace FLX_XH_B = . if (FLX_XH_B >= -15 & FLX_XH_B <= -1)
replace BAR_XH_A = . if (BAR_XH_A >= -15 & BAR_XH_A <= -1)
replace BAR_XH_B = . if (BAR_XH_B >= -15 & BAR_XH_B <= -1)
replace BWT_XH_B = . if (BWT_XH_B >= -15 & BWT_XH_B <= -1)
replace BWT_XH_A = . if (BWT_XH_A >= -15 & BWT_XH_A <= -1)
replace OAT_XH_B = . if (OAT_XH_B >= -15 & OAT_XH_B <= -1)
replace OAT_XH_A = . if (OAT_XH_A >= -15 & OAT_XH_A <= -1)
replace RYE_XH_A = . if (RYE_XH_A >= -15 & RYE_XH_A <= -1)
replace RYE_XH_B = . if (RYE_XH_B >= -15 & RYE_XH_B <= -1)
replace WHT_XH_A = . if (WHT_XH_A >= -15 & WHT_XH_A <= -1)
replace WHT_XH_B = . if (WHT_XH_B >= -15 & WHT_XH_B <= -1)
replace COT_XH_A = . if (COT_XH_A >= -15 & COT_XH_A <= -1)
replace COT_XH_C = . if (COT_XH_C >= -15 & COT_XH_C <= -1)
replace BEA_XH_A = . if (BEA_XH_A >= -15 & BEA_XH_A <= -1)
replace BEA_XH_B = . if (BEA_XH_B >= -15 & BEA_XH_B <= -1)
replace PEA_XH_B = . if (PEA_XH_B >= -15 & PEA_XH_B <= -1)
replace PEA_XH_A = . if (PEA_XH_A >= -15 & PEA_XH_A <= -1)
replace PNT_XH_B = . if (PNT_XH_B >= -15 & PNT_XH_B <= -1)
replace PNT_XH_A = . if (PNT_XH_A >= -15 & PNT_XH_A <= -1)
replace SRG_MH_A = . if (SRG_MH_A >= -15 & SRG_MH_A <= -1)
replace BET_XH_T = . if (BET_XH_T >= -15 & BET_XH_T <= -1)
replace BET_XH_A = . if (BET_XH_A >= -15 & BET_XH_A <= -1)
replace VEG_XH_A = . if (VEG_XH_A >= -15 & VEG_XH_A <= -1)
replace POT_XH_B = . if (POT_XH_B >= -15 & POT_XH_B <= -1)
replace POT_XH_A = . if (POT_XH_A >= -15 & POT_XH_A <= -1)
replace CRN_GH_B = . if (CRN_GH_B >= -15 & CRN_GH_B <= -1)
replace CRN_GH_A = . if (CRN_GH_A >= -15 & CRN_GH_A <= -1)
replace SRG_GH_A = . if (SRG_GH_A >= -15 & SRG_GH_A <= -1)
replace SRG_GH_B = . if (SRG_GH_B >= -15 & SRG_GH_B <= -1)
replace FRM_XX_Q = . if (FRM_XX_Q >= -15 & FRM_XX_Q <= -1)
replace SIZ_AX_A = . if (SIZ_AX_A >= -15 & SIZ_AX_A <= -1)
replace FRM_SA_Q = . if (FRM_SA_Q >= -15 & FRM_SA_Q <= -1)
replace FRM_SB_Q = . if (FRM_SB_Q >= -15 & FRM_SB_Q <= -1)
replace FRM_SC_Q = . if (FRM_SC_Q >= -15 & FRM_SC_Q <= -1)
replace FRM_SD_Q = . if (FRM_SD_Q >= -15 & FRM_SD_Q <= -1)
replace FRM_SE_Q = . if (FRM_SE_Q >= -15 & FRM_SE_Q <= -1)
replace FRM_SF_Q = . if (FRM_SF_Q >= -15 & FRM_SF_Q <= -1)
replace FRM_SG_Q = . if (FRM_SG_Q >= -15 & FRM_SG_Q <= -1)
replace FRM_SH_Q = . if (FRM_SH_Q >= -15 & FRM_SH_Q <= -1)
replace FRM_SI_Q = . if (FRM_SI_Q >= -15 & FRM_SI_Q <= -1)
replace FRM_SL_Q = . if (FRM_SL_Q >= -15 & FRM_SL_Q <= -1)
replace FRM_OX_Q = . if (FRM_OX_Q >= -15 & FRM_OX_Q <= -1)
replace FRM_OP_Q = . if (FRM_OP_Q >= -15 & FRM_OP_Q <= -1)
replace FRM_MX_Q = . if (FRM_MX_Q >= -15 & FRM_MX_Q <= -1)
replace FRM_TC_Q = . if (FRM_TC_Q >= -15 & FRM_TC_Q <= -1)
replace FRM_TT_Q = . if (FRM_TT_Q >= -15 & FRM_TT_Q <= -1)
replace FRM_XW_Q = . if (FRM_XW_Q >= -15 & FRM_XW_Q <= -1)
replace FRM_OW_Q = . if (FRM_OW_Q >= -15 & FRM_OW_Q <= -1)
replace FRM_MW_Q = . if (FRM_MW_Q >= -15 & FRM_MW_Q <= -1)
replace FRM_XN_Q = . if (FRM_XN_Q >= -15 & FRM_XN_Q <= -1)
replace FRM_ON_Q = . if (FRM_ON_Q >= -15 & FRM_ON_Q <= -1)
replace FRM_MN_Q = . if (FRM_MN_Q >= -15 & FRM_MN_Q <= -1)
replace FRM_BX_Q = . if (FRM_BX_Q >= -15 & FRM_BX_Q <= -1)
replace FML_XX_A = . if (FML_XX_A >= -15 & FML_XX_A <= -1)
replace IML_XX_A = . if (IML_XX_A >= -15 & IML_XX_A <= -1)
replace UNL_XX_A = . if (UNL_XX_A >= -15 & UNL_XX_A <= -1)
replace ARE_XX_A = . if (ARE_XX_A >= -15 & ARE_XX_A <= -1)
replace IMP_XX_V = . if (IMP_XX_V >= -15 & IMP_XX_V <= -1)
replace LAB_XX_V = . if (LAB_XX_V >= -15 & LAB_XX_V <= -1)
replace FRT_BX_V = . if (FRT_BX_V >= -15 & FRT_BX_V <= -1)
replace CTL_XU_Q = . if (CTL_XU_Q >= -15 & CTL_XU_Q <= -1)
replace CTL_SV_Q = . if (CTL_SV_Q >= -15 & CTL_SV_Q <= -1)
replace CTL_ST_Q = . if (CTL_ST_Q >= -15 & CTL_ST_Q <= -1)
replace CTL_SX_Q = . if (CTL_SX_Q >= -15 & CTL_SX_Q <= -1)
replace CTL_BX_Q = . if (CTL_BX_Q >= -15 & CTL_BX_Q <= -1)
replace CTL_HV_Q = . if (CTL_HV_Q >= -15 & CTL_HV_Q <= -1)
replace CTL_MX_Q = . if (CTL_MX_Q >= -15 & CTL_MX_Q <= -1)
replace CTL_LX_Q = . if (CTL_LX_Q >= -15 & CTL_LX_Q <= -1)
replace CTL_XX_Q = . if (CTL_XX_Q >= -15 & CTL_XX_Q <= -1)
replace HRS_XU_Q = . if (HRS_XU_Q >= -15 & HRS_XU_Q <= -1)
replace HRS_XV_Q = . if (HRS_XV_Q >= -15 & HRS_XV_Q <= -1)
replace HRS_XW_Q = . if (HRS_XW_Q >= -15 & HRS_XW_Q <= -1)
replace HRS_XX_Q = . if (HRS_XX_Q >= -15 & HRS_XX_Q <= -1)
replace MUL_XU_Q = . if (MUL_XU_Q >= -15 & MUL_XU_Q <= -1)
replace MUL_XV_Q = . if (MUL_XV_Q >= -15 & MUL_XV_Q <= -1)
replace MUL_XW_Q = . if (MUL_XW_Q >= -15 & MUL_XW_Q <= -1)
replace MUL_XX_Q = . if (MUL_XX_Q >= -15 & MUL_XX_Q <= -1)
replace SHP_XU_Q = . if (SHP_XU_Q >= -15 & SHP_XU_Q <= -1)
replace SHP_EX_Q = . if (SHP_EX_Q >= -15 & SHP_EX_Q <= -1)
replace SHP_RX_Q = . if (SHP_RX_Q >= -15 & SHP_RX_Q <= -1)
replace SHP_XX_Q = . if (SHP_XX_Q >= -15 & SHP_XX_Q <= -1)
replace SWN_XX_Q = . if (SWN_XX_Q >= -15 & SWN_XX_Q <= -1)
replace CTL_XN_Q = . if (CTL_XN_Q >= -15 & CTL_XN_Q <= -1)
replace HRS_XN_Q = . if (HRS_XN_Q >= -15 & HRS_XN_Q <= -1)
replace SWN_XN_Q = . if (SWN_XN_Q >= -15 & SWN_XN_Q <= -1)
replace MLK_XX_G = . if (MLK_XX_G >= -15 & MLK_XX_G <= -1)
replace BUT_XX_P = . if (BUT_XX_P >= -15 & BUT_XX_P <= -1)
replace CHS_XX_P = . if (CHS_XX_P >= -15 & CHS_XX_P <= -1)
replace CHK_XX_Q = . if (CHK_XX_Q >= -15 & CHK_XX_Q <= -1)
replace EGG_XX_D = . if (EGG_XX_D >= -15 & EGG_XX_D <= -1)
replace WOL_XX_F = . if (WOL_XX_F >= -15 & WOL_XX_F <= -1)
replace WOL_XX_P = . if (WOL_XX_P >= -15 & WOL_XX_P <= -1)
replace FML_XX_V = . if (FML_XX_V >= -15 & FML_XX_V <= -1)
replace BLD_XX_V = . if (BLD_XX_V >= -15 & BLD_XX_V <= -1)
replace STK_XX_V = . if (STK_XX_V >= -15 & STK_XX_V <= -1)
replace AFP_XQ_V = . if (AFP_XQ_V >= -15 & AFP_XQ_V <= -1)

*ICPSR 4254 differs from the original web extract used, obtained from http://enceladus.icpsr.umich.edu/GPDB/
*Correct cattle and flax variables in 1900 (only differences noticed)
*Other slight differences in extracts and rounding of variables create slight rounding differences in the final results (original results published)
drop CTL_XX_Q FLX_XH_A
destring UNFIPS, replace
sort UNFIPS
merge UNFIPS using 1900_webextract.dta
keep if _merge==3
drop _merge

keep NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A
order NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A
gen YEAR=1900
sort UNFIPS
save `1900_1', replace
clear

use 02896-0050-Data.dta
gen county_id = county/10
gen state_id = 8 if state==62
replace state_id = 19 if state==31
replace state_id = 27 if state==33
replace state_id = 20 if state==32
replace state_id = 31 if state==35
replace state_id = 48 if state==49
replace state_id = 30 if state==64
replace state_id = 35 if state==66
replace state_id = 38 if state==36
replace state_id = 40 if state==53
replace state_id = 46 if state==37
replace state_id = 56 if state==68
gen double UNFIPS = state_id*1000+county_id
drop if UNFIPS ==.
drop if county_id==0
keep UNFIPS farmval farmbui
sort UNFIPS
merge UNFIPS using `1900_1', unique
drop _merge
sort UNFIPS
save `1900', replace
clear


*Create temporary dataset for 1910
use 04254-0005-Data.dta
*Run code to put in missing values
replace OAT_XH_A = . if (OAT_XH_A >= -15 & OAT_XH_A <= -1)
replace OAT_XH_B = . if (OAT_XH_B >= -15 & OAT_XH_B <= -1)
replace WHT_XH_A = . if (WHT_XH_A >= -15 & WHT_XH_A <= -1)
replace WHT_XH_B = . if (WHT_XH_B >= -15 & WHT_XH_B <= -1)
replace EMM_XH_A = . if (EMM_XH_A >= -15 & EMM_XH_A <= -1)
replace EMM_XH_B = . if (EMM_XH_B >= -15 & EMM_XH_B <= -1)
replace BAR_XH_A = . if (BAR_XH_A >= -15 & BAR_XH_A <= -1)
replace BAR_XH_B = . if (BAR_XH_B >= -15 & BAR_XH_B <= -1)
replace BWT_XH_A = . if (BWT_XH_A >= -15 & BWT_XH_A <= -1)
replace BWT_XH_B = . if (BWT_XH_B >= -15 & BWT_XH_B <= -1)
replace RYE_XH_A = . if (RYE_XH_A >= -15 & RYE_XH_A <= -1)
replace RYE_XH_B = . if (RYE_XH_B >= -15 & RYE_XH_B <= -1)
replace FLX_XH_A = . if (FLX_XH_A >= -15 & FLX_XH_A <= -1)
replace FLX_XH_B = . if (FLX_XH_B >= -15 & FLX_XH_B <= -1)
replace HAY_XH_A = . if (HAY_XH_A >= -15 & HAY_XH_A <= -1)
replace HAY_XH_T = . if (HAY_XH_T >= -15 & HAY_XH_T <= -1)
replace HAY_AH_A = . if (HAY_AH_A >= -15 & HAY_AH_A <= -1)
replace HAY_KQ_A = . if (HAY_KQ_A >= -15 & HAY_KQ_A <= -1)
replace HAY_KS_A = . if (HAY_KS_A >= -15 & HAY_KS_A <= -1)
replace HAY_KR_A = . if (HAY_KR_A >= -15 & HAY_KR_A <= -1)
replace HAY_KL_A = . if (HAY_KL_A >= -15 & HAY_KL_A <= -1)
replace HAY_KV_A = . if (HAY_KV_A >= -15 & HAY_KV_A <= -1)
replace HAY_KW_A = . if (HAY_KW_A >= -15 & HAY_KW_A <= -1)
replace HAY_KT_A = . if (HAY_KT_A >= -15 & HAY_KT_A <= -1)
replace HAY_KY_A = . if (HAY_KY_A >= -15 & HAY_KY_A <= -1)
replace HAY_KF_A = . if (HAY_KF_A >= -15 & HAY_KF_A <= -1)
replace CRN_GH_A = . if (CRN_GH_A >= -15 & CRN_GH_A <= -1)
replace CRN_GH_B = . if (CRN_GH_B >= -15 & CRN_GH_B <= -1)
replace SRG_KK_A = . if (SRG_KK_A >= -15 & SRG_KK_A <= -1)
replace SRG_KK_B = . if (SRG_KK_B >= -15 & SRG_KK_B <= -1)
replace PEA_XH_A = . if (PEA_XH_A >= -15 & PEA_XH_A <= -1)
replace PEA_XH_B = . if (PEA_XH_B >= -15 & PEA_XH_B <= -1)
replace BEA_XH_A = . if (BEA_XH_A >= -15 & BEA_XH_A <= -1)
replace BEA_XH_B = . if (BEA_XH_B >= -15 & BEA_XH_B <= -1)
replace PNT_XH_A = . if (PNT_XH_A >= -15 & PNT_XH_A <= -1)
replace PNT_XH_B = . if (PNT_XH_B >= -15 & PNT_XH_B <= -1)
replace POT_XH_A = . if (POT_XH_A >= -15 & POT_XH_A <= -1)
replace POT_XH_B = . if (POT_XH_B >= -15 & POT_XH_B <= -1)
replace VEG_XH_A = . if (VEG_XH_A >= -15 & VEG_XH_A <= -1)
replace COT_XH_A = . if (COT_XH_A >= -15 & COT_XH_A <= -1)
replace COT_XH_C = . if (COT_XH_C >= -15 & COT_XH_C <= -1)
replace BET_XH_A = . if (BET_XH_A >= -15 & BET_XH_A <= -1)
replace BET_XH_T = . if (BET_XH_T >= -15 & BET_XH_T <= -1)
replace SRG_MH_A = . if (SRG_MH_A >= -15 & SRG_MH_A <= -1)
replace SRG_MH_T = . if (SRG_MH_T >= -15 & SRG_MH_T <= -1)
replace FRM_XX_Q = . if (FRM_XX_Q >= -15 & FRM_XX_Q <= -1)
replace FRM_NW_Q = . if (FRM_NW_Q >= -15 & FRM_NW_Q <= -1)
replace FRM_LW_Q = . if (FRM_LW_Q >= -15 & FRM_LW_Q <= -1)
replace FRM_XN_Q = . if (FRM_XN_Q >= -15 & FRM_XN_Q <= -1)
replace FRM_SA_Q = . if (FRM_SA_Q >= -15 & FRM_SA_Q <= -1)
replace FRM_SB_Q = . if (FRM_SB_Q >= -15 & FRM_SB_Q <= -1)
replace FRM_SC_Q = . if (FRM_SC_Q >= -15 & FRM_SC_Q <= -1)
replace FRM_SD_Q = . if (FRM_SD_Q >= -15 & FRM_SD_Q <= -1)
replace FRM_SE_Q = . if (FRM_SE_Q >= -15 & FRM_SE_Q <= -1)
replace FRM_SF_Q = . if (FRM_SF_Q >= -15 & FRM_SF_Q <= -1)
replace FRM_SG_Q = . if (FRM_SG_Q >= -15 & FRM_SG_Q <= -1)
replace FRM_SH_Q = . if (FRM_SH_Q >= -15 & FRM_SH_Q <= -1)
replace FRM_SI_Q = . if (FRM_SI_Q >= -15 & FRM_SI_Q <= -1)
replace FRM_SL_Q = . if (FRM_SL_Q >= -15 & FRM_SL_Q <= -1)
replace ARE_XX_A = . if (ARE_XX_A >= -15 & ARE_XX_A <= -1)
replace FML_XX_A = . if (FML_XX_A >= -15 & FML_XX_A <= -1)
replace WOD_XX_A = . if (WOD_XX_A >= -15 & WOD_XX_A <= -1)
replace FRM_OF_Q = . if (FRM_OF_Q >= -15 & FRM_OF_Q <= -1)
replace FRM_OB_Q = . if (FRM_OB_Q >= -15 & FRM_OB_Q <= -1)
replace FRM_OP_Q = . if (FRM_OP_Q >= -15 & FRM_OP_Q <= -1)
replace FML_OF_A = . if (FML_OF_A >= -15 & FML_OF_A <= -1)
replace IML_OF_A = . if (IML_OF_A >= -15 & IML_OF_A <= -1)
replace FRM_ON_Q = . if (FRM_ON_Q >= -15 & FRM_ON_Q <= -1)
replace FRM_TX_Q = . if (FRM_TX_Q >= -15 & FRM_TX_Q <= -1)
replace FML_TX_A = . if (FML_TX_A >= -15 & FML_TX_A <= -1)
replace IML_TX_A = . if (IML_TX_A >= -15 & IML_TX_A <= -1)
replace FRM_TQ_Q = . if (FRM_TQ_Q >= -15 & FRM_TQ_Q <= -1)
replace FRM_TH_Q = . if (FRM_TH_Q >= -15 & FRM_TH_Q <= -1)
replace FRM_TC_Q = . if (FRM_TC_Q >= -15 & FRM_TC_Q <= -1)
replace FRM_TU_Q = . if (FRM_TU_Q >= -15 & FRM_TU_Q <= -1)
replace FRM_TN_Q = . if (FRM_TN_Q >= -15 & FRM_TN_Q <= -1)
replace FRM_MX_Q = . if (FRM_MX_Q >= -15 & FRM_MX_Q <= -1)
replace FML_MX_A = . if (FML_MX_A >= -15 & FML_MX_A <= -1)
replace IML_MX_A = . if (IML_MX_A >= -15 & IML_MX_A <= -1)
replace FRM_IX_Q = . if (FRM_IX_Q >= -15 & FRM_IX_Q <= -1)
replace FML_IX_A = . if (FML_IX_A >= -15 & FML_IX_A <= -1)
replace IMP_XX_V = . if (IMP_XX_V >= -15 & IMP_XX_V <= -1)
replace PRP_OF_V = . if (PRP_OF_V >= -15 & PRP_OF_V <= -1)
replace PRP_TX_V = . if (PRP_TX_V >= -15 & PRP_TX_V <= -1)
replace PRP_MX_V = . if (PRP_MX_V >= -15 & PRP_MX_V <= -1)
replace FRT_RX_Q = . if (FRT_RX_Q >= -15 & FRT_RX_Q <= -1)
replace FRT_BX_V = . if (FRT_BX_V >= -15 & FRT_BX_V <= -1)
replace CTL_XX_Q = . if (CTL_XX_Q >= -15 & CTL_XX_Q <= -1)
replace CTL_MX_Q = . if (CTL_MX_Q >= -15 & CTL_MX_Q <= -1)
replace HRS_XX_Q = . if (HRS_XX_Q >= -15 & HRS_XX_Q <= -1)
replace MUL_XX_Q = . if (MUL_XX_Q >= -15 & MUL_XX_Q <= -1)
replace SWN_XX_Q = . if (SWN_XX_Q >= -15 & SWN_XX_Q <= -1)
replace SHP_XX_Q = . if (SHP_XX_Q >= -15 & SHP_XX_Q <= -1)
replace POL_XX_Q = . if (POL_XX_Q >= -15 & POL_XX_Q <= -1)
replace MLK_XX_G = . if (MLK_XX_G >= -15 & MLK_XX_G <= -1)
replace BUT_XX_P = . if (BUT_XX_P >= -15 & BUT_XX_P <= -1)
replace CHS_XX_P = . if (CHS_XX_P >= -15 & CHS_XX_P <= -1)
replace EGG_XX_D = . if (EGG_XX_D >= -15 & EGG_XX_D <= -1)
replace CTL_XN_Q = . if (CTL_XN_Q >= -15 & CTL_XN_Q <= -1)
replace HRS_XN_Q = . if (HRS_XN_Q >= -15 & HRS_XN_Q <= -1)
replace SWN_XN_Q = . if (SWN_XN_Q >= -15 & SWN_XN_Q <= -1)
replace CRO_XX_V = . if (CRO_XX_V >= -15 & CRO_XX_V <= -1)
replace CER_XX_V = . if (CER_XX_V >= -15 & CER_XX_V <= -1)
replace OGS_XX_V = . if (OGS_XX_V >= -15 & OGS_XX_V <= -1)
replace HAY_XX_V = . if (HAY_XX_V >= -15 & HAY_XX_V <= -1)
replace VEG_XX_V = . if (VEG_XX_V >= -15 & VEG_XX_V <= -1)
replace FRU_XX_V = . if (FRU_XX_V >= -15 & FRU_XX_V <= -1)
replace OFC_XX_V = . if (OFC_XX_V >= -15 & OFC_XX_V <= -1)
egen IML_XX_A = rsum(IML_MX_A IML_OF_A IML_TX_A)
keep NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A
order NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A
gen YEAR=1910
destring UNFIPS, replace
sort UNFIPS
save `1910_1', replace
clear

use 02896-0085-Data.dta
gen county_id = county/10
gen state_id = 8 if state==62
replace state_id = 19 if state==31
replace state_id = 27 if state==33
replace state_id = 20 if state==32
replace state_id = 31 if state==35
replace state_id = 48 if state==49
replace state_id = 30 if state==64
replace state_id = 35 if state==66
replace state_id = 38 if state==36
replace state_id = 40 if state==53
replace state_id = 46 if state==37
replace state_id = 56 if state==68
gen double UNFIPS = state_id*1000+county_id
drop if UNFIPS ==.
drop if county_id==0
keep UNFIPS farmval farmbui
sort UNFIPS
merge UNFIPS using `1910_1', unique
drop _merge
sort UNFIPS
save `1910', replace
clear


*Create temporary dataset for 1920
use 04254-0006-Data.dta
*Run code to put in missing values
replace OAT_XH_A = . if (OAT_XH_A >= -15 & OAT_XH_A <= -1)
replace OAT_XH_B = . if (OAT_XH_B >= -15 & OAT_XH_B <= -1)
replace WHT_XH_A = . if (WHT_XH_A >= -15 & WHT_XH_A <= -1)
replace WHT_XH_B = . if (WHT_XH_B >= -15 & WHT_XH_B <= -1)
replace BAR_XH_A = . if (BAR_XH_A >= -15 & BAR_XH_A <= -1)
replace BAR_XH_B = . if (BAR_XH_B >= -15 & BAR_XH_B <= -1)
replace RYE_XH_A = . if (RYE_XH_A >= -15 & RYE_XH_A <= -1)
replace RYE_XH_B = . if (RYE_XH_B >= -15 & RYE_XH_B <= -1)
replace BWT_XH_A = . if (BWT_XH_A >= -15 & BWT_XH_A <= -1)
replace BWT_XH_B = . if (BWT_XH_B >= -15 & BWT_XH_B <= -1)
replace EMM_XH_A = . if (EMM_XH_A >= -15 & EMM_XH_A <= -1)
replace EMM_XH_B = . if (EMM_XH_B >= -15 & EMM_XH_B <= -1)
replace FLX_XH_A = . if (FLX_XH_A >= -15 & FLX_XH_A <= -1)
replace FLX_XH_B = . if (FLX_XH_B >= -15 & FLX_XH_B <= -1)
replace HAY_XH_A = . if (HAY_XH_A >= -15 & HAY_XH_A <= -1)
replace HAY_XH_T = . if (HAY_XH_T >= -15 & HAY_XH_T <= -1)
replace HAY_KS_A = . if (HAY_KS_A >= -15 & HAY_KS_A <= -1)
replace HAY_KR_A = . if (HAY_KR_A >= -15 & HAY_KR_A <= -1)
replace HAY_KL_A = . if (HAY_KL_A >= -15 & HAY_KL_A <= -1)
replace HAY_KW_A = . if (HAY_KW_A >= -15 & HAY_KW_A <= -1)
replace HAY_KT_A = . if (HAY_KT_A >= -15 & HAY_KT_A <= -1)
replace HAY_KM_A = . if (HAY_KM_A >= -15 & HAY_KM_A <= -1)
replace HAY_KA_A = . if (HAY_KA_A >= -15 & HAY_KA_A <= -1)
replace HAY_KG_A = . if (HAY_KG_A >= -15 & HAY_KG_A <= -1)
replace HAY_KG_T = . if (HAY_KG_T >= -15 & HAY_KG_T <= -1)
replace CRN_AH_A = . if (CRN_AH_A >= -15 & CRN_AH_A <= -1)
replace CRN_GH_A = . if (CRN_GH_A >= -15 & CRN_GH_A <= -1)
replace CRN_GH_B = . if (CRN_GH_B >= -15 & CRN_GH_B <= -1)
replace SRG_AS_A = . if (SRG_AS_A >= -15 & SRG_AS_A <= -1)
replace SRG_KK_A = . if (SRG_KK_A >= -15 & SRG_KK_A <= -1)
replace BEA_XH_A = . if (BEA_XH_A >= -15 & BEA_XH_A <= -1)
replace BEA_XH_B = . if (BEA_XH_B >= -15 & BEA_XH_B <= -1)
replace PEA_XH_A = . if (PEA_XH_A >= -15 & PEA_XH_A <= -1)
replace PEA_XH_B = . if (PEA_XH_B >= -15 & PEA_XH_B <= -1)
replace PNT_XH_A = . if (PNT_XH_A >= -15 & PNT_XH_A <= -1)
replace PNT_XH_B = . if (PNT_XH_B >= -15 & PNT_XH_B <= -1)
replace CRN_FC_A = . if (CRN_FC_A >= -15 & CRN_FC_A <= -1)
replace CRN_FC_T = . if (CRN_FC_T >= -15 & CRN_FC_T <= -1)
replace SRG_FH_A = . if (SRG_FH_A >= -15 & SRG_FH_A <= -1)
replace SRG_FC_T = . if (SRG_FC_T >= -15 & SRG_FC_T <= -1)
replace POT_XH_A = . if (POT_XH_A >= -15 & POT_XH_A <= -1)
replace POT_XH_B = . if (POT_XH_B >= -15 & POT_XH_B <= -1)
replace VEG_XH_A = . if (VEG_XH_A >= -15 & VEG_XH_A <= -1)
replace COT_XH_A = . if (COT_XH_A >= -15 & COT_XH_A <= -1)
replace COT_XH_C = . if (COT_XH_C >= -15 & COT_XH_C <= -1)
replace BET_XH_A = . if (BET_XH_A >= -15 & BET_XH_A <= -1)
replace BET_XH_T = . if (BET_XH_T >= -15 & BET_XH_T <= -1)
replace FRM_XX_Q = . if (FRM_XX_Q >= -15 & FRM_XX_Q <= -1)
replace FRM_XD_Q = . if (FRM_XD_Q >= -15 & FRM_XD_Q <= -1)
replace FRM_XE_Q = . if (FRM_XE_Q >= -15 & FRM_XE_Q <= -1)
replace FRM_NW_Q = . if (FRM_NW_Q >= -15 & FRM_NW_Q <= -1)
replace FRM_LW_Q = . if (FRM_LW_Q >= -15 & FRM_LW_Q <= -1)
replace FRM_XN_Q = . if (FRM_XN_Q >= -15 & FRM_XN_Q <= -1)
replace FRM_SA_Q = . if (FRM_SA_Q >= -15 & FRM_SA_Q <= -1)
replace FRM_SB_Q = . if (FRM_SB_Q >= -15 & FRM_SB_Q <= -1)
replace FRM_SC_Q = . if (FRM_SC_Q >= -15 & FRM_SC_Q <= -1)
replace FRM_SD_Q = . if (FRM_SD_Q >= -15 & FRM_SD_Q <= -1)
replace FRM_SE_Q = . if (FRM_SE_Q >= -15 & FRM_SE_Q <= -1)
replace FRM_SF_Q = . if (FRM_SF_Q >= -15 & FRM_SF_Q <= -1)
replace FRM_SG_Q = . if (FRM_SG_Q >= -15 & FRM_SG_Q <= -1)
replace FRM_SH_Q = . if (FRM_SH_Q >= -15 & FRM_SH_Q <= -1)
replace FRM_SI_Q = . if (FRM_SI_Q >= -15 & FRM_SI_Q <= -1)
replace FRM_SL_Q = . if (FRM_SL_Q >= -15 & FRM_SL_Q <= -1)
replace ARE_XX_A = . if (ARE_XX_A >= -15 & ARE_XX_A <= -1)
replace FML_XX_A = . if (FML_XX_A >= -15 & FML_XX_A <= -1)
replace IML_XX_A = . if (IML_XX_A >= -15 & IML_XX_A <= -1)
replace WOD_XX_A = . if (WOD_XX_A >= -15 & WOD_XX_A <= -1)
replace UNL_XO_A = . if (UNL_XO_A >= -15 & UNL_XO_A <= -1)
replace UNL_XX_A = . if (UNL_XX_A >= -15 & UNL_XX_A <= -1)
replace FRM_OF_Q = . if (FRM_OF_Q >= -15 & FRM_OF_Q <= -1)
replace FML_OF_A = . if (FML_OF_A >= -15 & FML_OF_A <= -1)
replace IML_OF_A = . if (IML_OF_A >= -15 & IML_OF_A <= -1)
replace FRM_OB_Q = . if (FRM_OB_Q >= -15 & FRM_OB_Q <= -1)
replace FRM_OP_Q = . if (FRM_OP_Q >= -15 & FRM_OP_Q <= -1)
replace FRM_ON_Q = . if (FRM_ON_Q >= -15 & FRM_ON_Q <= -1)
replace FRM_MX_Q = . if (FRM_MX_Q >= -15 & FRM_MX_Q <= -1)
replace FML_MX_A = . if (FML_MX_A >= -15 & FML_MX_A <= -1)
replace IML_MX_A = . if (IML_MX_A >= -15 & IML_MX_A <= -1)
replace FRM_TX_Q = . if (FRM_TX_Q >= -15 & FRM_TX_Q <= -1)
replace FML_TX_A = . if (FML_TX_A >= -15 & FML_TX_A <= -1)
replace IML_TX_A = . if (IML_TX_A >= -15 & IML_TX_A <= -1)
replace FRM_TT_Q = . if (FRM_TT_Q >= -15 & FRM_TT_Q <= -1)
replace FRM_TM_Q = . if (FRM_TM_Q >= -15 & FRM_TM_Q <= -1)
replace FRM_TH_Q = . if (FRM_TH_Q >= -15 & FRM_TH_Q <= -1)
replace FRM_TC_Q = . if (FRM_TC_Q >= -15 & FRM_TC_Q <= -1)
replace FRM_TB_Q = . if (FRM_TB_Q >= -15 & FRM_TB_Q <= -1)
replace FRM_TU_Q = . if (FRM_TU_Q >= -15 & FRM_TU_Q <= -1)
replace FRM_TN_Q = . if (FRM_TN_Q >= -15 & FRM_TN_Q <= -1)
replace FRM_IX_Q = . if (FRM_IX_Q >= -15 & FRM_IX_Q <= -1)
replace FML_IX_A = . if (FML_IX_A >= -15 & FML_IX_A <= -1)
replace DRA_EX_Q = . if (DRA_EX_Q >= -15 & DRA_EX_Q <= -1)
replace DRA_ED_A = . if (DRA_ED_A >= -15 & DRA_ED_A <= -1)
replace DRA_EX_A = . if (DRA_EX_A >= -15 & DRA_EX_A <= -1)
replace DRA_EG_A = . if (DRA_EG_A >= -15 & DRA_EG_A <= -1)
replace DRA_KE_A = . if (DRA_KE_A >= -15 & DRA_KE_A <= -1)
replace DRA_WI_A = . if (DRA_WI_A >= -15 & DRA_WI_A <= -1)
replace DRA_WJ_A = . if (DRA_WJ_A >= -15 & DRA_WJ_A <= -1)
replace DRA_WK_A = . if (DRA_WK_A >= -15 & DRA_WK_A <= -1)
replace DRA_WL_A = . if (DRA_WL_A >= -15 & DRA_WL_A <= -1)
replace DRA_WM_A = . if (DRA_WM_A >= -15 & DRA_WM_A <= -1)
replace DRA_WS_A = . if (DRA_WS_A >= -15 & DRA_WS_A <= -1)
replace DRA_QA_A = . if (DRA_QA_A >= -15 & DRA_QA_A <= -1)
replace DRA_QB_A = . if (DRA_QB_A >= -15 & DRA_QB_A <= -1)
replace DRA_QC_A = . if (DRA_QC_A >= -15 & DRA_QC_A <= -1)
replace DRA_QD_A = . if (DRA_QD_A >= -15 & DRA_QD_A <= -1)
replace DRA_QE_A = . if (DRA_QE_A >= -15 & DRA_QE_A <= -1)
replace DRA_QF_A = . if (DRA_QF_A >= -15 & DRA_QF_A <= -1)
replace DRA_QG_A = . if (DRA_QG_A >= -15 & DRA_QG_A <= -1)
replace DRA_QH_A = . if (DRA_QH_A >= -15 & DRA_QH_A <= -1)
replace DRA_QJ_A = . if (DRA_QJ_A >= -15 & DRA_QJ_A <= -1)
replace DRA_QK_A = . if (DRA_QK_A >= -15 & DRA_QK_A <= -1)
replace DRA_QI_A = . if (DRA_QI_A >= -15 & DRA_QI_A <= -1)
replace DRA_QL_A = . if (DRA_QL_A >= -15 & DRA_QL_A <= -1)
replace PRP_XA_V = . if (PRP_XA_V >= -15 & PRP_XA_V <= -1)
replace IMP_XX_V = . if (IMP_XX_V >= -15 & IMP_XX_V <= -1)
replace PRP_OF_V = . if (PRP_OF_V >= -15 & PRP_OF_V <= -1)
replace PRP_MX_V = . if (PRP_MX_V >= -15 & PRP_MX_V <= -1)
replace PRP_TX_V = . if (PRP_TX_V >= -15 & PRP_TX_V <= -1)
replace PRP_XX_V = . if (PRP_XX_V >= -15 & PRP_XX_V <= -1)
replace FRT_RX_Q = . if (FRT_RX_Q >= -15 & FRT_RX_Q <= -1)
replace FRT_XX_V = . if (FRT_XX_V >= -15 & FRT_XX_V <= -1)
replace DRA_WT_M = . if (DRA_WT_M >= -15 & DRA_WT_M <= -1)
replace DRA_IE_H = . if (DRA_IE_H >= -15 & DRA_IE_H <= -1)
replace DRA_JE_G = . if (DRA_JE_G >= -15 & DRA_JE_G <= -1)
replace DRA_WI_M = . if (DRA_WI_M >= -15 & DRA_WI_M <= -1)
replace DRA_WK_M = . if (DRA_WK_M >= -15 & DRA_WK_M <= -1)
replace HRS_XX_Q = . if (HRS_XX_Q >= -15 & HRS_XX_Q <= -1)
replace MUL_XX_Q = . if (MUL_XX_Q >= -15 & MUL_XX_Q <= -1)
replace CTL_XX_Q = . if (CTL_XX_Q >= -15 & CTL_XX_Q <= -1)
replace CTL_HV_Q = . if (CTL_HV_Q >= -15 & CTL_HV_Q <= -1)
replace CTL_MX_Q = . if (CTL_MX_Q >= -15 & CTL_MX_Q <= -1)
replace SHP_XX_Q = . if (SHP_XX_Q >= -15 & SHP_XX_Q <= -1)
replace SWN_XX_Q = . if (SWN_XX_Q >= -15 & SWN_XX_Q <= -1)
replace CHK_XX_Q = . if (CHK_XX_Q >= -15 & CHK_XX_Q <= -1)
replace MLK_XX_G = . if (MLK_XX_G >= -15 & MLK_XX_G <= -1)
replace BUT_XX_P = . if (BUT_XX_P >= -15 & BUT_XX_P <= -1)
replace CHS_XX_P = . if (CHS_XX_P >= -15 & CHS_XX_P <= -1)
replace EGG_XX_D = . if (EGG_XX_D >= -15 & EGG_XX_D <= -1)
replace WOL_XX_P = . if (WOL_XX_P >= -15 & WOL_XX_P <= -1)
replace HRS_XN_Q = . if (HRS_XN_Q >= -15 & HRS_XN_Q <= -1)
replace CTL_XN_Q = . if (CTL_XN_Q >= -15 & CTL_XN_Q <= -1)
replace CTL_MN_Q = . if (CTL_MN_Q >= -15 & CTL_MN_Q <= -1)
replace SHP_XN_Q = . if (SHP_XN_Q >= -15 & SHP_XN_Q <= -1)
replace SWN_XN_Q = . if (SWN_XN_Q >= -15 & SWN_XN_Q <= -1)
replace FML_XX_V = . if (FML_XX_V >= -15 & FML_XX_V <= -1)
replace BLD_XX_V = . if (BLD_XX_V >= -15 & BLD_XX_V <= -1)
replace STK_XX_V = . if (STK_XX_V >= -15 & STK_XX_V <= -1)
replace CRO_XX_V = . if (CRO_XX_V >= -15 & CRO_XX_V <= -1)
replace CER_XX_V = . if (CER_XX_V >= -15 & CER_XX_V <= -1)
replace OGS_XX_V = . if (OGS_XX_V >= -15 & OGS_XX_V <= -1)
replace HAY_XX_V = . if (HAY_XX_V >= -15 & HAY_XX_V <= -1)
replace VEG_XX_V = . if (VEG_XX_V >= -15 & VEG_XX_V <= -1)
replace FRU_XX_V = . if (FRU_XX_V >= -15 & FRU_XX_V <= -1)
replace OFC_XX_V = . if (OFC_XX_V >= -15 & OFC_XX_V <= -1)
keep NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A
order NAME UNFIPS ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A
gen YEAR=1920
destring UNFIPS, replace
sort UNFIPS
save `1920', replace
clear



**Put all of the data into a base year of 1870

***
*Put year 1920 into a base of 1870
***
*Bring in exported data from GIS that adjusts for border changes
insheet using Export_19201870.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

*Generate the fraction of the new county that is in the old county
gen percent = new_area/area

*merge in other fields by new county id
rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1920', uniqusing

*multiply by the fraction to get the right amount for each piece
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A {
replace `var' = `var'*percent
}

*collapse by id_1 (old county id)
*if missing a value for any piece, keep the total missing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A, by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A {
replace `var' = . if `var' < 0
}

*keep only the core counties
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

*Generate ID system
format id_1 %05.0f
gen year_1 = 1920
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1920base1870', replace
clear

***
*Put year 1910 into a base of 1870 (same as above)
***
insheet using Export_19101870.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

gen percent = new_area/area

rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1910', uniqusing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui {
replace `var' = `var'*percent
}

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui, by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui {
replace `var' = . if `var' < 0
}

drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

format id_1 %05.0f
gen year_1 = 1910
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1910base1870', replace
clear

***
*Put year 1900 into a base of 1870 (same as above)
***
insheet using Export_19001870.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

gen percent = new_area/area

rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1900', uniqusing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui {
replace `var' = `var'*percent
}

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui  {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui , by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui  {
replace `var' = . if `var' < 0
}

drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

format id_1 %05.0f
gen year_1 = 1900
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1900base1870', replace
clear

***
*Put year 1890 into a base of 1870 (same as above)
***
insheet using Export_18901870.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

gen percent = new_area/area

rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1890', uniqusing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A farmval  {
replace `var' = `var'*percent
}

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A farmval  {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A farmval , by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A farmval  {
replace `var' = . if `var' < 0
}

drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

format id_1 %05.0f
gen year_1 = 1890
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1890base1870', replace
clear

***
*Put year 1880 into a base of 1870 (same as above)
***
insheet using Export_18801870.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

gen percent = new_area/area

rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1880', uniqusing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V FEN_XX_V CTL_XX_Q CRP_XX_A BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C {
replace `var' = `var'*percent
}

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V FEN_XX_V CTL_XX_Q CRP_XX_A BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V FEN_XX_V CTL_XX_Q CRP_XX_A BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C, by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V FEN_XX_V CTL_XX_Q CRP_XX_A BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C {
replace `var' = . if `var' < 0
}

drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

format id_1 %05.0f
gen year_1 = 1880
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1880base1870', replace
clear

***
*Combines files for each year (base year 1870)
***
use `1870'
rename UNFIPS id_1
rename YEAR year_1
append using `merged1880base1870'
append using `merged1890base1870'
append using `merged1900base1870'
append using `merged1910base1870'
append using `merged1920base1870'
drop unyear_1
rename id_1 UNFIPS
rename year_1 YEAR
order UNFIPS YEAR NAME ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V farmval farmbui AFP_XX_V FST_XX_V FEN_XX_V CTL_XX_Q CRP_XX_A BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A BEA_XH_A BET_XH_A PEA_XH_A
sort UNFIPS YEAR
rename UNFIPS unfips
rename YEAR year
rename NAME name
rename ARE_XX_A are_xx_a
rename FML_XX_A fml_xx_a
rename IML_XX_A iml_xx_a
rename WOD_XX_A wod_xx_a
rename FRM_XX_Q frm_xx_q
rename PRP_XX_V prp_xx_v
rename PRP_OF_V prp_of_v
rename PRP_TX_V prp_tx_v
rename PRP_MX_V prp_mx_v
rename AFP_XX_V afp_xx_v
rename FST_XX_V fst_xx_v
rename FEN_XX_V fen_xx_v
rename CTL_XX_Q ctl_xx_q
rename CRP_XX_A crp_xx_a
rename BAR_XH_A bar_xh_a
rename BAR_XH_B bar_xh_b
rename OAT_XH_A oat_xh_a
rename OAT_XH_B oat_xh_b
rename RYE_XH_A rye_xh_a
rename RYE_XH_B rye_xh_b
rename WHT_XH_A wht_xh_a
rename WHT_XH_B wht_xh_b
rename HAY_XH_A hay_xh_a
rename HAY_XH_T hay_xh_t
rename CRN_GH_A crn_gh_a
rename CRN_GH_B crn_gh_b
rename COT_XH_A cot_xh_a
rename COT_XH_C cot_xh_c
rename FLX_XH_A flx_xh_a
rename PNT_XH_A pnt_xh_a
rename POT_XH_A pot_xh_a
rename BEA_XH_A bea_xh_a
rename BET_XH_A bet_xh_a
rename PEA_XH_A pea_xh_a
save Base1870.dta, replace
clear


**Put all of the data into a base year of 1880 (as for base of 1870)

*1920, base 1880
insheet using Export_19201880.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

gen percent = new_area/area

rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1920', uniqusing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A {
replace `var' = `var'*percent
}


foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A, by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A {
replace `var' = . if `var' < 0
}

drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

format id_1 %05.0f
gen year_1 = 1920
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1920base1880', replace
clear

*1910, base 1880
insheet using Export_19101880.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

gen percent = new_area/area

rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1910', uniqusing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui {
replace `var' = `var'*percent
}

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui, by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_OF_V PRP_TX_V PRP_MX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui {
replace `var' = . if `var' < 0
}

drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

format id_1 %05.0f
gen year_1 = 1910
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1910base1880', replace
clear

*1900, base 1880
insheet using Export_19001880.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

gen percent = new_area/area

rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1900', uniqusing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui {
replace `var' = `var'*percent
}

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui  {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui , by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C BEA_XH_A BET_XH_A FLX_XH_A PEA_XH_A PNT_XH_A POT_XH_A farmval farmbui  {
replace `var' = . if `var' < 0
}

drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

format id_1 %05.0f
gen year_1 = 1900
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1900base1880', replace
clear

*1890, base 1880
insheet using Export_18901880.txt, tab
drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

gen percent = new_area/area

rename id UNFIPS
sort UNFIPS
merge UNFIPS using `1890', uniqusing

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A farmval  {
replace `var' = `var'*percent
}

foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A farmval  {
replace `var' = -100000000000000000000000 if `var'==.
}
collapse (sum) ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A farmval , by(id_1)
foreach var of varlist ARE_XX_A FML_XX_A IML_XX_A FRM_XX_Q PRP_XX_V AFP_XX_V CTL_XX_Q BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A farmval  {
replace `var' = . if `var' < 0
}

drop if id < 8000
drop if id > 9000 & id < 19000
drop if id > 21000 & id < 27000
drop if id > 28000 & id < 30000
drop if id > 32000 & id < 35000
drop if id > 36000 & id < 38000
drop if id > 39000 & id < 40000
drop if id > 41000 & id < 46000
drop if id > 47000 & id < 48000
drop if id > 49000 & id < 56000

format id_1 %05.0f
gen year_1 = 1890
gen unyear_1 = 0
recast double unyear_1
format unyear_1 %09.0f
replace unyear_1 = id_1*10000 + year
save `merged1890base1880', replace
clear

*Combine files
use `1880'
rename UNFIPS id_1
rename YEAR year_1
append using `merged1890base1880'
append using `merged1900base1880'
append using `merged1910base1880'
append using `merged1920base1880'
drop unyear_1
rename id_1 UNFIPS
rename year_1 YEAR
order UNFIPS YEAR NAME ARE_XX_A FML_XX_A IML_XX_A WOD_XX_A FRM_XX_Q PRP_XX_V PRP_OF_V PRP_TX_V PRP_MX_V farmval farmbui AFP_XX_V FEN_XX_V CTL_XX_Q CRP_XX_A BAR_XH_A BAR_XH_B OAT_XH_A OAT_XH_B RYE_XH_A RYE_XH_B WHT_XH_A WHT_XH_B HAY_XH_A HAY_XH_T CRN_GH_A CRN_GH_B COT_XH_A COT_XH_C FLX_XH_A PNT_XH_A POT_XH_A BEA_XH_A BET_XH_A PEA_XH_A
sort UNFIPS YEAR
rename UNFIPS unfips
rename YEAR year
rename NAME name
rename ARE_XX_A are_xx_a
rename FML_XX_A fml_xx_a
rename IML_XX_A iml_xx_a
rename WOD_XX_A wod_xx_a
rename FRM_XX_Q frm_xx_q
rename PRP_XX_V prp_xx_v
rename PRP_OF_V prp_of_v
rename PRP_TX_V prp_tx_v
rename PRP_MX_V prp_mx_v
rename AFP_XX_V afp_xx_v
rename FEN_XX_V fen_xx_v
rename CTL_XX_Q ctl_xx_q
rename CRP_XX_A crp_xx_a
rename BAR_XH_A bar_xh_a
rename BAR_XH_B bar_xh_b
rename OAT_XH_A oat_xh_a
rename OAT_XH_B oat_xh_b
rename RYE_XH_A rye_xh_a
rename RYE_XH_B rye_xh_b
rename WHT_XH_A wht_xh_a
rename WHT_XH_B wht_xh_b
rename HAY_XH_A hay_xh_a
rename HAY_XH_T hay_xh_t
rename CRN_GH_A crn_gh_a
rename CRN_GH_B crn_gh_b
rename COT_XH_A cot_xh_a
rename COT_XH_C cot_xh_c
rename FLX_XH_A flx_xh_a
rename PNT_XH_A pnt_xh_a
rename POT_XH_A pot_xh_a
rename BEA_XH_A bea_xh_a
rename BET_XH_A bet_xh_a
rename PEA_XH_A pea_xh_a
save Base1880.dta, replace




