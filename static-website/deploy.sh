#!/bin/bash

terraform init

BUCKET_NAME="$(terraform output -raw s3_bucket_name)"
CLOUDFRONT_DISTRIBUTION_ID="$(terraform output -raw cloudfront_distribution_id)"
CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME="$(terraform output -raw cloudfront_distribution_domain_name)"

aws s3 cp static/ "s3://${BUCKET_NAME}/" --recursive
aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} --paths "/*"
echo "https://${CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME}"
