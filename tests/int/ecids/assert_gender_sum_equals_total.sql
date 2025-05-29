select
    *
from {{ ref('public_postsecondary_enrollment_int') }}
where student_count != female_count + male_count + unknown_gender_count