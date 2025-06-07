SELECT *
FROM {{ ref('public_postsecondary_enrollment_report') }}
WHERE ROUND(
    american_indian_percentage +
    asian_pacific_percentage +
    african_american_percentage +
    hispanic_latino_percentage +
    us_non_resident_percentage +
    multi_race_percentage +
    unknown_race_percentage +
    white_percentage,
    4
) != 1.0
