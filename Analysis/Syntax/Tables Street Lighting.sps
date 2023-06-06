* Encoding: UTF-8.
DATASET CLOSE all.
get FILE='Data\TZHHLEVEL_4.sav'.


MRSETS
  /MDGROUP NAME=$HHOccupStatus LABEL='Occupation status' 
   CATEGORYLABELS=VARLABELS VARIABLES=HHOccupStatus_gr1 to HHOccupStatus_gr5 VALUE=1
  /DISPLAY NAME=[$HHOccupStatus].


CTABLES
  /VLABELS VARIABLES= headsex_gr1 edu_hh_gr1 HighEduc_Gr1 $HHOccupStatus NatExpQuint area region
                      m1 m2 m3 DISPLAY=LABEL
  /TABLE headsex_gr1 + edu_hh_gr1 + $HHOccupStatus + NatExpQuint + area + region
    BY m1 [ROWPCT.COUNT f40.0] + m2 [ROWPCT.COUNT f40.0] + m3 [ROWPCT.COUNT f40.0] 
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=area ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /CATEGORIES VARIABLES=headsex_gr1 ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /TITLES  TITLE='Table 1. Street lighting in neighbourhood. All households'
           CAPTION='Source: IASES 2022'.
  .



DATASET ACTIVATE $DataSet.
* Custom Tables.
CTABLES
  /VLABELS VARIABLES=Region M1 M2 M3 DISPLAY=LABEL
C3  /TABLE Region BY M1 [COUNT F40.0, ROWPCT.COUNT F40.0] + M2 [COUNT F40.0, ROWPCT.COUNT F40.0] + M3 
    [COUNT F40.0, ROWPCT.COUNT F40.0]
  /CATEGORIES VARIABLES=Region M1 M2 M3 ORDER=A KEY=VALUE EMPTY=INCLUDE
.

* Custom Tables.
CTABLES
  /VLABELS VARIABLES=Region M1 M2 M3 DISPLAY=LABEL
  /TABLE Region [COUNT F40.0, ROWPCT.COUNT F40.0] BY M1 + M2 + M3
  /CATEGORIES VARIABLES=Region M1 M2 M3 ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CRITERIA CILEVEL=95.

