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

--- 
  ```sql
  -- 2. Standardising Date Format
  --    We want to change the date from DATETIME to DATE

  ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
  ALTER COLUMN SaleDate DATE
  ```

![image](https://user-images.githubusercontent.com/94410139/143485827-9a26f16f-188d-4121-ad02-fe8928b8a006.png) 
![image](https://user-images.githubusercontent.com/94410139/143486657-0afd3043-1abb-4c22-a380-a6a389995278.png)

---

  ```sql
-- 3. Populating Property Address data

-- Check for NULLS

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing
WHERE PropertyAddress IS NULL

/* In the dataset there are various properties that have the same ParcelID but 
   differ in UniqueIDs, when that happens there are times when only one of the 
   properties has the PropertyAddress populated */

-- SELF JOIN to check NULLS for properties with same ParcelID and different UniqueID

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress
FROM Portfolio_Project..NashvilleHousing AS a
    JOIN Portfolio_Project..NashvilleHousing AS b
	  ON a.ParcelID = b.ParcelID
	  AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL
```
![image](https://user-images.githubusercontent.com/94410139/143587037-a1b48e62-874b-40d5-9df9-3d152e6ba51d.png)

 ```sql
 -- Populating a.PropertyAddress with b.PropertyAddress

UPDATE a
SET a.PropertyAddress = b.PropertyAddress
FROM Portfolio_Project..NashvilleHousing AS a
   JOIN Portfolio_Project..NashvilleHousing AS b
     ON a.ParcelID = b.ParcelID
     AND a.UniqueID  <> b.UniqueID 
WHERE a.PropertyAddress IS NULL
```
---

```sql
-- 4. Breaking out PropertyAddress into Individual Columns (Address, City)

-- Check to see how the PropertyAddress is separated 
-- It is separated with a ','

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing

-- Using SUBSTRING and CHARINDEX 
-- To select the Address (everything before the ',') and the City (everything after the ',') 

SELECT 
  SUBSTRING(TRIM(PropertyAddress), 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
  SUBSTRING(TRIM(PropertyAddress), CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM Portfolio_Project..NashvilleHousing
```
![image](https://user-images.githubusercontent.com/94410139/143602740-0967f55d-068d-454c-8457-cba2f14411ef.png)

```sql
-- Adding & updating the columns to the table

ALTER TABLE Portfolio_Project..NashvilleHousing
ADD 
  PropertySplitAddress NVARCHAR(255),
  PropertySplitCity NVARCHAR(255)

UPDATE Portfolio_Project..NashvilleHousing	
SET 
  PropertySplitAddress = SUBSTRING(TRIM(PropertyAddress), 1, CHARINDEX(',', PropertyAddress) -1),
  PropertySplitCity = SUBSTRING(TRIM(PropertyAddress), CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))
```
![image](https://user-images.githubusercontent.com/94410139/143604030-54af6ed5-d9bd-4344-b1b8-9af685b4e153.png)

---
```sql
-- 5. Breaking out OwnerAddress into Individual Columns (Address, City, State)

-- Check to see how the OwnerAddress is separated 

SELECT OwnerAddress
FROM Portfolio_Project..NashvilleHousing

-- Using PARSENAME
-- This allows us to get different parts of a string, when they are delimited by a '.'
-- So we have to replace the ','
-- It starts backwards, so a 1 will extract the ending of the string 

SELECT 
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM Portfolio_Project..NashvilleHousing

-- Adding & updating the columns to the table

ALTER TABLE Portfolio_Project..NashvilleHousing
ADD 
  OwnerSplitAddress NVARCHAR(255),
  OwnerSplitCity NVARCHAR(255),
  OwnerSplitState NVARCHAR(255)

UPDATE portfolio_project..nashvillehousing
SET
  ownersplitaddress = Parsename(Replace(owneraddress, ',', '.'), 3),
  ownersplitcity = Parsename(Replace(owneraddress, ',', '.'), 2),
  ownersplitstate = Parsename(Replace(owneraddress, ',', '.'), 1)  
```
![image](https://user-images.githubusercontent.com/94410139/143605705-35e8b189-cc70-43a9-a69c-265d42bb7166.png)

---
```sql
-- 6. Changing Y and N to Yes and No in SoldAsVacant field

-- Check to see how many options there are and which are the most populated

SELECT 
  DISTINCT(SoldAsVacant),
  COUNT(SoldAsVacant) AS Count
FROM Portfolio_Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count
```
![image](https://user-images.githubusercontent.com/94410139/143606474-10d8b26d-a2e5-4f87-b934-e821d9addf1c.png)

```sql
-- Updating column by changing all SoldAsVacant to Yes and No as they are the most populated options

UPDATE portfolio_project..NashvilleHousing
SET    soldasvacant = CASE
                        WHEN soldasvacant LIKE 'Y' THEN 'Yes'
                        WHEN soldasvacant LIKE 'N' THEN 'No'
                        ELSE soldasvacant
                      END  
```
![image](https://user-images.githubusercontent.com/94410139/143608014-232cf0ad-4e25-4beb-950a-df8c6cf97a11.png)

---

```sql
-- 7. Removing Duplicates

-- Using a CTE + ROW_NUMBER to find duplicates

WITH RowNumCTE AS
(
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY ParcelID) AS RowNumber
  FROM Portfolio_Project..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE RowNumber > 1

-- there are 104 duplicates
```
![image](https://user-images.githubusercontent.com/94410139/143610772-72c79067-f393-4909-bf72-55d234de6742.png)

```sql
-- Deleting the duplicates from the CTE

WITH RowNumCTE AS
(
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY ParcelID) AS RowNumber
  FROM Portfolio_Project..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE RowNumber > 1
```
---
```sql
 -- 7. Deleting Unused Columns (Like PropertyAddress & OwnerAddress as we have the splits)

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress
```
