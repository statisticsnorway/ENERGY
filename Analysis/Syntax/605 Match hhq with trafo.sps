* Encoding: UTF-8.

DATASET CLOSE ALL.
GET FILE='Data/TZHHLEVEL_1.sav'.

MATCH FILES FILE=*
           /TABLE='Cat\trafo_m_by_hhbuffer600.SAV'
           /IN=from_trafo
           /BY GeocodeHH
           .
EXECUTE.
FREQUENCIES from_trafo.

CROSSTABS c2 BY from_trafo.
