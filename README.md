# Sale Insights Data Analysis using SQL and Tableau
<h2 style='color:blue'>Table of Contents  📋 </h2>

### 🚀 [Setting up and instruction of SQL analysis](#setting-up-and-instruction-of-sql-analysis)
### 📉 [RFM Analysis](#rfm-analysis)
### 📈 [Analysis](#analysis)
### 📊 [Tableau Dashboard](#tableau-dashboard)



## 🚀 Setting up and instruction of SQL analysis 
#### Setting up
1. Open Sale Analysis.sql file in the SQL server or your SQL development kit.

2. Add the Dataset 'stores.xlsx' to the database and run the code.
#### Instruction of SQL analysis
To utilize SQL analysis for conducting sales data analysis, follow these steps:

1. Launch your preferred SQL client and connect with the database where you have imported the sales data.

2. Familiarize yourself with the SQL scripts available in the repository. These scripts encompass different facets of sales data analysis, including data cleansing, segmentation, and RFM analysis.

3. Employ the SQL queries within your SQL client to carry out the desired analysis.

4. Evaluate the outcomes and extract valuable insights from the sales data.

## 📉 RFM Analysis
RFM analysis is used to segment customers based on their purchasing behavior. It involves evaluating three key dimensions:

* <b>Recency(R):</b> Measures the time elapsed since the customer's last purchase. Customers who made recent purchases are more likely to be engaged and responsive.
* <b>Frequency(F):</b> Measures the number of purchases made by a customer over a specific period. Frequent customers are often more valuable to the business.
* <b>Monetary Value(M):</b> Measures the total value of purchases made by a customer. Customers with higher monetary value contribute more to the business revenue.
  
By analyzing these dimensions, RFM analysis assigns scores to each customer. It categorizes them into different segments such as Loyal Customers, Active (Customers who buy often & recently, but at low price points), Potential Customers, New Customers, and Lost Customers. 

## 📈 Analysis
Here are some instances of the analysis you can conduct using this repository:

* Items have not been ordered
* Items ordered at least once
* Order quantity and Revenue by countries
* Total orders and Revenue per status
* Revenue by Product
* Revenue by product line
* Identify the best customers and categorize them into different segments based on RFM analysis
  
_ For example, the following SQL query performs to identify the best customers by analyzing their recency, frequency, and monetary value (RFM): 
```SQL
with rfm as (
    select
        o.customerNumber,
        max(o.orderDate) as last_order_date,
        count(o.orderNumber) as Frequency,
		sum(od.quantityOrdered * od.priceEach) as MonetaryValue,
        sum(od.quantityOrdered * od.priceEach) / count(o.orderNumber) as AvgMonetaryValue
    from orders o
    inner join orderdetails od on o.orderNumber = od.orderNumber
    group by o.customerNumber
),
rfm_calc as ( 
	select 
		r.*, 
		ntile(4) over (order by last_order_date) as rfm_recency,
		ntile(4) over (order by Frequency) as rfm_frequency,
		ntile(4) over (order by MonetaryValue) as rfm_monetary
	from rfm r
)
select 
	c.customerName, rfm.*,
	(case
		when rfm_recency = 4 and rfm_frequency >= 3 and rfm_monetary >= 3 then 'Loyal Customers'
    when rfm_recency >= 3 and rfm_frequency >= 3 and rfm_monetary >= 2 then 'Active' --(Customers who buy often & recently, but at low price points)
		when rfm_recency >= 2 and rfm_frequency >= 1 and rfm_monetary >= 2 then 'Potential Customers'
		when rfm_recency >= 3 and rfm_frequency >= 1 and rfm_monetary = 1 then 'New Customers'
		when rfm_recency <= 2 and rfm_frequency >= 1 and rfm_monetary >=1 then 'Lost Customers'
	 end) as rfm_segment
from rfm_calc rfm
inner join customers c 
on rfm.customerNumber=c.customerNumber
```

If you want to explore SQL queries to analyze, feel free to refer to my SQL file in the repository. 
## 📊 Tableau Dashboard
### 🎨 Find the interactive dashboard here: [Sales Insight Dashboard](https://public.tableau.com/app/profile/hang.nguyen6427/viz/SalesInsightsDashboard_16887527602530/Dashboard1)



 



