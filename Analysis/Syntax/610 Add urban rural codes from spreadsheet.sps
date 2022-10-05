﻿* Encoding: UTF-8.
DATASET CLOSE all.
GET FILE='Data\TZHHLEVEL_1.sav'.

SORT CASES by GeocodeEA.
MATCH FILES file=*
           /TABLE='cat/ea_urbrur.sav'
           /in=from_cat
           /by GeocodeEA.

FREQUENCIES from_cat UrbRur urb1rur2.

TEMPORARY.
SELECT IF (from_cat = 0).
FREQUENCIES GeocodeEA.

CROSSTABS UrbRur by urb1rur2.

CTABLES
  /VLABELS VARIABLES=Region B11 B10 UrbRur Urb1Rur2 DISPLAY=LABEL
  /TABLE Region [COUNT F40.0] + B11 [COUNT F40.0] + B10 [COUNT F40.0] BY UrbRur + Urb1Rur2
  /CATEGORIES VARIABLES=Region UrbRur ORDER=A KEY=VALUE EMPTY=INCLUDE TOTAL=YES POSITION=BEFORE
  /CATEGORIES VARIABLES=B11 B10 ORDER=A KEY=VALUE EMPTY=INCLUDE
  /CATEGORIES VARIABLES=Urb1Rur2 ORDER=A KEY=VALUE EMPTY=EXCLUDE
  /CRITERIA CILEVEL=95.
