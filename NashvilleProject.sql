/*
Checks of values in data
*/

--Total Count
Select COUNT(*)
From NashvilleProject.dbo.NashvilleHousing

--Checking distinct values in landuse
Select Distinct(Landuse)
From NashvilleProject.dbo.NashvilleHousing

--Checking counts of distinct values in landuse
Select Landuse, COUNT(*) as CountLandUse
From NashvilleProject.dbo.NashvilleHousing
Group by LandUse

--Checking counts in property address
Select COUNT(PropertyAddress)
From NashvilleProject.dbo.NashvilleHousing

/*
Cleaning data is SQL Query
*/

Select *
From NashvilleProject.dbo.NashvilleHousing

--Standardize Date Format
Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From NashvilleProject.dbo.NashvilleHousing


--Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleProject.dbo.NashvilleHousing a
Join NashvilleProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleProject.dbo.NashvilleHousing a
Join NashvilleProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Splitting Address from combined to separate columns

Select PropertyAddress
From NashvilleProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as PropertySplitCity
From NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From NashvilleProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

Select *
From NashvilleProject.dbo.NashvilleHousing

--Standardizing Values in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	End
From NashvilleProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	End

--Removing Duplicates

WITH DuplicateCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID)
	Duplicate

From NashvilleProject.dbo.NashvilleHousing
)
Delete
From DuplicateCTE
Where Duplicate > 1

--Delete Unused Columns

Select *
From NashvilleProject.dbo.NashvilleHousing

Alter Table NashvilleProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

