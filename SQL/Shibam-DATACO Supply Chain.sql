-- ====================================================================
-- Database Schema Setup: Supply Chain & Logistics Performance Data
-- ====================================================================

CREATE TABLE orders_master (
    type VARCHAR(50),
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    benefit_per_order NUMERIC,
    sales_per_customer NUMERIC,
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    category_id INT,
    category_name VARCHAR(100),
    customer_city VARCHAR(100),
    customer_id INT,
    customer_name VARCHAR(150),
    customer_segment VARCHAR(50),
    customer_country VARCHAR(100),
    customer_state VARCHAR(100),
    department_id INT,
    department_name VARCHAR(100),
    latitude NUMERIC,
    longitude NUMERIC,
    market VARCHAR(50),
    order_state VARCHAR(100),
    order_customer_id INT,
    order_date DATE,
    order_id INT,
    order_item_discount NUMERIC,
    order_item_discount_rate NUMERIC,
    order_item_product_price NUMERIC,
    order_item_profit_ratio NUMERIC,
    order_item_quantity INT,
    sales NUMERIC,
    order_item_total NUMERIC,
    order_profit_per_order NUMERIC,
    order_country VARCHAR(100),
    order_region VARCHAR(100),
    order_city VARCHAR(100),
    order_status VARCHAR(50),
    product_card_id INT,
    product_category_id INT,
    product_name VARCHAR(255),
    product_price NUMERIC,
    shipping_date DATE,
    shipping_mode VARCHAR(100)
);


-- ====================================================================
-- PHASE 1 : DATA PROFILING & EXPLORATORY DATA ANALYSIS
-- ====================================================================

-- Check 1. Check total records, orders and customers
select count(*) as total_rows, count(distinct order_id) as unique_orders,
count(distinct customer_id) as unique_customers
from orders_master;


-- Check 2. Check missing values
select count(*) as total_records, 
sum(case when delivery_status is null then 1 else 0 end) as missing_delivery_status,
sum(case when order_profit_per_order is null then 1 else 0 end) as missing_profit,
sum(case when order_date is null then 1 else 0 end) as missing_order_date
from orders_master;


-- Check 3. Sales and profit summary
select min(sales) as minimum_sales,
max(sales) as maximum_sales,
round(avg(sales),2) as average_sales,
min(order_profit_per_order) as minimum_profit,
max(order_profit_per_order) as maximum_profit,
round(avg(order_profit_per_order),2) as average_profit,
sum(case when order_profit_per_order < 0 then 1 else 0 end) as negative_profit_lines,
round(sum(case when order_profit_per_order < 0 then 1 else 0 end) * 100.0 / count(*), 2) as negative_profit_pct
from orders_master;


-- Check 4. Top categories by orders
select category_name,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue
from orders_master
group by category_name
order by total_orders desc
limit 10;

-- Check 5. Sales by market
select market,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue,
round(avg(order_profit_per_order),2) as average_profit
from orders_master
group by market
order by revenue desc;


-- Check 6. Delivery status
select delivery_status,
count(distinct order_id) as total_orders,
round(count(distinct order_id) * 100.0 /
(select count(distinct order_id) from orders_master), 2) as percentage
from orders_master
group by delivery_status
order by total_orders desc;



-- Check 7. Shipping analysis
select shipping_mode, round(avg(days_for_shipment_scheduled),1) as scheduled_days,
round(avg(days_for_shipping_real),1) as actual_days,
round(avg(days_for_shipping_real) -
avg(days_for_shipment_scheduled),1) as average_delay
from orders_master
group by shipping_mode
order by actual_days desc;


-- Check 8. Profit by category
select category_name,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue,
round(sum(order_profit_per_order),2) as total_profit
from orders_master
group by category_name
order by total_profit desc;


-- Check 9. Late delivery by shipping mode
select shipping_mode,
count(distinct order_id) as total_orders,
sum(late_delivery_risk) as late_orders,
round(avg(late_delivery_risk) * 100,2) as late_delivery_percentage
from orders_master
group by shipping_mode
order by late_delivery_percentage desc;


-- Check 10. Revenue by order status
select order_status,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue
from orders_master
group by order_status
order by revenue desc;


-- ======================================================
-- PART 1 : BUSINESS OVERVIEW (BASIC ANALYSIS)
-- Objective:
-- Understand the overall business performance by analyzing
-- key sales, profit, customer, and market metrics.
-- ======================================================


-- Q1. What are the overall business KPIs?

select count(distinct order_id) as total_orders,
count(distinct customer_id) as total_customers,
round(sum(sales),2) as total_revenue,
round(sum(order_profit_per_order),2) as total_profit,
round(sum(sales) / count(distinct order_id), 2) as average_order_value,
round((sum(order_profit_per_order) / sum(sales)) * 100,2) as profit_margin_pct
from orders_master;

-- Q2. Which markets contribute the most to sales and profit?

select market,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue,
round(sum(order_profit_per_order),2) as total_profit
from orders_master
group by market
order by revenue desc;


-- Q3. Which product categories generate the highest revenue and profit?

select category_name,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue,
round(sum(order_profit_per_order),2) as total_profit
from orders_master
group by category_name
order by revenue desc;


-- Q4. How is revenue distributed across different customer segments?

select customer_segment,
count(distinct customer_id) as total_customers,
round(sum(sales),2) as revenue,
round(sum(sales) / count(distinct order_id), 2) as average_order_value,
round(sum(order_profit_per_order),2) as total_profit
from orders_master
group by customer_segment
order by revenue desc;


-- Q5. Which countries generate the highest revenue?

select order_country,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue,
round(sum(order_profit_per_order),2) as total_profit
from orders_master
group by order_country
order by revenue desc
limit 10;


-- ======================================================
-- PART 2 : OPERATIONAL PERFORMANCE ANALYSIS
-- Objective:
-- Evaluate shipping performance and identify operational
-- issues that may affect customer satisfaction and delivery
-- efficiency.
-- ======================================================

-- Q6. Which shipping mode has the highest late delivery percentage?

select shipping_mode,
count(distinct order_id) as total_orders,
sum(late_delivery_risk) as late_orders,
round(avg(late_delivery_risk) * 100,2) as late_delivery_percentage
from orders_master
group by shipping_mode
order by late_delivery_percentage desc;


-- Q7. Which markets experience the highest number of delayed deliveries?

select market,
count(distinct order_id) as total_orders,
sum(late_delivery_risk) as late_orders,
round(avg(late_delivery_risk) * 100,2) as late_delivery_percentage
from orders_master
group by market
order by late_delivery_percentage desc;


-- Q8. Which countries have the highest number of delayed deliveries?

select order_country,
count(distinct order_id) as total_orders,
sum(late_delivery_risk) as late_orders,
round(avg(late_delivery_risk) * 100,2) as late_delivery_percentage
from orders_master
group by order_country
order by late_orders desc
limit 10;


-- Q9. What is the average shipping delay for each shipping mode?

select shipping_mode,
round(avg(days_for_shipment_scheduled),1) as scheduled_days,
round(avg(days_for_shipping_real),1) as actual_days,
round(avg(days_for_shipping_real) -
avg(days_for_shipment_scheduled),1) as average_delay
from orders_master
group by shipping_mode
order by average_delay desc;


-- Q10. Does late delivery affect profitability?
select
case when late_delivery_risk = 1 then 'Late Delivery' else 'On Time' end as delivery_status,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue,
round(sum(order_profit_per_order),2) as total_profit,
round(avg(order_profit_per_order),2) as average_profit,
round((sum(order_profit_per_order) / sum(sales)) * 100, 2) as profit_margin_pct
from orders_master
group by case when late_delivery_risk = 1 then 'Late Delivery' else 'On Time' end
order by total_profit desc;


-- ======================================================

-- PART 3 : TIME-BASED BUSINESS ANALYSIS
-- Objective:
-- Analyze business performance over time to identify
-- sales trends, seasonal patterns and delivery performance.
-- ======================================================


-- Q11. Which months have the highest late delivery percentage?

select
to_char(order_date,'Month') as order_month,
count(distinct order_id) as total_orders,
sum(late_delivery_risk) as late_orders,
round(avg(late_delivery_risk) * 100,2) as late_delivery_percentage
from orders_master
group by
extract(month from order_date),
to_char(order_date,'Month')
order by late_delivery_percentage desc;


-- Q12. How have sales and profit changed over the years?

select
extract(year from order_date) as order_year,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue,
round(sum(order_profit_per_order),2) as total_profit
from orders_master
group by extract(year from order_date)
order by order_year;

-- Q13. Which months generate the highest revenue and profit?

select
trim(to_char(order_date,'Month')) as order_month,
count(distinct order_id) as total_orders,
round(sum(sales),2) as revenue,
round(sum(order_profit_per_order),2) as total_profit
from orders_master
group by
extract(month from order_date),
trim(to_char(order_date,'Month'))
order by revenue desc;


-- Q14. Which day of the week generates the highest sales and profit?

select
trim(to_char(order_date, 'Day')) as day_of_week,
count(distinct order_id) as total_orders,
round(sum(sales), 2) as revenue,
round(sum(order_profit_per_order), 2) as total_profit
from orders_master
group by
trim(to_char(order_date, 'Day'))
order by revenue desc;


-- ======================================================
--PART 4 : STRATEGIC BUSINESS ANALYSIS
-- Objective:
-- Use advanced SQL techniques such as Common Table
-- Expressions (CTEs) and Window Functions to answer
-- complex business questions and uncover deeper insights.
-- ======================================================


-- Q15. Rank the top 5 products by revenue within each market.

with product_sales as (
select market, product_name,
round(sum(sales), 2) as revenue
from orders_master
group by market, product_name
),
ranked_products as (
select market, product_name, revenue,
dense_rank() over(partition by market order by revenue desc) as revenue_rank
from product_sales
)
select market, product_name, revenue, revenue_rank
from ranked_products
where revenue_rank <= 5
order by market, revenue_rank;


-- Q16. Identify the top 10 customers based on lifetime revenue.

with customer_revenue as (
select customer_id, round(sum(sales), 2) as total_revenue
from orders_master
group by customer_id
)
select
customer_id, total_revenue,
dense_rank() over (order by total_revenue desc) as customer_rank
from customer_revenue
order by customer_rank
limit 10;


-- Q17. Calculate the running total of monthly sales.

with monthly_sales as (
select extract(year from order_date)::int as order_year,
extract(month from order_date)::int as order_month,
round(sum(sales), 2) as monthly_revenue
from orders_master
group by extract(year from order_date),
extract(month from order_date)
)
select order_year, order_month, monthly_revenue,
sum(monthly_revenue) over (
order by order_year, order_month
) as running_total_revenue
from monthly_sales;

-- Q18. Which products generate high sales but overall negative profit?
select product_name,
round(sum(sales),2) as revenue,
round(sum(order_profit_per_order),2) as total_profit
from orders_master
group by product_name
having sum(sales) > 10000
and sum(order_profit_per_order) < 0
order by revenue desc;


-- Q19. Rank markets based on their overall profitability.

with market_profit as (
select market,
round(sum(sales), 2) as total_revenue,
round(sum(order_profit_per_order), 2) as total_profit
from orders_master
group by market
),
benchmark as (
select avg(total_profit) as avg_market_profit
from market_profit
)
select mp.market, mp.total_revenue, mp.total_profit,
dense_rank() over (order by mp.total_profit desc) as market_rank,
case
when mp.total_profit >= b.avg_market_profit * 1.2 then 'High Performing'
when mp.total_profit >= b.avg_market_profit * 0.8 then 'Moderate Performing'
else 'Needs Improvement'
end as performance_category
from market_profit mp
cross join benchmark b
order by market_rank;


-- Q20. Which product categories contribute the highest percentage of total company revenue?

with category_sales as (
select category_name,
round(sum(sales),2) as revenue
from orders_master
group by category_name
)
select category_name, revenue,
round(
revenue * 100.0 /
sum(revenue) over(),2) as revenue_contribution_pct
from category_sales
order by revenue desc;