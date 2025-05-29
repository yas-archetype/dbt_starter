# DBT Project User Manual

## Table of Contents
1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [Local Setup](#local-setup)
4. [Working with DBT](#working-with-dbt)
5. [Development Guidelines](#development-guidelines)
6. [Deployment and CI/CD](#deployment-and-cicd)
7. [Troubleshooting](#troubleshooting)

## Project Overview

This dbt project is designed to transform and model data in Snowflake, following a modular and maintainable architecture. It implements a three-layer approach (raw, intermediate, and presentation) for data transformation, with clear separation of concerns and robust testing.

## Project Structure

### Root Directory
```
dbt_starter/
├── models/              # Core transformation models
├── snowflake/          # Snowflake infrastructure configuration
├── macros/             # Reusable SQL macros
├── tests/              # Data quality tests
├── seeds/              # Static data files
├── snapshots/          # Type 2 SCD tracking
├── analyses/           # Ad-hoc analyses
├── cicd/               # CI/CD configuration
├── dbt_project.yml     # Project configuration
├── profiles.yml        # Connection profiles
├── requirements.txt    # Python dependencies
└── .env_sample        # Environment variables template
```

### Key Directories and Files

#### `models/`
- `raw/`: Contains source definitions and initial data models
  - `sap_sources.yml`: Defines SAP source tables and their configurations
- `int/`: Intermediate transformations
  - Located in `int` database
  - Complex business logic and transformations
- `pres/`: Presentation layer
  - Located in `pres` database
  - Final models for end-user consumption

#### `snowflake/`
- `ci_cd.sql`: CI/CD related Snowflake objects
- `database_warehouse.sql`: Database and warehouse setup
- `fivetran.sql`: Fivetran integration configuration
- `network_policy.sql`: Network security policies
- `resource_monitor.sql`: Resource monitoring setup
- `rbac.sql`: Role-based access control configuration

#### `macros/`
- Custom SQL functions and transformations
- Reusable business logic
- Environment-specific configurations

#### `tests/`
- Data quality tests
- Schema tests
- Custom data tests

#### `seeds/`
- Static data files
- Reference data
- Lookup tables

#### `snapshots/`
- Type 2 Slowly Changing Dimension (SCD) tracking
- Historical data preservation

#### `analyses/`
- Ad-hoc analyses
- One-off queries
- Data exploration

#### `cicd/`
- CI/CD pipeline configurations

## Local Setup

### Prerequisites
1. Python 3.8 or higher
2. Git
3. Access to Snowflake instance
4. Private key for Snowflake authentication

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd dbt_starter
   ```

2. **Set Up Virtual Environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Configure Environment Variables**
   ```bash
   cp .env_sample .env
   ```
   Edit `.env` with your Snowflake credentials:
   ```
   SNOWFLAKE_ACCOUNT=BTRGALG-LIFEISGOOD
   SNOWFLAKE_DATABASE=<your_database>
   SNOWFLAKE_PRIVATE_KEY_PATH=<path_to_key>
   SNOWFLAKE_PRIVATE_KEY_PASSPHRASE=<key_passphrase>
   SNOWFLAKE_ROLE=<your_role>
   SNOWFLAKE_SCHEMA=<your_schema>
   SNOWFLAKE_USER=<your_username>
   SNOWFLAKE_WAREHOUSE=<your_warehouse>
   ```

4. **Verify Connection**
   ```bash
   source .env  # On Windows: set -a; source .env; set +a
   dbt debug
   ```

## Working with DBT

### Understanding profiles.yml

The `profiles.yml` file defines the connection configurations for different environments (targets). By default, the project is configured to use the `dev` target, but you can override this using the `--target` flag if your role has enough privileges for that environment.

```yaml
dbt_starter:
  target: dev  # Default target
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE') }}"
      database: "{{ env_var('SNOWFLAKE_DATABASE') }}"
      warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE') }}"
      schema: "{{ env_var('SNOWFLAKE_SCHEMA') }}"
      private_key_path: "{{ env_var('SNOWFLAKE_PRIVATE_KEY_PATH') }}"
      private_key_passphrase: "{{ env_var('SNOWFLAKE_PRIVATE_KEY_PASSPHRASE') }}"
    
    prod:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE') }}"
      database: "{{ env_var('SNOWFLAKE_DATABASE') }}"
      warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE') }}"
      schema: "{{ env_var('SNOWFLAKE_SCHEMA') }}"
      private_key_path: "{{ env_var('SNOWFLAKE_PRIVATE_KEY_PATH') }}"
      private_key_passphrase: "{{ env_var('SNOWFLAKE_PRIVATE_KEY_PASSPHRASE') }}"
```

#### Important Notes
   - Ensure your role has appropriate access to the target environment
   - Different environments may require different environment variables
   - Update `.env` file with appropriate values for each target
   - Consider using different `.env` files for different environments
   - Always test in dev before deploying to prod




### Adding New Models

1. **Raw Layer Models**
   - Create new source definitions in `models/raw/<source_name>_sources.yml`
   ```yaml
   sources:
     - name: <source_name>
       database: "{{ target.name }}_raw"
       schema: <schema_name>    
       tables:
         - name: <table_name>
   ```

2. **Intermediate Models**
   - Create in `models/int/<sub_directory>`
   - Each sub_directory is mapped to a snowflake schema which is configured in dbt_project.yml (please refer to project configuration below)
   - Use table materialization
   - Follow naming convention: `<domain>_<purpose>_int` for models that perform simple cleaning and transformations and `<domain>_<purpose>_agg` for models that perform aggregations to prepare the model for presentation layer

3. **Presentation Models**
   - Create in `models/pres/<sub_directory>`
   - Each sub_directory is mapped to a snowflake schema which is configured in dbt_project.yml (please refer to project configuration below)
   - Use table materialization
   - Follow naming convention: `dim_<business_entity>` and `fact_<business_entity>` and `report_<report_name>`

### Adding Tests
Create tests in `tests/` directory following guidelines below. 

1. **Schema Tests**

Create a file named `schema_test_<business_domain>.yml` and add dbt schema tests such as:
   ```yaml
   version: 2
   models:
     - name: <model_name>
       columns:
         - name: <column_name>
           tests:
             - unique
             - not_null
   ```

2. **Custom Tests**

Create a file named `assert_<test_description>.sql` and add dbt singular test such as:
   ```sql
   -- tests/assert_condition_is_false.sql
   select *
   from {{ ref('your_model') }}
   where condition = false
   ```

### Using Macros

Add custom macros in `macros/` directory to automate and standardize tasks. There are two fundamental custom macros that are responsible for ensuring models are created in the correct data transformation layer:

1. `generate_database_name.sql`

    This macro controls how database names are generated for your models. It follows a pattern where if a custom database name is specified, it prepends the target name (like 'dev' or 'prod') to the custom database name. If no custom database name is provided, it uses the default target database. This ensures consistent database naming across different environments

2. `generate_schema_name.sql`

    This macro manages schema naming conventions. When a custom schema name is provided, it uses that name directly. Otherwise, it falls back to the target schema specified in your dbt configuration.

### DBT Commands

1. **Development**
   ```bash
   dbt run --select model_name  # Run specific model
   dbt test --select model_name  # Test specific model
   dbt run --models +model_name  # Run model and dependencies
   ```

2. **Environment Selection**
   ```bash
   dbt run --target dev  # Development environment
   dbt run --target prod  # Production environment
   ```

3. **Full Refresh**
   ```bash
   dbt run --full-refresh  # Rebuild all models (for incremental models)
   ```

4. **Documentation**
   ```bash
   dbt docs generate  # Generate documentation
   dbt docs serve  # Serve documentation locally
   ```

### Configuration in dbt_project.yml

1. **Model Configurations**

    The `dbt_project.yml` file is the central configuration file for the dbt project and is where dbt behavior is defined for each part of the project. When a new subdirectory is created in the models directory, the configuration for it's behavior should be defined it in the dbt_project.yml file under the models section.
   ```yaml
   models:
     dbt_starter:
       pres:
         +database: pres
         +materialized: table
         +transient: false
         wholesale:
           +schema: wholesale
         <new_sub_directory>:  # New subdirectory
           +schema: <schema_name>
   ```

## Development Guidelines


### Best Practices

1. **Code Organization**
   - Keep models focused and single-purpose
   - Use CTEs for complex transformations
   - Document complex logic

2. **Testing**
   - Test all models
   - Include both schema and custom tests
   - Test edge cases

3. **Documentation**
   - Document all models
   - Include business logic explanations
   - Document assumptions

## Deployment and CI/CD

### Manual Deployment

1. **Development**
   ```bash
   dbt run --target dev
   dbt test --target dev
   ```

2. **Production**
   ```bash
   dbt run --target prod
   dbt test --target prod
   ```

### Automated Deployment (Bitbucket Pipeline)

The pipeline configuration is defined in `bitbucket-pipelines.yml` and the profile configuration for the CI/CD service user is defined in `cicd/`. The environment variables are added as repository variables in Bitbucket.

1. **Scheduled Runs**
   - Daily at 7 AM PST
   - Production environment
   - Full model run to update production tables

2. **Manual Triggers**
   - Environment selection
   - Full or partial runs
   - Test runs
