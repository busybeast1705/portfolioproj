--veiwing the dataset
select *
from housing

--standardising the sale date using alter command
alter table housing
alter column SaleDate date


--populating the property address
select *
from housing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from housing a
join housing b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--updating the property address
update a
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from housing a
join housing b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--a better way of updating the property address is by dropping the original one and renaming the derived one as property address



--breaking out address into individual columns as city address and state

select PropertyAddress
from housing 
order by ParcelID

select SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as address
from housing

--adding both the parts into the SQL table
alter table housing
add PropertySplitAddress nvarchar(255);

update housing
set PropertySplitAddress =  SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

alter table housing
add PropertyCity nvarchar(255);

update housing
set PropertyCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) 


--if you want to drop the original property address column
--alter table housing
--drop column PropertyAddress

select *
from housing


--similarly changing the owner address 

select OwnerAddress
from housing

Select PARSENAME(Replace(OwnerAddress,',','.'),3),PARSENAME(Replace(OwnerAddress,',','.'),2),PARSENAME(Replace(OwnerAddress,',','.'),1)
from housing


alter table housing
add OwnerSplitAddress nvarchar(255);

update housing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)  

alter table housing
add OwnerCity nvarchar(255);

update housing
set OwnerCity = PARSENAME(Replace(OwnerAddress,',','.'),2) 

alter table housing
add OwnerState nvarchar(255);

update housing
set  OwnerState=  PARSENAME(Replace(OwnerAddress,',','.'),1)


select *
from housing

--we can do the same thing using substring but it will be cumbersome, it is good to use parsename when there are multiple delimiters




--change Y and N to yes and no in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from housing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
when SoldAsVacant= 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from housing


Update housing
set SoldAsVacant = case
when SoldAsVacant= 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end



--remove the duplicates(not recommended to delete it using SQL)

with CTE_RowNum AS(
select *, ROW_NUMBER() over (
partition by ParcelID,PropertyAddress,SalePrice,SaleDate, LegalReference
order by UniqueID) as row_num
from housing
--order by ParcelID
)

--select *
--from CTE_RowNum
--WHERE row_num > 1
--ORDER BY PropertyAddress
DELETE
from CTE_RowNum
WHERE row_num > 1


--delete unused columns(not recommended to do on raw data)
select *
from housing


alter table housing
drop column OwnerAddress,PropertyAddress,TaxDistrict



