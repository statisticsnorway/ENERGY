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
    REC_ID GT 325.
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
"26" 26 RukwaSongwe.
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
LIST REC_ID  AA8new AA9 AA14 AA18 AA7A SUM_AtoGP AALOGIN AB1$01 AB1$02.

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
*CD 'C:\Users\per\Documents\OPPDRAG 21_12\2021_22 SPSS Tanzania'.
GET FILE='tmp\HHQTZ_2.sav'.
*Check the input file..
FREQUENCIES PFirst PLast.    
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
  LIST REC_ID AA8new PFirst10 PLast10  AA7Btmp SUM_A SUM_B SUM_CtoGP AB1$01 AB1$02.

*Scroll the list in the out-put window manually - look/compare names, coordinates, SUM-A and SUM_CtoGP.  .
*For those within the same duplicate "family" that most likely are stand-alone households (OK values), Take note on the REC_ID (take from the top type 1-0 and 0-0) 
*and fill into the list below to re-ecode them. .
SET RNG=MC SEED=20220220.
DO IF (REC_ID =   1568). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220219.
DO IF (REC_ID =   1960). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220218.
DO IF (REC_ID =   3842). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220217.
DO IF (REC_ID = 4446). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220216.
DO IF (REC_ID = 4462). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220215.
DO IF (REC_ID = 487). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220214.
DO IF (REC_ID = 6185).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220213.
DO IF (REC_ID = 4129). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220212.
DO IF (REC_ID = 819).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220211.
DO IF (REC_ID = 6469).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220210.
DO IF (REC_ID = 5827).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220209.
DO IF (REC_ID = 5814).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220208.
DO IF (REC_ID = 3629).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220207.
DO IF (REC_ID = 4101).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220206.
DO IF (REC_ID = 4472).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220205.
DO IF (REC_ID = 4632). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
SET RNG=MC SEED=20220204.
DO IF (REC_ID = 4101).
     COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
EXECUTE.

*From the list in the output window take note on records to be deleted and fill inn below- 
*Delete non-complete duplicate records that have meaningless/too little info filled in Sum_A SUM_CtoGP
*and that cannot be used to complete (that is transfer info on coordinates or head from section A.
*Keep the more complete record below in the same duplicate "family".       .
COMPUTE TMP1=0.
IF (REC_ID = 2399) TMP1=1.
IF (REC_ID = 2654) TMP1=1.
IF (REC_ID = 3850) TMP1=1.
IF (REC_ID = 4050) TMP1=1.
IF (REC_ID = 5109) TMP1=1.
IF (REC_ID = 4460) TMP1=1.
IF (REC_ID = 4451) TMP1=1.
IF (REC_ID = 4464) TMP1=1.
IF (REC_ID = 1117) TMP1=1.
IF (REC_ID = 4794) TMP1=1.
IF (REC_ID = 2071) TMP1=1.
IF (REC_ID = 2081) TMP1=1.
IF (REC_ID = 1413) TMP1=1.
IF (REC_ID = 602) TMP1=1.
IF (REC_ID = 4143) TMP1=1.
IF (REC_ID = 4139) TMP1=1.
IF (REC_ID = 2700) TMP1=1.
IF (REC_ID = 813) TMP1=1.
IF (REC_ID = 836) TMP1=1.
IF (REC_ID = 3097) TMP1=1.
IF (REC_ID = 3903) TMP1=1.
IF (REC_ID = 4414) TMP1=1.
IF (REC_ID = 3909) TMP1=1.
IF (REC_ID = 4407) TMP1=1.
IF (REC_ID = 6278) TMP1=1.
IF (REC_ID = 3638) TMP1=1.
IF (REC_ID = 4478) TMP1=1.
IF (REC_ID = 4480) TMP1=1.
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
SET RNG=MC SEED=20220299.
DO IF (REC_ID = 4472). 
    COMPUTE AA8new = RND (RV.UNIFORM(849, 999)).
END IF.
EXECUTE.
*Chack and if ANY in the list above, open the step below and renumber.

*Step 6) Identify/list remaining "true" duplicates for the initial records (AA8new LT 850)..
*check.
TEMPORARY.    
SELECT IF (PFirst20 = 0 OR PLast20 = 0) AND AA8new LT 850.
    LIST REC_ID AA8new PFirst20 PLast20 AA14tmp AA18tmp SUM_A SUM_B SUM_CtoGP AB1$01 AB1$02.

****************************************************************.
*START HER TO REPAIR / TRANSFER INFO FOR HEAD OF HOUSEHOLD BETWEEN RECORDS WITHIN THE REMAINING TRUE DUPLICATES..
*coordinates.
DO IF
    PFirst20=0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 1) AND
        SYSMIS(AA7B) = 1 AND LAG(AA7B,1) GT 1.
        COMPUTE AA7A = LAG(AA7A,1).
        COMPUTE AA7B = LAG(AA7B,1).
        COMPUTE flag1 = 1.
  ELSE IF 
     PFirst20 = 0 AND PLast20 = 1 AND
     AA8new LT 850 AND
     AA8new = LAG(AA8new, 2) AND
     SYSMIS(AA7B) = 1 AND LAG(AA7B, 2) GT 1.
        COMPUTE AA7A = LAG(AA7A, 2).
        COMPUTE AA7B = LAG(AA7B, 2).
        COMPUTE flag1 = 2.
END IF.  
EXECUTE. 
FREQUENCIES flag1.
*reationship head.
DO IF
    PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 1) AND
    MISSING(AB3$01)=1 AND LAG(AB3$01,1)=1.
    COMPUTE AB3$01 = LAG(AB3$01,1).
    COMPUTE flag2 = 1.
  ELSE IF 
    PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 2) AND
    MISSING(AB3$01)=1 AND LAG(AB3$01, 2)=1.
    COMPUTE AB3$01 = LAG(AB3$01, 2).
    COMPUTE flag2 = 2.
END IF. 
EXECUTE. 
FREQUENCIES flag2.
*head 5 years ago.
DO IF 
    PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 1) AND
    MISSING(AB3B$01)=1 AND (LAG(AB3B$01,1)=1 OR LAG(AB3B$01,1) = 2).
    COMPUTE AB3B$01 = LAG(AB3B$01,1).
    COMPUTE flag3 = 1.
  ELSE IF
     PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 2) AND
    MISSING(AB3B$01)=1 AND (LAG(AB3B$01, 2)=1 OR LAG(AB3B$01, 2) = 2).
    COMPUTE AB3B$01 = LAG(AB3B$01, 2).
    COMPUTE flag3 = 2.
END IF.
EXECUTE.
FREQUENCIES flag3.
*head sex.
DO IF 
    PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 1) AND
    MISSING(AB4$01)=1 AND (LAG(AB4$01,1) = 1 OR LAG(AB4$01,1) =2).
    COMPUTE AB4$01 = LAG(AB4$01,1).
    COMPUTE flag4 = 1.
  ELSE IF
     PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 2) AND
    MISSING(AB4$01)=1 AND (LAG(AB4$01,2) = 1 OR LAG(AB4$01, 2) =2).
    COMPUTE AB4$01 = LAG(AB4$01, 2).
    COMPUTE flag4 = 2.
END IF.  
EXECUTE. 
FREQUENCIES flag4.
*head age.
DO IF 
    PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 1) AND
    MISSING(AB5$01)=1 AND (LAG(AB5$01,1) GE 12).
    COMPUTE AB5$01 = LAG(AB5$01,1).
    COMPUTE flag5 = 1.
  ELSE IF
     PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 2) AND
    MISSING(AB5$01)=1 AND (LAG(AB5$01,2) GE 12).
    COMPUTE AB5$01 = LAG(AB5$01,2).
    COMPUTE flag5 = 2.
END IF.  
EXECUTE. 
FREQUENCIES flag5.
*head marital status.
DO IF 
    PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 1) AND
    MISSING(AB6$01)=1 AND LAG(AB6$01, 1) GE 1 AND LAG(AB6$01, 1) LE 8.
    COMPUTE AB6$01 = LAG(AB6$01,1).
    COMPUTE flag6 = 1.
  ELSE IF
     PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 2) AND
    MISSING(AB6$01)=1 AND LAG(AB6$01, 2) GE 1 AND LAG(AB6$01, 2) LE 8.
    COMPUTE AB6$01 = LAG(AB6$01,2).
    COMPUTE flag6 = 2.
END IF.  
EXECUTE. 
FREQUENCIES flag6.
*SUM B check.
DO IF 
    PFirst20 = 0 AND PLast20 = 1 AND
    AA8new LT 850 AND
    AA8new = LAG(AA8new, 1) AND
    MISSING(SUM_B)=1 AND LAG(SUM_B, 1) GE 1.
      COMPUTE B1 = LAG(B1,1).
      COMPUTE B2 = LAG(B2,1).
      COMPUTE B3 = LAG(B3,1).
      COMPUTE B4 = LAG(B4,1).
      COMPUTE B5 = LAG(B5,1).
      COMPUTE B6 = LAG(B6,1).
      COMPUTE B7 = LAG(B7,1).
      COMPUTE B8 = LAG(B8,1).
      COMPUTE B9 = LAG(B9,1).
      COMPUTE B10 = LAG(B10,1).
      COMPUTE B11 = LAG(B11,1).
      COMPUTE B12 = LAG(B12,1).
      COMPUTE B13 = LAG(B13,1).
      COMPUTE B14 = LAG(B14,1).
      COMPUTE B15 = LAG(B15,1).
      COMPUTE B16 = LAG(B16,1).
      COMPUTE B17 = LAG(B17,1).
      COMPUTE B18 = LAG(B18,1).
      COMPUTE B19 = LAG(B19,1).
      COMPUTE B20 = LAG(B20,1).
      COMPUTE B21 = LAG(B21,1).
      COMPUTE B22 = LAG(B22,1).
      COMPUTE flag7 = 1.
END IF.
EXECUTE. 
FREQUENCIES flag7.
*Check.
TEMPORARY.    
SELECT IF (PFirst20 = 0 OR PLast20 = 0) AND AA8new LT 850.
  LIST REC_ID AA8new PFirst20 PLast20  AA7B  AB3$01 AB3B$01 AB4$01 AB5$01 AB6$01 SUM_A SUM_CtoGp flag1 flag2 flag3 flag4.

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

*DELETE duplicates with the least info. 
COMPUTE TMP = 0.
EXECUTE.
IF(PLast30 = 0) TMP = 1.
EXECUTE.
*Check.
FREQUENCIES TMP.
TEMPORARY.    
SELECT IF (PFirst30 = 0 OR PLast30 = 0).
  LIST REC_ID AA8new PFirst30 PLast30  AA7Btmp SUM_A SUM_CtoGP AB1$01 AB1$02 TMP.

*Select records within the duplicate pair with the highest value in CEtoGP. 
SELECT IF 
    TMP = 0.
EXECUTE.
*clean.
DELETE VARIABLES TMP.

*Final check on duplicates.
SORT CASES BY GeocodeEA (A) AA8new (A) SUM_CtoGP(A). 
EXECUTE.
MATCH FILES
  /FILE=*
  /BY GeocodeEA AA8new
  /FIRST=PFirst40
  /LAST=PLast40.
EXECUTE.
*Check.
FREQUENCIES PFirst40 PLast40.

***********************************************''.
*IF still duplicates, repeat the previous procedure(s) based på new duplicate match PFirst4 / PLast40. .
*Within the same duplicate pair, Identtify and delete records with the least value in SUM_AtoGP..

*< IN HERE >

******************************************************************************      
IMPUTATION OF HEAD/HEAD SEX/HEAD AGE.
*imputation for missing head 
*Check start.
FREQUENCIES AB3$01 AB3$02 AB3$03.

*Step 1) Impute head if missings for head of household relationship.
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

*Step 4) Impute age to head as 2 years older that spouse - a proxy..
*Check start..
FREQUENCIES AB5$01.

*Using person #2 in the household.
DO IF  AB3$01 = 1 AND (MISSING(AB5$01)=1 OR AB5$01 < 12) AND AB3$02 = 2  AND AB5$02 GE 12.
    COMPUTE AB5$01 = ((AB5$02) + 2).
END IF.
EXECUTE.
*Check end.
FREQUENCIES AB5$01.

*If still missing - using person #3 in the household.
DO IF  AB3$01 = 1 AND (MISSING(AB5$01)=1 OR AB5$01 < 12) AND AB3$03 = 2  AND AB5$03 GE 12.
    COMPUTE AB5$01 = ((AB5$03) + 2).
END IF.
EXECUTE.
*Check end.
FREQUENCIES AB5$01.

*If still missing using person #4 in the household.
DO IF  AB3$01 = 1 AND (MISSING(AB5$01)=1  OR AB5$01 < 12) AND AB3$04 = 2  AND AB5$04 GE 12.
    COMPUTE AB5$01 = ((AB5$04) + 2).
END IF.
EXECUTE.
*Check end..
FREQUENCIES AB5$01.

*Set age to sysmis for possible head age found less than 12 years old in the fequency above.
DO IF AB5$01 LT 12. 
    COMPUTE AB5$01 = $SYSMIS.
END IF.
EXECUTE.

******************************************************************************      
* When no more duplicates on GeocodeEA + AA8new, create alphanummerisk HH number and concatenate GeocodeHH with 17 positions.

*String for HH serial number.
STRING HH (A3).
COMPUTE HH = STRING(AA8new,n3).

*Concat the geocode for HH.
STRING  GeocodeHH (A17).
COMPUTE GeocodeHH=CONCAT(Region, District, Ward, Dummy, Village, EA, HH).
VARIABLE LABELS GeocodeHH "HH_Geocode".
EXECUTE.

*for userfriendliness.
RENAME VARIABLES (AA7 = UrbRur).
RENAME VARIABLES (AA9 = Date).
RENAME VARIABLES (AA7A = Xcoord).
RENAME VARIABLES (AA7B = Ycoord).
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
*************************************************************************************
*Alternative last cleaning to be discussed.

*Step 1) Check valid GeocodeEA with the GIS Catalogue (XLS).
*save the workfile. 
SORT CASES BY GeocodeEA (A).
SAVE OUTFILE='tmp\HHQTZ_3.sav'
/KEEP 
ALL 
/COMPRESSED.
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.


*match the GIS attribute table geocodes with the geocodes on the work file.
MATCH FILES 
/FILE= =   "tmp\HHQTZ_3.sav"
/TABLE=  "Cat\ea.sav"
/BY GeocodeEA.
EXECUTE.

*Check records on the workfile that does not match the XLS catalogue of GeocodeEA from the GIS attribute table. 
TEMPORARY.
SELECT IF (SYSMIS(Rec_ID) = 1). 
LIST REC_ID.
EXECUTE.

*Delete.
SELECT IF (SYSMIS(Rec_ID) = 0). 
EXECUTE.
*Check step 1.
FREQUENCIES Region.

*Step 2) Delete any with zero value in SUM_A and SUM_B. Cannot be used as stand-allone household in analysis.   .
COMPUTE TMP2=0.
EXECUTE.
IF (SUM_A = 0 AND SUM_B= 0) TMP2=1.
EXECUTE.
*Check.
FREQUENCIES TMP2.
TEMPORARY.    
SELECT IF TMP2=1.
    LIST REC_ID AA8new Date AA14tmp AA18tmp AA7Btmp AB1$01 SUM_A SUM_B SUM_CtoGP.
*delete.
SELECT IF
    TMP2 = 0.
EXECUTE.
*check/delete.
FREQUENCIES Region.
DELETE VARIABLES TMP2.

*Step3) Identify and delete all records where sex and age of head is still missing.
TEMPORARY.
SELECT IF (MISSING(AB4$01) = 1 OR MISSING(AB5$01) = 1).
LIST REC_ID GeocodeEA HH UrbRur AA10 AA14 AB4$01 AB5$01 SUM_A SUM_B SUM_CtoGP.

*delete.
SELECT IF (MISSING(AB4$01) = 0 AND MISSING(AB5$01) = 0).
EXECUTE.
*Check.
FREQUENCIES Region.
FREQUENCIES GeocodeEA.
*****************************************************************************
Clean up temp variables. 
DELETE VARIABLES PFirst PLast PFirst10 PLast10 PFirst20 PLast20 PFirst30 PLast30 PFirst40 PLast40 PFirst50 PLast50
SUM_A SUM_B SUM_AtoGP SUM_CtoGP AA14tmp AA18tmp AA7Btmp  flag1 flag2 flag3 flag4 flag5 flag6 flag7 Duplicate.

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
UrbRur
Xcoord
Ycoord
Date
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 
*********************************************************************.
*END OF SYNTAX.
********************************************************************* 




