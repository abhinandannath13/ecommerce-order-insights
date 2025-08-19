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

-- 1. Orders and revenue summary
with summary as (select
    count(distinct order_id) as total_orders,
    sum(payment_value) as total_revenue,
    avg(payment_value) as avg_order_value
from all_order_details);

-- 2. Delayed vs on-time delivery
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


-- 4. Orders by product category
orders_by_category as ( select
    product_category_name,
    count(distinct order_id) as total_orders,
    sum(payment_value) as revenue
from all_order_details
group by product_category_name
order by revenue desc);

-- 5. Monthly trend
monthly_trend as ( select 
    to_char( order_date,'month-yy') as month,
    cunt(distinct order_id) as total_orders,
    sum(payment_value) as revenue
from all_order_details
group by to_char( order_date,'month-yy')
order by to_char( order_date,'month-yy'));



select * from orders_summary;
-- select * from delivery_summary;
-- select * from orders_by_state;
-- select * from orders_by_category;
-- select * from monthly_trend;