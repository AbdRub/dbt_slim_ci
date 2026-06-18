{{ config(materialized='view') }}

SELECT
    tpep_pickup_datetime                AS pickup_at,
    tpep_dropoff_datetime               AS dropoff_at,
    trip_duration_mins,
    trip_distance,
    cost_per_mile,
    passenger_count,
    PULocationID                        AS pickup_location_id,
    DOLocationID                        AS dropoff_location_id,
    fare_amount,
    tip_amount,
    total_amount,
    payment_type,
    payment_type_label,
    rate_code_label,
    pickup_hour,
    pickup_day_of_week,
    _batch_id

FROM {{ source('raw', 'yellow_trips_raw') }}

WHERE fare_amount > 0
  AND total_amount > 0