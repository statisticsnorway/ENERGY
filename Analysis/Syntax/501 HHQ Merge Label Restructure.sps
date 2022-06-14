* Encoding: UTF-8.
* Created 19.01.2022. 
* Update: Kristian 26.01 - 10.02.2022
*Update: Bjørn 24.05.2022        
* Update::Per 19.01 - 24.05.2022.
* SSB/NBS project team final approval: ................ 

*Objective: 1) Merging household file with community file and construcl&label new derived key variables for tabulation/analysis incl. tiers and weights
                 2) Produce the person level file with all household and community information appended
                 3) Secure consistency between household level file and the person level file

*In-put:   The cleaned (unique identifiers/no-duplicate) "tmp\HHQTZ_4 file" and the cleaned "tmp\COMTZ_2" file.                   

*Out-put: A) The household level file (with all community information append) ready for further analysis and tabullation
              B) The person level file (with all household- and community information appended)  ready for further analysis and tabullation.  
              
*******************************************************************************************************************************************''********************************************
The working filestructure for this program is as follows:

*.....\2021_22_SPSS Tanzania
            \Cat
            \Data in
                \TZ community
                \TZ listing
                \TZ HHQ
            \Production
            \Documentation
            \Syntax
            \Tabeller
            \Tmp
*************'*****************************************************************************
*Set the folder path and open file from the folder structure.
* "The SET DECIMAL=DOT" is necessary to add to get the XY coodinates correctly opened..
*Open temp 4 file.and continue .
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
GET FILE='tmp\HHQTZ_4.sav'.
SET DECIMAL=DOT.

*Check the input file..
FREQUENCIES Region.
******************************************************.
*MERGE/APPEND INFORMATION FROM THE COMMUNITY QUESTIONNAIRE TO THE HOUSEHOLD FILE. 
*THE ComTZ_2 file must be of same date or later date and cleaned/labelled/grouped before merging. 
SORT CASES BY GeocodeEA (A).
MATCH FILES 
/FILE=*   
/TABLE= 'tmp\ComTZ_2.sav'  
/BY GeocodeEA.
EXECUTE.	
**************************************************
*KEEP THE MISSING COMMUNITY IN THE FILE (we do not want to loose more HH)..
*Check where community interview is missing.
FREQUENCIES Region.
TEMPORARY.
SELECT IF
      (MISSING (comREC_ID) = 1). 
LIST comREC_ID GeocodeEA.

*Comment per 03.04.2022: We are missing community iterviews for a total of 101 households/records and 5 EAs.
*04032011106001
*04032711103001
*07012521105011
*08052011103003
*14060821104013.    

*We have a total of 5921 records on our work file.

*Save temporary HHQ + COM file and open again.
SAVE OUTFILE='tmp\TZHHCOM_1.sav'
/KEEP 
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.

*****************.
*Open file.and continue .
*OUTPUT CLOSE ALL.
*DATASET CLOSE ALL.
GET FILE='tmp\TZHHCOM_1.sav'.
SET DECIMAL=DOT.

*Check the input file..
FREQUENCIES Region.

**************************************************************************************************************
*CREATE NEW DERIVED MUCH USED VARIABLES FOR TABULATION.
**************************************************************************************************************.
*Correction of some country specifik value sets:
*a) Tanzania specific correction/recoding and new labeling of valueset for literacy (AC1$01-20)

*Check. 
*FREQUENCIES AC1$01 AC1$05 AC1$10 AC1$20.
VECTOR case = AC1$01 TO AC1$20.
LOOP #i = 1 TO 20.
IF ( case (#i) GT 10 AND case (#i) LT 15) case (#i) = 4.
IF (case (#i) = 15) case (#i) = 5. 
END LOOP.
EXECUTE.
VALUE LABELS AC1$01 TO AC1$20 
    1 "Kiswahili" 
    2 "English" 
    3 "Kiswahili and English" 
    4 "Any other language" 5 "No".
*Check.
*FREQUENCIES AC1$01 AC1$05 AC1$10 AC1$20.

*b) Tanzania specific correction/recoding and new labeling of valueset TARIFF_MZ to TARIFF_TZ
Variable C22.
*Name=TARIFF_TZ
Value=1;Domestic Use (D1)|Uso domÃ©stica (D1)|D1 [Matumizi chini ya Unit 75 kwa mwezi (TZS 100 kwa Unit)]
Value=2;General Use (T1)|Uso Geral (T1)|T1 [Matumizi zaidi ya Unit 75-750 kwa mwezi (TZS 292 kwa Unit)]

************************************************************
*1) Create new variable (headsex) Sex of head of household (Use AB4$01).
*Check.
*FREQUENCIES AB4$01.
COMPUTE headsex_gr1 = $SYSMIS.
FORMATS headsex_gr1 (F2.0).
RECODE AB4$01 (1 THRU 1 = 1) (2 THRU 2 = 2)  (MISSING = 3) INTO headsex_gr1.
VARIABLE LABELS headsex_gr1 "Sex of head of household".
VALUE LABELS headsex_gr1 1 " Male" 2 " Female" 3 " Not stated". 
EXECUTE.
*Check.
FREQUENCIES headsex_gr1. 

*OUTPUT CLOSE ALL.
****************************
*2) Create new variable (higheduc_gr1) with highest education in the household" (Use AC9$01 - AC9$20).
COMPUTE HighEduc = 0.
FORMATS higheduc (F2.0).
EXECUTE.

VECTOR person = AC9$01 TO AC9$20.
LOOP #i = 1 TO 20.
  IF ( person (#i) GT higheduc) higheduc = person (#i).
END LOOP.
EXECUTE.
*Check.
FREQUENCIES HighEduc.
RECODE HighEduc (0 THRU 2= 1) (11 THRU 14 = 2) (15 THRU 18 = 3) (19 THRU HIGHEST = 4) INTO HighEduc_Gr1.
VARIABLE LABELS HighEduc_Gr1 "Highest education completed by any household member".
VALUE LABELS HighEduc_Gr1 
1 "Pre-school or other no formal education" 
2 "Primary 1-4"
3 "Primary 5-8"
4 "Secondary or higher".
FORMATS HighEduc_Gr1 (F2.0).
*Check.
FREQUENCIES HighEduc_Gr1.
* Custom Tables.
*CTABLES
  /VLABELS VARIABLES=HighEduc_Gr1 UrbRur DISPLAY=LABEL
  /TABLE HighEduc_Gr1 [COUNT F40.0] BY UrbRur
  /CATEGORIES VARIABLES=HighEduc_Gr1 UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
  /CRITERIA CILEVEL=95.

*OUTPUT CLOSE ALL.
*******************************
*3) Create new variable (HHsize_gr1) with number of members in the household.(Use AB3$01 -AB3$20). 
COMPUTE HHsize = 0.
VECTOR person = AB3$01 TO AB3$20.
LOOP #i = 1 TO 20.
  IF ( person (#i) GT 0) HHsize = SUM(HHsize + 1).
END LOOP.
EXECUTE.
FREQUENCIES HHSize.
VARIABLE LABELS HHSize "Number of persons in the household".
RECODE HHsize (1 = 1) (2 = 2) (3 = 3) (4 = 4) (5 = 5) (6=6) (7 THRU HIGHEST = 7) INTO HHsize_Gr1.
VARIABLE LABELS HHsize_Gr1 "Household size (Persons)".
VALUE LABELS HHsize_gr1 
1 "1  " 
2 "2  "
3 "3  "
4 "4  "
5 "5  "
6 "6  "
7 "7+".
FORMATS HHsize_gr1 (F2.0).
EXECUTE.
*Check.
*FREQUENCIES HHsize_Gr1.
* Custom Tables.
*CTABLES
  /VLABELS VARIABLES=HHsize_Gr1 UrbRur DISPLAY=LABEL
  /TABLE HHsize_Gr1 [COUNT F40.0] BY UrbRur
  /CATEGORIES VARIABLES=HHsize_Gr1 UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
  /CRITERIA CILEVEL=95.

*OUTPUT CLOSE ALL.

*****************************************************************************.
*4) Create new variable (HHelGrid_gr1) with household connnected to grid or other el solutions."Electricity in household (grid/other/no electricity)".
* Check.
FREQUENCIES C2 C4 C6 C7 C8 C9.
IF (C2 = 1) HHElGrid_Gr1 = 1.
IF (C2 = 2 AND (C4 = 1 OR C6 = 1 OR C7 = 1 OR C8 = 1) ) HHElGrid_Gr1 = 2.
IF (C2 = 2  AND C4 = 2 AND C6 = 2 AND C7 = 2 AND C8 = 2 ) HHelGrid_Gr1 = 3.
*IF (SYSMIS(C2) = 1  AND SYSMIS(C4) = 1 AND SYSMIS(C6) = 1 AND SYSMIS(C7) = 1 AND SYSMIS(C8) = 1 AND SYSMIS(C9) = 1) HHElGrid_Gr1 = 4.
EXECUTE.
VARIABLE LABELS HHElGrid_gr1 "Electricity in the household (grid/other/no electricity)".
VALUE LABELS HHElGrid_gr1 
    1 "Household is connected to grid-based electricity (National or local)" 
    2 "Household is not connected any grid, but has other electricity solutions"
    3 "Household has no electricity solutions ".
    
*Check.
FREQUENCIES HHelGrid_gr1 .
* Custom Tables.
CTABLES
  /VLABELS VARIABLES=HHelGrid_Gr1 UrbRur DISPLAY=LABEL
  /TABLE HHElGrid_Gr1 [COUNT F40.0] BY UrbRur
  /CATEGORIES VARIABLES=HHElGrid_Gr1 UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
  /CRITERIA CILEVEL=95.

*OUTPUT CLOSE ALL.
***************************************************************************.
*5) Create 5 varables with grouped economic status by at least 1 hh member - for tabulation (Use A2$01-20 Occupation only??).
COMPUTE HHOccupStatus_gr1 = 0.
COMPUTE HHOccupStatus_gr2 = 0.
COMPUTE HHOccupStatus_gr3 = 0.
COMPUTE HHOccupStatus_gr4 = 0.
COMPUTE HHOccupStatus_gr5 = 0.
EXECUTE.
VECTOR person = A2$01 TO A2$20.
LOOP #i = 1 TO 20.
  IF ( person (#i) GT  0 AND person (#i) LT 3 )  HHOccupStatus_gr1 = 1.
  IF ( person (#i) GE  4 AND person (#i) LT 8 )  HHOccupStatus_gr2 = 1.
  IF ( person (#i) GE  10 AND person (#i) LT 12)  HHOccupStatus_gr3 = 1.
  IF ( person (#i) = 3 OR person (#i) = 8 OR person (#i) = 9 OR person (#i) = 12 ) HHOccupStatus_gr4 = 1.  
  IF ( person (#i) GE 13 AND person (#i) LT 21) HHOccupStatus_gr5 = 1.
END LOOP.
EXECUTE.
VARIABLE LABELS HHOccupStatus_gr1 "Self-employed/employer in farming/fishery".
VARIABLE LABELS HHOccupStatus_gr2 "Self-employed/employer in other production/service".
VARIABLE LABELS HHOccupStatus_gr3 "Employed in public sector".
VARIABLE LABELS HHOccupStatus_gr4 "Employed in formal sector (privat owner/company)".
VARIABLE LABELS HHOccupStatus_gr5 "Not economically active".
*Check.
*FREQUENCIES HHOccupStatus_gr1 HHOccupStatus_gr2 HHOccupStatus_gr3 HHOccupStatus_gr4 HHOccupStatus_gr5.
* Custom Tables.
*CTABLES
  /VLABELS VARIABLES=HHOccupStatus_gr1 HHOccupStatus_gr2 HHOccupStatus_gr3 HHOccupStatus_gr4 HHOccupStatus_gr5 UrbRur DISPLAY=LABEL
  /TABLE HHOccupStatus_gr1 + HHOccupStatus_gr2 + HHOccupStatus_gr3 + HHOccupStatus_gr4 + HHOccupStatus_gr5 
  BY UrbRur [COUNT F40.0]
  /CATEGORIES VARIABLES=HHOccupStatus_gr1 HHOccupStatus_gr2 HHOccupStatus_gr3 HHOccupStatus_gr4 
    HHOccupStatus_gr5 ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES=UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CRITERIA CILEVEL=95.

*OUTPUT CLOSE ALL.
 ***********************************************************************************************************.
*6) Create variable with info for "grid in community" grouping for tabulation based on comD1..

*We already have a MR set comD1_gr1a to comD1_gr1k. 

********************************************************************
********************************************************************.
*7) CREATE EXPENDITURE QUINTILE: 
A) Total annual HH exependitures
B) Impute mean for outliers and impute missing values in total annual expenditure
C) Total annual percapita HH expenditure 
D) Expenditure quintile (avg annual exp per capita in household) 

*A)
*Based on (Q2A$1 - 7) (Q2B$1 -7) (Q2C$1 -7) (Q11)  all weekly adjusted to annual ( 52)
 With (Q11 -13) monthly * 12  and Q15 - 16 annually kept as is. + HHsize..

*Exclude "dont know/assumed dont know 88-888-8888-... up to 8888888888 and 9999999999.. 
IF ( ANY (Q2A$1, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2A$1_TMP = Q2A$1.
IF ( ANY (Q2A$2, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2A$2_TMP = Q2A$2.
IF ( ANY (Q2A$3, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2A$3_TMP = Q2A$3.
IF ( ANY (Q2A$4, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2A$4_TMP = Q2A$4.
IF ( ANY (Q2A$5, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2A$5_TMP = Q2A$5.
IF ( ANY (Q2A$6, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2A$6_TMP = Q2A$6.
IF ( ANY (Q2A$7, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2A$7_TMP = Q2A$7.
IF ( ANY (Q2B$1, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2B$1_TMP = Q2B$1.
IF ( ANY (Q2B$2, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2B$2_TMP = Q2B$2.
IF ( ANY (Q2B$3, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2B$3_TMP = Q2B$3.
IF ( ANY (Q2B$4, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2B$4_TMP = Q2B$4.
IF ( ANY (Q2B$5, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2B$5_TMP = Q2B$5.
IF ( ANY (Q2B$6, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2B$6_TMP = Q2B$6.
IF ( ANY (Q2B$7, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2B$7_TMP = Q2B$7.
IF ( ANY (Q2C$1, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2C$1_TMP = Q2C$1.
IF ( ANY (Q2C$2, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2C$2_TMP = Q2C$2.
IF ( ANY (Q2C$3, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2C$3_TMP = Q2C$3.
IF ( ANY (Q2C$4, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2C$4_TMP = Q2C$4.
IF ( ANY (Q2C$5, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2C$5_TMP = Q2C$5.
IF ( ANY (Q2C$6, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2C$6_TMP = Q2C$6.
IF ( ANY (Q2C$7, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q2C$7_TMP = Q2C$7.
IF ( ANY (Q11, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q11_TMP = Q11.
IF ( ANY (Q12, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q12_TMP = Q12.
IF ( ANY (Q13, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q13_TMP = Q13.
IF ( ANY (Q14, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q14_TMP = Q14.
IF ( ANY (Q15, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q15_TMP = Q15.
IF ( ANY (Q16, 88, 888, 8888, 88888, 888888, 8888888, 88888888, 888888888, 8888888888, 9999999999) = 0) Q16_TMP = Q16.
EXECUTE.  
*food and wood weekly adjusted to year ..
COMPUTE CTMP1 = (SUM (Q2A$1_TMP, Q2A$2_TMP, Q2A$3_TMP, Q2A$4_TMP, Q2A$5_TMP, Q2A$6_TMP, Q2A$7_TMP,
Q2B$1_TMP, Q2B$2_TMP, Q2B$3_TMP, Q2B$4_TMP, Q2B$5_TMP, Q2B$6_TMP, Q2B$7_TMP,
Q2C$1_TMP, Q2C$2_TMP, Q2C$3_TMP, Q2C$4_TMP, Q2C$5_TMP, Q2C$6_TMP, Q2C$7_TMP, Q11_TMP) * 52).
*other monthly adjusted to year.
COMPUTE CTMP2 = (SUM(Q12_TMP, Q13_TMP, Q14_TMP) * 12).
*Other annual.
COMPUTE CTMP3 = SUM8(Q15_TMP, Q16_TMP). 
EXECUTE.

*Store and label total annual expenditures to the file if exp = 0 change to 1 to avouid divisions by 0 below. 
COMPUTE HHExpAll = SUM (CTMP1, CTMP2, CTMP3).
IF (HHExpAll LT 1) HHExpAll = 100.
FORMATS HHExpAll (F20.0).
VARIABLE LABELS HHExpAll "Total household annual expenditure (TZS)". 
EXECUTE.
*Check.
*FREQUENCIES HHExpAll.

*B1) Identify outlier(s) in HHExpAl and impute meanl.
SORT CASES BY REC_ID (A).
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /mean_HHExpAll =MEAN(HHExpAll) 
  /sd_HHExpAll=SD(HHExpAll)
  /n_cases =N.
EXECUTE.

TEMPORARY.
SELECT IF (HHExpAll GT (mean_HHExpAll + (3 * sd_HHExpAll )) OR HHExpAll LT (mean_HHExpAll - (3 * sd_HHExpAll ))).
LIST REC_ID HHExpAll mean_HHExpAll sd_HHExpAll n_cases.
EXECUTE.

*one outlier ( gt 3x stdv from mean) imputed as mean value..
IF (REC_ID = 1390) HHExpAll = 4574305.
EXECUTE.

***********************************************.
*B2) Hotdeck macro - nearest neighbour in strata imputation for missing HHExpAll.(higlight all between astreixes and run the HD).
DEFINE HOTDECK (y = !charend ('/')
                             /deck = !charend ("/")).
Output New name = hotdeckextra.
!do !s !in (!y).
      compute randnum = uniform(1).
      sort cases by !deck randnum.
      compute sortclg1 = 1.
      compute sortclg2 = 1.
      compute sortcld1 = 1.
      compute sortcld2 = 1.
   !DO !v !in (!deck).
      create sortd1v = lead(!v,1).
      create sortd2v = lead(!v,2).
         if (lag(!v) <> !v) sortclg1 = 0.
         if (lag(!v,2) <> !v) sortclg2 = 0.
         if (sortd1v <> !v) sortcld1 = 0.
         if (sortd2v <> !v) sortcld2 = 0.
   !DOEND.
   !let !newname = !CONCAT (!s, HD).
   compute newvar = !s.
   apply dictionary from * /source variables = !s /target variables = newvar.
   execute.
   Create yLead = Lead(!s,1).
   Create yLead2 = Lead (!s,2).
   DO If (Missing(newvar)).
      + DO IF ((sortclg1 = 1) AND Not Missing(lag(!s))).
            + Compute newvar = Lag(!s).
      + ELSE IF ((sortcld1 = 1) AND Not Missing (yLead)).
            + Compute newvar = yLead.
       + ELSE IF ((sortclg2 = 1) AND Not Missing(Lag(!s,2))).
            + Compute newvar = Lag(!s,2).
       + ELSE IF ((sortcld2 = 1) AND Not Missing(yLead2)).
            + Compute newvar = yLead2.
       + END IF.
   End If.
   Match Files/File = */drop yLead ylead2 sortd1v sortd2v sortclg1 sortclg2 sortcld1 sortcld2 randnum.
   execute.
   rename variables (newvar = !newname).
!doend.
output close name = hotdeckextra.
!ENDDEFINE.

HOTDECK y= HHExpAll  / deck = UrbRur HHSize_gr1 higheduc_gr1. 

*y       = variable missing to be imputed 
*deck = variables used to stratify into decks from where nearest neighbour value is imputed to the missing var y  
**********************************
*check HD results.
FREQUENCIES HHExpAllHD HHExpAll.
COMPUTE tmpExp = SUM(HHExpAll - HHExpAllHD).
EXECUTE.
FREQUENCIES tmpExp.
*28 records are imputed.. 

*Clean and rename.
DELETE VARIABLES HHExpAll mean_HHExpAll sd_HHExpAll n_cases.
RENAME VARIABLES HHExpAllHD = HHExpAll.
FREQUENCIES HHExpAll.

TEMPORARY.
SELECT IF SYSMIS(HHExpAll)=1.
LIST REC_ID.
*correct proxy for still missing use mean value.
IF (REC_ID=1419) HHExpAll = 4574305.
EXECUTE.

*C) Compute, store and label per capita total annual expenditures to the file. 
COMPUTE HHExpAllCapita = (HHExpAll / HHsize).
FORMATS HHExpAllCapita (F20.0).
VARIABLE LABELS HHExpAllCapita "Total household per capita annual expenditure (TZS)". 
EXECUTE.

*Check.
FREQUENCIES HHExpAllCapita..
*Delete TMP variables.
DELETE VARIABLES Q16_TMP Q15_TMP Q14_TMP Q13_TMP Q12_TMP Q11_TMP   
Q2A$1_TMP Q2A$2_TMP Q2A$3_TMP Q2A$4_TMP Q2A$5_TMP Q2A$6_TMP Q2A$7_TMP
Q2B$1_TMP Q2B$2_TMP Q2B$3_TMP Q2B$4_TMP Q2B$5_TMP Q2B$6_TMP Q2B$7_TMP
Q2C$1_TMP Q2C$2_TMP Q2C$3_TMP Q2C$4_TMP Q2C$5_TMP Q2C$6_TMP Q2C$7_TMP
CTMP1 CTMP2 CTMP3.

*D) Create Expenditure per capita quintiles.
COMPUTE ExpQnt = (HHExpAll / HHsize). 
EXECUTE.
RANK VARIABLES=ExpQnt (A)
  /NTILES(5)
  /PRINT=YES
  /TIES=MEAN.
RENAME VARIABLES NExpQnt = NatExpQuint.
VARIABLE LABELS NatExpQuint "Household per capita total annual expenditure quintile".
VALUE LABELS NatExpQuint 1"1st (Lowest)" 2"2nd" 3"3rd" 4"4th" 5"5th (Highest)".  
EXECUTE.

*Check/clean.
FREQUENCIES NatExpQuint.
DELETE VARIABLES ExpQnt.

OUTPUT CLOSE ALL.
******************************************************************************************************
******************************************************************************************************
*8) CREATE WEALTH INDEX AND WEALTH QUINTILE - CURRENT - NATIONAL.
*Make binary tmp variables (A-B-C below).

*A) HOUSEHOLD UTILITIES.
*HHsize
B6	Numeric	2	0	Number of rooms	None
B7	Numeric	2	0	Material walls	{1, Wood and mud}...
*B8	Numeric	1	0	Material roof	{1, Wood and mud}...
*B9	Numeric	2	0	Material floor	{1, Mud/dung}...
*B10	Numeric	1	0	Type of toilet	{1, No toilet / bush / field}...
*B11	Numeric	2	0	Source drinking water	{1, Pipe borne water}...
*B12	Numeric	2	0	Drinking water treated	{1, None}...
*B13	Numeric	2	0	Main source energy lighting	{1, Electricity (TANESCO)}...
*B14	Numeric	2	0	Main source enegy cooking	{1, Electricity (TANESCO)}...

*persons in household-new household utility for wealth index (10.03.2022).
COMPUTE tmpPersInHH =0.
*FREQUENCIES HHSize.
IF (HHSize LE 5) tmpPersInHH = 1.
*FREQUENCIES tmpPersInHH.
*persons per room.
COMPUTE tmpPers = 0.
COMPUTE tmpPers1 = SUM(HHsize / B6).
*FREQUENCIES tmpPers1.
IF ( tmpPers1 GT 0 AND tmpPers1 LE 2) tmpPers = 1.
VARIABLE LABELS tmpPers "Persons per room".
*FREQUENCIES tmpPers.
*material walls.
COMPUTE tmpWalls = 0.
*FREQUENCIES B7.
IF (B7 = 3 OR B7 = 5 OR B7 = 6 OR B7=7 OR B7 = 8 OR B7 = 11) tmpWalls = 1.
VARIABLE LABELS tmpWalls "Material for walls".
*material roof.
COMPUTE tmpRoof = 0.
*FREQUENCIES B8.
IF (B8 GE 3 AND B8 LT 6) tmpRoof = 1.
VARIABLE LABELS tmpRoof "Materials for roof".
*Material floor.
COMPUTE tmpFloor = 0.
*FREQUENCIES B9.
IF (B9 GT 2)  tmpFloor = 1.
VARIABLE LABELS tmpFloor "Materials for floor".
*Type of toilet.
COMPUTE tmpToilet = 0.
*FREQUENCIES B10.
IF(B10 GE 5 AND B10 LE 8) tmpToilet = 1.
VARIABLE LABELS tmpToilet "Type of toilet".
*Source of drinking water.
COMPUTE tmpWater = 0.
*FREQUENCIES B11.
IF (B11 GT 0 AND B11 LT 4) tmpWater = 1.
VARIABLE LABELS tmpWater "Water source".
*Main source of energ lighting.
COMPUTE tmpLight = 0.
*FREQUENCIES B13.
IF (B13 GT 0 AND B13 LT 2 ) tmpLight = 1.
VARIABLE LABELS tmpLight "Light source".
*Main source energy for cooking.
COMPUTE tmpCook = 0.
*FREQUENCIES B14.
IF (B14 = 1 OR B14 = 4) tmpCook = 1.
VARIABLE LABELS tmpCook "Cook source".
EXECUTE.
*clean.
DELETE VARIABLES tmpPers1.

*B) HOUSEHOLD NON-PRODUCTIVE ASSETS.
*L2$01 to L2$22	Numeric	2	0	item number	{1, Bed}...
*L2C$01	Numeric	2	0	Do you have/Number of items	{1, Yes}...
*Check.
*FREQUENCIES L2$01 L2$02 L2$03 L2$04 L2$05 L2$06 L2$07 L2$08 L2$09 L2$10 L2$11 L2$12 L2$13 L2$14 L2$15 L2$16 L2$17 L2$18 L2$19  L2$20 L2$21 L2$22. 
*Bed.
COMPUTE tmpBed = 0.
IF ( (L2$01 = 1 AND L2A$01 = 1) OR (L2$02 = 1 AND L2A$02 = 1) OR (L2$03 = 1 AND L2A$03 = 1) OR (L2$20 = 1 AND L2A$20 GT 0) ) tmpBed = 1. 
VARIABLE LABELS tmpBed "Bed".
*Table.
COMPUTE tmpTable = 0.
IF ( (L2$01 = 2 AND L2A$01 = 1) OR (L2$02 = 2 AND L2A$02 = 1) OR (L2$03 = 2 AND L2A$03 = 1) ) tmpTable = 1. 
VARIABLE LABELS tmpTable "Table".
*Bicycle.
COMPUTE tmpBicycle = 0.
IF ( (L2$03 = 3 AND L2A$03 = 1) OR (L2$04 = 3 AND L2A$04 = 1) ) tmpBicycle = 1. 
VARIABLE LABELS tmpBicycle "Bicycle".
*Motorcycle.
COMPUTE tmpMC = 0.
IF ( (L2$04 = 4 AND L2A$04 = 1) OR (L2$05 = 4 AND L2A$05 = 1) ) tmpMC = 1. 
VARIABLE LABELS tmpMC "MC".
*Car.
COMPUTE tmpCar = 0.
IF (L2$05 = 5 AND L2A$05 = 1) tmpCar = 1.
VARIABLE LABELS tmpCar "Car".
*RadioBatt .
COMPUTE tmpRadio1 = 0.
IF (L2$06 = 6 AND L2A$06 = 1)  tmpRadio1 = 1.
VARIABLE LABELS tmpRadio1 "Radio battery".
*Radio electric.
COMPUTE tmpRadio2 = 0.
IF (L2$08 = 8 AND L2A$08 = 1) tmpRadio2 = 1.
VARIABLE LABELS tmpRadio2 "Radio el".
*MobileCharge.
COMPUTE tmpCharge = 0.
IF ( (L2$07 = 7 AND L2A$07 = 1) OR (L2$08 = 7 AND L2A$08 = 1)  OR  (L2$22 = 7 AND L2A$22 GT 0)   ) tmpCharge = 1. 
VARIABLE LABELS tmpCharge "Mobile charger".
*Fan.
COMPUTE tmpFan = 0.
IF (L2$09 = 9 AND L2A$09 = 1) tmpFan = 1.
VARIABLE LABELS tmpFan "Fan".
*Refrigerator.
COMPUTE tmpRefrig = 0.
IF ( (L2$10 = 10 AND L2A$10 = 1) OR (L2$22 = 10 AND L2A$22 GT 0) OR (L2$19 = 10 AND L2A$19 = 1)  ) tmpRefrig = 1.
VARIABLE LABELS tmpRefrig "Refrigerator".
*MicroW.
COMPUTE tmpMicro = 0.
IF (L2$11 = 11 AND L2A$11 = 1) tmpMicro= 1.
VARIABLE LABELS tmpMicro "Microwave".
*Freez.
COMPUTE tmpFreez = 0.
IF ( (L2$12 = 12 AND L2A$12 = 1) OR  (L2$14 = 12 AND L2A$14 = 1) )   tmpFreez = 1.
VARIABLE LABELS tmpFreez "Freezer".
*Washmachine.
COMPUTE tmpWash = 0.
IF (L2$13 = 13 AND L2A$13 = 1) tmpWash = 1.
VARIABLE LABELS tmpWash "Washing machine".
*Sewingmachine el.
COMPUTE tmpSewing = 0.
IF (L2$14 = 14 AND L2A$14 = 1) tmpSewing = 1.
VARIABLE LABELS tmpSewing "Sewing machine".
*AC.
COMPUTE tmpAC = 0.
IF (L2$15 = 15 AND L2A$15 = 1) tmpAC = 1.
VARIABLE LABELS tmpAC "AC".
*PC.
COMPUTE tmpPC=0.
IF (L2$16 = 16 AND L2A$16 = 1) tmpPC = 1.
VARIABLE LABELS tmpPC "PC".
*PotEl.
COMPUTE tmpPot = 0.
IF ( (L2$17 = 17 AND L2A$17 = 1) OR (L2$19 = 17 AND L2A$19 = 1) ) tmpPot = 1. 
VARIABLE LABELS tmpPot "Electric kettle".
*TV..
COMPUTE tmpTV = 0.
IF ( (L2$18 = 18 AND L2A$18 = 1) OR (L2$19 = 18 AND L2A$19 = 1) OR (L2$20 = 18 AND L2A$20 GT 0)   ) tmpTV = 1. 
VARIABLE LABELS tmpTV "TV".
*WatewrpumpEl.
COMPUTE tmpPump = 0.
IF (L2$19 = 19 AND L2A$19 = 1) tmpPump = 1.
VARIABLE LABELS tmpPump "Water pump".
*Traditional light bulbs..
COMPUTE tmpTrad = 0.
IF (  (L2$20 = 20 AND L2A$20 > 0)  OR (L2$21 = 20 AND L2A$21 GT 0) ) tmpTrad = 1. 
VARIABLE LABELS tmpTrad "Traditional bulbs".
*LED light bulbs..
COMPUTE tmpLED = 0.
IF ( (L2$21 = 21 AND L2A$21 GT 0) OR (L2$22 = 21 AND L2A$22 GT 0) )  tmpLED = 1. 
VARIABLE LABELS tmpLED "LED bulbs".
*ElSaving bulbs..
COMPUTE tmpSave = 0.
IF (L2$22 = 22 AND L2A$22 GT 0) tmpSave = 1.
VARIABLE LABELS tmpSave "Saving bulbs".
EXECUTE.

*C) HOUSEHOLD_PRODUCTIVE ASSETS	
*L6	Numeric	1	0	How many cattle?	{0, None}...
*L7	Numeric	1	0	How many sheep, goat or pigs?	{0, None}...
*L8	Numeric	1	0	How many chicken, ducks, turkeys, geese?	{0, None}...
*Land cultivation.
COMPUTE tmpLand = 0.
IF (L3 GT 0) tmpLand = 1.
VARIABLE LABELS tmpLand "Land".
*cattle.
COMPUTE tmpCattle = 0.
IF(L6 GT 0) tmpCattle = 1.
VARIABLE LABELS tmpCattle "Cattle".
*ShoutPig.
COMPUTE tmpSmall = 0.
IF(L7 GT 0) tmpSmall = 1.
VARIABLE LABELS tmpSmall "Shouts and pigs".
*Birds.
COMPUTE tmpBirds = 0.
IF(L8 GT 0) tmpBirds = 1.
VARIABLE LABELS tmpBirds "Birds".
EXECUTE.

*Change all to scale format.
VARIABLE LEVEL tmpPersInHH tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBed tmpTable tmpBicycle tmpMC tmpCar 
tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC tmpPot tmpTV tmpPump 
tmpTrad tmpLED tmpSave tmpLand tmpCattle tmpSmall tmpBirds ( SCALE).
EXECUTE.

*Decide on variables to use for further use . 
*CTABLES
  /VLABELS VARIABLES= tmpPersInHH tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBed tmpTable tmpBicycle tmpMC tmpCar 
                     tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC tmpPot tmpTV tmpPump 
                     tmpTrad tmpLED tmpSave tmpLand tmpCattle tmpSmall tmpBirds UrbRur DISPLAY=LABEL
  /TABLE 
     tmpPersInHH [C][ROWPCT.COUNT F10.1] + tmpPers    [C][ROWPCT.COUNT F10.1] + tmpWalls   [C][ROWPCT.COUNT F10.1] + 
     tmpRoof        [C][ROWPCT.COUNT F10.1] + tmpFloor    [C][ROWPCT.COUNT F10.1] + tmpToilet   [C][ROWPCT.COUNT F10.1] + 
     tmpWater      [C][ROWPCT.COUNT F10.1] + tmpLight    [C][ROWPCT.COUNT F10.1] + tmpCook   [C][ROWPCT.COUNT F10.1] + 
     tmpBed         [C][ROWPCT.COUNT F10.1] + tmpTable   [C][ROWPCT.COUNT F10.1] + tmpBicycle [C][ROWPCT.COUNT F10.1] + 
     tmpMC          [C][ROWPCT.COUNT F10.1] + tmpCar      [C][ROWPCT.COUNT F10.1] + tmpRadio1 [C][ROWPCT.COUNT F10.1] + 
     tmpRadio2     [C][ROWPCT.COUNT F10.1] + tmpCharge [C][ROWPCT.COUNT F10.1] + tmpFan     [C][ROWPCT.COUNT F10.1] + 
     tmpRefrig       [C][ROWPCT.COUNT F10.1] + tmpMicro   [C][ROWPCT.COUNT F10.1] + tmpFreez   [C][ROWPCT.COUNT F10.1] + 
     tmpWash      [C][ROWPCT.COUNT F10.1] + tmpSewing [C][ROWPCT.COUNT F10.1] + tmpAC      [C][ROWPCT.COUNT F10.1] + 
     tmpPC          [C][ROWPCT.COUNT F10.1] + tmpPot      [C][ROWPCT.COUNT F10.1] + tmpTV       [C][ROWPCT.COUNT F10.1] + 
     tmpPump      [C][ROWPCT.COUNT F10.1] + tmpTrad     [C][ROWPCT.COUNT F10.1] + tmpLED     [C][ROWPCT.COUNT F10.1] + 
     tmpSave       [C][ROWPCT.COUNT F10.1] + tmpLand    [C][ROWPCT.COUNT F10.1] + tmpCattle   [C][ROWPCT.COUNT F10.1] + 
     tmpSmall      [C][ROWPCT.COUNT F10.1] + tmpBirds   [C][ROWPCT.COUNT F10.1]
  BY UrbRur /CLABELS ROWLABELS=OPPOSITE
  /CATEGORIES VARIABLES = 
      tmpPersInHH tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBed tmpTable tmpBicycle tmpMC 
      tmpCar tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC 
      tmpPot tmpTV tmpPump tmpTrad tmpLED tmpSave tmpLand tmpCattle tmpSmall tmpBirds ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES = UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE TOTAL=YES POSITION=AFTER.

*Check output window table.
*keep those items with FREQ more than 5% and less than 95% in both urb and rur strata (WFP proxy rule).

*For national Indicator take out: Fan Refrig Micro Wash Sewing AC PC Pot Pump TradBulb 

*********************************************.
*First factor iteration..
*FACTOR
  /VARIABLES tmpPersInHH tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook 
    tmpBed tmpTable tmpBicycle tmpMC tmpCar tmpFreez tmpRadio1 tmpRadio2 tmpCharge tmpTV tmpLED tmpSave 
    tmpLand tmpCattle tmpSmall tmpBirds
  /MISSING LISTWISE 
  /ANALYSIS tmpPersInHH tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook 
    tmpBed tmpTable tmpBicycle tmpMC tmpCar tmpFreez tmpRadio1 tmpRadio2 tmpCharge tmpTV tmpLED tmpSave 
    tmpLand tmpCattle tmpSmall tmpBirds
  /PRINT INITIAL CORRELATION KMO AIC EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

*RANK VARIABLES=FAC1_1 (A)
  /NTILES(5)
  /PRINT=YES
  /TIES=MEAN.

*CTABLES
  /VLABELS VARIABLES= tmpPersInHH tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook 
  tmpBed tmpTable tmpBicycle tmpMC tmpCar tmpFreez tmpRadio1 tmpRadio2 tmpCharge tmpTV tmpLED tmpSave 
   tmpLand tmpCattle tmpSmall tmpBirds NFAC1_1 DISPLAY=LABEL
  /TABLE 
    tmpPersInHH [MEAN] + tmpPers[MEAN] + tmpWalls [MEAN] + tmpRoof [MEAN] + tmpFloor [MEAN] + tmpToilet [MEAN] + tmpWater[MEAN] + 
    tmpLight [MEAN] + tmpCook [MEAN]  + tmpBed[MEAN] + tmpTable[MEAN] + tmpBicycle [MEAN] + tmpMC[MEAN] + tmpCar [MEAN]  + tmpFreez [MEAN] + 
    tmpRadio1 [MEAN] + tmpRadio2[MEAN] + tmpCharge[MEAN] + tmpTV[MEAN] + tmpLED [MEAN]  + tmpSave[MEAN]  + tmpLand [MEAN] +
    tmpCattle[MEAN] + tmpSmall[MEAN] + tmpBirds[MEAN]                                      
    BY NFAC1_1  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=NFAC1_1 ORDER=A KEY=VALUE EMPTY=EXCLUDE.

*correlation between first iteration wealth FAC1_1 and household per capita expenditure quintiles.
*NONPAR CORR
  /VARIABLES=HHExpAllCapita FAC1_1
  /PRINT=SPEARMAN TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.

*From correlation matrix remove: radio1 radio2 mobcharger, savebulbs, persperroom (low correlation to many items).
*From rotated component matrix remove: the items above + table: bed MC Shoats Cattle Birds (low loading to component 1)
KMO = 0,838 Sign 0.000
6 Components
Component 1 expalins 19,7% of variance

*clean.
*DELETE VARIABLES FAC1_1 FAC2_1 FAC3_1 FAC4_1 FAC5_1 FAC6_1 NFAC1_1. 
***************************************************************.
*Second factor iteration..
*FACTOR
  /VARIABLES tmpPersInHH tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBicycle tmpCar tmpFreez tmpTV tmpLED tmpLand
  /MISSING LISTWISE 
  /ANALYSIS tmpPersInHH tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBicycle tmpCar tmpFreez tmpTV tmpLED tmpLand
  /PRINT INITIAL CORRELATION KMO AIC EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
                 
*RANK VARIABLES=FAC1_1 (A)
  /NTILES(5)
  /PRINT=YES
  /TIES=MEAN.

*CTABLES
  /VLABELS VARIABLES= tmpPersInHH tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBicycle tmpCar tmpTV tmpFreez tmpLED 
   tmpLand NFAC1_1 DISPLAY=LABEL
  /TABLE 
    tmpPersInHH [MEAN] + tmpWalls [MEAN] + tmpRoof [MEAN] +tmpFloor [MEAN] + tmpToilet [MEAN] + tmpWater[MEAN] + tmpLight [MEAN] +
    tmpCook [MEAN]  + tmpBicycle [MEAN]  + tmpCar [MEAN]  + tmpTV [MEAN] + tmpFreez [MEAN] + tmpLED [MEAN]  + tmpLand [MEAN]                                      
    BY NFAC1_1  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=NFAC1_1 ORDER=A KEY=VALUE EMPTY=EXCLUDE.

*correlation between second iteration wealth FAC1_1 and household per capita expenditure quintiles.
*NONPAR CORR
  /VARIABLES=HHExpAllCapita FAC1_1
  /PRINT=SPEARMAN TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.

*Based on low scores on rotated component matrix and zik/zak curve in percentile take out: freez car, persons bicycle    

*Clean.
*DELETE VARIABLES FAC1_1 FAC2_1 FAC3_1 NFAC1_1.

*****************************************.
*Third factor iteration. - use for wealth.
FACTOR
  /VARIABLES tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED 
  /MISSING LISTWISE 
  /ANALYSIS tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED 
  /PRINT INITIAL CORRELATION KMO AIC EXTRACTION ROTATION
  /FORMAT SORT
  /PLOT EIGEN
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

RANK VARIABLES=FAC1_1 (A)
  /NTILES(5)
  /PRINT=YES
  /TIES=MEAN.

CTABLES
  /VLABELS VARIABLES= tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED NFAC1_1 DISPLAY=LABEL
  /TABLE 
    tmpWalls [MEAN] +tmpFloor [MEAN] + tmpToilet[MEAN] + tmpWater[MEAN] + tmpLight[MEAN] + tmpCook[MEAN] + tmpTV[MEAN] + tmpLED[MEAN] 
    BY NFAC1_1  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=NFAC1_1 ORDER=A KEY=VALUE EMPTY=EXCLUDE.

*correlation between third iteration wealth FAC1_1 and household per capita expenditure quintiles.
NONPAR CORR
  /VARIABLES=HHExpAllCapita FAC1_1
  /PRINT=SPEARMAN TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.

*check.
FREQUENCIES FAC1_1 NFAC1_1.

*FINAL STEP:
*Label final wealth index (quintile at national level).
RENAME VARIABLES FAC1_1 = NatWealthScore.
RENAME VARIABLES NFAC1_1 = NatWealthQuint.
VARIABLE LABELS NatWealthQuint 'Wealth quintile (National level)'.
VALUE LABELS  NatWealthQuint 1 "1st Lowest wealth" 2 "2nd"  3 "3rd" 4 "4th" 5 "5th Highest wealth". 

*Check.
FREQUENCIES NatWealthQuint NatWealthScore.

*check final factor items by exp quintile urban AND rural total.
*CTABLES
  /VLABELS VARIABLES= tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED tmpPersInHH tmpPers tmpRoof tmpBed tmpTable
tmpBicycle tmpMC tmpCar tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC tmpPot
tmpPump tmpTrad tmpSave tmpLand tmpCattle tmpSmall tmpBirds NatExpQuint DISPLAY=LABEL
  /TABLE 
    tmpWalls [MEAN] + tmpFloor [MEAN] + tmpToilet[MEAN] + tmpWater[MEAN] + tmpLight[MEAN] + tmpCook[MEAN] + tmpTV[MEAN] + tmpLED[MEAN] +
    tmpPersInHH [MEAN] + tmpPers[MEAN] + tmpRoof  [MEAN] + tmpBed [MEAN] + tmpTable  [MEAN] + tmpBicycle [MEAN] + tmpMC [MEAN] +
    tmpCar [MEAN] + tmpRadio1 [MEAN] + tmpRadio2 [MEAN] + tmpCharge [MEAN] + tmpFan [MEAN] + tmpRefrig [MEAN] + tmpMicro [MEAN] +
    tmpFreez [MEAN] + tmpWash [MEAN] + tmpSewing [MEAN] + tmpAC [MEAN] + tmpPC [MEAN] + tmpPot [MEAN] + tmpPump [MEAN] + 
    tmpTrad [MEAN] + tmpSave [MEAN] + tmpLand [MEAN] + tmpCattle [MEAN] + tmpSmall [MEAN] + tmpBirds [MEAN] 
    BY NatExpQuint /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=NatExpQuint ORDER=A KEY=VALUE EMPTY=EXCLUDE.

*Clean.
DELETE VARIABLES tmpPersInHH tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBed tmpTable tmpBicycle tmpMC tmpCar 
tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC tmpPot tmpTV tmpPump 
tmpTrad tmpLED tmpSave tmpLand tmpCattle tmpSmall tmpBirds.

OUTPUT CLOSE ALL.

***********************************************************************************************************************.

*9) CREATE RELATIVE VALUE OF ASSET SCORE - CURRENT AND 5 YEARS AGO.
  
*A) CURRENT ASSETS.
*Bed weighted.
COMPUTE currBed = 0.
IF ( (L2$01 = 1 AND L2A$01 = 1) OR (L2$02 = 1 AND L2A$02 = 1) OR (L2$03 = 1 AND L2A$03 = 1) OR (L2$20 = 1 AND L2A$20 GT 0) ) currBed = 275000. 
*FREQUENCIES currBed. 
*Table weighted..
COMPUTE currTable = 0.
IF ( (L2$01 = 2 AND L2A$01 = 1) OR (L2$02 = 2 AND L2A$02 = 1) OR (L2$03 = 2 AND L2A$03 = 1) ) currTable = 212500. 
*FREQUENCIES currTable
*Bicycle weighted..
COMPUTE currBicycle = 0.
IF ( (L2$03 = 3 AND L2A$03 = 1) OR (L2$04 = 3 AND L2A$04 = 1) ) currBicycle = 170000. 
*FREQUENCIES currBicycle.
*Motorcycle weighted..
COMPUTE currMC = 0.
IF ( (L2$04 = 4 AND L2A$04 = 1) OR (L2$05 = 4 AND L2A$05 = 1) ) currMC = 3000000. 
*FREQUENCIES currMC.
*Car.weighted.
COMPUTE currCar = 0.
IF (L2$05 = 5 AND L2A$05 = 1) currCar = 18000000.
*FREQUENCIES currCar. 
*RadioBatt weighted .
COMPUTE currRadio1 = 0.
IF (L2$06 = 6 AND L2A$06 = 1)  currRadio1 = 24000.
*FREQUENCIES currRadio1.
*Radio electric weighted..
COMPUTE currRadio2 = 0.
IF (L2$08 = 8 AND L2A$08 = 1) currRadio2 = 357500.
*FREQUENCIES currRadio2.
*MobileCharge weighted..
COMPUTE currCharge = 0.
IF ( (L2$07 = 7 AND L2A$07 = 1) OR (L2$08 = 7 AND L2A$08 = 1)  OR  (L2$22 = 7 AND L2A$22 GT 0)   ) currCharge = 30000. 
*FREQUENCIES currCharge.
*Fan weighted.
COMPUTE currFan = 0.
IF (L2$09 = 9 AND L2A$09 = 1) currFan = 214000.
*FREQUENCIES currFan.
*Refrigerator.weighted.
COMPUTE currRefrig = 0.
IF ( (L2$10 = 10 AND L2A$10 = 1) OR (L2$22 = 10 AND L2A$22 GT 0) OR (L2$19 = 10 AND L2A$19 = 1)  ) currRefrig = 640000.
*FREQUENCIES currRefrig.
*MicroW.weighted.
COMPUTE currMicro = 0.
IF (L2$11 = 11 AND L2A$11 = 1) currMicro= 260000.
*FREQUENCIES currMicro.
*Freez.weighted.
COMPUTE currFreez = 0.
IF ( (L2$12 = 12 AND L2A$12 = 1) OR  (L2$14 = 12 AND L2A$14 = 1) )   currFreez = 1055000.
*FREQUENCIES currFreez.
*Washmachine weighted..
COMPUTE currWash = 0.
IF (L2$13 = 13 AND L2A$13 = 1) currWash = 1055000.
*FREQUENCIES currWash.
*Sewingmachine el. weighted.
COMPUTE currSewing = 0.
IF (L2$14 = 14 AND L2A$14 = 1) currSewing = 500000.
*FREQUENCIES currSewing.
*AC.weighted.
COMPUTE currAC = 0.
IF (L2$15 = 15 AND L2A$15 = 1) currAC = 1450000.
*FREQUENCIES currAC.
*PC.weighted.
COMPUTE currPC=0.
IF (L2$16 = 16 AND L2A$16 = 1) currPC = 1250000..
*FREQUENCIES currPC.
*PotEl.
COMPUTE currPot = 0.
IF ( (L2$17 = 17 AND L2A$17 = 1) OR (L2$19 = 17 AND L2A$19 = 1) ) currPot = 75250.
*FREQUENCIES currPot. 
*TV weighted..
COMPUTE currTV = 0.
IF ( (L2$18 = 18 AND L2A$18 = 1) OR (L2$19 = 18 AND L2A$19 = 1) OR (L2$20 = 18 AND L2A$20 GT 0)   ) currTV = 810000. 
*FREQUENCIES currTV.
*WatewrpumpEl.weighted.
COMPUTE currPump = 0.
IF (L2$19 = 19 AND L2A$19 = 1) currPump = 400000.
*FREQUENCIES currPump.
*Traditional light bulbs.weighted.
COMPUTE currTrad = 0.
IF (  (L2$20 = 20 AND L2A$20 > 0)  OR (L2$21 = 20 AND L2A$21 GT 0) ) currTrad = 1500. 
*FREQUENCIES currTrad.
*LED light bulbs weighted..
COMPUTE currLED = 0.
IF ( (L2$21 = 21 AND L2A$21 GT 0) OR (L2$22 = 21 AND L2A$22 GT 0) )  currLED = 2000. 
*FREQUENCIES currLED.
*ElSaving bulbs.weighted.
COMPUTE currSave = 0.
IF (L2$22 = 22 AND L2A$22 GT 0) currSave = 2000.
*FREQUENCIES currSave.

*sum up current relative values.
COMPUTE AssetsCurrValueScore = SUM(currBed TO currSave).
VARIABLE LABELS AssetsCurrValueScore 'Value score of households current assets'.
EXECUTE.

*check.
FREQUENCIES AssetsCurrValueScore.

*Clean.
DELETE VARIABLES currBed currTable currBicycle currMC currCar currRadio1 currRadio2 currCharge currFan currRefrig currMicro currFreez currWash currSewing
currAC currPC currPot currTV currPump currTrad currLED currSave.

*B) ASSETS 5 YEARS AGO.
*Bed weighted.
COMPUTE YBed = 0.
IF ( (L2$01 = 1 AND L2C$01 = 1) OR (L2$02 = 1 AND L2C$02 = 1) OR (L2$03 = 1 AND L2C$03 = 1) OR (L2$20 = 1 AND L2C$20 = 1) ) YBed = 275000. 
*FREQUENCIES YBed. 
*Table weighted..
COMPUTE YTable = 0.
IF ( (L2$01 = 2 AND L2C$01 = 1) OR (L2$02 = 2 AND L2C$02 = 1) OR (L2$03 = 2 AND L2C$03 = 1) ) YTable = 212500. 
*FREQUENCIES YTable
*Bicycle weighted..
COMPUTE YBicycle = 0.
IF ( (L2$03 = 3 AND L2C$03 = 1) OR (L2$04 = 3 AND L2C$04 = 1) ) YBicycle = 170000. 
*FREQUENCIES YBicycle.
*Motorcycle weighted..
COMPUTE YMC = 0.
IF ( (L2$04 = 4 AND L2C$04 = 1) OR (L2$05 = 4 AND L2C$05 = 1) ) YMC = 3000000. 
*FREQUENCIES YMC.
*Car.weighted.
COMPUTE YCar = 0.
IF (L2$05 = 5 AND L2C$05 = 1) YCar = 18000000.
*FREQUENCIES YCar. 
*RadioBatt weighted .
COMPUTE YRadio1 = 0.
IF (L2$06 = 6 AND L2C$06 = 1)  YRadio1 = 24000.
*FREQUENCIES YRadio1.
*Radio electric weighted..
COMPUTE YRadio2 = 0.
IF (L2$08 = 8 AND L2C$08 = 1) YRadio2 = 357500.
*FREQUENCIES YRadio2.
*MobileCharge weighted..
COMPUTE YCharge = 0.
IF ( (L2$07 = 7 AND L2C$07 = 1) OR (L2$08 = 7 AND L2C$08 = 1)  OR  (L2$22 = 7 AND L2C$22 = 1)   ) YCharge = 30000. 
*FREQUENCIES YCharge.
*Fan weighted.
COMPUTE YFan = 0.
IF (L2$09 = 9 AND L2C$09 = 1) YFan = 214000.
*FREQUENCIES YFan.
*Refrigerator.weighted.
COMPUTE YRefrig = 0.
IF ( (L2$10 = 10 AND L2C$10 = 1) OR (L2$22 = 10 AND L2C$22 = 1) OR (L2$19 = 10 AND L2C$19 = 1)  ) YRefrig = 640000.
*FREQUENCIES YRefrig.
*MicroW.weighted.
COMPUTE YMicro = 0.
IF (L2$11 = 11 AND L2C$11 = 1) YMicro= 260000.
*FREQUENCIES YMicro.
*Freez.weighted.
COMPUTE YFreez = 0.
IF ( (L2$12 = 12 AND L2C$12 = 1) OR  (L2$14 = 12 AND L2C$14 = 1) )   YFreez = 1055000.
*FREQUENCIES YFreez.
*Washmachine weighted..
COMPUTE YWash = 0.
IF (L2$13 = 13 AND L2C$13 = 1) YWash = 1055000.
*FREQUENCIES YWash.
*Sewingmachine el. weighted.
COMPUTE YSewing = 0.
IF (L2$14 = 14 AND L2C$14 = 1) YSewing = 500000.
*FREQUENCIES YSewing.
*AC.weighted.
COMPUTE YAC = 0.
IF (L2$15 = 15 AND L2C$15 = 1) YAC = 1450000.
*FREQUENCIES YAC.
*PC.weighted.
COMPUTE YPC=0.
IF (L2$16 = 16 AND L2C$16 = 1) YPC = 1250000.
*FREQUENCIES YPC.
*PotEl.
COMPUTE YPot = 0.
IF ( (L2$17 = 17 AND L2C$17 = 1) OR (L2$19 = 17 AND L2C$19 = 1) ) YPot = 75250.
*FREQUENCIES YPot. 
*TV weighted..
COMPUTE YTV = 0.
IF ( (L2$18 = 18 AND L2C$18 = 1) OR (L2$19 = 18 AND L2C$19 = 1) OR (L2$20 = 18 AND L2C$20 = 1)   ) YTV = 810000. 
*FREQUENCIES YTV.
*WatewrpumpEl.weighted.
COMPUTE YPump = 0.
IF (L2$19 = 19 AND L2C$19 = 1) YPump = 400000.
*FREQUENCIES YPump.
*Traditional light bulbs.weighted.
COMPUTE YTrad = 0.
IF (  (L2$20 = 20 AND L2C$20 = 1)  OR (L2$21 = 20 AND L2C$21 = 1) ) YTrad = 1500. 
*FREQUENCIES YTrad.
*LED light bulbs weighted..
COMPUTE YLED = 0.
IF ( (L2$21 = 21 AND L2C$21 = 1) OR (L2$22 = 21 AND L2C$22 = 1) )  YLED = 2000. 
*FREQUENCIES YLED.
*ElSaving bulbs.weighted.
COMPUTE YSave = 0.
IF (L2$22 = 22 AND L2C$22 = 1) YSave = 2000.
*FREQUENCIES YSave.

*sum up values 5 years ago.
COMPUTE Assets5agoValueScore = SUM(YBed TO YSave).
VARIABLE LABELS Assets5agoValueScore 'Value score of households assets 5 years ago'.
EXECUTE.

*check.
FREQUENCIES Assets5agoValueScore.

*Clean.
DELETE VARIABLES YBed YTable YBicycle YMC YCar YRadio1 YRadio2 YCharge YFan YRefrig YMicro YFreez YWash YSewing
YAC YPC YPot YTV YPump YTrad YLED YSave.

*Change check 1.
COMPUTE tmpDiff = (AssetsCurrValueScore - Assets5agoValueScore).
EXECUTE.
FREQUENCIES tmpDiff.

OUTPUT CLOSE ALL.

********************************************************************************************************
*Possible other derived variables in here?
*fexe dependency ratios??    .



**********************************************************************************************************************.
**********************************************************************************************************************.
*Save temporary HHQ + COM file and open again.
SAVE OUTFILE='tmp\TZHHCOM_2a.sav'
/KEEP 
ALL 
/COMPRESSED.
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 

***********************************************************************************************************************.
*Open  tempoary file and continue .
GET FILE='tmp\TZHHCOM_2a.sav'.
SET DECIMAL=DOT.

*Check the input file..
FREQUENCIES Region.

*********************************************''.
*WEIGHTS.
*From Bjørn 27.05.2022 .
*Create EA weights (1000 hh).

IF(GeocodeEA= "01012711101008") WEIGHT= 2.81.
IF(GeocodeEA= "01060511103004") WEIGHT= 3.21.
IF(GeocodeEA="01011111101001" ) WEIGHT= 3.06.
IF(GeocodeEA="01030711103005" ) WEIGHT= 2.93.
IF(GeocodeEA="01041911101017" ) WEIGHT= 3.21.
IF(GeocodeEA="01071111102001" ) WEIGHT= 3.21.
IF(GeocodeEA="01022311102003" ) WEIGHT= 2.81.
IF(GeocodeEA="01051231103007" ) WEIGHT= 2.93.
IF(GeocodeEA="01020531102313" ) WEIGHT= 1.17.
IF(GeocodeEA="01050321104002" ) WEIGHT= 1.12.
IF(GeocodeEA="01052821106006" ) WEIGHT= 1.44.
IF(GeocodeEA="01052921101006" ) WEIGHT= 1.44.

IF(GeocodeEA="02040311101004" ) WEIGHT= 2.83.
IF(GeocodeEA="02020111102005" ) WEIGHT= 2.48.
IF(GeocodeEA="02040211104004" ) WEIGHT= 2.48.
IF(GeocodeEA="02060731101007" ) WEIGHT= 2.48.
IF(GeocodeEA="02010711101003" ) WEIGHT= 3.71.
IF(GeocodeEA="02051311102014" ) WEIGHT= 2.83.
IF(GeocodeEA="02020331101301" ) WEIGHT= 1.60.
IF(GeocodeEA="02030621104006" ) WEIGHT= 1.53.
IF(GeocodeEA="02031121105003" ) WEIGHT= 1.67.
IF(GeocodeEA="02031621101001" ) WEIGHT= 1.95.
IF(GeocodeEA="02040131103316" ) WEIGHT= 1.95.

IF(GeocodeEA="03010411102001" ) WEIGHT= 3.08.
IF(GeocodeEA="03012111102001" ) WEIGHT= 4.50.
IF(GeocodeEA="03031911101003" ) WEIGHT= 4.18.
IF(GeocodeEA="03041011102003" ) WEIGHT= 4.18.
IF(GeocodeEA="03042511107005" ) WEIGHT= 4.50.
IF(GeocodeEA="03050711102003" ) WEIGHT= 3.90.
IF(GeocodeEA="03031631103002" ) WEIGHT= 2.79.
IF(GeocodeEA="03020221109002" ) WEIGHT= 1.87.
IF(GeocodeEA="03032431102317" ) WEIGHT= 1.54.
IF(GeocodeEA="03060321102001" ) WEIGHT= 2.02.
IF(GeocodeEA="03061121102001" ) WEIGHT= 1.87.
IF(GeocodeEA="03051021111001" ) WEIGHT= 2.62.

IF(GeocodeEA="04013711101001" ) WEIGHT= 2.87.
IF(GeocodeEA="04011611105006" ) WEIGHT= 2.52.
IF(GeocodeEA="04020631109005" ) WEIGHT= 3.35.
IF(GeocodeEA="04032711103001" ) WEIGHT= 3.02.
IF(GeocodeEA="04070311101003" ) WEIGHT= 3.77.
IF(GeocodeEA="04011811106002" ) WEIGHT= 2.52.
IF(GeocodeEA="04032011106001" ) WEIGHT= 3.35.
IF(GeocodeEA="04062011104002" ) WEIGHT= 3.02.
IF(GeocodeEA="04101021105002" ) WEIGHT= 2.04.
IF(GeocodeEA="04040321107001" ) WEIGHT= 1.66.
IF(GeocodeEA="04041021112001" ) WEIGHT= 1.47.
IF(GeocodeEA="04041921106001" ) WEIGHT= 1.40.
IF(GeocodeEA="04101021102002" ) WEIGHT= 1.66.

IF(GeocodeEA="05060131106004" ) WEIGHT= 2.64.
IF(GeocodeEA="05010511106010" ) WEIGHT= 2.88.
IF(GeocodeEA="05030731103001" ) WEIGHT= 2.76.
IF(GeocodeEA="05061511101009" ) WEIGHT= 2.88.
IF(GeocodeEA="05020311103001" ) WEIGHT= 2.76.
IF(GeocodeEA="05030131102018" ) WEIGHT= 2.64.
IF(GeocodeEA="05041511101007" ) WEIGHT= 2.88.
IF(GeocodeEA="05070711101005" ) WEIGHT= 2.88.
IF(GeocodeEA="05060831101330" ) WEIGHT= 1.79.
IF(GeocodeEA="05022231101313" ) WEIGHT= 1.70.
IF(GeocodeEA="05050921108006" ) WEIGHT= 1.89.
IF(GeocodeEA="05051221112002" ) WEIGHT= 1.89.
IF(GeocodeEA="05011521101001" ) WEIGHT= 1.89.
IF(GeocodeEA="05031631106301" ) WEIGHT= 2.00.

IF(GeocodeEA="06020731101002" ) WEIGHT= 2.03.
IF(GeocodeEA="06011231103010" ) WEIGHT= 2.21.
IF(GeocodeEA="06050611104002" ) WEIGHT= 2.32.
IF(GeocodeEA="06012111102001" ) WEIGHT= 2.21.
IF(GeocodeEA="06041211101003" ) WEIGHT= 1.94.
IF(GeocodeEA="06010621101002" ) WEIGHT= 1.25.
IF(GeocodeEA="06030131101302" ) WEIGHT= 1.32.
IF(GeocodeEA="06041131104303" ) WEIGHT= 1.19.
IF(GeocodeEA="06070221102005" ) WEIGHT= 1.19.
IF(GeocodeEA="06070721103002" ) WEIGHT= 1.25.

IF(GeocodeEA="07010221103084" ) WEIGHT= 3.49.
IF(GeocodeEA="07010621105030" ) WEIGHT= 3.66.
IF(GeocodeEA="07011121101011" ) WEIGHT= 3.33.
IF(GeocodeEA="07011521102063" ) WEIGHT= 3.49.
IF(GeocodeEA="07012221105004" ) WEIGHT= 3.18.
IF(GeocodeEA="07012521105024" ) WEIGHT= 5.23.
IF(GeocodeEA="07012821107039" ) WEIGHT= 4.07.
IF(GeocodeEA="07013421101010" ) WEIGHT= 3.66.
IF(GeocodeEA="07020821102024" ) WEIGHT= 4.07.
IF(GeocodeEA="07021021104013" ) WEIGHT= 3.66.
IF(GeocodeEA="07021921104008" ) WEIGHT= 4.07.
IF(GeocodeEA="07022321102055" ) WEIGHT= 3.66.
IF(GeocodeEA="07022621104064" ) WEIGHT= 4.07.
IF(GeocodeEA="07030821105004" ) WEIGHT= 4.07.
IF(GeocodeEA="07031021107008" ) WEIGHT= 3.66.
IF(GeocodeEA="07031521103006" ) WEIGHT= 4.31.
IF(GeocodeEA="07031921102007" ) WEIGHT= 4.07.
IF(GeocodeEA="07032221103041" ) WEIGHT= 3.66.
IF(GeocodeEA="07032721103007" ) WEIGHT= 3.86.
IF(GeocodeEA="07032821106062" ) WEIGHT= 4.07.
IF(GeocodeEA="07010321104023" ) WEIGHT= 3.49.

IF(GeocodeEA="08030711105004" ) WEIGHT= 1.95.
IF(GeocodeEA="08011311103005" ) WEIGHT= 2.39.
IF(GeocodeEA="08022711105002" ) WEIGHT= 1.87.
IF(GeocodeEA="08052011103003" ) WEIGHT= 2.69.
IF(GeocodeEA="08023011104004" ) WEIGHT= 3.07.
IF(GeocodeEA="08041111101004" ) WEIGHT= 1.95.
IF(GeocodeEA="08012021106002" ) WEIGHT= 1.10.
IF(GeocodeEA="08060421103002" ) WEIGHT= 0.86.
IF(GeocodeEA="08061521103006" ) WEIGHT= 1.10.

IF(GeocodeEA="09032011106003" ) WEIGHT= 2.42.
IF(GeocodeEA="09012211102001" ) WEIGHT= 3.14.
IF(GeocodeEA="09030831102010" ) WEIGHT= 2.42.
IF(GeocodeEA="09061111102004" ) WEIGHT= 2.42.
IF(GeocodeEA="09020311105003" ) WEIGHT= 2.96.
IF(GeocodeEA="09031911109002" ) WEIGHT= 2.42.
IF(GeocodeEA="09060431105001" ) WEIGHT= 2.42.
IF(GeocodeEA="09030831107318" ) WEIGHT= 1.32.
IF(GeocodeEA="09050321101001" ) WEIGHT= 1.26.
IF(GeocodeEA="09060131104309" ) WEIGHT= 1.63.
IF(GeocodeEA="09060431107303" ) WEIGHT= 1.26.

IF(GeocodeEA="10032411103002" ) WEIGHT= 2.43.
IF(GeocodeEA="10031511101003" ) WEIGHT= 2.55.
IF(GeocodeEA="10011911104001" ) WEIGHT= 3.15.
IF(GeocodeEA="10030211101008" ) WEIGHT= 2.82.
IF(GeocodeEA="10050131102002" ) WEIGHT= 2.43.
IF(GeocodeEA="10060711102003" ) WEIGHT= 2.55.
IF(GeocodeEA="10013431102303" ) WEIGHT= 2.01.
IF(GeocodeEA="10040421101003" ) WEIGHT= 1.31.
IF(GeocodeEA="10041221105001" ) WEIGHT= 1.64.
IF(GeocodeEA="10041321106001" ) WEIGHT= 1.38.

IF(GeocodeEA="11021611103001" ) WEIGHT= 2.68.
IF(GeocodeEA="11010311106007" ) WEIGHT= 1.98.
IF(GeocodeEA="11021211104001" ) WEIGHT= 2.68.
IF(GeocodeEA="11010611106001" ) WEIGHT= 2.40.
IF(GeocodeEA="11042011101003" ) WEIGHT= 2.53.
IF(GeocodeEA="11010831101301" ) WEIGHT= 1.07.
IF(GeocodeEA="11030321103001" ) WEIGHT= 0.93.
IF(GeocodeEA="11031021110003" ) WEIGHT= 1.07.
IF(GeocodeEA="11050221104002" ) WEIGHT= 0.93.

IF(GeocodeEA="12040611103003" ) WEIGHT= 2.73.
IF(GeocodeEA="12020811102003" ) WEIGHT= 2.61.
IF(GeocodeEA="12040511105001" ) WEIGHT= 2.61.
IF(GeocodeEA="12070711103007" ) WEIGHT= 2.73.
IF(GeocodeEA="12020711102002" ) WEIGHT= 2.73.
IF(GeocodeEA="12070431102007" ) WEIGHT= 3.16.
IF(GeocodeEA="12032021111005" ) WEIGHT= 1.92.
IF(GeocodeEA="12080621101005" ) WEIGHT= 2.13.
IF(GeocodeEA="12081621102003" ) WEIGHT= 2.02.
IF(GeocodeEA="12082521101008" ) WEIGHT= 2.40.
IF(GeocodeEA="12083021105002" ) WEIGHT= 2.13.

IF(GeocodeEA="13021011102003" ) WEIGHT= 2.30.
IF(GeocodeEA="13060111101001" ) WEIGHT= 2.21.
IF(GeocodeEA="13032611101002" ) WEIGHT= 2.12.
IF(GeocodeEA="13020511102005" ) WEIGHT= 2.12.
IF(GeocodeEA="13040511101006" ) WEIGHT= 2.21.
IF(GeocodeEA="13060111104002" ) WEIGHT= 2.12.
IF(GeocodeEA="13030131102326" ) WEIGHT= 0.75.
IF(GeocodeEA="13041421101001" ) WEIGHT= 0.75.
IF(GeocodeEA="13050331105306" ) WEIGHT= 0.75.

IF(GeocodeEA="14021311103002" ) WEIGHT= 2.56.
IF(GeocodeEA="14071011102001" ) WEIGHT= 2.68.
IF(GeocodeEA="14030711103001" ) WEIGHT= 2.36.
IF(GeocodeEA="14070311104005" ) WEIGHT= 2.26.
IF(GeocodeEA="14012511101003" ) WEIGHT= 2.68.
IF(GeocodeEA="14021711104011" ) WEIGHT= 2.56.
IF(GeocodeEA="14031711102022" ) WEIGHT= 2.68.
IF(GeocodeEA="14070611102013" ) WEIGHT= 2.36.
IF(GeocodeEA="14021631102310" ) WEIGHT= 0.89.
IF(GeocodeEA="14060321106005" ) WEIGHT= 0.89.
IF(GeocodeEA="14060821104013" ) WEIGHT= 0.70.
IF(GeocodeEA="14040231101312" ) WEIGHT= 0.68.

IF(GeocodeEA="15020511105008" ) WEIGHT= 1.87.
IF(GeocodeEA="15010431105001" ) WEIGHT= 1.87.
IF(GeocodeEA="15020231106001" ) WEIGHT= 1.95.
IF(GeocodeEA="15021111106002" ) WEIGHT= 1.95.
IF(GeocodeEA="15040711102006" ) WEIGHT= 1.87.
IF(GeocodeEA="15031621112001" ) WEIGHT= 0.79.
IF(GeocodeEA="15040421108003" ) WEIGHT= 0.92.
IF(GeocodeEA="15041421109011" ) WEIGHT= 1.10.
IF(GeocodeEA="15031621135001" ) WEIGHT= 0.92.

IF(GeocodeEA="16011311103010" ) WEIGHT= 2.96.
IF(GeocodeEA="16051111101009" ) WEIGHT= 3.46.
IF(GeocodeEA="16071111103001" ) WEIGHT= 2.96.
IF(GeocodeEA="16050811101004" ) WEIGHT= 2.83.
IF(GeocodeEA="16020211102006" ) WEIGHT= 3.28.
IF(GeocodeEA="16050411102002" ) WEIGHT= 2.49.
IF(GeocodeEA="16070311102003" ) WEIGHT= 2.83.
IF(GeocodeEA="16031131103003" ) WEIGHT= 1.13.
IF(GeocodeEA="16041321102002" ) WEIGHT= 1.13.
IF(GeocodeEA="16041921102003" ) WEIGHT= 2.26.
IF(GeocodeEA="16011031103309" ) WEIGHT= 0.94.

IF(GeocodeEA="17031111103009" ) WEIGHT= 3.01.
IF(GeocodeEA="17010431102005" ) WEIGHT= 2.69.
IF(GeocodeEA="17041011104002" ) WEIGHT= 2.43.
IF(GeocodeEA="17021511101001" ) WEIGHT= 2.69.
IF(GeocodeEA="17040531102004" ) WEIGHT= 2.22.
IF(GeocodeEA="17043431104002" ) WEIGHT= 2.13.
IF(GeocodeEA="17010321103016" ) WEIGHT= 0.73.
IF(GeocodeEA="17011521105006" ) WEIGHT= 0.85.
IF(GeocodeEA="17041631104313" ) WEIGHT= 0.76.
IF(GeocodeEA="17051321104014" ) WEIGHT= 0.85.

IF(GeocodeEA="18010311102003" ) WEIGHT= 2.91.
IF(GeocodeEA="18040811103002" ) WEIGHT= 3.04.
IF(GeocodeEA="18010831102009" ) WEIGHT= 2.79.
IF(GeocodeEA="18021611102006" ) WEIGHT= 3.04.
IF(GeocodeEA="18032211103011" ) WEIGHT= 2.91.
IF(GeocodeEA="18040331102009" ) WEIGHT= 2.91.
IF(GeocodeEA="18071211105006" ) WEIGHT= 3.04.
IF(GeocodeEA="18010631101002" ) WEIGHT= 2.79.
IF(GeocodeEA="18032411104001" ) WEIGHT= 2.91.
IF(GeocodeEA="18050611102010" ) WEIGHT= 2.79.
IF(GeocodeEA="18033431101307" ) WEIGHT= 1.00.
IF(GeocodeEA="18060321103003" ) WEIGHT= 1.06.
IF(GeocodeEA="18060821101018" ) WEIGHT= 0.85.
IF(GeocodeEA="18070431101321" ) WEIGHT= 0.85.

IF(GeocodeEA="19020131101006" ) WEIGHT= 2.83.
IF(GeocodeEA="19071411101005" ) WEIGHT= 2.83.
IF(GeocodeEA="19040211101001" ) WEIGHT= 3.10.
IF(GeocodeEA="19051111103005" ) WEIGHT= 2.96.
IF(GeocodeEA="19070411103002" ) WEIGHT= 2.96.
IF(GeocodeEA="19040111104004" ) WEIGHT= 2.83.
IF(GeocodeEA="19052611101019" ) WEIGHT= 3.42.
IF(GeocodeEA="19010221105002" ) WEIGHT= 1.71.
IF(GeocodeEA="19030321106009" ) WEIGHT= 2.03.
IF(GeocodeEA="19030821108004" ) WEIGHT= 1.63.
IF(GeocodeEA="19031221106001" ) WEIGHT= 1.71.
IF(GeocodeEA="19060221107002" ) WEIGHT= 1.71.
IF(GeocodeEA="19060521105006" ) WEIGHT= 1.71.
IF(GeocodeEA="19071031103310" ) WEIGHT= 1.71.

IF(GeocodeEA="20041011102002" ) WEIGHT= 2.16.
IF(GeocodeEA="20011011104005" ) WEIGHT= 2.88.
IF(GeocodeEA="20022111101003" ) WEIGHT= 2.88.
IF(GeocodeEA="20041511103001" ) WEIGHT= 3.05.
IF(GeocodeEA="20061611105003" ) WEIGHT= 12.95.
IF(GeocodeEA="20011011102003" ) WEIGHT= 2.73.
IF(GeocodeEA="20070511101004" ) WEIGHT= 3.98.
IF(GeocodeEA="20012321101002" ) WEIGHT= 0.95.
IF(GeocodeEA="20042531101303" ) WEIGHT= 1.00.
IF(GeocodeEA="20050821101009" ) WEIGHT= 1.06.
IF(GeocodeEA="20050621104014" ) WEIGHT= 0.91.

IF(GeocodeEA="21022511101001" ) WEIGHT= 1.98.
IF(GeocodeEA="21010211102002" ) WEIGHT= 2.26.
IF(GeocodeEA="21020911104008" ) WEIGHT= 2.37.
IF(GeocodeEA="21041311101002" ) WEIGHT= 2.15.
IF(GeocodeEA="21011711105002" ) WEIGHT= 2.06.
IF(GeocodeEA="21031911101001" ) WEIGHT= 3.16.
IF(GeocodeEA="21050811101001" ) WEIGHT= 2.37.
IF(GeocodeEA="21051431102301" ) WEIGHT= 1.22.
IF(GeocodeEA="21030721101005" ) WEIGHT= 1.10.
IF(GeocodeEA="21060331103302" ) WEIGHT= 1.10.

IF(GeocodeEA="22020431106001" ) WEIGHT= 1.30.
IF(GeocodeEA="22040731102003" ) WEIGHT= 1.24.
IF(GeocodeEA="22020911101009" ) WEIGHT= 1.45.
IF(GeocodeEA="22032011101006" ) WEIGHT= 1.45.
IF(GeocodeEA="22011111101003" ) WEIGHT= 1.13.
IF(GeocodeEA="22031611104003" ) WEIGHT= 1.24.
IF(GeocodeEA="22050811101004" ) WEIGHT= 1.24.
IF(GeocodeEA="22010121109006" ) WEIGHT= 0.83.
IF(GeocodeEA="22030231105311" ) WEIGHT= 0.83.
IF(GeocodeEA="22060221101009" ) WEIGHT= 1.09.
IF(GeocodeEA="22040811102303" ) WEIGHT= 0.74.

IF(GeocodeEA="23020211108002" ) WEIGHT= 0.61.
IF(GeocodeEA="23020711102006" ) WEIGHT= 0.64.
IF(GeocodeEA="23031531101001" ) WEIGHT= 0.67.
IF(GeocodeEA="23031211102001" ) WEIGHT= 0.77.
IF(GeocodeEA="23031911102005" ) WEIGHT= 0.61.
IF(GeocodeEA="23030211103002" ) WEIGHT= 0.64.
IF(GeocodeEA="23032211101008" ) WEIGHT= 0.67.
IF(GeocodeEA="23010421102019" ) WEIGHT= 0.44.
IF(GeocodeEA="23010621104003" ) WEIGHT= 0.47.
IF(GeocodeEA="23010821102001" ) WEIGHT= 0.53.
IF(GeocodeEA="23020831101313" ) WEIGHT= 0.47.
IF(GeocodeEA="23010721103005" ) WEIGHT= 0.42.

IF(GeocodeEA="24031911101008" ) WEIGHT= 2.78.
IF(GeocodeEA="24011111102005" ) WEIGHT= 2.64.
IF(GeocodeEA="24041611101003" ) WEIGHT= 2.09.
IF(GeocodeEA="24011211103003" ) WEIGHT= 2.64.
IF(GeocodeEA="24022011105001" ) WEIGHT= 2.50.
IF(GeocodeEA="24042211103001" ) WEIGHT= 2.00.
IF(GeocodeEA="24050631104314" ) WEIGHT= 0.42.
IF(GeocodeEA="24030131103311" ) WEIGHT= 0.31.
IF(GeocodeEA="24042631102309" ) WEIGHT= 0.42.

IF(GeocodeEA="25010611107003" ) WEIGHT= 3.13.
IF(GeocodeEA="25040611105001" ) WEIGHT= 2.45.
IF(GeocodeEA="25052131101003" ) WEIGHT= 2.45.
IF(GeocodeEA="25010611103002" ) WEIGHT= 2.09.
IF(GeocodeEA="25012611103001" ) WEIGHT= 2.35.
IF(GeocodeEA="25021111104002" ) WEIGHT= 2.68.
IF(GeocodeEA="25052131106306" ) WEIGHT= 0.81.
IF(GeocodeEA="25012831102321" ) WEIGHT= 0.85.
IF(GeocodeEA="25013521114008" ) WEIGHT= 0.70.
IF(GeocodeEA="25013521128002" ) WEIGHT= 0.81.

IF(GeocodeEA="26060111101008" ) WEIGHT= 2.15.
IF(GeocodeEA="26060511102002" ) WEIGHT= 2.25.
IF(GeocodeEA="26060111107002" ) WEIGHT= 2.49.
IF(GeocodeEA="26060911106010" ) WEIGHT= 2.15.
IF(GeocodeEA="26090311107004" ) WEIGHT= 2.15.
IF(GeocodeEA="26061821125001" ) WEIGHT= 1.22.
IF(GeocodeEA="26100121122001" ) WEIGHT= 1.38.
IF(GeocodeEA="26061531101375" ) WEIGHT= 1.09.
IF(GeocodeEA="26100121111003" ) WEIGHT= 1.15.
IF(GeocodeEA="26100121128003" ) WEIGHT= 1.09.

*Adjustment from Bjørn 27.05.2022.
COMPUTE WEIGHT=WEIGHT * 1.0027. 

EXECUTE.

VARIABLE LABELS WEIGHT "Household-level weight (1000 households)".

*Check hh level weights.
FREQUENCIES WEIGHT.

*********************
*Compute Weights at person level.
COMPUTE POPWEIGHT = WEIGHT * HHsize.
EXECUTE.

VARIABLE LABELS POPWEIGHT "Person-level weight (1000 persons)".

*Check person level weights.
FREQUENCIES POPWEIGHT.

*Check the file..
FREQUENCIES Region.

*********************************************************************************************************
*Save temporary HHQ + COM file and open again.
SAVE OUTFILE='tmp\TZHHCOM_2b.sav'
/KEEP 
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 


******************************************************************************************************
*LABELING AND GROUPING HH FILE INITIAL VARIABLES (at least in the b and part of c section???).. 
******************************************************************************************************
*Open  file.and continue .
*OUTPUT CLOSE ALL.
*DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\TZHHCOM_2b.sav'.
SET DECIMAL=DOT.

*Check the input file..
FREQUENCIES Region.

*B1 Numeric Years in community	
*check.
*FREQUENCIES B1.
COMPUTE B1_gr1 = $SYSMIS.
FORMATS B1_gr1(F3.0).
VARIABLE LEVEL B1_gr1 (NOMINAL).
RECODE B1 (LOWEST THRU 2  =1) (3 THRU 5 =2) (6 THRU 9 = 3) (10 THRU 19 = 4) (20 THRU HIGHEST = 5) (MISSING = 6) INTO B1_gr1.
VARIABLE LABELS B1_gr1 "Years in community".
VALUE LABELS B1_gr1 
1 "          <3"
2 "      3 -  5"
3 "      6 -  9"
4 "  10 - 19"
5 "     20 +"
6 "Not stated".
*Check..
FREQUENCIES B1_gr1.
*OUTPUT CLOSE ALL.
********************************
*B3 Numeric Number of households share building	
*Check..
*FREQUENCIES B3.
COMPUTE B3_gr1 = $SYSMIS.
FORMATS B3_gr1(F3.0).
VARIABLE LEVEL B3_gr1 (NOMINAL).
RECODE B3 (LOWEST THRU 2=1) (3 THRU 4 =2) (5 THRU 7 = 3) (8 THRU HIGHEST = 4) (MISSING = 5) INTO B3_gr1.
VARIABLE LABELS B3_gr1 "Number of households share building".
VALUE LABELS B3_gr1
1 " 1 -  2" 
2 " 3 -  4" 
3 " 5 -  7" 
4 "       8 +" 
5 "Not stated".
*Check.
FREQUENCIES B3_gr1.
*OUTPUT CLOSE ALL.
********************************
*B6 Numeric Number of rooms	
*Check.
*FREQUENCIES B6.
COMPUTE B6_gr1 = $SYSMIS.
FORMATS B6_gr1(F3.0).
VARIABLE LEVEL B6_gr1 (NOMINAL).
RECODE B6 (LOWEST THRU 1=1) (2 THRU 2 =2) (3 THRU 3 = 3) (4 THRU 4 = 4) (5 THRU HIGHEST = 5) (MISSING = 6) INTO B6_gr1.
VARIABLE LABELS B6_gr1 "Number of rooms".
VALUE LABELS B6_gr1 
1 "   1 "
2 "   2"
3 "   3"
4 "   4"
5 "  5+"
6 "Not stated".
*Check..
FREQUENCIES B6_gr1.
*OUTPUT CLOSE ALL.
********************************.
*B16 household having accont where MR. 
IF ( (CHAR.SUBSTR(B16,1,1)= "A") OR (CHAR.SUBSTR(B16,2,1)= "A") OR (CHAR.SUBSTR(B16,3,1)= "A") OR (CHAR.SUBSTR(B16,4,1)= "A") )  B16_gr1a = 1.
IF ( (CHAR.SUBSTR(B16,1,1)= "B") OR (CHAR.SUBSTR(B16,2,1)= "B") OR (CHAR.SUBSTR(B16,3,1)= "B") OR (CHAR.SUBSTR(B16,4,1)= "B") )  B16_gr1b = 1.    
IF ( (CHAR.SUBSTR(B16,1,1)= "C") OR (CHAR.SUBSTR(B16,2,1)= "C") OR (CHAR.SUBSTR(B16,3,1)= "C") OR (CHAR.SUBSTR(B16,4,1)= "C") )  B16_gr1c = 1.    
IF ( (CHAR.SUBSTR(B16,1,1)= "D") OR (CHAR.SUBSTR(B16, 2,1)= "D") OR (CHAR.SUBSTR(B16,3,1)= "D") OR (CHAR.SUBSTR(B16,4,1)= "D") )  B16_gr1d = 1.    
IF ( (CHAR.SUBSTR(B16,1,1)= "Q") OR (CHAR.SUBSTR(B16,2,1)= "Q") OR (CHAR.SUBSTR(B16,3,1)= "Q") OR (CHAR.SUBSTR(B16,4,1)= "Q") )  B16_gr1e = 1.    
EXECUTE.
VARIABLE LABELS 
     B16_gr1a "Commercial bank"  
    /B16_gr1b "Cooperative credit union" 
    /B16_gr1c "Micro finance institution"
    /B16_gr1d "Other arrangements"
    /B16_gr1e "Nyingine".
VALUE LABELS 
   B16_gr1a  1 "Yes"
  /B16_gr1b  1 "Yes" 
  /B16_gr1c  1 "Yes"
  /B16_gr1d  1 "Yes"
  /B16_gr1e  1 "Yes".
EXECUTE.
*Check.
FREQUENCIES B16_gr1a B16_gr1b B16_gr1c B16_gr1d B16_gr1e.
*OUTPUT CLOSE ALL.
********************************.
*B18 String	2  Which informal institution account	MR.
*FREQUENCIES B18.
IF ( (CHAR.SUBSTR(B18,1,1)= "a") OR (CHAR.SUBSTR(B18,2,1)= "a") OR (CHAR.SUBSTR(B18,3,1)= "a") )  B18_gr1a = 1.
IF ( (CHAR.SUBSTR(B18,1,1)= "b") OR (CHAR.SUBSTR(B18,2,1)= "b") OR (CHAR.SUBSTR(B18,3,1)= "b") )  B18_gr1b = 1.
IF ( (CHAR.SUBSTR(B18,1,1)= "q") OR (CHAR.SUBSTR(B18,2,1)= "q") OR (CHAR.SUBSTR(B18,3,1)= "q") )  B18_gr1c = 1.
EXECUTE.
VARIABLE LABELS 
     B18_gr1a "Group savings (Rotational)"  
    /B18_gr1b "Group savings (One-time disbursement)" 
    /B18_gr1c "Other arrangements".
VALUE LABELS 
   B18_gr1a  1 "Yes"
  /B18_gr1b  1 "Yes" 
  /B18_gr1c  1 "Yes".
EXECUTE.
*Check..
FREQUENCIES B18_gr1a B18_gr1b B18_gr1c.
*OUTPUT CLOSE ALL.
********************************.
* B19 String	 What sources for loan credit MR.
*Check.
*FREQUENCIES B19.
IF ( (CHAR.SUBSTR(B19,1,1)= "a") OR (CHAR.SUBSTR(B19,2,1)= "a") OR (CHAR.SUBSTR(B19,3,1)= "a") OR (CHAR.SUBSTR(B19,4,1)= "a") OR
      (CHAR.SUBSTR(B19,5,1)= "a") OR (CHAR.SUBSTR(B19,6,1)= "a") OR (CHAR.SUBSTR(B19,7,1)= "a") OR (CHAR.SUBSTR(B19,8,1)= "a") OR
      (CHAR.SUBSTR(B19,9,1)= "a") OR (CHAR.SUBSTR(B19,10,1)= "a") ) B19_gr1a = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "b") OR (CHAR.SUBSTR(B19,2,1)= "b") OR (CHAR.SUBSTR(B19,3,1)= "b") OR (CHAR.SUBSTR(B19,4,1)= "b") OR
      (CHAR.SUBSTR(B19,5,1)= "b") OR (CHAR.SUBSTR(B19,6,1)= "b") OR (CHAR.SUBSTR(B19,7,1)= "b") OR (CHAR.SUBSTR(B19,8,1)= "b") OR
      (CHAR.SUBSTR(B19,9,1)= "b") OR (CHAR.SUBSTR(B19,10,1)= "b") ) B19_gr1b = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "c") OR (CHAR.SUBSTR(B19,2,1)= "c") OR (CHAR.SUBSTR(B19,3,1)= "c") OR (CHAR.SUBSTR(B19,4,1)= "c") OR
      (CHAR.SUBSTR(B19,5,1)= "c") OR (CHAR.SUBSTR(B19,6,1)= "c") OR (CHAR.SUBSTR(B19,7,1)= "c") OR (CHAR.SUBSTR(B19,8,1)= "c") OR
      (CHAR.SUBSTR(B19,9,1)= "c") OR (CHAR.SUBSTR(B19,10,1)= "c") ) B19_gr1c = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "d") OR (CHAR.SUBSTR(B19,2,1)= "d") OR (CHAR.SUBSTR(B19,3,1)= "d") OR (CHAR.SUBSTR(B19,4,1)= "d") OR
      (CHAR.SUBSTR(B19,5,1)= "d") OR (CHAR.SUBSTR(B19,6,1)= "d") OR (CHAR.SUBSTR(B19,7,1)= "d") OR (CHAR.SUBSTR(B19,8,1)= "d") OR
      (CHAR.SUBSTR(B19,9,1)= "d") OR (CHAR.SUBSTR(B19,10,1)= "d") ) B19_gr1d = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "e") OR (CHAR.SUBSTR(B19,2,1)= "e") OR (CHAR.SUBSTR(B19,3,1)= "e") OR (CHAR.SUBSTR(B19,4,1)= "e") OR
      (CHAR.SUBSTR(B19,5,1)= "e") OR (CHAR.SUBSTR(B19,6,1)= "e") OR (CHAR.SUBSTR(B19,7,1)= "e") OR (CHAR.SUBSTR(B19,8,1)= "e") OR
      (CHAR.SUBSTR(B19,9,1)= "e") OR (CHAR.SUBSTR(B19,10,1)= "e") ) B19_gr1e = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "f") OR (CHAR.SUBSTR(B19,2,1)= "f") OR (CHAR.SUBSTR(B19,3,1)= "f") OR (CHAR.SUBSTR(B19,4,1)= "f") OR
      (CHAR.SUBSTR(B19,5,1)= "f") OR (CHAR.SUBSTR(B19,6,1)= "f") OR (CHAR.SUBSTR(B19,7,1)= "f") OR (CHAR.SUBSTR(B19,8,1)= "f") OR
      (CHAR.SUBSTR(B19,9,1)= "f") OR (CHAR.SUBSTR(B19,10,1)= "f") ) B19_gr1f = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "g") OR (CHAR.SUBSTR(B19,2,1)= "g") OR (CHAR.SUBSTR(B19,3,1)= "g") OR (CHAR.SUBSTR(B19,4,1)= "g") OR
      (CHAR.SUBSTR(B19,5,1)= "g") OR (CHAR.SUBSTR(B19,6,1)= "g") OR (CHAR.SUBSTR(B19,7,1)= "g") OR (CHAR.SUBSTR(B19,8,1)= "g") OR
      (CHAR.SUBSTR(B19,9,1)= "g") OR (CHAR.SUBSTR(B19,10,1)= "g") ) B19_gr1g = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "h") OR (CHAR.SUBSTR(B19,2,1)= "h") OR (CHAR.SUBSTR(B19,3,1)= "h") OR (CHAR.SUBSTR(B19,4,1)= "h") OR
      (CHAR.SUBSTR(B19,5,1)= "h") OR (CHAR.SUBSTR(B19,6,1)= "h") OR (CHAR.SUBSTR(B19,7,1)= "h") OR (CHAR.SUBSTR(B19,8,1)= "h") OR
      (CHAR.SUBSTR(B19,9,1)= "h") OR (CHAR.SUBSTR(B19,10,1)= "h") ) B19_gr1h = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "i") OR (CHAR.SUBSTR(B19,2,1)= "i") OR (CHAR.SUBSTR(B19,3,1)= "i") OR (CHAR.SUBSTR(B19,4,1)= "i") OR
      (CHAR.SUBSTR(B19,5,1)= "i") OR (CHAR.SUBSTR(B19,6,1)= "i") OR (CHAR.SUBSTR(B19,7,1)= "i") OR (CHAR.SUBSTR(B19,8,1)= "i") OR
      (CHAR.SUBSTR(B19,9,1)= "i") OR (CHAR.SUBSTR(B19,10,1)= "i") ) B19_gr1i = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "j") OR (CHAR.SUBSTR(B19,2,1)= "j") OR (CHAR.SUBSTR(B19,3,1)= "j") OR (CHAR.SUBSTR(B19,4,1)= "j") OR
      (CHAR.SUBSTR(B19,5,1)= "j") OR (CHAR.SUBSTR(B19,6,1)= "j") OR (CHAR.SUBSTR(B19,7,1)= "j") OR (CHAR.SUBSTR(B19,8,1)= "j") OR
      (CHAR.SUBSTR(B19,9,1)= "j") OR (CHAR.SUBSTR(B19,10,1)= "j") ) B19_gr1j = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "k") OR (CHAR.SUBSTR(B19,2,1)= "k") OR (CHAR.SUBSTR(B19,3,1)= "k") OR (CHAR.SUBSTR(B19,4,1)= "k") OR
      (CHAR.SUBSTR(B19,5,1)= "k") OR (CHAR.SUBSTR(B19,6,1)= "k") OR (CHAR.SUBSTR(B19,7,1)= "k") OR (CHAR.SUBSTR(B19,8,1)= "k") OR
      (CHAR.SUBSTR(B19,9,1)= "k") OR (CHAR.SUBSTR(B19,10,1)= "k") ) B19_gr1k = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "l") OR (CHAR.SUBSTR(B19,2,1)= "l") OR (CHAR.SUBSTR(B19,3,1)= "l") OR (CHAR.SUBSTR(B19,4,1)= "l") OR
      (CHAR.SUBSTR(B19,5,1)= "l") OR (CHAR.SUBSTR(B19,6,1)= "l") OR (CHAR.SUBSTR(B19,7,1)= "l") OR (CHAR.SUBSTR(B19,8,1)= "l") OR
      (CHAR.SUBSTR(B19,9,1)= "l") OR (CHAR.SUBSTR(B19,10,1)= "l") ) B19_gr1l = 1.
IF ( (CHAR.SUBSTR(B19,1,1)= "m") OR (CHAR.SUBSTR(B19,2,1)= "m") OR (CHAR.SUBSTR(B19,3,1)= "m") OR (CHAR.SUBSTR(B19,4,1)= "m") OR
      (CHAR.SUBSTR(B19,5,1)= "m") OR (CHAR.SUBSTR(B19,6,1)= "m") OR (CHAR.SUBSTR(B19,7,1)= "m") OR (CHAR.SUBSTR(B19,8,1)= "m") OR
      (CHAR.SUBSTR(B19,9,1)= "m") OR (CHAR.SUBSTR(B19,10,1)= "m") ) B19_gr1m = 1.
EXECUTE.
FORMATS B19_gr1a TO B19_gr1m (F2.0).
VARIABLE LABELS
    B19_gr1a "Commercial bank/Government bank"
   /B19_gr1b "Cooperative credit union"
   /B19_gr1c "Micro finance union"
   /B19_gr1d "Rural bank"
   /B19_gr1e "State loan"
   /B19_gr1f  "NGO"
   /B19_gr1g "Business firm"
   /B19_gr1h "Employer"
   /B19_gr1i  "SACCO/Moneylender"
   /B19_gr1j "Shop"
   /B19_gr1k "Relative\Friend\Neighbour"
   /B19_gr1l  "Mobile money service"
   /B19_gr1m "Cannot get a loan/credit".
VALUE LABELS
    B19_gr1a 1 "Yes"
   /B19_gr1b 1 "Yes"
   /B19_gr1c 1 "Yes"
   /B19_gr1d 1 "Yes"
   /B19_gr1e 1 "Yes"
   /B19_gr1f  1 "Yes"
   /B19_gr1g 1 "Yes"
   /B19_gr1h 1 "Yes"
   /B19_gr1i  1 "Yes"
   /B19_gr1j  1 "Yes"
   /B19_gr1k 1 "Yes"
   /B19_gr1l  1 "Yes"
   /B19_gr1m 1 "Yes".
*Check.
FREQUENCIES  B19_gr1a B19_gr1b B19_gr1c B19_gr1d B19_gr1e B19_gr1f  B19_gr1g B19_gr1h B19_gr1i B19_gr1j  B19_gr1k B19_gr1l B19_gr1m.
*OUTPUT CLOSE ALL.
********************************.
*B22 String How use mobile money services MR...
*Check.
*FREQUENCIES B22. 
IF ( (CHAR.SUBSTR(B22,1,1)= "a") OR (CHAR.SUBSTR(B22,2,1)= "a") OR (CHAR.SUBSTR(B22,3,1)= "a") OR (CHAR.SUBSTR(B22,4,1)= "a") OR
      (CHAR.SUBSTR(B22,5,1)= "a") OR (CHAR.SUBSTR(B22,6,1)= "a") OR (CHAR.SUBSTR(B22,7,1)= "a") OR (CHAR.SUBSTR(B22,8,1)= "a") OR
      (CHAR.SUBSTR(B22,9,1)= "a") OR (CHAR.SUBSTR(B22,10,1)= "a") ) B22_gr1a = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "b") OR (CHAR.SUBSTR(B22,2,1)= "b") OR (CHAR.SUBSTR(B22,3,1)= "b") OR (CHAR.SUBSTR(B22,4,1)= "b") OR
      (CHAR.SUBSTR(B22,5,1)= "b") OR (CHAR.SUBSTR(B22,6,1)= "b") OR (CHAR.SUBSTR(B22,7,1)= "b") OR (CHAR.SUBSTR(B22,8,1)= "b") OR
      (CHAR.SUBSTR(B22,9,1)= "b") OR (CHAR.SUBSTR(B22,10,1)= "b") ) B22_gr1b = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "c") OR (CHAR.SUBSTR(B22,2,1)= "c") OR (CHAR.SUBSTR(B22,3,1)= "c") OR (CHAR.SUBSTR(B22,4,1)= "c") OR
      (CHAR.SUBSTR(B22,5,1)= "c") OR (CHAR.SUBSTR(B22,6,1)= "c") OR (CHAR.SUBSTR(B22,7,1)= "c") OR (CHAR.SUBSTR(B22,8,1)= "c") OR
      (CHAR.SUBSTR(B22,9,1)= "c") OR (CHAR.SUBSTR(B22,10,1)= "c") ) B22_gr1c = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "d") OR (CHAR.SUBSTR(B22,2,1)= "d") OR (CHAR.SUBSTR(B22,3,1)= "d") OR (CHAR.SUBSTR(B22,4,1)= "d") OR
      (CHAR.SUBSTR(B22,5,1)= "d") OR (CHAR.SUBSTR(B22,6,1)= "d") OR (CHAR.SUBSTR(B22,7,1)= "d") OR (CHAR.SUBSTR(B22,8,1)= "d") OR
      (CHAR.SUBSTR(B22,9,1)= "d") OR (CHAR.SUBSTR(B22,10,1)= "d") ) B22_gr1d = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "e") OR (CHAR.SUBSTR(B22,2,1)= "e") OR (CHAR.SUBSTR(B22,3,1)= "e") OR (CHAR.SUBSTR(B22,4,1)= "e") OR
      (CHAR.SUBSTR(B22,5,1)= "e") OR (CHAR.SUBSTR(B22,6,1)= "e") OR (CHAR.SUBSTR(B22,7,1)= "e") OR (CHAR.SUBSTR(B22,8,1)= "e") OR
      (CHAR.SUBSTR(B22,9,1)= "e") OR (CHAR.SUBSTR(B22,10,1)= "e") ) B22_gr1e = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "f") OR (CHAR.SUBSTR(B22,2,1)= "f") OR (CHAR.SUBSTR(B22,3,1)= "f") OR (CHAR.SUBSTR(B22,4,1)= "f") OR
      (CHAR.SUBSTR(B22,5,1)= "f") OR (CHAR.SUBSTR(B22,6,1)= "f") OR (CHAR.SUBSTR(B22,7,1)= "f") OR (CHAR.SUBSTR(B22,8,1)= "f") OR
      (CHAR.SUBSTR(B22,9,1)= "f") OR (CHAR.SUBSTR(B22,10,1)= "f") ) B22_gr1f = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "g") OR (CHAR.SUBSTR(B22,2,1)= "g") OR (CHAR.SUBSTR(B22,3,1)= "g") OR (CHAR.SUBSTR(B22,4,1)= "g") OR
      (CHAR.SUBSTR(B22,5,1)= "g") OR (CHAR.SUBSTR(B22,6,1)= "g") OR (CHAR.SUBSTR(B22,7,1)= "g") OR (CHAR.SUBSTR(B22,8,1)= "g") OR
      (CHAR.SUBSTR(B22,9,1)= "g") OR (CHAR.SUBSTR(B22,10,1)= "g") ) B22_gr1g = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "h") OR (CHAR.SUBSTR(B22,2,1)= "h") OR (CHAR.SUBSTR(B22,3,1)= "h") OR (CHAR.SUBSTR(B22,4,1)= "h") OR
      (CHAR.SUBSTR(B22,5,1)= "h") OR (CHAR.SUBSTR(B22,6,1)= "h") OR (CHAR.SUBSTR(B22,7,1)= "h") OR (CHAR.SUBSTR(B22,8,1)= "h") OR
      (CHAR.SUBSTR(B22,9,1)= "h") OR (CHAR.SUBSTR(B22,10,1)= "h") ) B22_gr1h = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "i") OR (CHAR.SUBSTR(B22,2,1)= "i") OR (CHAR.SUBSTR(B22,3,1)= "i") OR (CHAR.SUBSTR(B22,4,1)= "i") OR
      (CHAR.SUBSTR(B22,5,1)= "i") OR (CHAR.SUBSTR(B22,6,1)= "i") OR (CHAR.SUBSTR(B22,7,1)= "i") OR (CHAR.SUBSTR(B22,8,1)= "i") OR
      (CHAR.SUBSTR(B22,9,1)= "i") OR (CHAR.SUBSTR(B22,10,1)= "i") ) B22_gr1i = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "j") OR (CHAR.SUBSTR(B22,2,1)= "j") OR (CHAR.SUBSTR(B22,3,1)= "j") OR (CHAR.SUBSTR(B22,4,1)= "j") OR
      (CHAR.SUBSTR(B22,5,1)= "j") OR (CHAR.SUBSTR(B22,6,1)= "j") OR (CHAR.SUBSTR(B22,7,1)= "j") OR (CHAR.SUBSTR(B22,8,1)= "j") OR
      (CHAR.SUBSTR(B22,9,1)= "j") OR (CHAR.SUBSTR(B22,10,1)= "j") ) B22_gr1j = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "k") OR (CHAR.SUBSTR(B22,2,1)= "k") OR (CHAR.SUBSTR(B22,3,1)= "k") OR (CHAR.SUBSTR(B22,4,1)= "k") OR
      (CHAR.SUBSTR(B22,5,1)= "k") OR (CHAR.SUBSTR(B22,6,1)= "k") OR (CHAR.SUBSTR(B22,7,1)= "k") OR (CHAR.SUBSTR(B22,8,1)= "k") OR
      (CHAR.SUBSTR(B22,9,1)= "k") OR (CHAR.SUBSTR(B22,10,1)= "k") ) B22_gr1k = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "l") OR (CHAR.SUBSTR(B22,2,1)= "l") OR (CHAR.SUBSTR(B22,3,1)= "l") OR (CHAR.SUBSTR(B22,4,1)= "l") OR
      (CHAR.SUBSTR(B22,5,1)= "l") OR (CHAR.SUBSTR(B22,6,1)= "l") OR (CHAR.SUBSTR(B22,7,1)= "l") OR (CHAR.SUBSTR(B22,8,1)= "l") OR
      (CHAR.SUBSTR(B22,9,1)= "l") OR (CHAR.SUBSTR(B22,10,1)= "l") ) B22_gr1l = 1.
IF ( (CHAR.SUBSTR(B22,1,1)= "q") OR (CHAR.SUBSTR(B22,2,1)= "q") OR (CHAR.SUBSTR(B22,3,1)= "q") OR (CHAR.SUBSTR(B22,4,1)= "q") OR
      (CHAR.SUBSTR(B22,5,1)= "q") OR (CHAR.SUBSTR(B22,6,1)= "q") OR (CHAR.SUBSTR(B22,7,1)= "q") OR (CHAR.SUBSTR(B22,8,1)= "q") OR
      (CHAR.SUBSTR(B22,9,1)= "q") OR (CHAR.SUBSTR(B22,10,1)= "q") ) B22_gr1m = 1.
EXECUTE.
FORMATS B22_gr1a TO B22_gr1m (F2.0).
VARIABLE LABELS
       B22_gr1a "Receive money from family/friends/other"
      /B22_gr1b "Transfer credit or money to family/friends/other"
      /B22_gr1c "Top-up credit"
      /B22_gr1d "Receive NGO/State support"
      /B22_gr1e "Pay for electricity"
      /B22_gr1f  "Pay for water"
      /B22_gr1g "Internet top-up/credit"
      /B22_gr1h "Commercial purchase"
      /B22_gr1i  "Insurance"
      /B22_gr1j  "Loan payment"
      /B22_gr1k "Savings"
      /B22_gr1l "Get small loans from mobile provider"
      /B22_gr1m "Other not specified".
VALUE LABELS
       B22_gr1a  1 "Yes"
      /B22_gr1b  1 "Yes"
      /B22_gr1c  1 "Yes"
      /B22_gr1d  1 "Yes"
      /B22_gr1e  1 "Yes"
      /B22_gr1f   1 "Yes"
      /B22_gr1g  1 "Yes"
      /B22_gr1h  1 "Yes"
      /B22_gr1i   1 "Yes"
      /B22_gr1j   1 "Yes"
      /B22_gr1k  1 "Yes"
      /B22_gr1l   1 "Yes"
      /B22_gr1m  1 "Yes". 
*Check..
FREQUENCIES B22_gr1a   B22_gr1b  B22_gr1c B22_gr1d B22_gr1e B22_gr1f  B22_gr1g B22_gr1h B22_gr1i B22_gr1j B22_gr1k B22_gr1l B22_gr1a  B22_gr1m.
*OUTPUT CLOSE ALL.
********************************.
*C5 String What kind of solar power supply do you have? MR..  
*Check.
*FREQUENCIES C5.
IF ( (CHAR.SUBSTR(C5,1,1)= "a") OR (CHAR.SUBSTR(C5,2,1)= "a") OR (CHAR.SUBSTR(C5,3,1)= "a") ) C5_gr1a = 1.
IF ( (CHAR.SUBSTR(C5,1,1)= "b") OR (CHAR.SUBSTR(C5,2,1)= "b") OR (CHAR.SUBSTR(C5,3,1)= "b") ) C5_gr1b = 1.
IF ( (CHAR.SUBSTR(C5,1,1)= "c") OR (CHAR.SUBSTR(C5,2,1)= "c") OR (CHAR.SUBSTR(C5,3,1)= "c") ) C5_gr1c = 1.
EXECUTE.
FORMATS C5_gr1a TO C5_gr1c (F2.0).
VARIABLE LABELS 
      C5_gr1a "Solar home system (SHS) with a separate battery"
     /C5_gr1b "Solar multilight product"
     /C5_gr1c "Solar lantern".
VALUE LABELS
     C5_gr1a 1 "Yes"
    /C5_gr1b 1 "Yes"
    /C5_gr1c 1 "Yes".
*Check.
FREQUENCIES C5_gr1a C5_gr1b C5_gr1c.
*OUTPUT CLOSE ALL.
********************************.
*C17 Numeric Years grid connection	
*Check.
*FREQUENCIES C17.
COMPUTE C17_gr1 = $SYSMIS.
FORMATS C17_gr1(F3.0).
VARIABLE LEVEL C17_gr1 (NOMINAL).
RECODE C17 (LOWEST THRU 0=1) (1 THRU 2 =2) (3 THRU 4 = 3) (5 THRU 9 = 4) (10 THRU HIGHEST = 5) (MISSING = 6) INTO C17_gr1.
VARIABLE LABELS C17_gr1 "Years of grid connection".
VALUE LABELS C17_gr1 
1 "Less than a year "
2 "1 - 2"
3 "3 - 4"
4 "5 - 9"
5 "  10+"
6 "Not stated".
*Check..
FREQUENCIES C17_gr1.
*OUTPUT CLOSE ALL.
********************************.
*C18 Numeric How much pay grid connecton fee	{888888888, Don't know}...
*Check.
*FREQUENCIES C18.
COMPUTE C18_gr1 = $SYSMIS.
FORMATS C18_gr1(F3.0).
VARIABLE LEVEL C18_gr1 (NOMINAL).
IF (C18=8 OR C18=88 OR C18=888 OR C18=8888 OR C18=88888 OR C18=888888 OR C18=8888888 OR C18=88888888 OR C18=888888888) C18=888888888. 
RECODE C18 (LOWEST THRU 9999 =1) (10000 THRU 49999 = 2) (50000 THRU 299999 = 3) (300000 THRU 499999 = 4) 
(500000 THRU 888888887 = 5)    (888888888 = 6)  (888888889 = 7) (999999999 = 8) ( MISSING = 9) INTO C18_gr1.
VARIABLE LABELS C18_gr1 "How much paied for grid connecton fee (TZS)".
VALUE LABELS C18_gr1 
1 "                   <10 000 "
2 "  10 000  -    49 999"
3 "  50 000  -  299 999"
4 "300 000  -  499 999"
5 "                    500 000 +"
6 " Don't know"
7 "The dwelling was already connected when household moved in"
8 "Not applicaple"  
9 "Not stated".
*Check..
FREQUENCIES C18_gr1.
*OUTPUT CLOSE ALL.
********************************.
*C19 Numeric How much did your household pay for the internal wiring  (888888888, Don't know}...
*Check.
*FREQUENCIES C19.
COMPUTE C19_gr1 = $SYSMIS.
FORMATS C19_gr1(F3.0).
VARIABLE LEVEL C19_gr1 (NOMINAL).
IF (C18=8 OR C18=88 OR C18=888 OR C18=8888 OR C18=88888 OR C18=888888 OR C18=8888888 OR C18=88888888 OR C18=888888888) C18=888888888. 
RECODE C19 (LOWEST THRU 1999=1) (2000 THRU 9999 =2) (10000 THRU 49999 = 3) (50000 THRU 888888887 = 4) (888888888 = 5) (888888889 = 6) (999999999 = 7)
 ( MISSING = 8) INTO C19_gr1.
VARIABLE LABELS C19_gr1 "How much did your household pay for the internal wiring	 (TZS)".
VALUE LABELS C19_gr1 
1 "                     < 2 000" 
2 "      2 000  -    9 999"
3 "   10 000  -  49 999"
4 "                     50 000 +"
5 " Don't know"
6 "The dwelling was already connected when household moved in"
7 "Not applicaple"  
8 "Not stated".
*Check..
FREQUENCIES C19_gr1.
*OUTPUT CLOSE ALL.
*********************************************************
* C20 Numeric Days from applied to household connected {888, Don't know}...
*Check.
*FREQUENCIES C20.
COMPUTE C20_gr1 = $SYSMIS.
FORMATS C20_gr1(F3.0).
VARIABLE LEVEL C20_gr1 (NOMINAL).
RECODE C20 (LOWEST THRU 7=1) (8 THRU 29 =2) (30 THRU 99 = 3) (100 THRU 800 = 4) (888 = 5) ( MISSING = 6) INTO C20_gr1.
VARIABLE LABELS C20_gr1 "Days from applied to household connected".
VALUE LABELS C20_gr1 
1 "             < 7" 
2 "        8 -  29"
3 "       30 - 99"
4 "           100+"
5 "Don't know"
6 "Not stated".
*Check..
FREQUENCIES C20_gr1.
*OUTPUT CLOSE ALL.
*********************************************************
*C21 Numeric Weeks to to use electricity after connected {88, Don't know}...
*Check.
*FREQUENCIES C21.
COMPUTE C21_gr1 = $SYSMIS.
FORMATS C21_gr1(F3.0).
VARIABLE LEVEL C21_gr1 (NOMINAL).
RECODE C21 (0 = 1) (1 THRU 4 =2) (5 THRU 12 = 3) (13 THRU 24 = 4)  (25 THRU 87 = 5)  (88 = 6) (MISSING = 7) INTO C21_gr1.
VARIABLE LABELS C21_gr1 "Weeks to to use electricity after connected".
VALUE LABELS C21_gr1 
1 "        <1" 
2 "   1 -   4"
3 "   5 - 12"
4 " 13 - 24"
5 "        25+"
6 "Don't know"
7 "Not stated".
*Check..
FREQUENCIES C21_gr1.
*OUTPUT CLOSE ALL.
*********************************************************
*C24 Numeric Number of households sharing
*Check.
*FREQUENCIES C24.
COMPUTE C24_gr1 = $SYSMIS.
FORMATS C24_gr1(F3.0).
VARIABLE LEVEL C24_gr1 (NOMINAL).
RECODE C24 (1 = 1) (2 THRU 3 =2) (4 THRU 6 = 3) (7 THRU HIGHEST = 4) (MISSINC = 5) INTO C24_gr1.
VARIABLE LABELS C24_gr1 "Number of households sharing the meter".
VALUE LABELS C24_gr1 
1 "      1" 
2 " 2 - 3"
3 " 4 - 6"
4 "    7+"
5 "Not stated".
*Check..
FREQUENCIES C24_gr1.
*OUTPUT CLOSE ALL.
**************************************************
*C25 Numeric We would now like to know the capacity of the main fuse. What is the Ampere (A) stated? {888, Don't know}...
*Check.
*FREQUENCIES C25.
COMPUTE C25_gr1 = $SYSMIS.
FORMATS C25_gr1(F3.0).
VARIABLE LEVEL C25_gr1 (NOMINAL).
RECODE C25 (0 THRU 59 =1) (60 THRU 64 =2) (65 THRU 99 = 3) (100 THRU 800 = 4)  (888 = 5) INTO C25_gr1.
VARIABLE LABELS C25_gr1 "The capacity of the meter in Ampere (A)".
VALUE LABELS C25_gr1 
1 "      < 60" 
2 "  60 - 65"
3 "  66 - 99"
4 "     100+"
5 "Dont know".
*Check..
FREQUENCIES C25_gr1. 
*OUTPUT CLOSE ALL.
*********************************************************
*C26 Numeric We would now like to know the capacity of the meter. What are the watts (W) stated? {88888, Don't know}...
*Check.
*FREQUENCIES C26.
COMPUTE C26_gr1 = $SYSMIS.
FORMATS C26_gr1(F3.0).
VARIABLE LEVEL C26_gr1 (NOMINAL).
RECODE C26 (LOWEST THRU 4999 =1) (5000 THRU 9999 =2) (10000 THRU 19999 = 3) (20000 THRU 88887 = 4) (88888 = 5) INTO C26_gr1.
VARIABLE LABELS C26_gr1 "The capacity of the meter in watts (W)".
VALUE LABELS C26_gr1 
1 "            <   5 000" 
2 "  5 000 -   9 999"
3 "10 000 - 19 999"
4 "               20 000+"
5 "Don't know".
*Check..
FREQUENCIES C26_gr1.
*OUTPUT CLOSE ALL.
***************************************************************************************
*C30 Numeric Amount last month electricity bill {88888888, Don't know}...
*Check.
*FREQUENCIES C30.
COMPUTE C30_gr1 = $SYSMIS.
FORMATS C30_gr1(F3.0).
VARIABLE LEVEL C30_gr1 (NOMINAL).
RECODE C30 (LOWEST THRU 4999 =1) (5000 THRU 9999 =2) (10000 THRU 80000000 = 3) (88888888 = 4) INTO C30_gr1.
VARIABLE LABELS C30_gr1 "Amount on last month electricity bil (TZS)".
VALUE LABELS C30_gr1 
1 "            <   5 000" 
2 "  5 000 -   9 999"
3 "               10 000+"
4 "Dont know".
*Check..
FREQUENCIES C30_gr1.
*OUTPUT CLOSE ALL.

*************************************************************************************************************
*Save temporary HHQ + COM file with derived/grouped much used variables and weights.
SAVE OUTFILE='tmp\TZHHCOM_2c.sav'
/KEEP 
REC_ID
Region
GeocodeEA 
GeocodeHH 
HH
UrbRur 
Xcoord 
Ycoord
Date 
ADDRESS_LOCATION 
WEIGHT
POPWEIGHT
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 


**********************************************************************************************************************.
***********************************************************************************************************************.
*CALCULATE ENERGY/COOKING  DERIVED VARIABLES AND TIERS 
*From Bjørn 24.05.2022.

*Open  tempoary file and continue .
GET FILE='tmp\TZHHCOM_2c.sav'.
SET DECIMAL=DOT.

*Check the input file..
FREQUENCIES Region.
***********************************************************************.
************************************************************************************************************************.
*1) CREATE BASIC ENERGY VARIABLES.
*From Bjørn 24.05.2022.

*Household-connection to electricity.
COMPUTE HHELGRIDCON=C2.
VARIABLE LABELS HHELGRIDCON ‘Household connection to el. grid’.
VALUE LABELS HHELGRIDCON 1 'Yes' 2 "No" .

*SDG Access = HH connection to electricity based on clean fuel.
COMPUTE HHSDG7ACCESS=0.
IF (C10 EQ 1 OR C10 EQ 3 OR C10 EQ 5) HHSDG7ACCESS=1.

IF (C10 EQ 6 AND (C120 EQ 1 OR C120 EQ 2 OR C120 EQ 4)) HHSDG7ACCESS=1.
VARIABLE LABEL HHSDG7ACCESS ‘SDG7 Access to sustainable energy’.
VALUE LABELS HHSDG7ACCESS 0 'No' 1 "Yes" .

*Cooking ovens by type of fuel.
COMPUTE HHCOOKINGFUEL=0.
IF (I10 GE 101 AND I10 LE 142) HHCOOKINGFUEL=1.
IF ((I10 GE 201 AND I10 LE 231) OR (I10 EQ 241)) HHCOOKINGFUEL=2.
IF (I10 EQ 233) HHCOOKINGFUEL=3.
IF (I10 EQ 331 OR I10 EQ 332 OR I10 EQ 341) HHCOOKINGFUEL=4.
IF (I10 GE 451 AND I10 LE 471) HHCOOKINGFUEL=5.
VARIABLE LABEL HHCOOKINGFUEL ‘Main fuel for cooking’.
VALUE LABELS HHCOOKINGFUEL 1 "Firewood" 2 "Charcoal" 3 "Kerosene" 4 "Pellets" 5 "Bio gas / EL Solar".

FREQUENCIES HHELGRIDCON HHSDG7ACCESS HHCOOKINGFUEL.

*******************************************.
*2) CREATE ENERGY TIERS . 
*fROM bJØRN 24.05.2022.

*EL TIER CALCULATIONS FROM HOUSEHOLDINFORMATION.
*First background check of how many.
*B13	Numeric	2	0	Main source energy lighting	{1, Electricity (TANESCO)}...
*B14	Numeric	2	0	Main source enegy cooking	{1, Electricity (TANESCO)}...

*C2	Numeric	Do you have a grid connection?	{1, Yes}...
*C3	Numeric	Is this the national grid or a local grid?	{1, National grid}...
*C4	Numeric	Do you have any devices or power supply using solar power?	{1, Yes}...
*C5	String	What kind of solar power supply do you have?	{a, Solar home system (SHS) with a separate battery}...
*C6	Numeric	Do you use an electric generator?	{1, Yes}...
*C7	Numeric	Do you use pico-hydro power?	{1, Yes}...
*C8	Numeric	Do you use rechargeable battery (not linked to a solar device)?	{1, Yes}...
*C9	Numeric	Do you use dry cell batteries?	{1, Yes}...
*C10	Numeric	Which of these power sources is your main electrical power source?	{1, Grid}...

*AEGCAPW – AEGridCapacityW - Peak Capacity -Power capacity ratings in W.
*Variables to use:.
*B13	Numeric	Main source energy lighting	{1, Electricity (TANESCO)}.
*B14	Numeric	Main source enegy cooking	{1, Electricity (TANESCO)}.
*C2	Numeric	Do you have a grid connection?	{1, Yes}.
*C10	Numeric	Which of these power sources is your main electrical power source?	{1, Grid}.

COMPUTE AEGCAPW = 0.
*if electricity from grid set capacity to 2000W.
*If no info in C10, main source may also come from info on main source for lightning or cooking being grid connection or from info on grid connection in C2.
IF (C10=1 OR C2=1 OR B13=1 OR B14=1) AEGCAPW =2000.

*define the tiers for grid electricity.
RECODE AEGCAPW (2000 THRU HI=5) (ELSE=0) INTO AETGCAPW.

VARIABLE LABELS AEGCAPW 'AE Grid Capacity in W'.
VARIABLE LABELS AETGCAPW 'AE Tier Grid Capacity in W'.

FREQUENCIES AEGCAPW AETGCAPW.

*AESOLAR - AESolarCapacity – A solar system requires both a solar cell panel and a battery/batterypack. 
*The capacity is made by the minimum factor, hence peak capacity can only be calculated at tier level.

*AESOLW – AesolarCellCapacityW - Peak Capacity - Power capacity ratings in W.
*Variables to use:.
*C10           Numeric  Which of these power sources is your main electrical power source?	{1, Grid}...
*C54	Numeric  Do you share this solar home system with other households?	{1, Yes}...
*C55	Numeric  How many households share this solar home system?
*C56	Numeric  Power rating solar panel	{888, Don't know}...

* If household do not know how many hhs that share the solar home system, set it to 2.
COMPUTE TMPC54=C54.
COMPUTE TMPC55=C55.
COMPUTE TMPC56=C56.
IF (SYSMIS(TMPC55)=1) TMPC55=2.

COMPUTE AESOLW=0.
IF (TMPC55=888888) TMPC55=2.
*if solar home system is used only by one household, and the power rating is within range:. 
IF (C10=3 AND TMPC54=2 AND (TMPC56 GE 20 AND TMPC56 LE 900)) AESOLW =TMPC56.
*If power rating is unknown set it to the minimum of solar panels for solar home systems sold today being 60W.
IF (TMPC56=888888) TMPC56=60.
*if solar home system is used only by more household, and the power rating is within range Divide the power rating by number of households that share it.
IF (C10=3 AND TMPC54=1 AND (TMPC56 GE 20 AND TMPC56 LE 900)) AESOLW = TMPC56/TMPC55.
*On average a solar cell panel will provide energy for 5 hours a day.
COMPUTE AESOLWH = AESOLW * 5.
*define the tiers for solar panels.
RECODE AESOLW (3 THRU 49=1) (50 THRU 199=2) (200 THRU 799=3) (800 THRU 1999=4) (2000 THRU HI=5) (ELSE=0) INTO AETSOLW.

VARIABLE LABELS AESOLW 'AE Solar Panel Capacity in W'.
VARIABLE LABELS AETSOLW 'AE Tier Solar Panel Capacity in W'.

FREQUENCIES AESOLW AETSOLW.

*AESOBWH	AEsolarBatteryCapacityWh - Peak Capacity - Power cap. ratings in Ah or Wh.
*Variables to use:.
*C10           Numeric  Which of these power sources is your main electrical power source?	{1, Grid}...
*C57	Numeric  Capacity battery	{888, Don't know}...
*C58	Numeric  What is the voltage (V) of the rechargeable batteries?	{88, Don't know}...
*C59	Numeric  What is the watt hours  (Wh) stated on the batteries?.
*C124	Numeric voltage	{88, Don't know}...

*Check.
FREQUENCIES C10 C57 C58 C59.
COMPUTE TMPC57 = C57.
COMPUTE TMPC58 = C58.
COMPUTE TMPC59 = C59.
COMPUTE TMPC124 = C124.

IF (TMPC57 = 888) TMPC57=20.
IF (TMPC58 = 88) TMPC58=12.

COMPUTE AESOBWH=0.
*if Ah and V both are unknown set Ah to the smallest possible value, 20.
IF (TMPC57 = 88 AND TMPC58 = 88) TMPC57=20.
IF (C10= 3 AND TMPC57 GE 20 AND TMPC57 LE 900 AND TMPC57 NE 88 AND TMPC58 GE 6 AND TMPC58 LE 24) AESOBWH = TMPC57 * TMPC58 * 0.75.
*If hh has solar home system as main source, Ah is within range, Volt is within range and Ah not unknown, then AESOBWH is Ah*V*75%. 
IF (C10= 3 AND ((TMPC57 LT 20 OR TMPC57 GT 900) OR (TMPC58 LT 6 OR TMPC58 GT 24)) AND TMPC59 NE 88) AESOBWH = TMPC59 * 0.75.
*If hh has solar home system as main source, Ah or V are unknown, but Wh is within range, then AESOBWH is Wh*75%.
IF (C10= 6 AND TMPC124 GE 6 AND TMPC124 LE 24) AESOBWH = TMPC124 * 0.75.
*define the tiers for batteries.
RECODE AESOBWH (12 THRU 199=1) (200 THRU 999=2)
(1000 THRU 3399=3) (3400 THRU 8199=4) (8200 THRU HI=5) (ELSE=0) INTO AETSOBWH.

VARIABLE LABELS AESOBWH 'AE Solar Battery Capacity in Wh'.
VARIABLE LABELS AETSOBWH 'AE Tier Solar Battery Capacity in Wh'.

FREQUENCIES AESOBWH AETSOBWH.

*AESOLAR - AESolarCapacity – Capacity across the solar cell panel and battery/batterypack can not be compared directly, hence peak capacity can only be calculated at tier level. 
COMPUTE AETSOLAR=MIN (AETSOLW, AETSOBWH).
VARIABLE LABELS AETSOLAR 'AE Tier Solar Cell and Battery Capacity'.

FREQUENCIES AETSOLAR AETSOLW AETSOBWH.

*AEAGGW – AEaggregateCapacityW - Peak Capacity - Power capacity ratings in W.
*Variables to use.
*C10           Numeric  Which of these power sources is your main electrical power source?	{1, Grid}...
*C89	Numeric	1	0	Share generator other households	{1, Yes}...
*C90	Numeric	2	0	Number of households sharing generator	{88, Don't know}...
*C91	Numeric	5	0	Generator capacity	{88888, Don't know}...

*Check.
FREQUENCIES C10 C89 C90 C91.
*Note: In Tanzania - Only one household with generator on the file and capacoty is given as 220V and it is not shared with others, the capacity has a typo and should be replaced with common minimum of 3000.

COMPUTE TMPC90 = C90.
COMPUTE TMPC91 = C91.

COMPUTE AEAGGW=0.
*If don’t know how many are sharing we set this to 2 since it is usually too demanding to share with more than 2.
IF (C90 = 888888) TMPC90=2.
*If aggregate not shared, set number to 1 even if missing.
IF (C89=1) TMPC90=1.
IF (TMPC91=220) TMPC91=3000.
*If hh’s main source is an aggregate that is used only by this household and capacity is within W range, use AEAGGW for the calculation.
IF (C10= 4 AND C89 EQ 2 AND TMPC91 GE 500 AND TMPC91 LE 50000) AEAGGW = TMPC91.
*If hh’s main source is aggregate that is shared with other and capacity is within W range, use AEAGGW for the calculation divided by the number of users.
IF (C10= 4 AND C89 EQ 1 AND TMPC91 GE 500 AND TMPC91 LE 50000) AEAGGW = TMPC91/TMPC90.
*Define the tiers for aggregate.
RECODE AEAGGW (3 THRU 49=1) (50 THRU 199=2) (200 THRU 799=3) (800 THRU 1999=4) (2000 THRU HI=5) (ELSE=0) INTO AETAGGW.

VARIABLE LABELS AEAGGW 'AE Aggregate Capacity in W'.
VARIABLE LABELS AETAGGW 'AE Tier Aggregate Capacity in W'.

FREQUENCIES AEAGGW AETAGGW.
 
*AEBATWH - AEbatteryCapacityWh - Peak Capacity - Power capacity ratings in Wh.

*Rechargeable battery - not connected to solar.
*Variables to use.
*C10	Numeric	Which of these power sources is your main electrical power source? {1, Grid}...
*C123	Numeric	6	2	Capacity	None (Amp)
*C124	Numeric	2	0	Voltage	{88, Don't know}...
*C125	Numeric 4 0 What is the Watt hours  (Wh) stated on the battery? {8888, Don't know}...

*Check.
FREQUENCIES C10 C123 C124 C125.

*COMPUTE AEBATWH=0.

*if dont'know set C123-124-125 to within acceptable range.
COMPUTE TMPC123=C123.
COMPUTE TMPC124=C124.
COMPUTE TMPC125=C125.

*if Ampere and AEBATWH are unknown set Ah to 20 which is the lowest commercial value.
IF (TMPC123 = 88) TMPC123=20.

*If V is unknown set it to 12, since this is the standard value.
IF (TMPC124 = 88) TMPC124=12.

IF ( TMPC125=8888 OR TMPC125=888) TMPC125=200.

*If main source is battery or if aggregate is main and battery main back up, Ah is within range and not unknown, and V is within range, then calculate capacity by using Ah and V
IF (C10= 6 AND TMPC123 GE 20 AND TMPC123 LE 500 AND TMPC123 NE 88 AND TMPC124 GE 6 AND TMPC124 LE 24) AEBATWH = TMPC123 * TMPC125 * 0.75.

*Calc if capacity Wh is known and range OK (200 to 6000)..
IF( C10=6 AND SYSMIS(TMPC125)=0 ) AEBATWH = TMPC125 * 0.75.
*Alternative calc if still sysmis AEBATWH and V and Amp is known and range OK.
IF( C10=6 AND SYSMIS(AEBATWH)=1 AND SYSMIS(TMPC123)=0 AND SYSMIS(TMPC124)=0 )  AEBATWH= TMPC123 * TMPC124 * 0.75. 
*Alternative calc if still sysmis AEBATWH and V is missing and and Amp is known and range OK.
IF( C10=6 AND SYSMIS(AEBATWH)=1 AND SYSMIS(TMPC123)=0 AND SYSMIS(TMPC124)=1 )  AEBATWH= TMPC123 * 12 * 0.75. 
IF (C10= 4 AND C11=6 AND TMPC123 GE 20 AND TMPC123 LE 500 AND TMPC123 NE 88 AND TMPC124 GE 6 AND TMPC124 LE 24) AEBATWH = TMPC123 * C125 * 0.75.
IF (C10= 4 AND C11=6 AND TMPC123 GE 20 AND TMPC123 LE 500 AND TMPC123 NE 88 AND (TMPC124 LE 6 OR TMPC124 GT 24)) AEBATWH = TMPC123 * 12 * 0.75.
IF (C10= 4 AND C11=6 AND (TMPC123 LT 20 OR TMPC123 GT 500) AND (TMPC125 GE 200 AND TMPC125 LE 6000) AND TMPC125 NE 88 AND (TMPC124 LT 6 OR TMPC124 GE 24)) AEBATWH = TMPC125 * 0.75.

*Define the tiers for battery.
RECODE AEBATWH(12 THRU 199=1) (200 THRU 999=2) (1000 THRU 3399=3) (3400 THRU 8199=4) (8200 THRU HI=5) (ELSE=0) INTO AETBATWH.

VARIABLE LABELS AEBATWH 'AE Battery Capacity in Wh'.
VARIABLE LABELS AETBATWH 'AE Tier Battery Capacity in Wh'.

FREQUENCIES AEBATWH AETBATWH.

*AESOLLH - AEsolarLanternCapacityLmh - Peak Capacity - Power capacity ratings in Lmh.
*Solar multilight + solar lantern.
*Variables to use.
*C10
*C76	Numeric 2 0 How many hours was service available from this [DEVICE] each evening, from 6:00 pm to 10:00 pm, during last seven days?
*C81	Numeric 2 0 Number light bulbs	None
*Check.
FREQUENCIES C76 C81.

COMPUTE AESOLLH=0.
IF ((C10=7 OR C10 =8) AND (C76 GE 1 AND C76 LE 4) AND C81 GE 1) AESOLLH= 150 * C76 * C81.
RECODE AESOLLH (1000 THRU HI=1) (ELSE=0) INTO AETSOLLH.

VARIABLE LABELS AESOLLH 'AE Solar Lantern Capacity in Lh'.
VARIABLE LABELS AETSOLLH 'AE Tier Solar Lantern Capacity in Lh'.

FREQUENCIES AESOLLH AETSOLLH.

*AESERW – AeservicecapacityW - Peak Capacity – Summary requirements of appliances.
*An alternative way to calculate electric capacity is to summarize the required capacity for the actual appliances owned by the household This would allow to choose the highest tier across sources and appliances.

COMPUTE AESERW=0.

*MobileCharge.
COMPUTE TMPL2$07 = 0.
IF ( (L2$07 = 7 AND L2A$07 = 1) OR (L2$08 = 7 AND L2A$08 = 1)  OR  (L2$22 = 7 AND L2A$22 GT 0)   ) TMPL2$07 = 1. 
*Elradio.
COMPUTE TMPL2$08 = 0.
IF (L2$08 = 8 AND L2A$08 = 1) TMPL2$08 = 1.
*Fan.
COMPUTE TMPL2$09 = 0.
IF (L2$09 = 9 AND L2A$09 = 1) TMPL2$09 = 1.
*Refrigerator.
COMPUTE TMPL2$10 = 0.
IF ( (L2$10 = 10 AND L2A$10 = 1) OR (L2$22 = 10 AND L2A$22 GT 0) OR (L2$19 = 10 AND L2A$19 = 1)  ) TMPL2$10 = 1.
*MicroW.
COMPUTE TMPL2$11 = 0.
IF (L2$11 = 11 AND L2A$11 = 1) TMPL2$11= 1.
*Freez.
COMPUTE TMPL2$12 = 0.
IF ( (L2$12 = 12 AND L2A$12 = 1) OR  (L2$14 = 12 AND L2A$14 = 1) ) TMPL2$12 = 1.
*Washmachine.
COMPUTE TMPL2$13 = 0.
IF (L2$13 = 13 AND L2A$13 = 1) TMPL2$13 = 1.
*Sewingmachine el.
COMPUTE TMPL2$14 = 0.
IF (L2$14 = 14 AND L2A$14 = 1) TMPL2$14 = 1.
*AC.
COMPUTE TMPL2$15 = 0.
IF (L2$15 = 15 AND L2A$15 = 1) TMPL2$15 = 1.
*PC.
COMPUTE TMPL2$16=0.
IF (L2$16 = 16 AND L2A$16 = 1) TMPL2$16 = 1.
*PotEl.
COMPUTE TMPL2$17 = 0.
IF ( (L2$17 = 17 AND L2A$17 = 1) OR (L2$19 = 17 AND L2A$19 = 1) ) TMPL2$17 = 1. 
*TV.
COMPUTE TMPL2$18 = 0.
IF ( (L2$18 = 18 AND L2A$18 = 1) OR (L2$19 = 18 AND L2A$19 = 1) OR (L2$20 = 18 AND L2A$20 GT 0)   ) TMPL2$18 = 1. 
*WaterpumpEl.
COMPUTE TMPL2$19 = 0.
IF (L2$19 = 19 AND L2A$19 = 1) TMPL2$19 = 1.
*Traditional light bulbs..
COMPUTE TMPL2$20 = 0.
IF (  (TMPL2$20 = 20 AND L2A$20 > 0)  OR (L2$21 = 20 AND L2A$21 GT 0) ) TMPL2$20 = 1. 
*LED light bulbs.
COMPUTE TMPL2$21 = 0.
IF ( (L2$21 = 21 AND L2A$21 GT 0) OR (L2$22 = 21 AND L2A$22 GT 0) )  TMPL2$21 = 1. 
*ElSaving bulbs.
COMPUTE TMPL2$22 = 0.
IF (L2$22 = 22 AND L2A$22 GT 0) TMPL2$22 = 1.

*If hh has mobile charger and/or an electric radio.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$07 EQ 1 OR TMPL2$08 EQ 1)) AESERW= 49.

*If hh has 3 or more traditional light bulbs and/or 3 or more LED light bulbs and/or 3 or more any light bulbs and/or a fan and/or computer and/or tv.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$09 EQ 1 OR TMPL2$16 EQ 1 OR TMPL2$18 EQ 1)) AESERW= 199.

IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$20 GE 3 OR TMPL2$21 GE 3 OR TMPL2$22 GE 3)) AESERW= 199.

*If hh has fridge and/or freezer and/or electric water pump.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$10 EQ 1 OR TMPL2$12 EQ 1 OR TMPL2$19 EQ 1)) AESERW= 799.

*If hh has microwave oven and/or washing machine.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$11 EQ 1 OR TMPL2$13 EQ 1)) AESERW= 1999.
*If hh has air conditioner.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$15 EQ 1)) AESERW= 2000.

*Define tiers based on appliances.
RECODE AESERW (0=0) (1 THRU 49=1) (50 THRU 199=2) (200 THRU 799=3) (800 THRU 1999=4) (2000 THRU HI=5) (ELSE=0) INTO AETSERW.

VARIABLE LABELS AESERW 'AE Service Capacity in W'.
VARIABLE LABELS AETSERW 'AE Tier Service Capacity in W'.

FREQUENCIES AESERW AETSERW.

*AECAPW - AECapacityW - Peak Capacity across the means of access to electricity EL1.

FREQUENCIES AEGCAPW AESOLW AESOLWh AESOBWh AEAGGW  AEBATWH AESOLLH AESERW.

*Create final Acess to energy capacity tier.
*COMPUTE AETCAPACITY = 0.

*Tier5 Acess to energy calc.
IF ( AEGCAPW GE 2000 OR  AESOLWh GE 2000 OR AESOBWh GE 2000 OR AEAGGW GE 2000 OR 
    AEBATWh GE 2000 OR AESOLLH GE 2000 OR AESERW GE 2000) 
    AETCAPACITY = 5.
*Check.
FREQUENCIES AETCAPACITY.

*Tier4 Acess to energy calc.
IF ( SYSMIS(AETCAPACITY)=1 AND
      ( (AESOLWh  GE 800 AND AESOLWh LT 2000) OR 
      (AESOBWh GE 800 AND AESOBWh LT 2000) OR 
      (AEAGGW   GE 800 AND AEAGGW LT 2000)  OR 
      (AEBATWh GE 800 AND AEBATWh LT 2000) OR 
      (AESOLLH GE 800 AND AESOLLH LT 2000) OR
      (AESERW GE 800 AND AESERW LT 2000) ) ) AETCAPACITY = 4.
*Check.
FREQUENCIES AETCAPACITY.

*Tier3 Acess to energy calc.
IF ( SYSMIS(AETCAPACITY)=1 AND
      ( (AESOLWh  GE 200 AND AESOLWh LT 800) OR 
      (AESOBWh GE 200 AND AESOBWh LT 800) OR 
      (AEAGGW   GE 200 AND AEAGGW LT 800)  OR 
      (AEBATWh GE 200 AND AEBATWh LT 800) OR 
      (AESOLLH GE 200 AND AESOLLH LT 800) OR
      (AESERW GE 200 AND AESERW LT 800) ) ) AETCAPACITY = 3.
*Check.
FREQUENCIES AETCAPACITY.

*Tier2 Acess to energy calc.
IF ( SYSMIS(AETCAPACITY)=1 AND
      ( (AESOLWh  GE 50 AND AESOLWh LT 200) OR 
      (AESOBWh GE 50 AND AESOBWh LT 200) OR 
      (AEAGGW   GE 50 AND AEAGGW LT 200)  OR 
       (AEBATWh GE 50 AND AEBATWh LT 200) OR 
      (AESOLLH GE 50 AND AESOLLH LT 200) OR
       (AESERW GE 50 AND AEBATWh LT 200) ) ) AETCAPACITY = 2.
*Check.
FREQUENCIES AETCAPACITY.
*Tier1 Acess to energy calc.
IF ( SYSMIS(AETCAPACITY)=1 AND
      ( (AESOLWh  GE 3 AND AESOLWh LT 50) OR 
      (AESOBWh GE 3 AND AESOBWh LT 50) OR 
      (AEAGGW   GE 3 AND AEAGGW LT 50)  OR 
      (AEBATWh GE 3 AND AEBATWh LT 50) OR 
      (AESOLLH GE 3 AND AESOLLH LT 50) OR
      (AESERW GE 3 AND AEBATWh LT 50) ) ) AETCAPACITY = 1.
*Check.
FREQUENCIES AETCAPACITY.

COMPUTE AETCAPW=0.
RECODE AETCAPACITY (1=1) (2=2) (3=3) (4=4) (5=5) INTO AETCAPW.

FREQUENCIES AETCAPW.
    
*Tier Acess to energy capacity..
VARIABLE LABELS AETCAPW “Peak Capacity across means of access”.

FREQUENCIES AETCAPW.

FREQUENCIES AETSOLW AETGCAPW AETSOLW AETSOBWh AETAGGW AETBATWh AETSOLLH AETSERW AETCAPW.

*Duration, Availability EL2. 

*Tier availability Day.
*variables neded.
*C38	Numeric	2	0	Hours of electricity day and night typical month	{88, Don't know}...
*C75	Numeric	2	0	How many hours did you receive service from this [DEVICE] each day and night, during the last seven days?	None.
*C105	Numeric	2	0	Hours of generator available	{88, Don't know}...
*C121	Numeric	2	0	hours of electricity per day	{88, Don't know}...

*AEDURDN - Availability during day and night – Duration – day EL2A.
COMPUTE AEDURDN=0.
COMPUTE AEDURDN=MAX (C38, C75, C105, 121).
DO IF C10=1.
   RECODE AEDURDN (2 THRU 3=1) (4 THRU 7=2) (8 THRU 15=3) (16 THRU 22=4) (23 THRU HI=5) (ELSE=0) INTO AETDURDN.
END IF.

VARIABLE LABELS AETDURDN “Availability during day and night”.

FREQUENCIES AETDURDN.

*AEDURN - Availability during night – Duration – night EL2B.

*Tier availability Night.
*variables needed.
*C39	Numeric	2	0	Hours of electricity 6 pm to 10 pm typical month	{88, Don't know}...
*C76	Numeric	2	0	How many hours was service available from this [DEVICE] each evening, from 6:00 pm to 10:00 pm, during last seven days?	None
*C106	Numeric	2	0	Hours of generator available evening	{88, Don't know}...
*C122	Numeric	2	0	how many hours ech evening	None.

COMPUTE AEDURN=0.
COMPUTE AEDURN=MAX (C39, C76, C106, C122).
DO IF C10=1.
   RECODE AEDURN (1=1) (2=2) (3=3) (4 THRU HI=5) (ELSE=0) INTO AETDURN.
END IF.

VARIABLE LABELS AETDURN “Availability during night”.

FREQUENCIES AETDURN.

*AETDUR - Availability – Duration – total and night EL2.
COMPUTE AETDUR=MIN (AETDURDN, AETDURN).
MISSING VALUES AEDURDN AEDURN AETDURDN AETDURN AETDUR (0).

VARIABLE LABELS AETDUR «AE Availability Duration Total & night”.

FREQ AEDURDN AEDURN AETDURDN AETDURN AETDUR.

*AEREL - Reliability EL3.
*variables needed.
*C10	Numeric 1 0 Which of these power sources is your main electrical power source?	{1, Grid}...
*C40	Numeric 2 0 Number of blackouts per week	{66, No outages/blackouts}...
*C41	Numeric 2 0 Total duration blackouts per week	{88, Don't know}...

*Check.
FREQUENCIES C40 C41. 

COMPUTE AEREL=0.
IF (C10=1) AEREL=3.
IF (C10=1 AND C40 GE 1 AND C40 LE 14) AEREL= 4.
IF (C10=1 AND (C40 GE 1 AND C40 LE 4 AND C41 EQ 1) OR C40 EQ 66) AEREL= 5.
COMPUTE AETREL=AEREL.
MISSING VALUES AEREL AETREL (0).

VARIABLE LABELS AEREL «AE Reliability”.
VARIABLE LABELS AETREL «AE Tier Reliability”.

FREQUENCIES AEREL AETREL.

*AEQUAL – Quality – EL4.

*Tier quality.
*C10	Numeric 1 0 Which of these power sources is your main electrical power source?	{1, Grid}...
*C45	Numeric 2 0 Appliences get damaged due to brown out	{1, Yes}...
*Check.
FREQUENCIES C45.

COMPUTE AEQUAL=0.
IF (C10=1 AND C45=1) AEQUAL=3.
IF (C10=1 AND (C45 = 2 OR C45=88)) AEQUAL=5.
COMPUTE AETQUAL=AEQUAL.
MISSING VALUES AEQUAL AETQUAL (0).

VARIABLE LABELS AEQUAL «AE Quality”.
VARIABLE LABELS AETQUAL «AE Tier Quality”.

FREQUENCIES AEQUAL AETQUAL.

*AEAFF – Affordability – EL5.
*Variables needed.
*C27	Numeric	1	0	Pre-paid meter	{1, Yes}...
*C33	Numeric	8	0	How much did you spend the last time you bought electricity?	None
*C35	Numeric	6	0	How many KWh did you pay for	None
*HHExpAll	Numeric 20 0 Total household annual expenditure (TZS)
*Check.
FREQUENCIES C27 C33 C35.

*Cost of 1kWh. 
*The average costs are calculated for all who remember or have noted the last payment to the prepaid meter and amount of power purchased.
IF (C10=1 AND C27 = 1 AND C33 NE 88 AND C35 NE 88 AND C33 NE 0 AND C35 NE 0 ) AEKWHCOSTS = C33 / C35.
*Check.
FREQUENCIES AEKWHCOSTS.
*Calc TZ mean cost pr kWh.
*MEANS TABLES = AEKWHCOSTS
    /CELLS=MEAN.
*FROM OUTPUT:WINDOW::
    *Mean = 343 TZ per kW purchased.
*The energy costs of 365 kWh per year is a national value, being 343 TZ * 365 = 125195 TZ.
COMPUTE AECONSUM = HHExpAll.
IF (C10 = 1) AEENERGYCOSTS = 343 * 365 * 100 /AECONSUM.
FREQUENCIES AEENERGYCOSTS. 

COMPUTE AEENERGYCOSTS=365*AEKWHCOSTS * 100/ AECONSUM.

COMPUTE AEAFF=0.
IF (C10=1 AND AEENERGYCOSTS LT 5) AEAFF = 5. 
IF (C10=1 AND AEENERGYCOSTS GE 5) AEAFF = 2. 
IF (C10=1 AND AEENERGYCOSTS GT 0 AND AEENERGYCOSTS LE 5) AEAFF=5.
COMPUTE AETAFF = AEAFF. 
MISSING VALUES AEAFF AETAFF (0).

VARIABLE LABELS AEAFF «AE Affordability”.
VARIABLE LABELS AETAFF «AE Tier Affordability”.

FREQUENCIES AEKWHCOSTS AEENERGYCOSTS AECONSUM AEAFF AETAFF.

*AELEG - AELegality – EL6*.

*Variables used:
*C10	Numeric	1	0	Which of these power sources is your main electrical power source?	{1, Grid}...
*C27	Numeric	1	0	Pre-paid meter	{1, Yes}...
*C28	Numeric	2	0	Who receives payment	{1, Energy company}...
*Check.
FREQUENCIES C27 C28.

COMPUTE AELEG=0.
IF (C10=1) AELEG=3.
IF (C10 EQ 1 AND (C27 LE 1 OR ((C27 GE 1 AND C27 LE 10) OR C27 EQ 55))) AELEG=5.
COMPUTE AETLEG = AELEG. 
MISSING VALUES AELEG AETLEG (0).

VARIABLE LABELS AELEG «AE Legal”.
VARIABLE LABELS AETLEG «AE Tier Legal”.

FREQUENCIES AELEG AETLEG.

*AETHLTH - AETHealth – EL7.

*variables to use.
*C10	Numeric 1 0 Which of these power sources is your main electrical power source?	{1, Grid}...
*C48	Numeric 1 0 Any household members die or limb damage	{1, Yes}...
*C110	Numeric 1 0 Household members die or injury 12 months - generator	{1, Yes}...

COMPUTE AEHLTH=0.
IF (C10=1 AND C48=1) AEHLTH=3.
IF (C10=1 AND C48=2) AEHLTH=5.
IF (C10=4 AND C110=1) AEHLTH=3.
IF (C10=4 AND C110=2) AEHLTH=5.
COMPUTE AETHLTH=AEHLTH.
MISSING VALUES AEHLTH AETHLTH (0).

VARIABLE LABELS AEHLTH «AE Health”.
VARIABLE LABELS AETHLTH «AE Tier Health”.

FREQUENCIES AEHLTH AETHLTH.

*AETACCESS – AETAccess to electricity - Overall household Electricity access. 
*The tier level is determined by the lowest tier for which all applicable attributes are met. 
*Tier0 - Tier5 Minimum of EL1, EL2A, EL2B, EL3, EL4, EL5, EL6, EL7, EL8.
*For many households one or more of these variables are missing. The data-statement should only compare the non-missing variables.

*AETACCESS.
COMPUTE AETACCESS=0.
*COMPUTE AETACCESS=MIN (TierEl_Capacity, TierEl_Day, TierEl_Night, TierEl_Freq, TierEl_Duration, TierEl_Quality, TierEl_Afford, TierEl_Formal, TierEl_Health). 

*Check.
FREQUENCIES AETACCESS.

CTABLES
  /VLABELS VARIABLES=C2 C4 C5 C6 C7 C8 C9 C10 B13 AETACCESS
    DISPLAY=LABEL
  /TABLE C10 + C2 + C4 + C5 + C6 + C7 + C8 + C9 + B13
  BY 
  AETACCESS [COUNT F40.0]
  /CATEGORIES VARIABLES=C10 C2 C4 C5 C6 C7 C8 C9 B13 ORDER=A KEY=VALUE EMPTY=INCLUDE MISSING=INCLUDE 
  /CATEGORIES VARIABLES= AETACCESS ORDER=A KEY=VALUE EMPTY=INCLUDE MISSING=INCLUDE TOTAL=YES POSITION=BEFORE  
  /CRITERIA CILEVEL=95.

COMPUTE AETACCESS=MIN (AETCAPW, AETDUR, AETREL, AETQUAL, AETAFF, AETLEG, AETHLTH). 

FREQUENCIES AETACCESS AETCAPW AETDUR AETREL AETQUAL AETAFF AETLEG AETHLTH.

*Tier access to electricity in household.
*Access to electricity measured by the tier dimensions includes: Peak Capacity, Availability (Duration), Reliability, Quality, Affordability and future connection, Legality, Health and safety, and Overall tiers.
*Variables: AEGCAPW, AETGCAPW, AESOLWH, AESOLW, AETSOLW, AESOBWH, AETSOBWH, AETSOLAR, AEAGGW, AETAGGW, AEBATWH, AETBATWH, AESOLLH, 
    AETSOLLH, AESERW, AETSERW, AEGCAPW , AESOLAR, AEAGGW , AEBATWH, , AESOLLH, AETCAPW, AETGCAPWS , AETAGGW , AEDURDN, AETDURDN, AEDURN, AETDURN, AETDUR, 
    AETDURDN, AETDURN, AEREL , AETREL, AEQUAL , AETQUAL, AECONSUM, AEKWHCOSTS, AEAFF , AETAFF, AELEG , AETLEG, AEHLTH , AETHLTH, AETACCESS. 

FREQUENCIES AETGCAPW AETSOLW AETSOBWH AETSOLAR AETAGGW AETBATWH  AETSOLLH AETSERW AETCAPW AETGCAPW  AETAGGW  AETDURDN AETDURN AETDUR  AETDURDN AETDURN 
    AETREL AETQUAL AETAFF AETLEG AETHLTH AETACCESS.

WEIGHT WEIGHT.
FREQUENCIES AETGCAPW AETSOLW AETSOBWH AETSOLAR AETAGGW AETBATWH  AETSOLLH AETSERW AETCAPW AETGCAPW  AETAGGW  AETDURDN AETDURN AETDUR  AETDURDN AETDURN 
    AETREL AETQUAL AETAFF AETLEG AETHLTH AETACCESS.

WEIGHT POPWEIGHT.
FREQUENCIES AETGCAPW AETSOLW AETSOBWH AETSOLAR AETAGGW AETBATWH  AETSOLLH AETSERW AETCAPW AETGCAPW  AETAGGW  AETDURDN AETDURN AETDUR  AETDURDN
     AETDURN AETREL AETQUAL AETAFF AETLEG AETHLTH AETACCESS.
WEIGHT OFF.

FREQUENCIES HHSDG7ACCESS AETACCESS COMD3.

WEIGHT WEIGHT.
FREQUENCIES HHSDG7ACCESS AETACCESS COMD3.

WEIGHT POPWEIGHT.
FREQUENCIES HHSDG7ACCESS AETACCESS COMD3 B13 B14.
WEIGHT OFF. 

*clean up temporary variables used for tiers el. calculations.
DELETE VARIABLES TMPC54 TMPC55 TMPC56 TMPC57 TMPC58 TMPC59 TMPC124 TMPC90 TMPC91 TMPC123 TMPC125 TMPL2$07 TMPL2$08 TMPL2$09
 TMPL2$10 TMPL2$11 TMPL2$12 TMPL2$13 TMPL2$14 TMPL2$15 TMPL2$16 TMPL2$17 TMPL2$18 TMPL2$19 TMPL2$20 TMPL2$21 TMPL2$22.

********************************************************************************************.
*Save temporary HHQ + COM file with derived/grouped much used variables and weights.
SAVE OUTFILE='tmp\TZHHCOM_2d.sav'
/KEEP 
ALL
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 

***********************************************************************************************************************.
*Open  tempoary file and continue .
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\TZHHCOM_2d.sav'.
SET DECIMAL=DOT.

*Check the input file..
FREQUENCIES Region.
***********************************************************************.
*3) TIERS FOR COOKING.
*Bjørn 24.05.2022.

*C01 Cooking Exposure -Emission.
*CO1AEXPFUEL - Emission fuel.
*variables to use.
*I10	Numeric 3 0 Which one is your main stove? None .

RECODE I10 (101 THRU 241=3) (331 THRU 451=4) (452 THRU 471=5) (ELSE=0) INTO CO1ATEXPFUEL.

*CO1BEXPSTOVE - Emission Stove design.
*I10	Numeric 3 0 Which one is your main stove? None .

RECODE I10 (101 THRU 241=3) (331 THRU 451=4) (452 THRU 471=5) (ELSE=0) INTO CO1ATEXPFUEL.
RECODE I10 (101,102,201,202=0) (111,112,211=1) (121,122,221=2) (131,132,231,233,331,332=3) (141,142,241,341=4) (451 THRU 471=5) (ELSE=0) INTO CO1BTEXPSTOVE.

*CO1CEXPEMISSION – Overall emission. 
COMPUTE CO1CTEXPEMISSION=MIN (CO1ATEXPFUEL, CO1BTEXPSTOVE).

FREQUENCIES I10 CO1ATEXPFUEL CO1BTEXPSTOVE CO1CTEXPEMISSION CO1ATEXPFUEL CO1BTEXPSTOVE.

*Cooking Exposure - Ventilation: Volume of the kitchen and Ventilation structure and level.
*CO1DEXPKITVOL - Cooking Exposure - Ventilation: Volume of Kitchen.
*I46 Numeric 1 0 Shape of cooking space {1, Roughly square}.
*I47	Numeric 2 0 Dimension of cooking space (square).	
*I48	Numeric 2 0 Dimension of rectagular cooking place side 1.
*I49	Numeric 2 0 Dimension of rectagular cooking place side 2.
*I50	Numeric 2 0 Dimension of rectagular cooking place circular .
*I51	Numeric 2 0 Size of rectagular cooking place .
*I52	Numeric 1 0 Type of roof covering cooking place .
*I54	Numeric 1 0 How many doors and windows in cooking place?	.

*Calculate floor squaremeter.
COMPUTE CO1DEXPKITFLOOR=0.
IF (I46 EQ 1) CO1DEXPKITFLOOR=I47*0.75*I47*0.75.
IF (I46 EQ 2) CO1DEXPKITFLOOR=I48*0.75*I49*0.75.
IF (I46 EQ 3) CO1DEXPKITFLOOR=I50*0.5*0.75*I50*0.5*0.75*3.14.
IF (I46 EQ 4) CO1DEXPKITFLOOR=I51*0.75*0.75.
*Calculate type of ceiling.
RECODE I52 (2,3=0.75) (ELSE=1) INTO CO1DEXPKITCEILING.
*Calculate height under ceiling in meter.
RECODE I53 (1=0.75) (2=1.7) (3=2.55) (4=3.4) (5=4.25) INTO CO1DEXPKITHEIGHT.
*Calculate total volume of the cookingarea.
COMPUTE CO1DEXPKITVOL=0.
COMPUTE CO1DEXPKITVOL=CO1DEXPKITFLOOR * CO1DEXPKITCEILING * CO1DEXPKITHEIGHT.
*Identify tiers.
IF (CO1DEXPKITVOL GE 5) CO1DTEXPKITVOL=1.
IF (CO1DEXPKITVOL GE 10) CO1DTEXPKITVOL=2.
IF (CO1DEXPKITVOL GE 20) CO1DTEXPKITVOL=3.
IF (CO1DEXPKITVOL GE 40) CO1DTEXPKITVOL=4.
IF (I22 GE 5) CO1DTEXPKITVOL=5.
MISSING VALUES CO1DEXPKITVOL, CO1DTEXPKITVOL (0).

FREQUENCIES CO1DEXPKITFLOOR CO1DEXPKITCEILING CO1DEXPKITHEIGHT
CO1DEXPKITVOL CO1DTEXPKITVOL.

*CO1E CO1EEXPVENTSTR -  Cooking Exposure - Ventilation: Structure.
*Classify tiers according to number of doors/windows in the cooking area.
COMPUTE CO1ETEXPVENTSTR=0.
IF (I54 GE 1) CO1ETEXPVENTSTR=1.
IF (I54 GT 1) CO1ETEXPVENTSTR=2.
IF (I54 EQ 4) CO1ETEXPVENTSTR=3.
IF (I22 GE 4) OR (I24 EQ 1) CO1ETEXPVENTSTR=4.
IF (I22 GE 5) CO1ETEXPVENTSTR=5.
MISSING VALUES CO1ETEXPVENTSTR (0).

*CO1F CO1FEXPVENTLEV -  Cooking Exposure - Ventilation Level.
*Calculate ventilation into three tiers levels.
COMPUTE CO1FTEXPVENTLEV=0.
IF (I54 GE 2) CO1FTEXPVENTLEV=2.
IF (I54 EQ 4) CO1FTEXPVENTLEV=3.
IF (I55 EQ 3) CO1FTEXPVENTLEV=3.
IF ((I55 EQ 1) OR (I55 EQ 2)) CO1FTEXPVENTLEV=5.
IF ((I22 GE 4) AND (I22 LE 6)) CO1FTEXPVENTLEV=5.
IF (I22 GE 5) CO1FTEXPLEV=5.
MISSING VALUES CO1FTEXPLEV (0).

*CO1G CO1GEXPVENT - Cooking Exposure – Overall Ventilation Level.
*Calculate overall ventilation as the maximum of the ventilation structure and ventilation level.
COMPUTE CO1GTEXPVENT=0.
COMPUTE CO1GTEXPVENT=MAX (CO1ETEXPVENTSTR, CO1FTEXPVENTLEV).
MISSING VALUES CO1GTEXPVENT (0).

FREQUENCIES CO1GTEXPVENT CO1ETEXPVENTSTR CO1FTEXPVENTLEV.

*CO1G CO1HEXPCTIME - Cooking Exposure - Contact Time.

*I37	Numeric 3 0 On average, how much time do you spend in the... morning?.
*I38	Numeric 3 0 On average, how much time do you spend in the... afternoon?.
*I39	Numeric 3 0 On average, how much time do you spend in the... evening?	.
*I40	Numeric 3 0 In the last 7 days, on average, how much time did your household use [STOVE] per day to boil water (for cooking, washing, and drinking)?.

FREQUENCIES I37 I38 I39 I40.

COMPUTE CO1HEXPCTIME = 0.
COMPUTE CO1HEXPCTIME = (I37+I38+I39+I40) / 60.
COMPUTE CO1HTEXPCTIME = 0.
IF (CO1HEXPCTIME GT 0 AND CO1HEXPCTIME LT 7.5) CO1HTEXPCTIME=1.
IF (CO1HEXPCTIME GT 0 AND CO1HEXPCTIME LT 6) CO1HTEXPCTIME=2.
IF (CO1HEXPCTIME GT 0 AND CO1HEXPCTIME LT 4.5) CO1HTEXPCTIME=3.
IF (CO1HEXPCTIME GT 0 AND CO1HEXPCTIME LT 3) CO1HTEXPCTIME=4.
IF (CO1HEXPCTIME GE 0 AND CO1HEXPCTIME LT 1.5) CO1HTEXPCTIME=5.
MISSING VALUES CO1HTEXPCTIME (0).

FREQUENCIES CO1HEXPCTIME CO1HTEXPCTIME.

*CO1I CO1ICOOKEXP -Overall Cooking Exposure. 
*The overall cooking exposure tier is determined by the lowest tier level for any of the sub-dimensions. 
COMPUTE CO1ITCOOKEXP=0.
COMPUTE CO1ITCOOKEXP=MIN (CO1ATEXPFUEL, CO1BTEXPSTOVE, CO1CTEXPEMISSION, CO1DTEXPKITVOL, CO1GTEXPVENT, CO1HTEXPCTIME).
MISSING VALUES CO1ITCOOKEXP (0).

FREQUENCIES CO1HTEXPCTIME CO1ITCOOKEXP.

*C01* Cooking Exposure - Alternative approach if missing information.
*In Rwanda and Ethiopia, the detailed information such as on kitchen information and ventilation structure was missing for some households and a simplified approach was applied to determine the overall cooking exposure. 
COMPUTE CO1IEXPOSURE = 0.
IF (CO1BTEXPSTOVE EQ 5) CO1IEXPOSURE = 5.
IF (CO1BTEXPSTOVE EQ 4 AND CO1FTEXPVENTLEV EQ 5) CO1IEXPOSURE = 5.
IF (CO1BTEXPSTOVE EQ 4 AND CO1FTEXPVENTLEV NE 5) CO1IEXPOSURE = 4.
IF (CO1BTEXPSTOVE EQ 3 AND CO1FTEXPVENTLEV EQ 5 AND CO1HTEXPCTIME GE 3) CO1IEXPOSURE = 3.
IF (CO1BTEXPSTOVE EQ 3 AND CO1FTEXPVENTLEV EQ 5 AND CO1HTEXPCTIME GE 4) CO1IEXPOSURE = 4.
IF (CO1BTEXPSTOVE EQ 3 AND CO1FTEXPVENTLEV EQ 3) CO1IEXPOSURE = 3.
IF (CO1BTEXPSTOVE EQ 3 AND CO1FTEXPVENTLEV LT 3 AND CO1HTEXPCTIME GE 4) CO1IEXPOSURE = 3.
IF (CO1BTEXPSTOVE EQ 3 AND CO1FTEXPVENTLEV LT 3 AND CO1HTEXPCTIME LT 4) CO1IEXPOSURE = 2.
IF (CO1BTEXPSTOVE EQ 2 AND CO1FTEXPVENTLEV EQ 5 AND CO1HTEXPCTIME GE 4) CO1IEXPOSURE = 3.
IF (CO1BTEXPSTOVE EQ 2 AND CO1FTEXPVENTLEV EQ 5 AND CO1HTEXPCTIME LT 4) CO1IEXPOSURE = 2.
IF (CO1BTEXPSTOVE EQ 2 AND CO1FTEXPVENTLEV EQ 3) CO1IEXPOSURE = 2.
IF (CO1BTEXPSTOVE EQ 2 AND CO1FTEXPVENTLEV LT 3 AND CO1HTEXPCTIME GE 4) CO1IEXPOSURE = 2.
IF (CO1BTEXPSTOVE EQ 2 AND CO1FTEXPVENTLEV LT 3 AND CO1HTEXPCTIME LT 4) CO1IEXPOSURE = 1.
IF (CO1BTEXPSTOVE EQ 1 AND CO1FTEXPVENTLEV EQ 5 AND CO1HTEXPCTIME GE 4) CO1IEXPOSURE = 2.
IF (CO1BTEXPSTOVE EQ 1 AND CO1FTEXPVENTLEV EQ 5 AND CO1HTEXPCTIME LT 4) CO1IEXPOSURE = 1.
IF (CO1BTEXPSTOVE EQ 1 AND CO1FTEXPVENTLEV EQ 3) CO1IEXPOSURE = 1.
IF (CO1BTEXPSTOVE EQ 1 AND CO1FTEXPVENTLEV LT 3 AND CO1HTEXPCTIME GE 4) CO1IEXPOSURE = 1.
IF (CO1BTEXPSTOVE EQ 1 AND CO1FTEXPVENTLEV LT 3 AND CO1HTEXPCTIME LT 4) CO1IEXPOSURE = 0.
IF (CO1BTEXPSTOVE EQ 0 AND CO1FTEXPVENTLEV EQ 5) CO1IEXPOSURE = 0.
IF (CO1BTEXPSTOVE EQ 0 AND CO1FTEXPVENTLEV LE 3) CO1IEXPOSURE = 1.
MISSING VALUES CO1IEXPOSURE (0).

FREQUENCIES CO1IEXPOSURE CO1BTEXPSTOVE CO1FTEXPVENTLEV CO1HTEXPCTIME.


*CO2 CO2EFFICIENCY - Cookstove efficiency

*I10	Numeric 3 0 Which one is your main stove?

FREQUENCIES I10.
RECODE I10 (101,102,201,202=0) (111,112,211=1) (121,122,221=2) (131,132,231,233,331,332=3) (141,142,241,341=4) (451 THRU 471=5) (ELSE=0) INTO CO2TEFFICIENCY.
MISSING VALUES CO2TEFFICIENCY (0).
FREQUENCIES CO2TEFFICIENCY.

*COOKING CONVENIENCE - Total convenience combining fuel acquisition and stove preparation.
*CO3A CO3ACONVFUEL - Convenience - Fuel acquisition and preparation time. 

*I43	Numeric 2 0 How many of times did the household gather, collect or purchase fuel  during the last seven days?.
*I44	Numeric 2 0 How many members of the household were involved each time?.
*I45_HH Numeric 2 0 How long time did it typically take to gather, collect or purchase fuel per person each time they did so during the last seven days? (Hours).
*I45_MM Numeric 2 0 How long time did it typically take to gather, collect or purchase fuel per person each time they did so during the last seven days? (Minutes).

IF (I43=-1) I43=1.
FREQUENCIES I43.

FREQUENCIES I43 I44 I45_HH I45_MM.
COMPUTE CO3ACONVFUEL=I43*I44*((I45_HH*60+I45_MM)/60).

FREQUENCIES CO3ACONVFUEL.

*CO3B CO3BCONVSPREP - Convenience – Stove-preparation time. 
*I34	Numeric 3 0 How much time do household members spend preparing the [STOVE] and fuel for each meal on average?.

FREQUENCIES I34.

COMPUTE CO3BCONVSPREP=I34. 

COMPUTE CO3TCONV=1.
IF (CO3ACONVFUEL LT 7 AND CO3BCONVSPREP LT 15) CO3TCONV=3.
IF (CO3ACONVFUEL LT 1.5 AND CO3BCONVSPREP LT 5) CO3TCONV=4.
IF (CO3ACONVFUEL LT 0.5 AND CO3BCONVSPREP LT 2) EQTCONV=5.
MISSING VALUES CO3ACONVFUEL CO3BCONVSPREP (0).

FREQUENCIES CO3ACONVFUEL CO3BCONVSPREP CO3TCONV.


*CO4 COSAFETY - Safety of Primary Cookstove.
* I41	Numeric 1 0 In the last 12 months, did anybody in your household face any serious harm/injury from [STOVE]?.

COMPUTE CO4TSAFETY=0.
*If no serious accident clasify in tier4/5.
IF (I41 EQ 1) CO4TSAFETY=3.
IF (I41 EQ 2) CO4TSAFETY=4.
MISSING VALUES CO4TSAFETY (0).
FREQUENCIES CO4TSAFETY.


*CO5 CO5AFFORD – Affordability.
*I25 Numeric 2 0 In the last 12 months, what are the fuels you used the most on [STOVE]?.
*I31 Numeric 8 0 How much did you pay the last time you purchased one [UNIT] of [FUEL]?.
*I32 Numeric 2 0 How long does a [UNIT] of [FUEL] typically last?.
*I33 Numeric 1 0 How much of the fuel you bought was  used for cooking?.

COMPUTE COCONSUM=0.
COMPUTE AECONSUM = HHExpAll.
MISSING VALUES COCONSUM (0).

*Affordability may be calculated either as actual price paid or according to median price of main fuel.
*In order to be consistent with calculation of electricity costs, the latter approach is chosen.
*Hence we start by calculating the median price for all household with the same main fuel and use that for all households with the same main fuel.
*First we calculate the costs for all households with valid information on payment for last purchase and the typical number of days the fuel will reach, adjusted for the proportion of fuel used for cooking for each type of fuel.
*For each household, the cooking expenses are set to the median costs for the type of fuel they use.
*For households collecting firewood or other types of fuel, the costs are set to 0.
*In order to be affordable, the costs are within 5% of their total annual consumption estimated by the proxy HHEXPALL.

*Check variables.
FREQUENCIES I25 I31 I32 I33.
*Check median price for each type of fuel.
COMPUTE TMPCOFUELPAY=0.
MISSING VALUES I31 I32 (0, 88, 99).
COMPUTE TMPCOFUELCOST=(I31/(I32*I33))*365.
FREQUENCIES TMPCOFUELCOST / STATISTICS=MEDIAN.
TEMPORARY.
SELECT IF I25 EQ 1.
FREQUENCIES TMPCOFUELCOST / STATISTICS=MEDIAN.
TEMPORARY.
SELECT IF I25 EQ 2.
FREQUENCIES TMPCOFUELCOST / STATISTICS=MEDIAN.
TEMPORARY.
SELECT IF I25 EQ 4.
FREQUENCIES TMPCOFUELCOST / STATISTICS=MEDIAN.
TEMPORARY.
SELECT IF I25 EQ 5.
FREQUENCIES TMPCOFUELCOST / STATISTICS=MEDIAN.
TEMPORARY.
SELECT IF I25 EQ 14.
FREQUENCIES TMPCOFUELCOST / STATISTICS=MEDIAN.
TEMPORARY.
SELECT IF I25 EQ 15.
FREQUENCIES TMPCOFUELCOST / STATISTICS=MEDIAN.
TEMPORARY.
SELECT IF I25 EQ 55.
FREQUENCIES TMPCOFUELCOST / STATISTICS=MEDIAN.

*Calculate levelled costs as median cost for each main fueltype.
COMPUTE TMPFREECOST=0.
COMPUTE TMPFIREWOODCOST=130357.
COMPUTE TMPCHARCOALCOST=182500.
COMPUTE TMPKEROSENCOST=182500.
COMPUTE TMPLPGCOST =152083.
COMPUTE TMPBIOMASSCOST=1520.
COMPUTE TMPBIOGASCOST=23319.
COMPUTE TMPELECCOST= AEKWHCOSTS*365.

*Calculate household costs.
*Free fuel.
IF (I25 EQ 3 OR I25 EQ 8 OR I25 EQ 9 OR I25 EQ 10 OR I25 EQ 17 OR I25 EQ 18) COFUELCOST = TMPFREECOST.  
*Wood purchased. 
IF (I25 EQ 2) COFUELCOST = TMPFIREWOODCOST.
*Charcoal.
IF (I25 EQ 4) COFUELCOST = TMPCHARCOALCOST.
*Kerosen, ethanol.
IF (I25 EQ 5 OR I25 EQ 16) COFUELCOST = TMPKEROSENCOST.
*Coal, coal briquette, biomass briquett, pellets.
IF (I25 EQ 7 OR I25 EQ 11 OR I25 EQ 12 OR I25 EQ 14) COFUELCOST = TMPBIOMASSCOST.
*Biogas.
IF (I25 EQ 15) COFUELCOST = TMPBIOGASCOST.
*LPG, piped gas.
IF (I25 EQ 1 OR I25 EQ 6) COFUELCOST = TMPLPGCOST.
*Electric.
IF (I25 EQ 13) COFUELCOST = TMPELECCOST.

FREQUENCIES COFUELCOST.

COMPUTE CO5AFFORD = COFUELCOST * 100 / AECONSUM.

COMPUTE CO5TAFFORD=3.
IF (CO5AFFORD GE 5) CO5TAFFORD=5.
FREQUENCIES CO5AFFORD CO5TAFFORD. 

*CO6 COAVAIL - Fuel Availability.
*I28 Numeric 1 0 In the last 12 months, how often was the [FUEL TYPE] available?.

COMPUTE CO6AVAIL=0.
COMPUTE CO6AVAIL=I28.
COMPUTE CO6TAVAIL=3.
IF (CO6AVAIL EQ 2) CO6TAVAIL=4.
IF (CO6AVAIL EQ 1) CO6TAVAIL=5.
MISSING VALUES CO6TAVAIL (0).

FREQUENCIES CO6AVAIL CO6TAVAIL.

*Overall access to household cooking solutions.
*Tiers for overall cooking solution is summarized across the 6 cooking solution dimensions as the lowest tier. 
COMPUTE COTCOOKINGSOL = 0.
COMPUTE COTCOOKINGSOL = MIN (CO1ITCOOKEXP, CO2TEFFICIENCY, CO3TCONV, CO4TSAFETY, CO5TAFFORD, CO6TAVAIL).
MISSING VALUES COTCOOKINGSOL (0).

FREQUENCIES COTCOOKINGSOL CO1ITCOOKEXP CO2TEFFICIENCY CO3TCONV CO4TSAFETY CO5TAFFORD CO6TAVAIL.

VARIABLE LABELS     CO1DEXPKITFLOOR “Cooking Exposure - Ventilation: Size of floor in kitchen» 
    CO1DEXPKITCEILING “Cooking Exposure - Ventilation: Type of ceiling kitchen» 
    CO1DEXPKITHEIGHT “Cooking Exposure - Ventilation: Height of kitchen» 
    CO1DEXPKITVOL “Cooking Exposure - Ventilation: Volume of Kitchen»
    CO1HEXPCTIME “Cooking Exposure - Contact Time»   
    CO1IEXPOSURE "Cooking exposure - Overall"
    CO3ACONVFUEL “Convenience - Fuel acquisition (collection or purchase) and prep time h m» 
    CO3BCONVSPREP “Convenience – Stove-preparation time (minutes per meal)» 
    COCONSUM “Total consumption» 
    COFUELCOST “Standardized level of fuel costs» 
    CO5AFFORD “Affordability» 
    CO6AVAIL “Fuel Availability».

FREQUENCIES CO1DEXPKITFLOOR CO1DEXPKITCEILING CO1DEXPKITHEIGHT CO1DEXPKITVOL CO1HEXPCTIME  
    CO1IEXPOSURE CO3ACONVFUEL CO3BCONVSPREP COCONSUM COFUELCOST CO5AFFORD CO6AVAIL. 

VARIABLE LABELS  CO1ATEXPFUEL “Cooking Exp - Emission: Fuel»  
    CO1BTEXPSTOVE “Cooking Exp - Emission: Stove Design»  
    CO1CTEXPEMISSION “Cooking Exp – Overall emission»  
    CO1DTEXPKITVOL “Cooking Exp - Ventilation: Volume of Kitchen»  
    CO1ETEXPVENTSTR “Cooking Exp - Ventilation: Structure»  
    CO1FTEXPVENTLEV	 “Cooking Exp - Ventilation Level»  
    CO1GTEXPVENT “Cooking Exp - Overall Ventilation Level»  
    CO1HTEXPCTIME “Cooking Exp - Contact Time»  
    CO1ITCOOKEXP “Cooking Exp»  
    CO2TEFFICIENCY “Cookstove Efficiency»  
    CO3TCONV “Convenience - Fuel acquisition (collection or purchase) and prep time h m» 
    CO4TSAFETY  “Safety of Primary Cookstove»  
    CO5TAFFORD “Affordability»  
    CO6TAVAIL  “Fuel Availability» 
    COTCOOKINGSOL “Overall cooking solution» . 

FREQUENCIES CO1ATEXPFUEL CO1BTEXPSTOVE CO1CTEXPEMISSION CO1DTEXPKITVOL CO1ETEXPVENTSTR CO1FTEXPVENTLEV CO1GTEXPVENT 
    CO1HTEXPCTIME CO1ITCOOKEXP CO2TEFFICIENCY CO3TCONV CO4TSAFETY CO5TAFFORD CO6TAVAIL COTCOOKINGSOL.

*********************************.
*clean tmp vars for cooking tiers.
DELETE VARIABLES TMPCOFUELPAY TMPCOFUELCOST TMPFREECOST TMPFIREWOODCOST TMPCHARCOALCOST TMPKEROSENCOST TMPLPGCOST 
TMPBIOMASSCOST TMPBIOGASCOST TMPELECCOST.

*END ENERGY AND COOKING TIERS / VARIABLES.
*******************************************************************************************.
*Save temporary HHQ + COM file with derived/grouped much used variables and weights.
SAVE OUTFILE='tmp\TZHHCOM_2e.sav'
/KEEP 
ALL
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 

***********************************************************************************************************************.
*Open  tempoary file and continue .
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\TZHHCOM_2e.sav'.
SET DECIMAL=DOT.

*Check the input file..
FREQUENCIES Region.
***********************************************************************.
*According to NBS standards for tabulation of regions.
*Recode Region valuelables to be without regioan number as agreed with NBS.
FREQUENCIES Region.
VALUE LABELS Region 
"01" Dodoma
"02" Arusha 
"03" Kilimanjaro 
"04" Tanga 
"05" Morogoro 
"06" Pwani 
"07" Dar-es-salaam 
"08" Lindi 
"09" Mtwara 
"10" Ruwuma
"11" Iringa 
"12" Mbeya
"13" Singida
"14" Tabora
"15" Rukwa
"16" Kigoma
"17" Shinyanga
"18" Kagera
"19" Mwanza
"20" Mara
"21" Manyara
"22" Njombe
"23" Katavi
"24" Simiyu
"25" Geita
"26" Songwe.
EXECUTE.

*Check.
FREQUENCIES Region.

***************************************************************************************************************
*SAVE PRODUCTION FILES AT HOUSEHOLD LEVEL..

*1) Save temporary household-level production file with all community level varables attached..
*1a) SPSS sav file.
SORT CASES BY GeocodeHH (A).
SAVE OUTFILE='data\TZHHLEVEL_1.sav'
/KEEP 
REC_ID
Region
GeocodeEA 
GeocodeHH 
HH
UrbRur 
Xcoord 
Ycoord
Date 
ADDRESS_LOCATION 
WEIGHT
POPWEIGHT
ALL 
/COMPRESSED.

*1b) STATA dta file.
SAVE TRANSLATE OUTFILE= 'data\TZHHLEVEL_1.dta'  
/TYPE=STATA
/VERSION=14
/EDITION=SE
/KEEP 
REC_ID
Region
GeocodeEA 
GeocodeHH 
HH
UrbRur 
Xcoord 
Ycoord
Date 
ADDRESS_LOCATION 
WEIGHT
POPWEIGHT
ALL 
/COMPRESSED.
  
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 

**************************************************************************************************************************************************************
*CREATE/RESTRUCTURE TO PERSON-LEVEL FILE.

*Open file.and continue .
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='data\TZHHLEVEL_1.sav'.
SET DECIMAL=DOT.

*Check the input file..
FREQUENCIES Region.

*Create the person level file.
VARSTOCASES 
  /MAKE Name                FROM AB1$01 TO AB1$20
  /MAKE RelShip             FROM AB3$01 TO AB3$20
  /MAKE Head5YAgo       FROM AB3B$01 TO AB3B$20
  /MAKE Sex                   FROM AB4$01 TO AB4$20
  /MAKE Age                   FROM AB5$01 TO AB5$20
  /MAKE Marital               FROM AB6$01 TO AB6$20 
  /MAKE Literacy             FROM AC1$01 TO AC1$20
  /MAKE EverAttend         FROM AC2$01 TO  AC2$20
  /MAKE EnrollCurrY        FROM AC3$01 TO AC3$20
  /MAKE GradeCurrY        FROM AC4$01 TO AC4$20
  /MAKE AgeStartCurrY    FROM AC5$01 TO AC5$20
  /MAKE AttendCurrY       FROM AC6$01 TO AC6$20
  /MAKE AttendLastY       FROM AC7$01 TO AC7$20
  /MAKE GradeLastY        FROM AC8$01 TO AC8$20
  /MAKE HighEvComp       FROM AC9$01 TO AC9$20
  /MAKE MainOccpCurrY  FROM A2$01 TO A2$20
  /MAKE MainActCurrY     FROM A3$01 TO A3$20
  /MAKE MonthActCurrY   FROM A4$01 TO A4$20
  /MAKE DaysActCurrY     FROM A5$01 TO A5$20
  /MAKE MainOccp5YAgo FROM A6$01 TO A6$20
  /MAKE MainAct5YAgo    FROM A7$01 TO A7$20
  /MAKE Cooking              FROM A8$01 TO  A8$20
  /KEEP = ALL                    
  /NULL = DROP.
EXECUTE.
******************************************************************************.
*Grouping/labeling of some new person level variables before saving the file. 

*1) Age groups.
FREQUENCIES age.

COMPUTE Age_gr1 = $SYSMIS.
FORMATS Age_gr1 (F3.0).
VARIABLE LEVEL Age_gr1 (NOMINAL).
RECODE Age (LOWEST THRU 4=1) (5 THRU 11 =2) (12 THRU 14 = 3) (15 THRU 19 = 4) (20 THRU 29 = 5) (30 THRU 44 = 6) (45 THRU 64 = 7)
                (65 THRU HIGHEST =8) (MISSING = 9) INTO Age_gr1.
VARIABLE LABELS Age_gr1 "Age of household members (Years)".
VALUE LABELS Age_gr1 
1 " 0  -  4"
2 " 5  - 11"
3 "12 - 14"
4 "15 - 19"
5 "20 - 29"
6 "30 - 44"
7 "45 - 64"
8 "     65+"
9 "Not stated".
*Check..
FREQUENCIES Age_gr1.

* Custom Tables.
CTABLES
  /VLABELS VARIABLES=Age_gr1 UrbRur DISPLAY=LABEL
  /TABLE Age_Gr1 [COUNT F40.0] BY UrbRur
  /CATEGORIES VARIABLES=Age_Gr1 UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
  /CRITERIA CILEVEL=95.

*OUTPUT CLOSE ALL.

*2) Age group at start of current school year.
COMPUTE AgeStartCurrY_gr1 = $SYSMIS.
FORMATS AgeStartCurrY_gr1 (F3.0).
VARIABLE LEVEL AgeStartCurrY_gr1 (NOMINAL).
RECODE AgeStartCurrY (LOWEST THRU 4=1) (5 THRU 11 =2) (12 THRU 14 = 3) (15 THRU 19 = 4) (20 THRU HIGHEST = 5) (MISSING = 6) INTO AgeStartCurrY_gr1.
VARIABLE LABELS AgeStartCurrY_gr1 "Age at beginning of current school year (Years - Grouped)".
VALUE LABELS AgeStartCurrY_gr1 
1 "     < 5"
2 " 5  - 11"
3 "12 - 14"
4 "15 - 19"
5 "     20+"
6 "Not stated".
*Check..
FREQUENCIES AgeStartCurrY_gr1.

*3) Month of activity group.     
COMPUTE MonthActCurrY_gr1 = $SYSMIS.
FORMATS MonthActCurrY_gr1(F3.0).
VARIABLE LEVEL MonthActCurrY_gr1 (NOMINAL).
RECODE MonthActCurrY (0 THRU 0=1) (1 THRU 2 =2) (3 THRU 6 = 3) (7 THRU 11 = 4) (12 THRU HIGHEST = 5) (MISSING = 6) INTO MonthActCurrY_gr1.
VARIABLE LABELS MonthActCurrY_gr1 "Number of months in activity current year (grouped)".
VALUE LABELS MonthActCurrY_gr1 
1 "     0 "
2 "1 - 2"
3 "3 - 6"
4 "7 -11"
5 "    12"
6 "Not stated".
*Check..
FREQUENCIES MonthActCurrY_gr1.

*4) Days of activity per month group.
COMPUTE DaysActCurrY_gr1 = $SYSMIS.
FORMATS DaysActCurrY_gr1(F3.0).
VARIABLE LEVEL DaysActCurrY_gr1 (NOMINAL).
RECODE DaysActCurrY (0 THRU 0=1) (1 THRU 5 =2) (6 THRU 14 = 3) (15 THRU 24 = 4) (25 THRU HIGHEST = 5) (MISSING = 6) INTO DaysActCurrY_gr1.
VARIABLE LABELS DaysActCurrY_gr1 "Number of days per month in activity current year (grouped)".
VALUE LABELS DaysActCurrY_gr1 
1 "        0"
2 "  1 -  5"
3 "  6 - 14"
4 "15 - 24"
5 "     25+"
6 "Not stated".
*Check..
FREQUENCIES DaysActCurrY_gr1.
*Clean.
OUTPUT CLOSE ALL.

*************************************************************************.
*Save first version of person-level file with all household/community varables attached including new grouped and labelled variables..

SORT CASES BY GeocodeHH (A).

*SPSS sav file.
SAVE OUTFILE ='data\TZPRSLEVEL_1.sav'
/KEEP REC_ID Region GeocodeEA GeocodeHH HH UrbRur Xcoord Ycoord Date ADDRESS_LOCATION WEIGHT POPWEIGHT
Name RelShip Head5YAgo Sex Age Marital Literacy EverAttend EnrollCurrY GradeCurrY AgeStartCurrY AttendCurrY AttendLastY GradeLastY  
HighEvComp MainOccpCurrY MainActCurrY MonthActCurrY DaysActCurrY MainOccp5YAgo MainAct5YAgo Cooking ALL 
/COMPRESSED.


*STATA dta file.
SAVE TRANSLATE OUTFILE= 'data\TZPRSLEVEL_1.dta'  
/TYPE=STATA
/VERSION=14
/EDITION=SE
/KEEP REC_ID Region GeocodeEA GeocodeHH HH UrbRur Xcoord Ycoord Date ADDRESS_LOCATION WEIGHT POPWEIGHT
Name RelShip Head5YAgo Sex Age Marital Literacy EverAttend EnrollCurrY GradeCurrY AgeStartCurrY AttendCurrY AttendLastY GradeLastY  
HighEvComp MainOccpCurrY MainActCurrY MonthActCurrY DaysActCurrY MainOccp5YAgo MainAct5YAgo Cooking ALL
/COMPRESSED.
  
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 

***********************************************************************
*END OF SYNTAX
***********************************************************************    









