* Encoding: UTF-8.
DATASET CLOSE all.
get FILE='Data\TZHHLEVEL_3.sav'.


MRSETS
  /MDGROUP NAME=$HHOccupStatus LABEL='Occupation status' 
   CATEGORYLABELS=VARLABELS VARIABLES=HHOccupStatus_gr1 to HHOccupStatus_gr5 VALUE=1
  /DISPLAY NAME=[$HHOccupStatus].

RECODE L2A$20 
    (1 thru high = 1)
    (ELSE = 0)
    INTO L2A$20YN.

RECODE L2A$21 
    (1 thru high = 1)
    (ELSE = 0)
    INTO L2A$21YN.

RECODE L2A$22 
    (1 thru high = 1)
    (ELSE = 0)
    INTO L2A$22YN.

VARIABLE LABELS
 L2A$01 'Bed'
/L2A$02 'Table'
/L2A$03 'Bicycle'
/L2A$04 'Motorcycle'
/L2A$05 'Vehicle (Car, pickup truck, etc)'
/L2A$06 'Radio using batteries'
/L2A$07 'Mobile phone charger'
/L2A$08 'Electric radio'
/L2A$09 'Fan'
/L2A$10 'Refrigerator'
/L2A$11 'Microwave oven'
/L2A$12 'Freezer'
/L2A$13 'Washing machine'
/L2A$14 'Electric sewing machine'
/L2A$15 'Air Conditioner (AC)'
/L2A$16 'Computer/ Tablet'
/L2A$17 'Electric hot water pot/kettle'
/L2A$18 'TV'
/L2A$19 'Electric water pump'
/L2A$20YN 'Traditonal light bulbs'
/L2A$21YN 'LED light bulbs'
/L2A$22YN 'Light bulbs, tubes - other types'
.
VARIABLE LABELS
 L2C$01 'Bed'
/L2C$02 'Table'
/L2C$03 'Bicycle'
/L2C$04 'Motorcycle'
/L2C$05 'Vehicle (Car, pickup truck, etc)'
/L2C$06 'Radio using batteries'
/L2C$07 'Mobile phone charger'
/L2C$08 'Electric radio'
/L2C$09 'Fan'
/L2C$10 'Refrigerator'
/L2C$11 'Microwave oven'
/L2C$12 'Freezer'
/L2C$13 'Washing machine'
/L2C$14 'Electric sewing machine'
/L2C$15 'Air Conditioner (AC)'
/L2C$16 'Computer/ Tablet'
/L2C$17 'Electric hot water pot/kettle'
/L2C$18 'TV'
/L2C$19 'Electric water pump'
/L2C$20 'Traditonal light bulbs'
/L2C$21 'LED light bulbs'
/L2C$22 'Light bulbs, tubes - other types'
.
     

MRSETS
  /MDGROUP NAME=$assets LABEL='Assets'
   CATEGORYLABELS=VARLABELS VARIABLES=L2A$01 to L2A$19 L2A$20YN to L2A$22YN VALUE=1
  /DISPLAY NAME=[$Assets].
     
MRSETS
  /MDGROUP NAME=$assets5 LABEL='Assets 5 years ago'
   CATEGORYLABELS=VARLABELS VARIABLES=L2C$01 to L2C$22 VALUE=1
  /DISPLAY NAME=[$Assets5].
     

CTABLES
  /VLABELS VARIABLES= $assets area DISPLAY=NONE
  /TABLE $assets 
    BY area  [COLPCT.COUNT f40.0] 
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=area ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /CATEGORIES VARIABLES=$assets ORDER=A KEY=VALUE EMPTY=INCLUDE total=no position = before
  /TITLES  TITLE='Table 1. Household assets today'
           CAPTION='Source: IASES 2022'.
  .


CTABLES
  /VLABELS VARIABLES= $assets5 area DISPLAY=NONE
  /TABLE $assets5 
    BY area  [COLPCT.COUNT f40.0] 
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=area ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /CATEGORIES VARIABLES=$assets5 ORDER=A KEY=VALUE EMPTY=INCLUDE total=no position = before
  /TITLES  TITLE='Table 1. Household assets 5 years ago'
           CAPTION='Source: IASES 2022'.
  .


RECODE L2A$20 
    (0 = 0)
    (1 thru 4= 1)
    (5 thru high = 2)
    INTO trad_bulbs.

RECODE L2A$21 
    (0 = 0)
    (1 thru 4= 1)
    (5 thru high = 2)
    INTO led_bulbs.

RECODE L2A$22 
    (0 = 0)
    (1 thru 4= 1)
    (5 thru high = 2)
    INTO other_bulbs.

VARIABLE LABELS 
  trad_bulbs 'Traditional light bulbs'
  led_bulbs 'LED Light Bulbs'
  other_bulbs 'Light bulbs, tubes - other types'
  .

VALUE LABELS trad_bulbs led_bulbs other_bulbs
    0 '0'
    1 '1-4'
    2 '5 and more'
    . 
    
* Mangler edu_hh_gr1 som den under har.
CTABLES
  /VLABELS VARIABLES= headsex_gr1 HighEduc_Gr1 $HHOccupStatus NatExpQuint area region
                       trad_bulbs led_bulbs other_bulbs l2c$20 l2c$21 l2c$22 DISPLAY=LABEL
  /TABLE headsex_gr1 + $HHOccupStatus + NatExpQuint + area + region
    BY  trad_bulbs [ROWPCT.COUNT f40.0] + l2c$20  [ROWPCT.COUNT f40.0] + 
          led_bulbs [ROWPCT.COUNT f40.0] + l2c$21 [ROWPCT.COUNT f40.0] + 
          other_bulbs [ROWPCT.COUNT f40.0] + l2c$22 [ROWPCT.COUNT f40.0]
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=area ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /CATEGORIES VARIABLES=headsex_gr1 ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /TITLES  TITLE='Table 3. Light bulbs'
           CAPTION='Source: IASES 2022'.
  .

CTABLES
  /VLABELS VARIABLES= headsex_gr1 edu_hh_gr1 HighEduc_Gr1 $HHOccupStatus NatExpQuint area region
                       trad_bulbs led_bulbs other_bulbs DISPLAY=LABEL
  /TABLE headsex_gr1 + edu_hh_gr1 + $HHOccupStatus + NatExpQuint + area + region
    BY  trad_bulbs [ROWPCT.COUNT f40.0] +  led_bulbs [ROWPCT.COUNT f40.0] + other_bulbs [ROWPCT.COUNT f40.0] 
  /SLABELS VISIBLE=NO
  /CATEGORIES VARIABLES=area ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /CATEGORIES VARIABLES=headsex_gr1 ORDER=A KEY=VALUE EMPTY=INCLUDE total=yes position = before
  /TITLES  TITLE='Table 3. Light bulbs'
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

