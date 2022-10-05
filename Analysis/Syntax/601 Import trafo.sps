* Encoding: UTF-8.

DATASET CLOSE ALL.
GET DATA
  /TYPE=XLSX
  /FILE='Cat\snitt_tz_EA with el.xlsx'
  /SHEET=name 'snitt_tz_EA with el'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.
DELETE VARIABLES id to hamlet.
EXECUTE.
RENAME VARIABLES 
 (SN         = EL_SN)
 (RATING_KVA = EL_RATING_KVA)
 (NAME       = EL_NAME)
 (VOLTAGE_HI = EL_VOLTAGE_HI)
 (VOLTAGE_LO = EL_VOLTAGE_LO)
 (X          = EL_X)
 (Y          = EL_Y)
 (EA_Geocode = GeocodeEA)
.

SAVE OUTFILE='Cat\snitt_tz_EA with el.SAV'.

GET DATA
  /TYPE=XLSX
  /FILE='Cat\trafo_m_by_hhbuffer600.xlsx'
  /SHEET=name 'trafo_m_by_hhbuffer600'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.

RENAME VARIABLES 
 (SN         = TRAFO_SN)
 (RATING_KVA = TRAFO_RATING_KVA)
 (NAME       = TRAFO_NAME)
 (VOLTAGE_HI = TRAFO_VOLTAGE_HI)
 (VOLTAGE_LO = TRAFO_VOLTAGE_LO)
 (X          = TRAFO_X)
 (Y          = TRAFO_Y)
 (REC_ID     = TRAFO_REC_ID)
 (Xcoord     = TRAFO_Xcoord)
 (Ycoord     = TRAFO_Ycoord)
.

SORT CASES BY GeocodeHH TRAFO_VOLTAGE_LO.
MATCH FILES FILE=*
           /FIRST=f_trafo
           /LAST=l_trafo
           /BY GeocodeHH
           .
EXECUTE.

FREQUENCIES f_trafo l_trafo.
CROSSTABS f_trafo BY l_trafo.

SELECT IF (l_trafo = 1).
EXECUTE.
DELETE VARIABLES f_trafo l_trafo.

SAVE OUTFILE='Cat\trafo_m_by_hhbuffer600.SAV'.




