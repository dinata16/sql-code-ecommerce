create temporary table report_monthly_orders_product_agg as
  SELECT FORMAT_TIMESTAMP('%Y-%m', created_at) AS month ,
        product_id,
        sum(sale_price) total_sales
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  where status = 'Complete'
  group by month, product_id
  order by month asc, total_sales desc;

with max_sales_per_month as (
  select month,
        max(total_sales) as max_sales
  from report_monthly_orders_product_agg
  group by month
)
select r.* , p.category, p.name
from report_monthly_orders_product_agg as r
left join `bigquery-public-data.thelook_ecommerce.products` as p
on r.product_id = p.id
inner join max_sales_per_month as ms
on r.month = ms.month and r.total_sales = ms.max_sales
order by r.month;