{{ config(materialized='table') }}

WITH base AS (
    SELECT * FROM {{ ref('stg_yellow_trips') }}
)

SELECT
    payment_type_label,
    COUNT(*)                                            AS total_trips,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_trips,
    ROUND(AVG(fare_amount), 2)                          AS avg_fare,
    ROUND(AVG(tip_amount), 2)                           AS avg_tip,
    ROUND(AVG(total_amount), 2)                         AS avg_total,
    ROUND(SUM(total_amount), 2)                         AS total_revenue,
    ROUND(
        100.0 * SUM(tip_amount) / NULLIF(SUM(fare_amount), 0),
        2
    )                                                   AS tip_pct_of_fare,
    ROUND(total_revenue / NULLIF(total_trips, 0), 2)    AS avg_revenue_per_trip
FROM base
GROUP BY payment_type_label
ORDER BY total_trips DESC