USE TSQLFundamentals2008;
GO

-- Changed from github editor. V1.2
-- Changed from master V1.2
-- 00:31 3/30/2017
-- From bchr branch

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

-- Ïåðøèé âàð³àíò º êðàùèì îñê³ëüêè êîëè âèêîíóþòüñÿ ìàí³ïóëÿö³¿ íà ñòîïö³ ç ô³ëüòðà
-- ñåðâåð íå ìàº ìîæëèâîñò³ åôåêòèâíî çàñòîñóâàòè ³íäåêñè
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

-- Âèêîðèñòàííÿ ôóíêö³¿ TRY_CAST ÿêà ïîâåðòàº NULL ÿêùî îïåðàö³ÿ çàâåðøóºòüñÿ íåâäà÷åþ - òàêèì
-- ÷èíîì çàïèò íå ïîâåðíå ñòð³÷êó ÿêà â ïðåäèêàò³ ìàº NULL çàì³ñòü òîãî ùîá ãåíåðóâàòè ïîìèëêó
-- Òóò ñë³ä ïàìÿòàòè ùî ïîñë³äîâí³ñòü îïåðàòîð³â â WHERE clause íå âèêîíóºòüñÿ çë³âà íàïðàâî
-- ÷è ÿêîñü ïî ³íøîìó - âîíè âèêîíóþòüñÿ îäíî÷àñíî, òîìó íå ìîæíà ñòâåðäæóâàòè ùî ñïî÷àòêó 
-- â³äáóäåòüñÿ ïåðåâ³ðêà vt.propertytype = 'INT' ÿêà íå ïðîïóñòèòü ïåðåâ³ðêó äàë³ 
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

-- Êîëè âèêîíóºòüñÿ ïîøóê òèïó "col1 LIKE 'ABC%'" ñåðâåð ùå ìîæå âèêîðèñòàòè ³íäåêñ äëÿ ô³òðóºìîãî ñòîâïöÿ
-- ÿêùî øàáëîí ïî÷èíàºòüñÿ ÿê '%ABC%' ñåðâåð íå ìîæå ïîêëàäàòèñü íà âèêîðèñòàííÿ ³íäåêñà
-- '20070212' = ymd
-- '2007-02-12' = ymd íå çàëåæíà â³ä ìîâè äëÿ DATE,DATETIME2,DATETIMEOFFSET

-- Ôîðìàòóâàííÿ äàòè ³ ÷àñó
SELECT o.orderid,o.orderdate,o.empid,o.custid 
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE YEAR(o.orderdate) = 2007 AND MONTH(o.orderdate) = 2;

-- àëå îñê³ëüêè âèêîðèñòîâóþòüñÿ ìàí³ïóëÿö³¿ íà ñòîâïöåì ïî ÿêîìó â³äáóâàºòüñÿ ô³ëüòðàö³ÿ 
-- sql server íå ìîæå ïîêëàäàòèñü íà âïîðÿäêóâàííÿ ïî ³íäåêñó

SELECT o.orderid,o.orderdate,o.empid,o.custid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.orderdate >= '20070201' AND o.orderdate < '20070301'

-- òàêîæ äëÿ ðîáîòè ç äàòàìè êðàùå âèêîðèñòîâóâàòè îïåðàòîðè >= i < í³æ îïåðàòîð BETWEEN îñê³ëüêè öåé îïåðàòîð ìîæå çàêðóãëèòè çíà÷åííÿ

-- Ñîðòóâàííÿ
-- ßêùî âèêîðèñòîâóºòüñÿ DISTINCT à òàêîæ ORDER BY â îäíîìó ³ òîìó æ çàïèò³ - ðåçóëüòóþ÷èé íàá³ð ïîâèíåí ì³ñòèòè
-- ñòîâïö³ ïî ÿêèõ â³äáóâàºòüñÿ ñîðòóâàííÿ + áóäü ÿê³ ³íø³
-- ÿêùî çàïèò íå ì³ñòèòü DISTINCT ðåçóëüòóþ÷èé íàá³ð íå îáîâ"ÿçêîâî ïîâèíåí ì³ñòèòè ñòîïö³ ïî ÿêèõ â³äáóâàºòüñÿ ñîðòóâàííÿ
-- Íàïð. : ÿêùî âèáèðàþòüñÿ îêðåì³ ì³ñòà â ÿê³ ìîæóòü ì³ñòèòè á³ëüøå îäíîãî ïðàö³âíèêà ³ â³äáóâàºòüñÿ ñîðòóâàííÿ ïî äàò³
-- íàðîäæåííÿ, ïðè ÷îìó âîíà íå âêëþ÷åíà â ðåçóëüòóþ÷èé íàá³ð òî ñåðâåð íå çíàº ÿêó ñàìå ñòðîêó âèáðàòè â DISTINCT îñê³ëüêè
-- îäíå ì³ñòî ìàº äåê³ëüêà ïðàö³âíèê³â ç ð³çíèìè äíÿìè íàðîäæåííÿ
SELECT DISTINCT e.city
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE e.country = N'USA' AND e.region = N'WA'
ORDER BY e.birthdate

-- ïðàâèëüíèì áóäå çàïèò
SELECT DISTINCT e.city
FROM TSQLFundamentals2008.HR.Employees AS e
WHERE e.country = N'USA' AND e.region = N'WA'
ORDER BY e.city

-- ñîðòóâàííÿ NULL çíà÷åíü
-- êîëè shippeddate is null òî ïîâåðòàºòüñÿ 0, ÿêùî íå NULL òî 1 - òàêèì ÷èíîì 0 áóäå ïåðåä 1 ³ çíà÷åííÿ NOT NULL áóäóòü ñïî÷àòêó
SELECT o.orderid, o.shippeddate
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 20
ORDER BY CASE WHEN o.shippeddate IS NULL 
			  THEN 1
			  ELSE 0 
         END, o.shippeddate 
         
-- íåäåòåðì³íîâàíå ñîðòóâàííÿ - ÿêùî â ðåçóëüòóþ÷îìó íàáîð³ áóäå ñòîïåöü ïî ÿêîìó â³äáóâ ñîðòóâàííÿ ³ â³í ìàº äåê³ëüêà îäíàêîâèõ çíà÷åíü          
-- äåòåðì³íîâàíå ñîðòóâàííÿ - ñïèñîê ORDER BY ïîâèíåí áóòè óí³êàëüíèì

-- Ô³ëüòðóâàííÿ äàíèõ çà äîïîìîãîþ TOP i FETCH ... OFFSET
SELECT TOP(1) o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

SELECT TOP(1) PERCENT o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

-- WITH TIES ïîâåðíå äóþëþþ÷³ ðåçóëüòàòè ïî orderdate ÿêùî òàê³ º
SELECT TOP(1) WITH TIES o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC

-- àáî äîäàìî äåòåðì³í³çì : íàïð ùîá ñòðîêè ç á³ëüøèì orderid âèãðàëè
SELECT TOP(3) o.orderid, o.orderdate, o.custid, o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
ORDER BY o.orderdate DESC,o.orderid DESC

-- FETCH ... OFFSET
-- òåïåð ORDER BY ìàº äâ³ ðîë³ : 1) ïîâ³äîìèòè fetch/offset ÿê³ ñòðîêè ïîòð³áíî ô³ëüòðóâàòè
--								 2) îïðèäåëåíèå ñîðòèðîâêè ïðåäñòàâëåíèÿ â çàïðîñå
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

-- íàéá³ëüø äîðîã³ òîâàðè ïåðøî¿ êàòåãîð³¿
SELECT TOP (5) p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC

-- îñê³ëüêè ïîïåðåäí³é çàïèò íå äåòåðì³íîâàíèé - çðîáèìî öå çà ðàõóíîê çâÿçê³â
SELECT TOP (5) WITH TIES
	   p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC

-- à òåïåð çðîáèìî äåòåðì³íóâàííÿ çà ðàõóíîê productid â ïîðÿäêó ñïàäàííÿ
SELECT TOP (5) p.productid, p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.categoryid = 1         
ORDER BY p.unitprice DESC, p.productid DESC

-- ïåðåãëÿä òîâàð³â ïî 5 øòóê çà ðàç, ç ñîðòóâàííÿì ïî ö³í³ ³ ðîçðèâó ïî productid
DECLARE @page_size INT = 5;
DECLARE @page_num INT = 1;

SELECT *
FROM TSQLFundamentals2008.Production.Products AS p
ORDER BY p.unitprice DESC, p.productid DESC
OFFSET (@page_num - 1) * @page_size ROWS FETCH NEXT @page_size ROWS ONLY

-- Êîáìá³íóâàííÿ íàáîð³â äàíèõ
-- âèâ³ä äàíèõ ïðî äí³ òèæíÿ * 3 çì³íè íà äåíü
SELECT n1.n AS theday, n2.n AS shiftno
FROM TSQLFundamentals2008.Sales.Nums AS n1
CROSS JOIN TSQLFundamentals2008.Sales.Nums AS n2
WHERE n1.n <= 7 AND n2.n <= 3
ORDER BY theday,shiftno

-- âíóòð³øíº çºäíàííÿ ïîâåðòàº ò³ëüêè ò³ ñòðîêè ÿê³ ïðîõîäÿòü ïî ïðåäèêàòó â ON 
-- ÿêùî ïðåäèêàò ïîâåðòàº FALSE àáî NULL òî ñòðîêè â³äêèäàþòüñÿ
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid
WHERE s.country = N'Japan'

-- ð³çíèö³ ì³æ ïðåäèêàòàìè ON i WHERE äëÿ âíóòð³øí³õ ç"ºäíàíü íåìàº òîìó ìîæíà íàïèñàòè íàñòóïíèì ÷èíîì
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid AND 
															s.country = N'Japan'
															
-- ñàìîç"ºäíàííÿ äëÿ òîãî ùîá çíàéòè ìåíåäæåð³â äëÿ ðîá³òíèê³â
SELECT e1.empid, 
	   e1.firstname + e1.lastname AS [emp name],
	   e2.firstname + e2.lastname AS [mng name]
FROM TSQLFundamentals2008.HR.Employees AS e1
INNER JOIN TSQLFundamentals2008.HR.Employees AS e2 ON e1.mgrid = e2.empid															

-- çîâí³øí³ ç"ºäíàííÿ ïîâåðòàþòü ñòðîêè îá'ºäíàí³ ïî ïðåäèêàòó + ñòðîêè ç ë³âî¿ íàïð òàáëèö³ ç³ ñòðîêàìè ïðàâî¿ çàì³íåíèõ íà NULL
-- â öüîìó òèï³ ç'ºäíàííÿ ON i WHERE ìàþòü ð³çí³ ðîë³
-- WHERE ÿê ³ ðàí³øå ìàº ðîëü ô³ëüòðà ÿêèé â³äêèäóº ñòðîêè FALSE i NULL
-- ON â öüîìó âèïàäêó íå º ô³ëüòðîì éîãî çàâäàííÿ - ñï³âïàä³ííÿ äàíèõ, ³íøèìè ñëîâàìè äàí³ ç ë³âî¿ òàáëèö³ ïîâåðíóòüñÿ íàâ³òü
-- ÿêùî â ïðåäèêàò³ ON íåìàº ñï³âïàä³íü
-- ÿêùî â íàñòóïíîìó çàïèò³ çàì³íèòè WHERE íà AND òî çàì³ñòü ïîñòàâíèê³â ç ßïîí³¿ ìè îòðèìàºìî âñ³õ ïîñòàâíèê³â (áî öå ë³âà òàáëèöÿ)
SELECT s.companyname AS supplier, s.country, p.productid, p.productname, p.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
LEFT JOIN TSQLFundamentals2008.Production.Products AS p ON s.supplierid = p.supplierid
WHERE s.country = N'Japan'

SELECT e1.empid, 
	   e1.firstname + e1.lastname AS [emp name],
	   e2.firstname + e2.lastname AS [mng name]
FROM TSQLFundamentals2008.HR.Employees AS e1
LEFT JOIN TSQLFundamentals2008.HR.Employees AS e2 ON e1.mgrid = e2.empid	

-- âèâ³ä êë³ºíò³â ÿê³ íå ìàþòü çàìîâëåíü
SELECT c.custid,c.companyname,o.orderid,o.orderdate
FROM TSQLFundamentals2008.Sales.Customers AS c
LEFT JOIN TSQLFundamentals2008.Sales.Orders AS o ON c.custid = o.custid
WHERE o.orderid IS NULL

-- âèâåñòè âñ³õ êë³ºíò³â àëå çíàéòè â³äïîâ³äí³ ¿ì çàìîâëåííÿ ÿê³ áóëè ðîçì³ùåí³ ò³ëüêè â ëþòîìó 2008 
SELECT c.custid,c.companyname,o.orderid,o.orderdate
FROM TSQLFundamentals2008.Sales.Customers AS c
LEFT JOIN TSQLFundamentals2008.Sales.Orders AS o ON c.custid = o.custid AND
												    o.orderdate >= '20080201' AND 
												    o.orderdate < '20080301'

-- Çâÿçàíèé ï³äçàïèò
-- ïîòð³áíî ïîâåðíóòè ïðîäóêòè ÿê³ ìàþòü ì³í³ìàëüíó ö³íó â êîæí³é êàòåãîð³¿
SELECT p.categoryid, p.productid,p.productname,p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p
WHERE p.unitprice = (SELECT MIN(p2.unitprice) 
                     FROM TSQLFundamentals2008.Production.Products AS p2
                     WHERE p.categoryid = p2.categoryid )			
ORDER BY p.unitprice,p.categoryid 

-- âåðòàþòüñÿ êë³ºíòè ÿê³ ðîçì³ñòèëè ñâî¿ çàìîâëåííÿ 12 ëþòîãî 2007 ðîêó
SELECT c.custid,c.companyname
FROM TSQLFundamentals2008.Sales.Customers AS c
WHERE EXISTS (SELECT * FROM TSQLFundamentals2008.Sales.Orders AS o 
					   WHERE o.custid = c.custid AND o.orderdate = '20070212')					   

-- Òàáëè÷í³ âèðàçè
-- òàáëè÷íèé âèðàç ïîâèíåí áóòè ðåëÿö³éíèì, òîìó íå ìîæíà çàñòîñîâóâàòè ORDER BY 
-- âèêëþ÷åííÿì º çàñòîñóâàííÿ êîíñòðóêö³¿ ORDER BY ç êîíñòðóêö³ÿìè TOP/FETCH...OFFSET
-- òàáëè÷í³ âèðàçè íå ìàþòü âïëèâó íà ïðîäóêòèâí³ñòü

-- p.s. ROW_NUMBER òà ³íø³ â³êîíí³ ôóíêö³¿ äîçâîëåí³ ò³ëüêè â SELECT i ORDER BY
SELECT 
	ROW_NUMBER() OVER (PARTITION BY p.categoryid 
					   ORDER BY p.unitprice, 
								p.productid ASC) AS rn,
	p.categoryid,
	p.productid,
	p.productname,
	p.unitprice
FROM TSQLFundamentals2008.Production.Products AS p

-- ïîâåðòàºìî ïåðø³ äâà ïðîäóêòè ç íàéíèæ÷èìè ö³íàìè ç êîæíî¿ êàòåãîð³¿ (ïðèêëàä ïðîèçâîäíîé òàáëèöè)
-- ì³íóñè ïðîèçâîäíèõ òàáëèö : óñêëàäíþºòüñÿ ëîã³êà, òàê ÿê áàãàòî âêëàäåíü; ïðîáëåìè ïðè ðîáîò³ ç ñîåäèíåíèÿìè
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

-- Îáîáùåííèå òàáëè÷íèå âèðàæåíèÿ (common table expression) CTE
-- ÿêùî ïîòð³áíî äåê³ëüêà CTE ìîæíà ïðîñòî ðîçä³ëèòè ¿õ êîìàìè; êîæåí CTE ìîæå ïîñèëàòèñü
-- íà ïîïåðåäí³é, à çîâí³øí³é çàïèò ìîæå ïîñèëàòèñü íà âñ³ CTE
-- òàêîæ ìîæíà ïîñèëàòèñü íà äåëüêà åêçåìïëÿð³â CTE ùî íå ìîæëèâî äëÿ ïðîèçâîäíèõ òàáëèö
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

-- CTE ìîæóòü áóòè ðåêóðñèâíèìè : ðåêóðñ³ÿ ïðèïèíÿºòüñÿ êîëè ïîâåðòàºòüñÿ ïóñòèé íàá³ð
-- íàïðèêëàä âèâåäåìî ³ºðàðõ³þ ìåíåäæåð³â äëÿ ðîá³òíèêà
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

-- òåïåð âèâåäåìî âñ³õ ðîá³òíèê³â ìåíåäæåðà
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


-- Ïðåäñòàâëåíèÿ (view) ³ âñòðîºí³ òàáëè÷í³ ôóíêö³¿
-- ãîëîâíà ð³çíèöÿ ì³æ íèìè òå ùî ïåðø³ íå ìîæóòü ïðèéìàòè âõ³äíèõ ïàðàìåòð³â
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

-- Ñòâîðåííÿ òàáëè÷íî¿ ôóíêö³¿ 
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

-- Oïåðàòîð APPLY
-- CROSS APPLY : ÿêùî ïðàâèé òàáëè÷íèé âèðàç ïîâåðòàº ïóñòó ñòðîêó äëÿ ë³âîãî - òàêà ñòðîêà â³äêèäàºòüñÿ
-- ïîòð³áíî ïîâåðíóòè äâà òîâàðè ç ì³í ö³íîþ äëÿ ïîñòàâíèêà ç ID = 1
-- îñê³ëüêè âèðàç APPLY çàñòîñîâóºòüñÿ äëÿ êîæíîãî ïîñòàâíèêà çë³âà âè îòðèìóºòå
-- äâà ïðîäóêòè ç ì³í ö³íîþ äëÿ êîæíîãî ïîñòàâíèêà ç ßïîí³¿
-- òàê ÿê CROSS APPLY íå ïîâåðòàº ë³â³ ñòðîêè äëÿ ÿêèõ òàáëè÷íèé âèðàç ïîâåðòàº ïóñòèé íàá³ð
-- ïîñòàâíèêè ç ßïîí³¿, ÿê³ íå ìàþòü â³äïîâ³äíèõ ïðîäóêò³â â³äêèäàþòüñÿ
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
-- öåé îïåðàòîð ðîáèòü òåæ ñàìå ùî CROSS APPLY ³ êð³ì òîãî âêëþ÷àº â ðåçóëüòàò
-- ñòðîêè ç ë³âî¿ ñòîðîíè äëÿ ÿêèõ ïîâåðòàºòüñÿ ïóñòèé íàá³ð ç ïðàâî¿ ñòîðîíè
-- çíà÷åííÿ NULL âèêîðèñòîâóþòüñÿ ÿê çàì³ííèêè ðåçóëüòàòó ç ïðàâî¿ ñòîðîíè
-- â äåÿêîìó ðîçóì³íí³ ð³çíèöÿ ì³æ CROSS APPLY i OUTER APPLY òàêàæ ÿê ð³çíèöÿ ì³æ
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

-- ÏÐÀÊÒÈÊÓÌ
-- çðîáèòè âèá³ðêó êàòåãîð³é ïðîäóêò³â òà ì³í ö³íè äëÿ êîæíî¿ êàòåãîð³¿
SELECT p.categoryid, MIN(p.unitprice) AS min_price
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.categoryid

-- òåïåð ñòâîðèìî CTE ³ îáºäíàºìî éîãî ç Production.Products äëÿ òîãî ùîá âèáðàòè ³íôó ïðî ïðîäóêò
;WITH prodCte AS(
	SELECT p.categoryid, MIN(p.unitprice) AS min_price
	FROM TSQLFundamentals2008.Production.Products AS p
	GROUP BY p.categoryid
)
SELECT p.*
FROM prodCte AS pc
INNER JOIN TSQLFundamentals2008.Production.Products AS p ON pc.categoryid = p.categoryid
WHERE p.unitprice = pc.min_price

-- òåæ ñàìå àëå ÷åðåç apply (ÿêùî â êàòåãîð³¿ áóäóòü ñòðîêè â ÿêèõ ö³íà îäíàêîâà òî áóäóòü áðàòèñü îáèäâîº)
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

-- ñòâîðèòè òàáëè÷íó ôóíêö³þ ÿêà ïðèéìàº íà âõ³ä @ID ïîñòàâíèêà ³ @n òîâàð³â ç ì³í ö³íàìè ÿê³ 
-- ìàþòü áóòè ïîâåðíåí³. ÿêùî º îäíàêîâ³ òîâàðè òî çàñòîñîâóºòüñÿ óòî÷íþþ÷èé ïàðàìåòåð productid
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

-- ïîâåðíåìî äâà ïðîäóêòè äëÿ êîæíîãî ïîñòàâíèêà ç ßïîí³¿
DECLARE @tot_prods2 INT = 2;
SELECT s.supplierid,ca.productid,ca.productname,ca.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
CROSS APPLY TSQLFundamentals2008.Production.GetTopProducts(s.supplierid,@tot_prods2) AS ca
WHERE s.country = N'Japan'

-- çàñòîñóºìî ïîïåðåäí³é çàïèò äëÿ âèâîäó íàâ³òü òèõ ïîñòàâíèê³â ç ßïîí³¿ â ÿêèõ íåìàº ïðîäóêò³â
DECLARE @tot_prods2 INT = 2;
SELECT s.supplierid,ca.productid,ca.productname,ca.unitprice
FROM TSQLFundamentals2008.Production.Suppliers AS s
OUTER APPLY TSQLFundamentals2008.Production.GetTopProducts(s.supplierid,@tot_prods2) AS ca
WHERE s.country = N'Japan'

-- Îïåðàòîðè äëÿ ðîáîòè ç íàáîðàìè
-- îïåðàòîðè ïî ðîáîò³ ç íàáîðàìè ðîçãëÿäàþòü äâà çíà÷åííÿ NULL ÿê ð³âí³
-- îêðåì³ çàïèòè íå ìîæóòü ìàòè ORDER BY, öåé îïåðàòîð ìîæå áóòè ò³ëüêè äëÿ íàáîðó
-- ³ìåíà ñòîâïö³â äëÿ ðåçóëüòóþ÷èõ ñòîâïö³â âèçíà÷àþòüñÿ ïåðøèì çàïèòîì

-- UNION/UNION ALL
-- UNION ìàº íåÿâíèé DISTINCT, òîìó â³í íå ïîâåðòàº äóáëþþ÷èõ ñòðîê
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
UNION
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- UNION ALL ïîâåðòàº âñ³ ðåçóëüòàòè
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
UNION ALL
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- INTERSECT ïîâåðòàº ñï³ëüí³ äàí³, òîáòî ÿêùî ñòðîêà çóñòð³÷àºòüñÿ 1+ â ïåðøîìó íàáîð³ ³ 
-- 1+ â äðóãîìó òî âîíà ïîâåðíåòüñÿ
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
INTERSECT
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- EXCEPT ïîâåðòàº äàí³ ÿê³ º â ïåðøîìó ³ â³äñóòí³ â äðóãîìó íàáîð³
SELECT e.country AS country, e.region AS region, e.city AS city
FROM TSQLFundamentals2008.HR.Employees AS e
EXCEPT
SELECT c.country,c.region,c.city
FROM TSQLFundamentals2008.Sales.Customers AS c

-- Â UNION i INTERSECT ïîðÿäîê âõîäó íàáîð³â íåìàº çíà÷åííÿ, ó âèïàäêó EXCEPT ìàº
-- INTERSECT ìàº âèùèé çà UNION/EXCEPT ïð³îð³òåò. Ïð³îð³òåò òóò òàêîæ ìîæíà çàäàòè ÷åðåç
-- êðóãë³ ñêîáêè
-- INTERSECT/EXCEPT íå ïîâåðòàº äóáë³êàò³â ñòðîê

-- âèâåñòè ðîá³òíèê³â ÿê³ îáñëóãîâóâàëè êë³ºíòà 1 àëå íå êë³ºíòà 2
SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 1

EXCEPT

SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 2

-- âèâåñòè ðîá³òíèê³â ÿê³ îáñëóãîâóâàëè ³ êë³ºíòà 1 ³ êë³ºíòà 2
SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 1

INTERSECT

SELECT o.empid
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.custid = 2

-- âèáðàòè employee id òèõ ÿê³ íå ðîáèëè çàìîâëåííÿ 12 ëþòîãî 2008 ðîêó ð³çíèìè ñïîñîáàìè
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

-- Ãðóïóâàííÿ äàíèõ
-- çàïèò ÿêèé ãðóïóº âñ³ äàí³ â îäíó ãðóïó
SELECT COUNT(*)
FROM TSQLFundamentals2008.Sales.Orders AS o

-- âèâåñòè ïî â³äïðàâíèêó âàíòàæó ³ âèâîäèòü ê³ëüê³ñòü ñòðîê íà êîæíó ãðóïó
SELECT o.shipperid, COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
GROUP BY o.shipperid

-- ãðóïóâàòè äàí³ ïî â³äïðàâíèêó áàãàæó ³ ïî ðîêó
SELECT  o.shipperid
	   ,YEAR(o.shippeddate) AS shipperdate
	   ,COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
GROUP BY o.shipperid, YEAR(o.shippeddate)
ORDER BY o.shipperid, YEAR(o.shippeddate)

-- âèâåñòè ò³ äàí³ äëÿ ÿêèõ âàíòàæ âæå â³äâàíòàæåíî
-- òóò WHERE ïðàöþº íà ð³âí³ ñòðîêè à HAVING âæå ÿê ô³ëüòð ãðóïè
SELECT  o.shipperid
	   ,YEAR(o.shippeddate) AS shipperdate
	   ,COUNT(*) AS numorders
FROM TSQLFundamentals2008.Sales.Orders AS o
WHERE o.shippeddate IS NOT NULL
GROUP BY o.shipperid, YEAR(o.shippeddate)
HAVING COUNT(*) < 100

-- COUNT (*) íå ðåêîìåíäîâàíèé âàð³àíò áî ÿêùî â ñòîâïö³ º NULL òî âîíè áóäóòü ïîðàõîâàí³
-- COUNT (o.shippeddate) ðåêîìåíäîâàíèé âàð³àíò
-- ìîæíà òàêîæ âèêîðèñòîâóâàòè COUNT(DISTINCT o.shippeddate)

-- Ïîñèëàòèñü â SELECT ìîæíà ò³ëüêè íà ñòîâïö³ ÿê³ º â GROUP BY
-- àáî ðîáèòè îáõ³äíèé øëÿõ íàïðèêëàä ç òàáëè÷íèì âèðàçîì
;WITH cte AS (
	SELECT s.shipperid, COUNT(s.shipperid) AS nums
	FROM TSQLFundamentals2008.Sales.Shippers AS s
	GROUP BY s.shipperid
)
SELECT s.shipperid, s.companyname, c.nums
FROM TSQLFundamentals2008.Sales.Shippers AS s
INNER JOIN cte AS c ON c.shipperid = s.shipperid;

-- âèâåñòè ê³ëüê³ñòü çàìîâëåíü íà êîæíîãî êë³ºíòà ç ³ñïàí³¿
SELECT c.custid, COUNT(c.custid) AS ord_nums
FROM TSQLFundamentals2008.Sales.Orders AS o
INNER JOIN TSQLFundamentals2008.Sales.Customers AS c ON c.custid = o.custid
WHERE c.country = N'Spain'
GROUP BY c.custid

-- äîäàòè íà âèâ³ä òàêîæ ì³ñòî
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
-- öåé îïåðàòîð âèäàëÿº ñòðîêè ÿê³ ì³ñòÿòü NULL
-- â îïåðàòîð³ PIVOT öå íå ìîæëèâî çðîáèòè ÿêùî ñòîâïåöü ïîñòà÷àëüíèêà áóâ íåîáõ³äíèé
-- õî÷ äëÿ îäíîãî êë³ºíòà á³ëüøå
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

-- íàïèñàòè çàïèò äî òàáëèö³ Orders ÿêèé âèâîäèòü ìàêñèìàëüíó äàòó çàìîâëåííÿ äëÿ êîæíîãî
-- ðîêó à òàêîæ â³äâàíòàæóâà÷à ãðóçó
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

-- íàïèñàòè çàïèò ÿêèé ïîðàõóº äëÿ êîæíîãî êë³ºíòà ê³ëüê³ñòü çàìîâëåíü ÿêó â³äâàíòàæèâ ïåâíèé â³äâàíòàæíèê
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
 * Â³êîíí³ ôóíêö³¿
 *******************************************/
-- ïåðåâàãè ïåðåä ãðóïóâàííÿì â òîìó ùî ìîæíà âèêîðèñòîâóâàòè ãðóïóþ÷³ ³ äåòàë³çîâàí³ åëåìåíòè â îäíîìó çàïèò³
-- OVER() - ïðåäñòàâëÿº ñóìàðíó ê³ëüê³ñòü ñòðîê â áàçîâîìó çàïèò³
-- OVER(PARTIOTION BY some_col) - íàäàº ãðóïóâàííÿ äëÿ êîíêðåòíîãî åëåìåíòà
-- íàïð. SUM(val) OVER(PARTITION BY custid) - ÿêùî äëÿ ïîòî÷íî¿ ñòðîêè custid = 1, òî áóäóòü ò³ëüêè ò³ ñòðîêè â
-- âèá³ðö³ â ÿêèõ custid = 1, òîáòî âèðàç ïîâåðíå ñóìó äëÿ custid = 1

SELECT ov.custid,
	   ov.orderid,
	   ov.val,
	   SUM(ov.val) OVER(PARTITION BY ov.custid) AS custtotal,
	   SUM(ov.val) OVER() AS grandtotal
FROM TSQLFundamentals2008.Sales.OrderValues AS ov

-- â³êîíí³ àãðåãàòí³ ôóíêö³¿ òàêîæ ï³äòðèìóþòü êàäðóâàííÿ
-- çì³ñò êàäðóâàííÿ ïîëÿãàº â òîìó ùî îïðèä³ëÿºòüñÿ âïîðÿäêóâàííÿ âñåðåäèí³ ñåêö³¿
-- çà äîïîìîãîþ â³êîííîãî êàäðà, ³ ïîò³ì íà îñíîâ³ öüîãî âïîðÿäêóâàííÿ ìîæíà çàêëþ÷èòè íàá³ð ñòðîê 
-- ì³æ äâîìà ãðàíèöÿìè
-- â â³êîííîìó êàäð³ âêàçóºòüñÿ âèì³ðþâàííÿ ROWS/RANGE
-- âèêîðèñòîâóþ÷è ROWS ìîæíà âêàçàòè ãðàíèö³ ÿê îäèí ç ïàðàìåòð³â
-- 1. UNBOUNDED PRECEDING/FLOWING ÿê³ îçíà÷àþòü ïî÷àòîê ³ ê³íåöü ñåêö³¿ â³äïîâ³äíî
-- 2. CURRENT ROW - ïîòî÷íà ñòðîêà
-- 3. <n> ROWS PRECEDING/FLOWING ùî îçíà÷àº <n> ñòðîê äî ÷è ï³ñëÿ ïîòî÷íî¿ ñòðîêè

-- íàïèñàòè çàïèò äî OrderValues ÿêèé âèðàõóº ïðîì³æí³ çíà÷åííÿ ñóìè â³ä ïî÷àòêó ä³ÿëüíîñò³ 
-- äî ïîòî÷íîãî çàìîâëåííÿ
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

-- â sql º òàê³ ðàíæåðóþ÷³ ô-ö³¿ : ROW_NUMBER, RANK, DENSE_RANK, NTILE
-- äëÿ íèõ îáîâÿçêîâî âêàçóâàòè ORDER BY 
-- âàæëèâî ðîçóì³òè ùî ORDER BY â OVER îïðèä³ëÿº ò³ëüêè âïîðÿäêóâàííÿ äëÿ
-- îá÷èñëåííÿ â³êîííî¿ ôóíêö³¿; äëÿ òîãî ùîá ñîðòóâàòè ñòðîêè â âèá³ðö³ òðåáà
-- äîäàòè ORDER BY äëÿ âèá³ðêè
SELECT ov.custid, ov.orderid, ov.val,
	   ROW_NUMBER() OVER (ORDER BY ov.val) AS rn,
	   RANK()		OVER (ORDER BY ov.val) AS rnk,
	   DENSE_RANK() OVER (ORDER BY ov.val) AS denserank,
	   NTILE(100)	OVER (ORDER BY ov.val) AS ntilee100 
FROM TSQLFundamentals2008.Sales.OrderValues AS ov

-- ROW_NUMBER âèðàõîâóº óí³êàëüíèé ïîñë³äîâíèé íîìåð ñòðîêè ïî÷èíàþ÷è ç 1 â ñåêö³¿ â³êíà íà
-- îñíîâ³ ñîðòóâàííÿ; òàê ÿê ïîïåð çàïèò íå ìàº â³êíà òî ôóíêö³ÿ ðîçãëÿäàº ðåçóëüòóþ÷ó âèá³ðêó ÿê îäèí íàá³ð äàíèõ
-- òîáòî ôóíêö³ÿ âèðàõîâóº óí³êàëüí³ íîìåðè ñòðîê äëÿ âñüîãî ðåçóëüòóþ÷îãî íàáîðó;
-- order by - º íåîáõ³äíèì äëÿ ö³º¿ ôóíêö³¿
-- partiotion by - îïö³îíàëüíî 

-- RANK ³ DENSE_RANK â³äð³çíÿºòüñÿ â³ä ROW_NUMBER òèì ùî ÿêùî â ñîðòóâàíí³ çóñòð³÷àþòüñÿ îäíàêîâ³ ðåçóëüòàòè, íàïð
-- val = 36.00 äâà ³ á³ëüøå ðàç³â ï³äðÿä, òî RANK íå ïðèñâîþº íîâîãî ïîðÿäêîâîãî íîìåðó òàê³é ñòðîö³ à ROW_NUMBER ïðèñâî¿òü
-- RANK ìîæå ìàòè ðîçðèâè çíà÷åíü à DENSE_RANK í³ 
-- NTILE - âèêîðèñòîâóºòüñÿ äëÿ òîãî ùîá îðãàí³çóâàòè ñòðîêè â ñåðåäèí³ ñåêö³¿ â áàæàíó ê³ëüê³ñòü ãðóï; â íàøîìó âèïàäêó
-- ìè ðîáèëè çàïèò íà 100 ãðóï; 830 / 100 = 8 ç îñòàòêîì 30. Îñê³ëüêè º îñòàòîê òî ïåðø³ 30 ãðóï ìàòèìóòü ïî äîäàòêîâ³é 
-- ñòðîö³, òîáòî ïî 9 ñòðîê. Íàñòóïí³ 31-100 ãðóïè ïî 8 ñòðîê.

-- ÿê áóëî ñêàçàíî â³êîíí³ ôóíêö³¿ ìîæíà çàñòîñîâóâàòè ò³ëüêè â SELECT/ORDER BY òîìó ÿêùî ïîòð³áíî â³êîííó ôóíêö³þ 
-- âèêîðèñòàòè â WHERE òðåáà çàñòîñóâàòè CTE ³ ó âíóòð³øíüîìó çàïèò³ ïðèñâî¿òè ñòîâïöþ íà áàç³ ôóíêö³¿ ïñåâäîí³ì
-- äî ÿêîãî ìîæíà áóäå çâåðòàòèñü â WHERE çîâí³øíüîãî çàïèòó.


-- íàïèñàòè çàïèò ÿêèé áóäå ïîâåðòàòè êîâçàþ÷å ñåðåäíº äëÿ îñòàíí³õ òðüîõ çàìîâëåíü êë³ºíòà
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

-- íàïèñàòè çàïèò íà âèá³ðêó òðüîõ çàêàç³â ç íàéá³ëüøèìè çàòðàòàìè íà ïåðåâåçåííÿ ïî êîæíîìó â³äïðàâíèêó
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

-- íàïèñàòè çàïèò ÿêèé âèâåäå ð³çíèöþ ì³æ ïîòî÷íèì ³ ïîïåðåäí³ì çàìîâëåííÿì äàíîãî êë³ºíòà,
-- à òàêîæ ð³çíèöþ ì³æ ïîòî÷íèì ³ íàñòóïíèì çàìîâëåííÿì
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

-- Ñòâîðåííÿ òàáëèöü
-- â Sql Server òàáëèöþ ìîæíà ñòâîðèòè äâîìà ñïîñîáàìè
-- 1. create table
-- 2. select into ÿêà àâòîìàòè÷íî ñòâîðèòü òàáëèöþ 
-- òàáëèö³ â³äíîñÿòüñÿ äî ñõåì
USE TSQLFundamentals2008
GO
CREATE SCHEMA MyShema 

-- ñõåìó äëÿ òàáëèö³ ìîæíà çì³íþâàòè
ALTER SCHEMA Sales TRANSFER production.Categories;
ALTER SCHEMA Production TRANSFER Sales.Categories;

DECLARE @v1 DECIMAL(18,6) = 191235689123.03434999999;
DECLARE @v2 REAL = 19123568912343434390909.03434999999;
DECLARE @v3 DECIMAL(38,10) = 19123568912343434390909.03434999999;
SELECT @v3

-- êîëè ïðè ãðóïóâàíí³ ïîïàäàþòüñÿ NULL çíà÷åííÿ òî âîíè áóäóòü çðóïîâàí³ â îäíó ãðóïó
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

-- äëÿ òîãî ùîá âñòàíîâèòè ðåæèì ñòèñíåííÿ ³ñíóþ÷î¿ òàáëèö³
ALTER TABLE TSQLFundamentals2008.Production.CategoriesMy 
REBUILD WITH(data_compression = PAGE)

-- êîìàíäó ALTER TABLE ìîæíà âèêîðèñòîâóâàòè â òàêèõ ö³ëÿõ
-- 1. äîäàòè àáî âèäàëèòè ñòîâïåöü, âêëþ÷àþ÷è âè÷åñëÿåìèé ñòîâïåöü
-- 2. çì³íèòè òèï äàíèõ ñòîâïöÿ
-- 3. çì³íèòè äîïóñòèì³ñòü NULL çíà÷åííÿ
-- 4. äîäàòè àáî âèäàëèòè îáìåæåííÿ (primary key, unique constraint, foreign key, check constraint, default constraint)
-- ÿêùî ïîòð³áíî çì³íèòè îïðåäåëåíèå îãðàíè÷åíèÿ - âèäàë³òü éîãî ³ ñòâîð³òü íîâå
-- êîìàíäó ALTER TABLE íå ìîæíà âèêîðèñòàòè äëÿ 
-- 1. çì³íèòè ³ìÿ ñòîâïöÿ
-- 2. äîäàâàííÿ âëàñòèâîñò³ ³äåíòèô³êàòîðà
-- 3. âèäàëåííÿ âëàñòèâîñò³ ³äåíòèô³êàòîðà

-- Ïðàêòèêóì
-- ñòâîðèòè òàáëèöþ ç îäíèì ñòîâïöåì
USE TSQLFundamentals2008
GO

CREATE TABLE Production.CategoriesTest
(
	catid INT NOT NULL IDENTITY
)
GO

-- äîäàìî ñòîïö³ äî ñòâîðåíî¿ òàáëèö³
ALTER TABLE Production.CategoriesTest
ADD catname NVARCHAR(15) NOT NULL
GO

ALTER TABLE Production.CategoriesTest
ADD descr NVARCHAR(200) NOT NULL 
GO

-- äîäàìî äàí³ â òàáëèöþ
INSERT INTO TSQLFundamentals2008.Production.CategoriesTest(catid,catname,descr)
SELECT c.categoryid, c.categoryname, c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c

-- îñê³ëüêè íå ìîæíà ÿâíî âñòàâëÿòè ³äåíòèô³êàòîð ïîòð³áíî âèêîíàòè êîìàíäó IDENTITY_INSERT ON
SET IDENTITY_INSERT Production.CategoriesTest ON;
INSERT INTO TSQLFundamentals2008.Production.CategoriesTest(catid,catname,descr)
SELECT c.categoryid, c.categoryname, c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c
GO 
SET IDENTITY_INSERT Production.CategoriesTest OFF;

-- äëÿ òîãî ùîá âèäàëèòè òàáëèöþ âèêîíàòè êîìàíäó
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL DROP TABLE Production.CategoriesTest

-- Ðîáîòà ç NULL ñòîâïöÿìè
-- ñòâîðèòè òàáëèöþ CategoriesTest
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

-- Çàïîâíèòè òàáëèöþ
SET IDENTITY_INSERT Production.CategoriesTest ON;
GO
INSERT INTO Production.CategoriesTest (catid,catname,descr)
SELECT c.categoryid,c.categoryname,c.[description]
FROM TSQLFundamentals2008.Production.Categories AS c
GO
SET IDENTITY_INSERT Production.CategoriesTest OFF;

-- çá³ëüøèìî ðîçì³ð ñòîâïöÿ description
ALTER TABLE Production.CategoriesTest
	ALTER COLUMN descr NVARCHAR(500) NOT NULL;
	
-- ïåðåâ³ðèìî òàáëèöþ íà íàÿâí³ñòü NULL â ñòîâïö³ descr
SELECT ct.descr
FROM TSQLFundamentals2008.Production.CategoriesTest AS ct	

-- ñïðîáà çì³íèòè çíà÷åííÿ â ñòîâïö³ descr íà NULL (ñïðîáà áóäå íåâäàëà)
UPDATE Production.CategoriesTest
SET descr = NULL
WHERE catid = 8

-- çì³íèìî òàáëèöþ ³ çðîáèìî çíà÷åííÿ NULL äîçâîëåíèìè
ALTER TABLE Production.CategoriesTest
	ALTER COLUMN descr NVARCHAR(500) NULL;
	
-- òåïåð ïîïðîáóºìî çì³íèòè öåé ñòîâïåöü íàçàä íà NOT NULL
ALTER TABLE Production.CategoriesTest
 ALTER COLUMN descr NVARCHAR(500) NOT NULL;

-- çì³íèìî çíà÷åííÿ â ñòîâïö³ descr 
UPDATE Production.CategoriesTest
SET descr = 'Seaweed and fish'
WHERE catid = 8 

-- î÷èñòèìî áàçó äàíèõ 
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL DROP TABLE Production.CategoriesTest;

/*******************************************
 * Ö³ë³ñí³ñòü äàíèõ
 *******************************************/ 
-- íàéêðàùèé ìåòîä äëÿ çàáåçïå÷åííÿ ö³ë³ñíîñò³ äàíèõ öå constraints

/*******************************************
 * PRIMARY KEY
 *******************************************/
-- 1) íå ìîæóòü ìàòè NULL 
-- 2) áóäü ÿê³ äàí³ ïîâèíí³ ìàòè óí³êàëüí³ äàí³ â ñòîâïö³ àáî ñòîâïöÿõ ïåðâèííîãî êëþ÷à
-- 3) ìîæå áóòè ò³ëüêè îäèí primary key â òàáëèö³
-- êîëè ñòâîðþºòüñÿ primary key íåÿâíî ñòâîðþºòüñÿ unique constraint + clustered index
-- äëÿ òîãî ùîá ïîäèâèòèñü primary key constraints â áàç³ ïîòð³áíî âèêîíàòè sys.key_constraints ç ô³ëüòðàö³ºþ ïî PK
USE TSQLFundamentals2008
GO
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.[type] = 'PK'

-- òàêîæ ìîæíà çíàéòè óí³êàëüíèé ³íäåêñ ÿêèé âèêîðèñòîâóº ñåðâåð äëÿ çàáåçïå÷åííÿ 
-- îãðàíè÷åíèÿ ïåðâè÷íîãî êëþ÷à
USE TSQLFundamentals2008
GO
SELECT *
FROM sys.indexes AS i
WHERE i.[object_id] = OBJECT_ID('Production.Categories') AND
	  i.name = 'PK_Categories';
	
/*******************************************
 * UNIQUE CONSTRAINT
 *******************************************/  
-- öåé òèï îáìåæåííÿ ÿê ³ primary key àâòîìàòè÷íî ñòâîðþº ³íäåêñ äëÿ ñòîâïöÿ ç òàêèì æå ³ìåíåì ÿê
-- îáìåæåííÿ; óí³êàëüíèé ³íäåêñ ìîæå áóòè ÿê êëàñòèðèçîâàíèé òàê ³ íå êëàñòåðèçîâàíèé 
-- îáìåæåííÿ óí³êàëüíîñò³ íå âèìàãàº ùîá ñòîâïåöü áóâ NOT NULL - ìîæíà äîçâîëèòè NULL àëå ïðè öüîìó
-- ò³ëüêè îäíà ñòðîêà ìîæå ìàòè çíà÷åííÿ NULL
-- ïåðâèííèé êëþ÷ ³ îáìåæåííÿ óí³êàëüíîñò³ ìàþòü ò³æ îáìåæåííÿ ïî ê³ëüêîñò³ êëþ÷îâèõ ñòîâïö³â ùî ³ ³íäåêñ
-- ¿õ ìàêñèìàëüíà ê³ëüê³ñòü 16 ³ ðîçì³ð 900 áàéò
-- íàïðèêëàä äëÿ òîãî ùîá çàáåçïå÷èòè óí³êàëüí³ñòü íàçâ êàòåãîð³é ìîæíà îáÿâèòè UNIQUE CONSTRAINT
ALTER TABLE Production.CategoriesTest
 ADD CONSTRAINT UC_Categories UNIQUE(categorynamee) 
 	  
-- òàêîæ ìîæíà ïðîäèâèòèñü âñ³ îáìåæåííÿ óí³êàëüíîñò³ ÿê³ º â áàç³
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.[type] = 'UQ';

-- ìîæíà çíàéòè óí³êàëüíèé ³íäåêñ çàñòîñóâàâøè ô³ëüòð ïî ³ìåí³ îáìåæåííÿ
SELECT *
FROM sys.indexes AS i
WHERE i.name = 'UK_principal_name';

/*******************************************
 * FOREIGHN KEY
 *******************************************/
-- âèêîðèñòîâóºòüñÿ ÿê ññèëêà íà òàáëèöþ â ÿê³é º ïåðâèííèé êëþ÷
-- äëÿ òîãî ùîá äîäàòè çîâí³øí³é êëþ÷ ïîòð³áíî
-- ñòâîðåííÿ îáìåæåííÿ WITH CHECK ïîäðàçóìåâàåò ÷òî åñëè â òàáëèöå ñóùåñòâóþò äàíèå
-- ³ ÿêùî ìîæëèâ³ ïîðóøåííÿ îãðàíè÷åíèÿ òî êîìàíäà ALTER TABLE çàâåðøèòüñÿ ïîìèëêîþ
-- ñòîâïö³ ç ññèëî÷íèõ òàáëèöü ïîâèíí³ ìàòè óí³êàëüíèé ³íäåêñ, ñòâîðåíèé äëÿ íèõ, àáî çà
-- äîïîìîãîþ ïåðâèííîãî êëþ÷à íåÿâíî àáî ÷åðåç îáìåæåííÿ óí³êàëüíîñò³ àáî ÷åðåç ñòâîðåííÿ ³íäåêñó
USE TSQLFundamentals2008
GO

ALTER TABLE Production.Products WITH CHECK 
 ADD CONSTRAINT FK_Products_Categories FOREIGN KEY (categoryid)
 REFERENCES Production.Categories (categoryid);

-- ðåêîìåíäîâàíî äîäàâàòè íåêëàñòåðèçîâàíèé ³íäåêñ äî çîâí³øíüîãî êëþ÷à,
-- öå äîïîìîæå ï³äíÿòè ïåðôîìàíñ â äåÿêèõ âèïàäêàõ
 
-- Ùîá çíàéòè FKs â áàç³
SELECT *
FROM sys.foreign_keys AS fk
WHERE NAME = 'FK_Products_Categories' 

/*******************************************
 * CHECK CONSTRAINTS
 *******************************************/
-- öåé òèï îáìåæåííÿ ïðèçíà÷åíèé äëÿ òîãî ùîá îáìåæóâàòè çíà÷åííÿ â ñòîïâö³ ïåâíèì ÷èíîì
-- äëÿ òîãî ùîá ñòâîðèòè òàêèé CONSTRAINT
-- ÿêùî â ñòîâïö³ äîçâîëåíi NULL ïåðåêîíàéòåñü â òîìó ùî îáìåæåííÿ âðàõîâóº NULL çíà÷åííÿ
-- âñòàâêà îáìåæåííÿ ïðîõîäèòü çíà÷åííÿ unitprice >= 0 i unitprice < 0
ALTER TABLE TSQLFundamentals2008.Production.Products WITH CHECK
 ADD CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0);

-- äëÿ òîãî ùîá îòðèìàòè ñïèñîê CHECK CONSTRAINT äëÿ òàáëèö³ âèêîðèñòîâóéòå çàïèò
SELECT *
FROM sys.[check_constraints] AS cc
WHERE cc.parent_object_id = OBJECT_ID('Production.Products');

/*******************************************
 * DEFAULT CONSTRAINTS
 *******************************************/
-- äîçâîëÿþòü çàäàòè çíà÷åííÿ ïî çàìîâ÷óâàííþ ÿêå áóäå âèêîðèñòîâóâàòèñü ïðè äîäàâàíí³
-- äàíèõ â òàáëèöþ êîëè â³äñóòí³ çíà÷åííÿ â ³íñòðóêö³¿ INSERT
-- äëÿ òîãî ùîá âèâåñòè ïåðåë³ê öèõ îáìåæåíü äëÿ òàáëèö³
SELECT * 
FROM sys.default_constraints AS dc
WHERE dc.parent_object_id = OBJECT_ID('Production.Products');

-- ÏÐÀÊÒÈÊÓÌ
/* -- Ñîçäàòü òàáëèöó Production.Products
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

-- 1. Ðîáîòà ç PRIMARY i FOREIGN KEYs
-- ïðîòåñòóºìî Primary Key
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

-- Äîäàìî íîâó ñòðîêó ÿêà ïðèçíà÷èòü íîâèé productid
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
 
-- âèäàëèìî òåñòîâó ñòðîêó
DELETE FROM Production.Products
WHERE productname = N'Product test';

-- ïðîáóºìî ùå ðàç äîäàòè ñòðîêó ç íåâ³ðíèì çíà÷åííÿì catid = 99. áóäå íåâäà÷à ÷åðåç foreign key
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

-- ïîïðîáóºìî äîäàòè çîâí³øí³é êëþ÷ ç WITH CHECK - êîìàíäà íå âèêîíàºòüñÿ
ALTER TABLE Production.Products WITH CHECK
 ADD CONSTRAINT FK_Products_Categories FOREIGN KEY (categoryid)
 REFERENCES Production.Products (categoryid);
 
-- 2. Ðîáîòà ç CHECK CONSTRAINT
-- ïåðåâ³ðèìî ùî âñ³ íàçâè ïðîäóêò³â óí³êàëüí³
USE TSQLFundamentals2008
GO

SELECT p.productname, COUNT(*) AS prodname_count
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.productname
HAVING COUNT(*) > 1;

-- çàäàìî äëÿ productid = 1 çíà÷åííÿ ð³âíèì 'Product HHYDP'
UPDATE TSQLFundamentals2008.Production.Products
SET productname = 'Product RECZE'
WHERE productid = 1;

-- çíîâó ïåðåâ³ðèìî íàçâè íà íàÿâí³ñòü äóáë³êàò³â
SELECT p.productname, COUNT(*) AS prodname_count
FROM TSQLFundamentals2008.Production.Products AS p
GROUP BY p.productname
HAVING COUNT(*) > 1;

-- ñïðîáà äîäàòè îáìåæåííÿ óí³êàëüíîñò³ - âîíà áóäå failed
ALTER TABLE Production.Products
 ADD CONSTRAINT UQ_ProdName UNIQUE(productname);

-- ïîâåðíåìî íàçâó ïðîäóêòà äî ïåðøîïî÷àòêîâî¿
UPDATE TSQLFundamentals2008.Production.Products
SET productname = 'Product HHYDP'
WHERE productid = 1;

-- òåïåð îáìåæåííÿ ìîæíà äîäàòè (ðàçîì ç íèì ñòâîðèòüñÿ nonclustered index)
ALTER TABLE Production.Products
 ADD CONSTRAINT UQ_ProdName UNIQUE(productname);
 
SELECT *
FROM sys.key_constraints AS kc
WHERE kc.name = 'UQ_ProdName'

SELECT *
FROM sys.indexes AS i
WHERE i.NAME = 'UQ_ProdName' AND
	  i.[object_id] = OBJECT_ID('Production.Products')

-- âèäàëèìî îáìåæåííÿ óí³êàëüíîñò³
ALTER TABLE Production.Products
 DROP CONSTRAINT UQ_ProdName;
 
-- Âèñíîâîê äî îáìåæåíü : îáìåæåííÿ âêëþ÷àþòü â ñåáå îáìåæåííÿ ïåðâèííîãî êëþ÷à ³ îáìåæåííÿ óí³êàëüíîñò³, ÿê³ 
-- çàáåçïå÷óþòüñÿ sql server çà äîïîìîãîþ óí³êàëüíîãî ³íäåêñó. Âîíè òàêîæ âêëþ÷àþòü îáìåæåííÿ çîâí³øíüîãî 
-- êëþ÷à, ÿêå ãàðàíòóº ùî ò³ëüêè äàí³ ïðàâèëüí³ñòü ÿêèõ ïåðåâ³ðåíà â ³íø³é òàáëèö³ äîçâîëåí³ â ö³é òàáëèö³.
-- Òàêîæ ñþäè â³äíîñÿòüñÿ check constraints i default constraints ÿê³ çàñòîñîâóþòüñÿ äî ñòîïö³â

-- ÿêùî ñïðîáóâàòè äîäàòè äî òàáëèö³ ÿêà ìàº äàí³ ñòîâïåöü NOT NULL - òî ñïðîáà áóäå íåâäàëà
-- äëÿ òîãî ùîá âñå ïðîéøëî óñï³øíî ïîòð³áíî â êîìàíä³ äîäàòè NOT NULL DEFAULT '' íàïð

-- View and table functions ÏÐÀÊÒÈÊÓÌ
-- íàïèñàòè çàïèò ÿêèé ïîêàçóº ïðîäàíó ê³ëüê³ñòü ³ çàãàëüíèé îá'ºì ïðîäàæ³â äëÿ âñ³õ ïðîäàæ³â
-- ïî ðîêó ïî êë³ºíòó ³ ïî ãðóçîâ³äïðàâíèêó
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
 * Âñòàâêà äàíèõ â áàçó
 *******************************************/
-- INSERT INTO - äîäàâàííÿ â òàáëèöþ îäíó àáî äåê³ëüêà ñòðîê
-- INSERT SELECT - äîäàâàííÿ â òàáëèöþ ðåçóëüòàòó çàïèòó
-- INSERT EXEC - äîäàâàííÿ äàíèõ â òàáëèöþ ÿê³ ïîâåðíóëèñü ç³ ñòîðêè
-- SELECT INTO - âèêîðèñòàòè ðåçóëüòàò çàïèòó äëÿ ñòâîðåííÿ ³ çàïîâíåííÿ òàáëèö³

-- äëÿ äåìîíñòðàö³¿ ñòâîðèìî òàáëèöþ 
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

-- ÿêùî ïîòð³áíî âñòàâèòè âëàñíå çíà÷åííÿ IDENTITY
USE TSQLFundamentals2008
GO
SET IDENTITY_INSERT Sales.MyOrders ON
INSERT INTO TSQLFundamentals2008.sales.MyOrders(custid,empid,orderdate,shipcountry,freight)
VALUES (4,19,'20120720',N'USA',30.0)
SET IDENTITY_INSERT Sales.MyOrders OFF

-- ìîæíà íå âêàçóâàòè äàòó îñê³ëüêè âîíà ìàº îáìåæåííÿ default
INSERT INTO TSQLFundamentals2008.sales.MyOrders(custid,empid,orderdate,shipcountry,freight)
VALUES (4,19,DEFAULT,N'USA',30.0)

-- INSERT SELECT - âñòàâëÿº ðåçóëüòóþ÷ó âèá³ðêó çãåíåðîâàíó çàïèòîì â ö³ëüîâó òàáëèöþ
USE TSQLFundamentals2008
GO

SET IDENTITY_INSERT Sales.MyOrders ON;
INSERT INTO Sales.MyOrders(orderid,custid,empid,orderdate,shipcountry,freight)
SELECT o.orderid, o.custid, o.empid, o.orderdate, o.shipcountry, o.freight
FROM sales.Orders AS o
WHERE o.shipcountry = N'Norway'
SET IDENTITY_INSERT Sales.MyOrders OFF;

-- INSERT EXEC - çà äîïîìîãîþ ö³º¿ ³íñòðóêö³¿ ìîæíà âñòàâëÿòè äàí³ ÿê³ ïîâåðíåí³ ñòîðêîþ
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
 
-- çàïóñòèìî ñòîðêó äëÿ âèá³ðêè ðåêîðä³â ïî ïîðòóãàë³¿
USE TSQLFundamentals2008
GO

SET IDENTITY_INSERT Sales.MyOrders ON;
INSERT INTO Sales.MyOrders (orderid,custid,empid,orderdate,shipcountry,freight)
EXEC sales.ordersforcountry @country = N'Portugal'
SET IDENTITY_INSERT Sales.MyOrders OFF;

-- SELECT INTO - öÿ ³íñòðóêö³ÿ ñòâîðþº òàáëèöþ ³ êîï³þº òóäè äàí³ ç âèá³ðêè; ³íäåêñè, îáìåæåííÿ, òðèãåðè íå êîï³þþòüñÿ
IF OBJECT_ID('Sales.MyOrders','U') IS NOT NULL DROP TABLE Sales.MyOrders
GO

SELECT orderid, custid, empid, orderdate, shipcountry, freight
INTO sales.MyOrders
FROM Sales.orders 
WHERE shipcountry = N'Norway' 

/*******************************************
 * Îíîâëåííÿ äàíèõ 
 *******************************************/
-- ñòâîðèìî òåñòîâ³ òàáëèö³
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

-- òðåáà äîäàòè ñêèäêó 0.05 äëÿ âñ³õ çàìîâëåíü ÿê³ çðîáëåí³ êë³ºíòàìè ç íîðâåã³¿
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

-- Íå äåòåðì³íîâàíà êîíñòðóêö³ÿ UPDATE
SELECT c.custid, c.postalcode, mo.shippostalcode
FROM TSQLFundamentals2008.Sales.MyOrders AS mo
INNER JOIN TSQLFundamentals2008.Sales.MyCustomers AS c ON mo.custid = c.custid
ORDER BY c.custid

-- â äàíîìó çàïèò³ ÿêùî äëÿ êàñòîìåðà çóñòð³÷àþòüñÿ äóáëþþ÷³ ñòðîêè â çàìîâëåííÿõ òî íåìàº
-- äåòåðì³íîâàíîñò³ ÿêà ç íèõ áóäå âèáðàíà äëÿ òîãî ùîá âèòÿãòè ç íå¿ shippostalcode
UPDATE mc
 SET mc.postalcode = mo.shippostalcode
FROM TSQLFundamentals2008.Sales.MyCustomers AS mc
INNER JOIN TSQLFundamentals2008.Sales.MyOrders AS mo ON mo.custid = mc.custid

SELECT c.custid, c.postalcode
FROM TSQLFundamentals2008.Sales.MyCustomers AS c
ORDER BY c.custid

-- äåòåðì³íîâàíèé update
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
 * Âèäàëåííÿ äàíèõ
 *******************************************/
-- äîäàìî òåñòîâ³ òàáëèö³
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

-- ³íñòðóêö³ÿ DELETE ìîæå áóòè äîñèòü çàòðàòíîþ îñê³ëüêè â³äáóâàºòüñÿ ëîãóâàííÿ ö³º¿ îïåðàö³¿
-- â æóðíàë³ 
WHILE 1 = 1
BEGIN
	DELETE TOP(1000) FROM TSQLFundamentals2008.Sales.MyOrderDetails AS mo
	WHERE mo.productid = 12
	
	IF @@ROWCOUNT < 1000 BREAK;	
	
END

/*******************************************
 * Êóðñîðè
 *******************************************/
USE TSQLFundamentals2008
GO

IF OBJECT_ID('Sales.ProcessCustomer') IS NOT NULL DROP PROC Sales.ProcessCustomer;
GO

CREATE PROC Sales.ProcessCustomer(@custid INT) AS
 PRINT 'Processing customer ' + CAST(@custid AS VARCHAR(10));
GO

-- ïðèêëàä êóðñîðà
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

-- òåæ ñàìå ò³ëüêè çà äîïîìîãîþ ³íøîãî ³òåðàö³éíîãî ð³øåííÿ
DECLARE @custid INT;
SET @custid = (SELECT TOP(1) custid FROM TSQLFundamentals2008.Sales.Customers ORDER BY custid);
WHILE @custid IS NOT NULL
BEGIN
	EXEC TSQLFundamentals2008.Sales.ProcessCustomer
		@custid = @custid
	SET @custid = (SELECT TOP(1) custid FROM TSQLFundamentals2008.Sales.Customers WHERE custid > @custid ORDER BY custid)
END

-- ñòâîðèìî òåñòîâó ôóíêö³þ ÿêà ïîâåðòàº íàá³ð ÷èñåë â çàäàíîìó ä³àïàçîí³
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
 
 -- ïåðåâ³ðêà ôóíêö³¿
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

-- âèáðàòè íàðîñòàþ÷å çíà÷åííÿ
SELECT 
	   tn.actid, tn.tranid, tn.val,
	   (SELECT SUM(tn1.val) 
	    FROM TSQLFundamentals2008.dbo.Transactions AS tn1
	    WHERE tn1.actid = tn.actid AND tn1.tranid <= tn.tranid ) AS tot_run_sum
FROM TSQLFundamentals2008.dbo.transactions AS tn
ORDER BY tn.actid, tn.tranid

-- öå æ ñàìå íà îñíîâ³ êóðñîðà
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

-- òåæ ñàìå çà äîïîìîãîþ â³êîííèõ ñòàòèñòè÷íèõ ôóíêö³é 2012
SELECT t.actid,t.tranid,t.val,
	   (SUM(val) OVER (PARTITION BY actid ORDER BY t.tranid
						   ROWS unbounded preceding)) AS balance
FROM TSQLFundamentals2008.dbo.Transactions AS t

-- íàïèñàòè çàïèò ÿêèé íà îñíîâ³ êóðñîðà âèâåäå ìàêñèìàëüí³ çíà÷åííÿ ç òàáëèö³
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

-- ð³øåííÿ çàäà÷³ íà îñíîâ³ íàáîð³â
SELECT t.actid, MAX(t.val)
FROM TSQLFundamentals2008.dbo.Transactions AS t
GROUP BY t.actid

/*******************************************
 * Òèì÷àñîâ³ òàáëèö³ ³ òàáëè÷í³ âèðàçè
 *******************************************/
-- òèì÷àñîâ³ òàáëèö³ áóâàþòü ëîêàëüí³ (#T) ³ ãëîáàëüí³ (##T)
-- ëîêàëüí³ òèì÷àñîâ³ òàáëèö³ º âèäèì³ ò³ëüêè â ñåàíñ³ ÿêèé ¿õ ñòâîðèâ;
-- ð³çí³ ñåàíñè ìîæóòü ìàòè òèì÷àñîâ³ òàáëèö³ ç îäíàêîâèìè ³ìåíàìè ³ êîæåí 
-- ñåàíñ áóäå áà÷èòè ñâîþ óí³êàëüíó òàáëèöþ - ñåðâåð äîäàº ñóô³êñ äî íàçâ ùîá âîíè áóëè
-- óí³êàëüí³ â ñèñòåì³;
-- ëîêàëüí³ òèì÷àñîâ³ òàáëèö³ º âèäèì³ âñüîìó ð³âíþ ÿêèé ¿õ ñòâîðèâ - â ïàêåòàõ òà âñüîìó ñòåêó âèêëèê³â
-- ÿêùî ëîêàëüíó òèì÷àñîâó òàáëèöþ íå âèäàëèòè ÿâíî âîíà áóäå âèäàëåíà ï³ñëÿ çàâåðøåííÿ ð³âíÿ ÿêèé ¿¿ ñòâîðèâ;
-- ãëîáàëüí³ òèì÷àñîâ³ òàáëèö³ âèäí³ äëÿ âñ³õ ñåàíñ³â, âîíè âèäàëÿþòüñÿ ñåàíñîì ÿêèé ¿õ ñòâîðþâàâ ïðè óìîâ³
-- ùî íåìàº àêòèâíèõ ññèëîê íà íèõ;
-- òàáëè÷í³ çì³íí³ âèäí³ ò³ëüêè ïàêåòó ÿêèé ¿õ ñòâîðèâ ³ àâòîìàòè÷íî âèäàëÿþòüñÿ â ê³íö³ ïàêåòó
-- âîíè íå âèäèì³ ³íøèì ïàêåòàì à òàêîæ ñòåêó âèêëèê³â

-- íàñòóïíèé êîä ïîêàçóº ùî òèì÷àñîâ³ òàáëèö³ º âèäèì³ ³íøèì ïàêåòàì ³ ñòåêó âèêëèê³â
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

-- íàñòóïíèé êîä ïîêàçóº ùî òàáëè÷í³ çì³íí³ íå âèäèì³ í³äå êð³ì ñâîãî ïàêåòó
CREATE TABLE #T1
( col1 INT NOT NULL );
INSERT INTO #T1(col1) VALUES(10);
EXEC('SELECT col1 FROM #T1;');
GO
SELECT col1 FROM #T1;
GO
DROP TABLE #T1;
GO

-- òèì÷àñîâ³ òàáëèö³ ñòâîðþþòüñÿ â áàç³ tempdb ³ ÿê âæå çàçíà÷àëîñü ìîæíà ñòâîðèòè äåê³ëüêà
-- òàáëèöü ç îäíàêîâèìè ³ìåíàìè â ð³çíèõ ñåàíñàõ îñê³ëüêè ñåðâåð äîäàº ñóô³êñ äî ³ìåí³; 
-- ïðîòå ÿêùî ñòâîðèòè òèì÷àñîâ³ òàáëèö³ â ð³çíèõ ñåàíñàõ ç îäíàêîìèì ³ìåíåì îáìåæåííÿ òî áóäå
-- ñòâîðåíà ò³ëüêè îäíà òàáëèöÿ, à ³íøà ñïðîáà áóäå çàâåðøåíà ïîìèëêîþ;

-- ÿêùî ñòâîðþâàòè íàñòóïíó òàáëèöþ â ð³çíèõ ñåàíñàõ òî ïåðøà ñïðîáà áóäå óñï³øíà à íàñòóïí³
-- çàâåðøàòüñÿ ç ïîìèëêîþ
CREATE TABLE #T1
(
	col1     INT NOT NULL,
	col2     INT NOT NULL,
	col3     DATE NOT NULL,
	CONSTRAINT PK_#T1 PRIMARY KEY(col1)
);

-- îäíèì ç âèð³øåíü ïðîáëåìè - íå ïðèñâîþâàòè ³ìåí äëÿ îáìåæåíü â òèì÷àñîâèõ òàáëèöÿõ
CREATE TABLE #T1
(
	col1     INT NOT NULL,
	col2     INT NOT NULL,
	col3     DATE NOT NULL,
	PRIMARY KEY(col1)
);

-- â sql server ìîæíà ñòâîðþâàòè îáìåæåííÿ íà òèì÷àñîâèõ òàáëèöÿõ ï³ñëÿ ñòâîðåííÿ òàáëèö³
CREATE UNIQUE NONCLUSTERED INDEX idx_col2 ON #T1(col2);

CREATE NONCLUSTERED INDEX idx_col2 ON #T1(col2);

-- äëÿ òàáëè÷íèõ çì³ííèõ íå äîçâîëÿºòüñÿ ïðèñâîºííÿ ³ìåí äëÿ îáìåæåíü íàâ³òü â îäíîìó ñåàíñ³
-- íàñòóïíà ñïðîáà çàâåðøèòüñÿ ïîìèëêîþ
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            CONSTRAINT PK_@T1 PRIMARY KEY(col1)
        );
        
-- à öÿ ñïðîáà çàâåðøèòüñÿ óñï³øíî
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            PRIMARY KEY(col1)
        ); 
        
-- íå ìîæíà äîäàâàòè îáìåæåííÿ äî ³ñíóþ÷î¿ òàáëè÷íî¿ çì³ííî¿        
-- íàãàäàºìî ùî ïðè ñòâîðåíí³ ïåðâèííîãî êëþ÷à äëÿ éîãî óí³êàëüíîñò³ ñåðâåð ñòâîðþº íà ñòîâïö³ êëàñòåðèçîâàíèé
-- ³íäåêñ, à ïðè ñòâîðåíí³ îáìåæåííÿ óí³êàëüíîñò³ äîäàºòüñÿ íåêëàñòåðèçîâàíèé ³íäåêñ, òîìó ÿêùî ïîòð³áíî
-- îáÿâèòè ³íäåêñ íà òàáëè÷í³é çì³íí³é öå ìîæíà çðîáèòè â îáõ³ä
DECLARE @T1 AS TABLE
        (
            col1 INT NOT NULL,
            col2 INT NOT NULL,
            col3 DATE NOT NULL,
            PRIMARY KEY(col1)
        );
        
-- òèì÷àñîâ³ òàáëèö³ à òàêîæ òàáëè÷í³ çì³íí³ ìàþòü ïðåäñòàâëåííÿ â áàç³ äàíèõ tempdb
-- òàáëè÷í³ âèðàçè CTE ô³çè÷íîãî ïðåäñòàâëåííÿ íå ìàþòü

-- òðàíçàêö³¿ ïðàöþþòü ç òèì÷àñîâèìè òàáëèöÿìè ïðàêòè÷íî òàê ñàìî ÿê ç³ çâè÷àéíèìè
-- íàïðèêëàä â íàñòóïíîìó çàïèò³ çì³íè äî òèì÷àñîâî¿ òàáëèö³ áóäóòü â³äì³íåí³ 
-- â³äêàòîì òðàíçàêö³¿
CREATE TABLE #T1
( col1 INT NOT NULL );
BEGIN TRAN
	INSERT INTO #T1(col1) VALUES(10);
ROLLBACK TRAN
SELECT col1 FROM #T1;
DROP TABLE #T1;
GO             

-- çì³íè çàñòîñîâàí³ äî òàáëè÷íèõ çì³ííèõ â òðàíçàêö³¿ íå â³äì³íÿþòüñÿ
DECLARE @T1 AS TABLE
( col1 INT NOT NULL );
BEGIN TRAN
	INSERT INTO @T1(col1) VALUES(10);
ROLLBACK TRAN
SELECT col1 FROM @T1;

/*******************************************
 * Ñòàòèñòèêà
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

-- âèòÿãíåìî äàí³ ç òàáëèö³
SELECT t.col1,t.col2,t.col3
FROM #T1 AS t
WHERE t.col2 <= 5

-- íà öåé ðàç âèêîíàºìî ïîïåðåäí³é çàïèò äî òàáëè÷íî¿ çì³ííî¿
-- â äàíîìó âèïàäêó ïëàí áóäå íå òàêèé åôåêòèâíèé
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

-- ìîæíà çðîáèòè íàñòóïíèé âèñíîâîê : òàáëè÷í³ çì³íí³ äîáðå âèêîðèñòîâóâàòè â äâîõ âèïàäêàõ 
-- 1) êîëè ê³ëüê³ñòü äàíèõ ìàëà ³ ïëàí âèêîíàííÿ çàïèòó íå ìàº çíà÷åííÿ
-- 2) êîëè ïëàí äóæå ïðîñòèé, ùî îçíà÷àº ùî ³ñíóº ò³ëüêè îäèí ðîçóìíèé ïëàí ³ îïòèì³çàòîðó íå ïîòð³áí³
--    ã³ñòîãðàìè äëÿ ïðèéíÿòòÿ ð³øåííÿ

-- ÏÐÀÊÒÈÊÓÌ
-- òðåáà ïîâåðíóòè ê³ëüê³ñòü çàìîâëåíü çà ð³ê ³ ð³çíèöþ ì³æ ïîòî÷íèì ³ ïîïåðåäí³ì ðîêîì
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

-- îñê³ëüêè òàáëè÷íèé âèðàç áóäå ïðîãëÿíóòèé äâà ðàçè ìîæíà âèêîðèñòàòè íàïðèêëàä òàáëè÷íó çì³ííó
-- â äàíîìó âèïàäêó ðîáîòà ïî ïåðåãëÿäó, ãðóïóâàííþ ³ ñòàòè÷í³ îáðîáö³ äàíèõ âèêîíàíà ò³ëüêè îäèí
-- ðàç ³ ðåçóëüòàò çáåðåæåíî â òèì÷àñîâó òàáëèöþ òîìó çàïèò º åôåêòèâí³øèì
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
 * ÒÐÀÍÇÀÊÖ²¯
 *******************************************/
-- Òðàíçàêö³ÿ - öå ëîã³÷íà îäèíèöÿ ðîáîòè. 
-- Âñ³ çì³íè â áàç³ â³äáóâàþòüñÿ çà äîïîìîãîþ òðàíçàêö³é, ³íøèìè ñëîâàìè
-- âñ³ îïåðàö³¿ ÿê³ âíîñÿòü çì³íè â áàçó ñïðèéìàþòüñÿ sql server ÿê òðàíçàêö³¿
-- 1) âñ³ ³íñòðóêö³¿ ìîâè îïèñó äàíèõ DDL (CREATE TABLE,CREATE INDEX)
-- 2) âñ³ ³íñòðóêö³¿ îáðîáêè äàíèõ DML (insert,update,delete)
-- ACID (atomicity,consistency,isolation,durability)
-- atomicity - êîæíà òðàíçàêö³ÿ º àòîìàðíîþ îäèíèöåþ ðîáîòè, òîáòî àáî âèêîíóºòüñÿ âñå àáî í³÷îãî
-- consistency - êîæíà òðàíçàêö³ÿ ÿêà º çàâåðøåíà àáî ïåðåðâàíà çàëèøàº áàçó â ñîãëàñîâàííîì ñîñòîÿíèè, ïðè
-- íåñîãëàñîâàíîñòè ñåðâåð çðîáèòü â³äêàò òðàíçàêö³¿
-- isolation - êîæíà òðàíçàêö³ÿ âèêîíóºòüñÿ òàê í³áè âîíà ³ñíóº â ³çîëÿö³¿ ïî â³äíîøåííþ äî âñ³õ ³íøèõ òðàíçàêö³é
-- ÿêùî äâîì òðàíçàêö³ÿì òðåáà çì³íèòè îäí³ ³ ò³æ äàí³ îäíà ç íèõ ïîâèííà ïî÷åêàòè ïîêè çàâåðøèòüñÿ ³íøà
-- durability - êîæíà òðàíçàêö³ÿ ïîòåðïàº â³ä ïåðåðèâàííÿ ñåðâ³ñó. Êîëè ñåðâ³ñ â³äíîâëþºòüñÿ âñ³ çàâåðøåí³ 
-- òðàíçàêö³¿ êîì³òÿòüñÿ, âñ³ íåçàâåðøåí³ â³äêî÷óþòüñÿ

-- ³çîëÿö³ÿ òðàíçàêö³é çàáåçïå÷óºòüñÿ çà äîïîìîãîþ ìåõàí³çì³â áëîêóâàííÿ ³ âåðñ³éíîñò³ ñòðîê
-- sql server áëîêóº îá'ºêòè (ñòðîêè ³ òàáëèö³) äëÿ òîãî ùîá çàïîá³ãòè âì³øóâàííþ ³íøèõ òðàíçàêö³é 
-- â ä³¿ äàíî¿ òðàíçàêö³¿
-- âàæëèâî ï³äòðèìóâàòè ÿê³ñòü òðàíçàêö³é ÿê³ â³äïîâ³äàþòü ACID, äëÿ òîãî ùîá ãàðàíòóâàòè ùî ö³ë³ñí³ñòü äàíèõ
-- â áàç³ íå áóäå ïîðóøåíî
-- ñò³éê³ñòü òðàíçàêö³é äîñÿãàºòüñÿ çà äîïîìîãîþ òîãî ùî ñåðâåð çàïèñóº âñ³ òðàíçàêö³¿ â æóðíàë

-- àêòèâí³ òðàíçàêö³¿
SELECT * FROM sys.dm_tran_active_transactions AS dtat

-- ð³âåíü òðàíçàêö³¿ ³ ¿¿ ñòàí ìîæíà âèçíà÷èòè çà äîïîìîãîþ äâîõ ñèñòåìíèõ ôóíêö³é
-- @@TRANCOUNT - äîçâîëÿº ä³çíàòèñü ð³âåíü âêëàäåííÿ òðàíçàêö³¿
-- XACT_STATE() - äîçâîëÿº âèçíà÷èòè ñòàí òðàíçàêö³¿

-- ðåæèìè òðàíçàêö³¿
-- autocommit (DDL/DML)
-- implicit transaction (íåÿâíà)
-- explicit transaction (ÿâíà)

-- ROLLBACK çàâæäè ðîáèòü â³äêàò âñ³º¿ òðàíçàêö³¿ íå çàëåæíî â³ä òîãî ñê³ëüêè º ð³âíåé
-- âêëàäåíîñò³ òðàíçàêö³¿ ³ íà ÿêîìó ð³âí³ âèêëèêàíà öÿ êîìàíäà

-- äëÿ òîãî ùîá ãàðàíòóâàòè ô³êñàö³þ âñ³º¿ òðàíçàêö³¿ âö³ëîìó ïîòð³áíî âèêîíàòè ïî îäí³é
-- ³íñòðóêö³¿ COMMIT íà êîæåí ð³âåíü òðàíçàêö³¿, ïðè ÷îìó ò³ëüêè îñòàííÿ êîìàíäà COMMIT ä³éñíî
-- ô³êñóº âñþ òðàíçàêö³þ

USE TSQLFundamentals2008
GO

BEGIN TRAN MyFirstTranInLife

ROLLBACK

-- ùîá çáåðåãòè ³çîëÿö³þ òðàíçàêö³é sql server ðåàë³çóº íàá³ð ïðîòîêîë³â áëîêóâàííÿ
-- íà áàçîâîìó ð³âí³ ³ñíóº äâà îñíîâí³ :
-- 1) shared locks (ñîâìåùàåìèå) âèêîðèñòîâóþòüñÿ äëÿ ñåàíñ³â ÿê³ çä³éñíþþòü ÷èòàííÿ äàíèõ 
-- 2) exclusive locks (ìîíîïîëüí³) âèêîðèñòîâóþòüñÿ äëÿ ìîäèô³êàö³¿ äàíèõ, òîáòî îïåðàö³é çàïèñó

-- ìîíîïîëüíà áëîêèðîâêà çàâæäè âèíèêàº â âèïàäêó òðàíçàêö³¿ íàâ³òü ÿêùî öå àâòîìàòè÷íà òðàíçàêö³ÿ
-- êîëè íà ñåàíñ³ º ìîíîïîëüíå áëîêóâàííÿ íà ñòðîö³, òàáëèö³ àáî ³íøîìó îá'ºêò³ í³ÿêà ³íøà òðàíçàêö³ÿ 
-- íå ìîæå çì³íèòè äàí³, ïîêè ïîòî÷íà òðàíçàêö³ÿ íå áóäå çàêîì³÷åíà àáî â³äêî÷åíà
-- çà âèêëþ÷åííÿì îñîáëèâèõ áëîêóâàíü ³íø³ ñåàíñè íå ìîæóòü íàâ³òü ÷èòàòè çàáëîêîâàí³ â ìîíîïîëüíîìó
-- ðåæèì³ îá'ºêòè

-- ñóì³ñí³ñòü áëîêóâàíü
-- ÿêùî ñåàíñ âèêîíóº ò³ëüêè ÷èòàííÿ äàíèõ ïî çàìîâ÷óâàííþ sql server çàïóñêàº ò³ëüêè äóæå êîðîòê³ 
-- shared áëîêóâàííÿ íà îá'ºêò³; äâà ³ á³ëüøå ñåàíñ³â ìîæóòü ÷èòàòè îäí³ ³ ò³ æ äàí³
-- àëå ÿêùî ñåàíñ ìàº ðåñóðñ ç ìîíîïîëüíîþ áëîêèðîâêîþ, ³íø³ ñåàíñè íå ìîæóòü âèêîíóâàòè ÷èòàííÿ
-- àáî ìîäèô³êàö³þ öüîãî ðåñóðñó

-- Áëîêóâàííÿ
-- áëîêóâàííÿ âèíèêàº ó âèïàäêó êîëè îäèí ñåàíñ âèêîíóº ìîíîïîëüíå áëîêóâàííÿ ðåñóðñó íå äîçâîëÿþ÷è
-- ³íøîìó ñåàíñó í³ÿêèì ÷èíîì îòðèìàòè ìîæëèâ³ñòü áëîêóâàííÿ öüîãî ðåñóðñó
-- â òðàíçàêö³¿ ìîíîïîëüí³ áëîêóâàííÿ âòðèìóþòüñÿ äî ê³íöÿ òðàíçàêö³¿ òîìó ÿêùî ïåðøèé ñåàíñ âèêîíóº
-- òðàíçàêö³þ, äðóãèé ïîâèíåí ÷åêàòè äîêè ïåðøèé íå çàêîì³òèòü àáî íå â³äêîòèòü òðàíçàêö³þ

-- ìîíîïîëüíå áëîêóâàííÿ òàêîæ ìîæå áëîêóâàòè çàïèò íà ÷èòàííÿ ÿêùî ìîäóëü ÷èòàííÿ çàïðîøóº shared 
-- áëîêóâàííÿ, òîìó ùî ìîíîïîëüíå áëîêóâàííÿ íåñóì³ñíå òàêîæ ³ ç shared áëîêóâàííÿì

-- ìîäóë³ ÷èòàííÿ (share block) íå ìîæóòü áëîêóâàòè ³íø³ ìîäóë³ ÷èòàííÿ îñê³ëüêè âîíè ñóì³ñí³ ì³æ ñîáîþ
-- ìîäóë³ ÷èòàííÿ ìîæóòü ïðîòå áëîêóâàòè ìîäóë³ çàïèñó, îñê³ëüêè áóäü ÿêèé ìîäóëü ÷èòàííÿ ïîâèíåí ÷åêàòè
-- ïîêè shared áëîêóâàííÿ íå áóäå çâ³ëüíåíèì

-- äâ³ òðàíçàêö³¿ ÿê³ âèêîíóþòü îäí³ ³ ò³ æ ä³¿ â ïðîòèëåæí³é ïîñë³äîâíîñò³ ïðèâîäÿòü äî âçàºìîáëîêóâàííÿ
-- äâ³ òðàíçàêö³¿ ÿê³ âèêîíóþòü îäí³ ³ ò³ æ ä³¿ â îäíàêîâ³é ïîñë³äîâíîñò³ íå âèêëèêàþòü âçàºìîáëîêóâàííÿ

-- ³íñòðóêö³ÿ select òàêîæ ìîæå áðàòè ó÷àñòü â âçàºìîáëîêóâàíí³ : ÿêùî select áëîêóº ðåñóðñ íå äîçâîëÿþ÷è
-- çàâåðøèòèñü ³íø³é òðàíçàêö³¿, à ñàìà ³íñòðóêö³ÿ select íå ìîæå çàâåðøèòèñü òàê ÿê âîíà çàáëîêîâàíà 
-- ÿêîþñü òðàíçàêö³ºþ òî âèíèêàº öèêë âçàºìîáëîêóâàííÿ

-- áëîêóâàííÿ àáî âçàºìîáëîêóâàííÿ ìîæíà çá³ëüøèòè àáî çìåíøèòè ìåòîäîç çì³íè ñòåïåí³ ³çîëüîâàíîñò³ 
-- ACID - âëàñòèâîñòåé òðàíçàêö³¿; sql server äîçâîëÿº îäí³é òðàíçàêö³¿ ÷èòàòè äàí³ ³íøî¿ àáî âèêîíóâàòè
-- çì³íó äàíèõ ³íøèìè òðàíçàêö³ÿìè êîëè äàíà òðàíçàêö³ÿ âèêîíóº ÷èòàííÿ äàíèõ çà äîïîìîãîþ íàëàøòóâàííÿ
-- ð³âíÿ ³çîëÿö³¿ òðàíçàêö³é
-- äî íàéá³ëüø ÷àñòî âèêîðèñòîâóâàâíèõ ð³âí³â òðàíçàêö³é â³äíîñÿòüñÿ íàñòóïí³ :
-- 1) read committed - öå ð³âåíü ³çîëÿö³¿ ïî çàìîâ÷óâàííþ; âñ³ ìîäóë³ ÷èòàííÿ äàíèõ áóäóòü âèêîíóâàòè
--    ÷èòàííÿ ò³ëüêè òèõ çì³íåíèõ äàíèõ ÿê³ áóëè çàô³êñîâàí³; âñ³ select ³íñòðóêö³¿ áóäóòü íàìàãàòèñü
--    îòðèìàòè shared áëîêóâàííÿ ³ áóäü ÿê³ áàçîâ³ ðåñóðñè ÿê³ çì³íþþòüñÿ ³ ìàþòü ìîíîïîëüí³ áëîê³ðîâêè
--	  áóäóòü áëîêóâàòè ñåàíñ read committed
-- 1.1) read committed snapshot - öå íå íîâèé ð³âåíü, à äîäàòêîâèé ñïîñ³á âèêîðèñòàííÿ read committed;
--		1. ÷àñòî éîãî íàçèâàþòü RSCI; â³í âèêîðèñòîâóº áàçó tempdb äëÿ çáåðåæåííÿ ïî÷àòêîâèõ âåðñ³é
--		   çì³íåíèõ äàíèõ; ö³ âåðñ³¿ çáåð³ãàþòüñÿ ñò³ëüêè ñê³ëüêè íåîáõ³äíî, ùîá äîçâîëèòè ìîäóëÿì
--		   ÷èòàííÿ áàçîâ³ äàí³ â ¿õ ïî÷àòêîâîìó ñòàí³; â ðåçóëüòàò³ ³íñòðóêö³ÿì select á³ëüøå íå ïîòð³áí³
--		   shared áëîêóâàííÿ íà ðåñóðñ³ äëÿ âèêîíàííÿ ÷èòàíí³ çàô³êñîâàíèõ äàíèõ;
--		2. íàëàøòóâàííÿ read committed snapshot âèêîíóºòüñÿ íà ð³âí³ áàçè äàíèõ ³ º ïîñò³éíîþ ïðîïåðòüîþ áàçè
--		3. RSCI - öå íå îêðåìèé ð³âåíü ³çîëÿö³¿; öå ïðîñòî ³íøèé ìåòîä ðåàë³çàö³¿ READ COMMITTED, ÿêèé çàïîá³ãàº
--		   áëîêóâàííþ ìîäóë³â ÷èòàííÿ ìîäóëÿìè çàïèñó;
-- 2) read uncommitted - öåé ð³âåíü ³çîëÿö³¿ äîçâîëÿº ÷èòàòè íåçàô³êñîâàí³ äàí³; öå íàëàøòóâàííÿ âèäàëÿº
--    shared áëîêóâàííÿ ÿê³ îòðèìàí³ ³íñòðóêö³ÿìè select òàê ùî ìîäóë³ ÷èòàííÿ á³ëüøå íå áëîêóþòüñÿ
--    ìîäóëÿìè çàïèñó; öå íàçèâàºòüñÿ "dirty read"
-- 3) repeatable read - öåé ð³âåíü ³çîëÿö³¿ ãàðàíòóº ùî äàí³ ïðî÷èòàí³ â òðàíçàêö³¿ ìîæóòü äàë³ áóòè çíîâó
--    ïðî÷èòàí³ â òðàíçàêö³¿; íå äîïóñêàþòüñÿ îïåðàö³¿ âèäàëåííÿ àáî ìîäèô³êàö³¿ ïðî÷èòàíèõ ñòðîê â ³íøèõ ñåñ³ÿõ;
--	  â ðåçóëüòàò³ shared áëîêóâàííÿ óòðèìóþòüñÿ äî ê³íöÿ òðàíçàêö³¿; ïðîòå òðàíçàêö³ÿ ìîæå áà÷èòè íîâ³ ñòðîêè
--	  äîäàí³ ï³ñëÿ ïåðøî¿ îïåðàö³¿ ÷èòàííÿ; öå íàçèâàºòüñÿ ôàíòîìíèì ÷èòàííÿì (update lost problem óñóâàºòüñÿ)
-- 4) snapshot - öåé ð³âåíü âèêîðèñòîâóº óïðàâë³ííÿ âåðñ³ÿìè ñòðîê â áàç³ tempdb (ÿê RSCI); â³í äîçâîëåíèé ÿê
--    ïîñò³éíà ïðîïåðòÿ áàçè òîìó âñòàíîâëþºòüñÿ íà îêðåìó òðàíçàêö³þ; òðàíçàêö³ÿ ÿêà âèêîðèñòîâóº öåé ð³âåíü
--    ìîæå ïîâòîðèòè áóäü ÿêó îïåðàö³þ ÷èòàííÿ (repeatable read), ³ íå áóäå áà÷èòè í³ÿêèõ ôàíòîìíèõ ÷èòàíü;
--    îñê³ëüêè snapshot óïðàâëÿº âåðñ³ÿìè ñòðîê òî íå âèìàãàºòüñÿ í³ÿêèõ shared áëîêóâàíü íà áàçîâèõ äàíèõ
-- 5) serializable - öåé ð³âåíü º íàéá³ëüø ñòðîãèì ³ âñòàíîâëþºòüñÿ íà ñåàíñ; íà öüîìó ð³âí³ âñ³ îïåðàö³¿ º
--    repeatable ³ íîâ³ ñòðîêè, ÿê³ çàäîâ³ëüíÿþòü óìîâó â select òðàíçàêö³¿ íå ìîæóòü áóòè äîäàí³ â òàáëèöþ

-- Repeatable read prevents only non-repeatable read. Repeatable isolation level ensures that the data that one 
-- transaction has read, will be prevented from beeing updated or deleted by any other transaction, but it do
-- not prevent new rows from beeing inserted by other transaction resulting in phantom read concurency problem.

-- Serializable prevents both non-repeatable read and phantom read problems. Serializable isolation level ensures
-- that the data that one transaction has read, will be prevented from beeing updated or deleted by any other 
-- transaction. Is also prevents new rows from beeing inserted by other transactions, so this isolation level 
-- prevents both non-repeatable read and phantom read problems.

-- ð³âí³ ³çîëÿö³¿ âñòàíîâëþþòüñÿ íà ñåàíñ; ÿêùî í³ÿê³ ð³âí³ ³çîëÿö³¿ íå âñòàíîâëþâàëèñü íà ñåàíñ âñ³ òðàíçàêö³¿
-- áóäóòü âèêîíóâàòèñü çà äîïîìîãîþ ð³âíÿ ïî çàìîâ÷óâàííþ (read committed); 

-- ÿêùî ñåàíñ âèêîðèñòîâóº ð³âåíü ³çîëÿö³¿ READ COMMITTED çàïèòè âñå îäíî ìîæóòü îòðèìàòè çìîãó ÷èòàòè íåçàô³êñîâàí³
-- äàí³ âèêîðèñòîâóþ÷è òàê³ õ³íòè ÿê WITH (NOLOCK) àáî WITH (READUNCOMMITTED); çíà÷åííÿ ð³âíÿ ³çîëÿö³¿ äëÿ ñåàíñó íå
-- çì³íþºòüñÿ çì³íþþòüñÿ ò³ëüêè õàðàêòåðèñòèêè ÷èòàííÿ òàáëèö³;

-- ÿê áóëî ñêàçàíî, äëÿ òîãî ùîá çàïîá³ãòè áëîêóâàííþ ìîäóë³â çàïèñó ìîäóëÿìè ÷èòàííÿ ³ ïðè öüîìó ãàðàíòóâàòè ùî ìîäóë³
-- ÷èòàííÿ áà÷àòü ò³ëüêè çàô³êñîâàí³ äàí³ ïîòð³áíî âèêîðèñòîâóâàòè ïàðàìåòð (RSCI) íà ð³âí³ READ COMMITTED; ìîäóë³ ÷èòàííÿ
-- áà÷àòü á³ëüø ðàíí³ âåðñ³¿ çì³íåíèõ äàíèõ äëÿ ïîòî÷íèõ òðàíçàêö³é, àëå íå íåçàô³êñîâàí³ â äàíèé ìîìåíò äàí³

-- Loging deadlocks
-- ïåðåâ³êà ôëàæêà
DBCC TRACESTATUS (1222)

-- âêëþ÷èìî ëîãóâàííÿ
DBCC TRACEON (1222,-1)

-- âèêëþ÷èòè
DBCC TRACEOFF (1222,-1)

-- ïðî÷èòàòè ëîãóâàííÿ
EXEC sp_readerrorlog

/*******************************************
 * Îáðîáêà ïîìèëîê
 *******************************************/
-- êîëè ñåðâåð çãåíåðóº ïîìèëêó ñèñòåìíà ôóíêö³ÿ @@ERROR áóäå ì³ñòèòè äîäàòíº ö³ëå çíà÷åííÿ íîìåðó ïîìèëêè
-- ÿêùî íåìàº try/catch ïîâ³äîìëåííÿ ïðî ïîìèëêó áóäå ïåðåäàíî êë³ºíòó ³ íå ìîæå áóòè ïåðåõîïëåíî â êîä³ SQL
-- êð³ì òîãî ìîæíà ³í³ö³þâàòè ïîìèëêó çà äîïîìîãîþ êîìàíä
-- raiseerror (sql server < 2012)
-- throw (sql server >= 2012)
-- try/catch áëîê íå ìîæå áóòè âèêîðèñòàíèé â ôóíêö³ÿõ

DECLARE @message VARCHAR(100) = 'Error in %s stored procedure'
SELECT @message = FORMATMESSAGE(@message,'MY')
--RAISERROR(@message,16,0)
;THROW 50000,@message,0

-- äóæå âàæëèâîþ â³äì³íí³ñòþ ì³æ öèìè êîìàíäàìè º òå ùî RAISEERROR íå çàâåðøóº ðîáîòó ïàêåòà, à THROW çàâåðøóº
RAISERROR ('The error',16,0)
PRINT 'raise error'

throw 50000,'The error',0
PRINT 'throw error'

-- TRY_CONVERT i TRY_PARSE
-- TRY_CONVERT - íàìàãàºòüñÿ ïðèâåñòè çíà÷åííÿ äî çàäàíîãî òèïó àáî ïîâåðíå NULL
SELECT TRY_CONVERT(DATETIME,'1788-03-343')
SELECT TRY_CONVERT(DATETIME,'1990-01-01')

-- TRY_PARSE - ïðèéìàº äàí³ ç íåâ³äîìèì òèïîì ³ íàìàãàºòüñÿ ïåðåòâîðèòè ¿õ â êîíêðåòíèé òèï àáî ïîâåðíå NULL
SELECT TRY_PARSE('1' AS integer) 
SELECT TRY_PARSE('B' AS integer) -- ïðèòðèìóºòüñÿ ñèíòàêñèñó CAST/PARSE

-- äëÿ òîãî ùîá ñòâîðèòè ïîâ³äîìëåííÿ ïðî ïîìèëêó ìîæíà âèêîðèñòîâóâàòè òàêèé íàá³ð ôóíêö³é áëîêà catch:
-- 1. error_number - ïîâåðòàº íîìåð ïîìèëêè
-- 2. error_message - ïîâåðòàº ïîâ³äîìëåííÿ ïðî ïîìèëêó
-- 3. error_severity - ïîâåðòàº ð³âåíü ñåðéîçíîñò³ ïîìèëêè
-- 4. error_line - ïîâåðòàº íîìåð ñòðîêè â ïàêåò³ äå â³äáóëàñü ïîìèëêà
-- 5. error_procedure - ³ìÿ ôóíêö³¿, ñòîðêè, òðèãåðà ÿê³ âèêîíóâàëèñü â ìîìåíò åðîðó
-- 6. error_state - ñòàí ïîìèëêè

BEGIN TRY
	RAISERROR('Hello try',16,0)
END TRY
BEGIN CATCH
	
		SELECT *
		from TSQLFundamentals2008.dbo.GetErrors()
	
END CATCH

-- Ïðàêòèêóì
-- 1. ðîáîòà ç íåñòðóêòóðîâàíèìè ïîìèëêàìè
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

-- 2. íåñòðóêòóðîâàíà îáðîáêà ïîìèëîê
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
	-- Âèäàëåííÿ äîäàíî¿ ñòðîêè
	DELETE FROM Production.Products WHERE productid = 101
	PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows'
	
 -- 3. îáðîáêà ïîìèëêè ñòðóêòóðîâàíî
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
	;throw;	-- ïðîêèäóº ïîìèëêó ÿêà âèíèêëà êë³ºíòó; æîäåí êîä íå ìîæå âèêîíóâàòèñü ï³ñëÿ ö³º¿ ³íñòðóêö³¿
END CATCH;

GO

SELECT * FROM TSQLFundamentals2008.Production.Products AS p

-- Ïðîöåäóðè
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
 * ÒÐÈÃÅÐÈ
 *******************************************/
-- sql server ï³äòðèìóº òðèãåðè ç äâîìà òèïàìè ïîä³é
-- 1. ïîä³ÿ îáðîáêè äàíèõ (òðèãåðè DML)
-- 2. ïîä³ÿ îïèñó äàíèõ (DDL), òàê³ ÿê CREATE TABLE

-- DML òðèãåðè
-- 1. AFTER - ñïðàöüîâóº ò³ëüêè òîä³ êîëè ïîä³ÿ ÿêà ç íèì çâÿçàíà çàâåðøóºòüñÿ ³ ìîæå áóòè âèêîðèñòàíèé ò³ëüêè
-- äëÿ ïîñò³éíèõ òàáëèöü
-- 2. INSTEAD OF - öåé òðèãåð ñïðàöüîâóº çàì³ñòü ïîä³¿ ç ÿêèì â³í çâÿçàíèé ³ ìîæå áóòè ñòâîðåíèé äëÿ ïîñò³éíèõ
-- òàáëèöü ³ âþøîê
-- ö³ äâà òèïè òðèãåð³â âèêîíóþòüñÿ ÿê ÷àñòèíà òðàíçàêö³¿ çâÿçàíî¿ ç ³íñòðóêö³ºþ insert,update,delete
-- çàïóñê êîìàíäè rollback tran â êîä³ òðèãåðà ðîáèòü â³äêàò âñ³õ çì³í ÿê³ â³äáóâàëèñü â òðèãåð³ à òàêîæ â³äêàò
-- ³íñòðóêö³¿ DML ç ÿêîþ çâÿçàíèé òðèãåð; àëå âèêîðèñòàííÿ rollback ìîæå ìàòè ïîá³÷í³ åôåêòè; çàì³ñòü ö³º¿ êîìàíäè
-- ìîæíà âèêîíàòè êîìàíäó throw / raiserror ³ êîíòðîëþâàòè çá³é ÷åðåç ñòàíäàðòí³ ïðîöåäóðè îáðîáêè ïîìèëîê
-- íîðìàëüíèì âèõîäîì ç òðèãåðà º ³íñòðóêö³ÿ RETURN ÿê ³ â ñòîð ïðîöåäóð³

-- AFTER - êîä öüîãî òðèãåðà âèêîíóºòüñÿ òîä³ êîëè ³íñòðóêö³ÿ DML ïðîéøëà âñ³ îáìåæåííÿ, òàê³ ÿê primary/foreign key
-- ÿêùî îáìåæåííÿ íå ïðîéäåíî ³íñòðóêö³ÿ âèäàº ïîìèëêó ³ òðèãåð íå âèêîíóºòüñÿ			

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

-- inserted,deleted ì³ñòÿòü äóáë³êàòè òàáëèöü òðèãåðà; update àíàëîã³÷íèé äî âèäàëåííÿ ç âñòàâêîþ
-- ñïî÷àòêó ñòàð³ ñòðîêè êîï³þþòüñÿ â deleted, à ïîò³ì íîâ³ ñòðîêè äîäàþòüñÿ â òàáëèöþ òðèãåðà ³ òàáëèöþ inserted
UPDATE Production.Categories
SET categoryname = 'Beverages'
WHERE categoryname = 'Testcat1'	

DELETE FROM Production.Categories WHERE categoryid = 13

-- ñòâîðèìî after òðèãåð ÿêèé â³äîáðàæàº ³íôîðìàö³þ ïðî âèäàëåí³ òà äîäàí³ ñòðîêè
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

-- ïðè äîäàâàííÿ ñòðîê áóäå âèâåäåíà ê³ëüê³ñòü äîäàíèõ ÷åðåç òðèãåð
INSERT INTO sales.OrderDetails(orderid,productid,unitprice,qty,discount)
VALUES(10249,16,9.00,1,0.6),
	  (10249,15,9.00,1,0.4)

-- îíîâèìî îäíó ç ñòðîê ³ ïîáà÷èìî îäíó ñòðîêó ñåðåä âèäàëåíèõ ³ îäíó ñåðåä âñòàâëåíèõ
UPDATE Sales.OrderDetails
SET unitprice = 99.0
WHERE orderid = 10249 AND productid = 16	  

-- âèäàëèìî äâ³ ñòðîêè ³ ïîáà÷èìî ¿õ ñåðåä âèäàëåíèõ àëå íå ñåðåä äîäàíèõ
DELETE FROM Sales.OrderDetails
WHERE orderid = 10249 AND productid IN (15,16)

-- íàïèøåìî òðèãåð äëÿ ðåàë³çàö³¿ ëîã³êè : áóäü ÿêèé åëåìåíò ç òàáëèö³ Sales.OrderDetails â ÿêîãî unitprice < 10
-- íå ìîæå ìàòè çíèæêó á³ëüøå 0.5 
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

-- â ïðîòèëåæíîìó ïîðÿäêó òðèãåð íå ñïðàöüîâóº
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40),
	   (10249, 16, 9.00, 1, 0.60);

-- àëå ñïðàöþº ïðè òàêîìó âàð³àíò³ ÿê äâ³ íåçàëåæí³ âñòàâêè äàíèõ
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40)

INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 16, 9.00, 1, 0.60);	

-- îíîâèìî òðèãåð	   
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

-- ïîïðîáóºìî çíîâó âñòàâêó, ÿê áà÷èìî òåïåð äàí³ íå áóäóòü äîäàí³ â òàáëèöþ
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 16, 9.00, 1, 0.60),
	   (10249, 15, 9.00, 1, 0.40);	
	    
INSERT INTO Sales.OrderDetails (orderid, productid, unitprice,qty, discount)
VALUES (10249, 15, 9.00, 1, 0.40),
	   (10249, 16, 9.00, 1, 0.60);	
	   
	   
	   
-- INSTEAD OF - íàé÷àñò³øå âèêîðèñòîâóºòüñÿ ç view äëÿ òîãî ùîá àïäåéòíóòè òàáëèö³ ÿê³ ïîâÿçàí³ ç view
-- ñòâîðèìî view ÿêà ïîâåðòàº çàìîâëåííÿ
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
-- âèòÿãíóòè ³íôîðìàö³þ ïðî âñ³ ï³äêëþ÷åííÿ
SELECT des1.is_user_process,des1.original_login_name, * 
FROM sys.dm_exec_sessions AS des1

-- ñòâîðèìî òðèãåð ÿêèé áëîêóº ï³äêëþ÷åííÿ êîðèñòóâà÷à á³ëüøå í³æ 3 ñåñ³¿
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
		PRINT 'Fourth connection attempt by ' + @LoginName + ' blocked'; -- ïèøå ïîâ³äîìëåííÿ â ëîãè 
		ROLLBACK;
	END															
END

-- ïðî÷èòàºìî ³íôîðìàö³þ ç ëîã³â
EXEC sp_readerrorlog


/*******************************************
 * INDEXES
 *******************************************/
-- sql server îðãàí³çîâóº òàáëèö³ â êó÷³ àáî çáàëàíñîâàí³ äåðåâà
-- òàáëèöÿ, ÿêà îðãàí³çîâàíà â âèãëÿä³ çáàëàíñîâàíîãî äåðåâà íàçèâàºòüñÿ êëàñòåðèçîâàíîþ òàáëèöåþ àáî
-- êëàñòåðèçîâàíèì ³íäåêñîì
-- êó÷à - öå íàá³ð ñòîð³íîê ³ åêñòåíò³â, ÿêèé ñêëàäàºòüñÿ ç 8ìè ñòîð³íîê
-- ñòîð³íêà öå ìîäóëü ÿêèé çàéìàº 8êÁ
-- sql server â³äñë³äêîâóº ÿê³ ñòîð³íêè ³ åêñòåíòè íàëåæàòü îá'ºêòó çà äîïîìîãîþ ñèñòåìíèõ òàáëèöü
-- ÿê³ íàçèâàþòüñÿ ñòîð³íêàìè êàðòè ðîçïîä³ëó ³íäåêñà (Index allocation map, IAM); êîæíà òàáëèöÿ àáî ³íäåêñ
-- ìàº ïî êðàéí³é ì³ð³ îäíó ñòîð³íêó IAM, ÿêà íàçèâàºòüñÿ ïåðøîþ ñòîð³íêîþ IAM. Îäíà ñòîð³íêà IAM ìîæå 
-- âêàçóâàòè ïðèáëèçíî íà 4ÃÁ ïðîñòîðó; âåëèê³ îá'ºêòè ìîæóòü ìàòè á³ëüøå îäíî¿ ñòîð³íêè

-- ñòâîðèìî òàáëèöþ îðãàí³çîâàíó ó âèãëÿä³ êó÷³
USE TSQLFundamentals2008
GO

CREATE TABLE dbo.TestStructure
(
	id INT NOT NULL,
	filler1 CHAR(6) NOT NULL,
	filler2 CHAR(6) NOT NULL
)

-- çàãàëüíà ³íôîðìàö³ÿ ïðî òàáëèö³ ³ ³íäåêñè ìîæå áóòè ïðî÷èòàíà ç sys.indexes
USE TSQLFundamentals2008
SELECT OBJECT_NAME(i.[object_id]) AS table_name, i.name AS index_name,
	   i.[type], i.type_desc
FROM sys.indexes AS i
WHERE i.[object_id] = OBJECT_ID(N'dbo.TestStructure',N'U')

-- ìîæíà ä³çíàòèñü ñê³ëüêè ñòîð³íîê âèä³ëåíî ï³ä îá'ºêò íàñòóïíèì ÷èíîì
SELECT index_type_desc,index_depth,index_level,page_count,record_count,avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(N'TSQLFundamentals2008'),OBJECT_ID(N'dbo.TestStructure'),NULL,NULL,'DETAILED') AS ddips

EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure', @updateusage = TRUE

-- äîäàìî òåñòîâó ñòðîêó â òàáëèöþ 
INSERT INTO dbo.TestStructure(id,filler1,filler2)
VALUES(1,'a','b')

DECLARE @i INT = 0;
WHILE @i < 18000
BEGIN
	SET @i = @i + 1;
	INSERT INTO dbo.TestStructure(id,filler1,filler2)
	VALUES(@i,'a','b')
END

-- äîäàìî êëàñòåðèçîâàíèé ³íäåêñ íà ñòîâïö³
TRUNCATE TABLE TSQLFundamentals2008.dbo.TestStructure
CREATE CLUSTERED INDEX idx_cl_id ON TSQLFundamentals2008.dbo.TestStructure(id)
CREATE INDEX idx_TestStructure_f1 ON TSQLFundamentals2008.dbo.TestStructure(filler1)

ALTER TABLE TSQLFundamentals2008.dbo.TestStructure
ADD PRIMARY KEY (id)
-- âèäàëèìî ³íäåêñ
USE TSQLFundamentals2008
DROP INDEX dbo.TestStructure.idx_TestStructure_f1

-- äëÿ ïåðåãëÿäó âñ³õ ³íäåêñ³â òàáëèö³
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

 -- ñòâîðèìî òèï äàíèõ êîðèñòóâà÷à
 CREATE TYPE TestStructType AS TABLE
 (
 	Id INT PRIMARY KEY,
 	Fill1 CHAR(6),
 	Fill2 CHAR(6) 
 )
 
 -- ñòâîðèìî ïðîöåäóðó
 CREATE PROCEDURE dbo.spInsertOrder
  @TestStructTp dbo.TestStructType READONLY
 AS 
 BEGIN
 	INSERT INTO TSQLFundamentals2008.dbo.TestStructure(id,filler1,filler2)
 	SELECT tp.Id, tp.Fill1, tp.Fill2
 	FROM @TestStructTp AS tp
 END
 
 -- âèêëè÷åìî ïðîöåäóðó
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
