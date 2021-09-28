/*************************************************
 *				Assignment 1		             *
 *				Team: 7							 *
 *				Date: 15/09/2021				 *
 *************************************************/

USE MASTER
GO
IF DB_ID (N'Assignment1_v2') IS NOT NULL -- Check if it already exists and drop if it is
DROP DATABASE Assignment1_v2;
GO
CREATE DATABASE Assignment1_v2;
GO

USE Assignment1_v2
go


 -- Drop tables if they exist
DROP TABLE IF EXISTS FactSales;	
DROP TABLE IF EXISTS DimCustomer;
DROP TABLE IF EXISTS DimStaff;
DROP TABLE IF EXISTS DimDate;
DROP TABLE IF EXISTS DimItem;

GO


-- Create Tables
CREATE TABLE DimCustomer (
	ID uniqueidentifier DEFAULT NEWSEQUENTIALID(),
	Customer_ID nvarchar(50) not null,					-- customer natural key
	Customer_First_Name nvarchar(20) null,
	Customer_Surname nvarchar(20) null,					-- note not null may not always be true	
	Primary Key (ID)
)

CREATE TABLE DimStaff (
	ID uniqueidentifier DEFAULT NEWSEQUENTIALID(),
	Staff_ID nvarchar(50) not null,						-- staff natural key identifer
	Staff_First_Name	nvarchar(20) null,				
	Staff_Surname		nvarchar(20) null,
	Location_ID nvarchar(2) not null,
	Location_Name nvarchar(20) not null,
	Primary Key (ID),
)

CREATE TABLE DimItem (		
	ID uniqueidentifier DEFAULT NEWSEQUENTIALID(),			
	Item_ID	nvarchar(50)	not null,					-- Natural Tem key
	Item_Description nvarchar(30) null,
	Item_Unit_Price float null,
	Primary Key (ID)
)

CREATE TABLE DimDate (
	ID uniqueidentifier DEFAULT NEWSEQUENTIALID(),
	Sale_Date datetime2 not null,
	Day int null,			
	Month int	null,					
	Quarter int null,
	Year int null,
	Primary Key (ID)
)


CREATE TABLE FactSales (
	Dim_Date_ID uniqueidentifier not null,
	Dim_Customer_ID uniqueidentifier not null,
	Dim_Staff_ID uniqueidentifier not null,
	Dim_Item_ID uniqueidentifier not null,
	Receipt_ID nvarchar(50) not null,
	Receipt_Transaction_Row_ID nvarchar(50) not null,
	Item_Quantity int not null,	
	Row_Total float null,
	PRIMARY KEY (Dim_Date_ID, Dim_Customer_ID, Dim_Staff_ID, Dim_Item_ID, Receipt_ID, Receipt_Transaction_Row_ID),
	FOREIGN KEY (Dim_Date_ID) REFERENCES DimDate (ID),
	FOREIGN KEY (Dim_Customer_ID) REFERENCES DimCustomer (ID),
	FOREIGN KEY (Dim_Staff_ID) REFERENCES DimStaff (ID),
	FOREIGN KEY (Dim_Item_ID) REFERENCES DimItem (ID),
)
go



