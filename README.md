# terrafrom-gke-official

### Start by creating an admin projec t

```
export TF_USER=${USER}. # user account, replace if not current user name
export TF_VAR_ORG_ID=$(gcloud organizations list | awk '!/^DISPLAY_NAME/ { print $2 }')
export TF_VAR_BILLING_ACCOUNT=$(gcloud beta billing accounts list | awk '!/^ID/ { print $1 }')
export TF_ADMIN=${TF_USER}-terraform-admin

# Create New Project
gcloud projects create ${TF_ADMIN} \
  --organization ${TF_VAR_ORG_ID} \
  --set-as-default

# Link Project to Billing Account
gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_BILLING_ACCOUNT}
  ```
  
