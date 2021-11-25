# SQL Data Cleaning Project


#### 💡 Inspiration 
- While searching for ideas for portfolio projects I found Alex Freberg's [Data Analyst Portfolio Porject Series](https://www.youtube.com/watch?v=8rO7ztF4NtU), which I decided to follow.

---

#### ✍🏼 The Objective
- Cleaning a Nashville Real Estate dataset on SQL.

#### 📈 The Dataset 
-  [Click Here](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx)

#### 💻 Tools Used
- Data Cleaning = Microsoft SQL Server. 

#### 🔗 Links
- SQL Code =

---

# SQL Data Cleaning

## Downloading and Importing Data

- After downloading the dataset from [here](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx) we import the .xlsx file into SQL Server.
    
  ![image](https://user-images.githubusercontent.com/94410139/143484788-72d7767b-d098-46df-9467-f80bc5253f6f.png)


## SQL Server Queries

  ```sql
  -- 1. Viewing the data 
	
  SELECT *
  FROM Portfolio_Project..NashvilleHousing
  ```
  ![image](https://user-images.githubusercontent.com/94410139/143485552-e5be482d-8972-48af-814e-1529d1780abe.png)

  ```sql
  -- 2. Standardize Date Format
  --    We want to change the date from DATETIME to DATE

  ALTER TABLE Portfolio_Project.dbo.nashville_housing
  ALTER COLUMN SaleDate DATE
  ```

![image](https://user-images.githubusercontent.com/94410139/143485827-9a26f16f-188d-4121-ad02-fe8928b8a006.png) 
![image](https://user-images.githubusercontent.com/94410139/143486657-0afd3043-1abb-4c22-a380-a6a389995278.png)

  ```sql
  -- 3. Populate Property Address data

  -- Check for NULLS
  SELECT PropertyAddress
  FROM Portfolio_Project..nashville_housing
  WHERE PropertyAddress IS NULL
