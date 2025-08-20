use Shipping
go 

select * from Shipment_data

-- 1. Which mode of shipment is is most frequently used?
select 
    Mode_of_Shipment, 
    count(*) as Shipment_Count 
from Shipment_data
group by Mode_of_Shipment
order by Shipment_Count desc;

-- 2. What is the customers gender distribution?

select 
    Gender, 
    count(*) as Shipment_Count 
from Shipment_data
group by Gender
order by Shipment_Count desc;


-- 3. Which mode of shipment is the most efficient?

-- late deliveries
select 
    Mode_of_Shipment,
    count(*) as Late_deliveries,
    count(*) * 100.0 / (select count(*) from Shipment_data where Reached_on_Time_Y_N = 'Not on time') Percentage_of_total_late
from Shipment_data
where Reached_on_Time_Y_N = 'Not on time'
group by Mode_of_Shipment
order by Late_deliveries asc;

-- on time deliveries
select 
    Mode_of_Shipment,
    count(*) as total_shipments,
    sum(case when Reached_on_Time_Y_N = 'On time' then 1 else 0 end) as on_time_deliveries,
    (sum(case when Reached_on_Time_Y_N = 'On time' then 1 else 0 end) * 100.0 / count(*)) as on_time_percentage
from Shipment_data
group by Mode_of_Shipment
order by on_time_percentage desc;


-- 4. Does number of customer care calls influence customer review

select
    case
        when Customer_rating = 1 then 'Not satisfied'
        when Customer_rating = 2 then 'Poor'
        when Customer_rating = 3 then 'Fair'
        when Customer_rating = 4 then 'Good'
        when Customer_rating = 5 then 'Satisfied'
    end as Customer_satisfaction,
    Customer_care_calls, count(*) as Count
from Shipment_data
group by Customer_rating, Customer_care_calls
order by Customer_satisfaction desc;

-- 5. What is the average customer rating for each mode of shipment?

select 
    Mode_of_Shipment, 
    count(*) as shipments, 
    avg(Customer_rating) as avg_customer_rating 
from Shipment_data
group by Mode_of_Shipment
order by avg_customer_rating desc;

-- 6. Does the fastest method actually get the best ratings?

select
    Mode_of_Shipment,
    round(100 * sum(case when Reached_on_Time_Y_N = 'On time' then 1 else 0 end) / count (*), 1) as on_time_percentage,
    round(avg(Customer_rating), 2) as avg_rating
from Shipment_data
group by Mode_of_Shipment
order by avg_rating desc;

-- 7. Which shipping method yields the highest rating?

select 
    Mode_of_Shipment,
    avg(Customer_rating) as avg_rating_high_value
from Shipment_data
where Cost_of_the_Product > (select avg(Cost_of_the_Product) from Shipment_data)
group by Mode_of_Shipment
order by avg_rating_high_value desc;

-- 8. For late shipments, which mode receives the poorest ratings?

select 
    Mode_of_Shipment,
    avg(Customer_rating) as avg_rating_when_late
from Shipment_data
where Reached_on_Time_Y_N = 'Not on time'
group by Mode_of_Shipment
order by avg_rating_when_late asc;

-- 9. For on-time shipments, which mode receives the highest ratings?

select 
    Mode_of_Shipment,
    avg(Customer_rating) as avg_rating_when_timely
from Shipment_data
where Reached_on_Time_Y_N = 'On time'
group by Mode_of_Shipment
order by avg_rating_when_timely desc;

-- 10. For each mode, what's the relationship between support calls and rating?

select
    Mode_of_Shipment,
    Customer_care_calls,
    avg(Customer_rating) as avg_rating
from Shipment_data
group by Mode_of_Shipment, Customer_care_calls
order by Mode_of_Shipment, Customer_care_calls;

-- 11. Does offering a discount on a specific method lead to a higher rating?

select
    Mode_of_Shipment,
    case
        when Discount_offered = 0 then 'No Discount'
        when Discount_offered < 10 then 'Low Discount'
        when Discount_offered between 10 and 30 then 'Medium Discount'
        else 'High Discount' 
    end as discount_band,
    avg(Customer_rating) as average_rating
from Shipment_data
group by Mode_of_Shipment,
     case
        when Discount_offered = 0 then 'No Discount'
        when Discount_offered < 10 then 'Low Discount'
        when Discount_offered between 10 and 30 then 'Medium Discount'
        else 'High Discount' 
    end
order by Mode_of_Shipment, discount_band;

-- 12. For each warehouse, which mode achieves the highest rating?

with ranked_methods as (
    select
        Warehouse_block,
        Mode_of_Shipment,
        avg(Customer_rating) as average_rating,
        rank () over (partition by Warehouse_block order by avg(Customer_rating)desc) as rank
    from Shipment_data
    group by Warehouse_block, Mode_of_Shipment
)
select 
    Warehouse_block,
    Mode_of_Shipment as best_method,
    average_rating
from ranked_methods
where rank = 1
order by Warehouse_block;

-- 13. For "High" importance products, which method leads to the highest satisfaction?

select
    Mode_of_Shipment,
    avg(Customer_rating) as average_rating_high_importance
from Shipment_data
where Product_Importance = 'High'
group by Mode_of_Shipment
order by average_rating_high_importance desc;