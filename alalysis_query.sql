CREATE DATABASE IF NOT EXISTS walmartSales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(10) not null,
    product_line varchar(100) not null,
    unit_price decimal(10, 2) not null,
    quantity int not null,
    vat float(6, 4) not null,
    total decimal(10, 4) not null,
    date datetime not null,
    time time not null,
    payment_method varchar(15) not null,
    cogs decimal(10, 2) not null,
    gross_margin_pct float(11, 9) not null,
    gross_income decimal(12, 4) not null,
    rating decimal(2, 1) not null
);

-- ----------------------------------------------------------------------------------------------
-- ------------------------------------ Feature Engineering -------------------------------------

-- time_of_day

select
	time,
    (
	case
		when time between '00:00:00' and '12:00:00' then "Morning"
        when time between '12:01:00' and '16:00:00' then "Afternoon"
        else "Evening"
	end
    ) as "time_of_day"
from sales;

alter table sales add column time_of_day varchar(20);

update sales 
set time_of_day = (
	case
		when time between '00:00:00' and '12:00:00' then "Morning"
        when time between '12:01:00' and '16:00:00' then "Afternoon"
        else "Evening"
	end
);
-- ----------------------------------------------------------------------------------------------

-- day_name

select date, substring(dayname(date), 1, 3) as day_name
from sales;

alter table sales add column day_name varchar(3);

update sales
set day_name = substring(dayname(date), 1, 3);

-- ----------------------------------------------------------------------------------------------

-- month_name

select date, substring(monthname(date), 1, 3) as month_name
from sales;

alter table sales add column month_name varchar(3);

update sales
set month_name = substring(monthname(date), 1, 3);

-- ----------------------------------------------------------------------------------------------
-- ----------------------------- Generic Question -----------------------------------------------

-- How many unique cities does the data have?
select distinct city
from sales;

-- In which city is each branch?

select distinct branch
from sales;

select distinct city, branch
from sales;

-- ----------------------------------------------------------------------------------------------
-- -------------------------------------- Product -----------------------------------------------

-- How many unique product lines does the data have?

select count(distinct product_line) as "no of product line"
from sales;

-- What is the most common payment method?

select payment_method, count(payment_method) as "Count"
from sales
group by payment_method
order by Count desc;

-- ----------------------------------------------------------------------------------------------

-- What is the most selling product line?

select distinct product_line, count(product_line) as cnt
from sales
group by product_line
order by cnt desc limit 1;

-- ----------------------------------------------------------------------------------------------

-- What is the total revenue by month?

select month_name as Month, sum(total) as Total_Revenue
from sales
group by month_name
order by Total_Revenue desc;

-- ----------------------------------------------------------------------------------------------

-- What month had the largest COGS?

select month_name, sum(cogs) as total_cogs
from sales
group by month_name
order by total_cogs desc;

-- ----------------------------------------------------------------------------------------------

-- What product line had the largest revenue?

select product_line, sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc limit 1;

-- ----------------------------------------------------------------------------------------------

-- What is the city with the largest revenue?

select city, sum(total) as total_revenue
from sales
group by city
order by total_revenue desc limit 1;

-- ----------------------------------------------------------------------------------------------

-- What product line had the largest VAT?

select product_line, avg(vat) as avg_tax
from sales
group by product_line
order by avg_tax desc limit 1;

-- ----------------------------------------------------------------------------------------------

-- Fetch each product line and add a column to those product line showing "Good", "Bad".
-- Good if its greater than average sales

select avg(quantity) as avg_qnty
from sales;

select product_line, case
						when avg(quantity) > (select avg(quantity) from sales) then "Good"
                        else "Bad"
					 end as remark
from sales
group by product_line;

select product_line, avg(quantity) as avg_qnty
from sales
group by product_line;

-- ----------------------------------------------------------------------------------------------

-- Which branch sold more products than average product sold?

select branch, sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- ----------------------------------------------------------------------------------------------

-- What is the most common product line by gender?

select gender, product_line, count(product_line) as total_cnt
from sales
group by gender, product_line
order by total_cnt desc;

-- ----------------------------------------------------------------------------------------------

-- What is the average rating of each product line?

select product_line, avg(rating) as avg_rating
from sales
group by product_line
order by avg_rating desc;

-- ----------------------------------------------------------------------------------------------
-- ---------------------------------------- Sales -----------------------------------------------

-- Number of sales made in each time of the day per weekday

select time_of_day, count(invoice_id) as total_sales
from sales
where day_name = 'Sun'
group by time_of_day;

-- ----------------------------------------------------------------------------------------------

-- Which of the customer types brings the most revenue?

select customer_type, sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc;

-- ----------------------------------------------------------------------------------------------

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

select city, avg(vat) as vat
from sales
group by city
order by vat desc;

-- ----------------------------------------------------------------------------------------------

-- Which customer type pays the most in VAT?

select customer_type, avg(vat) as vat
from sales
group by customer_type
order by vat desc;

-- ----------------------------------------------------------------------------------------------
-- ------------------------------------------ Customer ------------------------------------------

-- How many unique customer types does the data have?

select distinct customer_type
from sales;

-- ----------------------------------------------------------------------------------------------

-- How many unique payment methods does the data have?

select distinct payment_method
from sales;

-- ----------------------------------------------------------------------------------------------

-- What is the most common customer type?

select customer_type, count(invoice_id) as count
from sales
group by customer_type
order by count desc;

-- ----------------------------------------------------------------------------------------------

-- Which customer type buys the most?

select customer_type, count(invoice_id) as cstm_cnt
from sales
group by customer_type;

-- ----------------------------------------------------------------------------------------------

-- What is the gender of most of the customers?

select gender, count(invoice_id) as no_of_cstm
from sales
group by gender;

-- ----------------------------------------------------------------------------------------------

-- What is the gender distribution per branch?

select gender, count(invoice_id) as no_of_cstm
from sales
where branch = 'A'
group by gender;

-- ----------------------------------------------------------------------------------------------

-- Which time of the day do customers give most ratings?

select time_of_day, avg(rating) as ratings
from sales
group by time_of_day
order by ratings desc;

-- ----------------------------------------------------------------------------------------------

-- Which time of the day do customers give most ratings per branch?

select time_of_day, avg(rating) as ratings
from sales
where branch = "C"
group by time_of_day
order by ratings desc;

-- ----------------------------------------------------------------------------------------------

-- Which day of the week has the best avg ratings?

select day_name, avg(rating) as avg_ratings
from sales
group by day_name
order by avg_ratings desc;

-- ----------------------------------------------------------------------------------------------

-- Which day of the week has the best average ratings per branch?

select day_name, avg(rating) as avg_ratings
from sales
where branch = "A"
group by day_name
order by avg_ratings desc;

-- ----------------------------------------------------------------------------------------------