* Encoding: UTF-8.
* Created 19.01.2022. 
* Update: Kristian 26.01 - 10.02.2022       
* Update::Per 19.01 - 02.04.2022.
* SSB/NBS project team final approval: ................ 

*Objective: 1) Clean and label the community level file with an unique identifier ready for merge to the household file  
                 2) Secure consistency between community level and household level file

*Out-put: A community level file ready for merging with the household level file (at EA level) for further tabullation and analysis, 
   
*The SPSS file used here is exported from a ".CSPRO CSDb" internal project database format to the hereby SPSS ".sav" format file.  
*use the export syntax as created by CSPro at export ( add correct directory path to the "export syntax" and save the file to '....\tmp\ComTZ_1.sav).
***********************************************************************************************************************  
*The working filestructure for this program is as follows:

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
***********************************************************************************.
*Set address to the filestructure once and get the imported raw-data-file from the tmp folder..
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
GET FILE='tmp\ComTZ_1.sav'.
SET DECIMAL=DOT.
************************************************************
*add record number before any other operation on the file.
COMPUTE comREC_ID= $CASENUM.
FORMATS comREC_ID(F6.0).
VARIABLE LABELS comREC_ID "Record_ID".
EXECUTE.

*chek number of records on in-file.
FREQUENCIES C_A1.

*Prepare for efficent listing (all on one line) listings in the output window..
SET WIDTH=255.
ALTER TYPE A5(a20) C_LOGIN (a20).

**************************************
*Delete records created before ToE - TO DISCUSS WITH NBS (look at the data file - unfortunately we do not have date variable on the Community).
SORT CASES BY comREC_ID(A).
SELECT IF 
    comREC_ID GT 6.
EXECUTE.

*check.
FREQUENCIES C_A1.

************************************************************************************************************************
*START MANUAL CHECK ON ID CODES BASED ON GIS ATTRIBUTE CATALOGUE (XLS) TO ENTER POSSIBLE MISSING ID CODES INTO THE FILE.

*Prepare a help variable for ammount of nummeric response filled iin.
COMPUTE SUM_AtoPtmp = SUM(C1,C2, D2, D3, D4, D5, D6, D8, D9, D10, D11, D12, D13, D14, D15, D17, D18, D19, D20, D21, D22, D23, D25,
    D26, D27, D28, D29, D30, D31, D32, H1,H2,H3,H4,H5,F1,F2,F3,F4,F5,F6,F7,F8,I1,I2,I3,I4,I5,I6,I7,I8,I9,J2,GP1,GP2,GP3). 
EXECUTE.
FORMATS SUM_AtoPtmp (F10.0).

*Check and corrrect missings on ID variables C_A1 to C_A6.
TEMPORARY.
    SELECT IF (SYSMIS(C_A1)=1 OR SYSMIS(C_A2)=1 OR SYSMIS(C_A3)=1 OR SYSMIS(C_A4)=1 OR SYSMIS(C_A5)=1 OR SYSMIS(C_A6)=1).
LIST comREC_ID C_A1 C_A2 C_A3 C_A4 C_A5 C_A6 A5 SUM_AtoPtmp.

*Help sort.
*SORT CASES BY comREC_D (A).
*Help sort.
*SORT CASES BY   C_A1(A) C_A2(A) C_A3(A) C_A4(A) C_A5(A) C_A6 A5(A).

*corrections based on visuals (14.02.2022)..
IF (comREC_ID = 8) C_A3 = 123.
IF (comREC_ID = 11) C_A5 = 2.
IF (comREC_ID = 11) C_A6 = 2.
IF (comREC_ID = 74) C_A6 = 3.
EXECUTE.

*END MANUAL CHECK.
*****************************************************************************************************************************
*When C_A1 to C_A6 are complete, create new alpha-nummeric ID variables. .
*String for REGIONS.
STRING comRegion (A2).
COMPUTE comRegion = STRING(C_A1,n2).
*String for DISTRICT..
STRING comDistrict (A2).
COMPUTE comDistrict = STRING(C_A2,n2).
*String for WARD..
STRING comWard (A3).
COMPUTE comWard = STRING(C_A3,n3).
*String for DUMMY..
STRING comDummy (A2).
RECODE C_A4 
    (0 THRU 99 = "11") 
INTO comDummy.
*String for VILLAGE (Vil_Mta_N).
STRING comVillage (A2).
COMPUTE comVillage = STRING(C_A5,n2).
*String for EA.
STRING comEA (A3).
COMPUTE comEA = STRING(C_A6,n3).
*Concat the geocode for EA.
STRING  GeocodeEA (A14).
COMPUTE GeocodeEA=CONCAT(comRegion, comDistrict, comWard, comDummy, comVillage, comEA).
VARIABLE LABELS GeocodeEA "EA_Geocode".
EXECUTE.
* Labelling new ID variables.
VARIABLE LABELS comRegion "Region".
VALUE LABELS comRegion 
"01" 01 Dodoma
"02" 02 Arusha 
"03" 03 Kilimanjaro 
"04" 04 Tanga 
"05" 05 Morogoro 
"06" 06 Pwani 
"07" 07 Dar-es-salaam 
"08" 08 Lindi 
"09" 09 Mtwara 
"10" 10 Ruwuma
"11" 11 Iringa 
"12" 12 Mbeya
"13" 13 Singida
"14" 14 Tabora
"15" 15 Rukwa
"16" 16 Kigoma
"17" 17 Shinyanga
"18" 18 Kagera
"19" 19 Mwanza
"20" 20 Mara
"21" 21 Manyara
"22" 22 Njombe
"23" 23 Katavi
"24" 24 Simiyu
"25" 25 Geita
"26" 26 Songwe.
VARIABLE LABELS comDistrict "District".
VARIABLE LABELS comWard "Ward".
VARIABLE LABELS comDummy "Dummy".
VARIABLE LABELS comVillage "Village".
VARIABLE LABELS comEA "EA_ID".
EXECUTE.
*Check.
FREQUENCIES comRegion. 

*Check / list training EAs given in the project GIS.attribute file (5 in ARUSHA and 5 in MOROGORO).They should be removed from the survey.
TEMPORARY.
SELECT IF (ANY(GeocodeEA, "02060111102005","02062131104006","02031221101005","02031721111001","02060211101003","05051621115001",
"05051421104001","05051921104001","05051621101002","05050921130004") = 1).
LIST GeocodeEA comREC_ID A5 A6 A7 A8 A9 SUM_AtoPtmp.
EXECUTE.

*Remove training EAs..
SELECT IF (ANY(GeocodeEA, "02060111102005","02062131104006","02031221101005","02031721111001","02060211101003","05051621115001",
"05051421104001","05051921104001","05051621101002","05050921130004") = 0).
*Check.
FREQUENCIES comRegion.
************************************************
*Duplicate check on GeocodeEA.
SORT CASES BY GeocodeEA(A) SUM_AtoPtmp(A).
MATCH FILES
  /FILE=*
  /BY GeocodeEA
  /FIRST=PFirst
  /LAST=PLast.
EXECUTE.
*check.
FREQUENCIES PFirst PLast.
TEMPORARY.
SELECT IF 
    PFirst = 0 OR PLast = 0.
LIST comREC_ID GeocodeEA A5 C_LOGIN PFirst PLast SUM_AtoPtmp .

*Delete duplicates.-  the records with the less filling in.
SELECT IF PLast=1.
EXECUTE.

*Check.
FREQUENCIES comRegion GeocodeEA.

*Clean.
DELETE VARIABLES PFirst PLast SUM_AtoPtmp.

*Renaming variables  to prepare for merge with HHQ file.
RENAME VARIABLES  (C_LOGIN=comC_LOGIN) (C_A1=comC_A1) (C_A2=comC_A2) (C_A3=comC_A3) (C_A4=comC_A5) (C_A5=comC_A6) (A5=comA5) 
(A6 = comUrbRur) (A7=comA7) (A8=comA8) (A9=comA9) (A10=comA10) (B1=comB1) (C1=comC1) (C2=comC2) (C3 = comC3) 
(D1=comD1) (D2=comD2) (D3=comD3) (D4=comD4) (D5=comD5) (D6=comD6) (D7=comD7) (D8=comD8) (D9=comD9) (D10=comD10)
(D11=comD11) (D12=comD12) (D13=comD13) (D14=comD14) (D15=comD15) (D16=comD16) (D17=comD17) (D18=comD18) (D19=comD19)
(D20=comD20) (D21=comD21) (D22=comD22) (D23=comD23) (D24=comD24) (D25=comD25) (D26=comD26) (D27=comD27) (D28=comD28)
(D29=comD29) (D30=comD30) (D31=comD31) (D32=comD32) (D33=comD33) (D34=comD34) (D35=comD35) (H1=comH1) (H2=comH2) 
(H3=comH3) (H4=comH4) (H5=comH5) (F1=comF1) (F2=comF2) (F3=comF3) (F4=comF4) (F5=comF5) (F6=comF6) (F7=comF7) (F8=comF8)
(I1=comI1) (I2=comI2) (I3=comI3) (I4=comI4) (I5=comI5) (I6=comI6) (I7=comI7) (I8=comI8) (I9=comI9)
(J1=comJ1) (J2=comJ2) (GP1=comGP1) (GP2=comGP2) (GP3=comGP3).

*save workfile. 
SORT CASES BY GeocodeEA (A).
SAVE OUTFILE='tmp\ComTZ_1b.sav'
/KEEP 
comREC_ID
comRegion
GeocodeEA
comUrbRur
comEA
ALL 
/COMPRESSED.

********************************************************************************************.
*new step for syntax v7.
*Manual check of EAs comparing with GIS and initial EA sampling xls sheet.

*Open work file.
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\ComTZ_1b.sav'.
SET DECIMAL=DOT.

* Custom Tables.
CTABLES
  /VLABELS VARIABLES=GeocodeEA comUrbRur comREC_ID DISPLAY=LABEL
  /TABLE GeocodeEA BY comUrbRur [COUNT F40.0] + comREC_ID [MEAN]
  /CATEGORIES VARIABLES=GeocodeEA ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES=comUrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CRITERIA CILEVEL=95.

*Compare the EA codes in this table with the listing from the HHQ questionnaire and the initial sample sheet (xls)
*Correction.
IF(GeocodeEA = "20042011102001") GeocodeEA="20041011102002".
IF(GeocodeEA = "16031131103303") GeocodeEA="16031131103003".
EXECUTE.

*Findings per 02.04.22 for discussion.
*Missing Community interviews for.
*04032711103001
*04032011106001
*08052011103003
*14060821104013
*Extra Community interview not with valid EA code and not possible to recalculate.into the missing (se above) for the same Region.:
*14031711122022

*Missing HHQ but community interview OK for:
*07011921103030 
*07020421101006

*END OF CLEANING.
******************************************************************
*LABELLING AND GROUPING OF KEY VARIABLES.
******************************************************************
*comB1 about who involved in the community interview.MR.

*check.
*FREQUENCIES comB1.
IF (CHAR.SUBSTR(comB1,1,1)="A" OR CHAR.SUBSTR(comB1,2,1)="A" OR CHAR.SUBSTR(comB1,3,1)="A" OR 
    CHAR.SUBSTR(comB1,4,1)="A" OR CHAR.SUBSTR(comB1,5,1)="A"  ) comB1_gr1a = 1.
IF (CHAR.SUBSTR(comB1,1,1)="B" OR CHAR.SUBSTR(comB1,2,1)="B" OR CHAR.SUBSTR(comB1,3,1)="B"OR 
    CHAR.SUBSTR(comB1,4,1)="B" OR CHAR.SUBSTR(comB1,5,1)="B"  ) comB1_gr1b = 1.
IF (CHAR.SUBSTR(comB1,1,1)="C" OR CHAR.SUBSTR(comB1,2,1)="C" OR CHAR.SUBSTR(comB1,3,1)="C"OR 
    CHAR.SUBSTR(comB1,4,1)="C" OR CHAR.SUBSTR(comB1,5,1)="C"  ) comB1_gr1c = 1.
IF (CHAR.SUBSTR(comB1,1,1)="D" OR CHAR.SUBSTR(comB1,2,1)="D" OR CHAR.SUBSTR(comB1,3,1)="D"OR 
    CHAR.SUBSTR(comB1,4,1)="D" OR CHAR.SUBSTR(comB1,5,1)="D"  ) comB1_gr1d = 1.
IF (CHAR.SUBSTR(comB1,1,1)="E" OR CHAR.SUBSTR(comB1,2,1)="E" OR CHAR.SUBSTR(comB1,3,1)="E"OR 
    CHAR.SUBSTR(comB1,4,1)="E" OR CHAR.SUBSTR(comB1,5,1)="E"  ) comB1_gr1e = 1.
IF (CHAR.SUBSTR(comB1,1,1)="F" OR CHAR.SUBSTR(comB1,2,1)="F" OR CHAR.SUBSTR(comB1,3,1)="F"OR 
    CHAR.SUBSTR(comB1,4,1)="F" OR CHAR.SUBSTR(comB1,5,1)="F"  ) comB1_gr1f = 1.
IF (CHAR.SUBSTR(comB1,1,1)="G" OR CHAR.SUBSTR(comB1,2,1)="G" OR CHAR.SUBSTR(comB1,3,1)="G"OR 
    CHAR.SUBSTR(comB1,4,1)="G" OR CHAR.SUBSTR(comB1,5,1)="G"  ) comB1_gr1g = 1.
IF (CHAR.SUBSTR(comB1,1,1)="H" OR CHAR.SUBSTR(comB1,2,1)="H" OR CHAR.SUBSTR(comB1,3,1)="H"OR 
    CHAR.SUBSTR(comB1,4,1)="H" OR CHAR.SUBSTR(comB1,5,1)="H"  ) comB1_gr1h = 1.
IF (CHAR.SUBSTR(comB1,1,1)="I" OR CHAR.SUBSTR(comB1,2,1)="I" OR CHAR.SUBSTR(comB1,3,1)="I"OR 
    CHAR.SUBSTR(comB1,4,1)="I" OR CHAR.SUBSTR(comB1,5,1)="I"   ) comB1_gr1i = 1.
IF (CHAR.SUBSTR(comB1,1,1)="J" OR CHAR.SUBSTR(comB1,2,1)="J" OR CHAR.SUBSTR(comB1,3,1)="J"OR 
    CHAR.SUBSTR(comB1,4,1)="J" OR CHAR.SUBSTR(comB1,5,1)="J"  ) comB1_gr1j = 1.
IF (CHAR.SUBSTR(comB1,1,1)="K" OR CHAR.SUBSTR(comB1,2,1)="K" OR CHAR.SUBSTR(comB1,3,1)="K"OR 
    CHAR.SUBSTR(comB1,4,1)="K" OR CHAR.SUBSTR(comB1,5,1)="K"  ) comB1_gr1k = 1.
IF (CHAR.SUBSTR(comB1,1,1)="X" OR CHAR.SUBSTR(comB1,2,1)="X" OR CHAR.SUBSTR(comB1,3,1)="X"OR 
    CHAR.SUBSTR(comB1,4,1)="X" OR CHAR.SUBSTR(comB1,5,1)="X"  ) comB1_gr1l = 1.
EXECUTE.
FORMATS comB1_gr1a TO comB1_gr1l (F1.0).
VARIABLE LABELS 
  comB1_gr1a "Chief/Chairperson"
 /comB1_gr1b "Electricity/Engineering"
 /comB1_gr1c "Village committee"
 /comB1_gr1d "Elderly"
 /comB1_gr1e "School"
 /comB1_gr1f  "Agriculture"
 /comB1_gr1g "Health"
 /comB1_gr1h "Business"
 /comB1_gr1i  "Religious resposible"
 /comB1_gr1j  "Young adult"
 /comB1_gr1k "Adult women/men"
 /comB1_gr1l  "Other not specified".
 VALUE LABELS
 comB1_gr1a 1 "Yes" 
 /comB1_gr1b 1 "Yes" 
 /comB1_gr1c 1 "Yes"
 /comB1_gr1d 1 "Yes"
 /comB1_gr1e 1 "Yes" 
 /comB1_gr1f  1 "Yes"
 /comB1_gr1g 1 "Yes" 
 /comB1_gr1h 1 "Yes"
 /comB1_gr1i 1 "Yes" 
 /comB1_gr1j 1 "Yes"
 /comB1_gr1k 1 "Yes"
 /comB1_gr1l 1 "Yes".
*Check.
FREQUENCIES comB1_gr1a comB1_gr1b comB1_gr1c comB1_gr1d comB1_gr1e comB1_gr1f comB1_gr1g comB1_gr1h comB1_gr1i comB1_gr1j
                        comB1_gr1k comB1_gr1l. 
*OUTPUT CLOSE ALL.
********************************************************************************.
*Group comC1 number of households in community.
*FREQUENCIES comC1.
COMPUTE comC1_gr1 = $SYSMIS.
FORMATS comC1_gr1(F2.0).
VARIABLE LEVEL comC1_gr1 (NOMINAL).
RECODE comC1
(LOWEST THRU 99=1)
(100 THRU 499 =2)
(500 THRU 999 = 3)
(1000 THRU 4999 = 4)
(5000 THRU HIGHEST = 5)
INTO comC1_gr1.
VARIABLE LABELS comC1_gr1 "Number of households in the community".
VALUE LABELS comC1_gr1 
1 "            <100"
2 "   100 -  499"
3 "   500 -  999"
4 " 1000 -4999"
5 "            5000+".
*Check.
FREQUENCIES comC1_gr1.
*OUTPUT CLOSE ALL.
*****************************************************.
*Group comC3 Two most frequent type of economic activities MR.

*FREQUENCIES comC3.
IF (CHAR.SUBSTR(comC3,1,1)= "A") OR  (CHAR.SUBSTR(comC3,2,1)= "A") comC3_gr1a = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "B") OR  (CHAR.SUBSTR(comC3,2,1)= "B") comC3_gr1b = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "C") OR  (CHAR.SUBSTR(comC3,2,1)= "C") comC3_gr1c = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "D") OR  (CHAR.SUBSTR(comC3,2,1)= "D") comC3_gr1d = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "E") OR  (CHAR.SUBSTR(comC3,2,1)= "E") comC3_gr1e = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "F") OR  (CHAR.SUBSTR(comC3,2,1)= "F") comC3_gr1f = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "G") OR  (CHAR.SUBSTR(comC3,2,1)= "G") comC3_gr1g = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "H") OR  (CHAR.SUBSTR(comC3,2,1)= "H") comC3_gr1h = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "I")  OR  (CHAR.SUBSTR(comC3,2,1)= "I") comC3_gr1i = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "J") OR  (CHAR.SUBSTR(comC3,2,1)= "J") comC3_gr1j = 1.  
IF (CHAR.SUBSTR(comC3,1,1)= "Q") OR  (CHAR.SUBSTR(comC3,2,1)= "Q") comC3_gr1k = 1.  
EXECUTE.
FORMATS comC3_gr1a TO comC3_gr1k (F2.0).
VARIABLE LABELS  
       comC3_gr1a  "Crop production"
      /comC3_gr1b  "Livestock"  
      /comC3_gr1c  "Fishing/hunting" 
      /comC3_gr1d  "Trading"
      /comC3_gr1e  "Services"  
      /comC3_gr1f   "Small-scale industry (non-farm)" 
      /comC3_gr1g  "Large-scale commercial industry (non-farm)"
      /comC3_gr1h  "Transport"  
      /comC3_gr1i   "Professional occupations" 
      /comC3_gr1j   "Civil service"
      /comC3_gr1k  "Other not specified".  
VALUE LABELS 
     comC3_gr1a 1 "Yes"  
     /comC3_gr1b 1 "Yes" 
     /comC3_gr1c 1 "Yes" 
     /comC3_gr1d 1 "Yes" 
     /comC3_gr1e 1 "Yes"
     /comC3_gr1f  1 "Yes"  
     /comC3_gr1g 1 "Yes" 
     /comC3_gr1h 1 "Yes"
     /comC3_gr1i  1 "Yes" 
     /comC3_gr1j  1 "Yes" 
     /comC3_gr1k 1 "Yes". 
*check.
FREQUENCIES comC3_gr1a comC3_gr1b comC3_gr1c comC3_gr1d comC3_gr1d comC3_gr1e comC3_gr1f 
                        comC3_gr1g comC3_gr1h comC3_gr1i comC3_gr1j comC3_gr1k.
****************************************.
*Group comD1 all sources of electricity MR..

*FREQUENCIES comD1.
IF (CHAR.SUBSTR(comD1,1,1)="A" OR CHAR.SUBSTR(comD1,2,1)="A" OR CHAR.SUBSTR(comD1,3,1)="A" OR 
    CHAR.SUBSTR(comD1,4,1)="A" OR CHAR.SUBSTR(comD1,5,1)="A"  ) comD1_gr1a = 1.
IF (CHAR.SUBSTR(comD1,1,1)="B" OR CHAR.SUBSTR(comD1,2,1)="B" OR CHAR.SUBSTR(comD1,3,1)="B" OR 
    CHAR.SUBSTR(comD1,4,1)="B" OR CHAR.SUBSTR(comD1,5,1)="B"  ) comD1_gr1b = 1.
IF (CHAR.SUBSTR(comD1,1,1)="C" OR CHAR.SUBSTR(comD1,2,1)="C" OR CHAR.SUBSTR(comD1,3,1)="C" OR 
    CHAR.SUBSTR(comD1,4,1)="C" OR CHAR.SUBSTR(comD1,5,1)="C"  ) comD1_gr1c = 1.
IF (CHAR.SUBSTR(comD1,1,1)="D" OR CHAR.SUBSTR(comD1,2,1)="D" OR CHAR.SUBSTR(comD1,3,1)="D" OR 
    CHAR.SUBSTR(comD1,4,1)="D" OR CHAR.SUBSTR(comD1,5,1)="D"  ) comD1_gr1d = 1.
IF (CHAR.SUBSTR(comD1,1,1)="E" OR CHAR.SUBSTR(comD1,2,1)="E" OR CHAR.SUBSTR(comD1,3,1)="E" OR 
    CHAR.SUBSTR(comD1,4,1)="E" OR CHAR.SUBSTR(comD1,5,1)="E"  ) comD1_gr1e = 1.
IF (CHAR.SUBSTR(comD1,1,1)="F" OR CHAR.SUBSTR(comD1,2,1)="F" OR CHAR.SUBSTR(comD1,3,1)="F" OR 
    CHAR.SUBSTR(comD1,4,1)="F" OR CHAR.SUBSTR(comD1,5,1)="F"  ) comD1_gr1f = 1.
IF (CHAR.SUBSTR(comD1,1,1)="G" OR CHAR.SUBSTR(comD1,2,1)="G" OR CHAR.SUBSTR(comD1,3,1)="G" OR 
    CHAR.SUBSTR(comD1,4,1)="G" OR CHAR.SUBSTR(comD1,5,1)="G"  ) comD1_gr1g = 1.
IF (CHAR.SUBSTR(comD1,1,1)="H" OR CHAR.SUBSTR(comD1,2,1)="H" OR CHAR.SUBSTR(comD1,3,1)="H" OR 
    CHAR.SUBSTR(comD1,4,1)="H" OR CHAR.SUBSTR(comD1,5,1)="H"  ) comD1_gr1h = 1.
IF (CHAR.SUBSTR(comD1,1,1)="I" OR CHAR.SUBSTR(comD1,2,1)="I" OR CHAR.SUBSTR(comD1,3,1)="I" OR 
    CHAR.SUBSTR(comD1,4,1)="I" OR CHAR.SUBSTR(comD1,5,1)="I"  ) comD1_gr1i = 1.
IF (CHAR.SUBSTR(comD1,1,1)="J" OR CHAR.SUBSTR(comD1,2,1)="J" OR CHAR.SUBSTR(comD1,3,1)="J" OR 
    CHAR.SUBSTR(comD1,4,1)="J" OR CHAR.SUBSTR(comD1,5,1)="J"  ) comD1_gr1j = 1.
IF (CHAR.SUBSTR(comD1,1,1)="X" OR CHAR.SUBSTR(comD1,2,1)="X" OR CHAR.SUBSTR(comD1,3,1)="X" OR 
    CHAR.SUBSTR(comD1,4,1)="X" OR CHAR.SUBSTR(comD1,5,1)="X"  ) comD1_gr1k = 1.
EXECUTE.
FORMATS comD1_gr1a TO comD1_gr1k (F2.0).
VARIABLE LABELS 
      comD1_gr1a "National grid"
     /comD1_gr1b  "Local mini-grid" 
     /comD1_gr1c  "Aggregate" 
     /comD1_gr1d  "Solar home system"
     /comD1_gr1e  "Solar lantern home system" 
     /comD1_gr1f   "Rechargable battery" 
     /comD1_gr1g  "Wind power" 
     /comD1_gr1h  "No electric power in the community, but grid in the neighbour community"  
     /comD1_gr1i   "No electric power in the community, but can charge batteries and mobiles in the neighbour community" 
     /comD1_gr1j   "No electric power in this or neighbour community, but can charge mobiles further away within walking distance"
     /comD1_gr1k  "No electric power in this or neighbour community within walking distance".  
VALUE LABELS 
     comD1_gr1a 1 "Yes"  
     /comD1_gr1b 1 "Yes" 
     /comD1_gr1c 1 "Yes" 
     /comD1_gr1d 1 "Yes" 
     /comD1_gr1e 1 "Yes"  
     /comD1_gr1f  1 "Yes"  
     /comD1_gr1g 1 "Yes" 
     /comD1_gr1h 1 "Yes"
     /comD1_gr1i  1 "Yes" 
     /comD1_gr1j  1 "Yes"
     /comD1_gr1k 1 "Yes". 
*Check.
FREQUENCIES comD1_gr1a comD1_gr1b comD1_gr1c comD1_gr1d comD1_gr1e comD1_gr1f 
                        comD1_gr1g comD1_gr1h comD1_gr1i comD1_gr1j comD1_gr1k.
*OUTPUT CLOSE ALL.
**********************************
*Group comD2 distance to TANESCO/EDM office.
*FREQUENCIES comD2.
COMPUTE comD2_gr1 = $SYSMIS.
FORMATS comD2_gr1(F3.0).
VARIABLE LEVEL comD2_gr1 (NOMINAL).
RECODE comD2
(LOWEST THRU 1=1)
(2 THRU 9 = 2)
(10 THRU 19 = 3)
(20 THRU 49 = 4)
(50 THRU 87 = 5)
(88 = 6)
(MISSING = 7)
INTO comD2_gr1.
VARIABLE LABELS comD2_gr1 "Distance from the community to the nearest TANESCO/EDM office (km)".
VALUE LABELS comD2_gr1 
1 "        <2"
2 "   2 -  9"
3 "10 - 19"
4 "20 - 49"
5 "       50+"
6 "Don't know"
7 "Not stated".
*Check.
FREQUENCIES comD2_gr1.
*OUTPUT CLOSE ALL.
*****************************************
*Group comD8 years with grid connection.
*FREQUENCIES comD8.
COMPUTE comD8_gr1 = $SYSMIS.
FORMATS comD8_gr1(F3.0).
VARIABLE LEVEL comD8_gr1 (NOMINAL).
RECODE comD8
(LOWEST THRU 4 = 1)
(5 THRU 9 = 2)
(10 THRU 19 = 3)
(20 THRU 49 = 4)
(50 THRU HIGHEST = 5)
(MISSING = 6)
INTO comD8_gr1.
VARIABLE LABELS comD8_gr1 "Years with grid-connection in the community".
VALUE LABELS comD8_gr1 
1 "        <5"
2 "   5 -  9"
3 "10 - 19"
4 "20 - 49"
5 "       50+"
6 "Not stated".
*Check.
FREQUENCIES comD8_gr1.
*OUTPUT CLOSE ALL.
*************************************
*Group comD10 ammount paid for grid connection.
*FREQUENCIES comD10.
COMPUTE comD10_gr1 = $SYSMIS.
FORMATS comD10_gr1(F10.0).
IF (comD10 = 88 OR comD10 = 888 OR comD10 = 8888 OR comD10=88888 OR comD10 = 888888 OR comD10 = 8888888) comD10=88888888. 
EXECUTE.
VARIABLE LEVEL comD10_gr1 (NOMINAL).
RECODE comD10
(LOWEST  THRU       29999   = 1)
(   30000    THRU     199999   = 2)
( 200000     THRU 88888887   = 3)
(88888888                             = 4)
(MISSING                          =    5)
INTO comD10_gr1.
VARIABLE LABELS comD10_gr1 "Ammount paid by the community for grid connection (1000 TZS)".
VALUE LABELS comD10_gr1 
1 "          <30"
2 "  30 - 199"
3 "         200 +"
4 "Dont' know" 
5 "Not stated".
*Check.
FREQUENCIES comD10_gr1.
*OUTPUT CLOSE ALL.
******************************
*Group comD16 Worst month for grid-service  MR.

*FREQUENCIES comD16.
IF (CHAR.SUBSTR(comD16,1,1)="a" OR CHAR.SUBSTR(comD16,2,1)="a" OR CHAR.SUBSTR(comD16,3,1)="a")  comD16_gr1a = 1.
IF (CHAR.SUBSTR(comD16,1,1)="b" OR CHAR.SUBSTR(comD16,2,1)="b" OR CHAR.SUBSTR(comD16,3,1)="b")  comD16_gr1b = 1.
IF (CHAR.SUBSTR(comD16,1,1)="c" OR CHAR.SUBSTR(comD16,2,1)="c" OR CHAR.SUBSTR(comD16,3,1)="c")  comD16_gr1c = 1.
IF (CHAR.SUBSTR(comD16,1,1)="d" OR CHAR.SUBSTR(comD16,2,1)="d" OR CHAR.SUBSTR(comD16,3,1)="d")  comD16_gr1d = 1.
IF (CHAR.SUBSTR(comD16,1,1)="e" OR CHAR.SUBSTR(comD16,2,1)="e" OR CHAR.SUBSTR(comD16,3,1)="e")  comD16_gr1e = 1.
IF (CHAR.SUBSTR(comD16,1,1)="f" OR CHAR.SUBSTR(comD16,2,1)="f" OR CHAR.SUBSTR(comD16,3,1)="f")     comD16_gr1f = 1.
IF (CHAR.SUBSTR(comD16,1,1)="g" OR CHAR.SUBSTR(comD16,2,1)="g" OR CHAR.SUBSTR(comD16,3,1)="g")  comD16_gr1g = 1.
IF (CHAR.SUBSTR(comD16,1,1)="h" OR CHAR.SUBSTR(comD16,2,1)="h" OR CHAR.SUBSTR(comD16,3,1)="h")  comD16_gr1h = 1.
IF (CHAR.SUBSTR(comD16,1,1)="i" OR CHAR.SUBSTR(comD16,2,1)="i" OR CHAR.SUBSTR(comD16,3,1)="i")     comD16_gr1i = 1.
IF (CHAR.SUBSTR(comD16,1,1)="j" OR CHAR.SUBSTR(comD16,2,1)="j" OR CHAR.SUBSTR(comD16,3,1)="j")     comD16_gr1j = 1.
IF (CHAR.SUBSTR(comD16,1,1)="k" OR CHAR.SUBSTR(comD16,2,1)="k" OR CHAR.SUBSTR(comD16,3,1)="k")  comD16_gr1k = 1.
IF (CHAR.SUBSTR(comD16,1,1)="l" OR CHAR.SUBSTR(comD16,2,1)="l" OR CHAR.SUBSTR(comD16,3,1)="l")     comD16_gr1l = 1.
EXECUTE.
FORMATS comD16_gr1a TO comD16_gr1l (F2.0).
VARIABLE LABELS 
      comD16_gr1a "January" 
     /comD16_gr1b  "February" 
     /comD16_gr1c  "March" 
     /comD16_gr1d  "April"
     /comD16_gr1e  "May" 
     /comD16_gr1f   "June" 
     /comD16_gr1g  "July" 
     /comD16_gr1h  "August"  
     /comD16_gr1i   "September" 
     /comD16_gr1j   "October"
     /comD16_gr1k  "November"  
     /comD16_gr1l   "December".
VALUE LABELS 
      comD16_gr1a 1 "Yes" 
     /comD16_gr1b 1 "Yes" 
     /comD16_gr1c 1 "Yes" 
     /comD16_gr1d 1 "Yes" 
     /comD16_gr1e 1 "Yes" 
     /comD16_gr1f 1 "Yes" 
     /comD16_gr1g 1 "Yes" 
     /comD16_gr1h 1 "Yes" 
     /comD16_gr1i 1 "Yes"
     /comD16_gr1j 1 "Yes" 
     /comD16_gr1k 1 "Yes" 
     /comD16_gr1l 1 "Yes". 
*Check.
FREQUENCIES comD16_gr1a comD16_gr1b comD16_gr1c comD16_gr1d comD16_gr1e comD16_gr1f comD16_gr1g comD16_gr1h comD16_gr1i 
comD16_gr1j comD16_gr1k comD16_gr1l.
*OUTPUT CLOSE ALL.
***********************************************
*Group comD20 total duration of outages/black-outs last week (hours).
*FREQUENCIES comD20.
COMPUTE comD20_gr1 = $SYSMIS.
FORMATS comD20_gr1(F10.0).
VARIABLE LEVEL comD20_gr1 (NOMINAL).
RECODE comD20
(LOWEST THRU 1 = 1)
(2 THRU 4 = 2)
(5 THRU 9 = 3)
(10 THRU 19 = 4)
(20 THRU HIGHEST = 5)
(MISSING = 6)
INTO comD20_gr1.
VARIABLE LABELS comD20_gr1 "Total duration of outages/black-outs in the community during the last week (hours)".
VALUE LABELS comD20_gr1 
1 "       <2"
2 "   2 -  4"
3 "   5 -  9"
4 "10 - 19"
5 "       20 +"
6 "Not stated".
*Check.
FREQUENCIES comD20_gr1.
*OUTPUT CLOSE ALL.
************************************
*Group comD23 number of days before previous blackut was repaired and the community regained power.
*FREQUENCIES comD23.
COMPUTE comD23_gr1 = $SYSMIS.
FORMATS comD23_gr1(F10.0).
VARIABLE LEVEL comD23_gr1 (NOMINAL).
RECODE comD23
(LOWEST THRU 1 = 1)
(2 THRU 4 = 2)
(5 THRU 9 = 3)
(10 THRU 19 = 4)
(20 THRU HIGHEST = 5)
(MISSING = 6)
INTO comD23_gr1.
VARIABLE LABELS comD23_gr1 "Number of days it took to repair after pervious outages/black-outs for the community to regain power".
VALUE LABELS comD23_gr1 
1 "        <2"
2 "    2 -  4"
3 "    5 -  9"
4 " 10 - 19"
5 "       20 +"
6 "Not stated".
*Check.
FREQUENCIES comD23_gr1.
*OUTPUT CLOSE ALL.
****************************************
*Group D24 Two most serious problems for the community with the grid electricity.MR.

*FREQUENCIES comD24.
IF (CHAR.SUBSTR(comD24,1,1)="a" OR CHAR.SUBSTR(comD24,2,1)="a")  comD24_gr1a = 1.
IF (CHAR.SUBSTR(comD24,1,1)="b" OR CHAR.SUBSTR(comD24,2,1)="b")  comD24_gr1b = 1.
IF (CHAR.SUBSTR(comD24,1,1)="c" OR CHAR.SUBSTR(comD24,2,1)="c")  comD24_gr1c = 1.
IF (CHAR.SUBSTR(comD24,1,1)="d" OR CHAR.SUBSTR(comD24,2,1)="d")  comD24_gr1d = 1.
IF (CHAR.SUBSTR(comD24,1,1)="e" OR CHAR.SUBSTR(comD24,2,1)="e")  comD24_gr1e = 1.
IF (CHAR.SUBSTR(comD24,1,1)="f" OR CHAR.SUBSTR(comD24,2,1)="f")  comD24_gr1f = 1.
IF (CHAR.SUBSTR(comD24,1,1)="g" OR CHAR.SUBSTR(comD24,2,1)="g")  comD24_gr1g = 1.
IF (CHAR.SUBSTR(comD24,1,1)="h" OR CHAR.SUBSTR(comD24,2,1)="h")  comD24_gr1h = 1.
IF (CHAR.SUBSTR(comD24,1,1)="i" OR CHAR.SUBSTR(comD24,2,1)="i")  comD24_gr1i = 1.
IF (CHAR.SUBSTR(comD24,1,1)="q" OR CHAR.SUBSTR(comD24,2,1)="q")  comD24_gr1j = 1.
IF (CHAR.SUBSTR(comD24,1,1)="x" OR CHAR.SUBSTR(comD24,2,1)="x")  comD24_gr1k = 1.
EXECUTE.
FORMATS comD24_gr1a TO comD24_gr1k (F2.0).
VARIABLE LABELS  
     comD24_gr1a "Supply/shortages/not enough hours of electricity" 
    /comD24_gr1b  "Low/high voltage, Problems of voltage"  
    /comD24_gr1c  "Unpredictable interruptions" 
    /comD24_gr1d  "Unpredictedly high bills"  
    /comD24_gr1e  "Too expensive" 
    /comD24_gr1f  "Do not trust the supplier"  
    /comD24_gr1g  "Can not power large appliances" 
    /comD24_gr1h  "Mainteinance/service problems"  
    /comD24_gr1i  "Unpredictable bills" 
    /comD24_gr1j  "Other problems not specified"  
    /comD24_gr1k  "No problems". 
VALUE LABELS 
      comD24_gr1a 1 "Yes" 
    / comD24_gr1b 1 "Yes" 
    /comD24_gr1c 1 "Yes"  
    /comD24_gr1d 1 "Yes"  
    /comD24_gr1e 1 "Yes" 
    /comD24_gr1f 1 "Yes"   
    /comD24_gr1g 1 "Yes"  
    /comD24_gr1h 1 "Yes" 
    /comD24_gr1i 1 "Yes"  
    /comD24_gr1j 1 "Yes"  
    /comD24_gr1k 1 "Yes".
*Check.
FREQUENCIES comD24_gr1a  comD24_gr1b comD24_gr1c comD24_gr1d comD24_gr1e comD24_gr1f comD24_gr1g comD24_gr1h comD24_gr1i 
comD24_gr1j  comD24_gr1k. 
*OUTPUT CLOSE ALL.
*****************************************************
*Group comD33 Possible to buy or lease a solar home system in the community.MR.

*FREQUENCIES comD33.
IF (CHAR.SUBSTR(comD33,1,2)="01" OR CHAR.SUBSTR(comD33,3,2)="01" OR CHAR.SUBSTR(comD33,6,2)="01" )  comD33_gr1a = 1.
IF (CHAR.SUBSTR(comD33,1,2)="02" OR CHAR.SUBSTR(comD33,3,2)="02" OR CHAR.SUBSTR(comD33,6,2)="02" )  comD33_gr1b = 1.
IF (CHAR.SUBSTR(comD33,1,2)="03" OR CHAR.SUBSTR(comD33,3,2)="03" OR CHAR.SUBSTR(comD33,6,2)="03" )  comD33_gr1c = 1.
IF (CHAR.SUBSTR(comD33,1,2)="04" OR CHAR.SUBSTR(comD33,3,2)="04" OR CHAR.SUBSTR(comD33,6,2)="04" )  comD33_gr1d = 1.
IF (CHAR.SUBSTR(comD33,1,2)="55" OR CHAR.SUBSTR(comD33,3,2)="55" OR CHAR.SUBSTR(comD33,6,2)="55" )  comD33_gr1e = 1.
EXECUTE.
FORMATS comD33_gr1a TO comD33_gr1e (F2.0).
VARIABLE LABELS 
  comD33_gr1a "Purchase from shops" 
 /comD33_gr1b "Purchase/lease from private companies" 
 /comD33_gr1c "Purchase/lease from NGOs" 
 /comD33_gr1d "Free" 
 /comD33_gr1e "Other not specified". 
VALUE LABELS comD33_gr1a 1 "Yes" /comD33_gr1b 1 "Yes" /comD33_gr1c 1 "Yes" /comD33_gr1d 1 "Yes" /comD33_gr1e 1 "Yes". 
*Check.
FREQUENCIES comD33_gr1a  comD33_gr1b  comD33_gr1c  comD33_gr1d  comD33_gr1e. 
*OUTPUT CLOSE ALL.
*********************************************
*Group comF4 distance from the village to the nearest town/city (km).
*FREQUENCIES comF4.
COMPUTE comF4_gr1 = $SYSMIS.
FORMATS comF4_gr1(F3.0).
VARIABLE LEVEL comF4_gr1 (NOMINAL).
RECODE comF4
(LOWEST THRU 1=1)
(2 THRU 9 = 2)
(10 THRU 19 = 3)
(20 THRU 49 = 4)
(50 THRU HIGHEST = 5)
INTO comF4_gr1.
VARIABLE LABELS comF4_gr1 "Distance from the community to the nearest town/city (km)".
VALUE LABELS comF4_gr1 
1 "       <2"
2 "   2 -  9"
3 "10 - 19"
4 "20 - 49"
5 "       50+".
*Check.
FREQUENCIES comF4_gr1.
*OUTPUT CLOSE ALL.
************************************
*Group comF5 distance from the village to the district center (km).
*FREQUENCIES comF5.
COMPUTE comF5_gr1 = $SYSMIS.
FORMATS comF5_gr1(F3.0).
VARIABLE LEVEL comF5_gr1 (NOMINAL).
RECODE comF5
(LOWEST THRU 1=1)
(2 THRU 9 = 2)
(10 THRU 19 = 3)
(20 THRU 49 = 4)
(50 THRU HIGHEST = 5)
INTO comF5_gr1.
VARIABLE LABELS comF5_gr1 "Distance from the community to the district center (km)".
VALUE LABELS comF5_gr1 
1 "       <2"
2 "  2 -   9"
3 "10 - 19"
4 "20 - 49"
5 "      50+".
*Check.
FREQUENCIES comF5_gr1.
*OUTPUT CLOSE ALL.
****************************************
*Group comF6 distance from the village to the nearest bank branch (km).
*FREQUENCIES comF6.
COMPUTE comF6_gr1 = $SYSMIS.
FORMATS comF6_gr1(F3.0).
VARIABLE LEVEL comF6_gr1 (NOMINAL).
RECODE comF6
(LOWEST THRU 1=1)
(2 THRU 9 = 2)
(10 THRU 19 = 3)
(20 THRU 49 = 4)
(50 THRU HIGHEST = 5)
INTO comF6_gr1.
VARIABLE LABELS comF6_gr1 "Distance from the community to the nearest bank branch (km)".
VALUE LABELS comF6_gr1 
1 "       <2"
2 "   2 -  9"
3 "10 - 19"
4 "20 - 49"
5 "      50+".
*Check.
FREQUENCIES comF6_gr1.
*OUTPUT CLOSE ALL.
***************************************
*Group comF7 distance from the village to the nearest micro finance institution (km).
*FREQUENCIES comF7.
COMPUTE comF7_gr1 = $SYSMIS.
FORMATS comF7_gr1(F3.0).
VARIABLE LEVEL comF7_gr1 (NOMINAL).
RECODE comF7
(LOWEST THRU 1=1)
(2 THRU 9 = 2)
(10 THRU 19 = 3)
(20 THRU 49 = 4)
(50 THRU HIGHEST = 5)
INTO comF7_gr1.
VARIABLE LABELS comF7_gr1 "Distance from the community to the nearest micro-finance institution (km)".
VALUE LABELS comF7_gr1 
1 "       <2"
2 "   2 -  9"
3 "10 - 19"
4 "20 - 49"
5 "      50+".
*Check.
FREQUENCIES comF7_gr1.
*OUTPUT CLOSE ALL.
****************************************
*Group J1. Does your community have any form of street lightning? MR.

*FREQUENCIES comJ1.
IF (CHAR.SUBSTR(comJ1,1,1)="A" OR CHAR.SUBSTR(comJ1,2,1)="A" OR CHAR.SUBSTR(comJ1,3,1)="A" )  comJ1_gr1a = 1.
IF (CHAR.SUBSTR(comJ1,1,1)="B" OR CHAR.SUBSTR(comJ1,2,1)="B" OR CHAR.SUBSTR(comJ1,3,1)="B" )  comJ1_gr1b = 1.
IF (CHAR.SUBSTR(comJ1,1,1)="C" OR CHAR.SUBSTR(comJ1,2,1)="C" OR CHAR.SUBSTR(comJ1,3,1)="C" )  comJ1_gr1c = 1.
*IF (CHAR.SUBSTR(comJ1,1,1)=" "  )  comJ1_gr1miss = 1.
EXECUTE.
FORMATS comJ1_gr1a TO comJ1_gr1c (F2.0).
VARIABLE LABELS 
     comJ1_gr1a "Public street lights" 
    /comJ1_gr1b "Outdoor lights/security lights"  
    /comJ1_gr1c "No lighting".
VALUE LABELS 
      comJ1_gr1a 1 "Yes"  
     /comJ1_gr1b 1 "Yes" 
     /comJ1_gr1c 1 "Yes" .
*Check.
FREQUENCIES comJ1_gr1a comJ1_gr1b comJ1_gr1c .
*OUTPUT CLOSE ALL.

*END OF LABELLING/GROUPING.
***********************************************************************************************************
*Organize the new created ID variables first on the file, sort file by Geocode (A) and store/save.

*THIS FILE (tmp\ComTZ_2.sav) IS READY TO BE MERGED TO THE HHQ FILE.

SORT CASES BY GeocodeEA (A).
SAVE OUTFILE='tmp\ComTZ_2.sav'
/KEEP 
comREC_ID
comRegion
GeocodeEA
comUrbRur
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.

***************************************************************************************
*END OF SYNTAX FOR CLEANING AND LABELING. 
****************************************************************************************



*SOME EXTRA. 
*PRELIMINARY/TESTING TABULATION AND ANALYSIS AT COMMUNITY LEVEL.
*****************************************************************************************.
*Open and re-save new file for further community level analysis.   

*OUTPUT CLOSE ALL.
*DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\ComTZ_2.sav'.
SET DECIMAL=DOT.

SAVE OUTFILE='tmp\ComTZ_3.sav'
/KEEP 
ALL.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.

GET FILE='tmp\ComTZ_3.sav'.
SET DECIMAL=DOT.
*****************************************************************************************
* FREQUENCIES.
FREQUENCIES comEA comUrbRur comA7 comA8 comA9 comA10 comB1 comC1 comC2 comC3 comD1
comD2 comD3 comD4 comD5 comD6 comD7 comD8 comD9 comD10 comD11 comD12 comD13 comD14 comD15 comD16 comD17 comD18 comD19 
comD20 comD21 comD22 comD23 comD24 comD25 comD26 comD27 comD28 comD29 comD30 comD31 comD32 comD33 comD34 comD35 comH1
comH2 comH3 comH4 comH5 comF1 comF2 comF3 comF4 comF5 comF6 comF7 comF8 comI1 comI2 comI3 comI4 comI5 comI6 comI7 comI8 comI9
comJ1 comJ2 comGP1 comGP2 comGP3. 

FREQUENCIES comRegion GeocodeEA comB1_gr1a comB1_gr1b comB1_gr1c comB1_gr1d comB1_gr1e comB1_gr1f comB1_gr1g comB1_gr1h 
comB1_gr1i comB1_gr1j comB1_gr1k comB1_gr1l comC1_gr1 comC3_gr1a comC3_gr1b comC3_gr1c comC3_gr1d comC3_gr1e 
comC3_gr1f comC3_gr1g comC3_gr1h comC3_gr1i comC3_gr1j comC3_gr1k  comD1_gr1a comD1_gr1b comD1_gr1c comD1_gr1d 
comD1_gr1e comD1_gr1f comD1_gr1g comD1_gr1h comD1_gr1i comD1_gr1j comD1_gr1k  comD2_gr1 comD8_gr1 comD10_gr1 
comD16_gr1a comD16_gr1b comD16_gr1c comD16_gr1d comD16_gr1e comD16_gr1f comD16_gr1g comD16_gr1h comD16_gr1i comD16_gr1j 
comD16_gr1k comD16_gr1l  comD20_gr1 comD23_gr1 comD24_gr1a comD24_gr1b comD24_gr1c comD24_gr1d comD24_gr1e 
comD24_gr1f comD24_gr1g comD24_gr1h comD24_gr1i comD24_gr1j comD24_gr1k  comD33_gr1a comD33_gr1b comD33_gr1c 
comD33_gr1d comD33_gr1e comF4_gr1 comF5_gr1 comF6_gr1 comF7_gr1 comJ1_gr1a comJ1_gr1b comJ1_gr1c.

*export freq results to xls worksheet.
*OBS: If the XLS worksheet already exists, change "CREATESHEET" to "MODIFYSHEET" in the syntax below. 
*OUTPUT EXPORT
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ComTZ_TAB1.xls'
     OPERATION= CREATESHEET  
     SHEET =  'FREQ1'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.

OUTPUT CLOSE ALL.
*************************************************
*CROSSTAB.
*example-macro. 
DEFINE !macro_CD1   (n1=!TOKENS(1) )
CROSSTABS
  /TABLES=comRegion BY !n1
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.
!ENDDEFINE.
!macro_CD1 n1=comC1_gr1.
!macro_CD1 n1=comC2.
!macro_CD1 n1=comD2_gr1.

*Export Crosstabs results to XLS worksheet.
*OUTPUT EXPORT 
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ComTZ_TAB1.xls'
     OPERATION= MODIFYSHEET  
     SHEET =  'CROSS1'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.

OUTPUT CLOSE ALL.
***********************************************************************.
*TABULATION..
*example-macro a few grouped variables and also a multi-response question .
DEFINE !macro_TABCOM1 (n1=!TOKENS(1))
CTABLES
 /VLABELS VARIABLES=  !n1 DISPLAY=LABEL
 /VLABELS VARIABLES=comUrbRur, comC1_gr1, comRegion DISPLAY=LABEL
 /TABLE  
 comUrbRur [C] +  comC1_gr1 [C] +  comRegion [C]   
       BY  
 !n1 [C] [ROWPCT.COUNT F40.0]  + !n1[S] [COUNT] /SLABELS VISIBLE=YES  
/CATEGORIES VARIABLES=comC1_gr1 [1, 2, 3, 4, 5, OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comUrbRur [1, 2] EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
/CATEGORIES VARIABLES=comRegion [OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=!n1 [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
/TITLES 
TITLE = "Table #. <Selected variable> by location, community size, conection to grid and region. Percent (and number of obs)"
CAPTION = "*Source: IASES tabulation test in Tanzania 2021/22 - unweighted data". 
!ENDDEFINE.
!macro_TABCOM1 n1=comF4_gr1.
!macro_TABCOM1 n1=comD2_gr1.
*add more variables here.

*example tabulation of multiple response variables.
* Define Multiple Response Sets.
MRSETS
  /MDGROUP NAME=$lighting LABEL='Outdoor lighting in the community' CATEGORYLABELS=VARLABELS 
    VARIABLES=comJ1_gr1a comJ1_gr1b comJ1_gr1c VALUE=1
  /DISPLAY NAME=[$lighting].

* Custom Tables.
CTABLES
  /VLABELS VARIABLES=comUrbRur comRegion $lighting DISPLAY=LABEL
  /TABLE comUrbRur [ROWPCT.TOTALN COMMA40.1] + comRegion [ROWPCT.TOTALN COMMA40.1] 
  BY 
  $lighting  /SLABELS VISIBLE=NO   
  /CATEGORIES VARIABLES=comUrbRur [1, 2] EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
  /CATEGORIES VARIABLES=comRegion ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', 
    '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26'] EMPTY=INCLUDE TOTAL=NO
  /CATEGORIES VARIABLES=$lighting [comJ1_gr1a, comJ1_gr1b, comJ1_gr1c] EMPTY=EXCLUDE TOTAL=NO POSITION=AFTER
  /TITLES 
   TITLE = "Table N. Outdoor lights in the community by location and region. Percent"
   CAPTION = "*Source: IASES tabulation test in Tanzania 2022 - unweighted data". 

*export tabullation results to worksheet.
*OUTPUT EXPORT 
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ComTZ_TAB1.xls'
     OPERATION= MODIFYSHEET  
     SHEET =  'TABLES1'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.

OUTPUT CLOSE ALL.
****************************************************************************************
****************************************************************************************.
*TRANSPOSE VARIABLES PERSONS INTERVIEWED 

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\ComTZ_3.sav'.
SET DECIMAL=DOT.

VARSTOCASES /ID = Rec_ID
  /MAKE comPerson   FROM  B_ID$1 B_ID$2  B_ID$3  B_ID$4  B_ID$5  B_ID$6  B_ID$7
  /MAKE comName     FROM B2_A$1 B2_A$2 B2_A$3 B2_A$4 B2_A$5 B2_A$6 B2_A$7
  /MAKE comSex        FROM B2_B$1 B2_B$2 B2_B$3 B2_B$4 B2_B$5 B2_B$6 B2_B$7
  /MAKE comFunction FROM B2_C$1 B2_C$2 B2_C$3 B2_C$4 B2_C$5 B2_C$6 B2_C$7
  /MAKE comYears     FROM B2_D$1 B2_D$2 B2_D$3 B2_D$4 B2_D$5 B2_D$6 B2_D$7
  /INDEX = comMemberID(10)
  /KEEP = comRegion comUrbRur GeocodeEA comC1_gr1 comD3 
  /NULL = DROP.
EXECUTE.

VARIABLE LABELS 
    comPerson    "Person contributing to the community interview _ID" 
    /comName     "Person contributing to the community interview _Name"
    /comSex        "Person contributing to the community interview _Sex" 
    /comFunction "Person contributing to the community interview _Function"
    /comYears     "Person contributing to the community interview _Years in the community".

*TABULATION 
* macro-example.
DEFINE !macro_TABCOM1 (n1=!TOKENS(1))
CTABLES
 /VLABELS VARIABLES=  !n1 DISPLAY=LABEL
 /VLABELS VARIABLES=comUrbRur, comC1_gr1, comRegion DISPLAY=LABEL
 /TABLE  
 comUrbRur [C] +  comC1_gr1 [C] + comRegion [C]  
       BY  
 !n1 [C] [ROWPCT.COUNT F40.0]  + !n1[S] [COUNT] /SLABELS VISIBLE=YES  
/CATEGORIES VARIABLES=comC1_gr1 [1, 2, 3, 4, 5, OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comUrbRur  [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
/CATEGORIES VARIABLES=comRegion [OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=!n1 [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
/TITLES 
TITLE = "Table #. Persons interviewed <Selected variable> by location, community size, conection to grid and region. Percent (and number of obs)"
CAPTION = "*Source: IASES tabulation test in Tanzania 2021/22 - unweighted data". 
!ENDDEFINE.
!macro_TABCOM1 n1=comSex.
!macro_TABCOM1 n1=comFunction.
!macro_TABCOM1 n1=comYears.

*export tabullation results to worksheet.
*OUTPUT EXPORT
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ComTZ_TAB1.xls'
     OPERATION= MODIFYSHEET  
     SHEET =  'TABLES2'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
*****************************************************************************************
TRANSPOSE VARIABLES INFRASTRUCTURE
 
*OUTPUT CLOSE ALL.
*DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\ComTZ_3.sav'.
SET DECIMAL=DOT.

VARSTOCASES /ID = Rec_ID
  /MAKE comInfraID            FROM INFRASTRUCTURE$01 INFRASTRUCTURE$02  INFRASTRUCTURE$03 INFRASTRUCTURE$04 INFRASTRUCTURE$05 INFRASTRUCTURE$06 
                                         INFRASTRUCTURE$07 INFRASTRUCTURE$08 INFRASTRUCTURE$09 INFRASTRUCTURE$10 INFRASTRUCTURE$11
  /MAKE comInfraType        FROM F9_NO$01 F9_NO$02 F9_NO$03 F9_NO$04 F9_NO$05 F9_NO$06 F9_NO$07 F9_NO$08 F9_NO$09 F9_NO$10 F9_NO$11
  /MAKE comAny               FROM F9A$01 F9A$02 F9A$03 F9A$04 F9A$05 F9A$06 F9A$07 F9A$08 F9A$09 F9A$10 F9A$11
  /MAKE comDistance        FROM F9B$01 F9B$02 F9B$03 F9B$04 F9B$05 F9B$06 F9B$07 F9B$08 F9B$09 F9B$10 F9B$11
  /MAKE comAccess          FROM F9C$01 F9C$02 F9C$03 F9C$04 F9C$05 F9C$06 F9C$07 F9C$08 F9C$09 F9C$10 F9C$11
  /MAKE comFiveAgo          FROM F9D$01 F9D$02 F9D$03 F9D$04 F9D$05 F9D$06 F9D$07 F9D$08 F9D$09 F9D$10 F9D$11
  /INDEX = MemberID(10)
  /KEEP = ALL. 
EXECUTE.

VARIABLE LABELS
          comInfraID       "Type of infrastructure in the community-lineID"
         /comInfraType   "Type of infrastructure/service"
         /comAny          "This infrastructure/service present in the community"
         /comDistance    "Distance to nearest facility/service (km)"
         /comAccess      "Do at least one of these facilities/services have access to electricity"
         /comFiveAgo      "Was this facility/service present in the community 5 years ago".

*Group distance to nearest facility (km).
*Check.
*FREQUENCIES Distance.
COMPUTE comDistance_gr1 = $SYSMIS.
FORMATS comDistance_gr1(F3.0).
VARIABLE LEVEL comDistance_gr1 (NOMINAL).
RECODE comDistance
(LOWEST THRU 1=1)
(2 THRU 9 = 2)
(10 THRU 19 = 3)
(20 THRU 49 = 4)
(50 THRU HIGHEST = 5)
INTO comDistance_gr1.
VARIABLE LABELS comDistance_gr1 "Distance to nearest facility (km)".
VALUE LABELS comDistance_gr1 
1 "      <2"
2 "  2 -  9"
3 "10 - 19"
4 "20 - 49"
5 "      50+".
EXECUTE.

*TABULATION examples. 
CTABLES
 /VLABELS VARIABLES=  comInfraType DISPLAY=LABEL
 /VLABELS VARIABLES=comUrbRur, comC1_gr1, comRegion, comAny DISPLAY=LABEL
 /TABLE  
(comUrbRur [C] +  comC1_gr1 [C]  + comRegion [C]) > comAny [C]  
       BY  
comInfraType [C] [ROWPCT.COUNT F40.0]  + comInfraType [S] [COUNT]  /SLABELS VISIBLE=YES   
/CATEGORIES VARIABLES=comC1_gr1 [1, 2, 3, 4, 5, OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comUrbRur  [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
/CATEGORIES VARIABLES=comRegion [OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comInfraType [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
/TITLES 
TITLE = "Table 1. Current Infrastructure in the Community by location, community size and region. Percent (and number of obs)"
CAPTION = "*Source: IASES tabulation test in Tanzania 2021/22 - unweighted data". 

CTABLES
 /VLABELS VARIABLES=  comInfraType DISPLAY=LABEL
 /VLABELS VARIABLES=comUrbRur, comC1_gr1,  comRegion DISPLAY=LABEL
 /TABLE  
(comUrbRur [C] +  comC1_gr1 [C] +  comRegion [C]) > comFiveAgo [C]  
       BY  
comInfraType [C] [ROWPCT.COUNT F40.0]  + comInfraType [S] [COUNT]  /SLABELS VISIBLE=YES   
/CATEGORIES VARIABLES=comC1_gr1 [1, 2, 3, 4, 5, OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comUrbRur  [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
/CATEGORIES VARIABLES=comRegion [OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comInfraType [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
/TITLES 
TITLE = "Table 2. Infrastructure in the Community five years ago by location, community size and region. Percent (and number of obs)"
CAPTION = "*Source: IASES tabulation test in Tanzania 2021/22 - unweighted data". 

CTABLES
 /VLABELS VARIABLES=  comInfraType DISPLAY=LABEL
 /VLABELS VARIABLES=comUrbRur, comC1_gr1, comRegion DISPLAY=LABEL
 /TABLE  
(comUrbRur [C] +  comC1_gr1 [C]  + comRegion [C]) > comDistance_gr1 [C]  
       BY  
comInfraType [C] [ROWPCT.COUNT F40.0]  + comInfraType [S] [COUNT]  /SLABELS VISIBLE=YES   
/CATEGORIES VARIABLES=comC1_gr1 [1, 2, 3, 4, 5, OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comUrbRur  [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
/CATEGORIES VARIABLES=comRegion [OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comInfraType [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
/TITLES 
TITLE = "Table 3. Distance to current Infrastructure by location, community size and region. Percent (and number of obs)"
CAPTION = "*Source: IASES tabulation test in Tanzania 2021/22 - unweighted data". 

CTABLES
 /VLABELS VARIABLES=  comInfraType DISPLAY=LABEL
 /VLABELS VARIABLES=comUrbRur, comC1_gr1, comRegion DISPLAY=LABEL
 /TABLE  
(comUrbRur [C] +  comC1_gr1 [C]  + comRegion [C]) > comAccess [C]  
       BY  
comInfraType [C] [ROWPCT.COUNT F40.0]  + comInfraType [S] [COUNT]  /SLABELS VISIBLE=YES   
/CATEGORIES VARIABLES=comC1_gr1 [1, 2, 3, 4, 5, OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comUrbRur  [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
/CATEGORIES VARIABLES=comRegion [OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=comInfraType [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
/TITLES 
TITLE = "Table 4. Infrastructure access to electricity by location, community size,  and region. Percent (and number of obs)"
CAPTION = "*Source: IASES tabulation test in Tanzania 2021/22 - unweighted data". 

*export tabullation results to worksheet.
*OUTPUT EXPORT
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ComTZ_TAB1.xls'
     OPERATION= MODIFYSHEET  
     SHEET =  'TABLES3'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
*****************************************************************************************
TRANSPOSE VARIABLES BUSINESS TYPES IN COMMUNITY 

*OUTPUT CLOSE ALL.
*DATASET CLOSE ALL.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\ComTZ_3.sav'.

VARSTOCASES /ID = Rec_ID
  /MAKE comManufactID FROM GM$01 GM$02 GM$03 GM$04 GM$05 GM$06 GM$07 GM$08 GM$09 GM$10 GM$11 GM$12
                                             GM$13 GM$14 GM$15 GM$16 GM$17 GM$18 GM$19 GM$20 GM$21 GM$22 GM$23 GM$24
  /MAKE comManufactType FROM G1_NO$01 G1_NO$02 G1_NO$03 G1_NO$04 G1_NO$05 G1_NO$06 G1_NO$07 G1_NO$08 G1_NO$09 G1_NO$10 G1_NO$11 G1_NO$12
                                             G1_NO$13 G1_NO$14 G1_NO$15 G1_NO$16 G1_NO$17 G1_NO$18 G1_NO$19 G1_NO$20 G1_NO$21 G1_NO$22 G1_NO$23 G1_NO$24
  /MAKE comAnyInCom      FROM G1A$01 G1A$02 G1A$03 G1A$04 G1A$05 G1A$06 G1A$07 G1A$08 G1A$09 G1A$10 G1A$11 G1A$12
                                             G1A$13 G1A$14 G1A$15 G1A$16 G1A$17 G1A$18 G1A$19 G1A$20 G1A$21 G1A$22 G1A$23 G1A$24
  /MAKE comAnyFiveAgo FROM G1B$01 G1B$02 G1B$03 G1B$04 G1B$05 G1B$06 G1B$07 G1B$08 G1B$09 G1B$10 G1B$11 G1B$12
                                             G1B$13 G1B$14 G1B$15 G1B$16 G1B$17 G1B$18 G1B$19 G1B$20 G1B$21 G1B$22 G1B$23 G1B$24
  /INDEX = memberID(10)
  /KEEP = ALL. 
EXECUTE.

VARIABLE LABELS
    comManufactID          "Manufacturing ID"
   /comManufactType      "Type of manufacturing"
   /comAnyInCom            "Any of this manufacturing type in the community currently"
   /comAnyFiveAgo               "Any of this manufacturing type in the community 5 years ago".

******************************************************
*CROSSTABS AND TABULATION .

CROSSTABS
  /TABLES=comUrbRur BY comC1_gr1
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES= comAnyInCom BY comUrbRur
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES= comManufactType BY comAnyInCom 
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.


*export tabullation results to worksheet.
*OUTPUT EXPORT
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ComTZ_TAB1.xls'
     OPERATION= MODIFYSHEET  
     SHEET =  'TABLES4'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
*****************************************************************************************
*END OF SYNTAX
*****************************************************************************************.



