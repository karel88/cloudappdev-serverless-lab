#!/bin/bash
set -x #echo on

CL_PACKAGE=lab-feedback-db-package

# logging into IBM Cloud
REGION_CODE="${PROD_REGION_ID//ibm:yp:/}"
bx login --apikey ${DEPLOYER_API_KEY} -a https://api.${REGION_CODE}.bluemix.net -o ${PROD_ORG_NAME} -s ${PROD_SPACE_NAME}

# creating cloudant package
if ! bx cloud-functions package get ${CL_PACKAGE}; then
    bx fn package bind /whisk.system/cloudant ${CL_PACKAGE} -p dbname feedback
fi

# binding credentials
bx fn service bind cloudantNoSQLDB ${CL_PACKAGE} --instance feedback-db-alias --keyname serverless-function-credentials

# installing serverless package
/opt/IBM/node-v6.7/bin/npm install

# deploying the serverless.yml
/opt/IBM/node-v6.7/bin/npx serverless deploy -v

