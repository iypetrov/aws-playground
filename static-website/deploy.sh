#!/bin/bash

terraform init

BUCKET_NAME="$(terraform output -raw s3_bucket_name)"
CLOUDFRONT_DISTRIBUTION_ID="$(terraform output -raw cloudfront_distribution_id)"
CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME="$(terraform output -raw cloudfront_distribution_domain_name)"

hugo --config config.yml
aws s3 sync public/ "s3://${BUCKET_NAME}/" --delete
aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} --paths "/*"
echo "https://${CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME}"
rm -rf public/
rm .hugo_build.lock
