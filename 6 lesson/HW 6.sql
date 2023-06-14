/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29  | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/*/
USE [WideWorldImporters]

set statistics time, io on

WITH SumMonth_CTE ([Year],[MonthNum],[SumMonth])
AS 
(SELECT YEAR(t3.InvoiceDate) AS [Year],
	    MONTH(t3.InvoiceDate) AS [MonthNum],
	    SUM(t1.[ExtendedPrice]) AS [SumMonth]
FROM [Sales].[InvoiceLines] t1
JOIN [Sales].[Invoices] t3 ON t1.InvoiceID = t3.InvoiceID
JOIN [Sales].[CustomerTransactions] t4 ON t3.InvoiceID = t4.InvoiceID
WHERE YEAR(t3.InvoiceDate) >= 2015
GROUP BY YEAR(t3.InvoiceDate),
	     MONTH(t3.InvoiceDate))

SELECT t2.InvoiceID, t2.InvoiceDate,t4.CustomerName, SUM(t3.ExtendedPrice) AS SumInvoice,
(SELECT SUM([SumMonth])
	  FROM SumMonth_CTE 
	  WHERE [Year]*100+[MonthNum] <= t1.[Year]*100 + t1.MonthNum) AS [Total]
FROM SumMonth_CTE AS t1
JOIN [Sales].[Invoices] AS t2 ON t1.MonthNum = MONTH(t2.InvoiceDate) AND t1.YEAR = YEAR(t2.InvoiceDate)
JOIN [Sales].[InvoiceLines] t3 ON t2.InvoiceID = t3.InvoiceID
JOIN [Sales].[Customers] t4 ON t2.CustomerID = t4.CustomerID
GROUP BY [Year],[MonthNum],[SumMonth],t2.InvoiceID, t2.InvoiceDate, t4.CustomerName 
ORDER BY t2.InvoiceID
/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

With SumMonth_CTE ([Year],[MonthNum],[SumMonth])
AS 
(SELECT Year(t3.InvoiceDate) as [Year],
	    month(t3.InvoiceDate) as [MonthNum],
	    SUM(t1.[ExtendedPrice]) as [SumMonth]
FROM [Sales].[InvoiceLines] t1
JOIN [Sales].[Invoices] t3 on t1.InvoiceID=t3.InvoiceID
JOIN [Sales].[CustomerTransactions] t4 on t3.InvoiceID=t4.InvoiceID
Where Year(t3.InvoiceDate)>=2015
Group by Year(t3.InvoiceDate),
	     month(t3.InvoiceDate))
SELECT t1.InvoiceID, t1.InvoiceDate,t3.CustomerName,SUM(t2.ExtendedPrice) as Sum_invoice,  t4.Total
FROM [Sales].[Invoices] t1
JOIN [Sales].[InvoiceLines] t2 on t1.InvoiceID=t2.InvoiceID
JOIN [Sales].[Customers] t3 on t1.CustomerID=t3.CustomerID
JOIN (SELECT [Year],
      [MonthNum],
      [SumMonth],
      SUM([SumMonth]) OVER (ORDER BY [Year],[MonthNum]) AS Total
      FROM SumMonth_CTE) t4 on MONTH(t1.InvoiceDate)=t4.[MonthNum] and YEAR(t1.InvoiceDate)=t4.[Year]
GROUP BY t1.InvoiceID, t1.InvoiceDate,t3.CustomerName, t4.Total
ORDER BY t1.InvoiceID

/*Результаты по статистике по первому запросу:  Время работы SQL Server:
                                                Время ЦП = 6094 мс, затраченное время = 7300 мс.

   Результаты по второму:  Время работы SQL Server:
						   Время ЦП = 859 мс, затраченное время = 1780 мс.

Второй запрос с использованием оконных функций оказался более быстрым и затратил меньше ресурсов
В первом запросе было больше сканирований, чем во втором/*


/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/*/*/

;WITH Quant_CTE ([MonthNum],[StockItemName],[QuanMonth],[RN])
AS
(SELECT month(t2.InvoiceDate) as [MonthNum],
	    t3.StockItemName,
	    SUM(t1.Quantity) as [QuanMonth],
	    ROW_NUMBER() OVER (partition by month(t2.InvoiceDate) ORDER BY SUM(t1.Quantity) desc) as [RN]
FROM [Sales].[InvoiceLines] t1
JOIN [Sales].[Invoices] t2 on t1.InvoiceID=t2.InvoiceID
JOIN [Warehouse].[StockItems] t3 on t1.StockItemID=t3.StockItemID
JOIN [Sales].[CustomerTransactions] t4 on t2.InvoiceID=t4.InvoiceID
Where Year(t2.InvoiceDate)=2016
GROUP BY month(t2.InvoiceDate),t3.StockItemName)

SELECT [MonthNum],StockItemName,[QuanMonth]
FROM Quant_CTE
Where [RN] in (1,2)
Order by [MonthNum],[RN]

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT [StockItemID],
       [StockItemName],
       [Brand],
       [UnitPrice],
ROW_NUMBER() OVER  (partition by Left([StockItemName],1) order by [StockItemName]),
COUNT([StockItemID]) OVER(),
COUNT([StockItemID]) OVER(partition by Left([StockItemName],1)),
LEAD([StockItemID],1) OVER(order by [StockItemName]),
LAG([StockItemID],1) OVER(order by[StockItemName]),
LAG ([StockItemName],2,'No items') OVER(order by [StockItemName]),
NTILE(30) OVER (order by[TypicalWeightPerUnit])
FROM [Warehouse].[StockItems]

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

;WITH lastSales_CTE (SalespersonPersonID,SalespersonPersonName,
CustomerID,CustomerName,InvoiceDate,SumInv,[RN])
AS
(SELECT t1.SalespersonPersonID,
	   t2.[FullName],
	   t1.CustomerID,
	   t3.CustomerName,
	   t1.InvoiceDate,
	   SUM(t4.ExtendedPrice) as SumInv,
	   ROW_NUMBER() OVER (partition by SalespersonPersonID order by InvoiceDate desc) as [RN]
FROM [WideWorldImporters].[Sales].[Invoices] t1
JOIN [WideWorldImporters].[Application].[People] t2 on t1.SalespersonPersonID=t2.PersonID
JOIN [WideWorldImporters].[Sales].[Customers] t3 on t1.CustomerID=t3.CustomerID
JOIN [WideWorldImporters].[Sales].[InvoiceLines] t4 on t1.InvoiceID=t4.InvoiceID
JOIN [Sales].[CustomerTransactions] t5 on t1.InvoiceID=t5.InvoiceID
GROUP BY t1.SalespersonPersonID,
	     t2.[FullName],
	     t1.CustomerID,
	     t3.CustomerName,
	     t1.InvoiceDate)
SElect SalespersonPersonID,
SalespersonPersonName,
CustomerID,
CustomerName,
InvoiceDate,
SumInv
--[RN]
FROM lastSales_CTE
Where [RN]=1 

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
;WITH MY_CTE (CustomerID,CustomerName,StockItemID,UnitPrice,InvoiceDate,DR)
AS
(SELECT  t1.CustomerID,
		t1.CustomerName,
		t3.StockItemID,
		t3.UnitPrice,
		t2.InvoiceDate,
		dense_Rank() OVER (PARTITION BY t1.CustomerName ORDER BY t3.UnitPrice DESC) as DR
FROM [Sales].[Customers] t1
JOIN [Sales].[Invoices] t2 on t1.CustomerID=t2.CustomerID
JOIN [Sales].[InvoiceLines] t3 on t2.InvoiceID=t3.InvoiceID
JOIN [Sales].[CustomerTransactions] t4 on t2.InvoiceID=t4.InvoiceID)
SELECT CustomerID,CustomerName,StockItemID,UnitPrice,InvoiceDate
FROM MY_CTE
WHERE DR in (1,2)


;WITH MY_CTE (CustomerID,CustomerName,StockItemID,UnitPrice,InvoiceDate,DR)
AS
(SELECT  t1.CustomerID,
		t1.CustomerName,
		t3.StockItemID,
		t3.UnitPrice,
		t2.InvoiceDate,
		dense_Rank() OVER (PARTITION BY t1.CustomerName ORDER BY t3.UnitPrice DESC) as DR
FROM [Sales].[Customers] t1
JOIN [Sales].[Invoices] t2 on t1.CustomerID=t2.CustomerID
JOIN [Sales].[InvoiceLines] t3 on t2.InvoiceID=t3.InvoiceID
JOIN [Sales].[CustomerTransactions] t4 on t2.InvoiceID=t4.InvoiceID)
SELECT CustomerID, CustomerName, StockItemID, UnitPrice, MAX(InvoiceDate) as max_InvoiceDate
FROM MY_CTE
WHERE DR in (1,2)
GROUP BY CustomerID, CustomerName, StockItemID, UnitPrice
