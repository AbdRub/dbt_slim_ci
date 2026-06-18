{{ config(materialized='table') }}

WITH base AS (
    SELECT * FROM {{ ref('stg_yellow_trips') }}
),

hourly_agg AS (
    SELECT
        pickup_hour,
        COUNT(*)                                        AS total_trips,
        SUM(passenger_count)                            AS total_passengers,
        ROUND(SUM(fare_amount), 2)                      AS total_fare_revenue,
        ROUND(AVG(fare_amount), 2)                      AS avg_fare_amount,
        ROUND(SUM(tip_amount), 2)                       AS total_tips,
        ROUND(AVG(tip_amount), 2)                       AS avg_tip_amount,
        ROUND(SUM(total_amount), 2)                     AS total_revenue,
        ROUND(AVG(trip_distance), 2)                    AS avg_trip_distance,
        ROUND(AVG(trip_duration_mins), 2)               AS avg_trip_duration_mins,
        ROUND(AVG(cost_per_mile), 2)                    AS avg_cost_per_mile,
        ROUND(
            100.0 * SUM(CASE WHEN tip_amount > 0 THEN 1 ELSE 0 END) / COUNT(*),
            1
        )                                               AS tip_rate_pct
    FROM base
    GROUP BY pickup_hour
)

SELECT
    pickup_hour,
    total_trips,
    total_passengers,
    total_fare_revenue,
    avg_fare_amount,
    total_tips,
    avg_tip_amount,
    total_revenue,
    avg_trip_distance,
    avg_trip_duration_mins,
    avg_cost_per_mile,
    tip_rate_pct,
    RANK() OVER (ORDER BY total_trips DESC)             AS demand_rank
FROM hourly_agg
ORDER BY pickup_hour