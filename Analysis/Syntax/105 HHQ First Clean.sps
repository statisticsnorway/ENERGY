* Encoding: UTF-8.
* Created 19.01.2022. 
* Update: Kristian 26.01 - 10.02.2022       
* Update::Per 19.01 - 14.02.2022.
* SSB/NBS project team final approval: ................ 

*Objective: 1) Re-construct household information from raw-data to the extent possible, clean for duplicates&test-records and construct an unique household identifier  
                 2) Secure consistency between household level and community level file
 
*Out-put: A household level file ready for merging with community file and further restructure/labelling, 
                 
*The SPSS raw-data file used here is exported from the CSPro/CSWeb internal project database as a SPSS ".sav" format file. 
*Use the "export syntax" created by CSPro at export. In SPSS, add correct "directory path" in the folder structure and "save file addess "to the "export syntax" before use. 
*Save the file to the  "...\Data in" folder as "....\tmp\HHQTZ_1.sav)".
*******************************************************************************************************************************************''********************************************
The working filestructure for this program is as follows:

*.....\Analysis
            \Cat
            \Data
            \Production
            \Documentation
            \Syntax
            \Tables
            \Tmp
*************'*****************************************************************************.
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
GET FILE='tmp\HHQTZ_1.sav'.

*Add recordnumber to the file opened to always be able to sort the records in the initial order found in the database.
COMPUTE REC_ID= $CASENUM.
FORMATS REC_ID(F6.0).
VARIABLE LABELS REC_ID "Record_ID".
EXECUTE.
*Check number of rec on initial in-file (and filling in of ID codes).
FREQUENCIES AA1.

*Delete records that are dated and stored to the project server before the field work started - that is records dated before the end of ToE TZ (16.12.2021)
*After REC_ID # 325, all dates are higher than 16/12.(end of NBS ToE in Arusha). 
SORT CASES BY REC_ID(A).
SELECT IF 
    REC_ID GT 324.
EXECUTE.
*Check.
FREQUENCIES AA1.

*Prepare for efficent listing (all on one line) listings in the output window..
SET WIDTH=255.
ALTER TYPE AA14(a20) ADDRESS_LOCATION (a25) AALOGIN(a10) AA18(a20) AA9(a10) AB1$01(a20)  AB1$02(a20).

*Check any missing ID codes .
TEMPORARY.
SELECT IF
    (MISSING (AA1) = 1 OR MISSING (AA2) = 1 OR MISSING (AA3) = 1 OR MISSING (AA4) = 1 OR MISSING (AA5) = 1 OR MISSING (AA6) = 1).
LIST REC_ID AA1 AA2 AA3 AA4 AA5 AA6 AA8 AA10 B1 C1 AA14 AA7B.


*Remove all without any AA1 to AA6 (Region to EA) filled in.
SELECT IF
    (MISSING (AA1) = 0 AND MISSING (AA2) = 0 AND MISSING (AA3) = 0 AND MISSING (AA4) = 0 AND MISSING (AA5) = 0 AND MISSING (AA6) = 0).
EXECUTE.
*check.
FREQUENCIES AA1.

*Work on HH number. .
*Compute AA8new (Household #) varable and keep initial AA8 unchanged.
COMPUTE AA8new = AA8.
FORMATS AA8new (F3.0).
EXECUTE.

*Impute possible missing AA8new serial number.
*check.
TEMPORARY.
SELECT IF
    MISSING (AA8new) = 1.
LIST REC_ID AA8new AA1 AA2 AA3 AA4 AA5 AA6 AA9 AA7B AA14 AA18 AALOGIN B1 C1.

*Create new.HH# if missing.
SET RNG=MC SEED=20220223.
DO IF(MISSING (AA8new) = 1) . 
     COMPUTE  AA8new = RND (RV.UNIFORM(900, 999)).
END IF.
EXECUTE.    
*Check.
*Re-run temp list above for check.

*When all ID codes are filled in - Create new alpha-nummeric ID variables for Region toEA.. .
*String for REGIONS.
STRING Region (A2).
COMPUTE Region = STRING(AA1,n2).
*String for DISTRICT..
STRING District (A2).
COMPUTE District = STRING(AA2,n2).
*String for WARD..
STRING Ward (A3).
COMPUTE Ward = STRING(AA3,n3).
*String for DUMMY..
STRING Dummy (A2).
RECODE AA4 
    (0 THRU 99 = "11") 
INTO Dummy.
*String for VILLAGE (Vil_Mta_N).
STRING Village (A2).
COMPUTE Village = STRING(AA5,n2).
*String for EA.
STRING EA (A3).
COMPUTE EA = STRING(AA6,n3).
*Concat the geocode for EA.
STRING  GeocodeEA (A14).
COMPUTE GeocodeEA=CONCAT(Region, District, Ward, Dummy, Village, EA).
VARIABLE LABELS GeocodeEA "EA_Geocode".
EXECUTE.
* Labelling new ID variables Region to EA..
VARIABLE LABELS Region "Region".
VALUE LABELS Region 
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
VARIABLE LABELS District "District".
VARIABLE LABELS Ward "Ward".
VARIABLE LABELS Dummy "Dummy".
VARIABLE LABELS Village "Village".
VARIABLE LABELS EA "EA_ID".
EXECUTE.
*Check.
FREQUENCIES Region. 

*****************************************************************************************************.
*DELETE NOT RELEVANT RECORDS
*****************************************************************************************************
*1) Delete extra EAs created for use only during the ToE  /ToT.
*List and delete training EAs with geocodes given in the project GIS.attribute file (5 in ARUSHA and 5 in MOROGORO).
*check TZ.
TEMPORARY.
SELECT IF (ANY(GeocodeEA, "02060111102005","02062131104006","02031221101005","02031721111001","02060211101003","05051621115001",
"05051421104001","05051921104001","05051621101002","05050921130004") = 1).
LIST GeocodeEA REC_ID AA8new AA9 AA7A AA10 AA14 AA18 AALOGIN B1 C1.
*Delete TZ.
SELECT IF (ANY(GeocodeEA, "02060111102005","02062131104006","02031221101005","02031721111001","02060211101003","05051621115001",
"05051421104001","05051921104001","05051621101002","05050921130004") = 0).
EXECUTE.
*Check.
FREQUENCIES Region.

*Check the datum-stamp if any wrong tablet setup on year-day-month .
SORT CASES BY AA9 (A).
FREQUENCIES AA9.
*Scroll the FREQ list top/bottom and manually take note on wrong-format-records and add them to the list for recoding below (from 09.02.2022)
*Valid datum format is YY-DD-MM.  
RECODE AA9 ("20-12-21" = "21-21-12").  
RECODE AA9 ("22-12-21" = "21-22-12").
RECODE AA9 ("23-12-21" = "21-23-12").
RECODE AA9 ("27-12-21" = "21-27-12").
RECODE AA9 ("28-12-21" = "21-28-12").
RECODE AA9 ("29-12-21" = "21-29-12").
RECODE AA9 ("30-12-21" = "21-30-12").
RECODE AA9 ("70-01-01" = "22-01-01").
RECODE AA9 ("70-03-01" = "22-03-01"). 
RECODE AA9 ("21-12-21" = "21-21-12").
EXECUTE.
*Check again and add to list above if still wrong dates..
*SORT CASES BY AA9 (A).
*FREQUENCIES AA9.


*3). Check and delete refusals and vaccancy.
*Check.
FREQUENCIES AA10.
TEMPORARY.
SELECT IF
    AA10 = 3 OR AA10 = 4.
LIST REC_ID GeocodeEA AA8new AA10 AA14 AA18 AA7A B1 C1.
*Delete records with refusals or vaccancy - keep the rest incl missings.. 
SELECT IF 
    (AA10 = 1 OR AA10 = 2 OR SYSMIS(AA10) = 1).
EXECUTE.
*Check.
FREQUENCIES AA10.

*4)Prepare for further checking based on  ammount of nummeric inforamtion filled in accross the HHQ. 
* Compute temporary check variables of nummeric filling in of the whole file person- and subject matter data.
COMPUTE SUM_A = SUM(AB3$01 TO A8$20).
COMPUTE SUM_B = SUM(b1 TO b15).
COMPUTE SUM_C = SUM(c1,c2,c3,c4,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,
    c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,c51,c52,
    c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,
    c94,c95,c96,c97,c98,c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,c112,
    c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,c125,c126,c127,c128,c129,c130,c131,c132,c133,c134). 
COMPUTE SUM_D = SUM(d1 TO d4).
COMPUTE SUM_E = SUM(e1 TO e3).
COMPUTE SUM_F = SUM(f1 TO f15).
COMPUTE SUM_G = SUM(g3 TO g4).
COMPUTE SUM_I  = SUM(i1,i2,i4,i6,i8,i10,i11,i12,i13,i14,i15,i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27,i28,i29,i30,i31,i32,i33,i34,i35,i36,i37,i38,i39,i40,
    i41,i42,i43,i44,i46,i47,i48,i49,i50,i51,i52,i53,i54,i55).
COMPUTE SUM_J = SUM(j1 TO j5).
COMPUTE SUM_K = SUM(k1,k2,k3,k4).
COMPUTE SUM_L = SUM(l1,l3,l4,l5,l6,l7,l8).
COMPUTE SUM_M = SUM(m1,m2,m3).
COMPUTE SUM_O = SUM(o1 TO o12).
COMPUTE SUM_Q = SUM(q11 TO q16).
COMPUTE SUM_S = SUM(s1 TO s7).
COMPUTE SUM_T = SUM(t1 TO t4).
COMPUTE SUM_U = SUM(u1,u4,u5,u6,u7,u8,u9,u10,u11).
COMPUTE SUM_GP = SUM(gp1,gp5,gp6,gp7,gp8,gp9,gp10,gp11,gp12,gp13,gp14,gp15,gp16,gp17,gp18,gp19,gp20,gp21,gp22,gp23,
    gp27,gp28,gp29,gp30,gp31,gp32,gp34,gp35,gp36,gp37,gp38,gp39,gp40,gp41,gp42,gp43).
COMPUTE SUM_AtoGP = SUM(SUM_A,SUM_B,SUM_C,SUM_D,SUM_E,SUM_F,SUM_G,SUM_I,SUM_J,SUM_K,SUM_L,
SUM_M,SUM_O,SUM_Q,SUM_S,SUM_T,SUM_U,SUM_GP).
COMPUTE SUM_CtoGP = SUM(SUM_C,SUM_D,SUM_E,SUM_F,SUM_G,SUM_I,SUM_J,SUM_K,SUM_L,
SUM_M,SUM_O,SUM_Q,SUM_S,SUM_T,SUM_U,SUM_GP).
FORMATS SUM_A TO SUM_CtoGP (F10.0).
EXECUTE.
*delete not further used help variables created above. 
DELETE VARIABLES SUM_C TO SUM_GP.

*'5) Check.and delete records without any nummeric information about persons, housing or in any of the subject matter.
*Check.
TEMPORARY.
SELECT IF  (SYSMIS(SUM_AtoGP) = 1). 
LIST REC_ID GeocodeEA AA8new AA9 AA14 AA18 AA7A SUM_AtoGP AALOGIN AB1$01 AB1$02.

*Delete.
SELECT IF
   ( SYSMIS(SUM_AtoGP) = 0 ).
EXECUTE.
*Check.
FREQUENCIES Region.

*6) Identify duplicates on GeocodeEA + EA number..
SORT CASES BY GeocodeEA (A) AA8new(A) SUM_CtoGP (A).
MATCH FILES
  /FILE=*
  /BY GeocodeEA AA8new
  /FIRST=PFirst
  /LAST=PLast.
EXECUTE.

IF (PFirst = 0 OR PLast = 0) Duplicate=1. 
FORMATS Duplicate (F2.0)
*Check how many duplicates on Household level and total number of records remaining?.
FREQUENCIES PFirst PLast Duplicate. 
********************************************************
*Reorganize the work-file with the new created ID variable and tmp help variables first on the file and store/save for better visuals when browsing the file.
SAVE OUTFILE='tmp\HHQTZ_2.sav'
/KEEP 
REC_ID
GeocodeEA
AA8
AA8new
PFirst
PLast
Duplicate
AA9
AA14
AA18
AA7B
SUM_A 
SUM_B
SUM_AtoGP
SUM_CtoGP 
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.
************************************************************.
************************************************************
*Open reorganized file.and continue cleaning of ID variables..DATASET CLOSE ALL.
CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\HHQTZ_2.sav'.
SET DECIMAL=DOT.
*Check the input file..
FREQUENCIES PFirst PLast Duplicate.    

*Prepare for efficent listing (all on one line) listings in the output window..
SET WIDTH=255.
ALTER TYPE AA14(a20) ADDRESS_LOCATION (a25) AALOGIN(a10) AA18(a20) AA9(a10) AB1$01(a20)  AB1$02(a20).

**************************************************************************************************..
*RECODE IF DIFFERENT HOUSEHOLDS IN THE SAME DUPLICATE PAIR AND BOTH ARE COMPLETE FILLED IN ON THE PERSON VARIABLES.

*Create /adjust some help variables.
STRING AA14tmp (A10).
COMPUTE AA14tmp = AA14.
IF (AA14tmp ="          ") AA14tmp = "000".
STRING AA18tmp (A10).
COMPUTE AA18tmp = AA18.
IF (AA18tmp ="          ") AA18tmp = "000".
COMPUTE AA7Btmp = AA7B. 
FORMATS AA7Btmp (F11.5).
IF (SYSMIS(AA7Btmp) = 1) AA7Btmp = 0.
IF (MISSING(SUM_A) = 1) SUM_A = 0.
IF (MISSING(SUM_B) = 1) SUM_B = 0.
IF (MISSING(SUM_CtoGP) = 1) SUM_CtoGP = 0. 
EXECUTE. 

*Check.starting file. 
*FREQUENCIES PFirst.
*TEMPORARY.    
*SELECT IF PFirst = 0 OR PLast = 0.
*  LIST REC_ID AA8new PFirst PLast AA9 AA14tmp AA18tmp AA7Btmp AB1$01 SUM_A SUM_B SUM_CtoGP AB1$01.

*Step 1)  Renumber HH# for duplicates of the type 0-1 with both OK filled in (based on SUM_A (min sum50) and SUM_CtoGP(min sum10000) and keep the rest for further check...
*Compare AA14tmp AA18tmp AA7Btmp. 
SORT CASES BY GeocodeEA (A) AA8new (A) PFirst (D) PLast (A). 

SET RNG=MC SEED=20220222.
DO IF
     AA8new = LAG(AA8new, 1) AND
     PFirst = 0 AND PLast = 1 AND  
     (  (AA14tmp NE "000" AND LAG(AA14tmp, 1) NE "000" AND AA14tmp NE LAG(AA14tmp, 1) ) OR  
        (AA18tmp NE "000" AND LAG(AA18tmp, 1) NE "000" AND AA18tmp NE LAG(AA18tmp, 1) ) OR
        (AA7Btmp  NE 0 AND LAG(AA7Btmp, 1) NE 0 AND AA7Btmp NE LAG(AA7Btmp, 1) )   ) AND
        SUM_A GT 50 AND SUM_CtoGP GT 10000 AND LAG(SUM_A, 1) GT 50 AND LAG(SUM_CtoGP, 1) GT 10000. 
     COMPUTE AA8new = RND (RV.UNIFORM(850, 999)).
     COMPUTE PFirst = 1.
     COMPUTE PLast = 1. 
     COMPUTE flag0 = 1.
END IF.
EXECUTE.
FREQUENCIES PFirst flag0.

*Step 2) Continue to renumber HH# of the type (0 - 0) with both OK filled in (based on same SUM_A and SUM_CtoGP min values and keep the rest for further check..  
*Compare AA14tmp AA18tmp AA7Btmp. 
SET RNG=MC SEED=20220221.
DO IF
    ( AA8new = LAG(AA8new, 1) OR AA8new = LAG(AA8new, 2) OR AA8new = LAG(AA8new, 3) ) AND
    PFirst = 0 AND PLast = 0 AND 
     (  (AA14tmp NE "000" AND LAG(AA14tmp, 1) NE "000" AND AA14tmp NE LAG(AA14tmp, 1) ) OR  
        (AA18tmp NE "000" AND LAG(AA18tmp, 1) NE "000" AND AA18tmp NE LAG(AA18tmp, 1) ) OR
        (AA7Btmp  NE 0 AND LAG(AA7Btmp, 1) NE 0 AND AA7Btmp NE LAG(AA7Btmp, 1) )  ) AND
        SUM_A GT 50 AND SUM_CtoGP GT 10000 AND LAG(SUM_A, 1) GT 50 AND LAG(SUM_CtoGP, 1) GT 10000. 
    COMPUTE AA8new = RND (RV.UNIFORM(850, 999)).
    COMPUTE flag0 = 2.
    COMPUTE PFirst = 1.
    COMPUTE PLast = 1.
END IF.
EXECUTE.
*Check/clean..
FREQUENCIES PFirst flag0.
DELETE VARIABLES flag0.

*************************************************************.
*Identify remaining or new created (due to renumbering above) duplicates on GeocodeEA + EA number - put largest SUM_CtoGP last.
SORT CASES BY GeocodeEA (A) AA8new (A) SUM_CtoGP (A). 
EXECUTE.
MATCH FILES
  /FILE=*
  /BY GeocodeEA AA8new
  /FIRST=PFirst10
  /LAST=PLast10.
EXECUTE.
*Check.
FREQUENCIES PFirst10. 

***********************
*Step 3). MANUAL CHECK OF REMAINING INITIAL DUPLICATES.
TEMPORARY.    
SELECT IF (PFirst10 = 0 OR PLast10 = 0). 
  LIST REC_ID GeocodeEA AA8new PFirst10 PLast10  AA7Btmp AA7A AA7B SUM_A SUM_B SUM_CtoGP AB1$01 AB1$02.

*Scroll the list in the out-put window manually - look/compare names, coordinates, SUM-A and SUM_CtoGP.  .
*For those within the same duplicate "family" that most likely are stand-alone households (OK values), 
Take note on the REC_ID (take from the top type 1-0 and 0-0) and fill into the list below to re-ecode them. .

SET RNG=MC SEED=20220220.
DO IF (REC_ID =   1416). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220219.
DO IF (REC_ID =   1743). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220218.
DO IF (REC_ID =   3738). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220217.
DO IF (REC_ID = 3748). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220216.
DO IF (REC_ID = 4951). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220215.
DO IF (REC_ID = 4317). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220214.
DO IF (REC_ID = 4307).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220213.
DO IF (REC_ID = 4323). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220212.
DO IF (REC_ID = 2251).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220211.
DO IF (REC_ID = 1854).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220210.
DO IF (REC_ID = 6005).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220209.
DO IF (REC_ID = 575).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220208.
DO IF (REC_ID = 4014).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220207.
DO IF (REC_ID = 4003).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220206.
DO IF (REC_ID = 775).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220205.
DO IF (REC_ID = 3013). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220204.
DO IF (REC_ID = 6276).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220203.
DO IF (REC_ID = 5651).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220202.
DO IF (REC_ID = 5638).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220201.
DO IF (REC_ID = 4272).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220200.
DO IF (REC_ID = 6094).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220199.
DO IF (REC_ID = 3538).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220198.
DO IF (REC_ID = 3528).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220197.
DO IF (REC_ID = 3975).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220196.
DO IF (REC_ID = 4333).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220195.
DO IF (REC_ID = 4495).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
EXECUTE.

*from the list in the output window - correct a coordinate pair as agreed with NBS at WS 20-24 june 2020.
TEMPORARY.
SELECT IF REC_ID = 334 OR REC_ID = 333.
LIST REC_ID AA7A AA7B.

IF (REC_ID = 334) AA7A = -5.16869.
IF (REC_ID = 334) AA7B = 38.72200.
EXECUTE.


*From the list in the output window take note on records to be deleted and fill inn below- 
*Delete non-complete duplicate records that have meaningless/too little info filled in Sum_A SUM_CtoGP
*and that cannot be used to complete (that is transfer info on coordinates or head from section A.
*Keep the more complete record below in the same duplicate "family".       .
COMPUTE TMP1=0.
IF (REC_ID = 3081) TMP1=1.
IF (REC_ID = 1674) TMP1=1.
IF (REC_ID = 2116) TMP1=1.
IF (REC_ID = 2132) TMP1=1.
IF (REC_ID = 2133) TMP1=1.
IF (REC_ID = 2136) TMP1=1.
IF (REC_ID = 2582) TMP1=1.
IF (REC_ID = 887) TMP1=1.
IF (REC_ID = 333) TMP1=1.
IF (REC_ID = 1169) TMP1=1.
IF (REC_ID = 3746) TMP1=1.
IF (REC_ID = 3925) TMP1=1.
IF (REC_ID = 4953) TMP1=1.
IF (REC_ID = 4321) TMP1=1.
IF (REC_ID = 4312) TMP1=1.
IF (REC_ID = 4325) TMP1=1.
IF (REC_ID = 1025) TMP1=1.
IF (REC_ID = 1091) TMP1=1.
IF (REC_ID = 1035) TMP1=1.
IF (REC_ID = 1034) TMP1=1.
IF (REC_ID = 1116) TMP1=1.
IF (REC_ID = 4649) TMP1=1.
IF (REC_ID = 4654) TMP1=1.
IF (REC_ID = 2780) TMP1=1.
IF (REC_ID = 1854) TMP1=1.
IF (REC_ID = 1852) TMP1=1.
IF (REC_ID = 1864) TMP1=1.
IF (REC_ID = 1838) TMP1=1.
IF (REC_ID = 1312) TMP1=1.
IF (REC_ID = 1285) TMP1=1.
IF (REC_ID = 2930) TMP1=1.
IF (REC_ID = 567) TMP1=1.
IF (REC_ID = 4017) TMP1=1.
IF (REC_ID = 4013) TMP1=1.
IF (REC_ID = 3840) TMP1=1.
IF (REC_ID = 1559) TMP1=1.
IF (REC_ID = 1565) TMP1=1.
IF (REC_ID = 1554) TMP1=1.
IF (REC_ID = 2626) TMP1=1.
IF (REC_ID = 6431) TMP1=1.
IF (REC_ID = 2720) TMP1=1.
IF (REC_ID = 749) TMP1=1.
IF (REC_ID = 777) TMP1=1.
IF (REC_ID = 781) TMP1=1.
IF (REC_ID = 773) TMP1=1.
IF (REC_ID = 792) TMP1=1.
IF (REC_ID = 788) TMP1=1.
IF (REC_ID = 754) TMP1=1.
IF (REC_ID = 752) TMP1=1.
IF (REC_ID = 786) TMP1=1.
IF (REC_ID = 753) TMP1=1.
IF (REC_ID = 789) TMP1=1.
IF (REC_ID = 3010) TMP1=1.
IF (REC_ID = 1615) TMP1=1.
IF (REC_ID = 1735) TMP1=1.
IF (REC_ID = 2638) TMP1=1.
IF (REC_ID = 3793) TMP1=1.
IF (REC_ID = 4281) TMP1=1.
IF (REC_ID = 3799) TMP1=1.
IF (REC_ID = 4274) TMP1=1.
IF (REC_ID = 6098) TMP1=1.
IF (REC_ID = 6031) TMP1=1.
IF (REC_ID = 3537) TMP1=1.
IF (REC_ID = 4339) TMP1=1.
IF (REC_ID = 4341) TMP1=1.
IF (REC_ID = 2485) TMP1=1.
IF (REC_ID = 3629) TMP1=1.
IF (REC_ID = 6960) TMP1=1.
EXECUTE.
*check.
FREQUENCIES TMP1.

*delete records.
SELECT IF TMP1 = 0.
EXECUTE.    
*clean.
DELETE VARIABLES TMP1.


*Step 4) Identify possible remaining or new created duplicates (due to renumbering above) on GeocodeEA + EA number - 
*Put largest SUM_CEtoGP last during sorting for the new duplicate test.
SORT CASES BY GeocodeEA (A) AA8new (A) SUM_CtoGP (A). 
EXECUTE.
MATCH FILES
  /FILE=*
  /BY GeocodeEA AA8new
  /FIRST=PFirst20
  /LAST=PLast20.
EXECUTE.
*Check.
FREQUENCIES PFirst20. 

*Step 5) Renumber possible new created duplicates due to use of random function i previous steps (for those with AA8new GT 849)..
*check.
TEMPORARY.    
SELECT IF (PFirst20 = 0 OR PLast20 = 0) AND AA8new GT 849.
    LIST REC_ID AA8new PFirst20 PLast20 AA9 AA14tmp AA18tmp AA7Btmp AB1$01 SUM_A SUM_B SUM_CtoGP.

*Recode remaining listed above in the 850 to 999 series..
SET RNG=MC SEED=20220100.
DO IF (REC_ID = 4000). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
EXECUTE.
*Chack and if ANY in the list above, open the step below and renumber.

*Step 6) Identify/list remaining "true" duplicates for the initial records (AA8new LT 850)..
*check.
TEMPORARY.    
SELECT IF (PFirst20 = 0 OR PLast20 = 0) AND AA8new LT 850.
    LIST REC_ID AA8new PFirst20 PLast20 AA14tmp AA18tmp SUM_A SUM_B SUM_CtoGP AB1$01 AB1$02.

*hardcode remaining tru duplicates delete.
COMPUTE tmptmp=0.
IF (REC_ID = 2123)  tmptmp = 1.
EXECUTE.

*delete records.
SELECT IF tmptmp = 0.
EXECUTE.    
*clean.
DELETE VARIABLES tmptmp.


****************************************************************.
*START HER TO REPAIR / TRANSFER INFO FOR HEAD OF HOUSEHOLD BETWEEN RECORDS WITHIN THE REMAINING TRUE DUPLICATES..
*this step is not necessary from 17.06.2022r


**************************************************
*ckeck duplicates now left on the file. 
SORT CASES BY GeocodeEA (A) AA8new (A) SUM_CtoGP(A). 
EXECUTE.
MATCH FILES
  /FILE=*
  /BY GeocodeEA AA8new
  /FIRST=PFirst30
  /LAST=PLast30.
EXECUTE.
*Check.
FREQUENCIES PFirst30 PLast30.
TEMPORARY.    
SELECT IF (PFirst30 = 0 OR PLast30 = 0).
  LIST REC_ID AA8new PFirst30 PLast30  AA7Btmp SUM_A SUM_CtoGP AB1$01 AB1$02.

***********************************************''.
*IF still duplicates, repeat the previous procedure(s) based på new duplicate match PFirst4 / PLast40. .
*Within the same duplicate pair, Identtify and delete records with the least value in SUM_AtoGP..

*< IN HERE >

******************************************************************************      
IMPUTATION OF HEAD/HEAD SEX/HEAD AGE.
*imputation for missing head 
*Check start.
FREQUENCIES AB3$01 AB3$02 AB3$03.

*Step 1) Impute head if missings for head of household relationship.and head 5 yeaars ago is given.
DO IF 
    MISSING (AB3$01) = 1 AND (AB3B$01 = 1 OR  AB3B$01 = 2).
    COMPUTE AB3$01 = 1.
END IF.
EXECUTE.
*Check end..
FREQUENCIES AB3$01.

*Step 2) Impute head for records with still missing.
DO IF MISSING (AB3$01) = 1.
    COMPUTE AB3$01 =1.
END IF.
EXECUTE.
*Check end.
FREQUENCIES AB3$01.

*Step 3) Impute sex  to head if missing - when sex of spouse is given. .
*Check start.
FREQUENCIES AB4$01.

*Using person # 2 in the household info.
DO IF  AB3$01 = 1 AND MISSING(AB4$01)=1 AND AB4$02 = 1  AND AB3$02 = 2.
    COMPUTE AB4$01 = 2.
END IF.
EXECUTE.
DO IF  AB3$01 = 1 AND MISSING(AB4$01)=1 AND AB4$02 = 2 AND  AB3$02 = 2.
    COMPUTE AB4$01 = 1.
END IF.
EXECUTE.
*Chek end.
FREQUENCIES AB4$01.

*If still missing - using person # 3 in the household.
DO IF  AB3$01 = 1 AND MISSING(AB4$01)=1 AND AB4$03 = 1  AND AB3$03 = 2.
    COMPUTE AB4$01 = 2.
END IF.
EXECUTE.
DO IF  AB3$01 = 1 AND MISSING(AB4$01)=1 AND AB4$03 = 2 AND  AB3$03 = 2.
    COMPUTE AB4$01 = 1.
END IF.
EXECUTE.
*Chek end.
FREQUENCIES AB4$01.

*If still missing - using person # 4 in the household.
DO IF  AB3$01 = 1 AND MISSING(AB4$01)=1 AND AB4$04 = 1  AND AB3$04 = 2.
    COMPUTE AB4$01 = 2.
END IF.
EXECUTE.
DO IF  AB3$01 = 1 AND MISSING(AB4$01)=1 AND AB4$04 = 2 AND  AB3$04 = 2.
    COMPUTE AB4$01 = 1.
END IF.
EXECUTE.
*Check end.
FREQUENCIES AB4$01.

*Step 4a) Impute age to head as 2 years older that spouse - a proxy..
*Check start..
FREQUENCIES AB5$01.

*Looking for spouse Using person #2 in the household.
DO IF  AB3$01 = 1 AND (MISSING(AB5$01)=1 OR AB5$01 < 12) AND AB3$02 = 2  AND AB5$02 GE 12.
    COMPUTE AB5$01 = ((AB5$02) + 2).
END IF.
EXECUTE.
*Check end.
FREQUENCIES AB5$01.

*If still missing - looking for spouse using person #3 in the household.
DO IF  AB3$01 = 1 AND (MISSING(AB5$01)=1 OR AB5$01 < 12) AND AB3$03 = 2  AND AB5$03 GE 12.
    COMPUTE AB5$01 = ((AB5$03) + 2).
END IF.
EXECUTE.
*Check end.
FREQUENCIES AB5$01.

*If still missing looking for spouse using person #4 in the household.
DO IF  AB3$01 = 1 AND (MISSING(AB5$01)=1  OR AB5$01 < 12) AND AB3$04 = 2  AND AB5$04 GE 12.
    COMPUTE AB5$01 = ((AB5$04) + 2).
END IF.
EXECUTE.
*Check end..
FREQUENCIES AB5$01.

*Step 4b) Impute age to head as 20 years older than child - a proxy..
*Check start..
FREQUENCIES AB5$01.

*Looking for child Using person #2 in the household.
DO IF  AB3$01 = 1 AND ( MISSING(AB5$01)=1 OR AB5$01 < 12 ) AND AB3$02 = 3  AND MISSING(AB5$02) = 0.
    COMPUTE AB5$01 = ((AB5$02) + 20).
END IF.
EXECUTE.
*Check end.
FREQUENCIES AB5$01.

*If still missing - looking for child using person #3 in the household.
DO IF  AB3$01 = 1 AND ( MISSING(AB5$01)=1 OR AB5$01 < 12) AND AB3$03 = 3  AND MISSING(AB5$03) = 0.
    COMPUTE AB5$01 = ((AB5$03) + 20).
END IF.
EXECUTE.
*Check end.
FREQUENCIES AB5$01.

*If still missing using person #4 in the household.
DO IF  AB3$01 = 1 AND ( MISSING(AB5$01)=1  OR AB5$01 < 12) AND AB3$04 = 3  AND MISSING(AB5$04) = 0.
    COMPUTE AB5$01 = ((AB5$04) + 20).
END IF.
EXECUTE.
*Check end..
FREQUENCIES AB5$01.

*Set age to sysmis for possible head age found less than 12 years old in the fequency above.
DO IF AB5$01 LT 12. 
    COMPUTE AB5$01 = $SYSMIS.
END IF.
EXECUTE.
*Check end..
FREQUENCIES AB5$01.
******************************************************************************      
* When no more duplicates on GeocodeEA + AA8new, create alphanummerisk HH number and concatenate GeocodeHH with 17 positions.

*String for HH serial number.
STRING HH (A3).
COMPUTE HH = STRING(AA8new,n3).
VARIABLE LABELS HH "Household number".

*Concat the geocode for HH.
STRING  GeocodeHH (A17).
COMPUTE GeocodeHH=CONCAT(Region, District, Ward, Dummy, Village, EA, HH).
VARIABLE LABELS GeocodeHH "HH_Geocode".
EXECUTE.

*Check.
*Check final results for GeocodeHH.
SORT CASES BY GeocodeHH.
MATCH FILES
  /FILE=*
  /BY GeocodeHH
  /FIRST=PFirst50
  /LAST=PLast50.
EXECUTE.
*Check.
FREQUENCIES PFirst50 PLast50.

*for userfriendliness.
RENAME VARIABLES (AA7 = UrbRur).
RENAME VARIABLES (AA9 = Date).
RENAME VARIABLES (AA7A = Ycoord).
RENAME VARIABLES (AA7B = Xcoord).

*save temporary file and re-open. 
SAVE OUTFILE='tmp\HHQTZ_2b.sav'
/KEEP ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.

***********************************************************.
*New step for v7 of the syntax - checking consistency of Geocode EA .
*Based on manual check between GIS EAcodes, SamplingEA codes and data file EAcodes..

*Open work file.
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\HHQTZ_2b.sav'.
SET DECIMAL=DOT.

FREQUENCIES region GeocodeEA.

* Custom Tables.
CTABLES
  /VLABELS VARIABLES=GeocodeEA UrbRur DISPLAY=LABEL
  /TABLE GeocodeEA BY UrbRur [COUNT F40.0]
  /CATEGORIES VARIABLES=GeocodeEA ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES=UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CRITERIA CILEVEL=95.

*Check this table manually against Bjørn smpling sheet xls and GIS catalogue.

*List, rename (or delete) records with wrong GeocodeEA (not matching GIS and Sampling xls from Bjørn when manual check). 
TEMPORARY.
SELECT IF  ( (GeocodeEA="01020531102013") OR (GeocodeEA="01020531102003") OR (GeocodeEA="07012521105011") OR (GeocodeEA="09050321101312")
    OR (GeocodeEA="10032411103084") OR (GeocodeEA="10032411103003") OR (GeocodeEA="10030211101006") OR (GeocodeEA="14040231101001") 
    OR (GeocodeEA="14040231101003") OR (GeocodeEA="15361621112001") OR (GeocodeEA="16031131104001") OR (GeocodeEA="16011031103003")
    OR (GeocodeEA="17041631104004") OR (GeocodeEA="17041631104002") OR (GeocodeEA="17021511101011") OR (GeocodeEA="17041631104001")
    OR (GeocodeEA="17041631104003") OR (GeocodeEA="20061611105011") OR (GeocodeEA="20042011102001") OR (GeocodeEA="20042531101003")
    OR (GeocodeEA="22031611104311") OR (GeocodeEA="24060911106010") OR (GeocodeEA="25012831102003") OR (GeocodeEA="26061531101075") 
    OR (GeocodeEA="26061531101003") ).
LIST Rec_ID GeocodeEA.

*Move wrong EA codes into correct EA.
IF (GeocodeEA="01020531102013") GeocodeEA="01020531102313".
IF (GeocodeEA="01020531102003") GeocodeEA="01020531102313".
IF (GeocodeEA="09050321101312") GeocodeEA="09050321101001".
IF (GeocodeEA="10032411103084") GeocodeEA="10032411103002".
IF (GeocodeEA="10032411103003") GeocodeEA="10032411103002".
IF (GeocodeEA="10030211101006") GeocodeEA="10030211101008".
IF (GeocodeEA="15361621112001") GeocodeEA="15031621112001".
IF (GeocodeEA="16031131104001") GeocodeEA="16031131103003".
IF (GeocodeEA="16011031103003") GeocodeEA="16011031103309".
IF (GeocodeEA="17021511101011") GeocodeEA="17021511101001".
IF (GeocodeEA="17041631104004") GeocodeEA="17041631104313".
IF (GeocodeEA="17041631104002") GeocodeEA="17041631104313".
IF (GeocodeEA="17041631104001") GeocodeEA="17041631104313".
IF (GeocodeEA="17041631104003") GeocodeEA="17041631104313".
IF (GeocodeEA="20061611105011") GeocodeEA="20061611105003".
IF (GeocodeEA="20042011102001") GeocodeEA="20041011102002".
IF (GeocodeEA="20042531101003") GeocodeEA="20042531101303".
IF (GeocodeEA="22031611104311") GeocodeEA="22031611104003".
IF (GeocodeEA="25012831102003") GeocodeEA="25012831102321".
IF (GeocodeEA="26061531101075") GeocodeEA="26061531101375".
IF (GeocodeEA="26061531101003") GeocodeEA="26061531101375".
EXECUTE.    

*Delete EAs with few hh not possible to renumber to valid EA code.
*We also delete the EA 07012521105011 (26 hh) because it is not in the sample or in the GIS file and thus cannot be given weights.
COMPUTE tmpGeo =0.
IF(GeocodeEA="14040231101001") tmpGeo=1.
IF(GeocodeEA="14040231101003") tmpGeo=1.
IF(GeocodeEA="24060911106010") tmpGeo=1.
IF(GeocodeEA="07012521105011") tmpGeo=1.
EXECUTE.

*Delete non-usable records. 
SELECT IF tmpGeo=0.
EXECUTE.

*Check.    
FREQUENCIES tmpGeo.

*Clean.
DELETE VARIABLES tmpGeo.


*save the workfile. 
SORT CASES BY GeocodeEA (A).
SAVE OUTFILE='tmp\HHQTZ_3.sav'
/KEEP 
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.

*****************************************************************.
*Open workfile.
CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\HHQTZ_3.sav'.
SET DECIMAL=DOT.

FREQUENCIES REGION.
*Step 1) Delete any with zero value in SUM_A and SUM_B. Cannot be used as stand-allone household in analysis.   .
COMPUTE TMP2=0.
EXECUTE.
IF (SUM_A = 0 AND SUM_B= 0) TMP2=1.
EXECUTE.
*Check.
FREQUENCIES TMP2.
SORT CASES BY GeocodeHH.
TEMPORARY.    
SELECT IF TMP2=1.
    LIST REC_ID AA8new Date AA14tmp AA18tmp AA7Btmp AB1$01 SUM_A SUM_B SUM_CtoGP.

*delete.
SELECT IF
    TMP2 = 0.
EXECUTE.

*Final check/delete.
FREQUENCIES Region.

*Clean.
DELETE VARIABLES TMP2.

*Step 2)  Identify records with all missing in either B or missing all info from C-to-end-of-file.- check and delete.
COMPUTE tmp3=0.
IF (SUM_B = 0 OR SUM_CtoGP=0) tmp3 =1.
EXECUTE.
TEMPORARY.
SELECT IF SUM_B = 0 OR SUM_CtoGP = 0.
LIST REC_ID GeocodeEA HH Ycoord AA10 AA14 SUM_A SUM_B SUM_CtoGP tmp3.

*Delete.
SELECT IF tmp3= 0.     
FREQUENCIES tmp3.
*clean.
DELETE VARIABLES tmp3.
FREQUENCIES region.

*Step 3).Impute head of household sex (step 3a) and age (step 3b) where still missing (imputation recommended because this info may be much used during tabulation).
TEMPORARY.
SELECT IF (MISSING(AB4$01) = 1 OR MISSING(AB5$01) = 1).
LIST REC_ID GeocodeEA HH Ycoord AA10 AA14 AB1$01 AB4$01 AB5$01 SUM_A SUM_B SUM_CtoGP.

*3a)Sex imputation.
*Complete name for head in the strata.. 
IF (  MISSING(AB4$01) = 1 OR MISSING(AB5$01) = 1 ) AB1$01 = AA14.
EXECUTE.

*List out recID and name of head to a xls sheet for manual decissions on names x sex by NBS.
OUTPUT CLOSE ALL.
TEMPORARY.
SELECT IF (MISSING(AB4$01) = 1 OR MISSING(AB5$01) = 1).
LIST REC_ID GeocodeHH AB1$01.

*Export the list to XLS worksheet for possible manual coding of sex by NBS..
*OUTPUT EXPORT 
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\HHQTZ_TABname.xls'
     OPERATION= CREATESHEET  
     SHEET =  'Names x sex control'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.

*Manual hard-coding of sex based "good enough" solution - possible later update based on name/sex list from NBS.
*After TZ check at workshop in Oslo 20-24 June, NBS har verified sex by name on all recocords in the list below:
*The renaining (not corrected by NBS)  are set to 1 or 2 male/female by edityors best guess and googeling of meaning of names.  
  

IF(REC_ID = 1440) AB4$01 = 1.
IF(REC_ID =   840) AB4$01 = 1.
IF(REC_ID =   839) AB4$01 = 1.
IF(REC_ID = 2387) AB4$01 = 1.
IF(REC_ID = 4172) AB4$01 = 1.
IF(REC_ID = 4178) AB4$01 = 1.
IF(REC_ID = 4116) AB4$01 = 1.
IF(REC_ID = 5969) AB4$01 = 2.
IF(REC_ID = 5071) AB4$01 = 1.
IF(REC_ID = 1499) AB4$01 = 1.
IF(REC_ID = 1744) AB4$01 = 2.
IF(REC_ID =   424) AB4$01 = 1.
IF(REC_ID =   705) AB4$01 = 2.
IF(REC_ID = 1166) AB4$01 = 1.
IF(REC_ID = 3421) AB4$01 = 1. 
IF(REC_ID = 3408) AB4$01 = 1.
IF(REC_ID = 2857) AB4$01 = 1.
IF(REC_ID = 6760) AB4$01 = 1.
IF(REC_ID = 6177) AB4$01 = 1.
IF(REC_ID = 5035) AB4$01 = 1.
IF(REC_ID = 3485) AB4$01 = 1.
IF(REC_ID = 3942) AB4$01 = 1.
IF(REC_ID = 2325) AB4$01 = 2.
IF(REC_ID = 3128) AB4$01 = 1.
IF(REC_ID = 6511) AB4$01 = 2.
IF(REC_ID = 6513) AB4$01 = 1.
IF(REC_ID =   955) AB4$01 = 2.
IF(REC_ID = 6356) AB4$01 = 2.
IF(REC_ID = 6354) AB4$01 = 1.
IF(REC_ID = 1656) AB4$01 = 2.
IF(REC_ID = 3052) AB4$01 = 2.
IF(REC_ID = 4226) AB4$01 = 2.
IF(REC_ID = 5533) AB4$01 = 1.
IF(REC_ID =   745) AB4$01 = 1. 
IF(REC_ID = 3830) AB4$01 = 1.
IF(REC_ID =   855) AB4$01 = 1.
IF(REC_ID = 4513) AB4$01 = 2.  
IF(REC_ID = 4889) AB4$01 = 1.
IF(REC_ID = 3222) AB4$01 = 1.
IF(REC_ID = 3236) AB4$01 = 1.  
IF(REC_ID = 1703) AB4$01 = 2.
IF(REC_ID =   474) AB4$01 = 1.
IF(REC_ID = 4800) AB4$01 = 1.
IF(REC_ID = 6878) AB4$01 = 2.
IF(REC_ID = 2721) AB4$01 = 1.
IF(REC_ID =   797) AB4$01 = 1.
IF(REC_ID = 7039) AB4$01 = 1.
IF(REC_ID = 7060) AB4$01 = 1.  
IF(REC_ID = 7130) AB4$01 = 1.
IF(REC_ID = 5254) AB4$01 = 1.
IF(REC_ID = 6443) AB4$01 = 2.
IF(REC_ID = 4691) AB4$01 = 1.  
IF(REC_ID = 6156) AB4$01 = 1.  
IF(REC_ID = 6154) AB4$01 = 1.  
IF(REC_ID = 7155) AB4$01 = 2. 
IF(REC_ID = 7142) AB4$01 = 2.
IF(REC_ID = 7161) AB4$01 = 1.
IF(REC_ID = 7160) AB4$01 = 1.  
IF(REC_ID = 7154) AB4$01 = 1.  
IF(REC_ID = 7165) AB4$01 = 1. 
IF(REC_ID = 3821) AB4$01 = 1.
IF(REC_ID = 6055) AB4$01 = 1.
IF(REC_ID = 5984) AB4$01 = 2.
IF(REC_ID = 6075) AB4$01 = 1.  
IF(REC_ID = 4366) AB4$01 = 2. 
IF(REC_ID = 4865) AB4$01 = 2.
IF(REC_ID = 4668) AB4$01 = 1.
IF(REC_ID = 6459) AB4$01 = 1.
IF(REC_ID = 6460) AB4$01 = 1.
IF(REC_ID = 6547) AB4$01 = 1.
IF(REC_ID = 6555) AB4$01 = 1. 
IF(REC_ID = 5504) AB4$01 = 2.  
IF(REC_ID = 6794) AB4$01 = 1. 
IF(REC_ID = 4420) AB4$01 = 1.
IF(REC_ID =   606) AB4$01 = 2.
IF(REC_ID = 6863) AB4$01 = 1.  
EXECUTE.  
 
* proxy set the remaining missing head sex where NBS haas no suggestion..
IF(REC_ID = 1445) AB4$01 = 1.
IF(REC_ID = 3423) AB4$01 = 1.
IF(REC_ID = 3493) AB4$01 = 1.
IF(REC_ID = 6343) AB4$01 = 1.
IF(REC_ID = 3695) AB4$01 = 1.
IF(REC_ID = 4747) AB4$01 = 2.  
IF(REC_ID = 6662) AB4$01 = 2.  
IF(REC_ID = 4299) AB4$01 = 2.
IF(REC_ID = 2732) AB4$01 = 2.
IF(REC_ID = 6441) AB4$01 = 1.
IF(REC_ID = 3712) AB4$01 = 2.
IF(REC_ID = 6158) AB4$01 = 2.  
IF(REC_ID = 7148) AB4$01 = 1. 
IF(REC_ID = 7018) AB4$01 = 1.
IF(REC_ID = 5981) AB4$01 = 2. 
IF(REC_ID = 5695) AB4$01 = 2. 
IF(REC_ID = 3365) AB4$01 = 1.  
IF(REC_ID = 3529) AB4$01 = 1.  
IF(REC_ID = 4439) AB4$01 = 2.
IF(REC_ID = 6588) AB4$01 = 2.
IF (REC_ID = 2387) AB4$01 = 1.
IF (REC_ID = 855) AB4$01 = 1.
IF (REC_ID = 5254) AB4$01 = 1.
EXECUTE.

*check.
FREQUENCIES AB4$01. 
TEMPORARY.
SELECT IF SYSMIS(AB4$01)=1.
LIST REC_ID.   


*******************************************************.
*3b) Impute still missing head age based on nearest neighbour add-in macro.
*check start.
FREQUENCIES AB5$01.

*compute temporary HH size help variable for stratification.
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

**********************************************.
*Hotdeck macro - nearest neighbour in strata imputation for missing head age.(higlight all between astreixes and run the HD).
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

HOTDECK y= AB5$01  / deck = UrbRur HHSize_gr1 AB4$01. 

*y       = variable missing to be imputed 
*deck = variables used to stratify into decks from where nearest neighbour value is imputed to the missing var y  
**********************************

*Impute check and delete/clean.
COMPUTE AB5$01 = AB5$01HD.
EXECUTE.
FREQUENCIES AB5$01.

DELETE VARIABLES AB5$01HD HHsize HHsize_gr1.

*****************************************************************************
*Clean up temp variables. 
DELETE VARIABLES AA14tmp AA18tmp AA7Btmp PFirst10 PLast10 PFirst20 PLast20 PFirst30 PLast30 PFirst50 PLast50.
*****************************************************************************************************
*****************************************************************************************************
*Save temporary file with unique identifiers  - ready for using next sytax for merge with community, labelling and restructuring. 

*THIS FILE IS ADDRESSED TO THE NEXT SYNTAX FOR FURTHER MERGE TO COMFILE, LABELLING AND RESTRUCTURE.

SORT CASES BY GeocodeEA (A) HH (A). 
SAVE OUTFILE='tmp\HHQTZ_4.sav'
/KEEP 
REC_ID
GeocodeEA
GeocodeHH
HH
Region
UrbRur
Xcoord
Ycoord
Date
ALL 
/COMPRESSED.

*final check/count.
FREQUENCIES Region.

*Close all.
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 
*********************************************************************.
*END OF SYNTAX.
********************************************************************* .





