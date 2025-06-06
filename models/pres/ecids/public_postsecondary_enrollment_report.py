import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col, bround

def model(dbt, session):
    dbt.config(materialized="table")

    df = dbt.ref("public_postsecondary_enrollment_int")

    result_df = df.select(
        col("segment"),
        col("institution"),
        col("fall_enrolled_at_year"),
        col("student_count"),
        col("female_count"),
        bround(col("female_count") / col("student_count"), 2).alias("female_percentage"),
        col("male_count"),
        bround(col("male_count") / col("student_count"), 2).alias("male_percentage"),
        col("unknown_gender_count"),
        bround(col("unknown_gender_count") / col("student_count"), 2).alias("unknown_gender_percentage"),
        col("american_indian_count"),
        bround(col("american_indian_count") / col("student_count"), 2).alias("american_indian_percentage"),
        col("asian_pacific_count"),
        bround(col("asian_pacific_count") / col("student_count"), 2).alias("asian_pacific_percentage"),
        col("african_american_count"),
        bround(col("african_american_count") / col("student_count"), 2).alias("african_american_percentage"),
        col("hispanic_latino_count"),
        bround(col("hispanic_latino_count") / col("student_count"), 2).alias("hispanic_latino_percentage"),
        col("us_non_resident_count"),
        bround(col("us_non_resident_count") / col("student_count"), 2).alias("us_non_resident_percentage"),
        col("multi_race_count"),
        bround(col("multi_race_count") / col("student_count"), 2).alias("multi_race_percentage"),
        col("unknown_race_count"),
        bround(col("unknown_race_count") / col("student_count"), 2).alias("unknown_race_percentage"),
        col("white_count"),
        bround(col("white_count") / col("student_count"), 2).alias("white_percentage"),
    )

    return result_df
