---- Ñîçäàíèå DB

CREATE DATABASE [NT]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'NT', FILENAME = N'D:\Data\NT.mdf' , SIZE = 24190976KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'NT_log', FILENAME = N'D:\Data\NT_log.ldf' , SIZE = 12001280KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

CREATE SCHEMA [TeartiarySales]
GO
	
USE [NT]
GO

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
 CONSTRAINT [PK_Nom] PRIMARY KEY CLUSTERED 


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
 CONSTRAINT [PK_TP] PRIMARY KEY CLUSTERED 


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
 CONSTRAINT [PK_DateID] PRIMARY KEY CLUSTERED 


CREATE TABLE [TertiarySales].[NT_Promo_Feed](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NOT NULL,
	[CreateDate] [date] NULL,
	[SalesItem_Promo] [decimal](15, 3) NULL,
	[SalesItemValueVAT_Promo] [decimal](15, 3) NULL,
	[PromoPriceReport] [decimal](15, 3) NULL,
	[RegPriceReport] [decimal](15, 3) NULL,
	[Date] [date] NULL
) ON [PRIMARY]


CREATE TABLE [TertiarySales].[NT_Promo_OPF](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NOT NULL,
	[CreateDate] [date] NULL,
	[SalesItem_Promo] [decimal](15, 3) NULL,
	[SalesItemValueVAT_Promo] [decimal](15, 3) NULL,
	[PromoPriceReport] [decimal](15, 3) NULL,
	[RegPriceReport] [decimal](15, 3) NULL,
	[Date] [date] NULL
) ON [PRIMARY]


CREATE TABLE [TertiarySales].[NT_Promo_Other](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NOT NULL,
	[CreateDate] [date] NULL,
	[SalesItem_Promo] [decimal](15, 3) NULL,
	[SalesItemValueVAT_Promo] [decimal](15, 3) NULL,
	[PromoPriceReport] [decimal](15, 3) NULL,
	[RegPriceReport] [decimal](15, 3) NULL,
	[Date] [date] NULL,
	[PT] [tinyint] NULL
) ON [PRIMARY]


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


CREATE TABLE [TertiarySales].[NT_Promo_ZPF](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NOT NULL,
	[CreateDate] [date] NULL,
	[SalesItem_Promo] [decimal](15, 3) NULL,
	[SalesItemValueVAT_Promo] [decimal](15, 3) NULL,
	[PromoPriceReport] [decimal](15, 3) NULL,
	[RegPriceReport] [decimal](15, 3) NULL,
	[Date] [date] NULL
) ON [PRIMARY]


CREATE TABLE [TertiarySales].[NT_Sales_Feed](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NULL,
	[CreateDate] [date] NULL,
	[SalesItem] [decimal](15, 3) NULL,
	[SalesValueVAT] [decimal](15, 3) NULL,
	[PurchaseValueVAT] [decimal](15, 3) NULL,
	[Date] [date] NULL
) ON [PRIMARY]


CREATE TABLE [TertiarySales].[NT_Sales_OPF](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NULL,
	[CreateDate] [date] NULL,
	[SalesItem] [decimal](15, 3) NULL,
	[SalesValueVAT] [decimal](15, 3) NULL,
	[PurchaseValueVAT] [decimal](15, 3) NULL,
	[Date] [date] NULL
) ON [PRIMARY]


CREATE TABLE [TertiarySales].[NT_Sales_Other](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NULL,
	[CreateDate] [date] NULL,
	[SalesItem] [decimal](15, 3) NULL,
	[SalesValueVAT] [decimal](15, 3) NULL,
	[PurchaseValueVAT] [decimal](15, 3) NULL,
	[Date] [date] NULL,
	[PT] [tinyint] NULL
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


CREATE TABLE [TertiarySales].[NT_Sales_ZPF](
	[FK_Store_NO] [nvarchar](100) NOT NULL,
	[FK_xcode] [nvarchar](255) NULL,
	[CreateDate] [date] NULL,
	[SalesItem] [decimal](15, 3) NULL,
	[SalesValueVAT] [decimal](15, 3) NULL,
	[PurchaseValueVAT] [decimal](15, 3) NULL,
	[Date] [date] NULL
) ON [PRIMARY]

ALTER TABLE [TertiarySales].[NT_Promo_Feed]  
ADD  CONSTRAINT [FK_PromoFeed_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Promo_Feed]
ADD  CONSTRAINT [FK_PromoFeed_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Promo_OPF] 
ADD  CONSTRAINT [FK_PromoOpf_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Promo_OPF] 
ADD  CONSTRAINT [FK_PromoOpf_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Promo_Other]
ADD  CONSTRAINT [FK_PromoOther_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Promo_Other]
ADD  CONSTRAINT [FK_PromoOther_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Promo_Sausage]
ADD  CONSTRAINT [FK_Promo_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Promo_Sausage]
ADD  CONSTRAINT [FK_Promo_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Promo_ZPF]
ADD  CONSTRAINT [FK_PromoZpf_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Promo_ZPF]
ADD  CONSTRAINT [FK_PromoZpf_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Sales_Feed]
ADD  CONSTRAINT [FK_SaleFeed_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Sales_Feed]
ADD  CONSTRAINT [FK_SalesFeed_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Sales_OPF]
ADD  CONSTRAINT [FK_SaleOZpf_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Sales_OPF]
ADD  CONSTRAINT [FK_SalesOpf_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Sales_Other]
ADD  CONSTRAINT [FK_SaleOther_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Sales_Other]
ADD  CONSTRAINT [FK_SalesOther_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Sales_Sausage]
ADD  CONSTRAINT [FK_Sales_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Sales_Sausage]
ADD  CONSTRAINT [FK_Sales_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])

ALTER TABLE [TertiarySales].[NT_Sales_ZPF]
ADD  CONSTRAINT [FK_SalesZpf_Nom] FOREIGN KEY([FK_xcode])
REFERENCES [TertiarySales].[NT_Nomenclatures] ([FK_xcode])

ALTER TABLE [TertiarySales].[NT_Sales_ZPF]
ADD  CONSTRAINT [FK_SalesZpf_TradePoints] FOREIGN KEY([FK_Store_NO])
REFERENCES [TertiarySales].[NT_TradePoints] ([FK_Store_NO])


--------1-2 èíäåêñà íà òàáëèöû
CREATE NONCLUSTERED INDEX [Tp_Client_StoreAddress] 
 ON [TertiarySales].[NT_TradePoints]
([Client],[StoreAddress]);


---------Íàëîæåíèå îãðàíè÷åíèÿ íà òàáëèöû
ALTER TABLE [TertiarySales].[NT_TradePoints]
ADD  CONSTRAINT [Uniq_FK_Store_NO] UNIQUE ([FK_Store_NO]);

ALTER TABLE [TertiarySales].[NT_Nomenclatures]
ADD CONSTRAINT [Uniq_FK_xcode] UNIQUE ([FK_xcode]);
