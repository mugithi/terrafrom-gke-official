# terrafrom-gke-official

### Start by creating an admin project. Official instructions [HERE](https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform)

```
export TF_VAR_org_id=$(gcloud organizations list | awk '!/^DISPLAY_NAME/ { print $2 }')
export TF_VAR_billing_account=$(gcloud beta billing accounts list | grep -i true | awk '{ print $1 }')
export TF_ADMIN=${USER}-terraform-admin
export TF_CREDS=~/.config/gcloud/${USER}-terraform-admin.json

```
In order to create projects, you will have to grant the org user ```Project Creator```
```
# Create New Project
gcloud projects create ${TF_ADMIN}-project \
  --organization ${TF_VAR_org_id} \
  --set-as-default
```

#### You can list all the billing accounts using the command ```gcloud beta billing accounts list```

```
# Link Project to Billing Account
gcloud beta billing projects link ${TF_ADMIN}-project \
  --billing-account ${TF_VAR_billing_account}
  ```
  
  
### Create a Terrafrom Service Account and download json credentials

```
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"
```

```
gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}-project.iam.gserviceaccount.com
  
 ```

###  Grant the service account permission to view the Admin Project and manage Cloud Storage:

```
gcloud projects add-iam-policy-binding ${TF_ADMIN}-project \
  --member serviceAccount:terraform@${TF_ADMIN}-project.iam.gserviceaccount.com \
  --role roles/viewer
  
 gcloud projects add-iam-policy-binding ${TF_ADMIN}-project \
  --member serviceAccount:terraform@${TF_ADMIN}-project.iam.gserviceaccount.com \
  --role roles/storage.admin

```

### Enable  APIs required by Terraform 

```
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable serviceusage.googleapis.com
```

### Add Organization level permissions, ability to create projects and assign them to billing accounts

```
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}-project.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}-project.iam.gserviceaccount.com \
  --role roles/billing.user
```

### Setup Terraform remote state in Cloud Storage 
```
gsutil mb -p ${TF_ADMIN}-project gs://${TF_ADMIN}-project

cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_ADMIN}-project"
   prefix  = "terraform/state"
   project = "${TF_ADMIN}-project"
 }
}
EOF
```

Enable versioning

```
gsutil versioning set on gs://${TF_ADMIN}
```

### Configure your project for Google Terraform Provider

```
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_ADMIN}-project
```



