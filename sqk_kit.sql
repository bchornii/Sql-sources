USE TSQLFundamentals2008;
GO

--SELECT o.custid, YEAR(o.orderdate) AS order_date
--FROM TSQLFundamentals2008.Sales.Orders AS o
--ORDER BY o.custid, YEAR(o.orderdate)


SELECT	 e.country
	   , YEAR(e.hiredate) AS hiredate
	   , COUNT(*) AS numemployees  		
	   , ROW_NUMBER() OVER (ORDER BY YEAR(e.hiredate)) AS rn
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE e.hiredate >= '20030101'
GROUP BY e.country, YEAR(e.hiredate)
HAVING COUNT(*) > 1
ORDER BY e.country, YEAR(e.hiredate)

DECLARE @d SMALLDATETIME;
DECLARE @date DATEtime = GETDATE()
SET @d = @date
SELECT @d

-- �������
SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0) -- ������ ���� ��������� �����

SELECT DATEADD(dd,-1,DATEADD(mm,DATEDIFF(mm,0,GETDATE()) + 1,0)) -- ������� ���� ��������� �����

-- ������ ����� � ������� � ������
DECLARE @names VARCHAR(100) = NULL;
SELECT @names = COALESCE(@names + ',','') + e.firstname --@names = @names + COALESCE(e.firstname + ',','')
FROM TSQLFundamentals2008.HR.Employees AS e;
SELECT @names

-- ������� ������ � �������� � ������
DECLARE @fullname VARCHAR(100) = 'Bohdan Chornii';
SELECT LEN(@fullname)
SELECT DATALENGTH(@fullname)
SELECT LEFT(@fullname, CHARINDEX(' ', @fullname) - 1)

SELECT EOMONTH(GETDATE())

SELECT DATEFROMPARTS(YEAR(GETDATE()),12,31)

-- add zero symbols before value
SELECT p.productid,
	   --ISNULL(REPLICATE('0', 10 - LEN(CAST(p.productid AS VARCHAR))),'') + CAST(p.productid AS VARCHAR)
	   --RIGHT(REPLICATE('0',10) + CAST(p.productid AS VARCHAR), 10)
	   FORMAT(p.productid, 'd10') 
FROM TSQLFundamentals2008.Production.Products AS p

-- Predicates
-- TRUE: when two operandes is not NULL and equal, ex. WA and WA
-- FALSE : where two operandes is not NULL and not equal, ex. OR and WA
-- UNKNOWN VALUE : where at least one operand is NULL or two operandes is NULLs (NULL = NULL -> unknown value) 
SELECT e.empid,e.firstname,e.lastname,e.country,e.region,e.city
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE e.region <> N'WA'

-- ������ ������ � ������ ������� ���� ����������� ���������� �� ������ � �������
-- ������ �� �� ��������� ��������� ����������� �������
DECLARE @dt DATE = NULL; --'20090101';
SELECT o.orderid,o.orderdate,o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.shippeddate = @dt OR (o.shippeddate IS NULL AND @dt IS NULL)

DECLARE @dt DATE = NULL; --'20090101';
SELECT o.orderid,o.orderdate,o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE COALESCE(o.shippeddate,'') = COALESCE(@dt,'')

-- Operation priority
-- 0.()
-- 1.NOT
-- 2.AND
-- 3.OR

-- ������������ ������� TRY_CAST ��� ������� NULL ���� �������� ����������� �������� - �����
-- ����� ����� �� ������� ������ ��� � �������� �� NULL ������ ���� ��� ���������� �������
-- ��� ��� �������� �� ����������� ��������� � WHERE clause �� ���������� ���� �������
-- �� ����� �� ������ - ���� ����������� ���������, ���� �� ����� ������������ �� �������� 
-- ���������� �������� vt.propertytype = 'INT' ��� �� ���������� �������� ��� 
DECLARE @values_table TABLE 
(
	propertytype VARCHAR(20),
	propertyval INT
)

INSERT INTO @values_table
VALUES('INT',20),('INT',30),
	  ('INT',40),(NULL,NULL)
	  
SELECT vt.propertytype,vt.propertyval
FROM @values_table vt
WHERE vt.propertytype = 'INT' AND TRY_CAST(vt.propertyval AS INT) > 10 --CAST(vt.propertytype AS INT) > 10	  

-- ���� ���������� ����� ���� "col1 LIKE 'ABC%'" ������ �� ���� ����������� ������ ��� ��������� �������
-- ���� ������ ���������� �� '%ABC%' ������ �� ���� ����������� �� ������������ �������
-- '20070212' = ymd
-- '2007-02-12' = ymd �� ������� �� ���� ��� DATE,DATETIME2,DATETIMEOFFSET

-- ������������ ���� � ����
SELECT o.orderid,o.orderdate,o.empid,o.custid 
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE YEAR(o.orderdate) = 2007 AND MONTH(o.orderdate) = 2;

-- ��� ������� ���������������� ���������� �� �������� �� ����� ���������� ���������� 
-- sql server �� ���� ����������� �� ������������� �� �������

SELECT o.orderid,o.orderdate,o.empid,o.custid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.orderdate >= '20070201' AND o.orderdate < '20070301'

-- ����� ��� ������ � ������ ����� ��������������� ��������� >= i < �� �������� BETWEEN ������� ��� �������� ���� ���������� ��������

-- ����������
-- ���� ��������������� DISTINCT � ����� ORDER BY � ������ � ���� � ����� - ������������ ���� ������� ������
-- ������� �� ���� ���������� ���������� + ���� �� ����
-- ���� ����� �� ������ DISTINCT ������������ ���� �� ����"������ ������� ������ ������ �� ���� ���������� ����������
-- ����. : ���� ����������� ����� ���� � �� ������ ������ ����� ������ ���������� � ���������� ���������� �� ���
-- ����������, ��� ���� ���� �� �������� � ������������ ���� �� ������ �� ��� ��� ���� ������ ������� � DISTINCT �������
-- ���� ���� �� ������� ���������� � ������ ����� ����������
SELECT DISTINCT e.city
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE e.country = N'USA' AND e.region = N'WA'
ORDER BY e.birthdate

-- ���������� ���� �����
SELECT DISTINCT e.city
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE e.country = N'USA' AND e.region = N'WA'
ORDER BY e.city

-- ���������� NULL �������
-- ���� shippeddate is null �� ����������� 0, ���� �� NULL �� 1 - ����� ����� 0 ���� ����� 1 � �������� NOT NULL ������ ��������
SELECT o.orderid, o.shippeddate
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 20
ORDER BY CASE WHEN o.shippeddate IS NULL 
			  THEN 1
			  ELSE 0 
         END, o.shippeddate 
         
-- �������������� ���������� - ���� � ������������� ����� ���� ������� �� ����� ����� ���������� � �� �� ������� ��������� �������          
-- ������������ ���������� - ������ ORDER BY ������� ���� ���������

-- Գ���������� ����� �� ��������� TOP i FETCH ... OFFSET
SELECT TOP(1) o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

SELECT TOP(1) PERCENT o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

-- WITH TIES ������� �������� ���������� �� orderdate ���� ��� �
SELECT TOP(1) WITH TIES o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

-- ��� ������ ��������� : ���� ��� ������ � ������ orderid �������
SELECT TOP(3) o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC,o.orderid DESC

-- FETCH ... OFFSET
-- ����� ORDER BY �� �� ��� : 1) ��������� fetch/offset �� ������ ������� �����������
--								 2) ����������� ���������� ������������� � �������
DECLARE @pagesize AS BIGINT = 25;
DECLARE @pagenum AS BIGINT = 1;
SELECT o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC,o.orderid DESC
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY

DECLARE @offset INT = 10;
SELECT o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC,o.orderid DESC
OFFSET @offset ROWS 

-- ������� ����� ������ ����� �������
SELECT TOP (5) p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC

-- ������� ��������� ����� �� ������������� - ������� �� �� ������� ������
SELECT TOP (5) WITH TIES
	   p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC

-- � ����� ������� ������������� �� ������� productid � ������� ��������
SELECT TOP (5) p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC, p.productid DESC

-- �������� ������ �� 5 ���� �� ���, � ����������� �� ��� � ������� �� productid
DECLARE @page_size INT = 5;
DECLARE @page_num INT = 1;

SELECT *
FROM TSQLFundamentals2008.Production.Products AS p
ORDER BY p.unitprice DESC, p.productid DESC
OFFSET (@page_num - 1) * @page_size ROWS FETCH NEXT @page_size ROWS ONLY

-- ������������ ������ �����
-- ���� ����� ��� �� ����� * 3 ���� �� ����
SELECT n1.n AS theday, n2.n AS shiftno
FROM TSQLFundamentals2008.Sales.Nums AS n1
CROSS JOIN TSQLFundamentals2008.Sales.Nums AS n2
WHERE n1.n <= 7 AND n2.n <= 3
ORDER BY theday,shiftno

-- ������� ������� ������� ����� � ������ �� ��������� �� ��������� � ON 
-- ���� �������� ������� FALSE ��� NULL �� ������ �����������
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid
WHERE s.country = N'Japan'

-- ������ �� ����������� ON i WHERE ��� �������� �"������ ���� ���� ����� �������� ��������� �����
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid AND 
															s.country = N'Japan'
															
-- �����"������� ��� ���� ��� ������ ��������� ��� ��������
SELECT e1.empid, 
	   e1.firstname + e1.lastname AS [emp name],
	   e2.firstname + e2.lastname AS [mng name]
FROM TSQLFundamentals2008.HR.Employees AS e1
INNER JOIN TSQLFundamentals2008.HR.Employees AS e2 ON e1.mgrid = e2.empid															

-- ������ �"������� ���������� ������ ��'����� �� ��������� + ������ � ��� ���� ������� � �������� ����� �������� �� NULL
-- � ����� ��� �'������� ON i WHERE ����� ��� ���
-- WHERE �� � ����� �� ���� ������� ���� ������ ������ FALSE i NULL
-- ON � ����� ������� �� � �������� ���� �������� - ��������� �����, ������ ������� ��� � ��� ������� ����������� �����
-- ���� � �������� ON ���� ��������
-- ���� � ���������� ����� ������� WHERE �� AND �� ������ ���������� � ���� �� �������� ��� ���������� (�� �� ��� �������)
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
LEFT JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid
WHERE s.country = N'Japan'

SELECT e1.empid, 
	   e1.firstname + e1.lastname AS [emp name],
	   e2.firstname + e2.lastname AS [mng name]
FROM TSQLFundamentals2008.HR.Employees AS e1
LEFT JOIN TSQLFundamentals2008.HR.Employees AS e2 ON e1.mgrid = e2.empid	

-- ���� �볺��� �� �� ����� ���������
SELECT c.custid,c.companyname,o.orderid,o.orderdate
FROM TSQLFundamentals2008.Sales.Customers AS c
LEFT JOIN TSQLFundamentals2008.Sales.Orders AS o ON c.custid = o.custid
WHERE o.orderid IS NULL

-- ������� ��� �볺��� ��� ������ ������� �� ���������� �� ���� ������� ����� � ������ 2008 
SELECT c.custid,c.companyname,o.orderid,o.orderdate
FROM TSQLFundamentals2008.Sales.Customers AS c
LEFT JOIN TSQLFundamentals2008.Sales.Orders AS o ON c.custid = o.custid AND
												    o.orderdate >= '20080201' AND 
												    o.orderdate < '20080301'

-- �������� �������
-- ������� ��������� �������� �� ����� �������� ���� � ����� �������
SELECT p.categoryid, p.productid,p.productname,p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.unitprice = (SELECT MIN(p2.unitprice) 
                     FROM TSQLFundamentals2008.Production.Products AS p2
                     WHERE p.categoryid = p2.categoryid )			
ORDER BY p.unitprice,p.categoryid 

-- ���������� �볺��� �� ��������� ��� ���������� 12 ������ 2007 ����
SELECT c.custid,c.companyname
FROM TSQLFundamentals2008.Sales.Customers AS c
WHERE EXISTS (SELECT * FROM TSQLFundamentals2008.Sales.Orders AS o 
					   WHERE o.custid = c.custid AND o.orderdate = '20070212')					   

-- ������� ������
-- ��������� ����� ������� ���� ����������, ���� �� ����� ������������� ORDER BY 
-- ����������� � ������������ ����������� ORDER BY � ������������� TOP/FETCH...OFFSET
-- ������� ������ �� ����� ������ �� �������������

-- p.s. ROW_NUMBER �� ���� ����� ������� �������� ����� � SELECT i ORDER BY
SELECT 
	ROW_NUMBER() OVER (PARTITION BY p.categoryid 
					   ORDER BY p.unitprice, 
								p.productid ASC) AS rn,
	p.categoryid,
	p.productid,
	p.productname,
	p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p

-- ��������� ����� ��� �������� � ���������� ������ � ����� ������� (������� ����������� �������)
-- ����� ����������� ������ : ������������� �����, ��� �� ������ ��������; �������� ��� ����� � ������������
SELECT 		
	d.categoryid,
	d.productid,
	d.productname,
	d.unitprice
FROM (	SELECT 
		ROW_NUMBER() OVER (PARTITION BY p.categoryid 
						   ORDER BY p.unitprice, 
									p.productid ASC) AS rn,
		p.categoryid,
		p.productid,
		p.productname,
		p.unitprice
		FROM TSQLFundamentals2008.Production.Products AS p) AS d
WHERE d.rn <= 2;	

-- ���������� ��������� ��������� (common table expression) CTE
-- ���� ������� ������� CTE ����� ������ �������� �� ������; ����� CTE ���� ����������
-- �� ���������, � ������� ����� ���� ���������� �� �� CTE
-- ����� ����� ���������� �� ������ ���������� CTE �� �� ������� ��� ����������� ������
-- FROM CTE1 AS C1 INNER JOIN CTE1 AS C2
;WITH cte as(
	SELECT ROW_NUMBER() OVER (PARTITION BY p.categoryid ORDER BY p.unitprice,p.productid) AS rn,
		   p.categoryid,
		   p.productid,
		   p.productname,
		   p.unitprice
	FROM TSQLFundamentals2008.Production.Products AS p	
)  
SELECT c.categoryid,c.productid,c.productname,c.unitprice
FROM cte AS c
WHERE c.rn <= 2;

-- CTE ������ ���� ������������ : ������� ������������ ���� ����������� ������ ����
-- ��������� �������� �������� ��������� ��� ��������
;WITH empCTE AS(
	SELECT e.empid, e.mgrid, e.firstname, e.lastname, 0 AS distance
	FROM TSQLFundamentals2008.HR.Employees AS e
	WHERE e.empid = 9
	
	UNION ALL
	
	SELECT e.empid,e.mgrid,e.firstname,e.lastname,ec.distance + 1 AS distance
	FROM empCTE AS ec
	INNER JOIN TSQLFundamentals2008.HR.Employees AS e ON ec.mgrid = e.empid
)
SELECT *
FROM empCTE AS ec

-- ����� �������� ��� �������� ���������
;WITH cte AS (
	SELECT e.empid, e.mgrid, e.lastname, e.firstname, 0 AS lvl
	FROM TSQLFundamentals2008.HR.Employees AS e
	WHERE e.empid = 1
	
	UNION ALL
	
	SELECT e.empid, e.mgrid, e.lastname, e.firstname, c.lvl + 1 AS lvl
	FROM TSQLFundamentals2008.HR.Employees AS e
	INNER JOIN cte AS c ON e.mgrid = c.empid
)
SELECT *
FROM cte AS c


-- ������������� (view) � ������ ������� �������
-- ������� ������ �� ���� �� �� ����� �� ������ �������� ������� ���������
-- USE TSQLFundamentals2008
-- GO
-- 
-- IF OBJECT_ID('Sales.RankedProducts','V') IS NOT NULL
-- DROP VIEW Sales.RankedProducts
-- 
-- GO
-- 
-- CREATE VIEW Sales.RankedProducts
-- AS
-- SELECT ROW_NUMBER() OVER (PARTITION BY p.categoryid ORDER BY p.unitprice,p.productid) AS rn,
-- 	   p.categoryid,
-- 	   p.productid,
-- 	   p.productname,
-- 	   p.unitprice
-- FROM TSQLFundamentals2008.Production.Products AS p
-- 
-- GO

SELECT *
FROM TSQLFundamentals2008.Sales.RankedProducts AS rp
WHERE rp.rn <= 2;

-- ��������� �������� ������� 
-- USE TSQLFundamentals2008
-- GO
-- 
-- IF OBJECT_ID('HR.GetManagers','IF') IS NOT NULL DROP FUNCTION HR.GetManagers;
-- 
-- GO
-- CREATE FUNCTION HR.GetManagers(@empid AS INT) RETURNS TABLE
-- AS
-- RETURN
-- 	WITH empCte AS (
-- 		SELECT e.empid,e.mgrid,e.firstname,e.lastname, 0 AS distance
-- 		FROM TSQLFundamentals2008.HR.Employees AS e
-- 		WHERE e.empid = @empid
-- 		
-- 		UNION ALL
-- 		
-- 		SELECT e.empid,e.mgrid,e.firstname,e.lastname,ec.distance + 1 AS distance
-- 		FROM empCte AS ec
-- 		INNER JOIN TSQLFundamentals2008.HR.Employees AS e ON ec.mgrid = e.empid		
-- 	)
-- 	SELECT *
-- 	FROM empCte AS ec;
-- 
-- GO	

SELECT *
FROM TSQLFundamentals2008.HR.GetManagers(9) AS M

-- O������� APPLY
-- CROSS APPLY : ���� ������ ��������� ����� ������� ����� ������ ��� ����� - ���� ������ ����������
-- ������� ��������� ��� ������ � �� ����� ��� ���������� � ID = 1
-- ������� ����� APPLY ������������� ��� ������� ���������� ���� �� ��������
-- ��� �������� � �� ����� ��� ������� ���������� � ����
-- ��� �� CROSS APPLY �� ������� �� ������ ��� ���� ��������� ����� ������� ������ ����
-- ���������� � ����, �� �� ����� ��������� �������� �����������
SELECT s.supplierid,a.productid, a.productname, a.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
CROSS APPLY(
	SELECT TOP(2) *
	FROM TSQLFundamentals2008.Production.Products AS p
	WHERE p.supplierid = s.supplierid
	ORDER BY p.unitprice,p.productid ASC
) AS A
WHERE s.country = N'Japan'

-- OUTER APPLY
-- ��� �������� ������ ��� ���� �� CROSS APPLY � ��� ���� ������ � ���������
-- ������ � ��� ������� ��� ���� ����������� ������ ���� � ����� �������
-- �������� NULL ���������������� �� �������� ���������� � ����� �������
-- � ������� ������� ������ �� CROSS APPLY i OUTER APPLY ����� �� ������ ��
-- INNER JOIN i LEFT JOIN
SELECT s.supplierid,a.productid, a.productname, a.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
OUTER APPLY(
	SELECT TOP(2) *
	FROM TSQLFundamentals2008.Production.Products AS p
	WHERE p.supplierid = s.supplierid
	ORDER BY p.unitprice,p.productid ASC
) AS A
WHERE s.country = N'Japan'

-- ���������
-- ������� ������ �������� �������� �� �� ���� ��� ����� �������
SELECT p.categoryid, MIN(p.unitprice) AS min_price
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.categoryid

-- ����� �������� CTE � ������� ���� � Production.Products ��� ���� ��� ������� ���� ��� �������
;WITH prodCte AS(
	SELECT p.categoryid, MIN(p.unitprice) AS min_price
	FROM TSQLFundamentals2008.Production.Products AS p
	GROUP BY p.categoryid
)
SELECT p.*
FROM prodCte AS pc
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON pc.categoryid = p.categoryid
WHERE p.unitprice = pc.min_price

-- ��� ���� ��� ����� apply (���� � ������� ������ ������ � ���� ���� �������� �� ������ ������� ������)
SELECT p.*
FROM TSQLFundamentals2008.Sales.Nums AS tb
CROSS APPLY(
	SELECT TOP(1) WITH TIES
		   p2.categoryid,		   
		   p2.unitprice
	FROM TSQLFundamentals2008.Production.Products AS p2
	WHERE p2.categoryid = tb.n
	ORDER BY p2.unitprice ASC
) AS ca
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON ca.categoryid = p.categoryid AND 
														    p.unitprice = ca.unitprice
WHERE tb.n <= 8;

-- �������� �������� ������� ��� ������ �� ���� @ID ���������� � @n ������ � �� ������ �� 
-- ����� ���� ��������. ���� � ������� ������ �� ������������� ���������� ��������� productid
-- USE TSQLFundamentals2008
-- GO
-- 
-- IF OBJECT_ID('Production.GetTopProducts','IF') IS NOT NULL DROP FUNCTION Production.GetTopProducts;
-- GO
-- 
-- CREATE FUNCTION Production.GetTopProducts(@suppid AS INT,@n AS INT) RETURNS TABLE
-- AS
-- RETURN
-- 	SELECT TOP(@n) 
-- 			   p.productid,
-- 			   p.productname,
-- 			   p.unitprice
-- 	FROM TSQLFundamentals2008.Production.Products AS p
-- 	WHERE p.supplierid = @suppid
-- 	ORDER BY p.unitprice,p.productid
-- 	
-- GO

DECLARE @suppid INT = 1;
DECLARE @tot_prods INT = 2;
SELECT *
FROM TSQLFundamentals2008.Production.GetTopProducts(@suppid,@tot_prods) AS p	

-- ��������� ��� �������� ��� ������� ���������� � ����
DECLARE @tot_prods2 INT = 2;
SELECT s.supplierid,ca.productid,ca.productname,ca.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
CROSS APPLY TSQLFundamentals2008.Production.GetTopProducts(s.supplierid,@tot_prods2) AS ca
WHERE s.country = N'Japan'

-- ��������� ��������� ����� ��� ������ ����� ��� ���������� � ���� � ���� ���� ��������
DECLARE @tot_prods2 INT = 2;
SELECT s.supplierid,ca.productid,ca.productname,ca.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
OUTER APPLY TSQLFundamentals2008.Production.GetTopProducts(s.supplierid,@tot_prods2) AS ca
WHERE s.country = N'Japan'

-- ��������� ��� ������ � ��������
-- ��������� �� ����� � �������� ����������� ��� �������� NULL �� ���
-- ����� ������ �� ������ ���� ORDER BY, ��� �������� ���� ���� ����� ��� ������
-- ����� �������� ��� ������������ �������� ������������ ������ �������

-- UNION/UNION ALL
-- UNION �� ������� DISTINCT, ���� �� �� ������� ��������� �����
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
UNION
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- UNION ALL ������� �� ����������
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
UNION ALL
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- INTERSECT ������� ����� ���, ����� ���� ������ ����������� 1+ � ������� ����� � 
-- 1+ � ������� �� ���� �����������
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
INTERSECT
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- EXCEPT ������� ��� �� � � ������� � ������ � ������� �����
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
EXCEPT
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- � UNION i INTERSECT ������� ����� ������ ���� ��������, � ������� EXCEPT ��
-- INTERSECT �� ����� �� UNION/EXCEPT �������. ������� ��� ����� ����� ������ �����
-- ����� ������
-- INTERSECT/EXCEPT �� ������� �������� �����

-- ������� �������� �� ������������� �볺��� 1 ��� �� �볺��� 2
SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 1

EXCEPT

SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 2

-- ������� �������� �� ������������� � �볺��� 1 � �볺��� 2
SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 1

INTERSECT

SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 2

-- ������� employee id ��� �� �� ������ ���������� 12 ������ 2008 ���� ������ ���������
SELECT e.empid
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE NOT EXISTS (SELECT * FROM TSQLFundamentals2008.Sales.Orders AS o 
                  WHERE o.empid = e.empid AND o.orderdate = '20080212')
                  
SELECT e.empid
FROM TSQLFundamentals2008.HR.Employees AS e
LEFT JOIN TSQLFundamentals2008.Sales.Orders AS o ON o.empid = e.empid AND o.orderdate = '20080212'
WHERE o.orderid IS NULL                   

SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
EXCEPT
SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.orderdate = '20080212'

-- ���������� �����
-- ����� ���� ����� �� ��� � ���� �����
SELECT COUNT(*)
FROM TSQLFundamentals2008.Sales.Orders AS o

-- ������� �� ���������� ������� � �������� ������� ����� �� ����� �����
SELECT o.shipperid, COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
GROUP BY o.shipperid

-- ��������� ��� �� ���������� ������ � �� ����
SELECT  o.shipperid
	   ,YEAR(o.shippeddate) AS shipperdate
	   ,COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
GROUP BY o.shipperid, YEAR(o.shippeddate)
ORDER BY o.shipperid, YEAR(o.shippeddate)

-- ������� � ��� ��� ���� ������ ��� �����������
-- ��� WHERE ������ �� ��� ������ � HAVING ��� �� ������ �����
SELECT  o.shipperid
	   ,YEAR(o.shippeddate) AS shipperdate
	   ,COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.shippeddate IS NOT NULL
GROUP BY o.shipperid, YEAR(o.shippeddate)
HAVING COUNT(*) < 100

-- COUNT (*) �� �������������� ������ �� ���� � ������� � NULL �� ���� ������ ���������
-- COUNT (o.shippeddate) �������������� ������
-- ����� ����� ��������������� COUNT(DISTINCT o.shippeddate)

-- ���������� � SELECT ����� ����� �� ������� �� � � GROUP BY
-- ��� ������ �������� ���� ��������� � ��������� �������
;WITH cte AS (
	SELECT s.shipperid, COUNT(s.shipperid) AS nums
	FROM TSQLFundamentals2008.Sales.Shippers AS s
	GROUP BY s.shipperid
)
SELECT s.shipperid, s.companyname, c.nums
FROM TSQLFundamentals2008.Sales.Shippers AS s
INNER JOIN cte AS c ON c.shipperid = s.shipperid;

-- ������� ������� ��������� �� ������� �볺��� � �����
SELECT c.custid, COUNT(c.custid) AS ord_nums
FROM TSQLFundamentals2008.Sales.Orders AS o
INNER JOIN TSQLFundamentals2008.Sales.Customers AS c ON c.custid = o.custid
WHERE c.country = N'Spain'
GROUP BY c.custid

-- ������ �� ���� ����� ����
;WITH cte AS (
	SELECT o.custid, 
		   COUNT(CASE WHEN o.orderid > 10662 THEN 1 ELSE NULL END) AS ord_num		   
	FROM TSQLFundamentals2008.Sales.Orders AS o
	GROUP BY o.custid
)
SELECT c2.custid, c2.country, c2.city, c.ord_num
FROM cte AS c
INNER JOIN TSQLFundamentals2008.Sales.Customers AS c2 ON c.custid = c2.custid 

-- PIVOT operator
;WITH cte AS(
	SELECT o.custid, o.shipperid, o.freight
	FROM TSQLFundamentals2008.Sales.Orders AS o
)
SELECT custid, [1], [2], [3]
FROM cte AS c2
PIVOT
(
	SUM(freight)
	FOR shipperid
	IN ([1],[2],[3])
) AS p


;WITH cte AS (
	SELECT o.custid, o.empid
	FROM TSQLFundamentals2008.Sales.Orders AS o
)
SELECT custid,[1],[2],[3],[4],[5],[6],[7],[8],[9]  
FROM cte AS c
PIVOT
(
	COUNT(empid)
	FOR empid
	IN([1],[2],[3],[4],[5],[6],[7],[8],[9])
) AS p

-- UNPIVOT
-- ��� �������� ������� ������ �� ������ NULL
-- � �������� PIVOT �� �� ������� ������� ���� �������� ������������� ��� ����������
-- ��� ��� ������ �볺��� �����
USE TSQLFundamentals2008;
GO

IF OBJECT_ID('Sales.FreightTotals') IS NOT NULL DROP TABLE Sales.FreightTotals;
GO

;WITH pivData AS(
	SELECT o.custid, o.shipperid, o.freight
	FROM TSQLFundamentals2008.Sales.Orders AS o
)
SELECT *
INTO TSQLFundamentals2008.Sales.FreightTotals 
FROM pivData AS pd
PIVOT
(
	SUM(freight)
	FOR shipperid
	IN([1],[2],[3])
) AS p

--SELECT * FROM TSQLFundamentals2008.Sales.FreightTotals

SELECT custid,shipperid,freight
FROM TSQLFundamentals2008.Sales.FreightTotals AS ft
UNPIVOT
(
	freight
	FOR shipperid
	IN ([1],[2],[3])
) AS up

-- �������� ����� �� ������� Orders ���� �������� ����������� ���� ���������� ��� �������
-- ���� � ����� ������������� �����
;WITH ordPiv AS (
	SELECT YEAR(o.orderdate) AS orderdate, o.shippeddate, o.shipperid
	FROM TSQLFundamentals2008.Sales.Orders AS o
)
SELECT orderdate, [1], [2], [3]
FROM ordPiv AS op
PIVOT
(
	MAX(shippeddate)
	FOR shipperid
	IN ([1],[2],[3])
) AS pv

-- �������� ����� ���� ������ ��� ������� �볺��� ������� ��������� ��� ���������� ������ �����������
;WITH custShips AS (
	SELECT o.custid, o.shipperid
	FROM TSQLFundamentals2008.Sales.Orders AS o
)
SELECT custid, [1], [2], [3]
FROM custShips 
PIVOT
(
	COUNT(shipperid)
	FOR shipperid
	IN([1],[2],[3])
) AS pv

/*******************************************
 * ³���� �������
 *******************************************/
-- �������� ����� ����������� � ���� �� ����� ��������������� �������� � ���������� �������� � ������ �����
-- OVER() - ����������� ������� ������� ����� � �������� �����
-- OVER(PARTIOTION BY some_col) - ���� ���������� ��� ����������� ��������
-- ����. SUM(val) OVER(PARTITION BY custid) - ���� ��� ������� ������ custid = 1, �� ������ ����� � ������ �
-- ������ � ���� custid = 1, ����� ����� ������� ���� ��� custid = 1

SELECT ov.custid,
	   ov.orderid,
	   ov.val,
	   SUM(ov.val) OVER(PARTITION BY ov.custid) AS custtotal,
	   SUM(ov.val) OVER() AS grandtotal
FROM TSQLFundamentals2008.Sales.OrderValues AS ov

-- ����� �������� ������� ����� ���������� ����������
-- ���� ���������� ������ � ���� �� ������������ ������������� �������� ������
-- �� ��������� �������� �����, � ���� �� ����� ����� ������������� ����� ��������� ���� ����� 
-- �� ����� ���������
-- � �������� ���� ��������� ���������� ROWS/RANGE
-- �������������� ROWS ����� ������� ������� �� ���� � ���������
-- 1. UNBOUNDED PRECEDING/FLOWING �� ��������� ������� � ����� ������ ��������
-- 2. CURRENT ROW - ������� ������
-- 3. <n> ROWS PRECEDING/FLOWING �� ������ <n> ����� �� �� ���� ������� ������

-- �������� ����� �� OrderValues ���� ������ ������ �������� ���� �� ������� �������� 
-- �� ��������� ����������
SELECT ov.custid, ov.orderid, ov.orderdate, ov.val,
	   SUM(ov.val) OVER(PARTITION BY custid
						ORDER BY orderdate, orderid
						ROWS BETWEEN unbounded preceding AND
						CURRENT ROW) AS runningtotal 
FROM TSQLFundamentals2008.Sales.OrderValues AS ov

;WITH cte1 AS (
	SELECT ov.custid, ov.orderdate, ov.val, 
		   ROW_NUMBER() OVER (PARTITION BY ov.custid 
			     			  ORDER BY ov.orderdate,ov.orderid) AS rn
	FROM TSQLFundamentals2008.Sales.OrderValues AS ov
)
SELECT c.*, 
	  (SELECT SUM(c1.val) FROM cte1 AS c1 
	   WHERE c1.rn <= c.rn AND c1.custid = c.custid) AS runsum
FROM cte1 AS c
ORDER BY c.custid,c.orderdate

-- � sql � ��� ���������� �-��� : ROW_NUMBER, RANK, DENSE_RANK, NTILE
-- ��� ��� ���������� ��������� ORDER BY 
-- ������� ������� �� ORDER BY � OVER �������� ����� ������������� ���
-- ���������� ������ �������; ��� ���� ��� ��������� ������ � ������ �����
-- ������ ORDER BY ��� ������
SELECT ov.custid, ov.orderid, ov.val,
	   ROW_NUMBER() OVER (ORDER BY ov.val) AS rn,
	   RANK()		OVER (ORDER BY ov.val) AS rnk,
	   DENSE_RANK() OVER (ORDER BY ov.val) AS denserank,
	   NTILE(100)	OVER (ORDER BY ov.val) AS ntilee100 
FROM TSQLFundamentals2008.Sales.OrderValues AS ov

-- ROW_NUMBER �������� ��������� ���������� ����� ������ ��������� � 1 � ������ ���� ��
-- ����� ����������; ��� �� ����� ����� �� �� ���� �� ������� �������� ����������� ������ �� ���� ���� �����
-- ����� ������� �������� ������� ������ ����� ��� ������ ������������� ������;
-- order by - � ���������� ��� ���� �������
-- partiotion by - ����������� 

-- RANK � DENSE_RANK ����������� �� ROW_NUMBER ��� �� ���� � ��������� ������������ ������� ����������, ����
-- val = 36.00 ��� � ����� ���� �����, �� RANK �� �������� ������ ����������� ������ ���� ������ � ROW_NUMBER ��������
-- RANK ���� ���� ������� ������� � DENSE_RANK � 
-- NTILE - ��������������� ��� ���� ��� ����������� ������ � ������� ������ � ������ ������� ����; � ������ �������
-- �� ������ ����� �� 100 ����; 830 / 100 = 8 � �������� 30. ������� � ������� �� ����� 30 ���� �������� �� ��������� 
-- ������, ����� �� 9 �����. ������� 31-100 ����� �� 8 �����.

-- �� ���� ������� ����� ������� ����� ������������� ����� � SELECT/ORDER BY ���� ���� ������� ������ ������� 
-- ����������� � WHERE ����� ����������� CTE � � ����������� ����� �������� ������� �� ��� ������� ��������
-- �� ����� ����� ���� ���������� � WHERE ���������� ������.


-- �������� ����� ���� ���� ��������� �������� ������ ��� ������� ����� ��������� �볺���
DECLARE @filter AS INT;
SET @filter = 2;
;WITH avgOrds AS (
	SELECT ov.custid, ov.orderid, ov.orderdate, ov.val,
		   ROW_NUMBER() OVER (PARTITION BY ov.custid 
							  ORDER BY ov.orderdate,ov.orderid) AS rn
	FROM TSQLFundamentals2008.Sales.OrderValues AS ov
)
SELECT ao.custid, ao.orderid, ao.orderdate, ao.val,
	   (SELECT AVG(ao1.val) FROM avgOrds AS ao1 WHERE ao1.custid = ao.custid AND ao1.rn >= ao.rn - @filter AND ao1.rn <= ao.rn) 
FROM avgOrds AS ao

-- �������� ����� �� ������ ����� ������ � ���������� ��������� �� ����������� �� ������� ����������
;WITH maxFreight AS(	
	SELECT o.orderid, o.orderdate, o.freight, o.shipperid,
		   ROW_NUMBER() OVER (PARTITION BY o.shipperid 
							  ORDER BY o.freight DESC, o.orderid ASC) AS rn
	FROM TSQLFundamentals2008.Sales.Orders AS o
)
SELECT mf.shipperid, mf.orderid, mf.orderdate, mf.freight, mf.rn
FROM maxFreight AS mf
WHERE mf.rn <= 3
ORDER BY mf.shipperid, mf.rn

-- �������� ����� ���� ������ ������ �� �������� � ��������� ����������� ������ �볺���,
-- � ����� ������ �� �������� � ��������� �����������
;WITH cte AS (
	SELECT ov.custid, ov.orderid, ov.orderdate, ov.val,
		   ROW_NUMBER() OVER (PARTITION BY ov.custid 
							  ORDER BY ov.orderid) AS rn 
	FROM TSQLFundamentals2008.Sales.OrderValues AS ov
)
SELECT c1.custid, c1.orderid, c1.orderdate, c1.val, 
	   (c1.val - c2.val) AS curr_prev_diff,
	   (c1.val - c3.val) AS curr_next_diff											
FROM cte AS c1
LEFT JOIN cte AS c2 ON c2.rn = c1.rn - 1 AND c2.custid = c1.custid
LEFT JOIN cte AS c3 ON c3.rn = c1.rn + 1 AND c3.custid = c1.custid

-- XML
SELECT c.custid AS [@custid], c.companyname AS [companyname]
FROM TSQLFundamentals2008.Sales.Customers AS c
WHERE c.custid <= 2
ORDER BY c.custid
FOR XML PATH('Customer'), ROOT('Customers')

-- ��������� �������
-- � Sql Server ������� ����� �������� ����� ���������
-- 1. create table
-- 2. select into ��� ����������� �������� ������� 
-- ������� ���������� �� ����
USE TSQLFundamentals2008
GO
CREATE SCHEMA MyShema 

-- ����� ��� ������� ����� ��������
ALTER SCHEMA Sales TRANSFER production.Categories;
ALTER SCHEMA Production TRANSFER Sales.Categories;

DECLARE @v1 DECIMAL(18,6) = 191235689123.03434999999;
DECLARE @v2 REAL = 19123568912343434390909.03434999999;
DECLARE @v3 DECIMAL(38,10) = 19123568912343434390909.03434999999;
SELECT @v3

-- ���� ��� ��������� ����������� NULL �������� �� ���� ������ �������� � ���� �����
DECLARE @t TABLE (
	id INT,
	val FLOAT
)

INSERT INTO @t
VALUES(1,10.0),
	  (2,12.0),
	  (1,13.0),
	  (NULL,NULL),
	  (NULL,32.0)
	  
SELECT  id, SUM(val)
FROM @t	 
GROUP BY id

-- CREATE TABLE some table for example
USE TSQLFundamentals2008
GO

CREATE TABLE Production.CategoriesMy
(
	catid INT IDENTITY(1,1) NOT NULL,
	catname NVARCHAR(15) NOT NULL,
	descr NVARCHAR(200) NOT NULL DEFAULT('')
) 
WITH (data_compression = row)

-- ��� ���� ��� ���������� ����� ��������� ������� �������
ALTER TABLE TSQLFundamentals2008.Production.CategoriesMy 
REBUILD WITH(data_compression = PAGE)

-- ������� ALTER TABLE ����� ��������������� � ����� �����
-- 1. ������ ��� �������� ��������, ��������� ����������� ��������
-- 2. ������ ��� ����� �������
-- 3. ������ ����������� NULL ��������
-- 4. ������ ��� �������� ��������� (primary key, unique constraint, foreign key, check constraint, default constraint)
-- ���� ������� ������ ����������� ����������� - ������� ���� � ������� ����
-- ������� ALTER TABLE �� ����� ����������� ��� 
-- 1. ������ ��� �������
-- 2. ��������� ���������� ��������������
-- 3. ��������� ���������� ��������������

-- ���������
-- �������� ������� � ����� ��������
USE TSQLFundamentals2008
GO

CREATE TABLE Production.CategoriesTest
(
	catid INT NOT NULL IDENTITY
)
GO

-- ������ ������ �� �������� �������
ALTER TABLE Production.CategoriesTest
ADD catname NVARCHAR(15) NOT NULL
GO

ALTER TABLE Production.CategoriesTest
ADD descr NVARCHAR(200) NOT NULL 
GO

-- ������ ��� � �������
INSERT INTO TSQLFundamentals2008.Production.CategoriesTest(catid,catname,descr)
SELECT c.categoryid, c.categoryname, c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c

-- ������� �� ����� ���� ��������� ������������� ������� �������� ������� IDENTITY_INSERT ON
SET IDENTITY_INSERT Production.CategoriesTest ON;
INSERT INTO TSQLFundamentals2008.Production.CategoriesTest(catid,catname,descr)
SELECT c.categoryid, c.categoryname, c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c
GO 
SET IDENTITY_INSERT Production.CategoriesTest OFF;

-- ��� ���� ��� �������� ������� �������� �������
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL DROP TABLE Production.CategoriesTest

-- ������ � NULL ���������
-- �������� ������� CategoriesTest
USE TSQLFundamentals2008
GO

CREATE TABLE Production.CategoriesTest
(
	catid INT NOT NULL IDENTITY,
	catname NVARCHAR(15) NOT NULL,
	descr NVARCHAR(200) NOT NULL,
	CONSTRAINT Pk_CategoriesTest PRIMARY KEY(catid)
)
GO

-- ��������� �������
SET IDENTITY_INSERT Production.CategoriesTest ON;
GO
INSERT INTO Production.CategoriesTest (catid,catname,descr)
SELECT c.categoryid,c.categoryname,c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c
GO
SET IDENTITY_INSERT Production.CategoriesTest OFF;

-- �������� ����� ������� description
ALTER TABLE Production.CategoriesTest
	ALTER COLUMN descr NVARCHAR(500) NOT NULL;
	
-- ��������� ������� �� �������� NULL � ������� descr
SELECT ct.descr
FROM TSQLFundamentals2008.Production.CategoriesTest AS ct	

-- ������ ������ �������� � ������� descr �� NULL (������ ���� �������)
UPDATE Production.CategoriesTest
SET descr = NULL
WHERE catid = 8

-- ������ ������� � ������� �������� NULL �����������
ALTER TABLE Production.CategoriesTest
	ALTER COLUMN descr NVARCHAR(500) NULL;
	
-- ����� ��������� ������ ��� �������� ����� �� NOT NULL
ALTER TABLE Production.CategoriesTest
 ALTER COLUMN descr NVARCHAR(500) NOT NULL;

-- ������ �������� � ������� descr 
UPDATE Production.CategoriesTest
SET descr = 'Seaweed and fish'
WHERE catid = 8 

-- �������� ���� ����� 
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL DROP TABLE Production.CategoriesTest;

/*******************************************
 * ֳ������ �����
 *******************************************/ 
-- ��������� ����� ��� ������������ �������� ����� �� constraints

/*******************************************
 * PRIMARY KEY
 *******************************************/
-- 1) �� ������ ���� NULL 
-- 2) ���� �� ��� ������ ���� ������� ��� � ������� ��� �������� ���������� �����
-- 3) ���� ���� ����� ���� primary key � �������
-- ���� ����������� primary key ������ ����������� unique constraint + clustered index
-- ��� ���� ��� ���������� primary key constraints � ��� ������� �������� sys.key_constraints � ����������� �� PK
USE TSQLFundamentals2008
GO
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.[type] = 'PK'

-- ����� ����� ������ ��������� ������ ���� ����������� ������ ��� ������������ 
-- ����������� ���������� �����
USE TSQLFundamentals2008
GO
SELECT *
FROM sys.indexes AS i
WHERE i.[object_id] = OBJECT_ID('Production.Categories') AND
	  i.name = 'PK_Categories';
	
/*******************************************
 * UNIQUE CONSTRAINT
 *******************************************/  
-- ��� ��� ��������� �� � primary key ����������� ������� ������ ��� ������� � ����� �� ������ ��
-- ���������; ��������� ������ ���� ���� �� ��������������� ��� � �� ��������������� 
-- ��������� ���������� �� ������ ��� �������� ��� NOT NULL - ����� ��������� NULL ��� ��� �����
-- ����� ���� ������ ���� ���� �������� NULL
-- ��������� ���� � ��������� ���������� ����� �� ��������� �� ������� �������� �������� �� � ������
-- �� ����������� ������� 16 � ����� 900 ����
-- ��������� ��� ���� ��� ����������� ���������� ���� �������� ����� ������� UNIQUE CONSTRAINT
ALTER TABLE Production.CategoriesTest
 ADD CONSTRAINT UC_Categories UNIQUE(categorynamee) 
 	  
-- ����� ����� ����������� �� ��������� ���������� �� � � ���
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.[type] = 'UQ';

-- ����� ������ ��������� ������ ������������ ������ �� ���� ���������
SELECT *
FROM sys.indexes AS i
WHERE i.name = 'UK_principal_name';

/*******************************************
 * FOREIGHN KEY
 *******************************************/
-- ��������������� �� ������ �� ������� � ��� � ��������� ����
-- ��� ���� ��� ������ ������� ���� �������
-- ��������� ��������� WITH CHECK ������������� ��� ���� � ������� ���������� �����
-- � ���� ������ ��������� ����������� �� ������� ALTER TABLE ����������� ��������
-- ������� � ��������� ������� ������ ���� ��������� ������, ��������� ��� ���, ��� ��
-- ��������� ���������� ����� ������ ��� ����� ��������� ���������� ��� ����� ��������� �������
USE TSQLFundamentals2008
GO

ALTER TABLE Production.Products WITH CHECK 
 ADD CONSTRAINT FK_Products_Categories FOREIGN KEY (categoryid)
 REFERENCES Production.Categories (categoryid);

-- ������������� �������� ����������������� ������ �� ���������� �����,
-- �� �������� ������ ��������� � ������ ��������
 
-- ��� ������ FKs � ���
SELECT *
FROM sys.foreign_keys AS fk
WHERE NAME = 'FK_Products_Categories' 

/*******************************************
 * CHECK CONSTRAINTS
 *******************************************/
-- ��� ��� ��������� ����������� ��� ���� ��� ���������� �������� � ������� ������ �����
-- ��� ���� ��� �������� ����� CONSTRAINT
-- ���� � ������� ��������i NULL ������������� � ���� �� ��������� ������� NULL ��������
-- ������� ��������� ��������� �������� unitprice >= 0 i unitprice < 0
ALTER TABLE TSQLFundamentals2008.Production.Products WITH CHECK
 ADD CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0);

-- ��� ���� ��� �������� ������ CHECK CONSTRAINT ��� ������� �������������� �����
SELECT *
FROM sys.[check_constraints] AS cc
WHERE cc.parent_object_id = OBJECT_ID('Production.Products');

/*******************************************
 * DEFAULT CONSTRAINTS
 *******************************************/
-- ���������� ������ �������� �� ������������ ��� ���� ����������������� ��� ��������
-- ����� � ������� ���� ������ �������� � ���������� INSERT
-- ��� ���� ��� ������� ������ ��� �������� ��� �������
SELECT * 
FROM sys.default_constraints AS dc
WHERE dc.parent_object_id = OBJECT_ID('Production.Products');

-- ���������
/* -- ������� ������� Production.Products
CREATE TABLE Production.Products
( productid INT NOT NULL IDENTITY,
productname NVARCHAR(40) NOT NULL,
supplierid INT NOT NULL,
categoryid INT NOT NULL,
unitprice MONEY NOT NULL
CONSTRAINT DFT_Products_unitprice DEFAULT(0),
discontinued BIT NOT NULL
CONSTRAINT DFT_Products_discontinued DEFAULT(0),
CONSTRAINT PK_Products PRIMARY KEY(productid),
CONSTRAINT FK_Products_Categories FOREIGN KEY(categoryid)
REFERENCES Production.Categories(categoryid),
CONSTRAINT FK_Products_Suppliers FOREIGN KEY(supplierid)
REFERENCES Production.Suppliers(supplierid),
CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0) );
*/

-- 1. ������ � PRIMARY i FOREIGN KEYs
-- ���������� Primary Key
SELECT *
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.productid = 1;

SET IDENTITY_INSERT Production.Products ON;
GO
INSERT INTO Production.Products
(
	productid, 
	productname,
	supplierid,
	categoryid,
	unitprice,
	discontinued
)
VALUES
(
	1,
	N'Product test',
	1,
	1,
	18,
	0
) 
GO
SET IDENTITY_INSERT Production.Products OFF;

-- ������ ���� ������ ��� ���������� ����� productid
INSERT INTO Production.Products
(
	-- productid -- this column value is auto-generated
	productname,
	supplierid,
	categoryid,
	unitprice,
	discontinued
)
VALUES
(
	N'Product test',
	1,
	1,
	18,
	0
)
 
-- �������� ������� ������
DELETE FROM Production.Products
WHERE productname = N'Product test';

-- ������� �� ��� ������ ������ � ������� ��������� catid = 99. ���� ������� ����� foreign key
INSERT INTO Production.Products
(
	-- productid -- this column value is auto-generated
	productname,
	supplierid,
	categoryid,
	unitprice,
	discontinued
)
VALUES
(
	N'Product test',
	1,
	99,
	18,
	0
)

-- ��������� ������ ������� ���� � WITH CHECK - ������� �� ����������
ALTER TABLE Production.Products WITH CHECK
 ADD CONSTRAINT FK_Products_Categories FOREIGN KEY (categoryid)
 REFERENCES Production.Products (categoryid);
 
-- 2. ������ � CHECK CONSTRAINT
-- ��������� �� �� ����� �������� �������
USE TSQLFundamentals2008
GO

SELECT p.productname, COUNT(*) AS prodname_count
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.productname
HAVING COUNT(*) > 1;

-- ������ ��� productid = 1 �������� ����� 'Product HHYDP'
UPDATE TSQLFundamentals2008.Production.Products
SET productname = 'Product RECZE'
WHERE productid = 1;

-- ����� ��������� ����� �� �������� ��������
SELECT p.productname, COUNT(*) AS prodname_count
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.productname
HAVING COUNT(*) > 1;

-- ������ ������ ��������� ���������� - ���� ���� failed
ALTER TABLE Production.Products
 ADD CONSTRAINT UQ_ProdName UNIQUE(productname);

-- ��������� ����� �������� �� ��������������
UPDATE TSQLFundamentals2008.Production.Products
SET productname = 'Product HHYDP'
WHERE productid = 1;

-- ����� ��������� ����� ������ (����� � ��� ���������� nonclustered index)
ALTER TABLE Production.Products
 ADD CONSTRAINT UQ_ProdName UNIQUE(productname);
 
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.name = 'UQ_ProdName'

SELECT *
FROM sys.indexes AS i
WHERE i.NAME = 'UQ_ProdName' AND
	  i.[object_id] = OBJECT_ID('Production.Products')

-- �������� ��������� ����������
ALTER TABLE Production.Products
 DROP CONSTRAINT UQ_ProdName;
 
-- �������� �� �������� : ��������� ��������� � ���� ��������� ���������� ����� � ��������� ����������, �� 
-- �������������� sql server �� ��������� ���������� �������. ���� ����� ��������� ��������� ���������� 
-- �����, ��� ������� �� ����� ��� ����������� ���� ��������� � ����� ������� �������� � ��� �������.
-- ����� ���� ���������� check constraints i default constraints �� �������������� �� �������

-- ���� ���������� ������ �� ������� ��� �� ��� �������� NOT NULL - �� ������ ���� �������
-- ��� ���� ��� ��� ������� ������ ������� � ������ ������ NOT NULL DEFAULT '' ����

-- View and table functions ���������
-- �������� ����� ���� ������ ������� ������� � ��������� ��'�� ������� ��� ��� �������
-- �� ���� �� �볺��� � �� ���������������
;WITH cte AS (
	SELECT YEAR(o.orderdate) AS [Year], 
		   o.custid,
		   o.shipperid, 
		   COUNT(*) AS num_of_orders, 
		   CAST(SUM(od.qty * od.unitprice * (1 - od.discount)) AS NUMERIC(12,2)) AS qty
	FROM TSQLFundamentals2008.sales.Orders AS o
	INNER JOIN TSQLFundamentals2008.sales.OrderDetails AS od ON o.orderid = od.orderid
	GROUP BY YEAR(o.orderdate),o.custid,o.shipperid
)
SELECT   c.[Year]
	   , c.custid
	   , c2.companyname
	   , c.shipperid
	   , s.companyname
	   , c.num_of_orders
	   , c.qty
FROM cte AS c
INNER JOIN TSQLFundamentals2008.Sales.Customers AS c2 ON c.custid = c2.custid
INNER JOIN TSQLFundamentals2008.Sales.Shippers AS s ON c.shipperid = s.shipperid

/*******************************************
 * ������� ����� � ����
 *******************************************/
-- INSERT INTO - ��������� � ������� ���� ��� ������� �����
-- INSERT SELECT - ��������� � ������� ���������� ������
-- INSERT EXEC - ��������� ����� � ������� �� ����������� � ������
-- SELECT INTO - ����������� ��������� ������ ��� ��������� � ���������� �������

-- ��� ������������ �������� ������� 
USE TSQLFundamentals2008;
IF OBJECT_ID('Sales.MyOrders') IS NOT NULL
    DROP TABLE Sales.MyOrders;
GO
CREATE TABLE Sales.MyOrders
(
	orderid         INT NOT NULL IDENTITY(1, 1)
	CONSTRAINT PK_MyOrders_orderid PRIMARY KEY,
	custid          INT NOT NULL,
	empid           INT NOT NULL,
	orderdate       DATE NOT NULL
	CONSTRAINT DFT_MyOrders_orderdate DEFAULT(CAST(SYSDATETIME() AS DATE)),
	shipcountry     NVARCHAR(15) NOT NULL,
	freight         MONEY NOT NULL
);

-- INSERT INTO
INSERT INTO TSQLFundamentals2008.sales.MyOrders(custid,empid,orderdate,shipcountry,freight)
VALUES (2,19,'20120720',N'USA',30.0)

-- ���� ������� �������� ������ �������� IDENTITY
USE TSQLFundamentals2008
GO
SET IDENTITY_INSERT Sales.MyOrders ON
INSERT INTO TSQLFundamentals2008.sales.MyOrders(custid,empid,orderdate,shipcountry,freight)
VALUES (4,19,'20120720',N'USA',30.0)
SET IDENTITY_INSERT Sales.MyOrders OFF

-- ����� �� ��������� ���� ������� ���� �� ��������� default
INSERT INTO TSQLFundamentals2008.sales.MyOrders(custid,empid,orderdate,shipcountry,freight)
VALUES (4,19,DEFAULT,N'USA',30.0)

-- INSERT SELECT - �������� ����������� ������ ����������� ������� � ������� �������
USE TSQLFundamentals2008
GO

SET IDENTITY_INSERT Sales.MyOrders ON;
INSERT INTO Sales.MyOrders(orderid,custid,empid,orderdate,shipcountry,freight)
SELECT o.orderid, o.custid, o.empid, o.orderdate, o.shipcountry, o.freight
FROM sales.Orders AS o
WHERE o.shipcountry = N'Norway'
SET IDENTITY_INSERT Sales.MyOrders OFF;

-- INSERT EXEC - �� ��������� ���� ���������� ����� ��������� ��� �� �������� �������
IF OBJECT_ID('Sales.OrdersForCountry','P') IS NOT NULL DROP PROC Sales.OrdersForCountry
GO

CREATE PROC Sales.OrdersForCountry 
 @country NVARCHAR(15)
AS
 SELECT   o.orderid
		, o.custid
		, o.empid
		, o.orderdate
		, o.shipcountry
		, o.freight
 FROM TSQLFundamentals2008.Sales.Orders AS o
 WHERE o.shipcountry = @country
 
-- ��������� ������ ��� ������ ������� �� �������볿
USE TSQLFundamentals2008
GO

SET IDENTITY_INSERT Sales.MyOrders ON;
INSERT INTO Sales.MyOrders (orderid,custid,empid,orderdate,shipcountry,freight)
EXEC sales.ordersforcountry @country = N'Portugal'
SET IDENTITY_INSERT Sales.MyOrders OFF;

-- SELECT INTO - �� ���������� ������� ������� � ����� ���� ��� � ������; �������, ���������, ������� �� ���������
IF OBJECT_ID('Sales.MyOrders','U') IS NOT NULL DROP TABLE Sales.MyOrders
GO

SELECT orderid, custid, empid, orderdate, shipcountry, freight
INTO sales.MyOrders
FROM Sales.orders 
WHERE shipcountry = N'Norway' 

/*******************************************
 * ��������� ����� 
 *******************************************/
-- �������� ������ �������
IF OBJECT_ID('Sales.MyOrderDetails', 'U') IS NOT NULL
    DROP TABLE Sales.MyOrderDetails;
IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL
    DROP TABLE Sales.MyOrders;
IF OBJECT_ID('Sales.MyCustomers', 'U') IS NOT NULL
    DROP TABLE Sales.MyCustomers;
    
SELECT * INTO Sales.MyCustomers
FROM   Sales.Customers;

ALTER TABLE Sales.MyCustomers
ADD CONSTRAINT PK_MyCustomers PRIMARY KEY(custid);

SELECT * INTO Sales.MyOrders
FROM   Sales.Orders;

ALTER TABLE Sales.MyOrders
ADD CONSTRAINT PK_MyOrders PRIMARY KEY(orderid);

SELECT * INTO Sales.MyOrderDetails
FROM   Sales.OrderDetails;

ALTER TABLE Sales.MyOrderDetails
ADD CONSTRAINT PK_MyOrderDetails PRIMARY KEY(orderid, productid);

-- ����� ������ ������ 0.05 ��� ��� ��������� �� ������� �볺����� � �����㳿
SELECT od.discount
FROM TSQLFundamentals2008.Sales.OrderDetails AS od
INNER JOIN TSQLFundamentals2008.Sales.Orders AS o ON o.orderid = od.orderid
INNER JOIN TSQLFundamentals2008.Sales.Customers AS c ON c.custid = o.custid
WHERE c.country = N'Norway';


UPDATE od
 SET od.discount += 0.05
FROM TSQLFundamentals2008.Sales.OrderDetails AS od(NOLOCK)
INNER JOIN TSQLFundamentals2008.Sales.Orders AS o(NOLOCK) ON od.orderid = o.orderid
INNER JOIN TSQLFundamentals2008.Sales.Customers AS c(NOLOCK) ON c.custid = o.custid
WHERE c.country = N'Norway';

-- �� ������������ ����������� UPDATE
SELECT c.custid, c.postalcode, mo.shippostalcode
FROM TSQLFundamentals2008.Sales.MyOrders AS mo
INNER JOIN TSQLFundamentals2008.Sales.MyCustomers AS c ON mo.custid = c.custid
ORDER BY c.custid

-- � ������ ����� ���� ��� ��������� ������������ �������� ������ � ����������� �� ����
-- �������������� ��� � ��� ���� ������� ��� ���� ��� ������� � �� shippostalcode
UPDATE mc
 SET mc.postalcode = mo.shippostalcode
FROM TSQLFundamentals2008.Sales.MyCustomers AS mc
INNER JOIN TSQLFundamentals2008.Sales.MyOrders AS mo ON mo.custid = mc.custid

SELECT c.custid, c.postalcode
FROM TSQLFundamentals2008.Sales.MyCustomers AS c
ORDER BY c.custid

-- ������������� update
UPDATE c
 SET c.postalcode = o.shippostalcode
FROM TSQLFundamentals2008.Sales.MyCustomers AS c
CROSS APPLY(
	SELECT TOP(1) o.shippostalcode
	FROM TSQLFundamentals2008.Sales.Orders AS o
	WHERE o.custid = c.custid
	ORDER BY o.orderdate, o.orderid 
) AS o

/*******************************************
 * ��������� �����
 *******************************************/
-- ������ ������ �������
IF OBJECT_ID('Sales.MyOrderDetails', 'U') IS NOT NULL
    DROP TABLE Sales.MyOrderDetails;
IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL
    DROP TABLE Sales.MyOrders;
IF OBJECT_ID('Sales.MyCustomers', 'U') IS NOT NULL
    DROP TABLE Sales.MyCustomers;
SELECT * INTO Sales.MyCustomers
FROM   Sales.Customers;

ALTER TABLE Sales.MyCustomers
ADD CONSTRAINT PK_MyCustomers PRIMARY KEY(custid);

SELECT * INTO Sales.MyOrders
FROM   Sales.Orders;

ALTER TABLE Sales.MyOrders
ADD CONSTRAINT PK_MyOrders PRIMARY KEY(orderid);

SELECT * INTO Sales.MyOrderDetails
FROM   Sales.OrderDetails;

ALTER TABLE Sales.MyOrderDetails
ADD CONSTRAINT PK_MyOrderDetails PRIMARY KEY(orderid, productid);

-- ���������� DELETE ���� ���� ������ ��������� ������� ���������� ��������� ���� ��������
-- � ������ 
WHILE 1 = 1
BEGIN
	DELETE TOP(1000) FROM TSQLFundamentals2008.Sales.MyOrderDetails AS mo
	WHERE mo.productid = 12
	
	IF @@ROWCOUNT < 1000 BREAK;	
	
END

/*******************************************
 * �������
 *******************************************/
USE TSQLFundamentals2008
GO

IF OBJECT_ID('Sales.ProcessCustomer') IS NOT NULL DROP PROC Sales.ProcessCustomer;
GO

CREATE PROC Sales.ProcessCustomer(@custid INT) AS
 PRINT 'Processing customer ' + CAST(@custid AS VARCHAR(10));
GO

-- ������� �������
DECLARE @custid INT;
DECLARE cust_cursor CURSOR FAST_FORWARD FOR SELECT custid FROM TSQLFundamentals2008.Sales.Customers;

OPEN cust_cursor
FETCH NEXT FROM cust_cursor INTO @custid
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC TSQLFundamentals2008.Sales.ProcessCustomer
		@custid = @custid
	FETCH NEXT FROM cust_cursor INTO @custid
END
CLOSE cust_cursor
DEALLOCATE cust_cursor;

-- ��� ���� ����� �� ��������� ������ ������������ ������
DECLARE @custid INT;
SET @custid = (SELECT TOP(1) custid FROM TSQLFundamentals2008.Sales.Customers ORDER BY custid);
WHILE @custid IS NOT NULL
BEGIN
	EXEC TSQLFundamentals2008.Sales.ProcessCustomer
		@custid = @custid
	SET @custid = (SELECT TOP(1) custid FROM TSQLFundamentals2008.Sales.Customers WHERE custid > @custid ORDER BY custid)
END

-- �������� ������� ������� ��� ������� ���� ����� � �������� �������
USE TSQLFundamentals2008
GO

IF OBJECT_ID('dbo.GetNums','IF') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO

CREATE FUNCTION [dbo].GetNums(@low AS BIGINT,@hight AS BIGINT) RETURNS TABLE
AS
RETURN
 WITH 
	L0 AS (SELECT c FROM(VALUES(1),(1)) AS d(c)),
	L1 AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
	L2 AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
	L3 AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
	L4 AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
	L5 AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
	Nums AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn 
			 FROM L5)
 SELECT @low + n.rn - 1 AS n
 FROM Nums AS n
 ORDER BY n.rn
 OFFSET 0 ROWS FETCH NEXT @hight - @low + 1 ROWS ONLY
 
 GO
 
 -- �������� �������
USE TSQLFundamentals2008
GO

IF OBJECT_ID('dbo.Transactions','U') IS NOT NULL DROP TABLE dbo.Transactions;
GO

CREATE TABLE dbo.Transactions 
(
	actid INT NOT NULL,
	tranid INT NOT NULL,
	val MONEY NOT NULL,
	CONSTRAINT PK_Transactions PRIMARY KEY(actid,tranid)	
)

DECLARE @num_partitions INT = 100;
DECLARE @rows_per_partition INT = 10000;

TRUNCATE TABLE dbo.Transactions;

INSERT INTO TSQLFundamentals2008.dbo.Transactions WITH(TABLOCK) (actid,tranid,val)
SELECT np.n, rp.n, (ABS(CHECKSUM(NEWID())%2)*2-1) * (1 + ABS(CHECKSUM(NEWID())%5)) 
FROM TSQLFundamentals2008.dbo.getnums(1,@num_partitions) AS np
CROSS JOIN TSQLFundamentals2008.dbo.getnums(1,@rows_per_partition) AS rp

-- ������� ���������� ��������
SELECT 
	   tn.actid, tn.tranid, tn.val,
	   (SELECT SUM(tn1.val) 
	    FROM TSQLFundamentals2008.dbo.Transactions AS tn1
	    WHERE tn1.actid = tn.actid AND tn1.tranid <= tn.tranid ) AS tot_run_sum
FROM TSQLFundamentals2008.dbo.transactions AS tn
ORDER BY tn.actid, tn.tranid

-- �� � ���� �� ����� �������
DECLARE @Result TABLE 
(
	actid INT,
	tranid INT,
	val MONEY,
	balance MONEY
) 
DECLARE @actid INT,
		@prvactid INT,
		@tranid INT,
		@val MONEY,
		@balance MONEY

DECLARE C CURSOR FAST_FORWARD FOR 
			 SELECT t.actid,t.tranid,t.val
			 FROM TSQLFundamentals2008.dbo.Transactions AS t
			 ORDER BY t.actid,t.tranid;
OPEN C
FETCH NEXT FROM c INTO @actid,@tranid,@val;
SELECT @prvactid = @actid, @balance = 0
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @actid <> @prvactid
		SELECT @prvactid = @actid, @balance = 0
	SET @balance = @balance + @val;
	INSERT INTO @Result(actid,tranid,val,balance)
	VALUES(@actid,@tranid,@val,@balance);
	FETCH NEXT FROM C INTO @actid,@tranid,@val;		
END			  		
CLOSE C;
DEALLOCATE C;

SELECT * FROM @Result;

-- ��� ���� �� ��������� ������� ������������ ������� 2012
SELECT t.actid,t.tranid,t.val,
	   (SUM(val) OVER (PARTITION BY actid ORDER BY t.tranid
						   ROWS unbounded preceding)) AS balance
FROM TSQLFundamentals2008.dbo.Transactions AS t

-- �������� ����� ���� �� ����� ������� ������ ���������� �������� � �������
DECLARE @Result TABLE 
(
	actid INT,
	mx MONEY
)
DECLARE @actid INT,
		@prvactid INT,
		@tranid INT,
		@val MONEY,
		@prevval MONEY
DECLARE C CURSOR FAST_FORWARD FOR
		  SELECT t.actid,t.tranid,t.val
		  FROM TSQLFundamentals2008.dbo.Transactions AS t
		  ORDER BY t.actid,t.val
OPEN C
FETCH NEXT FROM C INTO @actid,@tranid,@val
SELECT @prevval = @val, @prvactid = @actid
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @actid <> @prvactid
		INSERT INTO @Result(actid,mx) VALUES(@prvactid,@prevval)
	SELECT @prevval = @val, @prvactid = @actid
	FETCH NEXT FROM C INTO @actid,@tranid,@val
END		  	

IF @prvactid IS NOT NULL
	INSERT INTO @Result(actid,mx) VALUES(@prvactid,@prevval)	
CLOSE C;
DEALLOCATE C;

SELECT *
FROM @Result

-- ������ ������ �� ����� ������
SELECT t.actid, MAX(t.val)
FROM TSQLFundamentals2008.dbo.Transactions AS t
GROUP BY t.actid

/*******************************************
 * �������� ������� � ������� ������
 *******************************************/
-- �������� ������� ������� ������� (#T) � �������� (##T)
-- ������� �������� ������� � ����� ����� � ����� ���� �� �������;
-- ��� ������ ������ ���� �������� ������� � ���������� ������� � ����� 
-- ����� ���� ������ ���� �������� ������� - ������ ���� ������ �� ���� ��� ���� ����
-- ������� � ������;
-- ������� �������� ������� � ����� ������ ���� ���� �� ������� - � ������� �� ������ ����� �������
-- ���� �������� ��������� ������� �� �������� ���� ���� ���� �������� ���� ���������� ���� ���� �� �������;
-- �������� �������� ������� ���� ��� ��� ������, ���� ����������� ������� ���� �� ��������� ��� ����
-- �� ���� �������� ������ �� ���;
-- ������� ���� ���� ����� ������ ���� �� ������� � ����������� ����������� � ���� ������
-- ���� �� ����� ����� ������� � ����� ����� �������

-- ��������� ��� ������ �� �������� ������� � ����� ����� ������� � ����� �������
CREATE TABLE #T1
(
	col1 INT NOT NULL
);
INSERT INTO #T1  (col1) VALUES  (10);
EXEC ('SELECT col1 FROM #T1;');
GO
SELECT col1
FROM   #T1;
GO
DROP TABLE #T1;
GO

-- ��������� ��� ������ �� ������� ���� �� ����� ��� ��� ����� ������
CREATE TABLE #T1
( col1 INT NOT NULL );
INSERT INTO #T1(col1) VALUES(10);
EXEC('SELECT col1 FROM #T1;');
GO
SELECT col1 FROM #T1;
GO
DROP TABLE #T1;
GO

-- �������� ������� ����������� � ��� tempdb � �� ��� ����������� ����� �������� �������
-- ������� � ���������� ������� � ����� ������� ������� ������ ���� ������ �� ����; 
-- ����� ���� �������� �������� ������� � ����� ������� � ��������� ������ ��������� �� ����
-- �������� ����� ���� �������, � ���� ������ ���� ��������� ��������;

-- ���� ���������� �������� ������� � ����� ������� �� ����� ������ ���� ������ � �������
-- ����������� � ��������
CREATE TABLE #T1
(
	col1     INT NOT NULL,
	col2     INT NOT NULL,
	col3     DATE NOT NULL,
	CONSTRAINT PK_#T1 PRIMARY KEY(col1)
);

-- ����� � ������� �������� - �� ����������� ���� ��� �������� � ���������� ��������
CREATE TABLE #T1
(
	col1     INT NOT NULL,
	col2     INT NOT NULL,
	col3     DATE NOT NULL,
	PRIMARY KEY(col1)
);

-- � sql server ����� ���������� ��������� �� ���������� �������� ���� ��������� �������
CREATE UNIQUE NONCLUSTERED INDEX idx_col2 ON #T1(col2);

CREATE NONCLUSTERED INDEX idx_col2 ON #T1(col2);

-- ��� ��������� ������ �� ������������ ��������� ���� ��� �������� ����� � ������ �����
-- �������� ������ ����������� ��������
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            CONSTRAINT PK_@T1 PRIMARY KEY(col1)
        );
        
-- � �� ������ ����������� ������
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            PRIMARY KEY(col1)
        ); 
        
-- �� ����� �������� ��������� �� ������� �������� �����        
-- �������� �� ��� �������� ���������� ����� ��� ���� ���������� ������ ������� �� ������� ���������������
-- ������, � ��� �������� ��������� ���������� �������� ����������������� ������, ���� ���� �������
-- ������� ������ �� �������� ����� �� ����� ������� � �����
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            PRIMARY KEY(col1)
        );
        
-- �������� ������� � ����� ������� ���� ����� ������������� � ��� ����� tempdb
-- ������� ������ CTE ��������� ������������� �� �����

-- ���������� �������� � ����������� ��������� ��������� ��� ���� �� � ����������
-- ��������� � ���������� ����� ���� �� ��������� ������� ������ ������ 
-- ������� ����������
CREATE TABLE #T1
( col1 INT NOT NULL );
BEGIN TRAN
	INSERT INTO #T1(col1) VALUES(10);
ROLLBACK TRAN
SELECT col1 FROM #T1;
DROP TABLE #T1;
GO             

-- ���� ���������� �� ��������� ������ � ���������� �� ����������
DECLARE @T1 AS TABLE
( col1 INT NOT NULL );
BEGIN TRAN
	INSERT INTO @T1(col1) VALUES(10);
ROLLBACK TRAN
SELECT col1 FROM @T1;

/*******************************************
 * ����������
 *******************************************/
USE TSQLFundamentals2008
GO

DROP TABLE #T1;
GO

SET STATISTICS IO ON;

CREATE TABLE #T1
(
	col1     INT NOT NULL,
	col2     INT NOT NULL,
	col3     DATE NOT NULL,
	PRIMARY KEY(col1),
	UNIQUE(col2)
);
--CREATE NONCLUSTERED INDEX idx_t1_1 ON #T1(col2);

INSERT INTO #T1(col1, col2, col3)
SELECT n, n * 2, CAST(SYSDATETIME() AS DATE)
FROM TSQLFundamentals2008.dbo.GetNums(1,1000000) 

-- ��������� ��� � �������
SELECT t.col1,t.col2,t.col3
FROM #T1 AS t
WHERE t.col2 <= 5

-- �� ��� ��� �������� ��������� ����� �� �������� �����
-- � ������ ������� ���� ���� �� ����� ����������
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            PRIMARY KEY(col1),
            UNIQUE(col2)
        );
INSERT INTO @T1(col1, col2, col3)
SELECT n, n * 2, CAST(SYSDATETIME() AS DATE)
FROM dbo.GetNums(1, 1000000);

SELECT col1, col2, col3
FROM @T1
WHERE col2 <= 5;
GO

SET STATISTICS IO OFF;

-- ����� ������� ��������� �������� : ������� ���� ����� ��������������� � ���� �������� 
-- 1) ���� ������� ����� ���� � ���� ��������� ������ �� �� ��������
-- 2) ���� ���� ���� �������, �� ������ �� ���� ����� ���� �������� ���� � ����������� �� ������
--    ��������� ��� ��������� ������

-- ���������
-- ����� ��������� ������� ��������� �� �� � ������ �� �������� � ��������� �����
;WITH cte AS (
	SELECT YEAR(o.orderdate) AS yr
		 , COUNT(*) AS nums
		 , ROW_NUMBER() OVER (ORDER BY YEAR(o.orderdate)) AS rn
	FROM TSQLFundamentals2008.Sales.Orders AS o
	GROUP BY YEAR(o.orderdate)
)
SELECT c.yr, c.nums AS curr_year_nums, (c.nums - ISNULL(c2.nums,0)) AS prev_year_nums
FROM cte AS c
LEFT JOIN cte AS c2 ON c.rn = c2.rn + 1 

-- ������� ��������� ����� ���� ����������� ��� ���� ����� ����������� ��������� �������� �����
-- � ������ ������� ������ �� ���������, ���������� � ������� ������� ����� �������� ����� ����
-- ��� � ��������� ��������� � ��������� ������� ���� ����� � �����������
DECLARE @result TABLE(
	yr INT,
	num_ords BIGINT,
	rn BIGINT
)

INSERT INTO @result(yr,num_ords,rn)
SELECT  YEAR(o.orderdate) AS yr
	  , COUNT(o.orderdate) AS num_ords
	  , ROW_NUMBER() OVER (ORDER BY YEAR(o.orderdate)) AS rn
FROM TSQLFundamentals2008.Sales.Orders AS o
GROUP BY YEAR(o.orderdate)

SELECT r1.yr, r1.num_ords AS curr_yr_ords, (r1.num_ords - ISNULL(r2.num_ords,0)) AS prev_yr_ords
FROM @result AS r1
LEFT JOIN @result AS r2 ON r1.rn = r2.rn + 1

/*******************************************
 * �������ֲ�
 *******************************************/
-- ���������� - �� ������ ������� ������. 
-- �� ���� � ��� ����������� �� ��������� ����������, ������ �������
-- �� �������� �� ������� ���� � ���� ������������ sql server �� ����������
-- 1) �� ���������� ���� ����� ����� DDL (CREATE TABLE,CREATE INDEX)
-- 2) �� ���������� ������� ����� DML (insert,update,delete)
-- ACID (atomicity,consistency,isolation,durability)
-- atomicity - ����� ���������� � ��������� �������� ������, ����� ��� ���������� ��� ��� �����
-- consistency - ����� ���������� ��� � ��������� ��� ��������� ������ ���� � ������������� ���������, ���
-- ���������������� ������ ������� ����� ����������
-- isolation - ����� ���������� ���������� ��� ��� ���� ���� � �������� �� ��������� �� ��� ����� ����������
-- ���� ���� ����������� ����� ������ ��� � �� ��� ���� � ��� ������� �������� ���� ����������� ����
-- durability - ����� ���������� ������� �� ����������� ������. ���� ����� ������������ �� �������� 
-- ���������� ���������, �� ���������� �����������

-- �������� ���������� ������������� �� ��������� �������� ���������� � ��������� �����
-- sql server ����� ��'���� (������ � �������) ��� ���� ��� �������� ��������� ����� ���������� 
-- � 䳿 ���� ����������
-- ������� ����������� ����� ���������� �� ���������� ACID, ��� ���� ��� ����������� �� �������� �����
-- � ��� �� ���� ��������
-- ������� ���������� ���������� �� ��������� ���� �� ������ ������ �� ���������� � ������

-- ������ ����������
SELECT * FROM sys.dm_tran_active_transactions AS dtat

-- ����� ���������� � �� ���� ����� ��������� �� ��������� ���� ��������� �������
-- @@TRANCOUNT - �������� �������� ����� ��������� ����������
-- XACT_STATE() - �������� ��������� ���� ����������

-- ������ ����������
-- autocommit (DDL/DML)
-- implicit transaction (������)
-- explicit transaction (����)

-- ROLLBACK ������ ������ ����� �񳺿 ���������� �� ������� �� ���� ������ � �����
-- ���������� ���������� � �� ����� ��� ��������� �� �������

-- ��� ���� ��� ����������� �������� �񳺿 ���������� ������� ������� �������� �� ����
-- ���������� COMMIT �� ����� ����� ����������, ��� ���� ����� ������� ������� COMMIT �����
-- ����� ��� ����������

USE TSQLFundamentals2008
GO

BEGIN TRAN MyFirstTranInLife

ROLLBACK

-- ��� �������� �������� ���������� sql server ������ ���� ��������� ����������
-- �� �������� ��� ���� ��� ������ :
-- 1) shared locks (�����������) ���������������� ��� ������ �� ��������� ������� ����� 
-- 2) exclusive locks (���������) ���������������� ��� ����������� �����, ����� �������� ������

-- ���������� ���������� ������ ������ � ������� ���������� ����� ���� �� ����������� ����������
-- ���� �� ����� � ���������� ���������� �� ������, ������� ��� ������ ��'��� ���� ���� ���������� 
-- �� ���� ������ ���, ���� ������� ���������� �� ���� ��������� ��� ��������
-- �� ����������� ��������� ��������� ���� ������ �� ������ ����� ������ ���������� � ������������
-- ����� ��'����

-- �������� ���������
-- ���� ����� ������ ����� ������� ����� �� ������������ sql server ������� ����� ���� ������ 
-- shared ���������� �� ��'���; ��� � ����� ������ ������ ������ ��� � � � ���
-- ��� ���� ����� �� ������ � ����������� �����������, ���� ������ �� ������ ���������� �������
-- ��� ����������� ����� �������

-- ����������
-- ���������� ������ � ������� ���� ���� ����� ������ ���������� ���������� ������� �� ����������
-- ������ ������ ����� ����� �������� ��������� ���������� ����� �������
-- � ���������� ��������� ���������� ����������� �� ���� ���������� ���� ���� ������ ����� ������
-- ����������, ������ ������� ������ ���� ������ �� ��������� ��� �� �������� ����������

-- ���������� ���������� ����� ���� ��������� ����� �� ������� ���� ������ ������� ������� shared 
-- ����������, ���� �� ���������� ���������� �������� ����� � � shared �����������

-- ����� ������� (share block) �� ������ ��������� ���� ����� ������� ������� ���� ����� �� �����
-- ����� ������� ������ ����� ��������� ����� ������, ������� ���� ���� ������ ������� ������� ������
-- ���� shared ���������� �� ���� ���������

-- �� ���������� �� ��������� ��� � � � 䳿 � ���������� ����������� ��������� �� ���������������
-- �� ���������� �� ��������� ��� � � � 䳿 � �������� ����������� �� ���������� ���������������

-- ���������� select ����� ���� ����� ������ � �������������� : ���� select ����� ������ �� ����������
-- ����������� ����� ����������, � ���� ���������� select �� ���� ����������� ��� �� ���� ����������� 
-- ������ ����������� �� ������ ���� ���������������

-- ���������� ��� ��������������� ����� �������� ��� �������� ������� ���� ������ ������������ 
-- ACID - ������������ ����������; sql server �������� ���� ���������� ������ ��� ���� ��� ����������
-- ���� ����� ������ ������������ ���� ���� ���������� ������ ������� ����� �� ��������� ������������
-- ���� �������� ����������
-- �� ������� ����� ����������������� ���� ���������� ���������� ������� :
-- 1) read committed - �� ����� �������� �� ������������; �� ����� ������� ����� ������ ����������
--    ������� ����� ��� ������� ����� �� ���� ����������; �� select ���������� ������ ����������
--    �������� shared ���������� � ���� �� ����� ������� �� ��������� � ����� ��������� ���������
--	  ������ ��������� ����� read committed
-- 1.1) read committed snapshot - �� �� ����� �����, � ���������� ����� ������������ read committed;
--		1. ����� ���� ��������� RSCI; �� ����������� ���� tempdb ��� ���������� ���������� �����
--		   ������� �����; �� ���� ����������� ������ ������ ���������, ��� ��������� �������
--		   ������� ����� ��� � �� ����������� ����; � ��������� ����������� select ����� �� ������
--		   shared ���������� �� ������ ��� ��������� ������ ������������ �����;
--		2. ������������ read committed snapshot ���������� �� ��� ���� ����� � � �������� ���������� ����
--		3. RSCI - �� �� ������� ����� ��������; �� ������ ����� ����� ��������� READ COMMITTED, ���� �������
--		   ���������� ������ ������� �������� ������;
-- 2) read uncommitted - ��� ����� �������� �������� ������ ������������ ���; �� ������������ �������
--    shared ���������� �� ������� ������������ select ��� �� ����� ������� ����� �� ����������
--    �������� ������; �� ���������� "dirty read"
-- 3) repeatable read - ��� ����� �������� ������� �� ��� �������� � ���������� ������ ��� ���� �����
--    �������� � ����������; �� ������������ �������� ��������� ��� ����������� ���������� ����� � ����� �����;
--	  � ��������� shared ���������� ����������� �� ���� ����������; ����� ���������� ���� ������ ��� ������
--	  ����� ���� ����� �������� �������; �� ���������� ��������� �������� (update lost problem ���������)
-- 4) snapshot - ��� ����� ����������� ��������� ������� ����� � ��� tempdb (�� RSCI); �� ���������� ��
--    ������� �������� ���� ���� �������������� �� ������ ����������; ���������� ��� ����������� ��� �����
--    ���� ��������� ���� ��� �������� ������� (repeatable read), � �� ���� ������ ����� ��������� ������;
--    ������� snapshot �������� ������� ����� �� �� ���������� ����� shared ��������� �� ������� �����
-- 5) serializable - ��� ����� � ������� ������� � �������������� �� �����; �� ����� ��� �� �������� �
--    repeatable � ��� ������, �� ������������ ����� � select ���������� �� ������ ���� ����� � �������

-- Repeatable read prevents only non-repeatable read. Repeatable isolation level ensures that the data that one 
-- transaction has read, will be prevented from beeing updated or deleted by any other transaction, but it do
-- not prevent new rows from beeing inserted by other transaction resulting in phantom read concurency problem.

-- Serializable prevents both non-repeatable read and phantom read problems. Serializable isolation level ensures
-- that the data that one transaction has read, will be prevented from beeing updated or deleted by any other 
-- transaction. Is also prevents new rows from beeing inserted by other transactions, so this isolation level 
-- prevents both non-repeatable read and phantom read problems.

-- ��� �������� �������������� �� �����; ���� ��� ��� �������� �� ��������������� �� ����� �� ����������
-- ������ ������������ �� ��������� ���� �� ������������ (read committed); 

-- ���� ����� ����������� ����� �������� READ COMMITTED ������ ��� ���� ������ �������� ����� ������ ������������
-- ��� �������������� ��� ����� �� WITH (NOLOCK) ��� WITH (READUNCOMMITTED); �������� ���� �������� ��� ������ ��
-- ��������� ��������� ����� �������������� ������� �������;

-- �� ���� �������, ��� ���� ��� �������� ���������� ������ ������ �������� ������� � ��� ����� ����������� �� �����
-- ������� ������ ����� ���������� ��� ������� ��������������� �������� (RSCI) �� ��� READ COMMITTED; ����� �������
-- ������ ���� ���� ���� ������� ����� ��� �������� ����������, ��� �� ������������ � ����� ������ ���

-- Loging deadlocks
-- ������� ������
DBCC TRACESTATUS (1222)

-- �������� ���������
DBCC TRACEON (1222,-1)

-- ���������
DBCC TRACEOFF (1222,-1)

-- ��������� ���������
EXEC sp_readerrorlog

/*******************************************
 * ������� �������
 *******************************************/
-- ���� ������ ������� ������� �������� ������� @@ERROR ���� ������ ������ ���� �������� ������ �������
-- ���� ���� try/catch ����������� ��� ������� ���� �������� �볺��� � �� ���� ���� ����������� � ��� SQL
-- ��� ���� ����� ��������� ������� �� ��������� ������
-- raiseerror (sql server < 2012)
-- throw (sql server >= 2012)
-- try/catch ���� �� ���� ���� ������������ � ��������

DECLARE @message VARCHAR(100) = 'Error in %s stored procedure'
SELECT @message = FORMATMESSAGE(@message,'MY')
--RAISERROR(@message,16,0)
;THROW 50000,@message,0

-- ���� �������� �������� �� ���� ��������� � �� �� RAISEERROR �� ������� ������ ������, � THROW �������
RAISERROR ('The error',16,0)
PRINT 'raise error'

throw 50000,'The error',0
PRINT 'throw error'

-- TRY_CONVERT i TRY_PARSE
-- TRY_CONVERT - ���������� �������� �������� �� �������� ���� ��� ������� NULL
SELECT TRY_CONVERT(DATETIME,'1788-03-343')
SELECT TRY_CONVERT(DATETIME,'1990-01-01')

-- TRY_PARSE - ������ ��� � �������� ����� � ���������� ����������� �� � ���������� ��� ��� ������� NULL
SELECT TRY_PARSE('1' AS integer) 
SELECT TRY_PARSE('B' AS integer) -- ������������ ���������� CAST/PARSE

-- ��� ���� ��� �������� ����������� ��� ������� ����� ��������������� ����� ���� ������� ����� catch:
-- 1. error_number - ������� ����� �������
-- 2. error_message - ������� ����������� ��� �������
-- 3. error_severity - ������� ����� ���������� �������
-- 4. error_line - ������� ����� ������ � ����� �� �������� �������
-- 5. error_procedure - ��� �������, ������, ������� �� ������������ � ������ �����
-- 6. error_state - ���� �������

BEGIN TRY
	RAISERROR('Hello try',16,0)
END TRY
BEGIN CATCH
	
		SELECT *
		from TSQLFundamentals2008.dbo.GetErrors()
	
END CATCH

-- ���������
-- 1. ������ � ����������������� ���������
USE TSQLFundamentals2008
GO

DECLARE @errnum AS INT;
BEGIN TRAN
	SET IDENTITY_INSERT Production.products ON;
	INSERT INTO production.Products
	(
		productid, -- this column value is auto-generated
		productname,
		supplierid,
		categoryid,
		unitprice,
		discontinued
	)
	VALUES
	(
		1,
		N'Test1: Duplicate product',
		1,
		1,
		18.0,
		0		
	)
	SET @errnum = @@ERROR
	IF @errnum <> 0 
	BEGIN
		PRINT 'Insert into products failed with error ' + CAST(@errnum AS VARCHAR);		
	END
	
	GO
	IF @@TRANCOUNT <> 0 ROLLBACK TRAN

-- 2. ��������������� ������� �������
USE TSQLFundamentals2008
GO

DECLARE @errnum AS INT;
BEGIN TRAN
	SET IDENTITY_INSERT Production.products ON;
	INSERT INTO production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued)
	VALUES(1,N'Test1: Duplicate product',1,1,18.0,0)
	SET @errnum = @@ERROR
	IF @errnum <> 0 
	BEGIN
		IF @@TRANCOUNT > 0 
		BEGIN
			PRINT 'Rollback. Counter = ' + CAST(@@TRANCOUNT AS VARCHAR)
			ROLLBACK TRAN
		END 
		PRINT 'Insert into products failed with error ' + CAST(@errnum AS VARCHAR);		
	END	
	
	PRINT 'Rollback. Counter = ' + CAST(@@TRANCOUNT AS VARCHAR)
	
	INSERT INTO production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued)
	VALUES(1,N'Test1: Duplicate product',1,1,18.0,0)
	SET @errnum = @@ERROR
	IF @errnum <> 0 
	BEGIN
		IF @@TRANCOUNT > 0 
		BEGIN
			PRINT 'Rollback. Counter = ' + CAST(@@TRANCOUNT AS VARCHAR)
			ROLLBACK TRAN
		END 
		PRINT 'Insert into products failed with error ' + CAST(@errnum AS VARCHAR);		
	END	
	SET IDENTITY_INSERT Production.Products OFF;	
	IF @@TRANCOUNT > 0 COMMIT TRAN
	
	-- SELECT * FROM Production.Products AS p
	-- ��������� ������ ������
	DELETE FROM Production.Products WHERE productid = 101
	PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows'
	
 -- 3. ������� ������� �������������
USE TSQLFundamentals2008
GO 
DECLARE @error_number AS INT,
        @error_message AS NVARCHAR(1000),
        @error_severity AS INT;
BEGIN TRY
	BEGIN TRAN;
		SET IDENTITY_INSERT Production.Products ON;
		INSERT INTO Production.Products(productid, productname, supplierid,categoryid, unitprice, discontinued)
		VALUES(1, N'Test1: Duplicate productid', 1, 1, 18.00, 0);
		INSERT INTO Production.Products(productid, productname, supplierid,categoryid, unitprice, discontinued)
		VALUES(101, N'Test2: New productid', 1, 10, 18.00, 0);
		SET IDENTITY_INSERT Production.Products OFF;
	COMMIT TRAN;
END TRY
BEGIN CATCH
	SELECT XACT_STATE()  AS 'XACT_STATE', @@TRANCOUNT   AS '@@TRANCOUNT';
	SELECT @error_number   = ERROR_NUMBER(),
	       @error_message  = ERROR_MESSAGE(),
	       @error_severity = ERROR_SEVERITY();
	--RAISERROR (@error_message, @error_severity, 1);
	IF @@TRANCOUNT > 0
	BEGIN
		PRINT 'Tran rollback...'
		ROLLBACK TRANSACTION;
	END
	;throw;	-- ������� ������� ��� ������� �볺���; ����� ��� �� ���� ������������ ���� ���� ����������
END CATCH;

GO

SELECT * FROM TSQLFundamentals2008.Production.Products AS p

-- ���������
USE TSQLFundamentals2008
GO

IF OBJECT_ID('Sales.ListCustomersByAddress') IS NOT NULL DROP PROCEDURE Sales.ListCustomersByAddress
GO

ALTER PROCEDURE [Sales].[ListCustomersByAddress]
 @address AS NVARCHAR(60)
AS

DECLARE @sql NVARCHAR(MAX);
SET @sql = N' 
 select companyname,contactname
 from tsqlfundamentals2008.sales.customers 
 where address = @address;';

EXEC sp_executesql @statement = @sql,
				   @params = N'@address NVARCHAR(60)',
				   @address = @address
RETURN;				   

-- call procedure
GO

EXEC TSQLFundamentals2008.Sales.ListCustomersByAddress @address = N'8901 Tsawassen Blvd.';

/*******************************************
 * �������
 *******************************************/
-- sql server ������� ������� � ����� ������ ����
-- 1. ���� ������� ����� (������� DML)
-- 2. ���� ����� ����� (DDL), ��� �� CREATE TABLE

-- DML �������
-- 1. AFTER - ��������� ����� ��� ���� ���� ��� � ��� ������� ����������� � ���� ���� ������������ �����
-- ��� �������� �������
-- 2. INSTEAD OF - ��� ������ ��������� ������ ��䳿 � ���� �� �������� � ���� ���� ��������� ��� ��������
-- ������� � �����
-- �� ��� ���� ������� ����������� �� ������� ���������� ������� � ����������� insert,update,delete
-- ������ ������� rollback tran � ��� ������� ������ ����� ��� ��� �� ���������� � ������ � ����� �����
-- ���������� DML � ���� �������� ������; ��� ������������ rollback ���� ���� ����� ������; ������ ���� �������
-- ����� �������� ������� throw / raiserror � ������������ ��� ����� ��������� ��������� ������� �������
-- ���������� ������� � ������� � ���������� RETURN �� � � ���� ��������

-- AFTER - ��� ����� ������� ���������� ��� ���� ���������� DML ������� �� ���������, ��� �� primary/foreign key
-- ���� ��������� �� �������� ���������� ���� ������� � ������ �� ����������			

USE TSQLFundamentals2008
GO

IF OBJECT_ID('Production.tr_ProductionCategories_catname','TR') IS NOT NULL DROP TRIGGER Production.tr_ProductionCategories_catname;
GO

ALTER TRIGGER Production.tr_ProductionCategories_catname
ON Production.Categories
AFTER INSERT,UPDATE 
AS 
BEGIN
	IF @@ROWCOUNT = 0 RETURN;
	SET NOCOUNT ON;
	IF EXISTS(SELECT COUNT(*) 
			  FROM INSERTED AS i 
			  INNER JOIN Production.Categories AS c ON c.categoryname = i.categoryname 
	          GROUP BY i.categoryname
	          HAVING COUNT(*) > 1)
	 BEGIN
	 	ROLLBACK TRAN
	 	RAISERROR ('Duplicates not allowed',16,1);
	 END
END

INSERT INTO Production.Categories(categoryname,[description])
VALUES('Testcat1','Testcat1 descr')

-- inserted,deleted ������ �������� ������� �������; update ���������� �� ��������� � ��������
-- �������� ���� ������ ��������� � deleted, � ���� ��� ������ ��������� � ������� ������� � ������� inserted
UPDATE Production.Categories
SET categoryname = 'Beverages'
WHERE categoryname = 'Testcat1'	

DELETE FROM Production.Categories WHERE categoryid = 13

-- �������� after ������ ���� �������� ���������� ��� ������� �� ����� ������
USE TSQLFundamentals2008
GO

IF OBJECT_ID('Sales.tr_SalesOrderDetailsDML','TR') IS NOT NULL DROP TRIGGER Sales.tr_SalesOrderDetailsDML
GO

CREATE TRIGGER Sales.tr_SalesOrderDetailsDML
ON Sales.OrderDetails
AFTER DELETE,INSERT,UPDATE 
AS
BEGIN
	IF @@ROWCOUNT = 0 RETURN;
	SET NOCOUNT ON;
	SELECT COUNT(*) AS inserted_rows FROM INSERTED;
	SELECT COUNT(*) AS deleted_rows FROM DELETED;	
END

DELETE FROM sales.OrderDetails
WHERE orderid = 10249 AND productid IN (15,16);

-- ��� ��������� ����� ���� �������� ������� ������� ����� ������
INSERT INTO sales.OrderDetails(orderid,productid,unitprice,qty,discount)
VALUES(10249,16,9.00,1,0.6),
	  (10249,15,9.00,1,0.4)

-- ������� ���� � ����� � �������� ���� ������ ����� ��������� � ���� ����� ����������
UPDATE Sales.OrderDetails
SET unitprice = 99.0
WHERE orderid = 10249 AND productid = 16	  

-- �������� �� ������ � �������� �� ����� ��������� ��� �� ����� �������
DELETE FROM Sales.OrderDetails
WHERE orderid = 10249 AND productid IN (15,16)

-- �������� ������ ��� ��������� ����� : ���� ���� ������� � ������� Sales.OrderDetails � ����� unitprice < 10
-- �� ���� ���� ������ ����� 0.5 
USE TSQLFundamentals2008
GO

IF OBJECT_ID('Sales.tr_SalesOrderDetails_DiscountLimit','TR') IS NOT NULL DROP TRIGGER Sales.tr_SalesOrderDetails_DiscountLimit;
GO

ALTER TRIGGER sales.tr_SalesOrderDetails_DiscountLimit
ON Sales.OrderDetails
AFTER INSERT,UPDATE 
AS 
BEGIN
	IF @@ROWCOUNT = 0 RETURN;
	SET NOCOUNT ON;
	
	DECLARE @unitprice AS MONEY,
			@discount AS DECIMAL(4,3);
	SELECT @unitprice = unitprice FROM INSERTED;
	SELECT @discount = discount FROM INSERTED;
	IF @unitprice < 10 AND @discount > 0.5 
	BEGIN
		ROLLBACK TRAN
		RAISERROR('Discount must be less than 0.5 when unitprice is less than 10$.',16,0)
	END
	--SELECT * FROM INSERTED
	--SELECT * FROM DELETED  
END

INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 16, 9.00, 1, 0.60),
	   (10249, 15, 9.00, 1, 0.40);	 
	   
UPDATE sales.OrderDetails
SET unitprice = 11.0
WHERE orderid = 10249 AND productid = 15	   
	   
SELECT * FROM Sales.OrderDetails AS od WHERE od.orderid = 10249
DELETE FROM Sales.OrderDetails WHERE orderid = 10249 AND productid IN (15,16);

-- � ������������ ������� ������ �� ���������
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40),
	   (10249, 16, 9.00, 1, 0.60);

-- ��� ������� ��� ������ ������ �� �� �������� ������� �����
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40)

INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 16, 9.00, 1, 0.60);	

-- ������� ������	   
ALTER TRIGGER sales.tr_SalesOrderDetails_DiscountLimit
ON Sales.OrderDetails
AFTER INSERT,UPDATE 
AS 
BEGIN
	IF @@ROWCOUNT = 0 RETURN;
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT * FROM INSERTED WHERE unitprice < 10 AND discount > 0.5)	
	BEGIN
		ROLLBACK TRAN
		RAISERROR('Discount must be less than 0.5 when unitprice is less than 10$.',16,0)
	END
END

-- ��������� ����� �������, �� ������ ����� ��� �� ������ ����� � �������
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 16, 9.00, 1, 0.60),
	   (10249, 15, 9.00, 1, 0.40);	
	    
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40),
	   (10249, 16, 9.00, 1, 0.60);	
	   
	   
	   
-- INSTEAD OF - ��������� ��������������� � view ��� ���� ��� ���������� ������� �� ������� � view
-- �������� view ��� ������� ����������
USE TSQLFundamentals2008
GO

ALTER VIEW Sales.vw_OrderDetails
AS 
 SELECT o.orderid, c.companyname, p.productname, od.unitprice, od.qty, od.discount
 FROM TSQLFundamentals2008.Sales.Orders AS o
 INNER JOIN TSQLFundamentals2008.Sales.OrderDetails AS od ON o.orderid = od.orderid 
 INNER JOIN TSQLFundamentals2008.Sales.Customers AS c ON o.custid = c.custid
 INNER JOIN TSQLFundamentals2008.Production.Products AS p ON od.productid = p.productid
GO

/*******************************************
 * INSERT TRIGER
 *******************************************/
USE TSQLFundamentals2008
GO

ALTER TRIGGER sales.tr_vwOrderDetails
ON sales.vw_OrderDetails
INSTEAD OF INSERT 
AS 
BEGIN
	--SELECT * FROM INSERTED;
	--SELECT * FROM DELETED;
	
	DECLARE @custid INT,
			@productid INT;
	
	-- customer id
	SELECT @custid = c.custid
	FROM TSQLFundamentals2008.Sales.Customers AS c
	INNER JOIN INSERTED AS i ON i.companyname = c.companyname
	
	-- product id
	SELECT @productid = p.productid
	FROM TSQLFundamentals2008.Production.Products AS p
	INNER JOIN INSERTED AS i ON i.productname = p.productname
	
	IF(@custid IS NULL OR @productid IS NULL)
	BEGIN
		RAISERROR('Customer ID or Product ID is incorrect.',16,1)
		RETURN
	END
	ELSE
	BEGIN
		PRINT 'Data inserted into Sales.Orders and Sales.OrderDetails tables.'
	END	
END

INSERT INTO TSQLFundamentals2008.Sales.vw_OrderDetails(orderid,companyname,productname,unitprice,qty,discount)
VALUES(12300,'Customer ENQZT','Product QMVUN',14.0,1,0.21)

/*******************************************
 * UPDATE TRIGER
 *******************************************/
USE TSQLFundamentals2008
GO

ALTER TRIGGER sales.tr_vwOrderDetails_Update
ON sales.vw_OrderDetails
   INSTEAD OF UPDATE
AS
BEGIN
	-- Check for changes have been made
	IF EXISTS(
	   SELECT * FROM   INSERTED 
	   EXCEPT	
	   SELECT *	FROM   DELETED
	)
	BEGIN			
		
		--SELECT * FROM DELETED 
		--SELECT * FROM INSERTED 
		-- Get previous product id for determination
		DECLARE @prevprodid TABLE(id INT);	
		
		INSERT INTO @prevprodid(id)	
		SELECT p.productid
		FROM   TSQLFundamentals2008.Production.Products AS p
		INNER JOIN DELETED AS d ON  d.productname = p.productname
		
		--SELECT * FROM @prevprodid
		
		-- Throw error when update orderid
		IF (UPDATE(orderid))
		BEGIN
		    RAISERROR('Order id cannot be changed.', 16, 1)
		    RETURN
		END
		
		-- update company name
		IF (UPDATE(companyname))
		BEGIN
		    DECLARE @custid INT;
		    
		    SELECT @custid = c.custid
		    FROM   TSQLFundamentals2008.Sales.Customers AS c
		    INNER JOIN INSERTED AS i ON  i.companyname = c.companyname
		    
		    IF (@custid IS NULL)
		    BEGIN
		        RAISERROR('Invalid companyname.', 16, 1)
		        RETURN
		    END
		    
		    UPDATE o
		    SET    custid = @custid
		    FROM   TSQLFundamentals2008.Sales.orders AS o
		    INNER JOIN INSERTED AS i ON  i.orderid = o.orderid
		END
		
		-- update product name
		IF (UPDATE(productname))
		BEGIN
		    DECLARE @productid INT;				
		    SELECT @productid = p.productid
		    FROM   TSQLFundamentals2008.Production.Products AS p
		    INNER JOIN INSERTED AS i ON  i.productname = p.productname				
		    
		    IF (@productid IS NULL)
		    BEGIN
		        RAISERROR('Product name is incorrect.', 16, 1)
		        RETURN;
		    END
		    
		    UPDATE od
		    SET    od.productid = @productid
		    FROM   INSERTED AS i
		    INNER JOIN TSQLFundamentals2008.Sales.OrderDetails AS od ON  i.orderid = od.orderid
		    INNER JOIN @prevprodid AS pv ON pv.id  = od.productid
		END
		
		-- update unit price
		IF (UPDATE(unitprice))
		BEGIN
		    UPDATE od
		    SET    unitprice = i.unitprice
		    FROM   INSERTED AS i
		    INNER JOIN TSQLFundamentals2008.Sales.OrderDetails AS od ON  i.orderid = od.orderid
		    INNER JOIN @prevprodid AS pv ON pv.id  = od.productid
		END
		
		-- update quantity
		IF (UPDATE(qty))
		BEGIN
		    UPDATE od
		    SET    qty = i.qty
		    FROM   INSERTED AS i
		    INNER JOIN TSQLFundamentals2008.Sales.OrderDetails AS od ON  i.orderid = od.orderid
		    INNER JOIN @prevprodid AS pv ON pv.id  = od.productid
		END
		
		-- update discount
		IF (UPDATE(discount))
		BEGIN
		    UPDATE od
		    SET    discount = i.discount		    		    		    
		    --SELECT *
		    FROM   INSERTED AS i
		    INNER JOIN TSQLFundamentals2008.Sales.OrderDetails AS od ON  i.orderid = od.orderid 
		    INNER JOIN @prevprodid AS pv ON pv.id  = od.productid
		    
		END
	END
END

-- SELECT * FROM TSQLFundamentals2008.Sales.vw_OrderDetails -- Customer ENQZT	Product QMVUN
 select * from TSQLFundamentals2008.Sales.OrderDetails where orderid = 10248 OR orderid = 10249
 SELECT * FROM TSQLFundamentals2008.Sales.Orders AS o WHERE o.orderid = 10248
 
 SELECT * FROM TSQLFundamentals2008.Production.Products AS p WHERE p.productid = 72 OR p.productname = 'Product QMVUN'
 SELECT vod.* FROM TSQLFundamentals2008.Sales.vw_OrderDetails AS vod WHERE vod.orderid = 10248 
 
 UPDATE TSQLFundamentals2008.Sales.vw_OrderDetails
 SET productname = 'Product QMVUN'
 WHERE orderid = 10248 AND productname = 'Product PWCJB' 
 
 UPDATE TSQLFundamentals2008.Sales.vw_OrderDetails
 SET qty = 14
 WHERE orderid = 10248 AND productname = 'Product QMVUN'
 
 UPDATE TSQLFundamentals2008.Sales.vw_OrderDetails
 SET unitprice = 14.00
 WHERE orderid = 10248 AND productname = 'Product QMVUN'
 
 UPDATE TSQLFundamentals2008.Sales.vw_OrderDetails
 SET discount = 0.1
 WHERE orderid IN (10248) AND productname IN ('Product QMVUN','Product GEEOO')
 
/*******************************************
 * DELETE TRIGER
 *******************************************/
USE TSQLFundamentals2008
GO

ALTER TRIGGER sales.tr_OrderDetails_Delete
ON sales.vw_OrderDetails
INSTEAD OF DELETE
AS
BEGIN
	-- Get previous product id for determination
	DECLARE @prevprodid TABLE(id INT);	
	
	INSERT INTO @prevprodid(id)	
	SELECT p.productid
	FROM   TSQLFundamentals2008.Production.Products AS p
	INNER JOIN DELETED AS d ON  d.productname = p.productname
		 
	DELETE od
	FROM TSQLFundamentals2008.Sales.OrderDetails AS od
	INNER JOIN DELETED AS d ON od.orderid = d.orderid
	INNER JOIN @prevprodid AS pv ON od.productid = pv.id
	
END

DELETE FROM TSQLFundamentals2008.Sales.vw_OrderDetails
WHERE orderid = 10248 AND productname IN ('Product QMVUN','Product RJVNM')

SELECT * FROM TSQLFundamentals2008.Production.Products AS p WHERE p.productid = 42

SELECT * FROM TSQLFundamentals2008.Sales.OrderDetails AS md
WHERE md.orderid = 10248 

-- Insert copy of OrderDetails rows from MyOrderDetails
INSERT INTO TSQLFundamentals2008.Sales.OrderDetails
(
	orderid,
	productid,
	unitprice,
	qty,
	discount
)
SELECT od.orderid, od.productid, od.unitprice, od.qty, od.discount
FROM TSQLFundamentals2008.Sales.MyOrderDetails AS od
WHERE od.orderid = 10248

/*******************************************
 * LOGON TRIGERS
 *******************************************/
-- ��������� ���������� ��� �� ����������
SELECT des1.is_user_process,des1.original_login_name, * 
FROM sys.dm_exec_sessions AS des1

-- �������� ������ ���� ����� ���������� ����������� ����� �� 3 ���
CREATE TRIGGER tr_AuditLogin
ON ALL SERVER
FOR logon
AS
BEGIN
	DECLARE @LoginName NVARCHAR(100);
	SET @LoginName = ORIGINAL_LOGIN();
	
	IF(SELECT COUNT(*) FROM sys.dm_exec_sessions AS ds 
	   WHERE ds.is_user_process = 1 AND ds.original_login_name = @LoginName) > 3
	BEGIN		
		PRINT 'Fourth connection attempt by ' + @LoginName + ' blocked'; -- ���� ����������� � ���� 
		ROLLBACK;
	END															
END

-- ��������� ���������� � ����
EXEC sp_readerrorlog


/*******************************************
 * INDEXES
 *******************************************/
-- sql server ��������� ������� � ���� ��� ����������� ������
-- �������, ��� ����������� � ������ �������������� ������ ���������� ��������������� �������� ���
-- ��������������� ��������
-- ���� - �� ���� ������� � ��������, ���� ���������� � 8�� �������
-- ������� �� ������ ���� ����� 8��
-- sql server ��������� �� ������� � �������� �������� ��'���� �� ��������� ��������� �������
-- �� ����������� ��������� ����� �������� ������� (Index allocation map, IAM); ����� ������� ��� ������
-- �� �� ������ �� ���� ������� IAM, ��� ���������� ������ �������� IAM. ���� ������� IAM ���� 
-- ��������� ��������� �� 4�� ��������; ����� ��'���� ������ ���� ����� ���� �������

-- �������� ������� ����������� � ������ ����
USE TSQLFundamentals2008
GO

CREATE TABLE dbo.TestStructure
(
	id INT NOT NULL,
	filler1 CHAR(6) NOT NULL,
	filler2 CHAR(6) NOT NULL
)

-- �������� ���������� ��� ������� � ������� ���� ���� ��������� � sys.indexes
USE TSQLFundamentals2008
SELECT OBJECT_NAME(i.[object_id]) AS table_name, i.name AS index_name,
	   i.[type], i.type_desc
FROM sys.indexes AS i
WHERE i.[object_id] = OBJECT_ID(N'dbo.TestStructure',N'U')

-- ����� �������� ������ ������� ������� �� ��'��� ��������� �����
SELECT index_type_desc,index_depth,index_level,page_count,record_count,avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(N'TSQLFundamentals2008'),OBJECT_ID(N'dbo.TestStructure'),NULL,NULL,'DETAILED') AS ddips

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure', @updateusage = TRUE

-- ������ ������� ������ � ������� 
INSERT INTO dbo.TestStructure(id,filler1,filler2)
VALUES(1,'a','b')

DECLARE @i INT = 0;
WHILE @i < 18000
BEGIN
	SET @i = @i + 1;
	INSERT INTO dbo.TestStructure(id,filler1,filler2)
	VALUES(@i,'a','b')
END

-- ������ ��������������� ������ �� �������
TRUNCATE TABLE TSQLFundamentals2008.dbo.TestStructure
CREATE CLUSTERED INDEX idx_cl_id ON TSQLFundamentals2008.dbo.TestStructure(id)
CREATE INDEX idx_TestStructure_f1 ON TSQLFundamentals2008.dbo.TestStructure(filler1)

ALTER TABLE TSQLFundamentals2008.dbo.TestStructure
ADD PRIMARY KEY (id)
-- �������� ������
USE TSQLFundamentals2008
DROP INDEX dbo.TestStructure.idx_TestStructure_f1

-- ��� ��������� ��� ������� �������
USE TSQLFundamentals2008
EXEC sp_helpindex teststructure

-- a clustered index determines the physical order of data in a table. For this reason, a table can 
-- have only one clustered index; 
-- PRIMARY KEY constraint create clustered indexes automatically if no clustered index already exists
-- on the table
-- non clustered index is stored separately from data then table can has more than one non clustered index;

-- clustered index is faster than non clustered because it contains data itself and no need to extra lookup for data
-- clustered index determines the storage order or rows in table and hense doesn't require additional disk space, but
-- non clustered index stores separately from data then it need additional disk space

-- there are no differences between Unique constraint and Unique index
-- when you create unique constraint nonclustered index is created behind the scenes
CREATE UNIQUE NONCLUSTERED INDEX uix_TestStructure_f1_f2 
ON TSQLFundamentals2008.dbo.TestStructure(filler1,filler2)

-- USEFULL points to REMEMBER
-- 1) by default PRIMARY KEY constraint creates unique clusted index,where as a UNIQUE constrastraint
-- creates a uniques non clustered index; these defaults can be changed if you with to;
-- 2) a UNIQUE constraint or a UNIQUE index cannot be created on an existing table, if the table
-- contains duplicates in columns. Obviously to solve this remove the key columns from the index 
-- definition or delete or updates duplicate values.

-- INSERT,UPDATE,DELETE statements can become slow because when data is modified, the data in all
-- indexes also needs to be updated. Index can help to find row that we want to delete but too many
-- indexes to update can actually hurt the performance of data modification

-- non clustered index requires additional space and it should use lookup for retrieve data that 
-- is not covered by index (not included)

/*******************************************
 * Table valued parameters
 *******************************************/
 USE TSQLFundamentals2008

 -- �������� ��� ����� �����������
 CREATE TYPE TestStructType AS TABLE
 (
 	Id INT PRIMARY KEY,
 	Fill1 CHAR(6),
 	Fill2 CHAR(6) 
 )
 
 -- �������� ���������
 CREATE PROCEDURE dbo.spInsertOrder
  @TestStructTp dbo.TestStructType READONLY
 AS 
 BEGIN
 	INSERT INTO TSQLFundamentals2008.dbo.TestStructure(id,filler1,filler2)
 	SELECT tp.Id, tp.Fill1, tp.Fill2
 	FROM @TestStructTp AS tp
 END
 
 -- ��������� ���������
 DECLARE @TestStructTp dbo.TestStructType
 INSERT INTO @TestStructTp VALUES (1,'a','b')
 INSERT INTO @TestStructTp VALUES (2,'c','d')
 INSERT INTO @TestStructTp VALUES (3,'e','f')
 
 EXEC dbo.spInsertOrder
  @TestStructTp = @TestStructTp   
 
 SELECT * FROM TSQLFundamentals2008.dbo.TestStructure AS ts
 
 SELECT * FROM TSQLFundamentals2008.Production.Products AS p 
 
 EXEC TSQLFundamentals2008.dbo.GetAllProducts 
 
 EXEC TSQLFundamentals2008.dbo.UpsertProduct
 	@ProductId = 1,
 	@ProductName = 'Product HHYDP',
 	@SupplierId = 1,
 	@CategoryId = 1,
 	@UnitPrice = 18.2,
 	@Discounted = 0  
 
 
 ---------------------------------------------------------------------------------------
 
;WITH cte AS(
	SELECT DISTINCT o.custid
	FROM TSQLFundamentals2008.Sales.Orders AS o
	WHERE o.orderid IN(10261,10268,10282,10293)
),
cte1 AS(
	SELECT o.custid,o.orderid,o.orderdate
	FROM cte AS c
	JOIN TSQLFundamentals2008.Sales.Orders AS o ON o.custid = c.custid
	CROSS APPLY(
		SELECT COUNT(DISTINCT o2.orderid) AS cs
		FROM TSQLFundamentals2008.Sales.Orders AS o2
		WHERE o2.custid = o.custid
	) ca
	WHERE ca.cs > 2
),
cte2 AS(
	SELECT c1.*,
		   ROW_NUMBER() OVER (PARTITION BY c1.custid 
							  ORDER BY c1.orderdate desc) AS rn
	FROM cte1 AS c1
)
--SELECT * FROM cte2
SELECT c2.*,ca.*
FROM cte2 AS c2
CROSS APPLY(
	SELECT TOP 1 *
	FROM cte2 AS c22
	WHERE c22.custid = c2.custid AND c22.rn > c2.rn AND c22.orderid <> c2.orderid
	ORDER BY c22.rn 
) ca
WHERE c2.rn = 1
ORDER BY c2.custid
