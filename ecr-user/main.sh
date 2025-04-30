#!/bin/bash

export APP=app
export TAG=bar
export AWS_ACCOUNT_ID=678468774710
export AWS_PROFILE=container
export AWS_REGION=eu-west-2
export ECR_PASSWORD_FILE=/tmp/ecr_password.txt

if ! aws ecr describe-repositories --repository-name $APP --region $AWS_REGION 2> /dev/null; then
    aws ecr create-repository --repository-name $APP --region $AWS_REGION --image-tag-mutability MUTABLE
fi
aws ecr get-login-password --region $AWS_REGION > $ECR_PASSWORD_FILE

docker pull nginx:latest
docker tag nginx:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP:$TAG
docker login --username AWS --password $(cat $ECR_PASSWORD_FILE) $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP:$TAG
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP:$TAG

rm -f $ECR_PASSWORD_FILE
