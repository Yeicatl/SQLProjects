--Claning data in SQL Queries 

SELECT *
FROM SQL2022..NashvilleHousing

--Standarize Data Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM SQL2022..NashvilleHousing

-- update function and the name of the table 
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted  = CONVERT(Date,SaleDate)

--Populate property Address data

SELECT *
FROM SQL2022..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Using the parcel ID we can complete the proper address with first a JOIN function to remove the repeticion on parcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQL2022..NashvilleHousing a
JOIN SQL2022..NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQL2022..NashvilleHousing a
JOIN SQL2022..NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM SQL2022..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress)) AS City
FROM SQL2022..NashvilleHousing 

--To add the two columns that we visualize previously we need to create two new columns 

ALTER TABLE NashvilleHousing
ADD PropertyNewAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyNewAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDatdConverted;



--Other Method to separate the Owner Address using parsename thta only works with dots so we need to replace the commas with dots 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM SQL2022..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--Change Y and N to Yes or No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM SQL2022..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant
		END
FROM SQL2022..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant
		END

--Remove Duplicates writing a CTE
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			   UniqueID
			   ) row_num
FROM SQL2022..NashvilleHousing
----ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--Delete Unused columns

SELECT *
FROM SQL2022..NashvilleHousing

ALTER TABLE SQL2022..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE SQL2022..NashvilleHousing
DROP COLUMN SaleDate
 