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
