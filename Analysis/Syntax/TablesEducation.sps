* Encoding: UTF-8.
DATASET CLOSE all.
GET FILE='Data\TZPRSLEVEL_3.sav'.

WEIGHT POPWEIGHT.

COMPUTE n = 1.
VARIABLE LABELS n 'n = 100%'.


MRSETS
  /MDGROUP NAME=$Occup LABEL='Economic status by at least one member of  household' 
   CATEGORYLABELS=VARLABELS VARIABLES=HHOccupStatus_gr1 HHOccupStatus_gr2 HHOccupStatus_gr3 HHOccupStatus_gr4 HHOccupStatus_gr5 
 VALUE=1
  /DISPLAY NAME=[$Occup].

DEFINE !EducTable (colvar=!tokens(1)
              /tablenum=!tokens(1)
              /titletext=!ENCLOSE('(',')'))
TEMPORARY.
SELECT IF (age >= 5).
CTABLES
  /VLABELS VARIABLES=area region headsex_gr1 HighEduc_Gr1 $Occup NatExpQuint comD3 comD1_gr1h !colvar n DISPLAY=LABEL
  /TABLE area + region + headsex_gr1 + HighEduc_Gr1 + $Occup + NatExpQuint + comD3 [C] + comD1_gr1h [C] BY !colvar [C] [ROWPCT.COUNT F40.0] + n 
    [S][UCOUNT F40.0]
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=area EMPTY=EXCLUDE TOTAL=YES LABEL='Mainland Tanzania' 
    POSITION=BEFORE
  /CATEGORIES VARIABLES=region headsex_gr1 HighEduc_Gr1 NatExpQuint comD3 comD1_gr1h !colvar  ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES=$Occup  EMPTY=EXCLUDE
  /CRITERIA CILEVEL=95
   /TITLES
    TITLE=!Concat("'",'Table ',!tablenum ,'.  ', !titletext, ' by background variables. Percent',"'")
    CAPTION='n = unweighted number of households.' 'Source: IASES 2022'. 
  .
!ENDDEFINE.

!EducTable colvar=literacy tablenum=1 titletext=(Literacy, persons 5 years and above).
!EducTable colvar=EverAttend tablenum=2 titletext=(Ever attended school. Persons 5 years and above).
!EducTable colvar=EnrollCurrY tablenum=3 titletext=(School enrollment this year, persons 5 years and above).
!EducTable colvar=GradeCurrY tablenum=4 titletext=(School grade enrollment this year, persons 5 years and above).
!EducTable colvar=AttendCurrY tablenum=5 titletext=(Current school, persons 5 years and above).
!EducTable colvar=GradeLastY tablenum=6 titletext=(School grade attended previous school year, persons 5 years and above).
!EducTable colvar=HighEvComp tablenum=7 titletext=(Highest grade of educaton completed, persons 5 years and above).

