select
    segment,
    institution,
    year_fall_term as fall_enrolled_at_year,
    student_cnt as student_count,
    female_cnt as female_count,
    male_cnt as male_count,
    unkngender_cnt as unknown_gender_count,
    amerind_cnt as american_indian_count,
    aapi_cnt as asian_pacific_count,
    aframer_cnt as african_american_count,
    hisplat_cnt as hispanic_latino_count,
    usnonres_cnt as us_non_resident_count,
    multirace_cnt as multi_race_count,
    unknrace_cnt as unknown_race_count,
    white_cnt as white_count
from {{ source('ecids', 'public_postsecondary_enrollment') }}