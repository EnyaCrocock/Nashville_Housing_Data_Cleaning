-- CLEANING DATA IN SQL

-- 1. Viewing the data 
	
SELECT *
FROM Portfolio_Project..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------

-- 2. Standardise Date Format
--    We want to change the date from DATETIME to DATE

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ALTER COLUMN SaleDate DATE

----------------------------------------------------------------------------------------------------------------------------------------

-- 3. Populate Property Address data

-- Check for NULLS

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing
WHERE PropertyAddress IS NULL

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

-- Populating a.PropertyAddress with b.PropertyAdress using UPDATE & SET

UPDATE a
SET a.PropertyAddress = b.PropertyAddress
FROM Portfolio_Project..NashvilleHousing AS a
  JOIN Portfolio_Project..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
WHERE a.PropertyAddress IS NULL

-- Check if there are still NULL values or if it was done correctly

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing
WHERE PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------------------------------------------

-- 4. Breaking out PropertyAddress into Individual Columns (Address, City, State)

-- Check to see how the PropertyAddress is separated 

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing

-- Using SUBSTRING and CHARINDEX 
-- To select the Address (everything before the ',') and the City (everything after the ',') 

SELECT 
  SUBSTRING(TRIM(PropertyAddress), 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
  SUBSTRING(TRIM(PropertyAddress), CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM Portfolio_Project..NashvilleHousing

-- Adding & updating the columns to the table

ALTER TABLE Portfolio_Project..NashvilleHousing
ADD 
  PropertySplitAddress NVARCHAR(255),
  PropertySplitCity NVARCHAR(255)

UPDATE Portfolio_Project..NashvilleHousing	
SET 
  PropertySplitAddress = SUBSTRING(TRIM(PropertyAddress), 1, CHARINDEX(',', PropertyAddress) -1),
  PropertySplitCity = SUBSTRING(TRIM(PropertyAddress), CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))

----------------------------------------------------------------------------------------------------------------------------------------

-- 5. Breaking out OwnerAddress into Individual Columns (Address, City, State)

-- Check to see how the OwnerAddress is separated 

SELECT OwnerAddress
FROM Portfolio_Project..NashvilleHousing

-- Using PARSENAME to select parts of a string

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

UPDATE Portfolio_Project..NashvilleHousing
SET 
  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

----------------------------------------------------------------------------------------------------------------------------------------

-- 6. Changing Y and N to Yes and No in SoldAsVacant field

-- Check to see how many options there are and which are the most populated

SELECT 
  DISTINCT(SoldAsVacant),
  COUNT(SoldAsVacant) AS Count
FROM Portfolio_Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count

-- Updating collumn by changing all SoldAsVacant to Yes and No as they ar the most populated options

UPDATE portfolio_project..NashvilleHousing
SET    soldasvacant = CASE
                        WHEN soldasvacant LIKE 'Y' THEN 'Yes'
                        WHEN soldasvacant LIKE 'N' THEN 'No'
                        ELSE soldasvacant
                      END  

----------------------------------------------------------------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------------------------------------------------------

 -- 8. Deleting Unused Columns (Like PropertyAddress & OwnerAddress (as we have the splits))

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress