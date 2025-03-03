# Module 1A: Docker & PostgreSQL Setup

## 1. Docker Setup: Initial Commands

### PostgreSQL Container:
A PostgreSQL container is created with the following command:

```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v c:/Users/ahmed/Desktop/data-engineering-zoomcamp-2025/week_1/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:13
```
The database is initialized with root as the user and password, and a database called `ny_taxi`.

### PostgreSQL CLI:
To connect to PostgreSQL from the terminal, use:

```bash
pgcli -h localhost -p 5431 -u root -d ny_taxi
```

### pgAdmin Setup:
Run the pgAdmin container to manage PostgreSQL visually:

```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    dpage/pgadmin4
```

### Network Setup:
Create a Docker network to connect PostgreSQL and pgAdmin containers:

```bash
docker network create pg-network
```

## 2. Dockerized PostgreSQL and pgAdmin Setup

### PostgreSQL Container with Network:
This command starts a PostgreSQL container and connects it to the `pg-network` network:

```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v "./ny-taxi-volume:/var/lib/postgresql/data" \
    -p 5431:5432 \
    --network=pg-network \
    --name pg-database \
    postgres:13
```

### pgAdmin Container with Network:
Similarly, start the pgAdmin container and link it to the same network:

```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    --network=pg-network \
    --name pgadmin \
    dpage/pgadmin4
```

## 3. Python Ingestion Script

### Manual Data Ingestion:
Download data and ingest into PostgreSQL using the following command:

```bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

python ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5431 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url=${URL}
```

## 4. Dockerizing the Ingestion Script

### Dockerfile for Python Ingestion Script:
A Dockerfile is used to create a Docker image for the ingestion script:

```dockerfile
FROM python:3.9

RUN apt-get install wget 
RUN pip install pandas sqlalchemy psycopg2

WORKDIR /app
COPY ingest_data.py ingest_data.py

ENTRYPOINT [ "python", "ingest_data.py" ]
```

### Building the Docker Image:
To build the Docker image for the ingestion script:

```bash
docker build -t taxi_ingest:v001 .
```

### Running the Dockerized Ingestion Script:
After building the image, run it with:

```bash
docker run -it \
    --network=pg-network \
    taxi_ingest:v001 \
        --user=root \
        --password=root \
        --host=pg-database \
        --port=5432 \
        --db=ny_taxi \
        --table_name=yellow_taxi_trips \
        --url=${URL}
```

## 5. Docker Compose for Automation

### docker-compose.yml:
A `docker-compose.yml` file is used to automate running PostgreSQL and pgAdmin containers:

```yaml
services:
    pgdatabase:
        image: postgres:13
        environment:
            - POSTGRES_USER=root
            - POSTGRES_PASSWORD=root
            - POSTGRES_DB=ny_taxi
        volumes:
            - "./ny_taxi_postgres_data:/var/lib/postgresql/data:rw"
        ports:
            - "5431:5432"
    pgadmin:
        image: dpage/pgadmin4
        environment:
            - PGADMIN_DEFAULT_EMAIL=admin@admin.com
            - PGADMIN_DEFAULT_PASSWORD=root
        ports:
            - "8080:80"
```

## 6. Python Ingestion Script Breakdown

### Ingestion Logic:
The `ingest_data.py` script does the following:
- Downloads the CSV file from a given URL using `wget`.
- Uses Pandas to process the data in chunks (100,000 rows at a time) to avoid memory overload.
- Converts timestamps to datetime objects.
- Inserts data into the PostgreSQL database in chunks using SQLAlchemy.

### Key functions:
- `pd.read_csv()` with `iterator=True` and `chunksize=100000` for chunking the data.
- `df.to_sql()` inserts the data into the specified PostgreSQL table.

## Overall Summary

### Manual Workflow:
The manual workflow is where you don't automate the ingestion process. Here’s what you would do:

#### Declare the URL:
You manually declare the URL of the CSV file you want to ingest in the ingestion script (`ingest_data.py`).

#### Run the Ingestion Script:
You manually run the ingestion script in your terminal:

```bash
python ingest_data.py \
  --user=root \
  --password=root \
  --host=localhost \
  --port=5431 \
  --db=ny_taxi \
  --table_name=yellow_taxi_trips \
  --url=${URL}
```
This requires you to manually handle the data ingestion process each time you want to load new data.

### Automated Workflow (with Docker):
In the automated workflow, you don’t manually run the ingestion script. Instead, Docker handles everything for you.

#### Run Docker Compose:
First, run the following command to start the PostgreSQL and pgAdmin containers:

```bash
docker-compose up
```

#### Run the Dockerized Ingestion Script:
After the containers are up, you can run the ingestion process automatically using this Docker command:

```bash
docker run -it \
  --network=pg-network \
  taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url=${URL}
```
This command does the following automatically:
- Runs the Dockerized ingestion script.
- Downloads the CSV file from the provided URL.
- Processes and ingests the data into your PostgreSQL database.

### Summary of Files:
#### Manual Workflow:
- `ingest_data.py` (You declare the URL manually and run the script).
- `docker-compose.yml` (Only for setting up the containers).
- PostgreSQL and pgAdmin containers (Launched with `docker-compose up`).
- Run ingestion script manually after setting up the containers.

#### Automated Workflow:
- `docker-compose.yml` (Defines PostgreSQL and pgAdmin services).
- `Dockerfile` (To dockerize the ingestion script).
- `ingest_data.py` (Same as in manual workflow, but now runs automatically within Docker).
- URL for Data (Still required for the ingestion process).
- `docker-compose up` to start the containers.
- `docker run` to automatically run the ingestion process inside a Docker container.