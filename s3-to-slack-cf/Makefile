.PHONY: help create update delete describe validate status

SHELL := /bin/bash

STACK_NAME ?= s3-to-slack
REGION ?= eu-central-1
TEMPLATE_FILE = template.yaml
LAMBDA_IMAGE_URI ?= 833704146350.dkr.ecr.eu-central-1.amazonaws.com/queue-event-to-slack:1.2.2
LAMBDA_TIMEOUT ?= 900

validate:
	@echo "Validating CloudFormation template..."
	@aws cloudformation validate-template \
		--template-body file://$(TEMPLATE_FILE) \
		--region $(REGION)
	@echo "Template is valid!"

create: validate
	@echo "Stack: $(STACK_NAME)"
	@echo "Region: $(REGION)"
	@echo "Account ID: $$(aws sts get-caller-identity --query Account --output text)"
	@echo ""
	@echo "Creating CloudFormation stack..."
	@if [ -n "$(LAMBDA_IMAGE_URI)" ] || [ -n "$(LAMBDA_TIMEOUT)" ]; then \
		PARAMS=""; \
		if [ -n "$(LAMBDA_IMAGE_URI)" ]; then \
			PARAMS="$$PARAMS ParameterKey=LambdaImageUri,ParameterValue=$(LAMBDA_IMAGE_URI)"; \
		fi; \
		if [ -n "$(LAMBDA_TIMEOUT)" ]; then \
			PARAMS="$$PARAMS ParameterKey=LambdaTimeout,ParameterValue=$(LAMBDA_TIMEOUT)"; \
			SQS_TIMEOUT=$$(( $(LAMBDA_TIMEOUT) * 6 )); \
			PARAMS="$$PARAMS ParameterKey=SQSVisibilityTimeout,ParameterValue=$$SQS_TIMEOUT"; \
		fi; \
		aws cloudformation create-stack \
			--stack-name $(STACK_NAME) \
			--template-body file://$(TEMPLATE_FILE) \
			--parameters $$PARAMS \
			--region $(REGION) \
			--capabilities CAPABILITY_NAMED_IAM; \
	else \
		aws cloudformation create-stack \
			--stack-name $(STACK_NAME) \
			--template-body file://$(TEMPLATE_FILE) \
			--region $(REGION) \
			--capabilities CAPABILITY_NAMED_IAM; \
	fi
	@echo "Waiting for stack creation to complete..."
	@aws cloudformation wait stack-create-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION)
	@echo "Stack created successfully!"
	@$(MAKE) describe

update: validate
	@echo "Stack: $(STACK_NAME)"
	@echo "Region: $(REGION)"
	@echo ""
	@echo "Updating CloudFormation stack..."
	@if [ -n "$(LAMBDA_IMAGE_URI)" ] || [ -n "$(LAMBDA_TIMEOUT)" ]; then \
		PARAMS=""; \
		if [ -n "$(LAMBDA_IMAGE_URI)" ]; then \
			PARAMS="$$PARAMS ParameterKey=LambdaImageUri,ParameterValue=$(LAMBDA_IMAGE_URI)"; \
		fi; \
		if [ -n "$(LAMBDA_TIMEOUT)" ]; then \
			PARAMS="$$PARAMS ParameterKey=LambdaTimeout,ParameterValue=$(LAMBDA_TIMEOUT)"; \
			SQS_TIMEOUT=$$(( $(LAMBDA_TIMEOUT) * 6 )); \
			PARAMS="$$PARAMS ParameterKey=SQSVisibilityTimeout,ParameterValue=$$SQS_TIMEOUT"; \
		fi; \
		aws cloudformation update-stack \
			--stack-name $(STACK_NAME) \
			--template-body file://$(TEMPLATE_FILE) \
			--parameters $$PARAMS \
			--region $(REGION) \
			--capabilities CAPABILITY_NAMED_IAM || \
			(echo "No updates to perform or stack does not exist" && exit 0); \
	else \
		aws cloudformation update-stack \
			--stack-name $(STACK_NAME) \
			--template-body file://$(TEMPLATE_FILE) \
			--region $(REGION) \
			--capabilities CAPABILITY_NAMED_IAM || \
			(echo "No updates to perform or stack does not exist" && exit 0); \
	fi
	@echo "Waiting for stack update to complete..."
	@aws cloudformation wait stack-update-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION) || true
	@echo "Stack update completed!"
	@$(MAKE) describe

delete:
	@echo "Stack: $(STACK_NAME)"
	@echo "Region: $(REGION)"
	@echo ""
	@echo "WARNING: This will delete the stack '$(STACK_NAME)'"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ]; then \
		echo "Deleting CloudFormation stack..."; \
		aws cloudformation delete-stack \
			--stack-name $(STACK_NAME) \
			--region $(REGION); \
		echo "Waiting for stack deletion to complete..."; \
		aws cloudformation wait stack-delete-complete \
			--stack-name $(STACK_NAME) \
			--region $(REGION); \
		echo "Stack deleted successfully!"; \
	else \
		echo "Deletion cancelled."; \
	fi

describe:
	@echo "Stack outputs for '$(STACK_NAME)':"
	@aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query 'Stacks[0].Outputs' \
		--output table || echo "Stack not found or has no outputs"

status:
	@aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query 'Stacks[0].[StackName,StackStatus,CreationTime]' \
		--output table || echo "Stack not found"

