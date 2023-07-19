drop table if exists nashville_housing;
create table nashville_housing(
"unique_id" numeric,
"parcel_id" varchar,
"land_use" text,
"property_address" varchar,
"sale_date" date,
"sale_price" numeric,
"legal_reference" varchar,
"sold_as_vacant" text,
"owner_name" varchar,
"owner_address" varchar,
"acreage" numeric,
"tax_district" text,
"land_value" numeric,
"building_value" numeric,
"total_value" numeric,
"year_built" numeric,
"bedrooms" numeric,
"full_bath" numeric,
"half_bath" numeric
);
select *
from nashville_housing;
-- where property_address <> '410  ROSEHILL CT, GOODLETTSVILLE'

-- select a.unique_id, a.parcel_id, a.property_address, b.parcel_id, b.property_address
-- from nashville_housing a
-- join nashville_housing b
-- 	on a.parcel_id = b.parcel_id and
-- 	a.unique_id <> b.unique_id
-- where a.property_address is null;

update nashville_housing
set property_address = b.property_address
from nashville_housing a
join nashville_housing b
	 on a.parcel_id = b.parcel_id
  	 AND a.unique_id <> b.unique_id
WHERE nashville_housing.property_address IS NULL
  AND nashville_housing.parcel_id = b.parcel_id
  AND nashville_housing.unique_id <> b.unique_id;
  
SELECT SUBSTRING(property_address, 1, POSITION(',' IN property_address) - 1), 
SUBSTRING(property_address, POSITION(',' IN property_address) + 1, length(property_address))
FROM nashville_housing;

alter table nashville_housing
add split_property_address varchar;

update nashville_housing
set split_property_address = SUBSTRING(property_address, 1, POSITION(',' IN property_address) - 1)

alter table nashville_housing
add split_property_city varchar;

update nashville_housing
set split_property_city = SUBSTRING(property_address, POSITION(',' IN property_address) + 1, length(property_address))

select split_part(owner_address, ',', 1)
,split_part(owner_address, ',', 2),
split_part(owner_address, ',', 3)
from nashville_housing

alter table nashville_housing
add split_owner_address varchar;

update nashville_housing
set split_owner_address = split_part(owner_address, ',', 1)

alter table nashville_housing
add split_owner_city varchar;

update nashville_housing
set split_owner_city = split_part(owner_address, ',', 2)

alter table nashville_housing
add split_owner_state varchar;

update nashville_housing
set split_owner_state = split_part(owner_address, ',', 3)

select sold_as_vacant, count(sold_as_vacant)
from nashville_housing
group by sold_as_vacant
order by 2

select
	case when sold_as_vacant = 'Y' then 'Yes'
		 when sold_as_vacant = 'N' then 'No'
		 else sold_as_vacant
	end
from nashville_housing

update nashville_housing
set sold_as_vacant = case when sold_as_vacant = 'Y' then 'Yes'
		 when sold_as_vacant = 'N' then 'No'
		 else sold_as_vacant
	end;

WITH duplicates AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY parcel_id, property_address, sale_price, sale_date, legal_reference
      ORDER BY unique_id
    ) AS row_num
  FROM nashville_housing
)
-- select *
-- from duplicates
-- where row_num > 1
DELETE FROM nashville_housing
WHERE (parcel_id, property_address, sale_price, sale_date, legal_reference, unique_id) IN (
  SELECT parcel_id, property_address, sale_price, sale_date, legal_reference, unique_id
  FROM duplicates
  WHERE row_num > 1
);


	
	
	