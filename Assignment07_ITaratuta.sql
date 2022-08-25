--*************************************************************************--
-- Title: Assignment07
-- Author: ITaratuta
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-08-24,ITaratuta,Created DB, Created code to answer questions 1-8
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_ITaratuta')
	 Begin 
	  Alter Database [Assignment07DB_ITaratuta] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_ITaratuta;
	 End
	Create Database Assignment07DB_ITaratuta;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_ITaratuta;

--Use master;
--Drop Database Assignment07DB_ITaratuta;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
--Select * From vCategories;
--go
--Select * From vProducts;
--go
--Select * From vEmployees;
--go
--Select * From vInventories;
--go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

--Select [ProductName]
--		,[UnitPrice]
--From [dbo].[vProducts]
--Order by 1

--Select [ProductName]
--		,[UnitPrice] = FORMAT ([UnitPrice], 'C', 'en-us')
--From [dbo].[vProducts] ---- working without alias
--Order by 1

Select p1.[ProductName]
		,[UnitPrice] = FORMAT (p1.[UnitPrice], 'C', 'en-us')
From [dbo].[vProducts] as p1
Order by 1;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

--Select c1.[CategoryName]
--		,p1.[ProductName]
--From [dbo].[vProducts] as p1
--Join [dbo].[vCategories] as c1
--On	p1.[CategoryID] = c1.[CategoryID]
--Order by 1,2

Select c1.[CategoryName]
		,p1.[ProductName]
		,[UnitPrice] = FORMAT (p1.[UnitPrice], 'C', 'en-us')
From [dbo].[vProducts] as p1
-- Left Inner Join vProducts on the left because FK CategoryID can be NULL
-- want to list all products regardless of category 
Join [dbo].[vCategories] as c1
On	p1.[CategoryID] = c1.[CategoryID]
Order by 1,2;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--Select p1.[ProductName]
--		,v1.[InventoryDate] 
--		,v1.[Count]
--From [dbo].[vProducts] as p1
--Join [dbo].[vInventories] as v1
--On p1.[ProductID] = v1.[ProductID]
--Order by 1,2

--Select p1.[ProductName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ',' + STR (YEAR(v1.[InventoryDate]))
--		,v1.[Count] -- need column name
--From [dbo].[vProducts] as p1
--Join [dbo].[vInventories] as v1
--On p1.[ProductID] = v1.[ProductID]
--Order by 1,2 -- not sorted by date

--Select p1.[ProductName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ',' + STR (YEAR(v1.[InventoryDate]))
	--may use the same function, adding space after comma
--		,[InventoryCount] = v1.[Count]
--From [dbo].[vProducts] as p1
--Join [dbo].[vInventories] as v1
--On p1.[ProductID] = v1.[ProductID]
--Order by 1,CAST ([InventoryDate] as date)

Select p1.[ProductName]
		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
		,[InventoryCount] = v1.[Count]
From [dbo].[vProducts] as p1
Join [dbo].[vInventories] as v1
On p1.[ProductID] = v1.[ProductID]
Order by 1,CAST ([InventoryDate] as date);
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Create View vProductInventories
As
	Select Top 1000000
		p1.[ProductName]
		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
		,[InventoryCount] = v1.[Count]
	From [dbo].[vProducts] as p1
	Join [dbo].[vInventories] as v1
	On p1.[ProductID] = v1.[ProductID]
	Order by 1,CAST ([InventoryDate] as date);
go

--Check that it works: 
Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product?? (Category name instead) and Date.

--Create View vCategoryInventories
--As
--	Select Top 1000000
--		c1.[CategoryName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
--		,[InventoryCount] = v1.[Count] -- need to group by catergory name, date
--	From [dbo].[vProducts] as p1
--	Join [dbo].[vInventories] as v1
--	On p1.[ProductID] = v1.[ProductID]
--	Join [dbo].[vCategories] as c1 - need to list Categoies first (in case there is no Products)
--	On p1.[CategoryID] = c1.[CategoryID]
--	Order by p1.[ProductID], [InventoryDate] -- need to cast as date

Create OR Alter View vCategoryInventories
As
	Select Top 1000000
		c1.[CategoryName]
		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
		,[InventoryCountByCategory] = SUM (v1.[Count])
	From [dbo].[vCategories] as c1
	Join [dbo].[vProducts] as p1
	On c1.[CategoryID] = p1.[CategoryID]
	Join [dbo].[vInventories] as v1
	On p1.[ProductID] = v1.[ProductID]
	Group by c1.[CategoryName], [InventoryDate]
	Order by c1.[CategoryName], CAST ([InventoryDate] as date);
go

-- Check that it works:
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

--ISNULL (
--	IIF ((MONTH ([InventoryDate]) LIKE 'January'),
--								(LAG (v1.[InventoryDate])
--								OVER (Order by p1.[ProductName], v1.[InventoryDate]))
--								,0)
----								, 0)

--Create OR Alter View vProductInventoriesWithPreviousMonthCounts
--As
--	Select Top 1000000 -- Operand type clash: int is incompatible with date	`
--		p1.[ProductName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
--		,[InventoryCount] = v1.[Count]
		
--	From [dbo].[vProducts] as p1
--	Join [dbo].[vInventories] as v1
--	On p1.[ProductID] = v1.[ProductID]
--	Order by 1, CAST([InventoryDate] as date);

--Create OR Alter View vProductInventoriesWithPreviousMonthCounts
--As
--	Select Top 1000000 -- Operand type clash: int is incompatible with date	`
--		p1.[ProductName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
--		,[InventoryCount] = v1.[Count]
--		,[PreviousMonthCount] = LAG (v1.[InventoryDate]) - need last count not date
--								OVER (Order by v1.[InventoryDate], p1.[ProductName]) -- sort by name like last line
--	From [dbo].[vProducts] as p1
--	Join [dbo].[vInventories] as v1
--	On p1.[ProductID] = v1.[ProductID]
--	Order by 1, CAST([InventoryDate] as date);

--Create OR Alter View vProductInventoriesWithPreviousMonthCounts
--As
--	Select Top 1000000 -- Operand type clash: int is incompatible with date	`
--		p1.[ProductName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
--		,[InventoryCount] = v1.[Count]
--		,[PreviousMonthCount] = LAG (v1.[Count])
--								OVER (Order by p1.[ProductName], (CAST([InventoryDate] as date)))
--	From [dbo].[vProducts] as p1
--	Join [dbo].[vInventories] as v1
--	On p1.[ProductID] = v1.[ProductID]
--	Order by 1, CAST([InventoryDate] as date);

--(DATENAME (mm,v1.[InventoryDate]) LIKE 'January')

--Create OR Alter View vProductInventoriesWithPreviousMonthCounts
--As
--	Select Top 1000000 -- Operand type clash: int is incompatible with date	`
--		p1.[ProductName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
--		,[InventoryCount] = v1.[Count]
--		,[PreviousMonthCount] = ISNULL (
--								LAG (v1.[Count])
--								OVER (Order by p1.[ProductName], (CAST([InventoryDate] as date)))
--								, 0) -- Need to set JANUARY NULL to zero
--	From [dbo].[vProducts] as p1
--	Join [dbo].[vInventories] as v1
--	On p1.[ProductID] = v1.[ProductID]
--	Order by 1, CAST([InventoryDate] as date);

--Select MONTH ([InventoryDate]) from [dbo].[vInventories];

--Create OR Alter View vProductInventoriesWithPreviousMonthCounts
--As
--	Select Top 1000000 -- Operand type clash: int is incompatible with date	`
--		p1.[ProductName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
--		,[InventoryCount] = v1.[Count]
--		,[PreviousMonthCount] = IIF (
--								(((MONTH (v1.[InventoryDate])) = 1) AND (v1.[Count] IS NULL))		--condition
--								, 0																	--value_if_true
--								, (LAG (v1.[Count])
--								OVER (Order by p1.[ProductName], (CAST([InventoryDate] as date))))	--value_if_false
--								)
--	From [dbo].[vProducts] as p1
--	Join [dbo].[vInventories] as v1
--	On p1.[ProductID] = v1.[ProductID]
--	Order by 1, CAST([InventoryDate] as date); --First PreviousMonthCount is NULL

--Create OR Alter View vProductInventoriesWithPreviousMonthCounts
--As
--	Select Top 1000000
--		p1.[ProductName]
--		,[InventoryDate] = DATENAME (mm,v1.[InventoryDate]) + ', ' + DATENAME (yy,(v1.[InventoryDate]))
--		,[InventoryCount] = v1.[Count]
--		,[PreviousMonthCount] = IIF (
--					(LAG (v1.[Count])
--					OVER (Order by p1.[ProductName], (CAST([InventoryDate] as date))))
--					IS NULL AND ((MONTH (v1.[InventoryDate])) = 1)						--condition
--					, 0																	--value_if_true
--					,(LAG (v1.[Count])
--					OVER (Order by p1.[ProductName], (CAST([InventoryDate] as date))))	--value_if_false
--					)								
--	From [dbo].[vProducts] as p1
--	Join [dbo].[vInventories] as v1
--	On p1.[ProductID] = v1.[ProductID]
--	Order by 1, CAST([InventoryDate] as date); -- cast to sort by date instead of sort by string

Create OR Alter View vProductInventoriesWithPreviousMonthCounts
As
	Select Top 1000000
		[ProductName]
		,[InventoryDate]
		,[InventoryCount]
		,[PreviousMonthCount] = IIF (
					(LAG ([InventoryCount])
					OVER (Order by [ProductName], (CAST([InventoryDate] as date))))
					IS NULL AND ((MONTH ([InventoryDate])) = 1)						--condition
					, 0																--value_if_true
					,(LAG ([InventoryCount])
					OVER (Order by [ProductName], (CAST([InventoryDate] as date))))	--value_if_false
					)								
	From vProductInventories
	Order by 1, CAST([InventoryDate] as date); -- cast to sort by date instead of sort by string
go

-- Check that it works:
Select * From vProductInventoriesWithPreviousMonthCounts;
go
--Select * From vProductInventoriesWithPreviousMonthCounts Order by [PreviousMonthCount] Asc;

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
	Select Top 1000000
		[ProductName]
		,[InventoryDate]
		,[InventoryCount]
		,[PreviousMonthCount]
		,[CountVsPreviousCountKPI] = ISNULL (
									Case
									When [InventoryCount] > [PreviousMonthCount] Then 1
									When [InventoryCount] = [PreviousMonthCount] Then 0
									When [InventoryCount] < [PreviousMonthCount] Then -1
									End
									, 0)
	From vProductInventoriesWithPreviousMonthCounts
	Order by 1, CAST([InventoryDate] as date); -- cast to sort by date instead of sort by string
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
-- Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs Order by [CountVsPreviousCountKPI] Asc;

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs (@kpi int)
Returns Table
As
	--Begin -- cannot use begin with simple table value function, @t1 can use begin
Return
	Select [ProductName]
	,[InventoryDate]
	,[InventoryCount]
	,[PreviousMonthCount]
	,[CountVsPreviousCountKPI]
	From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where [CountVsPreviousCountKPI] = @kpi
	--End -- cannot use end with simple table value function, @t1 can use end
go

/* Check that it works:*/
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/