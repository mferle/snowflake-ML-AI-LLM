-- setup the Snowflake environment

-- create a role
use role useradmin;
create role developer;
grant role developer to role sysadmin;

-- create a database, a schema, and a virtual warehouse
use role sysadmin;
create database demo_db;
create schema work;
create warehouse developer_wh;

-- grant usage on the database, schema, and warehouse to the role
use role sysadmin;
grant all on database demo_db to role developer;
grant all on schema work to role developer;
grant usage on warehouse developer_wh to role developer;

-- grant the USAGE_VIEWER database role to allow viewing usage
use role accountadmin;
grant database role SNOWFLAKE.USAGE_VIEWER to role developer;

use role developer;
