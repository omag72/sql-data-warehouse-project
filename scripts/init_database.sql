/*
#######################################################
CREATE Database and Schemas
######################################################
Script Purpose:
  This script creates a new database named 'DataWarehouse' after checking if it akready exists.
  If the database exists, it is dropped and recreated.Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'

  WARNING:
  Running this script will drop the entire 'DataWarehouse' database if it exists.All data in the database will be permanantly deleted.
  Proceed with caution and ensure you have the proper backups before running the script 
  */


USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

--Create the 'DataWarehouse' database
CREATE DATBASE DataWarehouse;
GO

USE DataWarehouse;
GO

--CREATE Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
