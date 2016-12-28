# ReportSC
The goal of this project is to increase transparency within the 
University of Southern California's Department of Public Safety by providing a means
for visualizing its reports and allow for independent bodies to perform statistical
analysis and report their findings for the benefit of the community.

Once downloaded and extracted, the executable can be found in the folder named "x64"
and a shortcut can be manually created by the user for easier access. 

Raw parsed reports can be found in the "dpsreports" folder while the datasets that the 
program reads from can be found in the "data" folder. The datasets are saved as .dps 
files. 

"MainDataset.dps" contains all the reports from the "dpsreports" folder and is what will
be the most up-to-date dataset. Should this file be corrupted or lost, there is a backup
"MainDataset.dps" found in the backup folder. 

You may also find key functions used in ReportSC in the bin file including parsing 
the raw dps text files, pulling the latest reports from the DPS website, and writing and
reading .dps files. 

---------------------------Using the GUI-------------------------------

Update button:
- The update button will pull the most recent reports from the dps website and update them to "MainDataset.dps." 
- ***It is important to check the spelling of new reports because the conversion from the oridinal .pdf to .txt is not perfect***

Load button:
- The load button will load a dataset file (.dps) and display the reports

Save button:
- The save button will save the current loaded dataset file in the case it has been edited

Export button:
- The export button will export the current search into a new dataset file

Generate Histogram button:
- The generate histogram button will generate a histogram based on a user chosen field with an optional filter being added using powershell regular expressions to only capture words that match. 
- Only the top 5 results will be displayed but for the full histogram the user must save the histogram

Add button:
- The add button will allow user to manually enter in a report in the case that the update function missed a report.

Search function:
- To search within a specified field use the format: "Field: Value"
- To search multiple values use the format: "Value1|Value2|Value3"
- To perform a search within another use the format: "Search1, Search2, Search3"
- The search function allows for powershell regular expressions