-- create a custom role
use role useradmin;
create role data_scientist;

-- grant the role to myself so I can use it
set my_current_user = current_user();
grant role data_scientist to user identifier($my_current_user);

-- create a warehouse, database, schema, and grant privileges
use role sysadmin;
create database ml_db;
grant usage on database ml_db to role data_scientist;
create schema credit_scoring;
grant all on schema credit_scoring to role data_scientist;
create warehouse data_science_wh with warehouse_size = 'xsmall';
grant usage on warehouse data_science_wh to role data_scientist;

-- grant the classification model privilege
grant create SNOWFLAKE.ML.CLASSIFICATION 
  on schema ml_db.credit_scoring 
  to role data_scientist;

-- continue working with the newly created role
use role data_scientist;
use warehouse data_science_wh;
use database ml_db;
use schema credit_scoring;

-- internal stage
create stage credit_scoring_data;
-- upload train.csv from https://www.kaggle.com/datasets/parisrohan/credit-score-classification/

create or replace file format my_csv_format type=csv, parse_header=true, field_optionally_enclosed_by='"';

CREATE or replace TABLE demo_data
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    WITHIN GROUP (ORDER BY order_id)
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@credit_scoring_data/train.csv',
          FILE_FORMAT=>'my_csv_format'
        )
      ));

copy into demo_data
from @credit_scoring_data/train.csv file_format=my_csv_format match_by_column_name = case_insensitive;
