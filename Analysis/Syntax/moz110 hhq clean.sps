* Encoding: UTF-8.
* Created 19.01.2022. 
* Update: Kristian 26.01 - 10.02.2022       
* Update::Per 19.01 - 30.04.2022.
* SSB/NBS project team final approval: ................ 

*Objective: 1) Re-construct household information from raw-data to the extent possible, clean for duplicates&test-records and construct an unique household identifier  
                 2) Secure consistency between household level and community level file
 
*Out-put: A household level file ready for merging with community file and further restructure/labelling, 
                 
*The SPSS raw-data file used here is exported from the CSPro/CSWeb internal project database as a SPSS ".sav" format file. 
*Use the "export syntax" created by CSPro at export. In SPSS, add correct "directory path" in the folder structure and "save file addess "to the "export syntax" before use. 
*Save the file to the  ".....\tmp\HHQTZ_1.sav)".
*******************************************************************************************************************************************''********************************************
The working filestructure for this program is as follows:

*.....\2021_22_SPSS Mozambique
            \Cat
            \Data
            \Documentation
            \Production
            \Tables
            \Syntax
            \Tmp
*************'*****************************************************************************
*Open imported temp file from the folder structure.
GET FILE='data\moz_hhq_raw.sav'.

*Add recordnumber to the file opened to always be able to sort the records in the initial order found in the database.
COMPUTE REC_ID= $CASENUM.
FORMATS REC_ID(F6.0).
VARIABLE LABELS REC_ID "Record_ID".
EXECUTE.
*Check number of rec on initial in-file (and filling in of ID codes).
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

*When all ID codes are filled in - Create new alpha-nummeric ID variables for Provincia to AE.. .
*String for PROVINCIA.
STRING Provincia (A2).
COMPUTE Provincia = STRING(AA1,n2).
*String for DISTRITO..
STRING Distrito (A2).
COMPUTE Distrito = STRING(AA2,n2).
*String for POSTO..
STRING Posto (A3).
COMPUTE Posto = STRING(AA3,n3).
*String for LOCALIDADE..
STRING Localidade (A2).
COMPUTE Localidade = STRING(AA4,n2).
*String for VILA/CIDADE.
STRING Vila_Cidade (A2).
COMPUTE Vila_Cidade = STRING(AA5,n2).
*String for AE.
STRING AE (A3).
COMPUTE AE = STRING(AA6,n3).

*Concat the geocode for EA.
STRING  GeocodeEA (A14).
COMPUTE GeocodeEA=CONCAT(Provincia, Distrito, Posto, Localidade, Vila_Cidade, AE).
VARIABLE LABELS GeocodeEA "EA_Geocode".
EXECUTE.
* Labelling new ID variables Region to EA..
VARIABLE LABELS Provincia "Provincia".
VALUE LABELS Provincia 
"01" 01 Niassa
"02" 02 Cabo Delgado 
"03" 03 Nampula 
"04" 04 Zambezia 
"05" 05 Tete 
"06" 06 Manica 
"07" 07 Sofala 
"08" 08 Inhambane 
"09" 09 Gaza 
"10" 10 Maputo Provincia
"11" 11 Maputo Cidade. 
VARIABLE LABELS Distrito "Distrito".
VARIABLE LABELS Posto "Posto".
VARIABLE LABELS Localidade "Localidade".
VARIABLE LABELS Vila_Cidade "Vila_Cidade".
VARIABLE LABELS AE "EA_ID".
EXECUTE.
*Check.
FREQUENCIES Provincia. 

*****************************************************************************************************.
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
COMPUTE SUM_A = SUM(AB3$01 TO A8$50).
COMPUTE SUM_B = SUM(b1 TO b15).
COMPUTE SUM_C = SUM(c1,c2,c3,c4,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,
    c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,c51,c52,
    c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,
    c94,c95,c96,c97,c98,c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,c112,
    c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,c125,c126,c127,c128,c129,c130,c131,c132,c133,c134). 
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
COMPUTE SUM_AtoGP = SUM(SUM_A,SUM_B,SUM_C,SUM_E,SUM_F,SUM_G,SUM_I,SUM_J,SUM_K,SUM_L,
SUM_M,SUM_O,SUM_Q,SUM_S,SUM_T,SUM_U,SUM_GP).
COMPUTE SUM_CtoGP = SUM(SUM_C,SUM_E,SUM_F,SUM_G,SUM_I,SUM_J,SUM_K,SUM_L,
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
FREQUENCIES Provincia.

*6) Identify duplicates on GeocodeEA + EA number..
SORT CASES BY GeocodeEA (A) AA8new(A) SUM_CtoGP (A).
MATCH FILES
  /FILE=*
  /BY GeocodeEA AA8new
  /FIRST=PFirst
  /LAST=PLast.
EXECUTE.

IF (PFirst = 0 OR PLast = 0) Duplicate=1. 
FORMATS Duplicate (F2.0).

*Check how many duplicates on Household level and total number of records remaining?.
FREQUENCIES PFirst PLast Duplicate. 
*Check if any systematic duplicate by enumerator and region.
TEMPORARY.
SELECT IF Duplicate=1.
LIST REC_ID Provincia GeocodeEA AA9 AA9A AALOGIN.


********************************************************
*Reorganize the work-file with the new created ID variable and tmp help variables first on the file and store/save for better visuals when browsing the file.
SAVE OUTFILE='tmp\HHQMZ_2.sav'
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
GET FILE='tmp\HHQMZ_2.sav'.

*Check the input file..
FREQUENCIES PFirst PLast Duplicate.    
**************************************************************************************************..
*RECODE IF DIFFERENT HOUSEHOLDS IN THE SAME DUPLICATE PAIR AND BOTH ARE COMPLETE FILLED IN ON THE PERSON VARIABLES.

*Create /adjust some temporary help variables.
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
FREQUENCIES PFirst.
TEMPORARY.    
SELECT IF PFirst = 0 OR PLast = 0.
  LIST REC_ID AA8new PFirst PLast AA9 AA14tmp AA18tmp AA7Btmp AB1$01 SUM_A SUM_B SUM_CtoGP AB1$01.

*Step 1)  Renumber HH# for duplicates of the type 0-1 with both OK filled in (based on SUM_A (min sum50) and SUM_CtoGP(min sum9000) and keep the rest for further check...
*Compare AA14tmp AA18tmp AA7Btmp. 
SORT CASES BY GeocodeEA (A) AA8new (A) PFirst (D) PLast (A). 

SET RNG=MC SEED=20220222.
DO IF
     AA8new = LAG(AA8new, 1) AND
     PFirst = 0 AND PLast = 1 AND  
     (  (AA14tmp NE "000" AND LAG(AA14tmp, 1) NE "000" AND AA14tmp NE LAG(AA14tmp, 1) ) OR  
        (AA18tmp NE "000" AND LAG(AA18tmp, 1) NE "000" AND AA18tmp NE LAG(AA18tmp, 1) ) OR
        (AA7Btmp  NE 0 AND LAG(AA7Btmp, 1) NE 0 AND AA7Btmp NE LAG(AA7Btmp, 1) )   ) AND
        SUM_A GT 50 AND SUM_CtoGP GT 1000 AND LAG(SUM_A, 1) GT 50 AND LAG(SUM_CtoGP, 1) GT 1000. 
     COMPUTE AA8new = RND (RV.UNIFORM(850, 999)).
     COMPUTE PFirst = 1.
     COMPUTE PLast = 1. 
     COMPUTE flag0 = 1.
END IF.
EXECUTE.
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

*imputation for missing head 
*Check start.
FREQUENCIES AB3$01 AB3$02 AB3$03.

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
VARIABLE LABELS HH "Codigo do agregado familiar".

*Concat the geocode for HH.
STRING  GeocodeHH (A17).
COMPUTE GeocodeHH=CONCAT(Provincia, Distrito, Posto, Localidade, Vila_Cidade, AE, HH).
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
SAVE OUTFILE='tmp\HHQMZ_2b.sav'
/KEEP ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.

***********************************************************.
*New step for v7 of the syntax - checking consistency of Geocode EA .
*Based on manual check between GIS EAcodes, SamplingEA codes and data file EAcodes..

*Open work file.
GET FILE='tmp\HHQMZ_2b.sav'.

FREQUENCIES Provincia GeocodeEA.

* Custom Tables.
CTABLES
  /VLABELS VARIABLES=GeocodeEA UrbRur DISPLAY=LABEL
  /TABLE GeocodeEA BY UrbRur [COUNT F40.0]
  /CATEGORIES VARIABLES=GeocodeEA ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES=UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CRITERIA CILEVEL=95.


*save the workfile. 
SORT CASES BY GeocodeEA (A).
SAVE OUTFILE='tmp\HHQMZ_3.sav'
/KEEP 
ALL 
/COMPRESSED.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.

*****************************************************************.
*Open workfile.
GET FILE='tmp\HHQMZ_3.sav'.

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
FREQUENCIES Provincia.

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

*check.
FREQUENCIES AB4$01. 
  
*******************************************************.
*3b) Impute still missing head age based on nearest neighbour add-in macro.
*check start.
FREQUENCIES AB5$01.

*****************************************************************************
*Clean up temp variables. 
DELETE VARIABLES AA14tmp AA18tmp AA7Btmp PFirst10 PLast10 PFirst50 PLast50 PFirst PLast Duplicate.

*Last check of results.
FREQUENCIES Provincia GeocodeEA.
* Custom Tables.
CTABLES
  /VLABELS VARIABLES=GeocodeEA UrbRur DISPLAY=LABEL
  /TABLE GeocodeEA BY UrbRur [COUNT F40.0]
  /CATEGORIES VARIABLES=GeocodeEA ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES=UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CRITERIA CILEVEL=95.

*****************************************************************************************************
*****************************************************************************************************
*Save temporary file with unique identifiers  - ready for using next sytax for merge with community, labelling and restructuring. 

*THIS FILE IS ADDRESSED TO THE NEXT SYNTAX FOR FURTHER MERGE TO COMFILE, LABELLING AND RESTRUCTURE.

SORT CASES BY GeocodeEA (A) HH (A). 
SAVE OUTFILE='tmp\HHQMZ_4.sav'
/KEEP 
REC_ID
GeocodeEA
GeocodeHH
HH
Provincia
UrbRur
Xcoord
Ycoord
Date
ALL 
/COMPRESSED.

*final check/count.
FREQUENCIES Provincia.

*Close all.
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE. 
*********************************************************************.
*END OF SYNTAX.
********************************************************************* .





