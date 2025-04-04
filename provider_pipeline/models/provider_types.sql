WITH provider_degree_data AS (
    SELECT
        p.id AS provider_id,
        p.first_name,
        -- Assuming 'degree_type' in providers contains comma-separated degree, rank pairs
        unnest(string_to_array(p.degrees, ',')) AS degree_rank
    FROM
        {{ ref('providers') }} p
),
ranked_degrees AS (
    SELECT
        provider_id,
        first_name,
        degree_rank,
        -- Assuming degree_rank is of format 'degree_rank' and rank is the numeric value
        -- You can split it further depending on your actual structure.
        CAST(split_part(degree_rank, '_', 2) AS INTEGER) AS rank,  -- Extracting rank (assuming format is 'degree_rank')
        split_part(degree_rank, '_', 1) AS degree  -- Extracting degree (assuming format is 'degree_rank')
    FROM
        provider_degree_data
),
lowest_rank_degrees AS (
    SELECT
        provider_id,
        first_name,
        degree,
        rank,
        -- Find the degree with the lowest rank for each provider
        ROW_NUMBER() OVER (PARTITION BY provider_id ORDER BY rank ASC) AS row_num
    FROM
        ranked_degrees
)
SELECT
    d.provider_id,
    d.first_name,
    -- Select ptui for the degree with the lowest rank (row_num = 1)
    dt.ptui
FROM
    lowest_rank_degrees d
JOIN
    {{ ref('degree_types') }} dt
    ON d.degree = dt.degree
WHERE
    d.row_num = 1