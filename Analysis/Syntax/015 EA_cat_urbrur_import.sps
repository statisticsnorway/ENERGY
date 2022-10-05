* Encoding: UTF-8.

DATASET CLOSE all.
GET DATA
  /TYPE=XLSX
  /FILE='Cat\Region1_26_EA Household Weights2022May26.xlsx'
  /SHEET=name 'Ark1'
  /CELLRANGE=RANGE 'A23:R357'
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.

FREQUENCIES Urb1Rur2.
TEMPORARY.
SELECT IF (sysmis(Urb1Rur2) = 1 and v9 ne '').
List v9 Urb1Rur2 region_n households.

SELECT IF (sysmis(Urb1Rur2) = 0).
EXECUTE.

DELETE VARIABLES region_n to hamlet EA_geocode households v10 to v18.
EXECUTE.

RENAME VARIABLES v9 = GeocodeEA.

ALTER TYPE GeocodeEA (a14).

SORT CASES by GeocodeEA.

MATCH FILES FILE=*
           /BY GeocodeEA
           /first=f_ea 
           /last=l_ea 
.
FREQUENCIES f_ea l_ea.

DELETE VARIABLES f_ea l_ea.

SAVE OUTFILE='cat/ea_urbrur.sav'.
