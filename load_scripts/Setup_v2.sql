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
	Customer_ID nvarchar(50) not null,					-- customer natural key
	Customer_First_Name nvarchar(20) null,
	Customer_Surname nvarchar(20) null,					-- note not null may not always be true	
	Primary Key (Customer_ID)
)

CREATE TABLE DimStaff (
	Staff_ID nvarchar(50) not null,						-- staff natural key identifer
	Staff_First_Name	nvarchar(20) null,				
	Staff_Surname		nvarchar(20) null,
	Location_ID nvarchar(2) not null,
	Location_Name nvarchar(20) not null,
	Primary Key (Staff_ID),
)

CREATE TABLE DimItem (					
	Item_ID	nvarchar(50)	not null,					-- Natural Tem key
	Item_Description nvarchar(30) null,
	Item_Unit_Price float null,
	Primary Key (Item_ID)
)

CREATE TABLE DimDate (
	Sale_Date datetime2 not null,
	Day int null,			
	Month int	null,					
	Quarter int null,
	Year int null,
	Primary Key (Sale_Date)
)


CREATE TABLE FactSales (
	Sale_Date datetime2 not null,
	Customer_ID nvarchar(50) not null,
	Staff_ID nvarchar(50) not null,
	Item_ID nvarchar(50) not null,
	Receipt_ID nvarchar(50) not null,
	Receipt_Transaction_Row_ID nvarchar(50) not null,
	Item_Quantity int not null,	
	Row_Total float null,
	PRIMARY KEY (Sale_Date, Customer_ID, Staff_ID, Item_ID, Receipt_ID, Receipt_Transaction_Row_ID),
	FOREIGN KEY (Sale_Date) REFERENCES DimDate (Sale_Date),
	FOREIGN KEY (Customer_ID) REFERENCES DimCustomer (Customer_ID),
	FOREIGN KEY (Staff_ID) REFERENCES DimStaff (Staff_ID),
	FOREIGN KEY (Item_ID) REFERENCES DimItem (Item_ID),
)
go



