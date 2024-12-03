# Monthly Sales Report Query

  This SQL script generates a report to identify the highest-selling products for each month, along with their category, from the `bigquery-public-data.thelook_ecommerce` dataset.

## Query Steps and Explanation
### Step 1: Create temporary table

```sql
CREATE TEMPORARY TABLE report_monthly_orders_product_agg AS
SELECT 
  FORMAT_TIMESTAMP('%Y-%m', created_at) AS month,
  product_id,
  SUM(sale_price) AS total_sales
FROM 
  `bigquery-public-data.thelook_ecommerce.order_items`
WHERE 
  status = 'Complete'
GROUP BY 
  month, product_id
ORDER BY 
  month ASC, total_sales DESC;
```

### Explanation:

1. Temporary Table:
    - A temporary table report_monthly_orders_product_agg is created to store aggregated sales data.
2. FORMAT_TIMESTAMP:
    - The created_at timestamp is converted to a year-month format (YYYY-MM) and renamed to month.
3. SUM(sale_price):
    - Calculates the total sales (total_sales) for each product in each month.
4. Filters:
    - Only records with status = 'Complete' are included.
5. GROUP BY:
    - Data is grouped by month and product_id to calculate aggregated sales.
6. ORDER BY:
    - Results are sorted by month (ascending) and total_sales (descending).


### Step 2: Find product with maximum sales per month
```sql
WITH max_sales_per_month AS (
  SELECT 
    month,
    MAX(total_sales) AS max_sales
  FROM 
    report_monthly_orders_product_agg
  GROUP BY 
    month
)
```

### Explanation
1. Common Table Expression (CTE):
    - A CTE named max_sales_per_month is created to calculate the maximum sales (max_sales) for each month.
2. MAX(total_sales):
    - Retrieves the highest total_sales value in each month.
  

### Step 3: Combine Data and retrieve results
```sql
SELECT 
  r.*, 
  p.category,
  p.name
FROM 
  report_monthly_orders_product_agg AS r
LEFT JOIN 
  `bigquery-public-data.thelook_ecommerce.products` AS p
ON 
  r.product_id = p.id
INNER JOIN 
  max_sales_per_month AS ms
ON 
  r.month = ms.month AND r.total_sales = ms.max_sales
ORDER BY 
  r.month;
```


### Explanation
1. Join Tables:
    - LEFT JOIN: Combines report_monthly_orders_product_agg with the products table to include the product category and product name.
    - INNER JOIN: Filters results to include only the products with maximum sales for each month (max_sales).
2. Order Results:
    - Results are sorted by month in ascending order.
  

## Key Objectives
- Aggregate monthly sales data for each product.
- Identify the product with the highest sales in each month.
- Include additional product details such as category and product name.


## Output
The final output contains:
    - Month: The year-month (YYYY-MM) of the sales.
    - Product ID: The unique identifier of the product.
    - Total Sales: The total sales for the product in the month.
    - Category: The category of the product.
    - Name: The product's name

## Dataset Details
- order_items: Contains order details, including created_at, status, sale_price, and product_id.
- products: Contains product details such as name and category.


## How to Run
1. Ensure access to the bigquery-public-data.thelook_ecommerce dataset in Google BigQuery.
2. Copy and paste the SQL script into your BigQuery console.
3. Execute the query to retrieve the results.
