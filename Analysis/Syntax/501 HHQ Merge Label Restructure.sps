* Encoding: UTF-8.
* Created 19.01.2022. 
* Update: Kristian 26.01 - 10.02.2022       
* Update::Per 19.01 - 28.02.2022.
* SSB/NBS project team final approval: ................ 

*Objective: 1) Merging household file with community file and construcl&label new derived key variables for tabulation/analysis
                 2) Produce the person level file with all household and community information appended
                 3) Secure consistency between household level file and the person level file

*In-put:   The cleaned (unique identifiers/no-duplicate) "tmp\HHQTZ_4 file" and the cleaned "tmp\COMTZ_2" file.                   

*Out-put: A) The household level file (with all community information append) ready for further analysis and tabullation
              B) The person level file (with all household- and community information appended)  ready for further analysis and tabullation.  
              
*******************************************************************************************************************************************''********************************************
The working filestructure for this program is as follows:

*.....\2021_22_SPSS Tanzania
            \Cat
            \Data
            \Production
            \Documentation
            \Syntax
            \Tables
            \Tmp
*************'*****************************************************************************
*Set the folder path and open file from the folder structure.
* "The SET DECIMAL=DOT" is necessary to add to get the XY coodinates correctly opened..
*Open temp 4 file.and continue .
*OUTPUT CLOSE ALL.
*DATASET CLOSE ALL.
GET FILE='tmp\HHQTZ_4.sav'.

*Check the input file..
FREQUENCIES Region.
******************************************************.
*MERGE/APPEND INFORMATION FROM THE COMMUNITY QUESTIONNAIRE TO THE HOUSEHOLD FILE. 
*THE ComTZ_2 file must be of same date or later date and cleaned/labelled/grouped before merging. 
SORT CASES BY GeocodeEA (A).
MATCH FILES 
/FILE=*   
/TABLE= 'tmp\ComTZ_2.sav'  
/IN=from_com
/BY GeocodeEA.
EXECUTE.	
**************************************************
*Select all with both COM records and HHQ records.
*Check start.
FREQUENCIES from_com Region.
TEMPORARY.
SELECT IF
      (from_com = 0). 
LIST comREC_ID GeocodeEA.

SELECT IF
   (from_com = 1). 
EXECUTE.

*Check end..
FREQUENCIES Region.  
***************************************************
*Save temporary HHQ + COM file and open again.
SAVE OUTFILE='tmp\TZHHCOM_1.sav'
/KEEP 
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 
********************************************************************.
*Open file.and continue .
GET FILE='tmp\TZHHCOM_1.sav'.

*Check the input file..
FREQUENCIES Region.

**************************************************************************************************************
*CREATE NEW DERIVED MUCH USED VARIABLES FOR TABULATION.
***************************************************************************************************************.
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
FREQUENCIES AC1$01 AC1$05 AC1$10 AC1$20.

*b) Tanzania specific correction/recoding and new labeling of valueset TARIFF_MZ to TARIFF_TZ
Variable C22.
*Name=TARIFF_TZ
Value=1;Domestic Use (D1)|Uso domÃ©stica (D1)|D1 [Matumizi chini ya Unit 75 kwa mwezi (TZS 100 kwa Unit)]
Value=2;General Use (T1)|Uso Geral (T1)|T1 [Matumizi zaidi ya Unit 75-750 kwa mwezi (TZS 292 kwa Unit)]

*Check. 
*FREQUENCIES C22.
*Conclusion - no need for recoding.
************************************************************
*1) Create new variable (headsex) Sex of head of household (Use AB4$01).
*Check.
*FREQUENCIES AB4$01.
COMPUTE headsex_gr1 = AB4$01.
FORMATS headsex_gr1 (F2.0).
EXECUTE.
RECODE AB4$01 (1 THRU 1 = 1) (2 THRU 2 = 2)  (MISSING = 3) INTO headsex_gr1.
VARIABLE LABELS headsex_gr1 "Sex of head of household".
VALUE LABELS headsex_gr1 1 " Male" 2 " Female" 3 " Not stated". 
EXECUTE.
*Check.
FREQUENCIES headsex_gr1.

OUTPUT CLOSE ALL.
****************************
*2) Create new variable (higheduc_gr1) with highest education in the household" (Use AC9$01 - AC9$20).
*<PER sjekk inndeling education for better grouping>.
1 "Pre-premary"
     2 "Adult education"
    11 "D1"
    12 "D2"
    13 "D3"
    14 "D4"
    15 "D5"
    16 "D6"
    17 "D7"
    18 "D8"
    19 "OSC"
    20 "MS+COURSE"
    21 "F1"
    22 "F2"
    23 "F3"
    24 "F4"
    25 "O+COURSE"
    31 "F5"
    32 "F6"
    33 "A+COURSE"
    34 "DIPLOMA"
    41 "U1"
    42 "U2"
    43 "U3"
    44 "U4"
    45 "U5&+"

COMPUTE higheduc = 0.
FORMATS higheduc (F2.0).
VECTOR person = AC9$01 TO AC9$20.
LOOP #i = 1 TO 20.
  IF ( person (#i) GT higheduc) higheduc = person (#i).
END LOOP.
EXECUTE.
*FREQUENCIES higheduc.
RECODE higheduc
(1 THRU 10 = 1) (11 THRU 17= 2) (18 THRU 20 = 3) (21 THRU 25 = 4) (26 THRU 34 = 5) (35 THRU HIGHEST = 6) (0 = 7) INTO higheduc_gr1.
VARIABLE LABELS higheduc_gr1 "Highest education completed by any member of household".
VALUE LABELS higheduc_gr1 
1 " Never attended school" 
2 " Lower primary"
3 " Primary"
4 " Secondary"
5 " Technical or other higher education / Diploma"
6 " University"
7 " Not stated".
FORMATS Higheduc_gr1 (F2.0).
*check/clean.
FREQUENCIES higheduc_gr1.
DELETE VARIABLES higheduc.

OUTPUT CLOSE ALL.
*******************************
*3) Create new variable (HHsize_gr1) with number of members in the household.(Use AB3$01 -AB3$20). 
COMPUTE HHsize = 0.
VECTOR person = AB3$01 TO AB3$20.
LOOP #i = 1 TO 20.
  IF ( person (#i) GT 0) HHsize = SUM(HHsize + 1).
END LOOP.
EXECUTE.
VARIABLE LABELS HHSize "Number of persons in the household".
RECODE HHsize (1 THRU 1 = 1) (2 THRU 2 = 2) (3 THRU 4 = 3) (5 THRU 9 = 4) (10 THRU HIGHEST = 5) INTO HHsize_Gr1.
VARIABLE LABELS HHsize_Gr1 "Household size (persons)".
VALUE LABELS HHsize_gr1 
1 "     1" 
2 "     2"
3 "3 - 4"
4 "5 - 9"
5 " 10+".
FORMATS HHsize_gr1 (F2.0).
*Check.
FREQUENCIES HHsize_Gr1.

OUTPUT CLOSE ALL.
*****************************************************************************.
*4) Create new variable (HHelGrid_gr1) with household connnected to grid or other el solutions."Electricity in household (grid/other/no electricity)".
* Check.
*FREQUENCIES C2 C4 C6 C7 C8 C9.
IF (C2 = 1) HHElGrid_gr1 = 1.
IF (C2 = 2 AND (C4 = 1 OR C6 = 1 OR C7 = 1 OR C8 = 1 OR C9 = 1) ) HHElGrid_gr1 = 2.
IF (C2 = 2  AND C4 = 2 AND C6 = 2 AND C7 = 2 AND C8 = 2 AND C9 = 2 ) HHelGrid_gr1 = 3.
IF (SYSMIS(C2) = 1  AND SYSMIS(C4) = 1 AND SYSMIS(C6) = 1 AND SYSMIS(C7) = 1 AND SYSMIS(C8) = 1 AND SYSMIS(C9) = 1) HHelGrid_gr1 = 4.
EXECUTE.
VARIABLE LABELS HHelGrid_gr1 "Electricity in the household (grid/other/no electricity)".
VALUE LABELS HHelGrid_gr1 
    1 "Household is connected to grid-based electricity (National or local)" 
    2 "Household is not connected any grid, but has other electricity solutions incl.use of dry-cell batteries"
    3 "Household has no electricity solutions "
    4 "Not stated".
*Check.
FREQUENCIES HHelGrid_gr1.

OUTPUT CLOSE ALL.
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
FREQUENCIES HHOccupStatus_gr1 HHOccupStatus_gr2 HHOccupStatus_gr3 HHOccupStatus_gr4 HHOccupStatus_gr5.

OUTPUT CLOSE ALL.
 ***********************************************************************************************************.
*6) Create variable with info for "grid in community" grouping for tabulation based on comD1..

*We already have a MR set comD1_gr1a to comD1_gr1k. 

**********************************************************.
*7) CREATE EXPENDITURE QUINTILE: 
A) Total annual HH exependitures
B) Total annual percapita HH expenditure 
C) Expenditure quintile (avg annual exp per capita in household) 

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

*A) Store and label total annual expenditures to the file. 
COMPUTE HHExpAll = SUM (CTMP1, CTMP2, CTMP3).
FORMATS HHExpAll (F20.0).
VARIABLE LABELS HHExpAll "Total household annual expenditure (TZS)". 
EXECUTE.
*Check.
*FREQUENCIES HHExpAll.

*B) Store and label per capita total annual expenditures to the file. 
COMPUTE HHExpAllCapita = (SUM(CTMP1, CTMP2, CTMP3) / HHsize).
FORMATS HHExpAllCapita (F20.0).
VARIABLE LABELS HHExpAllCapita "Total household per capita annual expenditure (TZS)". 
EXECUTE.

*Check.
*FREQUENCIES HHExpAll.
*Delete TMP variables.
DELETE VARIABLES Q16_TMP Q15_TMP Q14_TMP Q13_TMP Q12_TMP Q11_TMP   
Q2A$1_TMP Q2A$2_TMP Q2A$3_TMP Q2A$4_TMP Q2A$5_TMP Q2A$6_TMP Q2A$7_TMP
Q2B$1_TMP Q2B$2_TMP Q2B$3_TMP Q2B$4_TMP Q2B$5_TMP Q2B$6_TMP Q2B$7_TMP
Q2C$1_TMP Q2C$2_TMP Q2C$3_TMP Q2C$4_TMP Q2C$5_TMP Q2C$6_TMP Q2C$7_TMP
CTMP1 CTMP2 CTMP3.

*C) Create Expoenditure per capita quintiles.
COMPUTE ExpQnt = (HHExpAll / HHsize). 
EXECUTE.
RANK VARIABLES=ExpQnt (A)
  /NTILES(5)
  /PRINT=YES
  /TIES=MEAN.
IF (SYSMIS(NExpQnt)=1) NExpQnt=6.
VARIABLE LABELS NExpQnt "Household per capita total annual expenditure quintile".
VALUE LABELS NExpQnt 1"1st (Lowest)" 2"2nd" 3"3rd" 4"4th" 5"5th (Highest)" 6"Not stated". 
EXECUTE.

*Check/clean.
FREQUENCIES NExpQnt.
DELETE VARIABLES ExpQnt.

OUTPUT CLOSE ALL.
******************************************************************************************************
*8) CREATE WEALTH INDEX (QUINTILE)- CURRENT - NATIONAL.

*Start by making binary tmp scale variables (A-B-C below).

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

*persons per room.
COMPUTE tmpPers = 0.
COMPUTE tmpPers1 = SUM(HHsize / B6).
*FREQUENCIES tmpPers1.
IF ( tmpPers1 GT 0 AND tmpPers1 LE 2) tmpPers = 1.
VARIABLE LABELS tmpPers "Persons per room".
FREQUENCIES tmpPers.
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
VARIABLE LEVEL tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBed tmpTable tmpBicycle tmpMC tmpCar 
tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC tmpPot tmpTV tmpPump 
tmpTrad tmpLED tmpSave tmpLand tmpCattle tmpSmall tmpBirds ( SCALE).
EXECUTE.

*Decide on variables to use for a start. 
CTABLES
  /VLABELS VARIABLES= tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBed tmpTable tmpBicycle tmpMC tmpCar 
                     tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC tmpPot tmpTV tmpPump 
                     tmpTrad tmpLED tmpSave tmpLand tmpCattle tmpSmall tmpBirds UrbRur DISPLAY=LABEL
  /TABLE 
     tmpPers    [C][ROWPCT.COUNT PCT40.1] + tmpWalls   [C][ROWPCT.COUNT PCT40.1] + tmpRoof   [C][ROWPCT.COUNT PCT40.1] +
     tmpFloor    [C][ROWPCT.COUNT PCT40.1] + tmpToilet   [C][ROWPCT.COUNT PCT40.1] + tmpWater [C][ROWPCT.COUNT PCT40.1] + 
     tmpLight    [C][ROWPCT.COUNT PCT40.1] + tmpCook   [C][ROWPCT.COUNT PCT40.1] + tmpBed     [C][ROWPCT.COUNT PCT40.1] + 
     tmpTable   [C][ROWPCT.COUNT PCT40.1] + tmpBicycle [C][ROWPCT.COUNT PCT40.1] + tmpMC     [C][ROWPCT.COUNT PCT40.1] + 
     tmpCar      [C][ROWPCT.COUNT PCT40.1] + tmpRadio1 [C][ROWPCT.COUNT PCT40.1] + tmpRadio2 [C][ROWPCT.COUNT PCT40.1] + 
     tmpCharge [C][ROWPCT.COUNT PCT40.1] + tmpFan     [C][ROWPCT.COUNT PCT40.1] + tmpRefrig   [C][ROWPCT.COUNT PCT40.1] + 
     tmpMicro   [C][ROWPCT.COUNT PCT40.1] + tmpFreez   [C][ROWPCT.COUNT PCT40.1] + tmpWash   [C][ROWPCT.COUNT PCT40.1] + 
     tmpSewing [C][ROWPCT.COUNT PCT40.1] + tmpAC      [C][ROWPCT.COUNT PCT40.1] + tmpPC       [C][ROWPCT.COUNT PCT40.1] + 
     tmpPot      [C][ROWPCT.COUNT PCT40.1] + tmpTV       [C][ROWPCT.COUNT PCT40.1] + tmpPump    [C][ROWPCT.COUNT PCT40.1] + 
     tmpTrad     [C][ROWPCT.COUNT PCT40.1] + tmpLED     [C][ROWPCT.COUNT PCT40.1] + tmpSave     [C][ROWPCT.COUNT PCT40.1] + 
     tmpLand    [C][ROWPCT.COUNT PCT40.1] + tmpCattle   [C][ROWPCT.COUNT PCT40.1] + tmpSmall    [C][ROWPCT.COUNT PCT40.1] + 
     tmpBirds   [C][ROWPCT.COUNT PCT40.1]
  BY UrbRur /CLABELS ROWLABELS=OPPOSITE
  /CATEGORIES VARIABLES = 
      tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBed tmpTable tmpBicycle tmpMC 
      tmpCar tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC 
      tmpPot tmpTV tmpPump tmpTrad tmpLED tmpSave tmpLand tmpCattle tmpSmall tmpBirds ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES = UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE TOTAL=YES POSITION=AFTER.

*Check output window table.
*keep those items with FREQ more than 5% and less than 95% in both urb and rur strata (WFP proxy rule).

*For national Indicator take out: 
                    Radio2 Fan Refrig Micro Wash Sewing AC PC Pot Pump TradBulb SaveBulb (also take out all-Animals - based on later observations)

*First factor iteration..
FACTOR
   /VARIABLES tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBicycle tmpMC tmpRadio1  
                       tmpCharge tmpTV tmpFreez tmpLED tmpLand  
  /MISSING LISTWISE 
  /ANALYSIS  tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBicycle tmpMC tmpRadio1 
                     tmpCharge tmpTV tmpFreez tmpLED tmpLand  
  /PRINT INITIAL CORRELATION KMO AIC EXTRACTION ROTATION
  /FORMAT SORT
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

*check correlation matrix for too high ( >0.9) or too low (<0.1) correlation.
*For national indicator take out:
                   Batt-radio.and mob-charger 

DELETE VARIABLES FAC1_1 FAC2_1 FAC3_1 FAC4_1 FAC5_1.

*Second factor iteration..
FACTOR
   /VARIABLES  tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBicycle tmpMC tmpCar tmpTV tmpFreez tmpLED tmpLand
  /MISSING LISTWISE 
  /ANALYSIS  tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBicycle tmpMC tmpCar tmpTV tmpFreez tmpLED 
  /PRINT INITIAL CORRELATION KMO AIC EXTRACTION ROTATION
  /FORMAT SORT
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
  /VLABELS VARIABLES= tmpPers tmpRoof tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBicycle tmpMC tmpCar tmpTV 
                                        tmpFreez tmpLED tmpLand NFAC1_1 DISPLAY=LABEL
  /TABLE tmpPers[MEAN] + tmpRoof[MEAN] + tmpWalls [MEAN] + tmpFloor [MEAN] + tmpToilet [MEAN] + tmpWater [MEAN] + tmpLight [MEAN] + tmpCook [MEAN] +  
                                          tmpBicycle [MEAN] + tmpCar[MEAN] + tmpMC [MEAN] + tmpFreez[MEAN] + tmpTV [MEAN] + tmpLED [MEAN] + tmpLand [MEAN] 
    BY NFAC1_1  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=NFAC1_1 ORDER=A KEY=VALUE EMPTY=EXCLUDE.

*Check output window and take out:.
                                      * Pers Roof Bicycle Car MC Freez Land.

*Clean.
DELETE VARIABLES FAC1_1 FAC2_1 FAC3_1 FAC4_1 NFAC1_1.

*Third factor iteration.
FACTOR
   /VARIABLES tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED
  /MISSING LISTWISE 
  /ANALYSIS tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED
  /PRINT INITIAL CORRELATION KMO AIC EXTRACTION ROTATION
  /FORMAT SORT
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
  /VLABELS VARIABLES=tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED NFAC1_1 DISPLAY=LABEL
  /TABLE tmpWalls [MEAN] + tmpRoof [MEAN] + tmpFloor [MEAN] + tmpToilet [MEAN] + tmpWater [MEAN] + tmpLight [MEAN]+ tmpCook [MEAN] + 
              tmpTV [MEAN] + tmpLED [MEAN]
    BY NFAC1_1  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=NFAC1_1 ORDER=A KEY=VALUE EMPTY=EXCLUDE.

*For national indicator take out: 
                     Water and LED (based on later observations)

*Clean.
    DELETE VARIABLES FAC1_1 NFAC1_1.
    
    *Fourth factor iteration.
    FACTOR
       /VARIABLES tmpWalls tmpFloor tmpToilet tmpLight tmpCook tmpTV  
      /MISSING LISTWISE 
      /ANALYSIS tmpWalls tmpFloor tmpToilet tmpLight tmpCook tmpTV 
      /PRINT INITIAL CORRELATION KMO AIC EXTRACTION ROTATION
      /FORMAT SORT
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
      /VLABELS VARIABLES=tmpWalls tmpFloor tmpToilet tmpLight tmpCook tmpTV NFAC1_1 DISPLAY=LABEL
      /TABLE tmpWalls [MEAN] + tmpFloor [MEAN] + tmpToilet [MEAN] + tmpLight [MEAN]+ tmpCook [MEAN] + tmpTV [MEAN] 
        BY NFAC1_1  /SLABELS VISIBLE=NO
      /CATEGORIES VARIABLES=NFAC1_1 ORDER=A KEY=VALUE EMPTY=EXCLUDE.
    
    *Clean.
    DELETE VARIABLES FAC1_1 NFAC1_1.
    
*USE THIRD ITERATION AS BEST??
*Third factor iteration i.e. keep wall, floor, water, light-energy, cooking-energy and toilet-type (from B) + also TV and LED (from the asset list)..
FACTOR
   /VARIABLES tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED
  /MISSING LISTWISE 
  /ANALYSIS tmpWalls tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpTV tmpLED
  /PRINT INITIAL CORRELATION KMO AIC EXTRACTION ROTATION
  /FORMAT SORT
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

*Label final wealth index (quintile at national level).
RENAME VARIABLES NFAC1_1 = NatWIndex.
VARIABLE LABELS NatWIndex 'Wealth Index (National level)'.
VALUE LABELS  NatWIndex 1 "1st Lowest wealth" 2 "2nd"  3 "3rd" 4 "4th" 5 "5th Highest wealth". 
*Check.
FREQUENCIES NatWIndex.


GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=NatWIndex MEAN(tmpWalls) MEAN(tmpFloor) 
    MEAN(tmpToilet) MEAN(tmpWater) MEAN(tmpLight) MEAN(tmpCook) MEAN(tmpTV) MEAN(tmpLED) 
    MISSING=LISTWISE REPORTMISSING=NO
    TRANSFORM=VARSTOCASES(SUMMARY="#SUMMARY" INDEX="#INDEX")
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: NatWIndex=col(source(s), name("NatWIndex"), unit.category())
  DATA: SUMMARY=col(source(s), name("#SUMMARY"))
  DATA: INDEX=col(source(s), name("#INDEX"), unit.category())
  GUIDE: axis(dim(1), label("Wealth Index (National level)"))
  GUIDE: axis(dim(2), label("Mean"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label(""))
  GUIDE: text.title(label("Multiple Line Mean of Material for walls, Mean of Materials for ",
    "floor, Mean of Type of toilet, Mean of Water source, Mean of Light source, Mean of Cook ",
    "source, Mean of TV, Mean of LED bulbs by Wealth Index (National level) by INDEX"))
  SCALE: cat(dim(1), include("1", "2", "3", "4", "5"))
  SCALE: linear(dim(2), include(0))
  SCALE: cat(aesthetic(aesthetic.color.interior), include(
"0", "1", "2", "3", "4", "5", "6", "7"))
  ELEMENT: line(position(NatWIndex*SUMMARY), color.interior(INDEX), missing.wings())
END GPL.

*Compare Welatindex with exp qiuntiles. 
*TMP Remember to run expenditure quintile syntax before this step.
CROSSTABS
  /TABLES=NatWIndex BY NExpQnt
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ CC PHI LAMBDA UC CORR 
  /CELLS=COUNT
  /COUNT ROUND CELL.

*Clean.
DELETE VARIABLES tmpPers tmpWalls tmpRoof tmpFloor tmpToilet tmpWater tmpLight tmpCook tmpBed tmpTable tmpBicycle tmpMC tmpCar 
tmpRadio1 tmpRadio2 tmpCharge tmpFan tmpRefrig tmpMicro tmpFreez tmpWash tmpSewing tmpAC tmpPC tmpPot tmpTV tmpPump 
tmpTrad tmpLED tmpSave tmpLand tmpCattle tmpSmall tmpBirds FAC1_1 .

OUTPUT CLOSE ALL.

******************************************************************************************************.
*9) CREATE ENERGY TIERS . 

*<MULIG OPPDATERING INN HER>.

*********************************************************************************'.
*10) CREATE COOKING TIERS  .

*<MULIG OPPDATERING INN HER>


******************************************************************************************************   
*Save temporary HHQ + COM file and open again.
SAVE OUTFILE='tmp\TZHHCOM_2.sav'
/KEEP 
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 
********************************************************************.
*Open  file.and continue .
*OUTPUT CLOSE ALL.
*DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\TZHHCOM_2.sav'.

*Check the input file..
FREQUENCIES Region.

******************************************************************************************************
*LABELING AND GROUPING HH FILE INITIAL VARIABLES (at least in the b and part of c section???).. 
******************************************************************************************************
*B1 Numeric Years in community	
*check.
*FREQUENCIES B1.
COMPUTE B1_gr1 = $SYSMIS.
FORMATS B1_gr1(F3.0).
VARIABLE LEVEL B1_gr1 (NOMINAL).
RECODE B1 (LOWEST THRU 2 =1) (3 THRU 5 =2) (6 THRU 9 = 3) (10 THRU 19 = 4) (20 THRU HIGHEST = 5) (MISSING = 6) INTO B1_gr1.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
********************************
*B6 Numeric Number of rooms	None
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

OUTPUT CLOSE ALL.
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
    /B16_gr1e "Nyingine"
VALUE LABELS 
   B16_gr1a  1 "Yes"
  /B16_gr1b  1 "Yes" 
  /B16_gr1c  1 "Yes"
  /B16_gr1d  1 "Yes"
  /B16_gr1e  1 "Yes"
EXECUTE.
*Check.
FREQUENCIES B16_gr1a B16_gr1b B16_gr1c B16_gr1d B16_gr1e.

OUTPUT CLOSE ALL.
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
    /B18_gr1c "Other arrangements"
VALUE LABELS 
   B18_gr1a  1 "Yes"
  /B18_gr1b  1 "Yes" 
  /B18_gr1c  1 "Yes"
EXECUTE.
*Check..
FREQUENCIES B18_gr1a B18_gr1b B18_gr1c.

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.
*********************************************************
*C26 Numeric We would now like to know the capacity of the meter. What are the watts (W) stated? {88888, Don't know}...
*Check.
*FREQUENCIES C26.
COMPUTE C26_gr1 = $SYSMIS.
FORMATS C26_gr1(F3.0).
VARIABLE LEVEL C26_gr1 (NOMINAL).
RECODE C26 (LOWEST THRU 4999 =1) (5000 THRU 9999 =2) (10000 THRU 19999 = 3) (20000 THRU 88887 = 4)  (88888 = 5) INTO C26_gr1.
VARIABLE LABELS C26_gr1 "The capacity of the meter in watts (W)".
VALUE LABELS C26_gr1 
1 "            <   5 000" 
2 "  5 000 -   9 999"
3 "10 000 - 19 999"
4 "               20 000+"
5 "Don't know".
*Check..
FREQUENCIES C26_gr1.

OUTPUT CLOSE ALL.
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

OUTPUT CLOSE ALL.

*************************************************************************************************************
*POSSIBLE TO CONTINUE TO LABEL AND GROUP FROM HERE.
*<MORE?>


**************************************************************************************************************
*LABELLING GROUPING AND DERIVED KEY VARIABLES COMPLETED FOR THIS SYNTAX.

***************************************************************************************************************
*Save first version of household level production file with all community level varables attached..

SORT VARIABLES BY GeocodeHH (A).

SAVE OUTFILE='Production\TZHHLEVEL_1.sav'
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
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 

**************************************************************************************************************
 END OF FIRST VERSION HOUSEHOLD LEVEL PRODUCTION FILE (WITH COMMUNITY ATTACHED) REGROUPED AND LABELLED      .
**************************************************************************************************************

*FROM HERE:
*CREATE PERSON-LEVEL FILE.
********************************************************************.
*Open file.and continue .
*OUTPUT CLOSE ALL.
*DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='Production\TZHHLEVEL_1.sav'.

*Check the input file..
FREQUENCIES Region.

*Create the person-level file.
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
COMPUTE Age_gr1 = $SYSMIS.
FORMATS Age_gr1 (F3.0).
VARIABLE LEVEL Age_gr1 (NOMINAL).
RECODE Age (LOWEST THRU 4=1) (5 THRU 11 =2) (12 THRU 14 = 3) (15 THRU 19 = 4) (20 THRU 39 = 5) (40 THRU 64 = 6) (65 THRU HIGHEST =7) (MISSING = 8) INTO Age_gr1.
VARIABLE LABELS Age_gr1 "Age groups (Years)".
VALUE LABELS Age_gr1 
1 " 0  -  4"
2 " 5  - 11"
3 "12 - 14"
4 "15 - 19"
5 "20 - 39"
6 "40 - 64"
7 "     65+"
8 "Not stated".
*Check..
FREQUENCIES Age_gr1.

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

*4) Days of activity group.
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

SAVE OUTFILE ='Production\TZPRSLEVEL_1.sav'
/KEEP REC_ID Region GeocodeEA GeocodeHH HH UrbRur Xcoord Ycoord Date ADDRESS_LOCATION 
Name RelShip Head5YAgo Sex Age Marital Literacy EverAttend EnrollCurrY GradeCurrY AgeStartCurrY AttendCurrY AttendLastY GradeLastY  
HighEvComp MainOccpCurrY MainActCurrY MonthActCurrY DaysActCurrY MainOccp5YAgo MainAct5YAgo Cooking ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 

*****************************
*END OF SYNTAX
*****************************




