--- Создаем индексы

CREATE NONCLUSTERED INDEX [IDX_FK_xcode2]
ON [TertiarySales].[NT_Sales_Sausage] ([FK_Store_NO])
INCLUDE ([FK_xcode],[SalesItem],[SalesValueVAT],[PurchaseValueVAT])

CREATE NONCLUSTERED INDEX [IDX_FK_xcode] 
ON [TertiarySales].[NT_Promo_Sausage] ([FK_Store_NO])
INCLUDE ([SalesItem_Promo],[SalesItemValueVAT_Promo],[PromoPriceReport],[RegPriceReport])


--- Запись во временную таблицу из основных таблиц
insert into [DWH].[TertiarySales].[TertiarySalesLoad]
([Client]
      ,[StoreFormat]
      ,[TerritorialUnit]
      ,[Region]
      ,[Settlement]
      ,[StoreAddress]
      ,[StoreNumber]
      ,[ProductGroup]
      ,[TradeMark]
      ,[Manufacturer]
      ,[NameSKU]
      ,[NameConsSKU]
      ,[CodeSKU]
      ,[CodeEAN]
      ,[WeekNumber]
      ,[MonthName]
      ,[YearName]
      ,[SalesItem]
      ,[SalesValue]
      ,[WeightSKU]
      ,[SalesVolume]
      ,[PriceShelf]
      ,[PricePurchase]
      ,[SalesDate]
      ,[DateID]
      ,[BrandStm]
	  ,[Salesitem_promo]
	  ,[Salesvaluevat_promo]
      ,[Promo_price_report]
	  ,[Reg_price_report] )
SELECT
[Client],
[StoreFormat],
[Okrug],
[Region],
[City],
[StoreAddress],
[StoreCodeUni],
[SubGroup],
[Brand],
[Producer],
[SKU_Unif],
Null as [NameConsSku],
SUBSTRING(t2.[FK_xcode],CHARINDEX('-',t2.[FK_xcode])+1,LEN(t2.[FK_xcode])-CHARINDEX('-',t2.[FK_xcode])) as CodeSKU,
[CodEAN],
t4.WeekNumber,
t4.MonthName,
t4.Year,
t1.SalesItem,
t1.SalesValueVAT,
t2.Weight,
t2.Weight*t1.SalesItem/1000 as [SalesVolume],
CAST((t1.SalesValueVAT*1000)/(t2.Weight*t1.SalesItem) as decimal(15,4)) as [PriceShelf],
CAST((t1.PurchaseValueVAT*1000)/(t2.Weight*t1.SalesItem)as decimal(15,4)) as [PricePurchase],
t1.Date,
null as DateID,
t2.BrandStm,
[SalesItem_Promo],
[SalesItemValueVAT_Promo],
[PromoPriceReport],
[RegPriceReport]
FROM [TertiarySales].[NT_Sales_Sausage] t1
JOIN [TertiarySales].[NT_Nomenclatures] t2 on t1.FK_xcode=t2.FK_xcode
JOIN [TertiarySales].[NT_TradePoints] t3 on t1.FK_Store_NO=t3.FK_Store_NO
JOIN [TertiarySales].[NT_Calendar] t4 on t1.Date=t4.Date
LEFT JOIN[TertiarySales].[NT_Promo_Sausage] t5 on t5.FK_Store_NO=t3.FK_Store_NO and
t5.Date=t4.Date and t5.FK_xcode=t2.FK_xcode
WHERE (t2.Weight is not null or t2.Weight<>0) and [CLIENT] in ('Ашан')


------ Временная таблица
CREATE TABLE [TertiarySales].[TertiarySalesLoad](
	[Client] [nvarchar](255) NULL,
	[StoreFormat] [nvarchar](255) NULL,
	[TerritorialUnit] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Settlement] [nvarchar](255) NULL,
	[StoreAddress] [nvarchar](255) NULL,
	[StoreNumber] [nvarchar](255) NULL,
	[ProductGroup] [nvarchar](255) NULL,
	[TradeMark] [nvarchar](255) NULL,
	[Manufacturer] [nvarchar](255) NULL,
	[NameSKU] [nvarchar](255) NULL,
	[NameConsSKU] [nvarchar](255) NULL,
	[CodeSKU] [nvarchar](255) NULL,
	[CodeEAN] [nvarchar](255) NULL,
	[WeekNumber] [int] NULL,
	[MonthName] [nvarchar](255) NULL,
	[YearName] [int] NULL,
	[SalesItem] [decimal](15, 4) NULL,
	[SalesValue] [decimal](15, 4) NULL,
	[WeightSKU] [decimal](15, 4) NULL,
	[SalesVolume] [decimal](15, 4) NULL,
	[PriceShelf] [decimal](15, 4) NULL,
	[PricePurchase] [decimal](15, 4) NULL,
	[SalesDate] [date] NULL,
	[DateID] [int] NULL,
	[BrandStm] [nvarchar](20) NULL,
	[Salesitem_promo] [decimal](15, 4) NULL,
	[Salesvaluevat_promo] [decimal](15, 4) NULL,
	[Promo_price_report] [decimal](15, 4) NULL,
	[Reg_price_report] [decimal](15, 4) NULL
) ON [PRIMARY]
GO

---- Откуда забираем
CREATE TABLE [TertiarySales].[NT_Nomenclatures](
	[FK_xcode] [nvarchar](255) NOT NULL,
	[CodEAN] [nvarchar](100) NULL,
	[Producer] [nvarchar](255) NULL,
	[CreateDate] [date] NULL,
	[Brand] [nvarchar](100) NULL,
	[Category] [nvarchar](100) NULL,
	[Subcategory] [nvarchar](100) NULL,
	[ProductGroup] [nvarchar](100) NULL,
	[SubGroup] [nvarchar](100) NULL,
	[TypeMeat] [nvarchar](100) NULL,
	[Condition] [nvarchar](100) NULL,
	[Weight] [decimal](15, 3) NULL,
	[Package] [nvarchar](100) NULL,
	[Bone] [nvarchar](100) NULL,
	[Skin] [nvarchar](100) NULL,
	[Casing] [nvarchar](100) NULL,
	[Shape] [nvarchar](100) NULL,
	[BrandStm] [nvarchar](100) NULL,
	[SKU] [nvarchar](300) NULL,
	[SKU_Unif] [nvarchar](300) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
 CONSTRAINT [PK_Nom] PRIMARY KEY ([FK_xcode])) 

	
CREATE TABLE [TertiarySales].[NT_TradePoints](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[Chain] [nvarchar](100) NULL,
	[Client] [nvarchar](255) NULL,
	[StoreFormat] [nvarchar](255) NULL,
	[CreateDate] [date] NULL,
	[StoreCodeUni] [nvarchar](255) NULL,
	[Okrug] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[StoreAddress] [nvarchar](300) NULL,
	[Branch] [nvarchar](255) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
 CONSTRAINT [PK_TP] PRIMARY KEY ([FK_Store_NO]))


CREATE TABLE [TertiarySales].[NT_Calendar](
	[DateID] [int] NOT NULL,
	[Date] [date] NULL,
	[Year] [int] NULL,
	[MonthNum] [int] NULL,
	[MonthName] [nvarchar](20) NULL,
	[MonthYear] [nvarchar](20) NULL,
	[Quarter] [nvarchar](20) NULL,
	[HalfYear] [nvarchar](20) NULL,
	[WeekDayName] [nvarchar](20) NULL,
	[WeekNumber] [int] NULL,
	[MonthDayNumber] [int] NULL,
	[WeekDayNumber] [int] NULL,
	[FirstDayOfMonth] [date] NULL,
 CONSTRAINT [PK_DateID] PRIMARY KEY ([DateID])) 

	
CREATE TABLE [TertiarySales].[NT_Promo_Sausage](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NOT NULL,
	[CreateDate] [date] NULL,
	[SalesItem_Promo] [decimal](15, 3) NULL,
	[SalesItemValueVAT_Promo] [decimal](15, 3) NULL,
	[PromoPriceReport] [decimal](15, 3) NULL,
	[RegPriceReport] [decimal](15, 3) NULL,
	[Date] [date] NULL
) ON [PRIMARY]

CREATE TABLE [TertiarySales].[NT_Sales_Sausage](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NULL,
	[CreateDate] [date] NULL,
	[SalesItem] [decimal](15, 3) NULL,
	[SalesValueVAT] [decimal](15, 3) NULL,
	[PurchaseValueVAT] [decimal](15, 3) NULL,
	[Date] [date] NULL
) ON [PRIMARY]

