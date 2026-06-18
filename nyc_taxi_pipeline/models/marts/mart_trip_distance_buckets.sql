{{ config(materialized='table') }}

WITH base AS (
    SELECT * FROM {{ ref('stg_yellow_trips') }}
),

bucketed AS (
    SELECT
        CASE
            WHEN trip_distance < 1   THEN '0-1 miles'
            WHEN trip_distance < 3   THEN '1-3 miles'
            WHEN trip_distance < 5   THEN '3-5 miles'
            WHEN trip_distance < 10  THEN '5-10 miles'
            WHEN trip_distance < 20  THEN '10-20 miles'
            ELSE '20+ miles'
        END                          AS distance_band,
        CASE
            WHEN trip_distance < 1   THEN 1
            WHEN trip_distance < 3   THEN 2
            WHEN trip_distance < 5   THEN 3
            WHEN trip_distance < 10  THEN 4
            WHEN trip_distance < 20  THEN 5
            ELSE 6
        END                          AS sort_order,
        fare_amount,
        tip_amount,
        total_amount,
        trip_duration_mins
    FROM base
),

agg AS (
    SELECT
        distance_band,
        sort_order,
        COUNT(*)                            AS total_trips,
        ROUND(AVG(fare_amount), 2)          AS avg_fare,
        ROUND(AVG(tip_amount), 2)           AS avg_tip,
        ROUND(AVG(trip_duration_mins), 2)   AS avg_duration_mins,
        ROUND(SUM(total_amount), 2)         AS total_revenue
    FROM bucketed
    GROUP BY distance_band, sort_order
)

SELECT
    distance_band,
    total_trips,
    ROUND(100.0 * total_trips / SUM(total_trips) OVER (), 2) AS pct_of_all_trips,
    avg_fare,
    avg_tip,
    avg_duration_mins,
    total_revenue
FROM agg
ORDER BY sort_order