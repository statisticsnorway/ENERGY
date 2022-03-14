* Encoding: UTF-8.
* Created 19.01.2022. 
* Update::Per 19.01 - 10.02.2022.
* SSB/NBS project team final approval: ................ 

*Objective: 1) Browsing the listing data and costruct an unique household identifier 
                2) Secure consistency with the household level file 
                 
*Out-put: A listing data file with labels and unique identifier at household level. 
                 
*The SPSS raw-data file used here is exported from the CSPro/CSWeb internal project database as a SPSS ".sav" format file. 
*Use the "export syntax" created by CSPro at export. In SPSS, add correct "directory path" in the folder structure and "save file addess "to the "export syntax" before use. 
*Save the file to the  "...\Data in" folder as "....\tmp\ListTZ_1.sav)".
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

*Set address to the filestructure once and get the imported raw-data-file from the tmp folder.
DATASET CLOSE ALL.
OUTPUT CLOSE ALL.
GET FILE='tmp\ListTZ_1.sav'.

*add record number before any other operation on the file.
*the raw-database is always appending new records to the end of the database and thus all "training records" are at the top. 

COMPUTE lstREC_ID= $CASENUM.
FORMATS lstREC_ID(F6.0).
VARIABLE LABELS lstREC_ID "Record_ID".
EXECUTE.

*********************************************************************************
*GET RID OF TESTING RECORDS IN THE IN-DATA _CLEAN THE FILE!!!!
*remove the first "training records" by first time visual check and thereafter apply the automatic "select" below.
*This is because we have no date/time on the records to guide us for deleting training records. 
*With the new lstREC_ID, we can easily change the SELECT if lstREC_ID should be more than the 31 first records as below.
*This step must be further developed based on info from the HHQ file datum stamp.    . 

*Delete records.
TEMPORARY.
SELECT IF 
    lstREC_ID <= 31.
LIST lstREC_ID LL9 LL12.

SELECT IF 
    lstREC_ID GT 31.

*Create new alpha-nummeric ID variables. .
*String for REGIONS.
STRING lstRegion (A2).
COMPUTE lstRegion = STRING(LL1,n2).

*String for DISTRICT..
STRING lstDistrict (A2).
COMPUTE lstDistrict = STRING(LL2,n2).

*String for WARD..
STRING lstWard (A3).
COMPUTE lstWard = STRING(LL3,n3).

*String for DUMMY..
STRING lstDummy (A2).
RECODE LL4 
    (0 THRU 99 = "11") 
INTO lstDummy.

*String for VILLAGE (Vil_Mta_N).
STRING lstVillage (A2).
COMPUTE lstVillage = STRING(LL5,n2).

*String for EA.
STRING lstEA (A3).
COMPUTE lstEA = STRING(LL6,n3).

*String for Household serial number.
STRING lstHHnumber (A3).
COMPUTE lstEA = STRING(LL8,n3).

*Concat the geocode for EA.
STRING  GeocodeEA (A14).
COMPUTE GeocodeEA=CONCAT(lstRegion, lstDistrict, lstWard, lstDummy, lstVillage, lstEA).
VARIABLE LABELS GeocodeEA "EA_Geocode".
EXECUTE.

*Concat the geocode for household.
STRING  GeocodeHH (A17).
COMPUTE GeocodeHH=CONCAT(lstRegion, lstDistrict, lstWard, lstDummy, lstVillage, lstEA, lstHHnumber).
VARIABLE LABELS GeocodeHH "HH_Geocode".
EXECUTE.

* Labelling new ID variables.
VARIABLE LABELS lstRegion "Region".
VALUE LABELS lstRegion 
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

VARIABLE LABELS lstDistrict "District".
VARIABLE LABELS lstWard "Ward".
VARIABLE LABELS lstDummy "Dummy".
VARIABLE LABELS lstVillage "Village".
VARIABLE LABELS lstEA "EA_ID".
VARIABLE LABELS lstHHnumber "HHnumber".

*Check.
FREQUENCIES lstRegion. 

*Check / list training EAs given in the project GIS.attribute file (5 in ARUSHA and 5 in MOROGORO).They should be removed from the survey.
TEMPORARY.
SELECT IF (ANY(GeocodeEA, "02060111102005","02062131104006","02031221101005","02031721111001","02060211101003","05051621115001",
"05051421104001","05051921104001","05051621101002","05050921130004") = 1).
LIST lstREC_ID lstRegion GeocodeEA. 
EXECUTE.

*Remove training EAs..
SELECT IF (ANY(GeocodeEA, "02060111102005","02062131104006","02031221101005","02031721111001","02060211101003","05051621115001",
"05051421104001","05051921104001","05051621101002","05050921130004") = 0).

*Check.
FREQUENCIES lstRegion.

*RENAMING VARIABLES (with the same name found on the HHQ file) TO PREPARE FOR MERGE WITH HH FILE.
RENAME VARIABLES (LLOGIN = lstLLOGIN) (LL1 = lstLL1) (LL2 = lstLL2) (LL3 = lstLL3) (LL4 = lstLL4) (LL5 = lstLL5) (LL6 = lstLL6) 
(LL8 = lstLL8) (LLUR = lstLLUR) (LL7=lstLL7) (LL7A=lstLL7A) (LL7B =lstLL7B) (LL9 = lstLL9) (LL10=lstLL10) (LL11=lstLL11) (LL12=lstLL12).

VARIABLE LABELS lstLLUR "Urban/Rural".
VALUE LABELS lstLLUR 
    1 "Urban" 
    2 "Rural".
FREQUENCIES lstLLUR.
****************************************************
*compute number of hh listed in the EA.
COMPUTE lstHH_num = 1.
VARIABLE LEVEL lstHH_num (NOMINAL).
VARIABLE LABELS lstHH_num "Number of households listed in EA".
SORT CASES BY GeocodeEA (A).
AGGREGATE  
/OUTFILE=* MODE=ADDVARIABLES OVERWRITE=YES  
/PRESORTED 
/BREAK= GeocodeEA 
/lstHH_num = SUM(lstHH_num).
FORMATS lstHH_num (F6.0).

*check.
FREQUENCIES lstHH_num.
COMPUTE lstHH_num_gr1 = $SYSMIS.
FORMATS lstHH_num_gr1(F5.0).
VARIABLE LEVEL lstHH_num_gr1 (NOMINAL).
RECODE lstHH_num (LOWEST THRU 1 =1) (2 THRU 3 =2) (4 THRU 5 = 3) (6 THRU 9 = 4) (10 THRU HIGHEST = 5) INTO lstHH_num_gr1.
VARIABLE LABELS lstHH_num_gr1 "Number of households listed in the EA".
VALUE LABELS lstHH_num_gr1 
1 "    <2"
2 " 2 - 3"
3 " 4 - 5"
4 " 5 - 9"
5 "   10+".

*Check.
FREQUENCIES lstHH_num_gr1.

SAVE OUTFILE='tmp\ListTZ_2.sav'
/KEEP 
lstREC_ID
lstRegion
GeocodeEA
GeocodeHH
lstEA
lstHHnumber
lstHH_num
lstHH_num_gr1
ALL
/COMPRESSED..

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
EXECUTE.


*****************************************************************************************
*PRELIMINARY TABULLATION/BROWSING  AT LISTING LEVEL
*****************************************************************************************.
*Open temp data file..
GET FILE='tmp\ListTZ_2.sav'.

*****************************************************************************************
* FREQUENCIES.

FREQUENCIES VARIABLES= lstRegion lstHH_num lstHH_num_gr1 lstLLOGIN lstLL1 
                                             lstLL2 lstLL3 lstLL4 lstLL5 lstLL6 lstLLUR lstLL7 lstLL9 lstLL12.

*export freq results to worksheet.

*OBS: If worksheet already exists, change CREATESHEET to MODIFYSHEET in the syntax below. 
*OUTPUT EXPORT
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ListTZ_TAB1.xls'
     OPERATION= MODIFYSHEET  
     SHEET =  'FREQ'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.
*EXECUTE.

OUTPUT CLOSE ALL.

*************************************************************************************.
*CROSSTAB.

OUTPUT CLOSE ALL.
CROSSTABS
  /TABLES=lstLL9 BY lstLLUR
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
/TABLES=lstLL9 BY lstLL12
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
/TABLES=lstLL9 BY lstHH_num
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
/TABLES=lstLL9 BY lstHH_num_gr1
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
/TABLES=lstLLUR BY lstLL12
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

*export Cross results to worksheet.
*OUTPUT EXPORT
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ListTZ_TAB2.xls'
     OPERATION= MODIFYSHEET  
     SHEET =  'CRSTAB'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.
*EXECUTE.

OUTPUT CLOSE ALL.

**********************************************************************.
*TABULATION .
*macro example.
DEFINE !macro_TABCOM10 (n1=!TOKENS(1))
CTABLES
 /VLABELS VARIABLES = lstLLUR, lstHH_num_gr1, lstLL9, lstLL12,  lstRegion DISPLAY=LABEL
 /TABLE  
lstLLUR [C] +  lstHH_num_gr1 [C] + lstLL9 [C] + lstLL12 [C] + lstRegion [C]  
       BY  
!n1  [C] [ROWPCT.COUNT F40.0]  + !n1  [S] [COUNT]  /SLABELS VISIBLE=YES   
/CATEGORIES VARIABLES=lstLLUR  [1, 2, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
/CATEGORIES VARIABLES=lstHH_num_gr1 [1, 2, 3, 4, 5, OTHERNM] EMPTY=INCLUDE TOTAL=YES POSITION=AFTER
/CATEGORIES VARIABLES=lstLL9  [1, 2, 3, 4, OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=lstLL12  [1, 2, 3, OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/CATEGORIES VARIABLES=lstRegion [OTHERNM] EMPTY=INCLUDE TOTAL=NO POSITION=AFTER
/TITLES 
TITLE = "Table #. Households listed in the EA by location, EA size, presence at listing, source of el-power and region. Percent (and number of obs)"
CAPTION = "*Source: IASES tabulation test in Tanzania 2021/22 - unweighted data". 
!ENDDEFINE.
!macro_TABCOM10 n1=lstHH_num_gr1.
!macro_TABCOM10 n1=lstLL9.
!macro_TABCOM10 n1=lstLL12.

*****************************************************************************
*export tabullation results to worksheet.
*OUTPUT EXPORT
  /CONTENTS  
     EXPORT=VISIBLE  
     LAYERS= VISIBLE  
     MODELVIEWS= VISIBLE
  /XLS  DOCUMENTFILE=  'tabeller\ListTZ_TAB3.xls'
     OPERATION= CREATESHEET  
     SHEET =  'TABLES'
     LOCATION=LASTCOLUMN  
     NOTESCAPTIONS=YES.

OUTPUT CLOSE ALL.
DATASET CLOSE ALL.
*****************************************************************************************
*END OF SYNTAX
*****************************************************************************************








