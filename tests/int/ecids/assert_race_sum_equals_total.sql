select
    *
from {{ ref('public_postsecondary_enrollment_int') }}
where student_count != american_indian_count + asian_pacific_count + african_american_count + hispanic_latino_count + us_non_resident_count + multi_race_count + unknown_race_count + white_count