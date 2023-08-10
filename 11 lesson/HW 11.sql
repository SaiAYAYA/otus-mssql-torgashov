/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO [Purchasing].[Suppliers] 
       ([SupplierName]
      ,[SupplierCategoryID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[SupplierReference]
      ,[BankAccountName]
      ,[BankAccountBranch]
      ,[BankAccountCode]
      ,[BankAccountNumber]
      ,[BankInternationalCode]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy])
SELECT TOP (5)
       CONCAT('My any ',[SupplierName])
      ,[SupplierCategoryID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[SupplierReference]
      ,[BankAccountName]
      ,[BankAccountBranch]
      ,[BankAccountCode]
      ,[BankAccountNumber]
      ,[BankInternationalCode]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
FROM [Purchasing].[Suppliers]

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE [Purchasing].[Suppliers] 
WHERE [SupplierID]=10


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE [Purchasing].[Suppliers]
SET [SupplierName]='Test',
    [PostalAddressLine1]='dvadva'
WHERE [SupplierID]=10

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

SELECT TOP (5)[CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
INTO #MY_TEMP
FROM [Sales].[Customers]

--Добавим пару записей не совпадающих по имени

INSERT INTO #MY_TEMP
SELECT TOP (2)
       CONCAT('My any ',[CustomerName])
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
FROM [Sales].[Customers]
        
--SELECT * FROM #MY_TEMP

MERGE Sales.Customers as target
USING (SELECT [CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
	  FROM #MY_TEMP) AS Source 
	  ([CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy])
ON (target.CustomerName = source.CustomerName)
WHEN MATCHED 
		THEN UPDATE SET 
		  BillToCustomerID = source.BillToCustomerID
		, CustomerCategoryID = source.CustomerCategoryID
		, BuyingGroupID = source.BuyingGroupID
		, PrimaryContactPersonID = source.PrimaryContactPersonID
		, AlternateContactPersonID = source.AlternateContactPersonID
		, DeliveryMethodID = source.DeliveryMethodID
		, DeliveryCityID = source.DeliveryCityID
		, PostalCityID = source.PostalCityID
		, CreditLimit = source.CreditLimit
		, AccountOpenedDate = source.AccountOpenedDate
		, StandardDiscountPercentage = source.StandardDiscountPercentage
		, IsStatementSent = source.IsStatementSent
		, IsOnCreditHold = source.IsOnCreditHold
		, PaymentDays = source.PaymentDays
		, PhoneNumber = source.PhoneNumber
		, FaxNumber = source.FaxNumber
		, DeliveryRun = source.DeliveryRun
		, RunPosition = source.RunPosition
		, WebsiteURL = source.WebsiteURL
		, DeliveryAddressLine1 = source.DeliveryAddressLine1
		, DeliveryAddressLine2 = source.DeliveryAddressLine2
		, DeliveryPostalCode = source.DeliveryPostalCode
		, DeliveryLocation = source.DeliveryLocation
		, PostalAddressLine1 = source.PostalAddressLine1
		, PostalAddressLine2 = source.PostalAddressLine2
		, PostalPostalCode = source.PostalPostalCode
		, LastEditedBy = source.LastEditedBy
WHEN NOT MATCHED 
       THEN INSERT (   [CustomerName]
					  ,[BillToCustomerID]
					  ,[CustomerCategoryID]
					  ,[BuyingGroupID]
					  ,[PrimaryContactPersonID]
					  ,[AlternateContactPersonID]
					  ,[DeliveryMethodID]
					  ,[DeliveryCityID]
					  ,[PostalCityID]
					  ,[CreditLimit]
					  ,[AccountOpenedDate]
					  ,[StandardDiscountPercentage]
					  ,[IsStatementSent]
					  ,[IsOnCreditHold]
					  ,[PaymentDays]
					  ,[PhoneNumber]
					  ,[FaxNumber]
					  ,[DeliveryRun]
					  ,[RunPosition]
					  ,[WebsiteURL]
					  ,[DeliveryAddressLine1]
					  ,[DeliveryAddressLine2]
					  ,[DeliveryPostalCode]
					  ,[DeliveryLocation]
					  ,[PostalAddressLine1]
					  ,[PostalAddressLine2]
					  ,[PostalPostalCode]
					  ,[LastEditedBy])
VALUES (source.CustomerName, 
		source.BillToCustomerID, 
		source.CustomerCategoryID, 
		source.BuyingGroupID, 
		source.PrimaryContactPersonID, 
		source.AlternateContactPersonID, 
		source.DeliveryMethodID, 
		source.DeliveryCityID, 
		source.PostalCityID, 
		source.CreditLimit, 
		source.AccountOpenedDate, 
		source.StandardDiscountPercentage, 
		source.IsStatementSent, 
		source.IsOnCreditHold, 
		source.PaymentDays, 
		source.PhoneNumber, 
		source.FaxNumber, 
		source.DeliveryRun, 
		source.RunPosition,
		source.WebsiteURL, 
		source.DeliveryAddressLine1, 
		source.DeliveryAddressLine2, 
		source.DeliveryPostalCode, 
		source.DeliveryLocation, 
		source.PostalAddressLine1, 
		source.PostalAddressLine2,
		source.PostalPostalCode, 
		source.LastEditedBy)
OUTPUT $action, inserted.*;--посмотрим, как получилось


DROP TABLE IF EXISTS #MY_TEMP

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO

USE [WideWorldImporters]
SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "WideWorldImporters.Sales.Customers" out "D:\test.txt" -T -w -t"%%*" -S  sostav454micel'

SELECT *
INTO Sales.My_Customers
FROM Sales.Customers
WHERE 1 = 2 

BULK INSERT Sales.My_Customers
		FROM "D:\test.txt"
		WITH ( BATCHSIZE = 1000
			 , DATAFILETYPE = 'char'
			 , FIELDTERMINATOR = '%%*' 
			 , ROWTERMINATOR = '\n'
			 , KEEPNULLS
			 , TABLOCK
			)

DROP TABLE IF EXISTS Sales.My_Customers