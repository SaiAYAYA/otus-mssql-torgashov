/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

DECLARE @xmlDocument XML;

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK '\\Денисова Татьяна\ОБУЧЕНИЕ\SQL_SERVER\StockItems-188-1fb5df.xml', 
 SINGLE_CLOB)
AS data;

SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

SELECT @docHandle AS docHandle;

CREATE TABLE #StockItems(
StockItemName NVARCHAR(100) COLLATE Latin1_General_100_CI_AS NOT NULL, 
SupplierID INT, 
UnitPackageID INT, 
OuterPackageID INT, 
QuantityPerOuter INT, 
TypicalWeightPerUnit DECIMAL(18,3), 
LeadTimeDays INT, 
IsChillerStock BIT, 
TaxRate DECIMAL(18,3), 
UnitPrice DECIMAL(18,2), 
LastEditedBy INT);

INSERT INTO #StockItems
SELECT StockItemName , 
SupplierID, 
UnitPackageID, 
OuterPackageID, 
QuantityPerOuter, 
TypicalWeightPerUnit, 
LeadTimeDays, 
IsChillerStock, 
TaxRate, 
UnitPrice,
1
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	StockItemName NVARCHAR(100)  '@Name',
	SupplierID INT 'SupplierID',
	UnitPackageID INT 'Package/UnitPackageID',
	OuterPackageID INT 'Package/OuterPackageID',
	QuantityPerOuter INT 'Package/QuantityPerOuter',
	TypicalWeightPerUnit DECIMAL(18,3) 'Package/TypicalWeightPerUnit',
	LeadTimeDays INT 'LeadTimeDays',
	IsChillerStock BIT 'IsChillerStock',
	TaxRate DECIMAL(18,3) 'TaxRate',
	UnitPrice DECIMAL(18,2) 'UnitPrice'	);
--select * from #StockItems;

MERGE [Warehouse].[StockItems] AS target 
	USING (SELECT   StockItemName, 
					SupplierID, 
					UnitPackageID, 
					OuterPackageID, 
					QuantityPerOuter, 
					TypicalWeightPerUnit, 
					LeadTimeDays, 
					IsChillerStock, 
					TaxRate, 
					UnitPrice,
					LastEditedBy
                    FROM   #StockItems)
	AS source (StockItemName, 
					SupplierID, 
					UnitPackageID, 
					OuterPackageID, 
					QuantityPerOuter, 
					TypicalWeightPerUnit, 
					LeadTimeDays, 
					IsChillerStock, 
					TaxRate, 
					UnitPrice,
					LastEditedBy) 
	ON	 (target.[StockItemName] = source.[StockItemName]) 
WHEN MATCHED 
	 THEN UPDATE SET SupplierID = source.SupplierID,
	   				 UnitPackageID = source.UnitPackageID, 
					 OuterPackageID=source.OuterPackageID, 
					 QuantityPerOuter=source.QuantityPerOuter, 
					 TypicalWeightPerUnit=source.TypicalWeightPerUnit, 
					 LeadTimeDays=source.LeadTimeDays, 
					 IsChillerStock=source.IsChillerStock, 
					 TaxRate=source.TaxRate, 
					 UnitPrice=source.UnitPrice,
					 LastEditedBy=source.LastEditedBy
      WHEN NOT MATCHED 
		THEN INSERT (StockItemName, 
					SupplierID, 
					UnitPackageID, 
					OuterPackageID, 
					QuantityPerOuter, 
					TypicalWeightPerUnit, 
					LeadTimeDays, 
					IsChillerStock, 
					TaxRate, 
					UnitPrice,
					LastEditedBy) 
			VALUES (source.StockItemName,
			        source.SupplierID, 
			        source.UnitPackageID, 
					source.OuterPackageID, 
					source.QuantityPerOuter, 
					source.TypicalWeightPerUnit,
					source.LeadTimeDays,
					source.IsChillerStock,
					source.TaxRate,
					source.UnitPrice,
					source.LastEditedBy); 
          
EXEC sp_xml_removedocument @docHandle;
DROP TABLE IF EXISTS #StockItems;

--XQuery

DECLARE @x XML;
SET @x = (SELECT * FROM OPENROWSET (BULK '\\Денисова Татьяна\ОБУЧЕНИЕ\SQL_SERVER\StockItems-188-1fb5df.xml', 
SINGLE_BLOB)  AS d);

CREATE TABLE #StockItems2(
StockItemName NVARCHAR(100) COLLATE Latin1_General_100_CI_AS NOT NULL, 
SupplierID INT, 
UnitPackageID INT, 
OuterPackageID INT, 
QuantityPerOuter INT, 
TypicalWeightPerUnit DECIMAL(18,3), 
LeadTimeDays INT, 
IsChillerStock BIT, 
TaxRate DECIMAL(18,3), 
UnitPrice DECIMAL(18,2), 
LastEditedBy INT);

INSERT INTO #StockItems2
SELECT StockItemName , 
SupplierID, 
UnitPackageID, 
OuterPackageID, 
QuantityPerOuter, 
TypicalWeightPerUnit, 
LeadTimeDays, 
IsChillerStock, 
TaxRate, 
UnitPrice,
1
FROM (SELECT
t.StockItem.value('@Name','varchar(50)') as StockItemName, 
t.StockItem.value('SupplierID[1]', 'int') as SupplierID,
t.StockItem.value('Package[1]/UnitPackageID[1]','int') as UnitPackageID,
t.StockItem.value('Package[1]/OuterPackageID[1]', 'int') as OuterPackageID,
t.StockItem.value('Package[1]/QuantityPerOuter[1]', 'int') as QuantityPerOuter,
t.StockItem.value('Package[1]/TypicalWeightPerUnit[1]', 'float') as TypicalWeightPerUnit,
t.StockItem.value('LeadTimeDays[1]', 'int') as LeadTimeDays,
t.StockItem.value('IsChillerStock[1]', 'int') as IsChillerStock,
t.StockItem.value('TaxRate[1]', 'float') as TaxRate ,
t.StockItem.value('UnitPrice[1]', 'float') as UnitPrice
FROM @X.nodes('/StockItems/Item') t(StockItem)) t;


MERGE [Warehouse].[StockItems] AS target 
	USING (SELECT   StockItemName, 
					SupplierID, 
					UnitPackageID, 
					OuterPackageID, 
					QuantityPerOuter, 
					TypicalWeightPerUnit, 
					LeadTimeDays, 
					IsChillerStock, 
					TaxRate, 
					UnitPrice,
					LastEditedBy
                    FROM   #StockItems2)
	AS source (StockItemName, 
					SupplierID, 
					UnitPackageID, 
					OuterPackageID, 
					QuantityPerOuter, 
					TypicalWeightPerUnit, 
					LeadTimeDays, 
					IsChillerStock, 
					TaxRate, 
					UnitPrice,
					LastEditedBy) 
	ON	 (target.[StockItemName] = source.[StockItemName]) 
WHEN MATCHED 
	 THEN UPDATE SET SupplierID = source.SupplierID,
	   				 UnitPackageID = source.UnitPackageID, 
					 OuterPackageID=source.OuterPackageID, 
					 QuantityPerOuter=source.QuantityPerOuter, 
					 TypicalWeightPerUnit=source.TypicalWeightPerUnit, 
					 LeadTimeDays=source.LeadTimeDays, 
					 IsChillerStock=source.IsChillerStock, 
					 TaxRate=source.TaxRate, 
					 UnitPrice=source.UnitPrice,
					 LastEditedBy=source.LastEditedBy
      WHEN NOT MATCHED 
		THEN INSERT (StockItemName, 
					SupplierID, 
					UnitPackageID, 
					OuterPackageID, 
					QuantityPerOuter, 
					TypicalWeightPerUnit, 
					LeadTimeDays, 
					IsChillerStock, 
					TaxRate, 
					UnitPrice,
					LastEditedBy) 
			VALUES (source.StockItemName,
			        source.SupplierID, 
			        source.UnitPackageID, 
					source.OuterPackageID, 
					source.QuantityPerOuter, 
					source.TypicalWeightPerUnit,
					source.LeadTimeDays,
					source.IsChillerStock,
					source.TaxRate,
					source.UnitPrice,
					source.LastEditedBy)
						OUTPUT  $action, inserted.*;


DROP TABLE IF EXISTS #StockItems2;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT  StockItemName AS [@Name],
		SupplierID AS [SupplierID],
		UnitPackageID AS [Package/UnitPackageID],
		OuterPackageID AS [Package/OuterPackageID],
		QuantityPerOuter AS [Package/QuantityPerOuter],
		TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit],
		LeadTimeDays as [LeadTimeDays],
		IsChillerStock AS [IsChillerStock],
		TaxRate AS [TaxRate],
		UnitPrice as [UnitPrice]
FROM [Warehouse].[StockItems]
FOR XML PATH('Item'), ROOT('StockItems');
GO


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT 
    StockItemID,
    StockItemName, 
    JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
	  JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
FROM [Warehouse].[StockItems];

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT 
    StockItemID,
    StockItemName,
	  STRING_AGG(Tags2.value,', ') as  Tags2
FROM [Warehouse].[StockItems]
CROSS APPLY OPENJSON (CustomFields, '$.Tags') Tags
CROSS APPLY OPENJSON (CustomFields, '$.Tags') Tags2
WHERE Tags.value ='Vintage'
GROUP BY StockItemID,  StockItemName;
