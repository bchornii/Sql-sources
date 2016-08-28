/*
 * DIRTY READ EXAMPLE
 */
-- transaction 1 (dirty read)
-- 555-9999
--SELECT * FROM TSQLFundamentals2008.HR.Employees AS e WHERE e.empid = 1

USE TSQLFundamentals2008
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN TRAN
UPDATE TSQLFundamentals2008.HR.Employees
SET phone = '555-8888'
WHERE empid = 1

-- bill customer
WAITFOR DELAY '00:00:15'

ROLLBACK TRAN

/*
 * UPDATE LOST EXAMPLE 10248	11
 */
 
SELECT * FROM Sales.OrderDetails AS od 
WHERE od.orderid = 10248 AND od.productid = 11 

UPDATE TSQLFundamentals2008.Sales.orderdetails
SET qty = 12
WHERE orderid = 10248 AND productid = 11

-- Transaction 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRAN 
DECLARE @qty INT;

SELECT @qty = od.qty
FROM TSQLFundamentals2008.Sales.OrderDetails AS od
WHERE od.orderid = 10248 AND od.productid = 11

WAITFOR DELAY '00:00:10'
SET @qty = @qty - 1

UPDATE TSQLFundamentals2008.Sales.orderdetails
SET qty = @qty
WHERE orderid = 10248 AND productid = 11

PRINT @qty
COMMIT TRAN

/*******************************************
 * Non repeatable read
 *******************************************/
 USE TSQLFundamentals2008

  -- Transaction 1
 SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
 -- SET TRANSACTION ISOLATION LEVEL READ COMMITTED
 BEGIN TRAN
 
 SELECT od.qty FROM Sales.OrderDetails AS od 
 WHERE od.orderid = 10248 AND od.productid = 11
 
 WAITFOR DELAY '00:00:10'
 
 SELECT od.qty FROM Sales.OrderDetails AS od 
 WHERE od.orderid = 10248 AND od.productid = 11
 
 COMMIT TRAN
 
 /*******************************************
  * Phantom read problem
  *******************************************/
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
  BEGIN TRAN
  SELECT * FROM TSQLFundamentals2008.sales.Shippers AS s
  
  WAITFOR DELAY '00:00:10'
  
  SELECT * FROM TSQLFundamentals2008.sales.Shippers AS s
  
  COMMIT TRAN
  
  /*******************************************
   * Snapshot isolation level
   *******************************************/
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
  
  BEGIN TRAN
  UPDATE TSQLFundamentals2008.Sales.orderdetails
  SET qty = 14
  WHERE orderid = 10248 AND productid = 11
  
  COMMIT TRAN  
  
  SELECT qty
  FROM TSQLFundamentals2008.Sales.OrderDetails AS od
  WHERE od.orderid = 10248 AND od.productid = 11
  
  /*******************************************
   * Практикум - робота з взаємоблокуванням
   *******************************************/
   -- в транзакції всі монопольні блокування втримуються до
   -- кінця транзакції
  USE TSQLFundamentals2008
  
  BEGIN TRAN 
  
  UPDATE TSQLFundamentals2008.HR.Employees
  SET postalcode = N'10004'
  WHERE empid = 1
  
  COMMIT TRAN
  
  -- Очистка
  UPDATE TSQLFundamentals2008.HR.Employees
  SET postalcode = N'10004'
  WHERE empid = 1
  
  /*******************************************
   * Несумісність монопольної і shared блокувань
   *******************************************/
  USE TSQLFundamentals2008
  
  BEGIN TRAN 
  
  UPDATE TSQLFundamentals2008.HR.Employees
  SET postalcode = N'10005'
  WHERE empid = 1
  
  COMMIT TRAN
  
  -- Очистка
  UPDATE TSQLFundamentals2008.HR.Employees
  SET postalcode = N'10004'
  WHERE empid = 1