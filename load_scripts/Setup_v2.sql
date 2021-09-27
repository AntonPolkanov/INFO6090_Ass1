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
	Customer_Key int identity not null,					-- Surrogate key for Dimension Table
	CustomerID nvarchar(3) not null,					-- customer natural key
	Customer_First_Name nvarchar(20) null,
	Customer_Surname nvarchar(20) null,					-- note not null may not always be true	
	Primary Key (Customer_Key)
)

CREATE TABLE DimStaff (
	Staff_Key int identity not null,				-- Surrogate key for Dimension Table	
	Staff_ID nvarchar(5) null,						-- staff natural key identifer
	Staff_First_Name	nvarchar(20) null,				
	Staff_Surname		nvarchar(20) null,
	Location_ID nvarchar(2) not null,
	Location_Name nvarchar(20) not null,
	Primary Key (Staff_Key),
)

CREATE TABLE DimItem (					
	Item_Key int identity not null,					--Surrogate dimension table key
	Item_ID	nvarchar(5)	null,					-- Natural Tem key
	Item_Description nvarchar(30) null,
	Item_Unit_Price float null,
	Primary Key (Item_Key)
)

CREATE TABLE DimDate (
	Date_Key int identity not null,
	Date_date date null,
	Date_day int null,			
	Date_Month int	null,					
	Date_Quarter int null,
	Date_Year int null,
	Primary Key (Date_Key)
)


CREATE TABLE FactSales (
	Date_Key int not null,
	Customer_Key int not null,
	Staff_Key int not null,
	Item_Key int not null,
	Receipt_ID nvarchar(5) not null,
	Receipt_Transaction_Row_ID nvarchar(5) not null,
	Item_Quantity int not null,	
	Row_Total float null,
	PRIMARY KEY (Date_Key, Customer_Key, Staff_Key, Item_Key, Receipt_ID, Receipt_Transaction_Row_ID),
	FOREIGN KEY (Date_Key) REFERENCES DimDate (Date_Key),
	FOREIGN KEY (Customer_Key) REFERENCES DimCustomer (Customer_Key),
	FOREIGN KEY (Staff_Key) REFERENCES DimStaff (Staff_Key),
	FOREIGN KEY (Item_Key) REFERENCES DimItem (Item_Key),
)
go



