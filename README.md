# Sale Insights Data Analysis using SQL and Tableau
**Author: Hang Vo Thuy Nguyen**
<h2 style='color:blue'>Table of Contents  📋 </h2>

### 🚀 [1. Setting up and database structure](#1-setting-up-and-database-structure)
### 📊 [2. Using SQL analysis](#2-using-sql-analysis)
### 📉 [3. RFM Analysis](#3-rfm-analysis)
### 📈 [4. Analysis](#4-analysis)
### 🎨 [5. Tableau Dashboard](#5-tableau-dashboard)



## 1. Setting up and database structure
#### 1.1 Setting up
1. Open Sale Analysis.sql file in the SQL server or your SQL development kit.

2. Add the Dataset 'stores.xlsx' to the database and run the code.

#### 1.2 Database structure

<img width="621" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/0cdd4cbc-bcdf-4087-a4de-3f1cc269796e">

## 2. Using SQL analysis
To utilize SQL analysis for conducting sales data analysis, follow these steps:

1. Launch your preferred SQL client and connect with the database where you have imported the sales data.

2. Familiarize yourself with the SQL scripts available in the repository. These scripts encompass different facets of sales data analysis, including data cleansing, segmentation, and RFM analysis.

3. Employ the SQL queries within your SQL client to carry out the desired analysis.

4. Evaluate the outcomes and extract valuable insights from the sales data.

## 3. RFM Analysis
RFM analysis is used to segment customers based on their purchasing behavior. It involves evaluating three key dimensions:

* <b>Recency(R):</b> Measures the time elapsed since the customer's last purchase. Customers who made recent purchases are more likely to be engaged and responsive.
* <b>Frequency(F):</b> Measures the number of purchases made by a customer over a specific period. Frequent customers are often more valuable to the business.
* <b>Monetary Value(M):</b> Measures the total value of purchases made by a customer. Customers with higher monetary value contribute more to the business revenue.
  
By analyzing these dimensions, RFM analysis assigns scores to each customer. It categorizes them into different segments such as Loyal Customers, Active (Customers who buy often & recently, but at low price points), Potential Customers, New Customers, and Lost Customers. 

## 4. Analysis
Here are some analyses I used in this repository:

* **Items have not been ordered**
```SQL
select * from products P
left join orderdetails O
on P.productCode=O.productCode
where O.productCode is null
```
##### Output:

<img width="813" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/0a340308-2ea6-4763-9013-e6e905c2b3f8">

* **Items ordered at least once**
```SQL
select distinct P.productCode, P.productName 
from products P inner join orderdetails O 
on P.productcode=O.productCode
```
##### Output:

<img width="813" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/87efc58b-7d4f-4fd6-8937-b8c24d601cff">

* **Order quantity and Revenue by countries**
```SQL
select c.country, sum(od.quantityOrdered) as TotalQuantityOrderd, sum(od.quantityOrdered*od.priceEach) as Revenue
from customers c inner join orders o
on c.customerNumber=o.customerNumber
inner join orderdetails od
on o.orderNumber=od.orderNumber
group by c.country
order by TotalQuantityOrderd desc
```
##### Output:

<img width="812" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/43b52df5-7a44-45ba-8278-5fe4213b2f04">

* **Total orders and Revenue per status**
```SQL
select o.status, count(distinct o.orderNumber) as OrderCount, sum(od.quantityOrdered * od.priceEach) AS Revenue
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber
group by o.status
order by Revenue desc
```
##### Output: 

<img width="204" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/c0c6ef90-47fe-4f77-980e-8c0c7e7eae60">

* **Revenue by Product**
```SQL
select P.productCode, P.productName, sum(od.quantityOrdered * od.priceEach) as Revenue
from products P inner join orderdetails od
on P.productCode=od.productCode 
group by P.productCode, P.productName
order by Revenue desc
```
##### Output:

<img width="811" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/aed0275c-fa00-48a7-8bc3-1a95e8c422b2">
  
* **Revenue by product line**
```SQL
select p.productLine, sum(od.quantityOrdered * od.priceEach) AS Revenue
from products p
inner join orderdetails od
on p.productCode = od.productCode
group by p.productLine
order by Revenue desc
```
##### Output:

<img width="180" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/1864580a-9d9e-4542-a81f-822b5626de6a">

* **Identify the best customers and categorize them into different segments based on RFM analysis**
```SQL
with rfm as (
    select
        o.customerNumber,
        max(o.orderDate) as last_order_date,
        count(o.orderNumber) as Frequency,
		sum(od.quantityOrdered * od.priceEach) as MonetaryValue,
        sum(od.quantityOrdered * od.priceEach) / count(o.orderNumber) as AvgMonetaryValue,
		(select max(orderDate) from orders as max_order_date) as max_order_date,
		datediff(dd, max(o.orderDate), (select max(orderDate) from orders)) as Recency
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
order by MonetaryValue desc
```
##### Output
<img width="897" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/747e32ee-3c22-4bcc-8505-4b2c238e58b6">

## 5. Tableau Dashboard
Here is a preview of the interactive dashboard created using Tableau:

<img width="692" alt="image" src="https://github.com/Hannahnv/Sales-Insights-Data-Analysis/assets/102349995/e8df1d63-b4bc-4c5a-b586-aa459e9cece9">

### 🎨 Find the interactive dashboard here: [Sales Insight Dashboard](https://public.tableau.com/app/profile/hang.nguyen6427/viz/SalesInsightsDashboard_16887527602530/Dashboard1)

