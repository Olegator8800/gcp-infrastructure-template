#!/bin/bash
set -e

#see https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
#see https://linux-notes.org/rabota-s-google-cloud-platform-compute-instance-i-terraform-v-unix-linux/

export TF_PROJECT=###PROJECT_NAME###
export TF_CREDS=./account.json

export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_PROJECT}

export CLUSTER_NAME = "k8s-cluster"

function init_service_user {
  gcloud iam service-accounts create terraform \
    --display-name "Terraform admin account"

  gcloud iam service-accounts keys create ${TF_CREDS} \
    --iam-account terraform@${TF_PROJECT}.iam.gserviceaccount.com
}

function apply_service_user_permissions {
  gcloud projects add-iam-policy-binding ${TF_PROJECT} \
    --member serviceAccount:terraform@${TF_PROJECT}.iam.gserviceaccount.com \
    --role roles/viewer

  gcloud projects add-iam-policy-binding ${TF_PROJECT} \
    --member serviceAccount:terraform@${TF_PROJECT}.iam.gserviceaccount.com \
    --role roles/storage.admin

  gcloud projects add-iam-policy-binding ${TF_PROJECT} \
    --member serviceAccount:terraform@${TF_PROJECT}.iam.gserviceaccount.com \
    --role roles/compute.admin

  gcloud projects add-iam-policy-binding ${TF_PROJECT} \
    --member serviceAccount:terraform@${TF_PROJECT}.iam.gserviceaccount.com \
    --role roles/dns.admin

  gcloud projects add-iam-policy-binding ${TF_PROJECT} \
    --member serviceAccount:terraform@${TF_PROJECT}.iam.gserviceaccount.com \
    --role roles/deploymentmanager.editor

  gcloud projects add-iam-policy-binding ${TF_PROJECT} \
    --member serviceAccount:terraform@${TF_PROJECT}.iam.gserviceaccount.com \
    --role roles/iam.serviceAccountUser

  gcloud projects add-iam-policy-binding ${TF_PROJECT} \
    --member serviceAccount:terraform@${TF_PROJECT}.iam.gserviceaccount.com \
    --role roles/container.clusterAdmin

  gcloud projects add-iam-policy-binding ${TF_PROJECT} \
    --member serviceAccount:terraform@${TF_PROJECT}.iam.gserviceaccount.com \
    --role roles/container.admin

  gcloud services enable cloudresourcemanager.googleapis.com
  gcloud services enable cloudbilling.googleapis.com
  gcloud services enable iam.googleapis.com
  gcloud services enable compute.googleapis.com
  gcloud services enable container.googleapis.com
  gcloud services enable serviceusage.googleapis.com
  gcloud services enable dns.googleapis.com
}

function terraform_init {
cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_PROJECT}-tf-state-prod"
   prefix  = "terraform/state"
 }
}
EOF

  terraform init
}

function terraform_validate {
  terraform validate
  terraform plan
}

function terraform_upgrade {
  terraform apply -auto-approve
}

function generate_k8s_kubeconfig {
  gcloud container clusters get-credentials ${CLUSTER_NAME} --zone europe-north1-b --project ${TF_PROJECT}
}


PS3='Выберете действие, либо любой символ кроме числа для выхода: '
select action in "init_service_user" "apply_service_user_permissions" "terraform_init" "terraform_validate" "terraform_upgrade" "generate_k8s_kubeconfig"
do
    if [[ $action == init_service_user ]]; then
        init_service_user
    elif [[ $action ==  apply_service_user_permissions ]]; then
        apply_service_user_permissions
    elif [[ $action ==  terraform_init ]]; then
        terraform_init
    elif [[ $action ==  terraform_validate ]]; then
        terraform_validate
    elif [[ $action ==  terraform_upgrade ]]; then
        terraform_upgrade
    elif [[ $action ==  generate_k8s_kubeconfig ]]; then
        generate_k8s_kubeconfig
        else exit 0
    fi
  break
done
