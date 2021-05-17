################
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#################


while getopts b:t:s:i:h: flag
do
    case "${flag}" in
        b ) BUCKET=${OPTARG}
            ;;
        t ) TYPE=${OPTARG};;
        s ) SCOPE=${OPTARG};;
        i ) ID=${OPTARG};;
        h ) 
            echo "Usage: cmd [-b] [-t] [-s] [-i] [-h]"
    esac
done

# Validate 
if [ -z "$BUCKET" ]
    then
        echo "No Storage Bucket Provided"
        exit    
fi

if [ -z "$TYPE" ]
    then
        echo "Using Default Type 'resource'"
        TYPE="resource"
fi

if [ -z "$SCOPE" ]
    then
        echo "Using Default Scope 'organization'"
        SCOPE="organization"
fi

if [ -z "$ID" ]
    then
        echo "No ID provided. Please provide either an ORG or Project ID depending on the SCOPE."
        exit
fi

#This script will run through all the checks


#Create a storage bucket for storing the asset inventory output. Replace bucket name with your bucket
#export MY_BUCKET_NAME=<bucket-name>

#Run inventory report. This will export resource assets for the checks

gcloud asset export --output-path=gs://${BUCKET}/resource_inventory.json --content-type=${TYPE} --${SCOPE}=$ID 

#Copy the inventory content to the working directory 
echo "Copying Locally"

# Wait for file to exist and copy.
while true; do
	gsutil cp gs://${BUCKET}/resource_inventory.json ./assets
	if [ $? -eq 0 ]; then
		break
	fi
done

# Run the Tests
if test -f "report.txt"; then
    rm report.txt
fi
# Process file and run output through conftest
# This is necesary due to gcloud asset export outputting each asset as a json object and not as a list
for file in ./assets/*.json; do
    echo "Checking ${file}"
    echo $file >> report.txt
    cat $file | tr '\n' ',' | sed  '1s;^;{"data": [\n;' - | sed '$ a ]}'  |  conftest test -p policies -o table - >> report.txt
    printf "\n" >> report.txt
done
