#Bash script for setting up authentication, configuring the project, enabling services, and creating a service account in GCP:

#!/bin/bash
# Authenticate user to gcloud
gcloud auth login
gcloud auth list
gcloud config set account $OWNER

# Setup current project
gcloud config set project $PROJECT_ID

# Enable required services
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable certificatemanager.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable servicenetworking.googleapis.com
# Set region and zone
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
# Create Service Account
gcloud iam service-accounts create $GSA_DISPLAY_NAME --display-name=$GSA_DISPLAY_NAME
# List all service accounts
gcloud iam service-accounts list
# Assign roles to the Service Account
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/owner
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/iam.serviceAccountTokenCreator

echo "Service Account $GSA_DISPLAY_NAME created and assigned required roles."