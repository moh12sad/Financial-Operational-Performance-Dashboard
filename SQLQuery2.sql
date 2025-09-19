SELECT TOP (1000) [vehicle_model]
      ,[Incident_Number]
      ,[Summary]
      ,[paid_amount]
      ,[date]
      ,[column6]
  FROM [most popular 1000 youtube video].[dbo].[vehicles received]

  ALTER TABLE [most popular 1000 youtube video].[dbo].[vehicles received]
DROP COLUMN column6;

select* from [most popular 1000 youtube video].[dbo].[vehicles received];

select Summary, SUM(paid_amount) total_paid
from [most popular 1000 youtube video].[dbo].[vehicles received]
group by Summary
order by total_paid desc;

select Summary, count(Summary) group_vehicles
from [most popular 1000 youtube video].[dbo].[vehicles received]
group by Summary
order by group_vehicles desc;

select vehicle_model, count(vehicle_model) counting_vehicles_received,SUM(paid_amount) total_paid_for_each_model,
from [most popular 1000 youtube video].[dbo].[vehicles received]
group by vehicle_model
order by most_vehicles_received desc;

select sum(paid_amount) total_4_all_vehicles from [most popular 1000 youtube video].[dbo].[vehicles received];

SELECT 
    v.vehicle_model, 
    COUNT(v.vehicle_model) AS counting_models_received,
    SUM(v.paid_amount) AS total_paid_for_each_model,
    (SUM(v.paid_amount) / t.total_4_all_vehicles) * 100 AS ratio_paid
FROM [most popular 1000 youtube video].[dbo].[vehicles received] v
CROSS JOIN (
    SELECT SUM(paid_amount) AS total_4_all_vehicles
    FROM [most popular 1000 youtube video].[dbo].[vehicles received]
) t
GROUP BY v.vehicle_model, t.total_4_all_vehicles
ORDER BY counting_models_received DESC;

SELECT 
    v.summary, 
    COUNT(v.vehicle_model) AS counting_models_received,
    SUM(v.paid_amount) AS total_paid_for_each_model,
    (SUM(v.paid_amount) / t.total_4_all_vehicles) * 100 AS ratio_paid
FROM [most popular 1000 youtube video].[dbo].[vehicles received] v
CROSS JOIN (
    SELECT SUM(paid_amount) AS total_4_all_vehicles
    FROM [most popular 1000 youtube video].[dbo].[vehicles received]
) t
GROUP BY v.summary, t.total_4_all_vehicles
ORDER BY counting_models_received DESC;

SELECT FORMAT(date, 'dddd,yyyy-MM-dd') AS formatted_date
FROM [most popular 1000 youtube video].[dbo].[vehicles received];


select vehicle_model, Summary, paid_amount, FORMAT(date, 'dddd,yyyy-MM-dd') AS formatted_date
from [most popular 1000 youtube video].[dbo].[vehicles received];

SELECT 
    t1.formatted_date,
    COUNT(*) AS no_of_vehicles_per_day
FROM (
    SELECT 
        vehicle_model, 
        Summary, 
        paid_amount, 
        FORMAT([date], 'dddd,yyyy-MM-dd') AS formatted_date
    FROM [most popular 1000 youtube video].[dbo].[vehicles received]
) t1
GROUP BY t1.formatted_date
ORDER BY no_of_vehicles_per_day DESC;

-- (اختياري) لو عايز أسماء الأيام بالإنجليزي
-- SET LANGUAGE English;

WITH daily AS (
    SELECT
        CAST(v.[date] AS date)           AS d,         -- اليوم (بدون وقت)
        DATENAME(weekday, v.[date])      AS day_name,  -- اسم اليوم
        COUNT(*)                         AS cnt        -- عدد العربيات في اليوم ده
    FROM [most popular 1000 youtube video].[dbo].[vehicles received] AS v
    GROUP BY
        CAST(v.[date] AS date),
        DATENAME(weekday, v.[date])
)
SELECT
    day_name,
    AVG(1.0 * cnt) AS avg_vehicles_per_day,  -- متوسط عدد العربيات لليوم ده عبر كل الأسابيع/التواريخ
    COUNT(*)       AS num_days,              -- عدد الأيام التي ظهر فيها اليوم ده
    SUM(cnt)       AS total_vehicles         -- إجمالي العربيات لليوم ده
FROM daily
GROUP BY day_name
ORDER BY
    CASE day_name
        WHEN 'Saturday'    THEN 1
        WHEN 'Sunday'    THEN 2
        WHEN 'Monday'   THEN 3
        WHEN 'Tuesday' THEN 4
        WHEN 'Wednesday'  THEN 5
        WHEN 'Thursday'    THEN 6
        WHEN 'Friday'  THEN 7
    END;

WITH total_all AS (
    SELECT SUM(paid_amount) AS total_4_all_vehicles
    FROM [most popular 1000 youtube video].[dbo].[vehicles received]
),
by_summary AS (
    SELECT 
        Summary, 
        COUNT(*) AS cnt_summary,
        SUM(paid_amount) AS total_paid_summary
    FROM [most popular 1000 youtube video].[dbo].[vehicles received]
    GROUP BY Summary
),
by_model AS (
    SELECT 
        vehicle_model,
        COUNT(*) AS cnt_model,
        SUM(paid_amount) AS total_paid_model
    FROM [most popular 1000 youtube video].[dbo].[vehicles received]
    GROUP BY vehicle_model
),
by_model_ratio AS (
    SELECT 
        v.vehicle_model,
        COUNT(*) AS cnt_model,
        SUM(v.paid_amount) AS total_paid_model,
        (SUM(v.paid_amount) / t.total_4_all_vehicles) * 100 AS ratio_paid_model
    FROM [most popular 1000 youtube video].[dbo].[vehicles received] v
    CROSS JOIN total_all t
    GROUP BY v.vehicle_model, t.total_4_all_vehicles
),
by_summary_ratio AS (
    SELECT 
        v.summary,
        COUNT(*) AS cnt_summary,
        SUM(v.paid_amount) AS total_paid_summary,
        (SUM(v.paid_amount) / t.total_4_all_vehicles) * 100 AS ratio_paid_summary
    FROM [most popular 1000 youtube video].[dbo].[vehicles received] v
    CROSS JOIN total_all t
    GROUP BY v.summary, t.total_4_all_vehicles
),
by_day AS (
    SELECT 
        FORMAT([date], 'dddd,yyyy-MM-dd') AS formatted_date,
        COUNT(*) AS no_of_vehicles_per_day
    FROM [most popular 1000 youtube video].[dbo].[vehicles received]
    GROUP BY FORMAT([date], 'dddd,yyyy-MM-dd')
),
avg_by_weekday AS (
    SELECT
        DATENAME(weekday, v.[date]) AS day_name,
        AVG(1.0 * COUNT(*)) OVER (PARTITION BY DATENAME(weekday, v.[date])) AS avg_vehicles_per_day
    FROM [most popular 1000 youtube video].[dbo].[vehicles received] v
    GROUP BY CAST(v.[date] AS date), DATENAME(weekday, v.[date])
)
-- النتيجة الموحدة
SELECT 
    s.Summary,
    s.cnt_summary,
    s.total_paid_summary,
    sr.ratio_paid_summary,
    m.vehicle_model,
    m.cnt_model,
    m.total_paid_model,
    mr.ratio_paid_model,
    d.formatted_date,
    d.no_of_vehicles_per_day,
    a.day_name,
    a.avg_vehicles_per_day,
    t.total_4_all_vehicles
FROM by_summary s
LEFT JOIN by_summary_ratio sr ON s.Summary = sr.Summary
LEFT JOIN by_model m ON 1=1  -- هنا ممكن تضبط join لو عايز تربط summary مع model أو تخليها مستقلة
LEFT JOIN by_model_ratio mr ON m.vehicle_model = mr.vehicle_model
LEFT JOIN by_day d ON 1=1
LEFT JOIN avg_by_weekday a ON 1=1
CROSS JOIN total_all t;

