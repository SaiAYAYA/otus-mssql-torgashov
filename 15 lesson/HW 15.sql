 USE [WideWorldImporters]

  
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'clr enabled', 1;
EXEC sp_configure 'clr strict security', 0;
GO


RECONFIGURE;
GO


ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 


CREATE ASSEMBLY SumSales_CLR
FROM 'D:\Repos\CLR_test.dll'
WITH PERMISSION_SET = SAFE; 

--SELECT * FROM sys.assemblies;
--GO


CREATE FUNCTION [MY_schema].[SumSales] (@Customer int)  
RETURNS DECIMAL (18,2)
AS EXTERNAL NAME [SumSales_CLR].[CLR_test.CLR_Procedure].SumSalesCustomer;
GO 


SELECT [MY_schema].[SumSales] (835) AS [CLR];

SELECT SUM(SIL.ExtendedPrice) 
FROM [Sales].[Invoices] SI 
JOIN [Sales].[InvoiceLines] SIL on SI.InvoiceID=SIL.InvoiceID 
WHERE SI.CustomerID=835;
