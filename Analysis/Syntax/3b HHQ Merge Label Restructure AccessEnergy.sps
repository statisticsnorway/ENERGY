* Encoding: UTF-8.


Encoding: UTF-8.

CD 'S:\Organisasjon\A200\S216\D Betalte oppdrag\Energy\C Methodological development\SPSS\2021_22 SPSS Tanzania'.
GET FILE='tmp\TZHHCOM_2b.sav'.
SET DECIMAL=DOT.
WEIGHT OFF.
*create tmp number of persons in the household..
COMPUTE tmpHHsize = 0.
FORMATS tmpHHsize (F2.0).
VECTOR person = AB3$01 TO AB3$20.
LOOP #i = 1 TO 20.
  IF ( person (#i) GT 0) tmpHHsize = SUM(tmpHHsize + 1).
END LOOP.
EXECUTE.
FREQUENCIES tmpHHSize.

*CREATE EA WEIGHTS.
COMPUTE WEIGHT=0.
IF(GeocodeEA= "01012711101008"        ) WEIGHT=         2.00.
IF(GeocodeEA= "01060511103004"        ) WEIGHT=         2.29.
IF(GeocodeEA="01011111101001"         ) WEIGHT=         2.18.
IF(GeocodeEA="01030711103005"         ) WEIGHT=         2.09.
IF(GeocodeEA="01041911101017"         ) WEIGHT=         2.29.
IF(GeocodeEA="01071111102001"         ) WEIGHT=         2.29.
IF(GeocodeEA="01022311102003"         ) WEIGHT=         2.00.
IF(GeocodeEA="01051231103007"         ) WEIGHT=         2.09.
IF(GeocodeEA="01020531102313"         ) WEIGHT=         0.83.
IF(GeocodeEA="01050321104002"         ) WEIGHT=         0.80.
IF(GeocodeEA="01052821106006"         ) WEIGHT=         1.03.
IF(GeocodeEA="01052921101006"         ) WEIGHT=         1.03.
                                                         
IF(GeocodeEA="02040311101004"         ) WEIGHT=         2.01.
IF(GeocodeEA="02020111102005"         ) WEIGHT=         1.76.
IF(GeocodeEA="02040211104004"         ) WEIGHT=         1.76.
IF(GeocodeEA="02060731101007"         ) WEIGHT=         1.76.
IF(GeocodeEA="02010711101003"         ) WEIGHT=         2.64.
IF(GeocodeEA="02051311102014"         ) WEIGHT=         2.01.
IF(GeocodeEA="02020331101301"         ) WEIGHT=         1.14.
IF(GeocodeEA="02030621104006"         ) WEIGHT=         1.09.
IF(GeocodeEA="02031121105003"         ) WEIGHT=         1.19.
IF(GeocodeEA="02031621101001"         ) WEIGHT=         1.39.
IF(GeocodeEA="02040131103316"         ) WEIGHT=         1.39.
                                                         
IF(GeocodeEA="03010411102001"         ) WEIGHT=         2.19.
IF(GeocodeEA="03012111102001"         ) WEIGHT=         3.20.
IF(GeocodeEA="03031911101003"         ) WEIGHT=         2.98.
IF(GeocodeEA="03041011102003"         ) WEIGHT=         2.98.
IF(GeocodeEA="03042511107005"         ) WEIGHT=         3.20.
IF(GeocodeEA="03050711102003"         ) WEIGHT=         2.78.
IF(GeocodeEA="03031631103002"         ) WEIGHT=         1.98.
IF(GeocodeEA="03020221109002"         ) WEIGHT=         1.33.
IF(GeocodeEA="03032431102317"         ) WEIGHT=         1.10.
IF(GeocodeEA="03060321102001"         ) WEIGHT=         1.43.
IF(GeocodeEA="03061121102001"         ) WEIGHT=         1.33.
IF(GeocodeEA="03051021111001"         ) WEIGHT=         1.86.
                                                         
IF(GeocodeEA="04013711101001"         ) WEIGHT=         2.05. 
*IF(GeocodeEA="04011371101001"         ) WEIGHT=         2.05.
IF(GeocodeEA="04011611105006"         ) WEIGHT=         1.79.
*IF(GeocodeEA="04011161105006"         ) WEIGHT=         1.79.
IF(GeocodeEA="04020631109005"         ) WEIGHT=         2.39.
IF(GeocodeEA="04032711103001"         ) WEIGHT=         2.15.
IF(GeocodeEA="04070311101003"         ) WEIGHT=         2.69.
IF(GeocodeEA="04011811106002"         ) WEIGHT=         1.79.
IF(GeocodeEA="04032011106001"         ) WEIGHT=         2.39.
IF(GeocodeEA="04062011104002"         ) WEIGHT=         2.15.
IF(GeocodeEA="04101021105002"         ) WEIGHT=         1.45.
IF(GeocodeEA="04040321107001"         ) WEIGHT=         1.18.
IF(GeocodeEA="04041021112001"         ) WEIGHT=         1.05.
IF(GeocodeEA="04041921106001"         ) WEIGHT=         0.99.
IF(GeocodeEA="04101021102002"         ) WEIGHT=         1.18.
                                                         
IF(GeocodeEA="05060131106004"         ) WEIGHT=         1.88.
IF(GeocodeEA="05010511106010"         ) WEIGHT=         2.05.
IF(GeocodeEA="05030731103001"         ) WEIGHT=         1.96.
IF(GeocodeEA="05061511101009"         ) WEIGHT=         2.05.
IF(GeocodeEA="05020311103001"         ) WEIGHT=         1.96.
IF(GeocodeEA="05030131102018"         ) WEIGHT=         1.88.
IF(GeocodeEA="05041511101007"         ) WEIGHT=         2.05.
IF(GeocodeEA="05070711101005"         ) WEIGHT=         2.05.
IF(GeocodeEA="05060831101330"         ) WEIGHT=         1.27.
IF(GeocodeEA="05022231101313"         ) WEIGHT=         1.21.
IF(GeocodeEA="05050921108006"         ) WEIGHT=         1.34.
IF(GeocodeEA="05051221112002"         ) WEIGHT=         1.34.
IF(GeocodeEA="05011521101001"         ) WEIGHT=         1.34.
IF(GeocodeEA="05031631106301"         ) WEIGHT=         1.42.
                                                         
IF(GeocodeEA="06020731101002"         ) WEIGHT=         1.44.
IF(GeocodeEA="06011231103010"         ) WEIGHT=         1.57.
IF(GeocodeEA="06050611104002"         ) WEIGHT=         1.65.
IF(GeocodeEA="06012111102001"         ) WEIGHT=         1.57.
IF(GeocodeEA="06041211101003"         ) WEIGHT=         1.38.
IF(GeocodeEA="06010621101002"         ) WEIGHT=         0.89.
IF(GeocodeEA="06030131101302"         ) WEIGHT=         0.94.
IF(GeocodeEA="06041131104303"         ) WEIGHT=         0.84.
IF(GeocodeEA="06070221102005"         ) WEIGHT=         0.84.
IF(GeocodeEA="06070721103002"         ) WEIGHT=         0.89.
                                                         
IF(GeocodeEA="07010221103084"         ) WEIGHT=         2.27.
IF(GeocodeEA="07010621105030"         ) WEIGHT=         2.38.
IF(GeocodeEA="07011121101011"         ) WEIGHT=         2.16.
IF(GeocodeEA="07011521102063"         ) WEIGHT=         2.27.
                                                         
IF(GeocodeEA="07012221105004"         ) WEIGHT=         2.07.
IF(GeocodeEA="07012521105024"         ) WEIGHT=         3.40.
IF(GeocodeEA="07012821107039"         ) WEIGHT=         2.65.
IF(GeocodeEA="07013421101010"         ) WEIGHT=         2.38.
                                                         
IF(GeocodeEA="07020821102024"         ) WEIGHT=         2.65.
IF(GeocodeEA="07021021104013"         ) WEIGHT=         2.38.
IF(GeocodeEA="07021921104008"         ) WEIGHT=         2.65.
IF(GeocodeEA="07022321102055"         ) WEIGHT=         2.38.
IF(GeocodeEA="07022621104064"         ) WEIGHT=         2.65.
IF(GeocodeEA="07030821105004"         ) WEIGHT=         2.65.
IF(GeocodeEA="07031021107008"         ) WEIGHT=         2.38.
IF(GeocodeEA="07031521103006"         ) WEIGHT=         2.80.
IF(GeocodeEA="07031921102007"         ) WEIGHT=         2.65.
IF(GeocodeEA="07032221103041"         ) WEIGHT=         2.38.
IF(GeocodeEA="07032721103007"         ) WEIGHT=         2.51.
IF(GeocodeEA="07032821106062"         ) WEIGHT=         2.65.
IF(GeocodeEA="07010321104023"         ) WEIGHT=         2.27.
                                                         
IF(GeocodeEA="08030711105004"         ) WEIGHT=         1.39.
IF(GeocodeEA="08011311103005"         ) WEIGHT=         1.70.
IF(GeocodeEA="08022711105002"         ) WEIGHT=         1.33.
IF(GeocodeEA="08052011103003"         ) WEIGHT=         1.91.
IF(GeocodeEA="08023011104004"         ) WEIGHT=         2.19.
IF(GeocodeEA="08041111101004"         ) WEIGHT=         1.39.
IF(GeocodeEA="08012021106002"         ) WEIGHT=         0.78.
IF(GeocodeEA="08060421103002"         ) WEIGHT=         0.61.
IF(GeocodeEA="08061521103006"         ) WEIGHT=         0.78.
                                                         
IF(GeocodeEA="09032011106003"         ) WEIGHT=         1.73.
IF(GeocodeEA="09012211102001"         ) WEIGHT=         2.23.
IF(GeocodeEA="09030831102010"         ) WEIGHT=         1.73.
IF(GeocodeEA="09061111102004"         ) WEIGHT=         1.73.     
IF(GeocodeEA="09020311105003"         ) WEIGHT=         2.11.
IF(GeocodeEA="09031911109002"         ) WEIGHT=         1.73.
IF(GeocodeEA="09060431105001"         ) WEIGHT=         1.73.
IF(GeocodeEA="09030831107318"         ) WEIGHT=         0.94.
IF(GeocodeEA="09050321101001"         ) WEIGHT=         0.90.
IF(GeocodeEA="09060131104309"         ) WEIGHT=         1.16.
IF(GeocodeEA="09060431107303"         ) WEIGHT=         0.90.
                                                         
IF(GeocodeEA="10032411103002"         ) WEIGHT=         1.73.
IF(GeocodeEA="10031511101003"         ) WEIGHT=         1.81.
IF(GeocodeEA="10011911104001"         ) WEIGHT=         2.24.
IF(GeocodeEA="10030211101008"         ) WEIGHT=         2.00.
IF(GeocodeEA="10050131102002"         ) WEIGHT=         1.73.
IF(GeocodeEA="10060711102003"         ) WEIGHT=         1.81.
IF(GeocodeEA="10013431102303"         ) WEIGHT=         1.43.
IF(GeocodeEA="10040421101003"         ) WEIGHT=         0.93.     
IF(GeocodeEA="10041221105001"         ) WEIGHT=         1.17.
IF(GeocodeEA="10041321106001"         ) WEIGHT=         0.98.
                                                         
IF(GeocodeEA="11021611103001"         ) WEIGHT=         1.91.
IF(GeocodeEA="11010311106007"         ) WEIGHT=         1.41.
IF(GeocodeEA="11021211104001"         ) WEIGHT=         1.91.
IF(GeocodeEA="11010611106001"         ) WEIGHT=         1.7.
IF(GeocodeEA="11042011101003"         ) WEIGHT=         1.80.
IF(GeocodeEA="11010831101301"         ) WEIGHT=         0.76.
IF(GeocodeEA="11030321103001"         ) WEIGHT=         0.66.
IF(GeocodeEA="11031021110003"         ) WEIGHT=         0.76.
IF(GeocodeEA="11050221104002"         ) WEIGHT=         0.66.
                                                         
IF(GeocodeEA="12040611103003"         ) WEIGHT=         1.94.
IF(GeocodeEA="12020811102003"         ) WEIGHT=         1.86.
IF(GeocodeEA="12040511105001"         ) WEIGHT=         1.86.
IF(GeocodeEA="12070711103007"         ) WEIGHT=         1.94.
IF(GeocodeEA="12020711102002"         ) WEIGHT=         1.94.
IF(GeocodeEA="12070431102007"         ) WEIGHT=         2.25.
IF(GeocodeEA="12032021111005"         ) WEIGHT=         1.37.
IF(GeocodeEA="12080621101005"         ) WEIGHT=         1.52.
IF(GeocodeEA="12081621102003"         ) WEIGHT=         1.44.
IF(GeocodeEA="12082521101008"         ) WEIGHT=         1.71.
IF(GeocodeEA="12083021105002"         ) WEIGHT=         1.52.
                                                         
IF(GeocodeEA="13021011102003"         ) WEIGHT=         1.64.
IF(GeocodeEA="13060111101001"         ) WEIGHT=         1.57.
IF(GeocodeEA="13032611101002"         ) WEIGHT=         1.51.
IF(GeocodeEA="13020511102005"         ) WEIGHT=         1.51.
IF(GeocodeEA="13040511101006"         ) WEIGHT=         1.57.
IF(GeocodeEA="13060111104002"         ) WEIGHT=         1.51.
IF(GeocodeEA="13030131102326"         ) WEIGHT=         0.54.
IF(GeocodeEA="13041421101001"         ) WEIGHT=         0.54.
IF(GeocodeEA="13050331105306"         ) WEIGHT=         0.54.
                                                         
IF(GeocodeEA="14021311103002"         ) WEIGHT=         1.82.
IF(GeocodeEA="14071011102001"         ) WEIGHT=         1.91.
IF(GeocodeEA="14030711103001"         ) WEIGHT=         1.68.
IF(GeocodeEA="14070311104005"         ) WEIGHT=         1.61.
IF(GeocodeEA="14012511101003"         ) WEIGHT=         1.91.
IF(GeocodeEA="14021711104011"         ) WEIGHT=         1.82.
IF(GeocodeEA="14031711102022"         ) WEIGHT=         1.91.
IF(GeocodeEA="14070611102013"         ) WEIGHT=         1.68.
IF(GeocodeEA="14021631102310"         ) WEIGHT=         0.63.
IF(GeocodeEA="14060321106005"         ) WEIGHT=         0.63.
IF(GeocodeEA="14060821104013"         ) WEIGHT=         0.50.
IF(GeocodeEA="14040231101312"         ) WEIGHT=         0.48.
                                                         
IF(GeocodeEA="15020511105008"         ) WEIGHT=         1.33.
IF(GeocodeEA="15010431105001"         ) WEIGHT=         1.33.
IF(GeocodeEA="15020231106001"         ) WEIGHT=         1.39.
IF(GeocodeEA="15021111106002"         ) WEIGHT=         1.39.
IF(GeocodeEA="15040711102006"         ) WEIGHT=         1.33.
IF(GeocodeEA="15031621112001"         ) WEIGHT=         0.56.
IF(GeocodeEA="15040421108003"         ) WEIGHT=         0.65.
IF(GeocodeEA="15041421109011"         ) WEIGHT=         0.78.
IF(GeocodeEA="15031621135001"         ) WEIGHT=         0.65.
                                                         
IF(GeocodeEA="16011311103010"         ) WEIGHT=         2.11.
IF(GeocodeEA="16051111101009"         ) WEIGHT=         2.46.
IF(GeocodeEA="16071111103001"         ) WEIGHT=         2.11.
IF(GeocodeEA="16050811101004"         ) WEIGHT=         2.01.
IF(GeocodeEA="16020211102006"         ) WEIGHT=         2.3.
IF(GeocodeEA="16050411102002"         ) WEIGHT=         1.77.
IF(GeocodeEA="16070311102003"         ) WEIGHT=         2.01.
IF(GeocodeEA="16031131103003"         ) WEIGHT=         0.80.
IF(GeocodeEA="16041321102002"         ) WEIGHT=         0.80.
IF(GeocodeEA="16041921102003"         ) WEIGHT=         1.61.
IF(GeocodeEA="16011031103309"         ) WEIGHT=         0.67.
                                                         
IF(GeocodeEA="17031111103009"         ) WEIGHT=         2.14.
IF(GeocodeEA="17010431102005"         ) WEIGHT=         1.91.
IF(GeocodeEA="17041011104002"         ) WEIGHT=         1.73.
IF(GeocodeEA="17021511101001"         ) WEIGHT=         2.60.
IF(GeocodeEA="17040531102004"         ) WEIGHT=         1.58.
IF(GeocodeEA="17043431104002"         ) WEIGHT=         1.52.
IF(GeocodeEA="17010321103016"         ) WEIGHT=         0.52.
IF(GeocodeEA="17011521105006"         ) WEIGHT=         0.60.
IF(GeocodeEA="17041631104313"         ) WEIGHT=         0.54.
IF(GeocodeEA="17051321104014"         ) WEIGHT=         0.60.
                                                         
IF(GeocodeEA="18010311102003"         ) WEIGHT=         2.07.
IF(GeocodeEA="18040811103002"         ) WEIGHT=         2.17.
IF(GeocodeEA="18010831102009"         ) WEIGHT=         1.98.
IF(GeocodeEA="18021611102006"         ) WEIGHT=         2.17.
IF(GeocodeEA="18032211103011"         ) WEIGHT=         2.07.
IF(GeocodeEA="18040331102009"         ) WEIGHT=         2.07.
IF(GeocodeEA="18071211105006"         ) WEIGHT=         2.17.
IF(GeocodeEA="18010631101002"         ) WEIGHT=         1.98.
IF(GeocodeEA="18032411104001"         ) WEIGHT=         2.07.
IF(GeocodeEA="18050611102010"         ) WEIGHT=         1.98.
IF(GeocodeEA="18033431101307"         ) WEIGHT=         0.71.
IF(GeocodeEA="18060321103003"         ) WEIGHT=         0.76.
IF(GeocodeEA="18060821101018"         ) WEIGHT=         0.61.
IF(GeocodeEA="18070431101321"         ) WEIGHT=         0.61.
                                                         
IF(GeocodeEA="19020131101006"         ) WEIGHT=         2.01.
IF(GeocodeEA="19071411101005"         ) WEIGHT=         2.01.
IF(GeocodeEA="19040211101001"         ) WEIGHT=         2.20.
IF(GeocodeEA="19051111103005"         ) WEIGHT=         2.10.
IF(GeocodeEA="19070411103002"         ) WEIGHT=         2.10.
IF(GeocodeEA="19040111104004"         ) WEIGHT=         2.01.
IF(GeocodeEA="19052611101019"         ) WEIGHT=         2.44.
IF(GeocodeEA="19010221105002"         ) WEIGHT=         1.22.
IF(GeocodeEA="19030321106009"         ) WEIGHT=         1.45.
IF(GeocodeEA="19030821108004"         ) WEIGHT=         1.16.
IF(GeocodeEA="19031221106001"         ) WEIGHT=         1.22.
IF(GeocodeEA="19060221107002"         ) WEIGHT=         1.22.
IF(GeocodeEA="19060521105006"         ) WEIGHT=         1.22.
IF(GeocodeEA="19071031103310"         ) WEIGHT=         1.22.
                                                         
IF(GeocodeEA="20041011102002"         ) WEIGHT=         1.54.
IF(GeocodeEA="20011011104005"         ) WEIGHT=         2.05.
IF(GeocodeEA="20022111101003"         ) WEIGHT=         2.05.
IF(GeocodeEA="20041511103001"         ) WEIGHT=         2.17.
IF(GeocodeEA="20061611105003"         ) WEIGHT=         9.22.
IF(GeocodeEA="20011011102003"         ) WEIGHT=         1.94.
IF(GeocodeEA="20070511101004"         ) WEIGHT=         2.84.
IF(GeocodeEA="20012321101002"         ) WEIGHT=         0.68.
IF(GeocodeEA="20042531101303"         ) WEIGHT=         0.72.
IF(GeocodeEA="20050821101009"         ) WEIGHT=         0.76.
IF(GeocodeEA="20050621104014"         ) WEIGHT=         0.65.
                                                         
IF(GeocodeEA="21022511101001"         ) WEIGHT=         1.41.
IF(GeocodeEA="21010211102002"         ) WEIGHT=         1.61.
IF(GeocodeEA="21020911104008"         ) WEIGHT=         1.69.
IF(GeocodeEA="21041311101002"         ) WEIGHT=         1.53.
IF(GeocodeEA="21011711105002"         ) WEIGHT=         1.47.
IF(GeocodeEA="21031911101001"         ) WEIGHT=         2.25.
IF(GeocodeEA="21050811101001"         ) WEIGHT=         1.69.
IF(GeocodeEA="21051431102301"         ) WEIGHT=         0.87.
IF(GeocodeEA="21030721101005"         ) WEIGHT=         0.78.
IF(GeocodeEA="21060331103302"         ) WEIGHT=         0.78.
                                                         
IF(GeocodeEA="22020431106001"         ) WEIGHT=         0.93.
IF(GeocodeEA="22040731102003"         ) WEIGHT=         0.88.
IF(GeocodeEA="22020911101009"         ) WEIGHT=         1.03.
IF(GeocodeEA="22032011101006"         ) WEIGHT=         1.03.
IF(GeocodeEA="22011111101003"         ) WEIGHT=         0.81.
IF(GeocodeEA="22031611104003"         ) WEIGHT=         0.88.
IF(GeocodeEA="22050811101004"         ) WEIGHT=         0.88.
IF(GeocodeEA="22010121109006"         ) WEIGHT=         0.59.
IF(GeocodeEA="22030231105311"         ) WEIGHT=         0.59.
IF(GeocodeEA="22060221101009"         ) WEIGHT=         0.77.
IF(GeocodeEA="22040811102303"         ) WEIGHT=         0.53.
                                                         
IF(GeocodeEA="23020211108002"         ) WEIGHT=         0.43.
IF(GeocodeEA="23020711102006"         ) WEIGHT=         0.45.
IF(GeocodeEA="23031531101001"         ) WEIGHT=         0.47.
IF(GeocodeEA="23031211102001"         ) WEIGHT=         0.55.
IF(GeocodeEA="23031911102005"         ) WEIGHT=         0.43.
IF(GeocodeEA="23030211103002"         ) WEIGHT=         0.45.
IF(GeocodeEA="23032211101008"         ) WEIGHT=         0.47.
IF(GeocodeEA="23010421102019"         ) WEIGHT=         0.31.
IF(GeocodeEA="23010621104003"         ) WEIGHT=         0.33.
IF(GeocodeEA="23010821102001"         ) WEIGHT=         0.38.
IF(GeocodeEA="23020831101313"         ) WEIGHT=         0.33.
IF(GeocodeEA="23010721103005"         ) WEIGHT=         0.30.
                                                         
IF(GeocodeEA="24031911101008"         ) WEIGHT=         1.98.
IF(GeocodeEA="24011111102005"         ) WEIGHT=         1.88.
IF(GeocodeEA="24041611101003"         ) WEIGHT=         1.49.
IF(GeocodeEA="24011211103003"         ) WEIGHT=         1.88.
IF(GeocodeEA="24022011105001"         ) WEIGHT=         1.78.
IF(GeocodeEA="24042211103001"         ) WEIGHT=         1.43.
IF(GeocodeEA="24050631104314"         ) WEIGHT=         0.30.
IF(GeocodeEA="24030131103311"         ) WEIGHT=         0.22.
IF(GeocodeEA="24042631102309"         ) WEIGHT=         0.30.
                                                         
IF(GeocodeEA="25010611107003"         ) WEIGHT=         2.23.
IF(GeocodeEA="25040611105001"         ) WEIGHT=         1.74.
IF(GeocodeEA="25052131101003"         ) WEIGHT=         1.74.
IF(GeocodeEA="25010611103002"         ) WEIGHT=         1.49.
IF(GeocodeEA="25012611103001"         ) WEIGHT=         1.67.
IF(GeocodeEA="25021111104002"         ) WEIGHT=         1.91.
IF(GeocodeEA="25052131106306"         ) WEIGHT=         0.57.
IF(GeocodeEA="25012831102321"         ) WEIGHT=         0.60.
IF(GeocodeEA="25013521114008"         ) WEIGHT=         0.50.
IF(GeocodeEA="25013521128002"         ) WEIGHT=         0.57.
                                                         
IF(GeocodeEA="26060111101008"         ) WEIGHT=         1.53.
IF(GeocodeEA="26060511102002"         ) WEIGHT=         1.60.
IF(GeocodeEA="26060111107002"         ) WEIGHT=         1.77.
IF(GeocodeEA="26060911106010"         ) WEIGHT=         1.53.
IF(GeocodeEA="26090311107004"         ) WEIGHT=         1.53.
IF(GeocodeEA="26061821125001"         ) WEIGHT=         0.87.
IF(GeocodeEA="26100121122001"         ) WEIGHT=         0.99.
IF(GeocodeEA="26061531101375"         ) WEIGHT=         0.78.
IF(GeocodeEA="26100121111003"         ) WEIGHT=         0.82.
IF(GeocodeEA="26100121128003"         ) WEIGHT=         0.78.


*Compute Weights at person level.
COMPUTE POPWEIGHT = WEIGHT * tmpHHsize.

FREQ WEIGHT POPWEIGHT.
*Check the input file..
FREQUENCIES Region.
************************************************************************************************************************.
*Basic energy variables.
*Household-connection to electricity.
*Household-connection to electricity.
COMPUTE HHELGRIDCON=C2.
VARIABLE LABELS HHELGRIDCON ‘HH CONNECTION TO ELECTRIC GRID’.
VALUE LABELS HHELGRIDCON 1 'YES' 2 "NO" .

*SDG Access = HH connection to electricity based on clean fuel.
COMPUTE HHSDG7ACCESS=0.
IF (C10 EQ 1 OR C10 EQ 3 OR C10 EQ 5) HHSDG7ACCESS=1.

IF (C10 EQ 6 AND (C120 EQ 1 OR C120 EQ 2 OR C120 EQ 4)) HHSDG7ACCESS=1.
VARIABLE LABEL HHSDG7ACCESS ‘SDG7 ACCESS SUSTAINABLE ENERGY’.
VALUE LABELS HHSDG7ACCESS 0 'NO' 1 "YES" .


*Cooking ovens by type of fuel.
COMPUTE HHCOOKINGFUEL=0.
IF (I10 GE 101 AND I10 LE 142) HHCOOKINGFUEL=1.
IF ((I10 GE 201 AND I10 LE 231) OR (I10 EQ 241)) HHCOOKINGFUEL=2.
IF (I10 EQ 233) HHCOOKINGFUEL=3.
IF (I10 EQ 331 OR I10 EQ 332 OR I10 EQ 341) HHCOOKINGFUEL=4.
IF (I10 GE 451 AND I10 LE 471) HHCOOKINGFUEL=5.
VARIABLE LABEL HHCOOKINGFUEL ‘MAIN FUEL FOR COOKING’.
VALUE LABELS HHCOOKINGFUEL 1 "FIREWOOD" 2 "CHARCOAL" 3 "KEROSENE" 4 "PELLETS" 5 "BIO GAS EL SOLAR".

FREQ HHELGRIDCON HHSDG7ACCESS HHCOOKINGFUEL.

*1) CREATE ENERGY TIERS . 
*EL TIER CALCULATIONS FROM HOUSEHOLDINFORMATION.
*First background check of how many.
*B13	Numeric	2	0	Main source energy lighting	{1, Electricity (TANESCO)}...
*B14	Numeric	2	0	Main source enegy cooking	{1, Electricity (TANESCO)}...

*C2	Numeric	Do you have a grid connection?	{1, Yes}...
*C3	Numeric	Is this the national grid or a local grid?	{1, National grid}...
*C4	Numeric	Do you have any devices or power supply using solar power?	{1, Yes}...
*C5	String	What kind of solar power supply do you have?	{a, Solar home system (SHS) with a separate battery}...
*C6	Numeric	Do you use an electric generator?	{1, Yes}...
*C7	Numeric	Do you use pico-hydro power?	{1, Yes}...
*C8	Numeric	Do you use rechargeable battery (not linked to a solar device)?	{1, Yes}...
*C9	Numeric	Do you use dry cell batteries?	{1, Yes}...
*C10	Numeric	Which of these power sources is your main electrical power source?	{1, Grid}...

*AEGCAPW – AEGridCapacityW - Peak Capacity -Power capacity ratings in W.
*Variables to use:.
*B13	Numeric	Main source energy lighting	{1, Electricity (TANESCO)}.
*B14	Numeric	Main source enegy cooking	{1, Electricity (TANESCO)}.
*C2	Numeric	Do you have a grid connection?	{1, Yes}.
*C10	Numeric	Which of these power sources is your main electrical power source?	{1, Grid}.

COMPUTE AEGCAPW = 0.
*if electricity from grid set capacity to 2000W.
*If no info in C10, main source may also come from info on main source for lightning or cooking being grid connection or from info on grid connection in C2.
IF (C10=1 OR C2=1 OR B13=1 OR B14=1) AEGCAPW =2000.

*define the tiers for grid electricity.
RECODE AEGCAPW (2000 THRU HI=5) (ELSE=0) INTO AETGCAPW.

VARIABLE LABELS AEGCAPW 'AE Grid Capacity in W'.
VARIABLE LABELS AETGCAPW 'AE Tier Grid Capacity in W'.

FREQ AEGCAPW AETGCAPW.

*AESOLAR - AESolarCapacity – A solar system requires both a solar cell panel and a battery/batterypack. 
*The capacity is made by the minimum factor, hence peak capacity can only be calculated at tier level.

*AESOLW – AesolarCellCapacityW - Peak Capacity - Power capacity ratings in W.
*Variables to use:.
*C10           Numeric  Which of these power sources is your main electrical power source?	{1, Grid}...
*C54	Numeric  Do you share this solar home system with other households?	{1, Yes}...
*C55	Numeric  How many households share this solar home system?
*C56	Numeric  Power rating solar panel	{888, Don't know}...

* If household do not know how many hhs that share the solar home system, set it to 2.
COMPUTE TMPC54=C54.
COMPUTE TMPC55=C55.
COMPUTE TMPC56=C56.
IF (SYSMIS(TMPC55)=1) TMPC55=2.

COMPUTE AESOLW=0.
IF (TMPC55=888888) TMPC55=2.
*if solar home system is used only by one household, and the power rating is within range:. 
IF (C10=3 AND TMPC54=2 AND (TMPC56 GE 20 AND TMPC56 LE 900)) AESOLW =TMPC56.
*If power rating is unknown set it to the minimum of solar panels for solar home systems sold today being 60W.
IF (TMPC56=888888) TMPC56=60.
*if solar home system is used only by more household, and the power rating is within range Divide the power rating by number of households that share it.
IF (C10=3 AND TMPC54=1 AND (TMPC56 GE 20 AND TMPC56 LE 900)) AESOLW = TMPC56/TMPC55.
*On average a solar cell panel will provide energy for 5 hours a day.
COMPUTE AESOLWH = AESOLW * 5.
*define the tiers for solar panels.
RECODE AESOLW (3 THRU 49=1) (50 THRU 199=2) (200 THRU 799=3) (800 THRU 1999=4) (2000 THRU HI=5) (ELSE=0) INTO AETSOLW.

VARIABLE LABELS AESOLW 'AE Solar Panel Capacity in W'.
VARIABLE LABELS AETSOLW 'AE Tier Solar Panel Capacity in W'.

FREQ AESOLW AETSOLW.

*AESOBWH	AEsolarBatteryCapacityWh - Peak Capacity - Power cap. ratings in Ah or Wh.
*Variables to use:.
*C10           Numeric  Which of these power sources is your main electrical power source?	{1, Grid}...
*C57	Numeric  Capacity battery	{888, Don't know}...
*C58	Numeric  What is the voltage (V) of the rechargeable batteries?	{88, Don't know}...
*C59	Numeric  What is the watt hours  (Wh) stated on the batteries?.
*C124	Numeric voltage	{88, Don't know}...

*Check.
FREQUENCIES C10 C57 C58 C59.
COMPUTE TMPC57 = C57.
COMPUTE TMPC58 = C58.
COMPUTE TMPC59 = C59.
COMPUTE TMPC124 = C124.

IF (TMPC57 = 888) TMPC57=20.
IF (TMPC58 = 88) TMPC58=12.

COMPUTE AESOBWH=0.
*if Ah and V both are unknown set Ah to the smallest possible value, 20.
IF (TMPC57 = 88 AND TMPC58 = 88) TMPC57=20.
IF (C10= 3 AND TMPC57 GE 20 AND TMPC57 LE 900 AND TMPC57 NE 88 AND TMPC58 GE 6 AND TMPC58 LE 24) AESOBWH = TMPC57 * TMPC58 * 0.75.
*If hh has solar home system as main source, Ah is within range, Volt is within range and Ah not unknown, then AESOBWH is Ah*V*75%. 
IF (C10= 3 AND ((TMPC57 LT 20 OR TMPC57 GT 900) OR (TMPC58 LT 6 OR TMPC58 GT 24)) AND TMPC59 NE 88) AESOBWH = TMPC59 * 0.75.
*If hh has solar home system as main source, Ah or V are unknown, but Wh is within range, then AESOBWH is Wh*75%.
IF (C10= 6 AND TMPC124 GE 6 AND TMPC124 LE 24) AESOBWH = TMPC124 * 0.75.
*define the tiers for batteries.
RECODE AESOBWH (12 THRU 199=1) (200 THRU 999=2)
(1000 THRU 3399=3) (3400 THRU 8199=4) (8200 THRU HI=5) (ELSE=0) INTO AETSOBWH.

VARIABLE LABELS AESOBWH 'AE Solar Battery Capacity in Wh'.
VARIABLE LABELS AETSOBWH 'AE Tier Solar Battery Capacity in Wh'.

FREQ AESOBWH AETSOBWH.

*AESOLAR - AESolarCapacity – Capacity across the solar cell panel and battery/batterypack can not be compared directly, hence peak capacity can only be calculated at tier level. 
COMPUTE AETSOLAR=MIN (AETSOLW, AETSOBWH).
VARIABLE LABELS AETSOLAR 'AE Tier Solar Cell and Battery Capacity'.

FREQ AETSOLAR AETSOLW AETSOBWH.

*AEAGGW – AEaggregateCapacityW - Peak Capacity - Power capacity ratings in W.
*Variables to use.
*C10           Numeric  Which of these power sources is your main electrical power source?	{1, Grid}...
*C89	Numeric	1	0	Share generator other households	{1, Yes}...
*C90	Numeric	2	0	Number of households sharing generator	{88, Don't know}...
*C91	Numeric	5	0	Generator capacity	{88888, Don't know}...

*Check.
FREQUENCIES C10 C89 C90 C91.
*Note: In Tanzania - Only one household with generator on the file and capacoty is given as 220V and it is not shared with others, the capacity has a typo and should be replaced with common minimum of 3000.

COMPUTE TMPC90 = C90.
COMPUTE TMPC91 = C91.

COMPUTE AEAGGW=0.
*If don’t know how many are sharing we set this to 2 since it is usually too demanding to share with more than 2.
IF (C90 = 888888) TMPC90=2.
*If aggregate not shared, set number to 1 even if missing.
IF (C89=1) TMPC90=1.
IF (TMPC91=220) TMPC91=3000.
*If hh’s main source is an aggregate that is used only by this household and capacity is within W range, use AEAGGW for the calculation.
IF (C10= 4 AND C89 EQ 2 AND TMPC91 GE 500 AND TMPC91 LE 50000) AEAGGW = TMPC91.
*If hh’s main source is aggregate that is shared with other and capacity is within W range, use AEAGGW for the calculation divided by the number of users.
IF (C10= 4 AND C89 EQ 1 AND TMPC91 GE 500 AND TMPC91 LE 50000) AEAGGW = TMPC91/TMPC90.
*Define the tiers for aggregate.
RECODE AEAGGW (3 THRU 49=1) (50 THRU 199=2) (200 THRU 799=3) (800 THRU 1999=4) (2000 THRU HI=5) (ELSE=0) INTO AETAGGW.

VARIABLE LABELS AEAGGW 'AE Aggregate Capacity in W'.
VARIABLE LABELS AETAGGW 'AE Tier Aggregate Capacity in W'.

FREQ AEAGGW AETAGGW.
 
*AEBATWH - AEbatteryCapacityWh - Peak Capacity - Power capacity ratings in Wh.

*Rechargeable battery - not connected to solar.
*Variables to use.
*C10	Numeric	Which of these power sources is your main electrical power source? {1, Grid}...
*C123	Numeric	6	2	Capacity	None (Amp)
*C124	Numeric	2	0	Voltage	{88, Don't know}...
*C125	Numeric 4 0 What is the Watt hours  (Wh) stated on the battery? {8888, Don't know}...

*Check.
FREQUENCIES C10 C123 C124 C125.

*COMPUTE AEBATWH=0.

*if dont'know set C123-124-125 to within acceptable range.
COMPUTE TMPC123=C123.
COMPUTE TMPC124=C124.
COMPUTE TMPC125=C125.

*if Ampere and AEBATWH are unknown set Ah to 20 which is the lowest commercial value.
IF (TMPC123 = 88) TMPC123=20.

*If V is unknown set it to 12, since this is the standard value.
IF (TMPC124 = 88) TMPC124=12.

IF ( TMPC125=8888 OR TMPC125=888) TMPC125=200.

*If main source is battery or if aggregate is main and battery main back up, Ah is within range and not unknown, and V is within range, then calculate capacity by using Ah and V
IF (C10= 6 AND TMPC123 GE 20 AND TMPC123 LE 500 AND TMPC123 NE 88 AND TMPC124 GE 6 AND TMPC124 LE 24) AEBATWH = TMPC123 * TMPC125 * 0.75.

*Calc if capacity Wh is known and range OK (200 to 6000)..
IF( C10=6 AND SYSMIS(TMPC125)=0 ) AEBATWH = TMPC125 * 0.75.
*Alternative calc if still sysmis AEBATWH and V and Amp is known and range OK.
IF( C10=6 AND SYSMIS(AEBATWH)=1 AND SYSMIS(TMPC123)=0 AND SYSMIS(TMPC124)=0 )  AEBATWH= TMPC123 * TMPC124 * 0.75. 
*Alternative calc if still sysmis AEBATWH and V is missing and and Amp is known and range OK.
IF( C10=6 AND SYSMIS(AEBATWH)=1 AND SYSMIS(TMPC123)=0 AND SYSMIS(TMPC124)=1 )  AEBATWH= TMPC123 * 12 * 0.75. 
IF (C10= 4 AND C11=6 AND TMPC123 GE 20 AND TMPC123 LE 500 AND TMPC123 NE 88 AND TMPC124 GE 6 AND TMPC124 LE 24) AEBATWH = TMPC123 * C125 * 0.75.
IF (C10= 4 AND C11=6 AND TMPC123 GE 20 AND TMPC123 LE 500 AND TMPC123 NE 88 AND (TMPC124 LE 6 OR TMPC124 GT 24)) AEBATWH = TMPC123 * 12 * 0.75.
IF (C10= 4 AND C11=6 AND (TMPC123 LT 20 OR TMPC123 GT 500) AND (TMPC125 GE 200 AND TMPC125 LE 6000) AND TMPC125 NE 88 AND (TMPC124 LT 6 OR TMPC124 GE 24)) AEBATWH = TMPC125 * 0.75.

*Define the tiers for battery.
RECODE AEBATWH(12 THRU 199=1) (200 THRU 999=2) (1000 THRU 3399=3) (3400 THRU 8199=4) (8200 THRU HI=5) (ELSE=0) INTO AETBATWH.

VARIABLE LABELS AEBATWH 'AE Battery Capacity in Wh'.
VARIABLE LABELS AETBATWH 'AE Tier Battery Capacity in Wh'.

FREQ AEBATWH AETBATWH.

*AESOLLH - AEsolarLanternCapacityLmh - Peak Capacity - Power capacity ratings in Lmh.
*Solar multilight + solar lantern.
*Variables to use.
*C10
*C76	Numeric 2 0 How many hours was service available from this [DEVICE] each evening, from 6:00 pm to 10:00 pm, during last seven days?
*C81	Numeric 2 0 Number light bulbs	None
*Check.
FREQUENCIES C76 C81.

COMPUTE AESOLLH=0.
IF ((C10=7 OR C10 =8) AND (C76 GE 1 AND C76 LE 4) AND C81 GE 1) AESOLLH= 150 * C76 * C81.
RECODE AESOLLH (1000 THRU HI=1) (ELSE=0) INTO AETSOLLH.

VARIABLE LABELS AESOLLH 'AE Solar Lantern Capacity in Lh'.
VARIABLE LABELS AETSOLLH 'AE Tier Solar Lantern Capacity in Lh'.

FREQ AESOLLH AETSOLLH.

*AESERW – AeservicecapacityW - Peak Capacity – Summary requirements of appliances.
*An alternative way to calculate electric capacity is to summarize the required capacity for the actual appliances owned by the household This would allow to choose the highest tier across sources and appliances.

COMPUTE AESERW=0.

*MobileCharge.
COMPUTE TMPL2$07 = 0.
IF ( (L2$07 = 7 AND L2A$07 = 1) OR (L2$08 = 7 AND L2A$08 = 1)  OR  (L2$22 = 7 AND L2A$22 GT 0)   ) TMPL2$07 = 1. 
*Elradio.
COMPUTE TMPL2$08 = 0.
IF (L2$08 = 8 AND L2A$08 = 1) TMPL2$08 = 1.
*Fan.
COMPUTE TMPL2$09 = 0.
IF (L2$09 = 9 AND L2A$09 = 1) TMPL2$09 = 1.
*Refrigerator.
COMPUTE TMPL2$10 = 0.
IF ( (L2$10 = 10 AND L2A$10 = 1) OR (L2$22 = 10 AND L2A$22 GT 0) OR (L2$19 = 10 AND L2A$19 = 1)  ) TMPL2$10 = 1.
*MicroW.
COMPUTE TMPL2$11 = 0.
IF (L2$11 = 11 AND L2A$11 = 1) TMPL2$11= 1.
*Freez.
COMPUTE TMPL2$12 = 0.
IF ( (L2$12 = 12 AND L2A$12 = 1) OR  (L2$14 = 12 AND L2A$14 = 1) ) TMPL2$12 = 1.
*Washmachine.
COMPUTE TMPL2$13 = 0.
IF (L2$13 = 13 AND L2A$13 = 1) TMPL2$13 = 1.
*Sewingmachine el.
COMPUTE TMPL2$14 = 0.
IF (L2$14 = 14 AND L2A$14 = 1) TMPL2$14 = 1.
*AC.
COMPUTE TMPL2$15 = 0.
IF (L2$15 = 15 AND L2A$15 = 1) TMPL2$15 = 1.
*PC.
COMPUTE TMPL2$16=0.
IF (L2$16 = 16 AND L2A$16 = 1) TMPL2$16 = 1.
*PotEl.
COMPUTE TMPL2$17 = 0.
IF ( (L2$17 = 17 AND L2A$17 = 1) OR (L2$19 = 17 AND L2A$19 = 1) ) TMPL2$17 = 1. 
*TV.
COMPUTE TMPL2$18 = 0.
IF ( (L2$18 = 18 AND L2A$18 = 1) OR (L2$19 = 18 AND L2A$19 = 1) OR (L2$20 = 18 AND L2A$20 GT 0)   ) TMPL2$18 = 1. 
*WaterpumpEl.
COMPUTE TMPL2$19 = 0.
IF (L2$19 = 19 AND L2A$19 = 1) TMPL2$19 = 1.
*Traditional light bulbs..
COMPUTE TMPL2$20 = 0.
IF (  (TMPL2$20 = 20 AND L2A$20 > 0)  OR (L2$21 = 20 AND L2A$21 GT 0) ) TMPL2$20 = 1. 
*LED light bulbs.
COMPUTE TMPL2$21 = 0.
IF ( (L2$21 = 21 AND L2A$21 GT 0) OR (L2$22 = 21 AND L2A$22 GT 0) )  TMPL2$21 = 1. 
*ElSaving bulbs.
COMPUTE TMPL2$22 = 0.
IF (L2$22 = 22 AND L2A$22 GT 0) TMPL2$22 = 1.

*If hh has mobile charger and/or an electric radio.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$07 EQ 1 OR TMPL2$08 EQ 1)) AESERW= 49.

*If hh has 3 or more traditional light bulbs and/or 3 or more LED light bulbs and/or 3 or more any light bulbs and/or a fan and/or computer and/or tv.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$09 EQ 1 OR TMPL2$16 EQ 1 OR TMPL2$18 EQ 1)) AESERW= 199.

IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$20 GE 3 OR TMPL2$21 GE 3 OR TMPL2$22 GE 3)) AESERW= 199.

*If hh has fridge and/or freezer and/or electric water pump.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$10 EQ 1 OR TMPL2$12 EQ 1 OR TMPL2$19 EQ 1)) AESERW= 799.

*If hh has microwave oven and/or washing machine.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$11 EQ 1 OR TMPL2$13 EQ 1)) AESERW= 1999.
*If hh has air conditioner.
IF (C10 GE 1 AND C10 LE 9 AND (TMPL2$15 EQ 1)) AESERW= 2000.

*Define tiers based on appliances.
RECODE AESERW (0=0) (1 THRU 49=1) (50 THRU 199=2) (200 THRU 799=3) (800 THRU 1999=4) (2000 THRU HI=5) (ELSE=0) INTO AETSERW.

VARIABLE LABELS AESERW 'AE Service Capacity in W'.
VARIABLE LABELS AETSERW 'AE Tier Service Capacity in W'.

FREQ AESERW AETSERW.

*AECAPW - AECapacityW - Peak Capacity across the means of access to electricity EL1.

FREQUENCIES AEGCAPW AESOLW AESOLWh AESOBWh AEAGGW  AEBATWH AESOLLH AESERW.

*Create final Acess to energy capacity tier.
*COMPUTE AETCAPACITY = 0.

*Tier5 Acess to energy calc.
IF ( AEGCAPW GE 2000 OR  AESOLWh GE 2000 OR AESOBWh GE 2000 OR AEAGGW GE 2000 OR 
    AEBATWh GE 2000 OR AESOLLH GE 2000 OR AESERW GE 2000) 
    AETCAPACITY = 5.
*Check.
FREQUENCIES AETCAPACITY.

*Tier4 Acess to energy calc.
IF ( SYSMIS(AETCAPACITY)=1 AND
      ( (AESOLWh  GE 800 AND AESOLWh LT 2000) OR 
      (AESOBWh GE 800 AND AESOBWh LT 2000) OR 
      (AEAGGW   GE 800 AND AEAGGW LT 2000)  OR 
      (AEBATWh GE 800 AND AEBATWh LT 2000) OR 
      (AESOLLH GE 800 AND AESOLLH LT 2000) OR
      (AESERW GE 800 AND AESERW LT 2000) ) ) AETCAPACITY = 4.
*Check.
FREQUENCIES AETCAPACITY.

*Tier3 Acess to energy calc.
IF ( SYSMIS(AETCAPACITY)=1 AND
      ( (AESOLWh  GE 200 AND AESOLWh LT 800) OR 
      (AESOBWh GE 200 AND AESOBWh LT 800) OR 
      (AEAGGW   GE 200 AND AEAGGW LT 800)  OR 
      (AEBATWh GE 200 AND AEBATWh LT 800) OR 
      (AESOLLH GE 200 AND AESOLLH LT 800) OR
      (AESERW GE 200 AND AESERW LT 800) ) ) AETCAPACITY = 3.
*Check.
FREQUENCIES AETCAPACITY.

*Tier2 Acess to energy calc.
IF ( SYSMIS(AETCAPACITY)=1 AND
      ( (AESOLWh  GE 50 AND AESOLWh LT 200) OR 
      (AESOBWh GE 50 AND AESOBWh LT 200) OR 
      (AEAGGW   GE 50 AND AEAGGW LT 200)  OR 
       (AEBATWh GE 50 AND AEBATWh LT 200) OR 
      (AESOLLH GE 50 AND AESOLLH LT 200) OR
       (AESERW GE 50 AND AEBATWh LT 200) ) ) AETCAPACITY = 2.
*Check.
FREQUENCIES AETCAPACITY.
*Tier1 Acess to energy calc.
IF ( SYSMIS(AETCAPACITY)=1 AND
      ( (AESOLWh  GE 3 AND AESOLWh LT 50) OR 
      (AESOBWh GE 3 AND AESOBWh LT 50) OR 
      (AEAGGW   GE 3 AND AEAGGW LT 50)  OR 
      (AEBATWh GE 3 AND AEBATWh LT 50) OR 
      (AESOLLH GE 3 AND AESOLLH LT 50) OR
      (AESERW GE 3 AND AEBATWh LT 50) ) ) AETCAPACITY = 1.
*Check.
FREQUENCIES AETCAPACITY.

COMPUTE AETCAPW=0.
RECODE AETCAPACITY (1=1) (2=2) (3=3) (4=4) (5=5) INTO AETCAPW.

FREQ AETCAPW.
    
*Tier Acess to energy capacity..


VARIABLE LABELS AETCAPW “Peak Capacity across means of access”.

FREQUENCIES AETCAPW.

FREQUENCIES AETSOLW AETGCAPW AETSOLW AETSOBWh AETAGGW AETBATWh AETSOLLH AETSERW AETCAPW.

*Duration, Availability EL2. 

*Tier availability Day.
*variables neded.
*C38	Numeric	2	0	Hours of electricity day and night typical month	{88, Don't know}...
*C75	Numeric	2	0	How many hours did you receive service from this [DEVICE] each day and night, during the last seven days?	None.
*C105	Numeric	2	0	Hours of generator available	{88, Don't know}...
*C121	Numeric	2	0	hours of electricity per day	{88, Don't know}...

*AEDURDN - Availability during day and night – Duration – day EL2A.
COMPUTE AEDURDN=0.
COMPUTE AEDURDN=MAX (C38, C75, C105, 121).
DO IF C10=1.
   RECODE AEDURDN (2 THRU 3=1) (4 THRU 7=2) (8 THRU 15=3) (16 THRU 22=4) (23 THRU HI=5) (ELSE=0) INTO AETDURDN.
END IF.

VARIABLE LABELS AETDURDN “Availability during day and night”.

FREQUENCIES AETDURDN.

*AEDURN - Availability during night – Duration – night EL2B.

*Tier availability Night.
*variables needed.
*C39	Numeric	2	0	Hours of electricity 6 pm to 10 pm typical month	{88, Don't know}...
*C76	Numeric	2	0	How many hours was service available from this [DEVICE] each evening, from 6:00 pm to 10:00 pm, during last seven days?	None
*C106	Numeric	2	0	Hours of generator available evening	{88, Don't know}...
*C122	Numeric	2	0	how many hours ech evening	None.

COMPUTE AEDURN=0.
COMPUTE AEDURN=MAX (C39, C76, C106, C122).
DO IF C10=1.
   RECODE AEDURN (1=1) (2=2) (3=3) (4 THRU HI=5) (ELSE=0) INTO AETDURN.
END IF.

VARIABLE LABELS AETDURN “Availability during night”.

FREQUENCIES AETDURN.

*AETDUR - Availability – Duration – total and night EL2.
COMPUTE AETDUR=MIN (AETDURDN, AETDURN).
MISSING VALUES AEDURDN AEDURN AETDURDN AETDURN AETDUR (0).

VARIABLE LABELS AETDUR «AE Availability Duration Total & night”.

FREQ AEDURDN AEDURN AETDURDN AETDURN AETDUR.

*AEREL - Reliability EL3.
*variables needed.
*C10	Numeric 1 0 Which of these power sources is your main electrical power source?	{1, Grid}...
*C40	Numeric 2 0 Number of blackouts per week	{66, No outages/blackouts}...
*C41	Numeric 2 0 Total duration blackouts per week	{88, Don't know}...

*Check.
FREQUENCIES C40 C41. 

COMPUTE AEREL=0.
IF (C10=1) AEREL=3.
IF (C10=1 AND C40 GE 1 AND C40 LE 14) AEREL= 4.
IF (C10=1 AND (C40 GE 1 AND C40 LE 4 AND C41 EQ 1) OR C40 EQ 66) AEREL= 5.
COMPUTE AETREL=AEREL.
MISSING VALUES AEREL AETREL (0).

VARIABLE LABELS AEREL «AE Reliability”.
VARIABLE LABELS AETREL «AE Tier Reliability”.

FREQ AEREL AETREL.

*AEQUAL – Quality – EL4.

*Tier quality.
*C10	Numeric 1 0 Which of these power sources is your main electrical power source?	{1, Grid}...
*C45	Numeric 2 0 Appliences get damaged due to brown out	{1, Yes}...
*Check.
FREQUENCIES C45.

COMPUTE AEQUAL=0.
IF (C10=1 AND C45=1) AEQUAL=3.
IF (C10=1 AND (C45 = 2 OR C45=88)) AEQUAL=5.
COMPUTE AETQUAL=AEQUAL.
MISSING VALUES AEQUAL AETQUAL (0).

VARIABLE LABELS AEQUAL «AE Quality”.
VARIABLE LABELS AETQUAL «AE Tier Quality”.

FREQ AEQUAL AETQUAL.

*AEAFF – Affordability – EL5.
*Variables needed.
*C27	Numeric	1	0	Pre-paid meter	{1, Yes}...
*C33	Numeric	8	0	How much did you spend the last time you bought electricity?	None
*C35	Numeric	6	0	How many KWh did you pay for	None
*HHExpAll	Numeric 20 0 Total household annual expenditure (TZS)
*Check.
FREQUENCIES C27 C33 C35.

*Cost of 1kWh. 
*The average costs are calculated for all who remember or have noted the last payment to the prepaid meter and amount of power purchased.
IF (C10=1 AND C27 = 1 AND C33 NE 88 AND C35 NE 88 AND C33 NE 0 AND C35 NE 0 ) AEKWHCOSTS = C33 / C35.
*Check.
FREQUENCIES AEKWHCOSTS.
*Calc TZ mean cost pr kWh.
*MEANS TABLES = AEKWHCOSTS
    /CELLS=MEAN.
*FROM OUTPUT:WINDOW::
    *Mean = 343 TZ per kW purchased.
*The energy costs of 365 kWh per year is a national value, being 343 TZ * 365 = 125195 TZ.
COMPUTE AECONSUM = HHExpAll.
IF (C10 = 1) AEENERGYCOSTS = 343 * 365 * 100 /AECONSUM.
FREQUENCIES AEENERGYCOSTS. 

COMPUTE AEENERGYCOSTS=365*AEKWHCOSTS * 100/ AECONSUM.

COMPUTE AEAFF=0.
IF (C10=1 AND AEENERGYCOSTS LT 5) AEAFF = 5. 
*Per, why 3 and not 5?.
IF (C10=1 AND AEENERGYCOSTS GE 5) AEAFF = 2. 
IF (C10=1 AND AEENERGYCOSTS GT 0 AND AEENERGYCOSTS LE 5) AEAFF=5.
COMPUTE AETAFF = AEAFF. 
MISSING VALUES AEAFF AETAFF (0).

VARIABLE LABELS AEAFF «AE Affordability”.
VARIABLE LABELS AETAFF «AE Tier Affordability”.

FREQ AEKWHCOSTS AEENERGYCOSTS AECONSUM AEAFF AETAFF.

*AELEG - AELegality – EL6*.

*Variables used:
*C10	Numeric	1	0	Which of these power sources is your main electrical power source?	{1, Grid}...
*C27	Numeric	1	0	Pre-paid meter	{1, Yes}...
*C28	Numeric	2	0	Who receives payment	{1, Energy company}...
*Check.
FREQUENCIES C27 C28.

COMPUTE AELEG=0.
IF (C10=1) AELEG=3.
IF (C10 EQ 1 AND (C27 LE 1 OR ((C27 GE 1 AND C27 LE 10) OR C27 EQ 55))) AELEG=5.
COMPUTE AETLEG = AELEG. 
MISSING VALUES AELEG AETLEG (0).

VARIABLE LABELS AELEG «AE Legal”.
VARIABLE LABELS AETLEG «AE Tier Legal”.

FREQ AELEG AETLEG.


*AETHLTH - AETHealth – EL7.

*variables to use.
*C10	Numeric 1 0 Which of these power sources is your main electrical power source?	{1, Grid}...
*C48	Numeric 1 0 Any household members die or limb damage	{1, Yes}...
*C110	Numeric 1 0 Household members die or injury 12 months - generator	{1, Yes}...


COMPUTE AEHLTH=0.
IF (C10=1 AND C48=1) AEHLTH=3.
IF (C10=1 AND C48=2) AEHLTH=5.
IF (C10=4 AND C110=1) AEHLTH=3.
IF (C10=4 AND C110=2) AEHLTH=5.
COMPUTE AETHLTH=AEHLTH.
MISSING VALUES AEHLTH AETHLTH (0).

VARIABLE LABELS AEHLTH «AE Health”.
VARIABLE LABELS AETHLTH «AE Tier Health”.

FREQ AEHLTH AETHLTH.

*AETACCESS – AETAccess to electricity - Overall household Electricity access. 
*The tier level is determined by the lowest tier for which all applicable attributes are met. 
*Tier0 - Tier5 Minimum of EL1, EL2A, EL2B, EL3, EL4, EL5, EL6, EL7, EL8.
*For many households one or more of these variables are missing. The data-statement should only compare the non-missing variables.

*AETACCESS.
COMPUTE AETACCESS=0.
*COMPUTE AETACCESS=MIN (TierEl_Capacity, TierEl_Day, TierEl_Night, TierEl_Freq, TierEl_Duration, TierEl_Quality, TierEl_Afford, TierEl_Formal, TierEl_Health). 

*Check.
FREQUENCIES AETACCESS.

CTABLES
  /VLABELS VARIABLES=C2 C4 C5 C6 C7 C8 C9 C10 B13 AETACCESS
    DISPLAY=LABEL
  /TABLE C10 + C2 + C4 + C5 + C6 + C7 + C8 + C9 + B13
  BY 
  AETACCESS [COUNT F40.0]
  /CATEGORIES VARIABLES=C10 C2 C4 C5 C6 C7 C8 C9 B13 ORDER=A KEY=VALUE EMPTY=INCLUDE MISSING=INCLUDE 
  /CATEGORIES VARIABLES= AETACCESS ORDER=A KEY=VALUE EMPTY=INCLUDE MISSING=INCLUDE TOTAL=YES POSITION=BEFORE  
  /CRITERIA CILEVEL=95.

COMPUTE AETACCESS=MIN (AETCAPW, AETDUR, AETREL, AETQUAL, AETAFF, AETLEG, AETHLTH). 

FREQ AETACCESS AETCAPW AETDUR AETREL AETQUAL AETAFF AETLEG AETHLTH.

*Tier access to electricity in household.
*Access to electricity measured by the tier dimensions includes: Peak Capacity, Availability (Duration), Reliability, Quality, Affordability and future connection, Legality, Health and safety, and Overall tiers.
*Variables: AEGCAPW, AETGCAPW, AESOLWH, AESOLW, AETSOLW, AESOBWH, AETSOBWH, AETSOLAR, AEAGGW, AETAGGW, AEBATWH, AETBATWH, AESOLLH, 
    AETSOLLH, AESERW, AETSERW, AEGCAPW , AESOLAR, AEAGGW , AEBATWH, , AESOLLH, AETCAPW, AETGCAPWS , AETAGGW , AEDURDN, AETDURDN, AEDURN, AETDURN, AETDUR, 
    AETDURDN, AETDURN, AEREL , AETREL, AEQUAL , AETQUAL, AECONSUM, AEKWHCOSTS, AEAFF , AETAFF, AELEG , AETLEG, AEHLTH , AETHLTH, AETACCESS. 

FREQ AETGCAPW AETSOLW AETSOBWH AETSOLAR AETAGGW AETBATWH  AETSOLLH AETSERW AETCAPW AETGCAPW  AETAGGW  AETDURDN AETDURN AETDUR  AETDURDN AETDURN 
    AETREL AETQUAL AETAFF AETLEG AETHLTH AETACCESS.

WEIGHT WEIGHT.

FREQ AETGCAPW AETSOLW AETSOBWH AETSOLAR AETAGGW AETBATWH  AETSOLLH AETSERW AETCAPW AETGCAPW  AETAGGW  AETDURDN AETDURN AETDUR  AETDURDN AETDURN 
    AETREL AETQUAL AETAFF AETLEG AETHLTH AETACCESS.

WEIGHT POPWEIGHT.

FREQ AETGCAPW AETSOLW AETSOBWH AETSOLAR AETAGGW AETBATWH  AETSOLLH AETSERW AETCAPW AETGCAPW  AETAGGW  AETDURDN AETDURN AETDUR  AETDURDN
     AETDURN AETREL AETQUAL AETAFF AETLEG AETHLTH AETACCESS.

WEIGHT OFF.

FREQ HHSDG7ACCESS AETACCESS COMD3.

WEIGHT WEIGHT.
FREQ HHSDG7ACCESS AETACCESS COMD3.

WEIGHT POPWEIGHT.
FREQ HHSDG7ACCESS AETACCESS COMD3.

WEIGHT OFF. 

***********************************************************************************************************************************************************.
OUTPUT CLOSE ALL.
DATASET CLOSE ALL.

*Next module will be on Measuring Multi-tier Cooking Solutions.

EXECUTE. 

*****************************.
*END OF SYNTAX.
*****************************.

