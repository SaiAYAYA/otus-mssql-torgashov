/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "12 - �������� ���������, �������, ��������, �������".

������� ����������� � �������������� ���� ������ WideWorldImporters.

*/

USE WideWorldImporters

/*
�� ���� �������� �������� �������� ��������� / ������� � ������������������ �� �������������.
*/

/*
1) �������� ������� ������������ ������� � ���������� ������ �������.
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MY_schema].[MaxSumSales] ()
RETURNS TABLE 
AS
RETURN 
(
	WITH MY_CTE (CustomerID,Sales)
	AS
	(SELECT t1.CustomerID,sum(t2.[ExtendedPrice])
	FROM [Sales].[Invoices] t1
	JOIN [Sales].[InvoiceLines] t2 on t1.InvoiceID=t2.InvoiceID
	GROUP BY CustomerID)
	SELECT top(1) CustomerID,Sales
	FROM MY_CTE
	ORDER BY Sales DESC
);
GO

SELECT CustomerID, Sales FROM [MY_schema].[MaxSumSales]();



/*
2) �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
������������ ������� :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
--CREATE SCHEMA  MY_schema;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [MY_schema].[Max_sales] @CustomerID int
AS
BEGIN
	IF @CustomerID in (SELECT DISTINCT CustomerID
						FROM [Sales].[Invoices])
	
	SELECT SUM(t2.[ExtendedPrice]) AS SUM_Sales
	FROM [Sales].[Invoices] t1
	JOIN [Sales].[InvoiceLines] t2 on t1.InvoiceID=t2.InvoiceID
	WHERE t1.CustomerID=@CustomerID
	ELSE
	SELECT 'The customer with the ID ' + CAST(@CustomerID as char(5)) + ' did not make purchases' as NOT_FOUND
    
END
GO

EXEC [MY_schema].[Max_sales] 5000

/*
3) ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
*/

--������� Id, ���� � ����� ������� �� ���������� ����������
CREATE FUNCTION [MY_schema].Func_OrdersSum (@CustomerID int)
RETURNS TABLE 
AS
RETURN 
	SELECT  
	t1.OrderID,
	t1.OrderDate,
	Sum(UnitPrice*Quantity) as OrdersSum
	FROM [Sales].[Orders] t1
	JOIN [Sales].[OrderLines] t2 on t1.OrderID=t2.OrderID
	WHERE  [CustomerID] = @CustomerID
	GROUP BY  t1.OrderID, t1.OrderDate
GO

GO

CREATE PROCEDURE [MY_schema].Proc_OrdersSum @CustomerID int
AS
BEGIN 
	SELECT  
	t1.OrderID,
	t1.OrderDate,
	Sum(UnitPrice*Quantity) as OrdersSum
	FROM [Sales].[Orders] t1
	JOIN [Sales].[OrderLines] t2 on t1.OrderID=t2.OrderID
	WHERE  [CustomerID] = @CustomerID
	GROUP BY  t1.OrderID, t1.OrderDate
END

GO

SET STATISTICS TIME ON

DECLARE @CustomerID int
SET @CustomerID=1053
EXEC [MY_schema].Proc_OrdersSum @CustomerID

select *
from [MY_schema].Func_OrdersSum(1053)

--���������: ����� �� = 0 ��, ����������� ����� = 11 ��.
--�������: ����� �� = 0 ��, ����������� ����� = 4 ��. - �������� �������
/*
4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����. 
*/

--������� ���������� ����� �� ���� ������� ���������� ����������

CREATE FUNCTION [MY_schema].[SumOrders] ( @CustomerID int )
RETURNS TABLE 
AS
RETURN 
(
	SELECT SUM([Quantity]*[UnitPrice]) as SumOrders
	FROM [Sales].[OrderLines] t1
	JOIN [Sales].[Orders] t2 on t1.OrderID=t2.OrderID
	WHERE t2.CustomerID=@CustomerID
);
GO


SELECT [CustomerID],
[CustomerName],
t2.FullName,
summax.SumOrders
FROM [Sales].[Customers] t1
JOIN [Application].[People] t2 on t1.PrimaryContactPersonID=t2.PersonID
CROSS APPLY [MY_schema].[SumOrders] ([CustomerID]) as summax


/*
5) �����������. �� ���� ���������� ������� ����� ������� �������� ���������� �� �� ������������ � ������. 
��������� �� ���������� ������ � �������, � ������ ������, � �� ����� ������� Read Committed.


*/