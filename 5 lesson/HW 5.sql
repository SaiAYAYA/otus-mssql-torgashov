/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "03 - Подзапросы, CTE, временные таблицы".
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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

WITH Invoice_CTE ([SalespersonPersonID])
AS (SELECT [SalespersonPersonID]
    FROM [Sales].[Invoices]
    WHERE [InvoiceDate] = '2015-07-04')
SELECT [PersonID], [FullName]
FROM [Application].[People] t1 
LEFT JOIN Invoice_CTE t2 ON t1.PersonID = t2.SalespersonPersonID
WHERE [IsSalesperson] = 1 AND t2.SalespersonPersonID IS NULL


SELECT [PersonID], [FullName]
FROM [Application].[People] t1
LEFT JOIN (SELECT [SalespersonPersonID]
FROM [Sales].[Invoices]
WHERE [InvoiceDate] = '2015-07-04')t2 ON t1.PersonID = t2.SalespersonPersonID
WHERE [IsSalesperson] = 1 AND t2.SalespersonPersonID IS NULL

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

WITH StockItems_CTE ([UnitPrice],[StockItemID],[StockItemName])
AS
(SELECT MIN([UnitPrice]),
         [StockItemID],
         [StockItemName]
FROM [Warehouse].[StockItems]
GROUP BY [StockItemID],[StockItemName])
SELECT TOP (1) [StockItemID],
             [StockItemName],
             [UnitPrice]
FROM StockItems_CTE 
ORDER BY [UnitPrice]


SELECT [StockItemID],
       [StockItemName],
       [UnitPrice]
FROM [Warehouse].[StockItems] 
WHERE [UnitPrice] = (SELECT MIN([UnitPrice]) 
FROM [Warehouse].[StockItems])

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

WITH MaxPay_CTE ([CustomerID],[TransactionAmount])
AS (SELECT TOP (5) [CustomerID],[TransactionAmount]
	FROM [Sales].[CustomerTransactions]
	ORDER BY [TransactionAmount] DESC)
SELECT t1.[CustomerID],
       [CustomerName],
       t2.TransactionAmount
FROM [Sales].[Customers] t1
JOIN MaxPay_CTE t2 ON t1.CustomerID = t2.CustomerID


SELECT t1.[CustomerID],
       [CustomerName],
       t2.TransactionAmount
FROM [Sales].[Customers] t1
JOIN (SELECT TOP (5) [CustomerID],[TransactionAmount]
FROM [Sales].[CustomerTransactions]
ORDER BY [TransactionAmount] DESC) t2 ON t1.CustomerID = t2.CustomerID


SELECT TOP (5)
       t1.[CustomerID],
       [CustomerName],
       t2.TransactionAmount
FROM [Sales].[Customers] t1
JOIN [Sales].[CustomerTransactions] t2 ON t1.CustomerID = t2.CustomerID
ORDER BY t2.TransactionAmount DESC

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

WITH Expen_CTE ([StockItemID],[StockItemName])
AS 
(SELECT TOP (3) [StockItemID],[StockItemName]
FROM [Warehouse].[StockItems]
ORDER BY [UnitPrice] DESC)
SELECT DISTINCT t1.[CityID],[CityName],t6.FullName
FROM [Application].[Cities] t1
JOIN [Sales].[Customers] t2 ON t1.CityID = t2.DeliveryCityID
JOIN [Sales].[Invoices] t3 ON t2.CustomerID = t3.CustomerID
JOIN [Sales].[InvoiceLines] t4 ON t4.InvoiceID = t3.InvoiceID
JOIN Expen_CTE t5 ON t4.StockItemID = t5.StockItemID
JOIN [Application].[People] t6 ON t3.PackedByPersonID = t6.PersonID


SELECT DISTINCT t1.[CityID],[CityName],t6.FullName
FROM [Application].[Cities] t1
JOIN [Sales].[Customers] t2 ON t1.CityID = t2.DeliveryCityID
JOIN [Sales].[Invoices] t3 ON t2.CustomerID = t3.CustomerID
JOIN [Sales].[InvoiceLines] t4 ON t4.InvoiceID = t3.InvoiceID
JOIN (SELECT TOP (3) [StockItemID],[StockItemName]
      FROM [Warehouse].[StockItems]
      ORDER BY [UnitPrice] DESC) t5 ON t4.StockItemID = t5.StockItemID
JOIN [Application].[People] t6 ON t3.PackedByPersonID = t6.PersonID

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT Invoices.InvoiceID, Invoices.InvoiceDate,
(SELECT People.FullName
	FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
JOIN (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
напишите здесь свое решение