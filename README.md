# INFO6090_Ass2

### Database Setup Assignment 2

1. Execute the `Setup.sql` script
2. Using the 'Import Data' task load data from the 'EBUS3030_Assignment_Two_Data_2021.xlsx' using the following parameters:

   - Data Source: Microsoft Excel. Pick the file.
   - Destination: SQL Server Native Client 11.0; Server Name: your-server-name; Authentication: Windows Auth; Database: Assignment2
   - Copy data from one or more tables or views
   - Destination table name (double click on the cell to change it): [dbo].[SalesData]
   - Run immediately

3. Execute the `Populate.sql` script

# ~~INFO6090_Ass1~~

### ~~Database Setup Assignment 1~~

1. Execute the `Populate_v2.sql` script
2. Using 'Load data from flat file' task load data from the 'Assignment One 2021.csv'.
   Call the new table name to `SalesData`.
   On the 'Modify Columns' step allow all columns to accept NULL values; do not set private key.
3. Execute the `Setup_v2.sql` script

### ~~Queries~~

1. To get top performer by sales, number of orders handled and total items sold,
   execute the `Find_top_salesman_multiple_metrics.sql` script
