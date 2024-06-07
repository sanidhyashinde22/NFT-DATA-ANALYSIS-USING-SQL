USE cryptopunk;
SELECT * FROM pricedata;
--  COUNT OF SALES IN BETWEEN January 1st, 2018 to December 31st, 2021

SELECT count(*) FROM pricedata WHERE event_date BETWEEN '01-01-2018' AND '31-11-2021';

-- Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.

SELECT name, eth_price, usd_price,event_date FROM pricedata ORDER BY usd_price DESC  LIMIT 5;

-- Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.
 SELECT * FROM pricedata;
SELECT event_date,usd_price, AVG(usd_price) OVER(
ORDER BY event_date
ROWS BETWEEN 50  PRECEDING AND CURRENT ROW
) AS moving_avg
FROM pricedata
ORDER BY event_date;


-- Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.

SELECT name, AVG(usd_price) AS average_price FROM pricedata GROUP BY(name) ORDER BY average_price DESC;

/* Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH.
 Order by the count of transactions in ascending order.*/
 
SELECT dayofweek(event_date),count(transaction_hash),AVG(eth_price) FROM pricedata GROUP BY event_date ORDER BY COUNT(transaction_hash);

/* Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, who bought the NFT, who sold the NFT,
the date, and what price it was sold for in USD rounded to the nearest thousandth.Here’s an example summary: 
 “CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14” */

 SELECT * FROM pricedata;
 ALTER TABLE pricedata
 DROP column summary;
SELECT * , concat(name,"was sold for","$" ,usd_price,"to",buyer_address,"from",seller_address, "on",event_date) AS Summary FROM pricedata;


/* Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer. */

CREATE VIEW 1919_purchases AS 
SELECT transaction_hash, buyer_address FROM pricedata WHERE buyer_address ="0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685" ;

SELECT * FROM 1919_purchases;

SELECT
    ROUND(eth_price / 100.0) * 100 AS price_range,
    COUNT(*) AS frequency
FROM pricedata
GROUP BY price_range
ORDER BY price_range;

/*Return a unioned query that contains the highest price each NFT was bought for and 
a new column called status saying “highest” with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. 
The table should have a name column, a price column called price, and a status column. Order the result set by the name of the NFT, and the status, in ascending order. */

 
SELECT DISTINCT name, usd_price AS highest FROM pricedata
UNION
SELECT DISTINCT name ,usd_price AS lowest FROM pricedata ORDER BY highest DESC;



-- What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format

SELECT 
dayofweek(event_date),COUNT(*),AVG(usd_price)
FROM
pricedata
GROUP BY dayofweek(event_date)
ORDER BY COUNT(*);

-- Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).

 
 SELECT month(event_date),SUM(usd_price )FROM pricedata
 GROUP BY month(event_date)
 ORDER BY month(event_date), SUM(usd_price );

-- Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.




SELECT count(transaction_hash) FROM pricedata WHERE transaction_hash = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

/* Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
 - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
 - Take the daily average of remaining transactions
 a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price for each day using a window function. Save it as a temporary table.
 b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and return a new estimated value which is just the daily average of the filtered data.*/

 CREATE TEMPORARY TABLE temp_price
SELECT event_date,usd_price,AVG(usd_price) OVER (PARTITION BY DAY(event_date)) AS avg_price FROM pricedata;

SELECT event_date,usd_price,avg_price AS daily_average FROM temp_price where avg_price > 0.10*avg_price ;

