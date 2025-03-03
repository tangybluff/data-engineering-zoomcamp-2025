# Module 1B: Terraform Setup for GCP Resources

## Step 1: Terraform Files Setup

### Main Terraform Configuration (`main.tf`)

This file is used to define the resources that Terraform will create, such as the Google Cloud Storage Bucket and BigQuery Dataset. The provider is defined to connect with Google Cloud, specifying the credentials, project, and region.

The Google Cloud Storage Bucket configuration includes:
- **Bucket name**: Ensure it’s globally unique (can use project name + custom name).
- **Lifecycle rules** to handle incomplete uploads.

A BigQuery Dataset resource is also defined for storing data.

Terraform commands to execute:
- `terraform init`
- `terraform plan`
- `terraform apply`

### Variables Configuration (`variables.tf`)

This file stores variable definitions like credentials file path, project name, region, storage class, and dataset/bucket names. It helps in making the configuration more dynamic and reusable across different environments.

Example variables:
- `credentials`: Path to GCP credentials JSON.
- `project`: GCP project ID.
- `region`: Region in which resources will be created.
- `bq_dataset_name`: BigQuery dataset name.
- `gcs_bucket_name`: Name of the storage bucket.

## Step 2: Terraform Commands

- `terraform init`: Initializes the working directory by downloading the required provider plugins.
- `terraform plan`: Shows a preview of the resources Terraform plans to create or modify.
- `terraform apply`: Applies the changes, creating the defined resources in Google Cloud.
- `terraform destroy`: Destroys the created resources when cleanup is needed.

## Step 3: Setting up the GCP VM Instance

### Generate SSH Key

Open GitBash and use the `ssh-keygen` command to generate a new SSH key pair:

```bash
ssh-keygen -t rsa -f gcp -C ahmed -b 2048
```

Copy the public key (`gcp.pub`) and add it to Google Cloud Metadata for SSH access.

### Create VM Instance in GCP

Navigate to **Compute Engine > VM Instances** in GCP. Create a new VM instance and configure the OS and storage options. Once created, SSH into the instance using the generated SSH key.

### Install Dependencies on VM

#### Install Anaconda3 for Python environment management:

```bash
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
bash Anaconda3-2024.10-1-Linux-x86_64.sh
source ~/anaconda3/bin/activate
```

#### Install Docker and Docker Compose:

Install Docker:

```bash
sudo apt-get install docker.io
```

Install Docker Compose:

```bash
wget https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-x86_64 -O docker-compose
chmod +x docker-compose
```

Configure VS Code Remote for working directly in the VM.

### Configure Docker

Set up Docker without sudo by adding the user to the Docker group:

```bash
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo service docker restart
```

## Step 4: Install and Configure GCP CLI

### Install Terraform

Download the Terraform binary for Linux:

```bash
wget https://releases.hashicorp.com/terraform/1.10.5/terraform_1.10.5_linux_amd64.zip
unzip terraform_1.10.5_linux_amd64.zip
rm terraform_1.10.5_linux_amd64.zip
```

### Set Up Google Cloud CLI

Upload the GCP credentials (`my-creds.json`) to the VM. Configure GCP CLI:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/my-creds.json
gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
```

## Step 5: Docker and PostgreSQL Setup

### Docker Compose for PostgreSQL and pgAdmin

Navigate to `data-engineering-zoomcamp/01-docker-terraform/2_docker_sql` and run:

```bash
docker-compose up -d
```

This will start PostgreSQL and pgAdmin containers, allowing you to interact with them.

### pgcli

To interact with the PostgreSQL instance, use `pgcli`:

```bash
pgcli -h localhost -U root -d ny_taxi
```

If needed, install `pgcli` and necessary dependencies.

## Step 6: Running the Ingestion Script

### Manual Ingestion

To populate the table, first declare the CSV URL and then run the ingestion script manually:

```bash
python ingest_data.py --user=root --password=root --host=localhost --port=5431 --db=ny_taxi --table_name=yellow_taxi_trips --url=${URL}
```

Alternatively, use Docker to run the ingestion script:

```bash
docker run -it taxi_ingest:v001 --user=root --password=root --host=pg-database --port=5432 --db=ny_taxi --table_name=yellow_taxi_trips --url=${URL}
```

## Step 7: Cleanup

### Terraform Destroy

Once you’re done testing or working with your resources, use `terraform destroy` to clean up the created resources.

## Key Notes

- **Google Cloud Project Setup**: When working with Terraform and Google Cloud, the project ID, region, and credentials are essential for the configuration.
- **SSH Access**: SSH key pair generation and configuring it in Google Cloud is crucial for connecting securely to the VM.
- **Docker & Terraform Integration**: Docker Compose is used to manage services like PostgreSQL and pgAdmin, while Terraform automates the creation of cloud resources.
- **Manual vs Automated Data Ingestion**:
    - Manual ingestion requires manually defining the URL and running the Python script.
    - Dockerized ingestion (via the Dockerfile and Docker Compose) automates this process by embedding the script into a container, making it easier to manage and run.