* Encoding: UTF-8.
DATASET CLOSE all.
GET FILE='Data\TZHHLEVEL_1.sav'.
WEIGHT weight.  
COMPUTE n = 1.
VARIABLE LABELS n 'n = 100%'.

DO IF (Region = '07').
 COMPUTE Area = 1.
ELSE IF (UrbRur = 1). 
 COMPUTE Area = 2.
ELSE IF (UrbRur = 2). 
 COMPUTE Area = 3.
ELSE.
 COMPUTE Area = 9.
END IF.
VALUE LABELS Area
 1 'Dar-es-salaam'
 2 'Rural'
 3 'Urban'
 .
FREQUENCIES Area.

MRSETS
  /MDGROUP NAME=$Occup LABEL='Economic status by at least one member of  household' 
   CATEGORYLABELS=VARLABELS VARIABLES=HHOccupStatus_gr1 HHOccupStatus_gr2 HHOccupStatus_gr3 HHOccupStatus_gr4 HHOccupStatus_gr5 
 VALUE=1
  /DISPLAY NAME=[$Occup].

CTABLES
  /VLABELS VARIABLES=headsex_gr1 HighEduc_Gr1 $Occup NatExpQuint comD3 comD1_gr1h c2 n DISPLAY=LABEL
  /TABLE headsex_gr1 + HighEduc_Gr1 + $Occup + NatExpQuint + comD3 [C] + comD1_gr1h [C] BY c2 [ROWPCT.COUNT F40.0] + n 
    [S][UCOUNT F40.0]
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=headsex_gr1 EMPTY=EXCLUDE TOTAL=YES LABEL='Mainland Tanzania' 
    POSITION=BEFORE
  /CATEGORIES VARIABLES=HighEduc_Gr1 NatExpQuint comD3 comD1_gr1h c2 ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES=$Occup  EMPTY=EXCLUDE
  /CRITERIA CILEVEL=95
   /TITLES
    TITLE='Table 6. Connection to grid by background variables. Percent'
    CAPTION='n = unweighted number of households.' 'Source: IASES 2022'. 
  .

DEFINE !Table (colvar=!tokens(1)
              /tablenum=!tokens(1)
              /titletext=!ENCLOSE('(',')'))
CTABLES
  /VLABELS VARIABLES=headsex_gr1 HighEduc_Gr1 $Occup NatExpQuint comD3 comD1_gr1h n DISPLAY=LABEL
  /VLABELS VARIABLES= !colvar n DISPLAY=NONE
  /TABLE headsex_gr1 + HighEduc_Gr1 + $Occup + NatExpQuint + comD3 [C] + comD1_gr1h [C] BY !colvar [ROWPCT.COUNT F40.0] + n 
    [S][UCOUNT F40.0]
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=headsex_gr1 EMPTY=EXCLUDE TOTAL=YES LABEL='Mainland Tanzania' 
    POSITION=BEFORE
  /CATEGORIES VARIABLES=HighEduc_Gr1 NatExpQuint comD3 comD1_gr1h !colvar ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CATEGORIES VARIABLES=$Occup  EMPTY=EXCLUDE
  /CRITERIA CILEVEL=95
   /TITLES
    TITLE=!Concat("'",'Table ',!tablenum ,'. Tiers for ', !titletext, ' by background variables. Percent',"'")
    CAPTION='n = unweighted number of households.' 'Source: IASES 2022'. 
  .
!ENDDEFINE.

!Table colvar=c2 tablenum=1 titletext=(Connection to grid).
!Table colvar=b2 tablenum=2 titletext=(Type of dwelling).


