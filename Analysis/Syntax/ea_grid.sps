* Encoding: UTF-8.
DATASET CLOSE all.
GET FILE='Data\moz_hhq_raw.sav'.
FREQUENCIES c2.

recode c2 
    (1 = 1)
    INTO c2y.

FREQUENCIES c2y.

AGGREGATE OUTFILE=* MODE=ADDVARIABLES
    /BREAK aa1 to aa6
    /ea_grid = max(c2y)
    .

FREQUENCIES ea_grid.

 
