select
    segment,
    institution,
    fall_enrolled_at_year,
    student_count,
    female_count,
    female_percentage,
    male_count,
    male_percentage,
    unknown_gender_count,
    unknown_gender_percentage,
    american_indian_count,
    american_indian_percentage,
    asian_pacific_count,
    asian_pacific_percentage,
    african_american_count,
    african_american_percentage,
    hispanic_latino_count,
    hispanic_latino_percentage,
    us_non_resident_count,
    us_non_resident_percentage,
    multi_race_count,
    multi_race_percentage,
    unknown_race_count,
    unknown_race_percentage,
    white_count,
    white_percentage
from {{ ref('public_postsecondary_enrollment_report') }}