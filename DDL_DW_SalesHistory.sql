use master;
GO

/*Create Datawarehouse*/
CREATE DATABASE SalesHistory_DW;
GO

USE SalesHistory_DW;
GO

/*Initialize*/
/*Create DimDate*/
CREATE TABLE dbo.DimDate (
	DateKey INT NOT NULL
	,DateValue DATE NOT NULL
	,CYear SMALLINT NOT NULL
	,DQtr TINYINT NOT NULL
	,DMonth TINYINT NOT NULL
	,DDay TINYINT NOT NULL
	,StartOfMonth DATE NOT NULL
	,EndOfMonth DATE NOT NULL
	,DMonthName VARCHAR(9) NOT NULL
	,DayOfWeekName VARCHAR(9) NOT NULL
	,CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED (DateKey)
	);
GO

/*Stored Proc to load data in DimDate*/
CREATE OR ALTER PROCEDURE dbo.DimDate_Load @DateValue DATE
AS
BEGIN;

	INSERT INTO dbo.DimDate
	SELECT CAST(YEAR(@DateValue) * 10000 + MONTH(@DateValue) * 100 + DAY(@DateValue) AS INT)
		,@DateValue
		,YEAR(@DateValue)
		,DATEPART(qq, @DateValue)
		,MONTH(@DateValue)
		,DAY(@DateValue)
		,DATEADD(DAY, 1, EOMONTH(@DateValue, - 1))
		,EOMONTH(@DateValue)
		,DATENAME(mm, @DateValue)
		,DATENAME(dw, @DateValue);
END
GO

/*Loading data into DimDate from '1998-01-01' to '2022-12-31' */
DECLARE @current_date DATE;

SET @current_date = '1998-01-01'

WHILE (@current_date <= '2022-12-31')
BEGIN
	EXECUTE dbo.DimDate_Load @current_date

	SET @current_date = DATEADD(DAY, 1, @current_date)
END
GO


/*Create DimLoaction */
CREATE TABLE [DimLocation] (
  [CountryKey] Int IDENTITY,
  [CountryName] NVARCHAR(40),
  [CountryIsoCode] NVARCHAR(2),
  [CountryRegion] NVARCHAR(20),
  [CountrySubregion] NVARCHAR(30),
  [CustStateProvince] NVARCHAR(40),
  [CustCity] NVARCHAR(30),
  [StartDate] Date,
  [EndDate] Date,
  CONSTRAINT PK_DimLocation PRIMARY KEY CLUSTERED (CountryKey)
);

 
/*Create DimPromotions*/
CREATE TABLE [DimPromotions] (
  [PromoKey] INT IDENTITY,
  [PromoName] NVARCHAR(30),
  [PromoCategory] NVARCHAR(30),
  [PromoSubcategory] NVARCHAR(30),
  [PromoBeginDate] DATETIME,
  [PromoEndDate] DATETIME,
  CONSTRAINT PK_DimPromotions PRIMARY KEY CLUSTERED (PromoKey)
);

 
/*Create DimProducts*/
CREATE TABLE [DimProducts] (
  [ProductKey] INT IDENTITY,
  [ProdName] NVARCHAR(50),
  [ProdDesc] NVARCHAR(4000),
  [ProdCategory] NVARCHAR(50),
  [ProdSubcategory] NVARCHAR(50),
  [ProdValid] NVARCHAR(1),
  CONSTRAINT PK_DimProducts PRIMARY KEY CLUSTERED (ProductKey)
);

 
/*Create DimChannels*/
CREATE TABLE [DimChannels] (
  [ChannelKey] INT IDENTITY,
  [ChannelDesc] NVARCHAR(20),
  [ChannelClass] NVARCHAR(20),
  CONSTRAINT PK_DimChannels PRIMARY KEY CLUSTERED ([ChannelKey])
);

 
/*Create DimCustomers*/
CREATE TABLE [DimCustomers] (
  [CustomerKey] INT IDENTITY,
  [CustFirstName] NVARCHAR(20),
  [CustLastName] NVARCHAR(40),
  [CustGender] NVARCHAR(1),
  [CustMaritalStatus] NVARCHAR(20),
  [EmailAddress] NVARCHAR(50),
  [CustIncomeLevel] NVARCHAR(30),
  [CustValid] NVARCHAR(1),
  [StartDate] Date,
  [EndDate] Date,
  CONSTRAINT PK_DimCustomers PRIMARY KEY CLUSTERED ([CustomerKey])
);

 
/*Create Fact Table FactSales*/
CREATE TABLE FactSales (
  [DateKey] INT,
  [CountryKey] INT,
  [CustomerKey] INT,
  [ProductKey] INT,
  [PromoKey] INT,
  [ChannelKey] INT,
  [QuantitySold] NUMERIC(10,2),
  [AmountSold] NUMERIC(10,2),
  CONSTRAINT [FK_Fact.PromoKey]
    FOREIGN KEY ([PromoKey])
      REFERENCES [DimPromotions]([PromoKey]),
  CONSTRAINT [FK_Fact.ProductKey]
    FOREIGN KEY ([ProductKey])
      REFERENCES [DimProducts]([ProductKey]),
  CONSTRAINT [FK_Fact.CustomerKey]
    FOREIGN KEY ([CustomerKey])
      REFERENCES [DimCustomers]([CustomerKey]),
  CONSTRAINT [FK_Fact.DateKey]
    FOREIGN KEY ([DateKey])
      REFERENCES [DimDate]([DateKey]),
  CONSTRAINT [FK_Fact.CountryKey]
    FOREIGN KEY ([CountryKey])
      REFERENCES [DimLocation]([CountryKey]),
	CONSTRAINT [FK_Fact.ChannelKey]
    FOREIGN KEY ([ChannelKey])
      REFERENCES [DimChannels] ([ChannelKey])
);