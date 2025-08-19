# E-Commerce Order Insights 

# Description:
This project aims to analyze and clean the Brazilian E-Commerce Public Dataset (from Kaggle) to make it ready for business insights. The data has been processed using SQL to create a consolidated table for easy management and reporting. The main focus of this project 
is to study order trends, delivery performance, customer distribution by state, and product category sales.

---

## Dataset Overview

The dataset contains e-commerce transactions from Brazil, including:

- **Orders** – purchase date, delivery date, status
- **Order Items** – products, prices, sellers
- **Products** – product categories and metadata
- **Customers** – location info (state, city)
- **Payments** – payment type, installments, value

---

## What I Did

1. **Data Cleaning**
   - Removed duplicates
   - Converted timestamps into proper `DATE` format
   - Standardized delivery delays calculation

2. **New Columns / Business Logic**
   - `delayed_delivery` → flag if the order was delivered after estimated date
   - Extracted **order_date, order_deliver_date, estimated_deliver_date** for analysis

3. **New Table**
   - Created a consolidated table `all_order_details` with:
     - Order, product, seller, customer, payment, and delivery details
     - Cleaned and joined using business logic

            drop table if exists all_order_details ;
             create table all_order_details as 
            (select distinct o.order_id,
            o.order_status, 
            o.order_purchase_timestamp :: date as order_date,
            to_timestamp(o.order_delivered_timestamp,'YYYY-MM-DD HH24:MI:SS') :: date as order_deliver_date,
            to_date(o.order_estimated_delivery_date,'YYYY-MM-DD') :: date as estimated_deliver_date,
            case when (to_timestamp(o.order_delivered_timestamp, 'YYYY-MM-DD HH24:MI:SS')::date - 
            to_date(o.order_estimated_delivery_date, 'YYYY-MM-DD')::date) > 0  then 'yes' else 'no' end as delayd_delivery,
            ot.price,
            ot.shipping_charges,
            ot.seller_id,
            pd.product_id,
            pd.product_category_name,
            p.payment_type,
            p.payment_installments,
            p.payment_value,
            c.customer_city,
            c.customer_state
            from orders as o
            left join  order_items ot on ot.order_id = o.order_id
            left join product_details pd on pd.product_id = ot.product_id
            left join payment p on p.order_id=o.order_id
            left join customer c on c.customer_id=o.customer_id);
  

4. **Analytics using CTEs**
   - **Orders Summary** → total orders, revenue, average order value  
   - **Delivery Summary** → how many were delayed vs on-time  
   - **Orders by State** → customer distribution & revenue by region  
   - **Orders by Category** → top-selling product categories  
   - **Monthly Trend** → order and revenue trend over time  

         delivery_summary as 
          (select delayd_delivery, count(distinct order_id) as order_count
          from all_order_details
          group by delayd_delivery);
          
          
          -- 3. Orders by state
          orders_by_state as
          (select
          customer_state,
          count(distinct order_id) as total_orders,
          sum(payment_value) as revenue
          from all_order_details
          group by customer_state);
          .....
---

## Why This Helps

- Business users can quickly answer:
  - How many orders were delayed?  
  - Which states bring the most revenue?  
  - Which categories sell best?  
  - Is revenue growing month by month?  

- This table can also be connected to:
  - **Tableau / Power BI** for dashboards  
  - **Python / Pandas** for deeper analysis  

---

## How to Use

1. Clone this repo:
   ```bash
   git clone https://github.com/abhinandannath13/ecommerce-order-insights.git
2.Open the SQL script in sql/ecommerce_analysis.sql.

3.Run in your SQL environment (PostgreSQL recommended).

4.At the bottom of the script, choose which result to view:

    select * from orders_summary;
    -- select * from delivery_summary;
    -- select * from orders_by_state;
    -- select * from orders_by_category;
    -- select * from monthly_trend;
