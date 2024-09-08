/*

Cleaning data in SQL Queries

*/


Select *
From nashville_data.dbo.Nashville_data

---------------------------------------------------------------

--Standardize Data Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From nashville_data.dbo.Nashville_data


Update nashville_data.dbo.Nashville_data
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE nashville_data.dbo.Nashville_data
Add SaleDateConverted Date;

Update nashville_data.dbo.Nashville_data
SET SaleDateConverted=CONVERT(Date,SaleDate)

---------------------------------------------------------------

--Populate Property Adress data

Select *
From nashville_data.dbo.Nashville_data
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashville_data.dbo.Nashville_data a
Join nashville_data.dbo.Nashville_data b
on a.ParcelID=b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is  null


Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashville_data.dbo.Nashville_data a
JOIN nashville_data.dbo.Nashville_data b
on a.ParcelID=b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-----------------------------------------------------------------------
--Breaking out Address into Individual Columns(Address,City,State)

Select PropertyAddress
From nashville_data.dbo.Nashville_data
--Where PropertyAddress is null
order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
--CHARINDEX(',',PropertyAddress) gives the position of comma hence -1 to display string before the comma
From nashville_data.dbo.Nashville_data

ALTER TABLE nashville_data.dbo.Nashville_data
Add PropertySplitAddress nvarchar(255);

Update nashville_data.dbo.Nashville_data
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashville_data.dbo.Nashville_data
Add PropertySplitCity nvarchar(255);

Update nashville_data.dbo.Nashville_data
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
From nashville_data.dbo.Nashville_data


SELECT OwnerAddress
From nashville_data.dbo.Nashville_data

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From nashville_data.dbo.Nashville_data


ALTER TABLE nashville_data.dbo.Nashville_data
Add OwnerSplitAddress nvarchar(255);

Update nashville_data.dbo.Nashville_data
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE nashville_data.dbo.Nashville_data
Add OwnerSplitCity nvarchar(255);

Update nashville_data.dbo.Nashville_data
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE nashville_data.dbo.Nashville_data
Add OwnerSplitState nvarchar(255);

Update nashville_data.dbo.Nashville_data
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT *
From nashville_data.dbo.Nashville_data


--------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From nashville_data.dbo.Nashville_data
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
,Case When SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
Else SoldAsVacant
END
From nashville_data.dbo.Nashville_data

Update nashville_data.dbo.Nashville_data
SET SoldAsVacant=Case When SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
Else SoldAsVacant
END


---------------------------------------------------------------------------

--Remove Duplicates
--Removing data from actual table is not a good practice instead create query for a temp table and delete data from there

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
				 )row_num
	
From nashville_data.dbo.Nashville_data
--Order by ParcelID
)

/*
WE RUN THIS QUERY TO DELETE ALL DUPLICATE AND THEN VIEW AGAIN USING THE BELOW COMMAND
DELETE
From RowNumCTE
WHERE row_num>1
--Order by PropertyAddress
*/


Select *
From RowNumCTE
WHERE row_num>1
--Order by PropertyAddress

Select *
From nashville_data.dbo.Nashville_data



---------------------------------------------------------------------------

--Delete Unused Columns



