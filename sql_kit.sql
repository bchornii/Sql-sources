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

-- Functions
SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0) -- the first day of the month

SELECT DATEADD(dd,-1,DATEADD(mm,DATEDIFF(mm,0,GETDATE()) + 1,0)) -- the last day of the month

-- create string from table rows information
DECLARE @names VARCHAR(100) = NULL;
SELECT @names = COALESCE(@names + ',','') + e.firstname --@names = @names + COALESCE(e.firstname + ',','')
FROM TSQLFundamentals2008.HR.Employees AS e;
SELECT @names

-- string len in bytes and symbols
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

-- The first predicate is better because when some manipulation
-- is applied to filter columns server cannot use indexes effectively
DECLARE @dt DATE = NULL; --'20090101';
SELECT o.orderid,o.orderdate,o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.shippeddate = @dt OR (o.shippeddate IS NULL AND @dt IS NULL)

DECLARE @dt DATE = NULL; --'20090101';
SELECT o.orderid,o.orderdate,o.empid, o.shippeddate
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE COALESCE(o.shippeddate,'') = COALESCE(@dt,'')

-- Operation priority
-- 0.()
-- 1.NOT
-- 2.AND
-- 3.OR

-- TRY_CAST method returns 'NULL' when operation is not finished correctly
-- So, instead of throwing an error query will not return row in result data set
-- PS. You should remember that predicates in WHERE clause is not evaluated from
-- left to right (like code execution) but they are evaluated simultaneously, so
-- you cannot say that evaluation of vt.propertytype = 'INT' will be executed as the 
-- first one and if it 'false' all remaining evaluations will be skipped 
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

-- When search is running in form of "col1 LIKE 'ABC%'" SERVER could use index for filtering column (col1)
-- but when search template is '%ABC%' SERVER could not rely on index
-- '20070212' = ymd
-- '2007-02-12' = ymd is independent of machine location and language DATE,DATETIME2,DATETIMEOFFSET

-- Date and time formatting
SELECT o.orderid,o.orderdate,o.empid,o.custid 
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE YEAR(o.orderdate) = 2007 AND MONTH(o.orderdate) = 2;

-- but because of manipulation on filtration column SERVER could not rely on using of index

SELECT o.orderid,o.orderdate,o.empid,o.custid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.orderdate >= '20070201' AND o.orderdate < '20070301'

-- PS. Better to use '>=' and '<' operators when have a deal with dates instead of BETWEEN operator because
-- latter could round date value

-- Sorting
-- When DISTINCT and ORDER BY clause is used in the same query - result data set MUST contain
-- columns which are placed in ORDER BY and any others
-- If query does not contain DISTINCT operator it is not mandatory for result data set to contain
-- columns which are placed in ORDER BY clause
-- Ex. If different cities are selected which may contain more than one worker and ORDER BY clause 
-- contains worker's date of birth and at the same time DOB is not included in result data set
-- SERVER will not know which row shoud be selected in DISTINCT because one city contains 
-- few workers with different DOB

-- BAD QUERY
SELECT DISTINCT e.city
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE e.country = N'USA' AND e.region = N'WA'
ORDER BY e.birthdate

-- GOOD QUERY
SELECT DISTINCT e.city
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE e.country = N'USA' AND e.region = N'WA'
ORDER BY e.city

-- Sort of NULL values
-- when shippeddate is NULL then return 0, 
-- when shippeddate NOT NULL then return 1 
-- thus 0 will be before the 1 in ordering and therefore NOT NULL will be at the beginning
SELECT o.orderid, o.shippeddate
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 20
ORDER BY CASE WHEN o.shippeddate IS NULL 
			  THEN 1
			  ELSE 0 
         END, o.shippeddate 
         
-- not determinated sort - result data set contains column on which we do ORDER BY and this column contains several duplicates
-- determined sort - values in columnd on which we do ORDER BY shouldn't contain any duplicates

-- Filtering by TOP and FETCH ... OFFSET
SELECT TOP(1) o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

SELECT TOP(1) PERCENT o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

-- WITH TIES returns duplicates by 'orderdate' if any
SELECT TOP(1) WITH TIES o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

-- or make result determinated - for instance rows with greatest 'orderid' should be retrieved
SELECT TOP(3) o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC,o.orderid DESC

-- FETCH ... OFFSET
-- for now ORDER BY has two roles : 1) make fetch/offset aware which rows should be filtered
--								    2) оприделение сортировки представления в запросе
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

-- the most expensive goods of the first category
SELECT TOP (5) p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC

-- the previous data set result is not determinated - make it use ties
SELECT TOP (5) WITH TIES
	   p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC

-- and now lets make determination by using 'productid'
SELECT TOP (5) p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC, p.productid DESC

-- lets create pagenation view for retrieving products with ordering by 'unitprice' and
-- determination by 'productid'
DECLARE @page_size INT = 5;
DECLARE @page_num INT = 1;

SELECT *
FROM TSQLFundamentals2008.Production.Products AS p
ORDER BY p.unitprice DESC, p.productid DESC
OFFSET (@page_num - 1) * @page_size ROWS FETCH NEXT @page_size ROWS ONLY

-- Data set combination
-- select data about days of week * 3 shifts per day
SELECT n1.n AS theday, n2.n AS shiftno
FROM TSQLFundamentals2008.Sales.Nums AS n1
CROSS JOIN TSQLFundamentals2008.Sales.Nums AS n2
WHERE n1.n <= 7 AND n2.n <= 3
ORDER BY theday,shiftno

-- INNER JOIN retrieves rows which are good for predicate specified in ON
-- if predicate returns 'FALSE' or 'NULL' then rows are skipped
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid
WHERE s.country = N'Japan'

-- there is no difference between ON and WHERE clause for INNER JOIN clause, so you can do this way
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid AND 
															s.country = N'Japan'

-- JOIN on itself to find managers for workers
SELECT e1.empid, 
	   e1.firstname + e1.lastname AS [emp name],
	   e2.firstname + e2.lastname AS [mng name]
FROM TSQLFundamentals2008.HR.Employees AS e1
INNER JOIN TSQLFundamentals2008.HR.Employees AS e2 ON e1.mgrid = e2.empid															

-- OUTER JOIN retrieve rows which are good for predicate + rows from the left/right table with 
-- right/left rows which are selected as NULLs
-- for this type of JOIN clause ON and WHERE clauses mean different things
-- WHERE play role of the filter and skip rows on FALSE or NULL
-- ON is not a filter anymore, his mission to evaluate data equality
-- put is simple data from left/rigt table will be retrieved even if in ON there is no equality
-- if in the next query change WHERE to AND then instead of suppliers from Japan we will get all the suppliers (because this table is left)
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
LEFT JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid
WHERE s.country = N'Japan'

SELECT e1.empid, 
	   e1.firstname + e1.lastname AS [emp name],
	   e2.firstname + e2.lastname AS [mng name]
FROM TSQLFundamentals2008.HR.Employees AS e1
LEFT JOIN TSQLFundamentals2008.HR.Employees AS e2 ON e1.mgrid = e2.empid	

-- clients who has no orders
SELECT c.custid,c.companyname,o.orderid,o.orderdate
FROM TSQLFundamentals2008.Sales.Customers AS c
LEFT JOIN TSQLFundamentals2008.Sales.Orders AS o ON c.custid = o.custid
WHERE o.orderid IS NULL

-- retrieve all the clients but find their orders which were made in February 2008
SELECT c.custid,c.companyname,o.orderid,o.orderdate
FROM TSQLFundamentals2008.Sales.Customers AS c
LEFT JOIN TSQLFundamentals2008.Sales.Orders AS o ON c.custid = o.custid AND
												    o.orderdate >= '20080201' AND 
												    o.orderdate < '20080301'

-- Subquery
-- retrieve all the products which have min price in every category
SELECT p.categoryid, p.productid,p.productname,p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.unitprice = (SELECT MIN(p2.unitprice) 
                     FROM TSQLFundamentals2008.Production.Products AS p2
                     WHERE p.categoryid = p2.categoryid )			
ORDER BY p.unitprice,p.categoryid 

-- a bit better that prev query in performance because inline JOIN query will
-- be executed just once instead of subquery which is executing for every row
-- from outer query
SELECT p.categoryid, p.productid,p.productname,p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
INNER JOIN 
(
  SELECT p.categoryid, MIN(p.unitprice) AS minprice
  FROM TSQLFundamentals2008.Production.Products AS p
  GROUP BY p.categoryid
) AS c ON c.minprice = p.unitprice AND c.categoryid = p.categoryid
ORDER BY p.unitprice,p.categoryid 

-- retrieve clients who made order February 12 2007
SELECT c.custid,c.companyname
FROM TSQLFundamentals2008.Sales.Customers AS c
WHERE EXISTS (SELECT * FROM TSQLFundamentals2008.Sales.Orders AS o 
					   WHERE o.custid = c.custid AND o.orderdate = '20070212')					   

-- Table expressions
-- табличний вираз повинен бути реляційним, тому не можна застосовувати ORDER BY 
-- виключенням є застосування конструкції ORDER BY з конструкціями TOP/FETCH...OFFSET
-- табличні вирази не мають впливу на продуктивність

-- p.s. ROW_NUMBER та інші віконні функції дозволені тільки в SELECT i ORDER BY
SELECT 
	ROW_NUMBER() OVER (PARTITION BY p.categoryid 
					   ORDER BY p.unitprice, 
								p.productid ASC) AS rn,
	p.categoryid,
	p.productid,
	p.productname,
	p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p

-- повертаємо перші два продукти з найнижчими цінами з кожної категорії (приклад производной таблици)
-- мінуси производних таблиц : ускладнюється логіка, так як багато вкладень; проблеми при роботі з соединениями
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

-- Обобщенние табличние виражения (common table expression) CTE
-- якщо потрібно декілька CTE можна просто розділити їх комами; кожен CTE може посилатись
-- на попередній, а зовнішній запит може посилатись на всі CTE
-- також можна посилатись на делька екземплярів CTE що не можливо для производних таблиц
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

-- CTE можуть бути рекурсивними : рекурсія припиняється коли повертається пустий набір
-- наприклад виведемо ієрархію менеджерів для робітника
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

-- тепер виведемо всіх робітників менеджера
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


-- Представления (view) і встроєні табличні функції
-- головна різниця між ними те що перші не можуть приймати вхідних параметрів
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

-- Створення табличної функції 
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

-- Oператор APPLY
-- CROSS APPLY : якщо правий табличний вираз повертає пусту строку для лівого - така строка відкидається
-- потрібно повернути два товари з мін ціною для поставника з ID = 1
-- оскільки вираз APPLY застосовується для кожного поставника зліва ви отримуєте
-- два продукти з мін ціною для кожного поставника з Японії
-- так як CROSS APPLY не повертає ліві строки для яких табличний вираз повертає пустий набір
-- поставники з Японії, які не мають відповідних продуктів відкидаються
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
-- цей оператор робить теж саме що CROSS APPLY і крім того включає в результат
-- строки з лівої сторони для яких повертається пустий набір з правої сторони
-- значення NULL використовуються як замінники результату з правої сторони
-- в деякому розумінні різниця між CROSS APPLY i OUTER APPLY такаж як різниця між
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

-- ПРАКТИКУМ
-- зробити вибірку категорій продуктів та мін ціни для кожної категорії
SELECT p.categoryid, MIN(p.unitprice) AS min_price
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.categoryid

-- тепер створимо CTE і обєднаємо його з Production.Products для того щоб вибрати інфу про продукт
;WITH prodCte AS(
	SELECT p.categoryid, MIN(p.unitprice) AS min_price
	FROM TSQLFundamentals2008.Production.Products AS p
	GROUP BY p.categoryid
)
SELECT p.*
FROM prodCte AS pc
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON pc.categoryid = p.categoryid
WHERE p.unitprice = pc.min_price

-- теж саме але через apply (якщо в категорії будуть строки в яких ціна однакова то будуть братись обидвоє)
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

-- створити табличну функцію яка приймає на вхід @ID поставника і @n товарів з мін цінами які 
-- мають бути повернені. якщо є однакові товари то застосовується уточнюючий параметер productid
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

-- повернемо два продукти для кожного поставника з Японії
DECLARE @tot_prods2 INT = 2;
SELECT s.supplierid,ca.productid,ca.productname,ca.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
CROSS APPLY TSQLFundamentals2008.Production.GetTopProducts(s.supplierid,@tot_prods2) AS ca
WHERE s.country = N'Japan'

-- застосуємо попередній запит для виводу навіть тих поставників з Японії в яких немає продуктів
DECLARE @tot_prods2 INT = 2;
SELECT s.supplierid,ca.productid,ca.productname,ca.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
OUTER APPLY TSQLFundamentals2008.Production.GetTopProducts(s.supplierid,@tot_prods2) AS ca
WHERE s.country = N'Japan'

-- Оператори для роботи з наборами
-- оператори по роботі з наборами розглядають два значення NULL як рівні
-- окремі запити не можуть мати ORDER BY, цей оператор може бути тільки для набору
-- імена стовпців для результуючих стовпців визначаються першим запитом

-- UNION/UNION ALL
-- UNION має неявний DISTINCT, тому він не повертає дублюючих строк
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
UNION
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- UNION ALL повертає всі результати
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
UNION ALL
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- INTERSECT повертає спільні дані, тобто якщо строка зустрічається 1+ в першому наборі і 
-- 1+ в другому то вона повернеться
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
INTERSECT
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- EXCEPT повертає дані які є в першому і відсутні в другому наборі
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
EXCEPT
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- В UNION i INTERSECT порядок входу наборів немає значення, у випадку EXCEPT має
-- INTERSECT має вищий за UNION/EXCEPT пріорітет. Пріорітет тут також можна задати через
-- круглі скобки
-- INTERSECT/EXCEPT не повертає дублікатів строк

-- вивести робітників які обслуговували клієнта 1 але не клієнта 2
SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 1

EXCEPT

SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 2

-- вивести робітників які обслуговували і клієнта 1 і клієнта 2
SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 1

INTERSECT

SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 2

-- вибрати employee id тих які не робили замовлення 12 лютого 2008 року різними способами
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

-- Групування даних
-- запит який групує всі дані в одну групу
SELECT COUNT(*)
FROM TSQLFundamentals2008.Sales.Orders AS o

-- вивести по відправнику вантажу і виводить кількість строк на кожну групу
SELECT o.shipperid, COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
GROUP BY o.shipperid

-- групувати дані по відправнику багажу і по року
SELECT  o.shipperid
	   ,YEAR(o.shippeddate) AS shipperdate
	   ,COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
GROUP BY o.shipperid, YEAR(o.shippeddate)
ORDER BY o.shipperid, YEAR(o.shippeddate)

-- вивести ті дані для яких вантаж вже відвантажено
-- тут WHERE працює на рівні строки а HAVING вже як фільтр групи
SELECT  o.shipperid
	   ,YEAR(o.shippeddate) AS shipperdate
	   ,COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.shippeddate IS NOT NULL
GROUP BY o.shipperid, YEAR(o.shippeddate)
HAVING COUNT(*) < 100

-- COUNT (*) не рекомендований варіант бо якщо в стовпці є NULL то вони будуть пораховані
-- COUNT (o.shippeddate) рекомендований варіант
-- можна також використовувати COUNT(DISTINCT o.shippeddate)

-- Посилатись в SELECT можна тільки на стовпці які є в GROUP BY
-- або робити обхідний шлях наприклад з табличним виразом
;WITH cte AS (
	SELECT s.shipperid, COUNT(s.shipperid) AS nums
	FROM TSQLFundamentals2008.Sales.Shippers AS s
	GROUP BY s.shipperid
)
SELECT s.shipperid, s.companyname, c.nums
FROM TSQLFundamentals2008.Sales.Shippers AS s
INNER JOIN cte AS c ON c.shipperid = s.shipperid;

-- вивести кількість замовлень на кожного клієнта з іспанії
SELECT c.custid, COUNT(c.custid) AS ord_nums
FROM TSQLFundamentals2008.Sales.Orders AS o
INNER JOIN TSQLFundamentals2008.Sales.Customers AS c ON c.custid = o.custid
WHERE c.country = N'Spain'
GROUP BY c.custid

-- додати на вивід також місто
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
-- цей оператор видаляє строки які містять NULL
-- в операторі PIVOT це не можливо зробити якщо стовпець постачальника був необхідний
-- хоч для одного клієнта більше
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

-- написати запит до таблиці Orders який виводить максимальну дату замовлення для кожного
-- року а також відвантажувача грузу
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

-- написати запит який порахує для кожного клієнта кількість замовлень яку відвантажив певний відвантажник
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
 * Віконні функції
 *******************************************/
-- переваги перед групуванням в тому що можна використовувати групуючі і деталізовані елементи в одному запиті
-- OVER() - представляє сумарну кількість строк в базовому запиті
-- OVER(PARTIOTION BY some_col) - надає групування для конкретного елемента
-- напр. SUM(val) OVER(PARTITION BY custid) - якщо для поточної строки custid = 1, то будуть тільки ті строки в
-- вибірці в яких custid = 1, тобто вираз поверне суму для custid = 1

SELECT ov.custid,
	   ov.orderid,
	   ov.val,
	   SUM(ov.val) OVER(PARTITION BY ov.custid) AS custtotal,
	   SUM(ov.val) OVER() AS grandtotal
FROM TSQLFundamentals2008.Sales.OrderValues AS ov

-- віконні агрегатні функції також підтримують кадрування
-- зміст кадрування полягає в тому що оприділяється впорядкування всередині секції
-- за допомогою віконного кадра, і потім на основі цього впорядкування можна заключити набір строк 
-- між двома границями
-- в віконному кадрі вказується вимірювання ROWS/RANGE
-- використовуючи ROWS можна вказати границі як один з параметрів
-- 1. UNBOUNDED PRECEDING/FLOWING які означають початок і кінець секції відповідно
-- 2. CURRENT ROW - поточна строка
-- 3. <n> ROWS PRECEDING/FLOWING що означає <n> строк до чи після поточної строки

-- написати запит до OrderValues який вирахує проміжні значення суми від початку діяльності 
-- до поточного замовлення
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

-- в sql є такі ранжеруючі ф-ції : ROW_NUMBER, RANK, DENSE_RANK, NTILE
-- для них обовязково вказувати ORDER BY 
-- важливо розуміти що ORDER BY в OVER оприділяє тільки впорядкування для
-- обчислення віконної функції; для того щоб сортувати строки в вибірці треба
-- додати ORDER BY для вибірки
SELECT ov.custid, ov.orderid, ov.val,
	   ROW_NUMBER() OVER (ORDER BY ov.val) AS rn,
	   RANK()		OVER (ORDER BY ov.val) AS rnk,
	   DENSE_RANK() OVER (ORDER BY ov.val) AS denserank,
	   NTILE(100)	OVER (ORDER BY ov.val) AS ntilee100 
FROM TSQLFundamentals2008.Sales.OrderValues AS ov

-- ROW_NUMBER вираховує унікальний послідовний номер строки починаючи з 1 в секції вікна на
-- основі сортування; так як попер запит не має вікна то функція розглядає результуючу вибірку як один набір даних
-- тобто функція вираховує унікальні номери строк для всього результуючого набору;
-- order by - є необхідним для цієї функції
-- partiotion by - опціонально 

-- RANK і DENSE_RANK відрізняється від ROW_NUMBER тим що якщо в сортуванні зустрічаються однакові результати, напр
-- val = 36.00 два і більше разів підряд, то RANK не присвоює нового порядкового номеру такій строці а ROW_NUMBER присвоїть
-- RANK може мати розриви значень а DENSE_RANK ні 
-- NTILE - використовується для того щоб організувати строки в середині секції в бажану кількість груп; в нашому випадку
-- ми робили запит на 100 груп; 830 / 100 = 8 з остатком 30. Оскільки є остаток то перші 30 груп матимуть по додатковій 
-- строці, тобто по 9 строк. Наступні 31-100 групи по 8 строк.

-- як було сказано віконні функції можна застосовувати тільки в SELECT/ORDER BY тому якщо потрібно віконну функцію 
-- використати в WHERE треба застосувати CTE і у внутрішньому запиті присвоїти стовпцю на базі функції псевдонім
-- до якого можна буде звертатись в WHERE зовнішнього запиту.


-- написати запит який буде повертати ковзаюче середнє для останніх трьох замовлень клієнта
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

-- написати запит на вибірку трьох заказів з найбільшими затратами на перевезення по кожному відправнику
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

-- написати запит який виведе різницю між поточним і попереднім замовленням даного клієнта,
-- а також різницю між поточним і наступним замовленням
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

-- Створення таблиць
-- в Sql Server таблицю можна створити двома способами
-- 1. create table
-- 2. select into яка автоматично створить таблицю 
-- таблиці відносяться до схем
USE TSQLFundamentals2008
GO
CREATE SCHEMA MyShema 

-- схему для таблиці можна змінювати
ALTER SCHEMA Sales TRANSFER production.Categories;
ALTER SCHEMA Production TRANSFER Sales.Categories;

DECLARE @v1 DECIMAL(18,6) = 191235689123.03434999999;
DECLARE @v2 REAL = 19123568912343434390909.03434999999;
DECLARE @v3 DECIMAL(38,10) = 19123568912343434390909.03434999999;
SELECT @v3

-- коли при групуванні попадаються NULL значення то вони будуть зруповані в одну групу
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

-- для того щоб встановити режим стиснення існуючої таблиці
ALTER TABLE TSQLFundamentals2008.Production.CategoriesMy 
REBUILD WITH(data_compression = PAGE)

-- команду ALTER TABLE можна використовувати в таких цілях
-- 1. додати або видалити стовпець, включаючи вичесляемий стовпець
-- 2. змінити тип даних стовпця
-- 3. змінити допустимість NULL значення
-- 4. додати або видалити обмеження (primary key, unique constraint, foreign key, check constraint, default constraint)
-- якщо потрібно змінити определение ограничения - видаліть його і створіть нове
-- команду ALTER TABLE не можна використати для 
-- 1. змінити імя стовпця
-- 2. додавання властивості ідентифікатора
-- 3. видалення властивості ідентифікатора

-- Практикум
-- створити таблицю з одним стовпцем
USE TSQLFundamentals2008
GO

CREATE TABLE Production.CategoriesTest
(
	catid INT NOT NULL IDENTITY
)
GO

-- додамо стопці до створеної таблиці
ALTER TABLE Production.CategoriesTest
ADD catname NVARCHAR(15) NOT NULL
GO

ALTER TABLE Production.CategoriesTest
ADD descr NVARCHAR(200) NOT NULL 
GO

-- додамо дані в таблицю
INSERT INTO TSQLFundamentals2008.Production.CategoriesTest(catid,catname,descr)
SELECT c.categoryid, c.categoryname, c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c

-- оскільки не можна явно вставляти ідентифікатор потрібно виконати команду IDENTITY_INSERT ON
SET IDENTITY_INSERT Production.CategoriesTest ON;
INSERT INTO TSQLFundamentals2008.Production.CategoriesTest(catid,catname,descr)
SELECT c.categoryid, c.categoryname, c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c
GO 
SET IDENTITY_INSERT Production.CategoriesTest OFF;

-- для того щоб видалити таблицю виконати команду
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL DROP TABLE Production.CategoriesTest

-- Робота з NULL стовпцями
-- створити таблицю CategoriesTest
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

-- Заповнити таблицю
SET IDENTITY_INSERT Production.CategoriesTest ON;
GO
INSERT INTO Production.CategoriesTest (catid,catname,descr)
SELECT c.categoryid,c.categoryname,c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c
GO
SET IDENTITY_INSERT Production.CategoriesTest OFF;

-- збільшимо розмір стовпця description
ALTER TABLE Production.CategoriesTest
	ALTER COLUMN descr NVARCHAR(500) NOT NULL;
	
-- перевіримо таблицю на наявність NULL в стовпці descr
SELECT ct.descr
FROM TSQLFundamentals2008.Production.CategoriesTest AS ct	

-- спроба змінити значення в стовпці descr на NULL (спроба буде невдала)
UPDATE Production.CategoriesTest
SET descr = NULL
WHERE catid = 8

-- змінимо таблицю і зробимо значення NULL дозволеними
ALTER TABLE Production.CategoriesTest
	ALTER COLUMN descr NVARCHAR(500) NULL;
	
-- тепер попробуємо змінити цей стовпець назад на NOT NULL
ALTER TABLE Production.CategoriesTest
 ALTER COLUMN descr NVARCHAR(500) NOT NULL;

-- змінимо значення в стовпці descr 
UPDATE Production.CategoriesTest
SET descr = 'Seaweed and fish'
WHERE catid = 8 

-- очистимо базу даних 
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL DROP TABLE Production.CategoriesTest;

/*******************************************
 * Цілісність даних
 *******************************************/ 
-- найкращий метод для забезпечення цілісності даних це constraints

/*******************************************
 * PRIMARY KEY
 *******************************************/
-- 1) не можуть мати NULL 
-- 2) будь які дані повинні мати унікальні дані в стовпці або стовпцях первинного ключа
-- 3) може бути тільки один primary key в таблиці
-- коли створюється primary key неявно створюється unique constraint + clustered index
-- для того щоб подивитись primary key constraints в базі потрібно виконати sys.key_constraints з фільтрацією по PK
USE TSQLFundamentals2008
GO
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.[type] = 'PK'

-- також можна знайти унікальний індекс який використовує сервер для забезпечення 
-- ограничения первичного ключа
USE TSQLFundamentals2008
GO
SELECT *
FROM sys.indexes AS i
WHERE i.[object_id] = OBJECT_ID('Production.Categories') AND
	  i.name = 'PK_Categories';
	
/*******************************************
 * UNIQUE CONSTRAINT
 *******************************************/  
-- цей тип обмеження як і primary key автоматично створює індекс для стовпця з таким же іменем як
-- обмеження; унікальний індекс може бути як кластиризований так і не кластеризований 
-- обмеження унікальності не вимагає щоб стовпець був NOT NULL - можна дозволити NULL але при цьому
-- тільки одна строка може мати значення NULL
-- первинний ключ і обмеження унікальності мають тіж обмеження по кількості ключових стовпців що і індекс
-- їх максимальна кількість 16 і розмір 900 байт
-- наприклад для того щоб забезпечити унікальність назв категорій можна обявити UNIQUE CONSTRAINT
ALTER TABLE Production.CategoriesTest
 ADD CONSTRAINT UC_Categories UNIQUE(categorynamee) 
 	  
-- також можна продивитись всі обмеження унікальності які є в базі
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.[type] = 'UQ';

-- можна знайти унікальний індекс застосувавши фільтр по імені обмеження
SELECT *
FROM sys.indexes AS i
WHERE i.name = 'UK_principal_name';

/*******************************************
 * FOREIGHN KEY
 *******************************************/
-- використовується як ссилка на таблицю в якій є первинний ключ
-- для того щоб додати зовнішній ключ потрібно
-- створення обмеження WITH CHECK подразумевает что если в таблице существуют дание
-- і якщо можливі порушення ограничения то команда ALTER TABLE завершиться помилкою
-- стовпці з ссилочних таблиць повинні мати унікальний індекс, створений для них, або за
-- допомогою первинного ключа неявно або через обмеження унікальності або через створення індексу
USE TSQLFundamentals2008
GO

ALTER TABLE Production.Products WITH CHECK 
 ADD CONSTRAINT FK_Products_Categories FOREIGN KEY (categoryid)
 REFERENCES Production.Categories (categoryid);

-- рекомендовано додавати некластеризований індекс до зовнішнього ключа,
-- це допоможе підняти перфоманс в деяких випадках
 
-- Щоб знайти FKs в базі
SELECT *
FROM sys.foreign_keys AS fk
WHERE NAME = 'FK_Products_Categories' 

/*******************************************
 * CHECK CONSTRAINTS
 *******************************************/
-- цей тип обмеження призначений для того щоб обмежувати значення в стопвці певним чином
-- для того щоб створити такий CONSTRAINT
-- якщо в стовпці дозволенi NULL переконайтесь в тому що обмеження враховує NULL значення
-- вставка обмеження проходить значення unitprice >= 0 i unitprice < 0
ALTER TABLE TSQLFundamentals2008.Production.Products WITH CHECK
 ADD CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0);

-- для того щоб отримати список CHECK CONSTRAINT для таблиці використовуйте запит
SELECT *
FROM sys.[check_constraints] AS cc
WHERE cc.parent_object_id = OBJECT_ID('Production.Products');

/*******************************************
 * DEFAULT CONSTRAINTS
 *******************************************/
-- дозволяють задати значення по замовчуванню яке буде використовуватись при додаванні
-- даних в таблицю коли відсутні значення в інструкції INSERT
-- для того щоб вивести перелік цих обмежень для таблиці
SELECT * 
FROM sys.default_constraints AS dc
WHERE dc.parent_object_id = OBJECT_ID('Production.Products');

-- ПРАКТИКУМ
/* -- Создать таблицу Production.Products
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

-- 1. Робота з PRIMARY i FOREIGN KEYs
-- протестуємо Primary Key
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

-- Додамо нову строку яка призначить новий productid
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
 
-- видалимо тестову строку
DELETE FROM Production.Products
WHERE productname = N'Product test';

-- пробуємо ще раз додати строку з невірним значенням catid = 99. буде невдача через foreign key
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

-- попробуємо додати зовнішній ключ з WITH CHECK - команда не виконається
ALTER TABLE Production.Products WITH CHECK
 ADD CONSTRAINT FK_Products_Categories FOREIGN KEY (categoryid)
 REFERENCES Production.Products (categoryid);
 
-- 2. Робота з CHECK CONSTRAINT
-- перевіримо що всі назви продуктів унікальні
USE TSQLFundamentals2008
GO

SELECT p.productname, COUNT(*) AS prodname_count
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.productname
HAVING COUNT(*) > 1;

-- задамо для productid = 1 значення рівним 'Product HHYDP'
UPDATE TSQLFundamentals2008.Production.Products
SET productname = 'Product RECZE'
WHERE productid = 1;

-- знову перевіримо назви на наявність дублікатів
SELECT p.productname, COUNT(*) AS prodname_count
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.productname
HAVING COUNT(*) > 1;

-- спроба додати обмеження унікальності - вона буде failed
ALTER TABLE Production.Products
 ADD CONSTRAINT UQ_ProdName UNIQUE(productname);

-- повернемо назву продукта до першопочаткової
UPDATE TSQLFundamentals2008.Production.Products
SET productname = 'Product HHYDP'
WHERE productid = 1;

-- тепер обмеження можна додати (разом з ним створиться nonclustered index)
ALTER TABLE Production.Products
 ADD CONSTRAINT UQ_ProdName UNIQUE(productname);
 
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.name = 'UQ_ProdName'

SELECT *
FROM sys.indexes AS i
WHERE i.NAME = 'UQ_ProdName' AND
	  i.[object_id] = OBJECT_ID('Production.Products')

-- видалимо обмеження унікальності
ALTER TABLE Production.Products
 DROP CONSTRAINT UQ_ProdName;
 
-- Висновок до обмежень : обмеження включають в себе обмеження первинного ключа і обмеження унікальності, які 
-- забезпечуються sql server за допомогою унікального індексу. Вони також включають обмеження зовнішнього 
-- ключа, яке гарантує що тільки дані правильність яких перевірена в іншій таблиці дозволені в цій таблиці.
-- Також сюди відносяться check constraints i default constraints які застосовуються до стопців

-- якщо спробувати додати до таблиці яка має дані стовпець NOT NULL - то спроба буде невдала
-- для того щоб все пройшло успішно потрібно в команді додати NOT NULL DEFAULT '' напр

-- View and table functions ПРАКТИКУМ
-- написати запит який показує продану кількість і загальний об'єм продажів для всіх продажів
-- по року по клієнту і по грузовідправнику
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
 * Вставка даних в базу
 *******************************************/
-- INSERT INTO - додавання в таблицю одну або декілька строк
-- INSERT SELECT - додавання в таблицю результату запиту
-- INSERT EXEC - додавання даних в таблицю які повернулись зі сторки
-- SELECT INTO - використати результат запиту для створення і заповнення таблиці

-- для демонстрації створимо таблицю 
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

-- якщо потрібно вставити власне значення IDENTITY
USE TSQLFundamentals2008
GO
SET IDENTITY_INSERT Sales.MyOrders ON
INSERT INTO TSQLFundamentals2008.sales.MyOrders(custid,empid,orderdate,shipcountry,freight)
VALUES (4,19,'20120720',N'USA',30.0)
SET IDENTITY_INSERT Sales.MyOrders OFF

-- можна не вказувати дату оскільки вона має обмеження default
INSERT INTO TSQLFundamentals2008.sales.MyOrders(custid,empid,orderdate,shipcountry,freight)
VALUES (4,19,DEFAULT,N'USA',30.0)

-- INSERT SELECT - вставляє результуючу вибірку згенеровану запитом в цільову таблицю
USE TSQLFundamentals2008
GO

SET IDENTITY_INSERT Sales.MyOrders ON;
INSERT INTO Sales.MyOrders(orderid,custid,empid,orderdate,shipcountry,freight)
SELECT o.orderid, o.custid, o.empid, o.orderdate, o.shipcountry, o.freight
FROM sales.Orders AS o
WHERE o.shipcountry = N'Norway'
SET IDENTITY_INSERT Sales.MyOrders OFF;

-- INSERT EXEC - за допомогою цієї інструкції можна вставляти дані які повернені сторкою
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
 
-- запустимо сторку для вибірки рекордів по португалії
USE TSQLFundamentals2008
GO

SET IDENTITY_INSERT Sales.MyOrders ON;
INSERT INTO Sales.MyOrders (orderid,custid,empid,orderdate,shipcountry,freight)
EXEC sales.ordersforcountry @country = N'Portugal'
SET IDENTITY_INSERT Sales.MyOrders OFF;

-- SELECT INTO - ця інструкція створює таблицю і копіює туди дані з вибірки; індекси, обмеження, тригери не копіюються
IF OBJECT_ID('Sales.MyOrders','U') IS NOT NULL DROP TABLE Sales.MyOrders
GO

SELECT orderid, custid, empid, orderdate, shipcountry, freight
INTO sales.MyOrders
FROM Sales.orders 
WHERE shipcountry = N'Norway' 

/*******************************************
 * Оновлення даних 
 *******************************************/
-- створимо тестові таблиці
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

-- треба додати скидку 0.05 для всіх замовлень які зроблені клієнтами з норвегії
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

-- Не детермінована конструкція UPDATE
SELECT c.custid, c.postalcode, mo.shippostalcode
FROM TSQLFundamentals2008.Sales.MyOrders AS mo
INNER JOIN TSQLFundamentals2008.Sales.MyCustomers AS c ON mo.custid = c.custid
ORDER BY c.custid

-- в даному запиті якщо для кастомера зустрічаються дублюючі строки в замовленнях то немає
-- детермінованості яка з них буде вибрана для того щоб витягти з неї shippostalcode
UPDATE mc
 SET mc.postalcode = mo.shippostalcode
FROM TSQLFundamentals2008.Sales.MyCustomers AS mc
INNER JOIN TSQLFundamentals2008.Sales.MyOrders AS mo ON mo.custid = mc.custid

SELECT c.custid, c.postalcode
FROM TSQLFundamentals2008.Sales.MyCustomers AS c
ORDER BY c.custid

-- детермінований update
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
 * Видалення даних
 *******************************************/
-- додамо тестові таблиці
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

-- інструкція DELETE може бути досить затратною оскільки відбувається логування цієї операції
-- в журналі 
WHILE 1 = 1
BEGIN
	DELETE TOP(1000) FROM TSQLFundamentals2008.Sales.MyOrderDetails AS mo
	WHERE mo.productid = 12
	
	IF @@ROWCOUNT < 1000 BREAK;	
	
END

/*******************************************
 * Курсори
 *******************************************/
USE TSQLFundamentals2008
GO

IF OBJECT_ID('Sales.ProcessCustomer') IS NOT NULL DROP PROC Sales.ProcessCustomer;
GO

CREATE PROC Sales.ProcessCustomer(@custid INT) AS
 PRINT 'Processing customer ' + CAST(@custid AS VARCHAR(10));
GO

-- приклад курсора
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

-- теж саме тільки за допомогою іншого ітераційного рішення
DECLARE @custid INT;
SET @custid = (SELECT TOP(1) custid FROM TSQLFundamentals2008.Sales.Customers ORDER BY custid);
WHILE @custid IS NOT NULL
BEGIN
	EXEC TSQLFundamentals2008.Sales.ProcessCustomer
		@custid = @custid
	SET @custid = (SELECT TOP(1) custid FROM TSQLFundamentals2008.Sales.Customers WHERE custid > @custid ORDER BY custid)
END

-- створимо тестову функцію яка повертає набір чисел в заданому діапазоні
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
 
 -- перевірка функції
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

-- вибрати наростаюче значення
SELECT 
	   tn.actid, tn.tranid, tn.val,
	   (SELECT SUM(tn1.val) 
	    FROM TSQLFundamentals2008.dbo.Transactions AS tn1
	    WHERE tn1.actid = tn.actid AND tn1.tranid <= tn.tranid ) AS tot_run_sum
FROM TSQLFundamentals2008.dbo.transactions AS tn
ORDER BY tn.actid, tn.tranid

-- це ж саме на основі курсора
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

-- теж саме за допомогою віконних статистичних функцій 2012
SELECT t.actid,t.tranid,t.val,
	   (SUM(val) OVER (PARTITION BY actid ORDER BY t.tranid
						   ROWS unbounded preceding)) AS balance
FROM TSQLFundamentals2008.dbo.Transactions AS t

-- написати запит який на основі курсора виведе максимальні значення з таблиці
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

-- рішення задачі на основі наборів
SELECT t.actid, MAX(t.val)
FROM TSQLFundamentals2008.dbo.Transactions AS t
GROUP BY t.actid

/*******************************************
 * Тимчасові таблиці і табличні вирази
 *******************************************/
-- тимчасові таблиці бувають локальні (#T) і глобальні (##T)
-- локальні тимчасові таблиці є видимі тільки в сеансі який їх створив;
-- різні сеанси можуть мати тимчасові таблиці з однаковими іменами і кожен 
-- сеанс буде бачити свою унікальну таблицю - сервер додає суфікс до назв щоб вони були
-- унікальні в системі;
-- локальні тимчасові таблиці є видимі всьому рівню який їх створив - в пакетах та всьому стеку викликів
-- якщо локальну тимчасову таблицю не видалити явно вона буде видалена після завершення рівня який її створив;
-- глобальні тимчасові таблиці видні для всіх сеансів, вони видаляються сеансом який їх створював при умові
-- що немає активних ссилок на них;
-- табличні змінні видні тільки пакету який їх створив і автоматично видаляються в кінці пакету
-- вони не видимі іншим пакетам а також стеку викликів

-- наступний код показує що тимчасові таблиці є видимі іншим пакетам і стеку викликів
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

-- наступний код показує що табличні змінні не видимі ніде крім свого пакету
CREATE TABLE #T1
( col1 INT NOT NULL );
INSERT INTO #T1(col1) VALUES(10);
EXEC('SELECT col1 FROM #T1;');
GO
SELECT col1 FROM #T1;
GO
DROP TABLE #T1;
GO

-- тимчасові таблиці створюються в базі tempdb і як вже зазначалось можна створити декілька
-- таблиць з однаковими іменами в різних сеансах оскільки сервер додає суфікс до імені; 
-- проте якщо створити тимчасові таблиці в різних сеансах з однакомим іменем обмеження то буде
-- створена тільки одна таблиця, а інша спроба буде завершена помилкою;

-- якщо створювати наступну таблицю в різних сеансах то перша спроба буде успішна а наступні
-- завершаться з помилкою
CREATE TABLE #T1
(
	col1     INT NOT NULL,
	col2     INT NOT NULL,
	col3     DATE NOT NULL,
	CONSTRAINT PK_#T1 PRIMARY KEY(col1)
);

-- одним з вирішень проблеми - не присвоювати імен для обмежень в тимчасових таблицях
CREATE TABLE #T1
(
	col1     INT NOT NULL,
	col2     INT NOT NULL,
	col3     DATE NOT NULL,
	PRIMARY KEY(col1)
);

-- в sql server можна створювати обмеження на тимчасових таблицях після створення таблиці
CREATE UNIQUE NONCLUSTERED INDEX idx_col2 ON #T1(col2);

CREATE NONCLUSTERED INDEX idx_col2 ON #T1(col2);

-- для табличних змінних не дозволяється присвоєння імен для обмежень навіть в одному сеансі
-- наступна спроба завершиться помилкою
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            CONSTRAINT PK_@T1 PRIMARY KEY(col1)
        );
        
-- а ця спроба завершиться успішно
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            PRIMARY KEY(col1)
        ); 
        
-- не можна додавати обмеження до існуючої табличної змінної        
-- нагадаємо що при створенні первинного ключа для його унікальності сервер створює на стовпці кластеризований
-- індекс, а при створенні обмеження унікальності додається некластеризований індекс, тому якщо потрібно
-- обявити індекс на табличній змінній це можна зробити в обхід
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            PRIMARY KEY(col1)
        );
        
-- тимчасові таблиці а також табличні змінні мають представлення в базі даних tempdb
-- табличні вирази CTE фізичного представлення не мають

-- транзакції працюють з тимчасовими таблицями практично так само як зі звичайними
-- наприклад в наступному запиті зміни до тимчасової таблиці будуть відмінені 
-- відкатом транзакції
CREATE TABLE #T1
( col1 INT NOT NULL );
BEGIN TRAN
	INSERT INTO #T1(col1) VALUES(10);
ROLLBACK TRAN
SELECT col1 FROM #T1;
DROP TABLE #T1;
GO             

-- зміни застосовані до табличних змінних в транзакції не відміняються
DECLARE @T1 AS TABLE
( col1 INT NOT NULL );
BEGIN TRAN
	INSERT INTO @T1(col1) VALUES(10);
ROLLBACK TRAN
SELECT col1 FROM @T1;

/*******************************************
 * Статистика
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

-- витягнемо дані з таблиці
SELECT t.col1,t.col2,t.col3
FROM #T1 AS t
WHERE t.col2 <= 5

-- на цей раз виконаємо попередній запит до табличної змінної
-- в даному випадку план буде не такий ефективний
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

-- можна зробити наступний висновок : табличні змінні добре використовувати в двох випадках 
-- 1) коли кількість даних мала і план виконання запиту не має значення
-- 2) коли план дуже простий, що означає що існує тільки один розумний план і оптимізатору не потрібні
--    гістограми для прийняття рішення

-- ПРАКТИКУМ
-- треба повернути кількість замовлень за рік і різницю між поточним і попереднім роком
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

-- оскільки табличний вираз буде проглянутий два рази можна використати наприклад табличну змінну
-- в даному випадку робота по перегляду, групуванню і статичні обробці даних виконана тільки один
-- раз і результат збережено в тимчасову таблицю тому запит є ефективнішим
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
 * ТРАНЗАКЦІЇ
 *******************************************/
-- Транзакція - це логічна одиниця роботи. 
-- Всі зміни в базі відбуваються за допомогою транзакцій, іншими словами
-- всі операції які вносять зміни в базу сприймаються sql server як транзакції
-- 1) всі інструкції мови опису даних DDL (CREATE TABLE,CREATE INDEX)
-- 2) всі інструкції обробки даних DML (insert,update,delete)
-- ACID (atomicity,consistency,isolation,durability)
-- atomicity - кожна транзакція є атомарною одиницею роботи, тобто або виконується все або нічого
-- consistency - кожна транзакція яка є завершена або перервана залишає базу в согласованном состоянии, при
-- несогласованости сервер зробить відкат транзакції
-- isolation - кожна транзакція виконується так ніби вона існує в ізоляції по відношенню до всіх інших транзакцій
-- якщо двом транзакціям треба змінити одні і тіж дані одна з них повинна почекати поки завершиться інша
-- durability - кожна транзакція потерпає від переривання сервісу. Коли сервіс відновлюється всі завершені 
-- транзакції комітяться, всі незавершені відкочуються

-- ізоляція транзакцій забезпечується за допомогою механізмів блокування і версійності строк
-- sql server блокує об'єкти (строки і таблиці) для того щоб запобігти вмішуванню інших транзакцій 
-- в дії даної транзакції
-- важливо підтримувати якість транзакцій які відповідають ACID, для того щоб гарантувати що цілісність даних
-- в базі не буде порушено
-- стійкість транзакцій досягається за допомогою того що сервер записує всі транзакції в журнал

-- активні транзакції
SELECT * FROM sys.dm_tran_active_transactions AS dtat

-- рівень транзакції і її стан можна визначити за допомогою двох системних функцій
-- @@TRANCOUNT - дозволяє дізнатись рівень вкладення транзакції
-- XACT_STATE() - дозволяє визначити стан транзакції

-- режими транзакції
-- autocommit (DDL/DML)
-- implicit transaction (неявна)
-- explicit transaction (явна)

-- ROLLBACK завжди робить відкат всієї транзакції не залежно від того скільки є рівней
-- вкладеності транзакції і на якому рівні викликана ця команда

-- для того щоб гарантувати фіксацію всієї транзакції вцілому потрібно виконати по одній
-- інструкції COMMIT на кожен рівень транзакції, при чому тільки остання команда COMMIT дійсно
-- фіксує всю транзакцію

USE TSQLFundamentals2008
GO

BEGIN TRAN MyFirstTranInLife

ROLLBACK

-- щоб зберегти ізоляцію транзакцій sql server реалізує набір протоколів блокування
-- на базовому рівні існує два основні :
-- 1) shared locks (совмещаемие) використовуються для сеансів які здійснюють читання даних 
-- 2) exclusive locks (монопольні) використовуються для модифікації даних, тобто операцій запису

-- монопольна блокировка завжди виникає в випадку транзакції навіть якщо це автоматична транзакція
-- коли на сеансі є монопольне блокування на строці, таблиці або іншому об'єкті ніяка інша транзакція 
-- не може змінити дані, поки поточна транзакція не буде закомічена або відкочена
-- за виключенням особливих блокувань інші сеанси не можуть навіть читати заблоковані в монопольному
-- режимі об'єкти

-- сумісність блокувань
-- якщо сеанс виконує тільки читання даних по замовчуванню sql server запускає тільки дуже короткі 
-- shared блокування на об'єкті; два і більше сеансів можуть читати одні і ті ж дані
-- але якщо сеанс має ресурс з монопольною блокировкою, інші сеанси не можуть виконувати читання
-- або модифікацію цього ресурсу

-- Блокування
-- блокування виникає у випадку коли один сеанс виконує монопольне блокування ресурсу не дозволяючи
-- іншому сеансу ніяким чином отримати можливість блокування цього ресурсу
-- в транзакції монопольні блокування втримуються до кінця транзакції тому якщо перший сеанс виконує
-- транзакцію, другий повинен чекати доки перший не закомітить або не відкотить транзакцію

-- монопольне блокування також може блокувати запит на читання якщо модуль читання запрошує shared 
-- блокування, тому що монопольне блокування несумісне також і з shared блокуванням

-- модулі читання (share block) не можуть блокувати інші модулі читання оскільки вони сумісні між собою
-- модулі читання можуть проте блокувати модулі запису, оскільки будь який модуль читання повинен чекати
-- поки shared блокування не буде звільненим

-- дві транзакції які виконують одні і ті ж дії в протилежній послідовності приводять до взаємоблокування
-- дві транзакції які виконують одні і ті ж дії в однаковій послідовності не викликають взаємоблокування

-- інструкція select також може брати участь в взаємоблокуванні : якщо select блокує ресурс не дозволяючи
-- завершитись іншій транзакції, а сама інструкція select не може завершитись так як вона заблокована 
-- якоюсь транзакцією то виникає цикл взаємоблокування

-- блокування або взаємоблокування можна збільшити або зменшити методоз зміни степені ізольованості 
-- ACID - властивостей транзакції; sql server дозволяє одній транзакції читати дані іншої або виконувати
-- зміну даних іншими транзакціями коли дана транзакція виконує читання даних за допомогою налаштування
-- рівня ізоляції транзакцій
-- до найбільш часто використовувавних рівнів транзакцій відносяться наступні :
-- 1) read committed - це рівень ізоляції по замовчуванню; всі модулі читання даних будуть виконувати
--    читання тільки тих змінених даних які були зафіксовані; всі select інструкції будуть намагатись
--    отримати shared блокування і будь які базові ресурси які змінюються і мають монопольні блокіровки
--	  будуть блокувати сеанс read committed
-- 1.1) read committed snapshot - це не новий рівень, а додатковий спосіб використання read committed;
--		1. часто його називають RSCI; він використовує базу tempdb для збереження початкових версій
--		   змінених даних; ці версії зберігаються стільки скільки необхідно, щоб дозволити модулям
--		   читання базові дані в їх початковому стані; в результаті інструкціям select більше не потрібні
--		   shared блокування на ресурсі для виконання читанні зафіксованих даних;
--		2. налаштування read committed snapshot виконується на рівні бази даних і є постійною пропертьою бази
--		3. RSCI - це не окремий рівень ізоляції; це просто інший метод реалізації READ COMMITTED, який запобігає
--		   блокуванню модулів читання модулями запису;
-- 2) read uncommitted - цей рівень ізоляції дозволяє читати незафіксовані дані; це налаштування видаляє
--    shared блокування які отримані інструкціями select так що модулі читання більше не блокуються
--    модулями запису; це називається "dirty read"
-- 3) repeatable read - цей рівень ізоляції гарантує що дані прочитані в транзакції можуть далі бути знову
--    прочитані в транзакції; не допускаються операції видалення або модифікації прочитаних строк в інших сесіях;
--	  в результаті shared блокування утримуються до кінця транзакції; проте транзакція може бачити нові строки
--	  додані після першої операції читання; це називається фантомним читанням (update lost problem усувається)
-- 4) snapshot - цей рівень використовує управління версіями строк в базі tempdb (як RSCI); він дозволений як
--    постійна пропертя бази тому встановлюється на окрему транзакцію; транзакція яка використовує цей рівень
--    може повторити будь яку операцію читання (repeatable read), і не буде бачити ніяких фантомних читань;
--    оскільки snapshot управляє версіями строк то не вимагається ніяких shared блокувань на базових даних
-- 5) serializable - цей рівень є найбільш строгим і встановлюється на сеанс; на цьому рівні всі операції є
--    repeatable і нові строки, які задовільняють умову в select транзакції не можуть бути додані в таблицю

-- Repeatable read prevents only non-repeatable read. Repeatable isolation level ensures that the data that one 
-- transaction has read, will be prevented from beeing updated or deleted by any other transaction, but it do
-- not prevent new rows from beeing inserted by other transaction resulting in phantom read concurency problem.

-- Serializable prevents both non-repeatable read and phantom read problems. Serializable isolation level ensures
-- that the data that one transaction has read, will be prevented from beeing updated or deleted by any other 
-- transaction. Is also prevents new rows from beeing inserted by other transactions, so this isolation level 
-- prevents both non-repeatable read and phantom read problems.

-- рівні ізоляції встановлюються на сеанс; якщо ніякі рівні ізоляції не встановлювались на сеанс всі транзакції
-- будуть виконуватись за допомогою рівня по замовчуванню (read committed); 

-- якщо сеанс використовує рівень ізоляції READ COMMITTED запити все одно можуть отримати змогу читати незафіксовані
-- дані використовуючи такі хінти як WITH (NOLOCK) або WITH (READUNCOMMITTED); значення рівня ізоляції для сеансу не
-- змінюється змінюються тільки характеристики читання таблиці;

-- як було сказано, для того щоб запобігти блокуванню модулів запису модулями читання і при цьому гарантувати що модулі
-- читання бачать тільки зафіксовані дані потрібно використовувати параметр (RSCI) на рівні READ COMMITTED; модулі читання
-- бачать більш ранні версії змінених даних для поточних транзакцій, але не незафіксовані в даний момент дані

-- Loging deadlocks
-- перевіка флажка
DBCC TRACESTATUS (1222)

-- включимо логування
DBCC TRACEON (1222,-1)

-- виключити
DBCC TRACEOFF (1222,-1)

-- прочитати логування
EXEC sp_readerrorlog

/*******************************************
 * Обробка помилок
 *******************************************/
-- коли сервер згенерує помилку системна функція @@ERROR буде містити додатнє ціле значення номеру помилки
-- якщо немає try/catch повідомлення про помилку буде передано клієнту і не може бути перехоплено в коді SQL
-- крім того можна ініціювати помилку за допомогою команд
-- raiseerror (sql server < 2012)
-- throw (sql server >= 2012)
-- try/catch блок не може бути використаний в функціях

DECLARE @message VARCHAR(100) = 'Error in %s stored procedure'
SELECT @message = FORMATMESSAGE(@message,'MY')
--RAISERROR(@message,16,0)
;THROW 50000,@message,0

-- дуже важливою відмінністю між цими командами є те що RAISEERROR не завершує роботу пакета, а THROW завершує
RAISERROR ('The error',16,0)
PRINT 'raise error'

throw 50000,'The error',0
PRINT 'throw error'

-- TRY_CONVERT i TRY_PARSE
-- TRY_CONVERT - намагається привести значення до заданого типу або поверне NULL
SELECT TRY_CONVERT(DATETIME,'1788-03-343')
SELECT TRY_CONVERT(DATETIME,'1990-01-01')

-- TRY_PARSE - приймає дані з невідомим типом і намагається перетворити їх в конкретний тип або поверне NULL
SELECT TRY_PARSE('1' AS integer) 
SELECT TRY_PARSE('B' AS integer) -- притримується синтаксису CAST/PARSE

-- для того щоб створити повідомлення про помилку можна використовувати такий набір функцій блока catch:
-- 1. error_number - повертає номер помилки
-- 2. error_message - повертає повідомлення про помилку
-- 3. error_severity - повертає рівень серйозності помилки
-- 4. error_line - повертає номер строки в пакеті де відбулась помилка
-- 5. error_procedure - імя функції, сторки, тригера які виконувались в момент ерору
-- 6. error_state - стан помилки

BEGIN TRY
	RAISERROR('Hello try',16,0)
END TRY
BEGIN CATCH
	
		SELECT *
		from TSQLFundamentals2008.dbo.GetErrors()
	
END CATCH

-- Практикум
-- 1. робота з неструктурованими помилками
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

-- 2. неструктурована обробка помилок
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
	-- Видалення доданої строки
	DELETE FROM Production.Products WHERE productid = 101
	PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows'
	
 -- 3. обробка помилки структуровано
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
	;throw;	-- прокидує помилку яка виникла клієнту; жоден код не може виконуватись після цієї інструкції
END CATCH;

GO

SELECT * FROM TSQLFundamentals2008.Production.Products AS p

-- Процедури
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
 * ТРИГЕРИ
 *******************************************/
-- sql server підтримує тригери з двома типами подій
-- 1. подія обробки даних (тригери DML)
-- 2. подія опису даних (DDL), такі як CREATE TABLE

-- DML тригери
-- 1. AFTER - спрацьовує тільки тоді коли подія яка з ним звязана завершується і може бути використаний тільки
-- для постійних таблиць
-- 2. INSTEAD OF - цей тригер спрацьовує замість події з яким він звязаний і може бути створений для постійних
-- таблиць і вюшок
-- ці два типи тригерів виконуються як частина транзакції звязаної з інструкцією insert,update,delete
-- запуск команди rollback tran в коді тригера робить відкат всіх змін які відбувались в тригері а також відкат
-- інструкції DML з якою звязаний тригер; але використання rollback може мати побічні ефекти; замість цієї команди
-- можна виконати команду throw / raiserror і контролювати збій через стандартні процедури обробки помилок
-- нормальним виходом з тригера є інструкція RETURN як і в стор процедурі

-- AFTER - код цього тригера виконується тоді коли інструкція DML пройшла всі обмеження, такі як primary/foreign key
-- якщо обмеження не пройдено інструкція видає помилку і тригер не виконується			

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

-- inserted,deleted містять дублікати таблиць тригера; update аналогічний до видалення з вставкою
-- спочатку старі строки копіюються в deleted, а потім нові строки додаються в таблицю тригера і таблицю inserted
UPDATE Production.Categories
SET categoryname = 'Beverages'
WHERE categoryname = 'Testcat1'	

DELETE FROM Production.Categories WHERE categoryid = 13

-- створимо after тригер який відображає інформацію про видалені та додані строки
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

-- при додавання строк буде виведена кількість доданих через тригер
INSERT INTO sales.OrderDetails(orderid,productid,unitprice,qty,discount)
VALUES(10249,16,9.00,1,0.6),
	  (10249,15,9.00,1,0.4)

-- оновимо одну з строк і побачимо одну строку серед видалених і одну серед вставлених
UPDATE Sales.OrderDetails
SET unitprice = 99.0
WHERE orderid = 10249 AND productid = 16	  

-- видалимо дві строки і побачимо їх серед видалених але не серед доданих
DELETE FROM Sales.OrderDetails
WHERE orderid = 10249 AND productid IN (15,16)

-- напишемо тригер для реалізації логіки : будь який елемент з таблиці Sales.OrderDetails в якого unitprice < 10
-- не може мати знижку більше 0.5 
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

-- в протилежному порядку тригер не спрацьовує
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40),
	   (10249, 16, 9.00, 1, 0.60);

-- але спрацює при такому варіанті як дві незалежні вставки даних
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40)

INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 16, 9.00, 1, 0.60);	

-- оновимо тригер	   
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

-- попробуємо знову вставку, як бачимо тепер дані не будуть додані в таблицю
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 16, 9.00, 1, 0.60),
	   (10249, 15, 9.00, 1, 0.40);	
	    
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40),
	   (10249, 16, 9.00, 1, 0.60);	
	   
	   
	   
-- INSTEAD OF - найчастіше використовується з view для того щоб апдейтнути таблиці які повязані з view
-- створимо view яка повертає замовлення
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
-- витягнути інформацію про всі підключення
SELECT des1.is_user_process,des1.original_login_name, * 
FROM sys.dm_exec_sessions AS des1

-- створимо тригер який блокує підключення користувача більше ніж 3 сесії
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
		PRINT 'Fourth connection attempt by ' + @LoginName + ' blocked'; -- пише повідомлення в логи 
		ROLLBACK;
	END															
END

-- прочитаємо інформацію з логів
EXEC sp_readerrorlog


/*******************************************
 * INDEXES
 *******************************************/
-- sql server організовує таблиці в кучі або збалансовані дерева
-- таблиця, яка організована в вигляді збалансованого дерева називається кластеризованою таблицею або
-- кластеризованим індексом
-- куча - це набір сторінок і екстентів, який складається з 8ми сторінок
-- сторінка це модуль який займає 8кБ
-- sql server відслідковує які сторінки і екстенти належать об'єкту за допомогою системних таблиць
-- які називаються сторінками карти розподілу індекса (Index allocation map, IAM); кожна таблиця або індекс
-- має по крайній мірі одну сторінку IAM, яка називається першою сторінкою IAM. Одна сторінка IAM може 
-- вказувати приблизно на 4ГБ простору; великі об'єкти можуть мати більше одної сторінки

-- створимо таблицю організовану у вигляді кучі
USE TSQLFundamentals2008
GO

CREATE TABLE dbo.TestStructure
(
	id INT NOT NULL,
	filler1 CHAR(6) NOT NULL,
	filler2 CHAR(6) NOT NULL
)

-- загальна інформація про таблиці і індекси може бути прочитана з sys.indexes
USE TSQLFundamentals2008
SELECT OBJECT_NAME(i.[object_id]) AS table_name, i.name AS index_name,
	   i.[type], i.type_desc
FROM sys.indexes AS i
WHERE i.[object_id] = OBJECT_ID(N'dbo.TestStructure',N'U')

-- можна дізнатись скільки сторінок виділено під об'єкт наступним чином
SELECT index_type_desc,index_depth,index_level,page_count,record_count,avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(N'TSQLFundamentals2008'),OBJECT_ID(N'dbo.TestStructure'),NULL,NULL,'DETAILED') AS ddips

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure', @updateusage = TRUE

-- додамо тестову строку в таблицю 
INSERT INTO dbo.TestStructure(id,filler1,filler2)
VALUES(1,'a','b')

DECLARE @i INT = 0;
WHILE @i < 18000
BEGIN
	SET @i = @i + 1;
	INSERT INTO dbo.TestStructure(id,filler1,filler2)
	VALUES(@i,'a','b')
END

-- додамо кластеризований індекс на стовпці
TRUNCATE TABLE TSQLFundamentals2008.dbo.TestStructure
CREATE CLUSTERED INDEX idx_cl_id ON TSQLFundamentals2008.dbo.TestStructure(id)
CREATE INDEX idx_TestStructure_f1 ON TSQLFundamentals2008.dbo.TestStructure(filler1)

ALTER TABLE TSQLFundamentals2008.dbo.TestStructure
ADD PRIMARY KEY (id)
-- видалимо індекс
USE TSQLFundamentals2008
DROP INDEX dbo.TestStructure.idx_TestStructure_f1

-- для перегляду всіх індексів таблиці
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

 -- створимо тип даних користувача
 CREATE TYPE TestStructType AS TABLE
 (
 	Id INT PRIMARY KEY,
 	Fill1 CHAR(6),
 	Fill2 CHAR(6) 
 )
 
 -- створимо процедуру
 CREATE PROCEDURE dbo.spInsertOrder
  @TestStructTp dbo.TestStructType READONLY
 AS 
 BEGIN
 	INSERT INTO TSQLFundamentals2008.dbo.TestStructure(id,filler1,filler2)
 	SELECT tp.Id, tp.Fill1, tp.Fill2
 	FROM @TestStructTp AS tp
 END
 
 -- викличемо процедуру
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
