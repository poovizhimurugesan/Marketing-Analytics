create database Marketing;

-- 1. Email Delivery Rate 

SELECT 
    (COUNT(CASE
        WHEN Activity_Type = 'Delivered' THEN Email_ID
    END) * 100.0) / COUNT(Email_ID) AS Email_delivery_rate_percentage
FROM
    activities;

-- 2. Open Rate

SELECT 
    (COUNT(CASE
        WHEN Activity_Type = 'Open' THEN Email_ID
    END) * 100.0) / COUNT(CASE
        WHEN Activity_Type = 'Delivered' THEN Email_ID
    END) AS Open_Rate
FROM
    activities;

-- 3. Click-Through Rate (CTR)

SELECT 
    (COUNT(CASE
        WHEN Activity_Type = 'Click' THEN Email_ID
    END) * 100.0) / COUNT(CASE
        WHEN Activity_Type = 'Open' THEN Email_ID
    END) AS Click_Through_Rate
FROM
    activities;

-- 4. Campaign Engagement Rate

SELECT 
    c.Campaign_ID,
    CONCAT(ROUND((COUNT(*) * 100.0) / (SELECT 
                            COUNT(*)
                        FROM
                            activities),
                    2),
            '%') AS engagement_rate_percentage
FROM
    activities a
        JOIN
    emails e ON a.Email_Id = e.Email_ID
        JOIN
    campaigns c ON e.Campaign_ID = c.Campaign_ID
GROUP BY c.Campaign_ID
ORDER BY engagement_rate_percentage DESC;
        
-- 5. Top Performing Campaigns 

SELECT 
    c.Campaign_ID,
    ROUND((COUNT(*) * 10000) / (SELECT 
                    COUNT(*)
                FROM
                    activities),
            0) AS engagement_rate_percentage
FROM
    activities a
        JOIN
    emails e ON a.Email_Id = e.Email_ID
        JOIN
    campaigns c ON e.Campaign_ID = c.Campaign_ID
GROUP BY c.Campaign_ID
ORDER BY engagement_rate_percentage DESC
LIMIT 10;

-- 6. Average Activity Per Email

SELECT 
    ROUND(COUNT(activity_id) * 1.0 / COUNT(DISTINCT email_id),
            0) AS average_activity_per_email
FROM
    activities;

-- 7. Activity Breakdown by Type

SELECT 
    Activity_Type, COUNT(Activity_Type) AS Activities
FROM
    activities
GROUP BY Activity_Type;

-- 8. Email Sent vs Activity Timeline

SELECT 
    COALESCE(e.date, a.date) AS date,
    COALESCE(e.sent_count, 0) AS emails_sent,
    COALESCE(a.delivered, 0) AS delivered,
    COALESCE(a.opens, 0) AS opens,
    COALESCE(a.clicks, 0) AS clicks
FROM
    (SELECT 
        CAST(Email_Sent_Date AS DATE) AS date,
            COUNT(*) AS sent_count
    FROM
        emails
    GROUP BY CAST(Email_Sent_Date AS DATE)) e
        JOIN
    (SELECT 
        CAST(Activity_Date AS DATE) AS date,
            SUM(CASE
                WHEN Activity_Type = 'Delivered' THEN 1
                ELSE 0
            END) AS delivered,
            SUM(CASE
                WHEN Activity_Type = 'Open' THEN 1
                ELSE 0
            END) AS opens,
            SUM(CASE
                WHEN Activity_Type = 'Click' THEN 1
                ELSE 0
            END) AS clicks
    FROM
        activities
    GROUP BY CAST(Activity_Date AS DATE)) a ON e.date = a.date
ORDER BY date;


-- Web Engagement KPIS

-- 1)Total Unique Visitors 

SELECT 
    CONCAT(ROUND(SUM(`Unique Visitors`) / 1000000, 2),
            'M') AS Unique_Visitors
FROM
    web_eng;

-- 2)Average Bounce Rate (%)

SELECT 
    ROUND(AVG(`Bounce Rate (%)`), 2) AS Average_Bounce_Rate
FROM
    web_eng;

-- 3)Average Session Duration

SELECT 
    ROUND(AVG(`Avg Session Duration (min)`), 2) AS Average_Bounce_Rate
FROM
    web_eng;

-- 4)Traffic Source Breakdown

SELECT 
    `Traffic Source`, COUNT(`Traffic Source`) AS Entries
FROM
    web_eng
GROUP BY `Traffic Source`
ORDER BY Entries DESC;

-- 5)Device Usage Share

SELECT 
    `Device Type`, COUNT(`Device Type`) AS Usages
FROM
    web_eng
GROUP BY `Device Type`
ORDER BY Usages DESC;

-- 6)Top 5 Regions by Unique Visitors

SELECT 
    Region, SUM(`Unique Visitors`) AS Unique_Visitors
FROM
    web_eng
GROUP BY Region
ORDER BY Unique_Visitors DESC
LIMIT 5;

-- 7)Engagement by Date (Time Series)

SELECT 
    Date,
    SUM(`Page Views`) AS Page_Views,
    SUM(`Unique Visitors`) AS Unique_Visitors
FROM
    web_eng
GROUP BY Date
ORDER BY Date;


-- Monthly 
SELECT 
    DATE_FORMAT(Date, '%b') AS Months,
    SUM(`Page Views`) AS Page_Views,
    SUM(`Unique Visitors`) AS Unique_Visitors
FROM
    web_eng
GROUP BY Months
ORDER BY Months DESC;


-- Additional KPIs

-- 1 Page Views per Visitor

SELECT 
    ROUND(SUM(`Page Views`) / SUM(`Unique Visitors`), 2) AS `Page_Views_Per_Visitor`
FROM web_eng;

-- 2 Bounce Rate by Traffic Source

SELECT 
    `Traffic Source`,
    CONCAT(ROUND(AVG(`Bounce Rate (%)`), 2), '%') AS `Avg_Bounce_Rate`
FROM web_eng
GROUP BY `Traffic Source`
ORDER BY `Avg_Bounce_Rate` DESC;

-- 3 Traffic Source Share Over Time

SELECT 
    DATE_FORMAT(`Date`, '%Y-%m') AS `Month`,
    `Traffic Source`,
    SUM(`Page Views`) AS `Total_Page_Views`
FROM web_eng
GROUP BY `Month`, `Traffic Source`
ORDER BY `Month`, `Total_Page_Views` DESC;

-- 4 Monthly Bounce Rate Trend

SELECT 
    DATE_FORMAT(`Date`, '%M %Y') AS `Month_Name`,
    CONCAT(ROUND(AVG(`Bounce Rate (%)`), 2), '%') AS `Avg_Bounce_Rate`
FROM web_eng
GROUP BY `Month_Name`
ORDER BY STR_TO_DATE(`Month_Name`, '%M %Y');

-- 5 High-Engagement Regions

SELECT 
    `Region`,
    SUM(`Page Views` + `Unique Visitors`) AS `Total_Engagement`
FROM web_eng
GROUP BY `Region`
ORDER BY `Total_Engagement` DESC
LIMIT 5;

-- 6  Average Page Views per Session
  
SELECT 
    ROUND(SUM(`Page Views`) / COUNT(*), 2) AS `Avg_Page_Views_per_Session`
FROM web_eng;

-- 7 Bounce Rate by Device Type
  
SELECT 
    `Device Type`,
    ROUND(AVG(`Bounce Rate (%)`), 2) AS `Avg_Bounce_Rate_%`
FROM web_eng
GROUP BY `Device Type`
ORDER BY `Avg_Bounce_Rate_%` DESC;

-- 8 Top Performing Months (Based on Visitors)

SELECT
    DATE_FORMAT(`Date`, '%Y-%m') AS `Month`,
    SUM(`Unique Visitors`) AS `Total_Visitors`
FROM web_eng
GROUP BY `Month`
ORDER BY `Total_Visitors` DESC
LIMIT 5;

-- 9 Average Session Duration by Region

SELECT 
    `Region`,
    ROUND(AVG(`Avg Session Duration (min)`), 2) AS `Avg_Session_Duration_min`
FROM web_eng
GROUP BY `Region`
ORDER BY `Avg_Session_Duration_min` DESC;

-- 10 Most Active Day of the Week

SELECT 
    DAYNAME(`Date`) AS `Day_of_Week`,
    SUM(`Page Views`) AS `Total_Page_Views`
FROM web_eng
GROUP BY `Day_of_Week`
ORDER BY `Total_Page_Views` DESC;
