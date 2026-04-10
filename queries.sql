-- 🍕 PIZZA SALES SQL PROJECT
-- Author: Aditya Agarwal
-- Description: SQL analysis of pizza sales dataset with business insights

-- =====================================================
-- 🔹 BASIC ANALYSIS
-- =====================================================

-- 1. Total number of orders placed
-- Output: 21,350 orders
-- Insight: Strong order volume indicates consistent demand

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- 2. Total revenue generated
-- Output: ~$8,17,860
-- Insight: Healthy revenue, but needs deeper breakdown to optimize growth

SELECT 
    ROUND(SUM(pizzas.price * order_details.quantity)) AS total_sales
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id

  
-- 3. Highest priced pizza
-- Output: The Greek Pizza, Price - 35.95
-- Insight: Premium pizzas can boost margins but may have lower volume

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- 4. Most common pizza size ordered
-- Output: Large size dominates, order_count - 18526
-- Insight: Customers prefer value-for-money sizes → pricing strategy works

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- 5. Top 5 most ordered pizza types (by quantity)
-- Output: Classic Deluxe, BBQ Chicken, Hawaeiin Pizza, Pepperon Pizza, Thai Chicken Pizza.
-- Insight: Few pizzas drive majority of volume → focus on these for marketing

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- =====================================================
-- 🔹 INTERMEDIATE ANALYSIS
-- =====================================================

-- 6. Total quantity of each pizza category ordered
-- Output: Classic, 14888, Supreme, 11987, Veggie, 11649, Chicken, 11050
-- Insight: Traditional flavors dominate → safer customer preference

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- 7. Distribution of orders by hour of the day
-- Output: Peak during lunch (12–2 PM) and evening (5–8 PM)
-- Insight: Clear peak hours → optimize staffing and delivery operations

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);


-- 8. Category-wise distribution of pizzas
-- Output: Classic, 8, Supreme, 9, Veggie, 9, Chicken, 6
-- Insight: Balanced menu, but classics still lead demand

SELECT 
    category, COUNT(name)
FROM
	pizza_types
GROUP BY category;


-- 9. Average number of pizzas ordered per day
-- Output: 138 pizzas/day
-- Insight: Stable daily demand → predictable inventory planning

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity; 


-- 10. Top 3 pizza types based on revenue
-- Output: Thai Chicken, Barbeque Chicken, California Chicken
-- Insight: Chicken pizzas get the most revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- =====================================================
-- 🔹 ADVANCED ANALYSIS
-- =====================================================

-- 11. Percentage contribution of each pizza type to total revenue
-- Output: Classic, 26, Supreme, 25, Chicken, 24, Veggie, 23
-- Insight: Revenue is equally distributed.

SELECT 
    pizza_types.category,
    (SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(pizzas.price * order_details.quantity),
                        2) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- 12. Cumulative revenue over time
-- Output: Steady upward trend
-- Insight: Consistent business growth over time

SELECT order_date, SUM(revenue) OVER(order by order_date) AS cum_revenue
FROM
(SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details 
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS sales;


-- 13. Top 3 pizza types by revenue within each category
-- Output: Different leaders in each category
-- Insight: Each category has its own top performers → targeted promotions needed

SELECT name, revenue 
FROM
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn 
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM((order_details.quantity)*pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn <= 3;
