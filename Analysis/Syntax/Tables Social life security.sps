* Encoding: UTF-8.
DATASET CLOSE all.
get FILE='Data\TZHHLEVEL_4.sav'.

* Women empowerment status, add together the number who have 1 or 3 in t2,t3 and t4.
COMPUTE es = sum(any(t2,1,3),any(t3,1,3),any(t4,1,3)).
FREQUENCIES t2 t3 t4 es.
VARIABLE LABELS es 'Women empowerment status'.

DO IF (W2A$1 = 4 or W2B$1 = 4).
    COMPUTE w2_compare = 4.
ELSE IF (W2A$1 > W2B$1).
    COMPUTE w2_compare = 1.
ELSE IF (W2A$1 = W2B$1).
    COMPUTE w2_compare = 2.
ELSE IF (W2A$1 < W2B$1).
    COMPUTE w2_compare = 3.
END IF. 
VARIABLE LABELS w2_compare 'Today compared to 5 years ago'.
VALUE LABELS w2_compare   
     1 "Not safe"
     2 "Fairly safe"
     3 "Completely safe"
     4 "Not applicable"
     .
*FREQUENCIES w2_compare.

CTABLES
  /VLABELS VARIABLES= headsex_gr1 edu_hh_gr1 HighEduc_Gr1 HHOccupStatus_gr1 HHOccupStatus_gr2 HHOccupStatus_gr3 HHOccupStatus_gr4 HHOccupStatus_gr5 NatExpQuint HHCONN comD3 sdg7 aetaccess es
                      W2A$1 W2B$1 w2_compare DISPLAY=LABEL
  /TABLE area + headsex_gr1 + edu_hh_gr1 + HHOccupStatus_gr1 + HHOccupStatus_gr2 + HHOccupStatus_gr3 + HHOccupStatus_gr4 + HHOccupStatus_gr5 + NatExpQuint + HHCONN + comD3 + sdg7 + aetaccess + es 
    BY W2A$1 [ROWPCT.COUNT f40.0] + W2B$1 [ROWPCT.COUNT f40.0] + w2_compare [ROWPCT.COUNT f40.0] 
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=area ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /CATEGORIES VARIABLES=headsex_gr1 ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /TITLES  TITLE='Women''s perceived security of walking alone in her area during daytime. Households with female adult(s). Percent'
  .


DEFINE !TableSecurity (colvar1=!tokens(1)
                      /colvar2=!tokens(1)
                      /tablenum=!tokens(1)
                      /titletext=!ENCLOSE('(',')'))

DO IF (!colvar1 = 4 or W2B$1 = 4).
    COMPUTE w2_compare = 4.
ELSE IF (!colvar1 > !colvar2).
    COMPUTE w2_compare = 1.
ELSE IF (!colvar1 = !colvar2).
    COMPUTE w2_compare = 2.
ELSE IF (!colvar1 < !colvar2).
    COMPUTE w2_compare = 3.
END IF. 
VARIABLE LABELS w2_compare 'Today compared to 5 years ago'.
VALUE LABELS w2_compare   
     1 "Not safe"
     2 "Fairly safe"
     3 "Completely safe"
     4 "Not applicable"
     .
*FREQUENCIES w2_compare.

CTABLES
  /VLABELS VARIABLES= headsex_gr1 edu_hh_gr1 HighEduc_Gr1 HHOccupStatus_gr1 HHOccupStatus_gr2 HHOccupStatus_gr3 HHOccupStatus_gr4 HHOccupStatus_gr5 NatExpQuint HHCONN comD3 sdg7 aetaccess es
                      !colvar1 !colvar2 w2_compare DISPLAY=LABEL
  /TABLE area + headsex_gr1 + edu_hh_gr1 + HHOccupStatus_gr1 + HHOccupStatus_gr2 + HHOccupStatus_gr3 + HHOccupStatus_gr4 + HHOccupStatus_gr5 + NatExpQuint + HHCONN + comD3 + sdg7 + aetaccess + es 
    BY !colvar1 [ROWPCT.COUNT f40.0] + !colvar1 [ROWPCT.COUNT f40.0] + w2_compare [ROWPCT.COUNT f40.0] 
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=area ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /CATEGORIES VARIABLES=headsex_gr1 ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /TITLES  TITLE=!Concat("'",'Table ',!tablenum ,'. ', !titletext, '. Households with female adult(s). Percent',"'")
    CAPTION='Source: IASES 2022'.
  .
!ENDDEFINE.

!TableSecurity colvar1=W2A$1 colvar2=W2B$1 tablenum=1 titletext=(Women''s perceived security of walking alone in her area during daytime).
!TableSecurity colvar1=W2A$2 colvar2=W2B$2 tablenum=2 titletext=(Women''s perceived security of walking alone in her area at night).
!TableSecurity colvar1=W2A$3 colvar2=W2B$3 tablenum=3 titletext=(Women''s perceived security of being alone at home during daytime).
!TableSecurity colvar1=W2A$4 colvar2=W2B$4 tablenum=4 titletext=(Women''s perceived security of being alone at home at night).
!TableSecurity colvar1=W2A$5 colvar2=W2B$5 tablenum=5 titletext=(Women''s perceived security of waiting for, or in public transport, in her area).
!TableSecurity colvar1=W2A$6 colvar2=W2B$6 tablenum=6 titletext=(Women''s perceived security at the workplace, e.g. fields, market, job, etc.).
!TableSecurity colvar1=W2A$7 colvar2=W2B$7 tablenum=7 titletext=(Women''s perceived security in public places, e.g. shopping centre, church).
!TableSecurity colvar1=W2A$8 colvar2=W2B$8 tablenum=8 titletext=(Women''s perceived security of when collecting firewood).
!TableSecurity colvar1=W2A$9 colvar2=W2B$9 tablenum=9 titletext=(Women''s perceived security of when fetching water).



