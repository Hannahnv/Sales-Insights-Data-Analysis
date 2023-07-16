select * from products
select * from orderdetails
select * from orders
select * from customers

-- Items have not been ordered
select * from products P
left join orderdetails O
on P.productCode=O.productCode
where O.productCode is null

-- Items ordered at least once
select distinct P.productCode, P.productName 
from products P inner join orderdetails O 
on P.productcode=O.productCode

--Order quantity and Revenue by countries
select c.country, sum(od.quantityOrdered) as TotalQuantityOrderd, sum(od.quantityOrdered*od.priceEach) as Revenue
from customers c inner join orders o
on c.customerNumber=o.customerNumber
inner join orderdetails od
on o.orderNumber=od.orderNumber
group by c.country
order by TotalQuantityOrderd desc

-- Total orders and Revenue per status
select o.status, count(distinct o.orderNumber) as OrderCount, sum(od.quantityOrdered * od.priceEach) AS Revenue
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber
group by o.status
order by Revenue desc

-- Revenue by Product
select P.productCode, P.productName, sum(od.quantityOrdered * od.priceEach) as Revenue
from products P inner join orderdetails od
on P.productCode=od.productCode 
group by P.productCode, P.productName
order by Revenue desc

-- Revenue by product line
select p.productLine, sum(od.quantityOrdered * od.priceEach) AS Revenue
from products p
inner join orderdetails od
on p.productCode = od.productCode
group by p.productLine
order by Revenue desc

-- Who is best customer? (Using RFM analysis)
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
