* Encoding: UTF-8.
*To be done only once (already done during the cleaning of the community questionnaire) .
*Read the XLS GIS attribute table, create a folder catalogue and store a SPSS version of the Geocodes in the GIS attribute table.
GET DATA
  /TYPE=XLSX
  /FILE='Cat\EA ID CATALOGUE NBS IASES 2021.xlsx'
  /SHEET=name 'Ark2'
  /CELLRANGE=RANGE 'M4:M310'
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.

SELECT IF (missing(IASES2021) = 0).
STRING GeocodeEA (a14).
COMPUTE GeocodeEA = STRING(IASES2021,n14).
EXECUTE.
DELETE VARIABLES IASES2021.
SORT CASES BY GeocodeEA.
SAVE OUTFILE='Cat\ea.sav'.

