
/*******************************************
 * Reusable SQL Scripts
 *******************************************/
/*******************************************
 * U - user table
 * P - stored procedure
 * PK - primary key
 * S - system table
 * IT - internal table
 * V - view
 *******************************************/
SELECT * FROM sysobjects AS s WHERE s.xtype = 'PK'

SELECT * FROM sys.tables AS t

SELECT * FROM sys.procedures AS p

SELECT * FROM INFORMATION_SCHEMA.TABLES AS t

SELECT * FROM INFORMATION_SCHEMA.[VIEWS] AS v

SELECT * FROM INFORMATION_SCHEMA.ROUTINES AS r -- procedures and functions

-- check for column
USE TSQLFundamentals2008

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] AS c 
		   WHERE c.COLUMN_NAME = 'orderid' 
		   AND c.TABLE_NAME = 'Orders' AND c.TABLE_SCHEMA = 'Sales')
BEGIN
	PRINT 'Column exists'
END			   
ELSE
BEGIN
	PRINT 'Column doesn''t 	exists'
END

/*******************************************
 * Alter table columns without drop table
 *******************************************/
 ALTER TABLE TSQLFundamentals2008.Sales.MyCustomers
 ALTER COLUMN custid INT 