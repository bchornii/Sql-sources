/*
 * DIRTY READ EXAMPLE
 */
-- transaction 2 (dirty read)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED 

SELECT * FROM TSQLFundamentals2008.HR.Employees AS e(NOLOCK) WHERE e.empid = 1


/*
 * UPDATE LOST EXAMPLE
 */
-- Transaction 2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRAN 
DECLARE @qty INT;

SELECT @qty = od.qty
FROM TSQLFundamentals2008.Sales.OrderDetails AS od
WHERE od.orderid = 10248 AND od.productid = 11

WAITFOR DELAY '00:00:1'
SET @qty = @qty - 2

UPDATE TSQLFundamentals2008.Sales.orderdetails
SET qty = @qty
WHERE orderid = 10248 AND productid = 11

PRINT @qty
COMMIT TRAN

/*******************************************
 * Non repeatable read
 *******************************************/
 -- Transaction 2
  
 UPDATE TSQLFundamentals2008.Sales.OrderDetails
 SET qty = 12
 WHERE orderid = 10248 AND productid = 11
 
 /*******************************************
  * Phantom read problem
  *******************************************/
  USE TSQLFundamentals2008
  GO
  
  SET IDENTITY_INSERT sales.shippers ON;
  INSERT INTO TSQLFundamentals2008.sales.Shippers(shipperid,companyname,phone)
  VALUES(4,'Shipper HFGOD','(325) 444-9789')
  SET IDENTITY_INSERT sales.shippers OFF;
  
  DELETE FROM TSQLFundamentals2008.Sales.Shippers
  WHERE shipperid = 4 OR shipperid = 6
  
  SELECT * FROM TSQLFundamentals2008.sales.Shippers AS s
  
  /*******************************************
   * Snapshot isolation level
   *******************************************/
   
  --ALTER DATABASE TSQLFundamentals2008
  --SET ALLOW_SNAPSHOT_ISOLATION ON
  
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE--SNAPSHOT--REPEATABLE READ
  
  BEGIN TRAN
  SELECT qty FROM TSQLFundamentals2008.Sales.OrderDetails AS od
  WHERE od.orderid = 10248 AND od.productid = 11
    
  COMMIT TRAN 
  
   /*******************************************
   * Практикум - робота з взаємоблокуванням
   *******************************************/
  USE TSQLFundamentals2008  

  UPDATE TSQLFundamentals2008.HR.Employees
  SET phone = N'555-9999'
  WHERE empid = 1   
  
  /*******************************************
   * Несумісність монопольної і shared блокувань
   *******************************************/
  USE TSQLFundamentals2008
  
  SELECT e.firstname,e.lastname
  FROM TSQLFundamentals2008.HR.Employees AS e
  