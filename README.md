# SPAR, one-click deployment on GCP
![SPAR-Architecture](assets/Spar-Architecture.png)


## Introduction

### Overview

- **Kubernetes (GKE)** - Google Kubernetes Engine (GKE) is used as the core platform for container orchestration.

-	**spar-spar-mapper-api** - Manages the routing and mapping of service requests to appropriate internal services.

- **spar-spar-self-service-api** - Enables self-service functionalities by handling user requests and interactions with internal services.

- **spar-spar-self-service-ui** – Provides the user interface for the self-service API, allowing users to interact with the system

- **Istio Ingress**: The traffic to the Spar services is managed by Istio, which acts as the ingress controller.


## Deployment Approach

Deployment uses the following tools:

- **Terraform for GCP** - Infrastructure deployment
- **Helm chart** - Application/Microservices deployment
- **Cloud Build** - YAML scripts which acts as a wrapper around Terraform Deployment scripts

The entire Terraform deployment is divided into 2 stages -

- **Pre-Config** stage
  - Create the required infra for RC deployment
- **Setup** Stage
  - Deploy the Core RC services
  
### Pre-requisites

- ### [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)

- #### Alternate

  - #### [Run gcloud commands with Cloud Shell](https://cloud.google.com/shell/docs/run-gcloud-commands)
  
- **Install kubectl**

   https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#apt

  
- **Install Helm**

  https://helm.sh/docs/intro/install/


- **Esignet Cluster Setup**
 
  Esignet cluster must be set up and running before proceeding.


### Workspace - Folder structure

- **(***Root Folder***)**
  - **assets**
    - images
    - architecture diagrams
    - ...(more)
  - **builds**
    - **apps** - Deploy/Remove all Application services
    - **infra** - Deploy/Remove all Infrastructure components end to end
  - **deployments -** Store config files required for deployment
    - **configs**
      - Store config files required for deployment
    - **scripts**
      - Shell scripts required to deploy services
  - **terraform-scripts**
      - Deployment files for end to end Infrastructure deployment
  - **terraform-variables**
    - **dev**
      - **pre-config**
        - **pre-config.tfvars**
          - Actual values for the variable template defined in **variables.tf** to be passed to **pre-config.tf** 
      


## Step-by-Step guide

#### Setup CLI environment variables

```bash
PROJECT_ID=
OWNER=
GSA=$PROJECT_ID-sa@$PROJECT_ID.iam.gserviceaccount.com
GSA_DISPLAY_NAME=$PROJECT_ID-sa
REGION=asia-south1
ZONE=asia-south1-a
CLUSTER=
DOMAIN_NAME=
EMAIL_ID=
alias k=kubectl
```

#### **Script to setup authentication, configuring the project, enabling services, and creating a service account in GCP**:
```
script file located at `deployment/scripts/setup_gcp.sh` 

**To execute the script**

bash setup_gcp.sh
```

#### Deploy Infrastructure using Terraform

#### Terraform State management

```bash
# Maintains the Terraform state for deployment

gcloud storage buckets create gs://$PROJECT_ID-tfs-stg --project=$PROJECT_ID --default-storage-class=STANDARD --location=$REGION --uniform-bucket-level-access

#### The PROJECT_ID needs to be updated in the command below.

# List all Storage buckets in the project to check the creation of the new one
gcloud storage buckets list --project=$PROJECT_ID
```

#### Pre-Config

##### Prepare Landing Zone

```bash
cd $BASEFOLDERPATH
#### The PROJECT_ID,GSA needs to be updated in the command below.
# One click of deployment of infrastructure

gcloud builds submit --config="./builds/infra/deploy-script.yaml" \
--project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_SERVICE_ACCOUNT_=$GSA,_LOG_BUCKET_=$PROJECT_ID-tfs-stg

# Remove/Destroy infrastructure
#### The PROJECT_ID,GSA needs to be updated in the command below.
/*
gcloud builds submit --config="./builds/infra/destroy-script.yaml" \
--project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_SERVICE_ACCOUNT_=$GSA,_LOG_BUCKET_=$PROJECT_ID-tfs-stg
*/
```

##### Output

...
Apply complete! Resources: 36 added, 0 changed, 0 destroyed.


_**Before moving to the next step, you need to create domain/subdomain and create a DNS `A` type record pointing to `lb_public_ip`**_


#### Deploy services


```bash
cd $BASEFOLDERPATH

# One click of deployment of services
#### The REGION,PROJECT_ID,GSA,EMAIL_ID,DOMAIN needs to be updated in the command below.

gcloud builds submit --config="./builds/apps/deploy-script.yaml" \
--region=$REGION --project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_REGION_="$REGION",_LOG_BUCKET_=$PROJECT_ID-tfs-stg,_EMAIL_ID_=$EMAIL_ID,_DOMAIN_=$DOMAIN,_SERVICE_ACCOUNT_=$GSA

# Remove/Destroy
#### The REGION,PROJECT_ID,GSA,EMAIL_ID,DOMAIN needs to be updated in the command below.

/*
gcloud builds submit --config="./builds/apps/destroy-script.yaml" \
--region=$REGION --project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,\
_REGION_="$REGION",_LOG_BUCKET_=$PROJECT_ID-tfs-stg,_SERVICE_ACCOUNT_=$GSA
*/
```


#### Connect to the Cluster through bastion host

```bash
gcloud compute instances list
gcloud compute ssh spar-dev-ops-vm --zone=$ZONE
gcloud container clusters get-credentials spar-dev-cluster --project=$PROJECT_ID --region=$REGION

kubectl get nodes
kubectl get pods -n spar
kubectl get svc -n istio-system
```


### Steps to connect to Psql
- Run the below command in bastion host
- Install psql client
```bash
sudo apt-get update
sudo apt-get install postgresql-client
```
- Run below command to access psql password
```bash
gcloud secrets versions access latest --secret spar-dev
```
- Run below command to get private ip of sql
```bash
 gcloud sql instances describe spar-dev-pgsql --format=json  | jq -r ".ipAddresses[0].ipAddress"
```
- Connect to psql
```bash
psql "sslmode=require hostaddr=PRIVATE_IP user=postgres dbname=postgres"
```

### DEMO

- Once the esignet is up and running get the client_secret value by running the below command 
```bash
    kubectl get secrets keycloak-client-secrets -n esignet -o jsonpath="{.data.mosip_pms_client_secret}" | base64 --decode
```

- Modify `client_secret` environment variable with the above secret and save the changes in the `esignet-OIDC-flow-with-mock` environment.

- To create an OIDC Client, navigate to the `OIDC Client Mgmt` section and trigger the necessary APIs to create the OIDC client. This gives the clientId and new privateKey_jwk.
 
- Next, create a mock identity for testing the OIDC flow. Go to the Mock Identity System section and trigger the `Create Mock Identity` API. Get the `individual_id` which gets generated.

- get the `clientId` and `privateKey_jwk` from the environment variables.

- TO INTEGRATE ESIGNET AND SPAR
  
  - Connect to the spardb 
    
    ```bash
       psql "sslmode=require hostaddr=PRIVATE_IP user=postgres dbname=postgres"
    ```
    - go the login_providers table and delete the existing data 

    ```bash
     delete from login_providers
    ```
    - update the query by replacing the domain, client_id, private_jwk, and redirection_uri in the  below command and start executing the query

    ```bash
     INSERT INTO "public"."login_providers" ("name", "type", "description", "login_button_text", "login_button_image_url", "authorization_parameters", "created_at", "updated_at", "id", "active", "strategy_id") VALUES('E Signet', 'oauth2_auth_code', 'e-signet', 'PROCEED WITH NATIONAL ID', 'https://login.url', '{   "authorize_endpoint": "https://demo.example.com/authorize",   "token_endpoint": "https://demo.example.com/v1/esignet/oauth/v2/token",   "validate_endpoint": "https://demo.example.com/v1/esignet/oidc/userinfo",   "jwks_endpoint": "https://demo.example.com/v1/esignet/oauth/.well-known/jwks.json",   "client_id": "JXT.........Ico",   "client_assertion_type": "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",   "client_assertion_jwk": {"kty":"RSA","n":"iiR5lAA....................3IOEg"},   "response_type": "code",   "scope": "openid profile email",   "redirect_uri": "https://demo.example.com/api/selfservice/oauth2/callback",   "code_verifier": "dBj.....1gFWFOEjXk",   "extra_authorize_parameters": {     "acr_values":"mosip:idp:acr:generated-code mosip:idp:acr:biometrics mosip:idp:acr:linked-wallet",     "claims": "{\"userinfo\":{\"name\":{\"essential\":true},\"phone_number\":{\"essential\":false},\"email\":{\"essential\":false},\"gender\":{\"essential\":true},\"address\":{\"essential\":false},\"picture\":{\"essential\":false}},\"id_token\":{}}"   }}', '2024-04-22 12:14:52.174414', '2024-04-22 12:14:52.174414', 1, 't', 1) ON CONFLICT DO NOTHING; 
     ``` 



