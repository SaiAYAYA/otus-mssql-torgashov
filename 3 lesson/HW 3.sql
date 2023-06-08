/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT year(t1.[InvoiceDate]) as Год,
		month(t1. [InvoiceDate]) as Месяц,
		AVG(t2.[UnitPrice]) as СредняяЦена,
		SUM(t2.[ExtendedPrice]) as ОбщаяСумма
FROM [Sales].[Invoices] as t1 
JOIN [Sales].[InvoiceLines] t2 on t1.InvoiceID=t2.InvoiceID
WHERE year(t1.[InvoiceDate]) = 2015 and month(t1. [InvoiceDate]) = 4
GROUP BY year(t1.[InvoiceDate]),
		month(t1. [InvoiceDate])

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT year(t1.[InvoiceDate]) as Год,
		month(t1. [InvoiceDate]) as Месяц,
		SUM(t2.[ExtendedPrice]) as ОбщаяСумма
FROM [Sales].[Invoices] as t1 
JOIN [Sales].[InvoiceLines] t2 on t1.InvoiceID=t2.InvoiceID
--WHERE year(t1.[InvoiceDate]) = 2015 and month(t1. [InvoiceDate]) = 4
GROUP BY year(t1.[InvoiceDate]),
		month(t1. [InvoiceDate])
HAVING SUM(t2.[ExtendedPrice]) > 4600000
ORDER BY [Год],[Месяц]

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT Year(t3.InvoiceDate) as [Год],
	   month(t3.InvoiceDate) as [Месяц],
	   t2.StockItemName as [Товар],
	   min(t3.InvoiceDate) as [ПерваяПродажа],
	   sum(t1.Quantity) as [КоличествоЗаМесяц],
       sum(t1.[ExtendedPrice]) as [СуммаЗаМесяц]
FROM [WideWorldImporters].[Sales].[InvoiceLines] t1
JOIN [WideWorldImporters].[Warehouse].[StockItems] t2 on t1.StockItemID=t2.StockItemID
JOIN [WideWorldImporters].[Sales].[Invoices] t3 on t1.InvoiceID=t3.InvoiceID
GROUP BY   Year(t3.InvoiceDate),
	       month(t3.InvoiceDate),
		   t2.StockItemName
HAVING sum(t1.Quantity) < 50
ORDER BY [Год], [Месяц], t2.StockItemName

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------

/*Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.*/

SELECT year(t3.InvoiceDate) as [Год],
	   month(t3.InvoiceDate) as [Месяц],
	   IIF(SUM(t1.[ExtendedPrice]) > 4600000, SUM(t1.[ExtendedPrice]), 0) as [СуммаЗаМесяц]
FROM [WideWorldImporters].[Sales].[InvoiceLines] t1
JOIN [WideWorldImporters].[Sales].[Invoices] t3 on t1.InvoiceID=t3.InvoiceID
GROUP BY Year(t3.InvoiceDate),
	     month(t3.InvoiceDate)
ORDER BY [Год],[Месяц]

SELECT year(t3.InvoiceDate) as [Год],
	   month(t3.InvoiceDate) as [Месяц],
	   t2.StockItemName as   [Товар],
	   IIF (sum(t1.Quantity) < 50, min(t3.InvoiceDate),null) as [Перваяпродажа],
	   IIF(sum(t1.Quantity) < 50,sum(t1.Quantity),0) as [КоличествоЗаМесяц],
       IIF (sum(t1.Quantity) < 50,sum(t1.[ExtendedPrice]),0) as [СуммаЗаМесяц]
FROM [WideWorldImporters].[Sales].[InvoiceLines] t1
JOIN [WideWorldImporters].[Warehouse].[StockItems] t2 on t1.StockItemID=t2.StockItemID
JOIN [WideWorldImporters].[Sales].[Invoices] t3 on t1.InvoiceID=t3.InvoiceID
GROUP BY t2.StockItemID,
       	   t2.StockItemName,
	       Year(t3.InvoiceDate),
	       month(t3.InvoiceDate)
ORDER BY [Год], [Месяц], t2.StockItemName

