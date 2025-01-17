use bank_data;

select * from branch;
select * from customers;
select * from accounts;
select * from employees;
select * from transactions;

# 1.Write a query to list all customers who haven't made any transactions in the last year. How can we make them active again? 

select c.customer_id,c.first_name,c.last_name from customers c
join accounts a on c.customer_id = a.customer_id
left join transactions t on a.account_number = t.account_number 
where t.transaction_id is null or 
t.transaction_date < date_sub(curdate(),interval 1 year);

# 2. Summarize the total transaction amount per account per month.

SELECT account_number, year(transaction_date) as year , month(transaction_date) as month,sum(amount) as total_amt
from transactions t 
group by account_number,year(transaction_date),month(transaction_date)
order by account_number,year,month;

# 3. Rank branches based on the total amount of deposits made in the last quarter

SELECT a.branch_id,sum(t.amount) , dense_rank() 
over(order by sum(t.amount) desc) as branch_rank
from accounts a inner join transactions t 
using(account_number)
where t.transaction_type="Deposit" and 
t.transaction_date>=date_sub(current_date(),interval 3 
month) group by a.branch_id
order by branch_rank;

#4. Find the name of the customer who  has deposited the highest amount.

SELECT concat(c.first_name," ",c.last_name) as full_name, t.amount 
from customers c 
inner join accounts a on c.customer_id=a.customer_id 
inner join transactions t on t.account_number=a.account_number
where t.transaction_type="Deposit"
order by t.amount desc
limit 1;

# 5. Identify any accounts that have made more than two transactions in a single day, which could indicate fraudulent activity. 

SELECT a.account_number as fraud_accounts,count(t.transaction_id) as no_of_transactions ,day(t.transaction_date) as single_day
from accounts a inner join transactions t 
using(account_number)
group by fraud_accounts,single_day
having no_of_transactions>2;

# 6.Calculate the average number of transactions per customer per account per month over the last year.

WITH MonthlyTransactions AS (
 SELECT a.customer_id, a.account_number, YEAR(t.transaction_date) AS transaction_year,
 MONTH(t.transaction_date) AS transaction_month,
 COUNT(t.transaction_id) AS num_transactions
 FROM accounts a
 INNER JOIN transactions t ON a.account_number = t.account_number
 WHERE
 t.transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)
 GROUP BY a.customer_id, a.account_number,
 YEAR(t.transaction_date), MONTH(t.transaction_date)
)
SELECT customer_id, account_number, ROUND(AVG(num_transactions), 2) AS avg_month_trans
FROM MonthlyTransactions
GROUP BY customer_id, account_number
ORDER BY avg_month_trans DESC;
 
 # 7. Write a query to find the daily transaction volume (total amount of all transactions) for the past month.

SELECT date(transaction_date) as transaction_day,round(sum(amount),3) as trans_volume
from transactions 
where 
transaction_date>=date_sub(current_date(),interval 1 month)
group by transaction_day
order by transaction_day;

# 8.Calculate the total transaction amount performed by each age group in the past year. (Age groups: 0-17, 18-30, 31-60, 60+)

SELECT 
case When floor((datediff(current_date(),c.date_of_birth)/365)) between 0 and 17 then "0-17"
	When floor((datediff(current_date(),c.date_of_birth)/365)) between 18 and 30 then "18-30"
	When floor((datediff(current_date(),c.date_of_birth)/365)) between 31 and 60 then "31-60"
else "60+" 
end as age_group,
sum(t.amount) as total_trans_amt from customers c inner join accounts a on c.customer_id=a.customer_id 
inner join transactions t on t.account_number=a.account_number
where t.transaction_date>=date_sub(current_date(),interval 1 year)
group by age_group;

#9.Find the branch with the highest average account balance.

SELECT branch_id,avg(balance) as avg_bal
from accounts 
group by branch_id
order by avg_bal desc
limit 1;

# 10. Calculate the average balance per customer at the end of each month in last year.

SELECT a.customer_id,year(t.transaction_date) as year,month(t.transaction_date) as month ,round(avg(a.balance),2)as avg_balance 
from accounts a join transactions t 
using(account_number) 
where 
t.transaction_date>=date_sub(current_date,interval 1 year)
group by customer_id,year,month
order by year,month;