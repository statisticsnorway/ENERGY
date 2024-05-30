# Impact of Access to Sustainable Energy Survey (IASES 2021/22)
## Overview of repository
 - Community: The community questionnaire
 - HHQ: Household questionnaire
 - Images: All images used by the system: Example of cook stoves, and toilets as well as map markers
 - Listing: The listing questionnare
 - LookupFiles: files containing country specific variables like region hierarchy, 
 users/enumerators etc as well as cspro apps to generate the corresponing csdb databases
 - Maps: The maps with Enumeration Areas marked 
 - Menu: The menu appliacation
 - Sampling: the sampling dictionary
 
 ## Deployment
  - download and unzip the repository
  - prepare the lookup files countrySpecificVariables.xlsx, users.xlsx and Regions.xlsx
  - run the scripts to generate cspro database files for each of the lookup file. 
  (Open the resulting files to verify they're OK)
  - Open the file Menu/menu.pff in a text editor. If there is an area in the file starting 
   with "[Parameters]": Delete it and anything below
  - modify the deploy script and run it
  - The map files must be uploaded manually to the server, to the folder /ENERGY/maps
