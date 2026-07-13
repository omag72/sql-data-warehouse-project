/*
================================================================================
STORED PROCEDURE: bronze.load_bronze
================================================================================
PURPOSE:
    Loads raw data from CSV source files into the Bronze layer (raw data layer) 
    of the data warehouse. This procedure truncates existing bronze tables and 
    performs bulk inserts from both CRM and ERP source systems.

PARAMETERS:
    None - This procedure does not accept any input parameters.

RETURN VALUES:
    None - This procedure does not return any values. Progress and timing 
    information are printed to the SQL Server message output.

USAGE:
    EXEC bronze.load_bronze;

TABLES LOADED:
    CRM Sources:
    - bronze.crm_cust_info (Customer information)
    - bronze.crm_prd_info (Product information)
    - bronze.crm_sales_details (Sales details)

    ERP Sources:
    - bronze.erp_cust_az12 (Customer data)
    - bronze.erp_loc_a101 (Location data)
    - bronze.erp_px_cat_g1v2 (Product category data)

NOTES:
    - All source file paths are hard-coded and may require adjustment for 
      different environments
    - Execution time for each load is tracked and printed
    - One record is manually inserted into bronze.erp_cust_az12 as a data fix
    - Error handling included with TRY-CATCH block

================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME,@batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT'##############################################################################';
        PRINT'Loading the bronze Layer';
        PRINT '#############################################################################';

        PRINT '-------------------------------------------------------------------------------------';
        PRINT 'Loading the crm tables';
        PRINT '-------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT 'Truncating table bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT 'Inserting into table bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\pc\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)

        SET @start_time = GETDATE();
        PRINT 'Truncating table bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT 'Inserting into table bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\pc\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\pc\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

        PRINT '-------------------------------------------------------------------------------------';
        PRINT 'Loading the erm tables';
        PRINT '-------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT 'Inserting into table bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\pc\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        INSERT INTO bronze.erp_cust_az12 (cid, bdate, gen)
        VALUES ('AW00029483', '1965-06-06', NULL);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\pc\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\pc\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        SET @batch_end_time = GETDATE();
        PRINT '>> Total Duration in loading the bronze layer is ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'seconds';
      END TRY
      BEGIN CATCH
               PRINT '##############################################################'
               PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
               PRINT 'Error Message' + ERROR_MESSAGE();
               PRINT '#############################################################'
      END CATCH
   END
