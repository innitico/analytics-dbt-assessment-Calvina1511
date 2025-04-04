WITH provider_data AS (
    SELECT
        p.id AS provider_id,
        p.first_name,
        COALESCE(
            -- Aggregating address data into JSON array
            STRING_AGG(
                CASE 
                    WHEN a.id IS NOT NULL THEN
                        '{"address_id": ' || a.id || 
                        ', "street": "' || a.street || 
                        '", "rank": "' || a.rank || '"}'
                END,
                ','  -- Separate JSON objects by commas
            ),
            '[]'  -- Return an empty array if no addresses
        ) AS addresses
    FROM
        {{ ref('providers') }} p
    LEFT JOIN
        {{ ref('addresses') }} a ON p.id = a.id  -- Assuming address table has provider_id
    GROUP BY
        p.id, p.first_name
)

SELECT
    provider_id,
    first_name,
    -- Ensure the aggregated JSON string is returned as an array
    -- Here, we wrap it in `ARRAY[]` to ensure it returns an array in the result
    CASE
        WHEN addresses = '[]' THEN ARRAY[]::JSON[]  -- Empty array case
        ELSE STRING_TO_ARRAY(addresses, ',')::JSON[]  -- Convert to JSON array
    END AS addresses
FROM
    provider_data