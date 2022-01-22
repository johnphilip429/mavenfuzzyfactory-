SET GLOBAL max_allowed_packet = 1073741824;

USE mavenfuzzyfactory;
SELECT * FROM order_item_refunds;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM website_pageviews;
SELECT * FROM website_sessions;


### breakdown of UTM source, campaign and referring domain.


SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions 
GROUP BY utm_source;


### conversion rate from session to order


SELECT 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
	YEAR(website_sessions.created_at) as yearly,
	MONTH(website_sessions.created_at) as monthly,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate


FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
    
WHERE
         utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
         
GROUP BY  yearly,monthly
ORDER BY yearly,monthly;


### gsearch non brand trended session .

         
SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE created_at > '2012-04-15'
	AND utm_source = 'gsearch' 
    AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);


### Device type conversion rate 


SELECT 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
	YEAR(website_sessions.created_at) as yearly,
	MONTH(website_sessions.created_at) as monthly,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type='mobile' THEN website_sessions.website_session_id ELSE NULL END ) AS mobile_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type='mobile' THEN orders.order_id ELSE NULL END ) AS mobile_orders,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type='desktop' THEN website_sessions.website_session_id ELSE NULL END ) AS desktop_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type='desktop' THEN orders.order_id ELSE NULL END ) AS desktop_orders

FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
    
WHERE
         utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
         
GROUP BY  yearly,monthly
ORDER BY yearly,monthly;


### weekly trends by device type to see the impact on volume?


SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS 'desktop_sessions',
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS 'mobile_sessions'
FROM
    website_sessions
WHERE
    website_sessions.created_at > '2012-05-19'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at)