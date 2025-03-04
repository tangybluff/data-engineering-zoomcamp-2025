# Data Load Tool (DLT) in Data Engineering

## Introduction to DLT

The Data Load Tool (DLT) is a powerful utility designed to facilitate the process of data ingestion in data engineering pipelines. It simplifies the extraction, transformation, and loading (ETL) of data from various sources into a centralized data repository, such as a data warehouse or data lake.

## Key Features of DLT

- **Automated Data Ingestion**: DLT automates the process of ingesting data from multiple sources, reducing the need for manual intervention.
- **Scalability**: It can handle large volumes of data, making it suitable for big data applications.
- **Flexibility**: Supports various data formats and sources, including databases, APIs, and flat files.
- **Data Transformation**: Provides tools for transforming raw data into a structured format suitable for analysis.
- **Error Handling**: Includes robust error handling mechanisms to ensure data integrity and reliability.

## How DLT is Used in Data Engineering

### 1. Data Extraction

DLT connects to various data sources to extract raw data. These sources can include relational databases, NoSQL databases, cloud storage, APIs, and more. The tool supports different data formats such as CSV, JSON, XML, and Parquet.

**Why use DLT for extraction?**

- ✅ Built-in REST API support – Extract data from APIs with minimal code.
- ✅ Automatic pagination handling – No need to loop through pages manually.
- ✅ Manages Rate Limits & Retries – Prevents exceeding API limits and handles failures.
- ✅ Streaming support – Extracts and processes data without loading everything into memory.
- ✅ Seamless integration – Works with normalization and loading in a single pipeline.

**Install DLT**

Install DLT with DuckDB as destination:

```bash
pip install dlt[duckdb]
```

**Example of extracting data with DLT**

Instead of manually writing pagination logic, let’s use DLT’s RESTClient helper to extract NYC taxi ride data:

```python
import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator

def paginated_getter():
    client = RESTClient(
        base_url="https://us-central1-dlthub-analytics.cloudfunctions.net",
        paginator=PageNumberPaginator(
            base_page=1,
            total_path=None
        )
    )

    for page in client.paginate("data_engineering_zoomcamp_api"):
        yield page

for page_data in paginated_getter():
    print(page_data)
```

**How DLT simplifies API extraction:**

- 🔹 No manual pagination – DLT automatically fetches all pages of data.
- 🔹 Low memory usage – Streams data chunk by chunk, avoiding RAM overflows.
- 🔹 Handles rate limits & retries – Ensures requests are sent efficiently without failures.
- 🔹 Flexible destination support – Load extracted data into databases, warehouses, or data lakes.

### 2. Data Transformation/Normalization

Once the data is extracted, DLT provides capabilities to transform the data. This can include cleaning, filtering, aggregating, and enriching the data to meet the requirements of downstream processes. Transformations can be defined using SQL, Python, or other scripting languages.

**Data cleaning typically involves two key steps:**

- Normalizing data – Structuring and standardizing data without changing its meaning.
- Filtering data for a specific use case – Selecting or modifying data in a way that changes its meaning to fit the analysis.

**Data cleaning: more than just fixing errors**

A big part of data cleaning is actually metadata work — ensuring data is structured and standardized so it can be used effectively.

**Metadata tasks in data cleaning:**

- ✅ Add types – Convert strings to numbers, timestamps, etc.
- ✅ Rename columns – Ensure names follow a standard format (e.g., no special characters).
- ✅ Flatten nested dictionaries – Bring values from nested dictionaries into the top-level row.
- ✅ Unnest lists/arrays – Convert lists into child tables since they can’t be stored directly in a flat format.

**Why prepare data? Why not use JSON directly?**

While JSON is a great format for data transfer, it’s not ideal for analysis. Here’s why:

- ❌ No enforced schema – We don’t always know what fields exist in a JSON document.
- ❌ Inconsistent data types – A field like age might appear as 25, "twenty five", or 25.00, which can break downstream applications.
- ❌ Hard to process – If we need to group data by day, we must manually convert date strings to timestamps.
- ❌ Memory-heavy – JSON requires reading the entire file into memory, unlike databases or columnar formats that allow scanning just the necessary fields.
- ❌ Slow for aggregation and search – JSON is not optimized for quick lookups or aggregations like columnar formats (e.g., Parquet).

JSON is great for data exchange but not for direct analytical use. To make data useful, we need to normalize it — flattening, typing, and structuring it for efficiency.

**Normalizing data with DLT**

**Why use DLT for normalization?**

- ✅ Automatically detects schema – No need to define column types manually.
- ✅ Flattens nested JSON – Converts complex structures into table-ready formats.
- ✅ Handles data type conversion – Converts dates, numbers, and booleans correctly.
- ✅ Splits lists into child tables – Ensures relational integrity for better analysis.
- ✅ Schema evolution support – Adapts to changes in data structure over time.

**Example**

Let's assume we extracted the following raw NYC taxi ride data, which contains nested dictionaries and lists:

```python
data = [
    {
        "vendor_name": "VTS",
        "record_hash": "b00361a396177a9cb410ff61f20015ad",
        "time": {
            "pickup": "2009-06-14 23:23:00",
            "dropoff": "2009-06-14 23:48:00"
        },
        "coordinates": {
            "start": {"lon": -73.787442, "lat": 40.641525},
            "end": {"lon": -73.980072, "lat": 40.742963}
        },
        "passengers": [
            {"name": "John", "rating": 4.9},
            {"name": "Jack", "rating": 3.9}
        ]
    }
]
```

**How DLT normalizes this data automatically**

Instead of manually flattening fields and extracting nested lists, we can load it directly into DLT:

```python
import dlt

pipeline = dlt.pipeline(
    pipeline_name="ny_taxi_data",
    destination="duckdb",
    dataset_name="taxi_rides",
)

info = pipeline.run(data, table_name="rides", write_disposition="replace")

print(info)
print(pipeline.last_trace)
```

**What happens behind the scenes?**

After running this pipeline, DLT automatically transforms the data into the following normalized structure:

**Main table: rides**

```python
pipeline.dataset(dataset_type="default").rides.df()
```

| vendor_name | record_hash | time__pickup         | time__dropoff        | coordinates__start__lon | coordinates__start__lat | coordinates__end__lon | coordinates__end__lat | _dlt_load_id      | _dlt_id          |
|-------------|-------------|----------------------|----------------------|-------------------------|-------------------------|-----------------------|-----------------------|-------------------|------------------|
| VTS         | b00361a396177a9cb410ff61f20015ad | 2009-06-14 23:23:00+00:00 | 2009-06-14 23:48:00+00:00 | -73.787442              | 40.641525              | -73.980072            | 40.742963            | 1738604244.2625916 | k+bnoLuti245ag |

This table displays structured taxi ride data, including vendor details, timestamps, coordinates, and DLT metadata.

**Child Table: rides_passengers**

```python
pipeline.dataset(dataset_type="default").rides__passengers.df()
```

| name | rating | _dlt_parent_id | _dlt_list_idx | _dlt_id          |
|------|--------|----------------|---------------|------------------|
| John | 4.9    | k+bnoLuti245ag | 0             | 8ppDh+8gQ7SSHg   |
| Jack | 3.9    | k+bnoLuti245ag | 1             | oQnWuvkgHhxlaA   |

- ✅ Nested structures were flattened into separate columns.
- ✅ Lists were extracted into child tables, preserving relationships.
- ✅ Timestamps were converted to the correct format.

**Why DLT makes normalization easy**

- 🔹 No manual transformations needed – Just load the raw data, and DLT does the rest!
- 🔹 Database-ready format – Ensures clean, structured tables for easy querying.
- 🔹 Handles schema evolution – Adapts to new fields automatically.
- 🔹 Scales effortlessly – Works for small datasets and enterprise-scale pipelines.

💡 With DLT, normalization happens automatically, so you can focus on insights instead of data wrangling.

### 3. Data Loading

After transformation, the data is loaded into a target data repository. This could be a data warehouse like Amazon Redshift, Google BigQuery, or Snowflake, or a data lake such as Amazon S3 or Azure Data Lake Storage. DLT ensures that the data is loaded efficiently and accurately.

The final step is loading the data into a destination. This is where the processed data is stored, making it ready for querying, analysis, or further transformations.

**How data loading happens without DLT**

Before DLT, data engineers had to manually handle schema validation, batch processing, error handling, and retries for every destination. This process becomes especially complex when loading data into data warehouses and data lakes, where performance optimization, partitioning, and incremental updates are critical.

**Problems without DLT:**

- ❌ Schema management is manual – If the schema changes, you need to update table structures manually.
- ❌ No automatic retries – If the network fails, data may be lost.
- ❌ No incremental loading – Every run reloads everything, making it slow and expensive.
- ❌ More code to maintain – A simple pipeline quickly becomes complex.

**How DLT handles the load step automatically**

With DLT, loading data requires just a few lines of code — schema inference, error handling, and incremental updates are all handled automatically!

**Why use DLT for loading?**

- ✅ Supports multiple destinations – Load data into BigQuery, Redshift, Snowflake, Postgres, DuckDB, Parquet (S3, GCS) and more.
- ✅ Optimized for performance – Uses batch loading, parallelism, and streaming for fast and scalable data transfer.
- ✅ Schema-aware – Ensures that column names, data types, and structures match the destination’s requirements.
- ✅ Incremental loading – Avoids unnecessary reloading by only inserting new or updated records.
- ✅ Resilience & retries – Automatically handles failures, ensuring data is loaded without missing records.

### Example: Loading Data into a Database with DLT

To leverage the full power of DLT, it is recommended to wrap your API Client in the `@dlt.resource` decorator. This decorator denotes a logical grouping of data within a data source, typically holding data of similar structure and origin:

```python
import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator

# Define the API resource for NYC taxi data
@dlt.resource(name="rides")  # The name of the resource (will be used as the table name)
def ny_taxi():
    client = RESTClient(
        base_url="https://us-central1-dlthub-analytics.cloudfunctions.net",
        paginator=PageNumberPaginator(
            base_page=1,
            total_path=None
        )
    )

    for page in client.paginate("data_engineering_zoomcamp_api"):  # API endpoint for retrieving taxi ride data
        yield page  # Yield data to manage memory

# Define new DLT pipeline
pipeline = dlt.pipeline(destination="duckdb")

# Run the pipeline with the new resource
load_info = pipeline.run(ny_taxi, write_disposition="replace")
print(load_info)

# Explore loaded data
pipeline.dataset(dataset_type="default").rides.df()
```

Done! The data is now stored in DuckDB, with the schema managed automatically!

## Incremental Loading

Incremental loading allows us to update datasets by loading only new or changed data, instead of replacing the entire dataset. This makes pipelines faster and more cost-effective by reducing redundant data processing.

### How does incremental loading work?

Incremental loading works alongside two key concepts:

- **Incremental extraction**: Only extracts the new or modified data rather than retrieving everything again.
- **State tracking**: Keeps track of what has already been loaded, ensuring that only new data is processed.

In DLT, state is stored in a separate table at the destination, allowing pipelines to track what has been processed.

🔹 Want to learn more? You can read about incremental extraction and state management in the DLT documentation.

### Incremental loading methods in DLT

DLT provides two ways to load data incrementally:

1. **Append (adding new records)**
    - Best for immutable or stateless data, such as taxi ride records.
    - Each run adds new records without modifying previous data.
    - Can also be used to create a history of changes (slowly changing dimensions).

    **Example**:
    - If taxi ride data is loaded daily, only new rides are added, rather than reloading the full history.
    - If tracking changes in a list of vehicles, each version is stored as a new row for auditing.

2. **Merge (updating existing records)**
    - Best for updating existing records (stateful data).
    - Replaces old records with updated ones based on a unique key.
    - Useful for tracking status changes, such as payment updates.

    **Example**:
    - A taxi ride's payment status could change from "booked" to "cancelled", requiring an update.
    - A customer profile might be updated with a new email or phone number.

### Choosing between Append and Merge

| Scenario | Use Append | Use Merge |
|----------|------------|-----------|
| Immutable records (e.g., ride history) | ✅ Yes | ❌ No |
| Tracking historical changes (slowly changing dimensions) | ✅ Yes | ❌ No |
| Updating existing records (e.g., payment status) | ❌ No | ✅ Yes |
| Keeping full change history | ✅ Yes | ❌ No |

### Example: Incremental loading with DLT

The goal: download only trips made after June 15, 2009, skipping the old ones.

Using DLT, we set up an incremental filter to only fetch trips made after a certain date:

```python
cursor_date = dlt.sources.incremental("Trip_Dropoff_DateTime", initial_value="2009-06-15")
```

This tells DLT:
- **Start date**: June 15, 2009 (initial_value).
- **Field to track**: Trip_Dropoff_DateTime (our timestamp).

As you run the pipeline repeatedly, DLT will keep track of the latest `Trip_Dropoff_DateTime` value processed. It will skip records older than this date in future runs.
Let's make the data resource incremental using `dlt.sources.incremental`:

```python
import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator

@dlt.resource(name="rides", write_disposition="append")
def ny_taxi(
    cursor_date=dlt.sources.incremental(
        "Trip_Dropoff_DateTime",   # <--- field to track, our timestamp
        initial_value="2009-06-15",   # <--- start date June 15, 2009
        )
    ):
    client = RESTClient(
        base_url="https://us-central1-dlthub-analytics.cloudfunctions.net",
        paginator=PageNumberPaginator(
            base_page=1,
            total_path=None
        )
    )

    for page in client.paginate("data_engineering_zoomcamp_api"):
        yield page
```

Finally, we run our pipeline and load the fresh taxi rides data:

```python
# define new dlt pipeline
pipeline = dlt.pipeline(pipeline_name="ny_taxi", destination="duckdb", dataset_name="ny_taxi_data")

# run the pipeline with the new resource
load_info = pipeline.run(ny_taxi)
print(pipeline.last_trace)
```

Only 5325 rows were filtered out and loaded into the DuckDB destination. Let's take a look at the earliest date in the loaded data:

```python
with pipeline.sql_client() as client:
    res = client.execute_sql(
            """
            SELECT
            MIN(trip_dropoff_date_time)
            FROM rides;
            """
        )
    print(res)
```

Run the same pipeline again.

```python
# define new dlt pipeline
pipeline = dlt.pipeline(pipeline_name="ny_taxi", destination="duckdb", dataset_name="ny_taxi_data")

# run the pipeline with the new resource
load_info = pipeline.run(ny_taxi)
print(pipeline.last_trace)
```

The pipeline will detect that there are no new records based on the `Trip_Dropoff_DateTime` field and the incremental cursor. As a result, no new data will be loaded into the destination:

```
0 load package(s) were loaded
```

💡 With DLT, incremental loading is simple, scalable, and automatic!

### Example: Loading Data into a Data Warehouse (BigQuery)

First, install the dependencies, define the source, then change the destination name and run the pipeline.

```bash
pip install dlt[bigquery]
```

Let's use our NY Taxi API and load data from the source into the destination.

```python
import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator

@dlt.resource(name="rides", write_disposition="replace")
def ny_taxi():
    client = RESTClient(
        base_url="https://us-central1-dlthub-analytics.cloudfunctions.net",
        paginator=PageNumberPaginator(
            base_page=1,
            total_path=None
        )
    )

    for page in client.paginate("data_engineering_zoomcamp_api"):
        yield page
```

#### Choosing a Destination

Switching between data warehouses (BigQuery, Snowflake, Redshift) or data lakes (S3, Google Cloud Storage, Parquet files) in DLT is incredibly straightforward — simply modify the destination parameter in your pipeline configuration.

For example:

```python
pipeline = dlt.pipeline(
    pipeline_name='taxi_data',
    destination='duckdb',  # <--- to test pipeline locally
    dataset_name='taxi_rides',
)

pipeline = dlt.pipeline(
    pipeline_name='taxi_data',
    destination='bigquery',  # <--- to run pipeline in production
    dataset_name='taxi_rides',
)
```

This flexibility allows you to easily transition from local development to production-grade environments.

💡 No need to rewrite your pipeline — DLT adapts automatically!

#### Set Credentials

The next logical step is to set credentials using DLT's TOML providers or environment variables (ENVs).

```python
import os
from google.colab import userdata

os.environ["DESTINATION__BIGQUERY__CREDENTIALS"] = userdata.get('BIGQUERY_CREDENTIALS')
```

#### Run the Pipeline

```python
pipeline = dlt.pipeline(
    pipeline_name="taxi_data",
    destination="bigquery",
    dataset_name="taxi_rides",
    dev_mode=True,
)

info = pipeline.run(ny_taxi)
print(info)
```

💡 What’s different?

- DLT automatically adapts the schema to fit BigQuery.
- Partitioning & clustering can be applied for performance optimization.
- Efficient batch loading ensures scalability.


## Conclusion

The Data Load Tool (DLT) is an essential component of modern data engineering pipelines. It streamlines the process of data ingestion, making it easier to manage and process large volumes of data. By automating data extraction, transformation, and loading, DLT helps data engineers focus on more strategic tasks, ultimately leading to more efficient and reliable data workflows.
