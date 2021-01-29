# GC Cloud Guardrails Validation

## Permissions
- Cloud Asset Viewer
- Service Usage Consumer

##  Process

### Generate Inventory
1. Enable Cloud Asset Inventory API
```
gcloud services enable cloudasset.googleapis.com
```

2. Create a storage bucket for storing the asset inventory output
```
export MY_BUCKET_NAME=<bucket-name>
gsutil mb gs://$MY_BUCKET_NAME
```

3. Run inventory report
```
gcloud asset export --output-path=gs://$MY_BUCKET_NAME/resource_inventory.json \
	--content-type=resource \ # content types can be the following: resource, iam-policy, access-policy, org-policy
	--project=<your_project_id> \ # --folder or --organization can also be used
```

4. Clone this repo `git clone <repourl>`

5. Copy files from google storage to your location disk
```
gsutil cp gs://$MY_BUCKET_NAME/resource_inventory.json ./cai-dir
```

6. Download [Conftest](https://www.conftest.dev/) or Build the container

### Install
```
# Linux
export CONFTEST_VERSION=0.21.0
wget https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz
tar -xvf conftest*.tar.gz
sudo mv conftest /usr/local/bin
```
Installation process for other [OSes](https://www.conftest.dev/install/)

### Container

```
docker build -t gc-guardrails .
```

7. Run the Tests
```
# Local
./run.sh

# Container
docker run -v $(pwd):/app
```

This will format the output from the inventory dump and run the tests. Results will be placed in the report.txt folder in the current directory.

example output

```
./cai-dir/access_policy_inventory.json
--------------------------------------------------------------------------------
PASS: 1/1
WARN: 0/1
FAIL: 0/1

./cai-dir/iam_inventory.json
--------------------------------------------------------------------------------
PASS: 10/10
WARN: 0/10
FAIL: 0/10

./cai-dir/inventory.json
[31mFAIL[0m - //compute.googleapis.com/projects/gke-test-project/regions/asia-east2/subnetworks/default not located in Canada 'asia-east2'
[31mFAIL[0m - //compute.googleapis.com/projects/gke-test-project/regions/asia-south1/subnetworks/default not located in Canada 'asia-south1'
[31mFAIL[0m - //compute.googleapis.com/projects/gke-test-project/regions/asia-southeast1/subnetworks/default not located in Canada 'asia-southeast1'
```

## Source Links
[Government of Canada Guardrails](https://github.com/canada-ca/cloud-guardrails)

[Cloud Inventory Assets](https://cloud.google.com/asset-inventory/docs/overviewhttps://cloud.google.com/asset-inventory/docs/overview)

[Open Policy Agent](https://www.openpolicyagent.org/)

[conftest](https://www.conftest.dev/)

[GCP Cloud Foundation Toolkit](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit)

[CFT Terraform templates](https://github.com/terraform-google-modules/terraform-example-foundation)