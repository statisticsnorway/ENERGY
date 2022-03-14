* Encoding: UTF-8.
DATA LIST FILE='Data\listing.dat' RECORDS=1
 /
 LLOGIN      1-100  (A)
 LL1       101-102 
 LL2       103-104 
 LL3       105-107 
 LL4       108-109 
 LL5       110-111 
 LL6       112-114 
 LL8       115-117 
 LLUR      118-118 
 LL7       119-119 
 LL7A      120-129  (6)
 LL7B      130-140  (6)
 LL9       141-141 
 LL10      142-261  (A)
 LL11      262-381  (A)
 LL12      382-382 
.
VARIABLE LABELS
  LLOGIN   "Login"
 /LL1      "Region"
 /LL2      "District"
 /LL3      "Subdistrict"
 /LL4      "Locality"
 /LL5      "Village"
 /LL6      "Enumeration Area"
 /LL8      "Serial number"
 /LLUR     "Urban/rural"
 /LL7      "Import or record GPS coordinates"
 /LL7A     "North coordinate (Latitude)"
 /LL7B     "East coordinate (Longitude)"
 /LL9      "Presence of household"
 /LL10     "Name of head of household"
 /LL11     "Address/location"
 /LL12     "source of power"
.
VALUE LABELS
  LL7     
     1 "Record GPS coordinates"
     2 "Import GPS from previous questionnaire"
 /LL9     
     1 "Present"
     2 "Temporary away"
     3 "Seasonal away"
     4 "Vacated"
 /LL12    
     1 "Power grid"
     2 "No grid, but solar cells with battery or solar home system"
     3 "None of the above"
.
EXECUTE.

SAVE OUTFILE='tmp\ListTZ_1.sav'.

