#!/bin/bash
set -x #echo on

ACTION_PREFIX=XX-
CL_PACKAGE=lab-feedback-db-package
SEQ_READ=${ACTION_PREFIX}save-feedback-entry-sequence
SEQ_WRITE=${ACTION_PREFIX}read-feedback-entry-sequence

# logging into IBM Cloud
REGION_CODE="${PROD_REGION_ID//ibm:yp:/}"
bx login --apikey ${DEPLOYER_API_KEY} -a https://api.${REGION_CODE}.bluemix.net -o ${PROD_ORG_NAME} -s ${PROD_SPACE_NAME}

# creating cloudant package
bx fn package bind /whisk.system/cloudant ${CL_PACKAGE} -p dbname feedback

# binding credentials
bx fn service bind cloudantNoSQLDB ${CL_PACKAGE} --instance feedback-db-alias --keyname serverless-function-credentials

# creating the first action
./pipeline/create-action.sh ${ACTION_PREFIX}prepare-entry-for-save prepare-entry-for-save.js 

# creating the second action
./pipeline/create-action.sh ${ACTION_PREFIX}set-read-input set-read-input.js 

# creating the third action
./pipeline/create-action.sh ${ACTION_PREFIX}format-entries format-entries.js 

# creating sequences
./pipeline/create-action.sh ${SEQ_READ} ${ACTION_PREFIX}prepare-entry-for-save,${CL_PACKAGE}/create-document --sequence --web true

./pipeline/create-action.sh ${SEQ_WRITE} ${ACTION_PREFIX}set-read-input,${CL_PACKAGE}/list-documents,${ACTION_PREFIX}format-entries --sequence --web true

# create APIs (disabled for labs)
# bx fn api create /${ACTION_PREFIX}feedback /entries GET ${SEQ_READ} -n ${ACTION_PREFIX}feedback

# bx fn api create /${ACTION_PREFIX}feedback /entries PUT ${SEQ_WRITE} -n ${ACTION_PREFIX}feedback
