/*
Cleaning Data in SQL Queries
*/

Select *
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing




-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing


Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data


Select *
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing a
JOIN SQL_Cleaning_Data_Project.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing a
JOIN SQL_Cleaning_Data_Project.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);


Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);


Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Looking at the split columns I just did in the before alter and update statements at the end of the query in new columns


SELECT *
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing


------------------------------------Splitting the OwnerAddress column into multiple columns

SELECT OwnerAddress
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
	,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
	,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--Looking at the split columns I just did in the before alter and update statements at the end of the query in new columns
SELECT *
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(soldasvacant)
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


SELECT SoldAsVacant
		, case when SoldAsVacant = 'y' then 'Yes'
				when SoldAsVacant = 'n' then 'No'
				else SoldAsVacant
				end
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = case when SoldAsVacant = 'y' then 'Yes'
				when SoldAsVacant = 'n' then 'No'
				else SoldAsVacant
				end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumcte as( 
	SELECT *,
			row_number() over(
			partition by parcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
							order by uniqueId) row_num		
						
								
	FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing)
	--order by ParcelID)

DELETE 
FROM RowNumcte
WHERE row_num >1
--order by PropertyAddress


SELECT *
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM SQL_Cleaning_Data_Project.dbo.NashvilleHousing

ALTER TABLE SQL_Cleaning_Data_Project.dbo.NashvilleHousing
DROP COLUMN ownerAddress, TaxDistrict, PropertyAddress

ALTER TABLE SQL_Cleaning_Data_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate
