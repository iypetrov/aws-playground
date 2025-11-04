package org.example.app.services;
import org.example.app.exceptions.ApiException;
import org.springframework.http.HttpStatus;
import org.example.app.enums.SecretType;
import org.example.app.models.CreateSecretResponseModel;
import org.example.app.models.GetSecretResponseModel;
import org.example.app.models.UpdateSecretResponseModel;
import org.example.app.models.DeleteSecretResponseModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.CreateSecretRequest;
import software.amazon.awssdk.services.secretsmanager.model.CreateSecretResponse;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;
import software.amazon.awssdk.services.secretsmanager.model.PutSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.PutSecretValueResponse;
import software.amazon.awssdk.services.secretsmanager.model.DeleteSecretRequest;
import software.amazon.awssdk.services.secretsmanager.model.DeleteSecretResponse;
import software.amazon.awssdk.services.secretsmanager.model.ResourceExistsException;
import software.amazon.awssdk.services.secretsmanager.model.ResourceNotFoundException;
import software.amazon.awssdk.services.secretsmanager.model.SecretsManagerException;
import software.amazon.awssdk.services.secretsmanager.model.InvalidRequestException;

@Service
public class SecretService {
    private static final Logger logger = LoggerFactory.getLogger(SecretService.class);
    private final SecretsManagerClient secretsManagerClient;

    public SecretService(SecretsManagerClient secretsManagerClient) {
        this.secretsManagerClient = secretsManagerClient;
    }

    public CreateSecretResponseModel createSecret(String secretName, String value) {
        CreateSecretRequest createSecretRequest = CreateSecretRequest.builder()
                .name(secretName)
                .secretString(value)
                .build();

        CreateSecretResponse createSecretResponse;
        try {
            createSecretResponse = secretsManagerClient.createSecret(createSecretRequest);
        } catch (ResourceExistsException e) {
            logger.error("Secret already exists: {}", secretName, e);
            throw new ApiException(HttpStatus.CONFLICT, humanMessage(e, "Secret already exists: " + secretName), e);
        } catch (InvalidRequestException e) {
            logger.error("Invalid request creating secret {}", secretName, e);
            throw new ApiException(HttpStatus.BAD_REQUEST, humanMessage(e, "Invalid request creating secret: " + secretName), e);
        } catch (SecretsManagerException e) {
            logger.error("AWS error creating secret {}", secretName, e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, humanMessage(e, "AWS error creating secret: " + secretName), e);
        } catch (RuntimeException e) {
            logger.error("Unexpected error creating secret {}", secretName, e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, defaultMessage(e, "Unexpected error creating secret: " + secretName), e);
        }

        logger.info("Creating secret {}", createSecretResponse.toString());
        return new CreateSecretResponseModel(
                createSecretRequest.name(),
                createSecretResponse.arn(),
                createSecretResponse.versionId()
        );
    }

    public GetSecretResponseModel getSecret(String secretName) {
        GetSecretValueRequest getSecretValueRequest = GetSecretValueRequest.builder()
                .secretId(secretName)
                .build();

        GetSecretValueResponse getSecretValueResponse;
        try {
            getSecretValueResponse = secretsManagerClient.getSecretValue(getSecretValueRequest);
        } catch (ResourceNotFoundException e) {
            logger.error("Secret not found: {}", secretName, e);
            throw new ApiException(HttpStatus.NOT_FOUND, humanMessage(e, "Secret not found: " + secretName), e);
        } catch (SecretsManagerException e) {
            logger.error("AWS error getting secret {}", secretName, e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, humanMessage(e, "AWS error getting secret: " + secretName), e);
        } catch (RuntimeException e) {
            logger.error("Unexpected error getting secret {}", secretName, e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, defaultMessage(e, "Unexpected error getting secret: " + secretName), e);
        }

        logger.info("Get secret {}", getSecretValueResponse.toString());
        return new GetSecretResponseModel(getSecretValueResponse.secretString());
    }

    public UpdateSecretResponseModel updateSecret(String secretName, String value) {
        PutSecretValueRequest putSecretValueRequest = PutSecretValueRequest.builder()
                .secretId(secretName)
                .secretString(value)
                .build();

        PutSecretValueResponse putSecretValueResponse;
        try {
            putSecretValueResponse = secretsManagerClient.putSecretValue(putSecretValueRequest);
        } catch (ResourceNotFoundException e) {
            logger.error("Secret not found for update: {}", secretName, e);
            throw new ApiException(HttpStatus.NOT_FOUND, humanMessage(e, "Secret not found: " + secretName), e);
        } catch (SecretsManagerException e) {
            logger.error("AWS error updating secret {}", secretName, e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, humanMessage(e, "AWS error updating secret: " + secretName), e);
        } catch (RuntimeException e) {
            logger.error("Unexpected error updating secret {}", secretName, e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, defaultMessage(e, "Unexpected error updating secret: " + secretName), e);
        }

        logger.info("Update secret {}", putSecretValueResponse.toString());
        return new UpdateSecretResponseModel(
                putSecretValueResponse.name(),
                putSecretValueResponse.arn(),
                putSecretValueResponse.versionId()
        );
    }

    public DeleteSecretResponseModel deleteSecret(String secretName) {
        DeleteSecretRequest deleteSecretRequest = DeleteSecretRequest.builder()
                .secretId(secretName)
                .forceDeleteWithoutRecovery(true)
                .build();

        DeleteSecretResponse deleteSecretResponse;
        try {
            deleteSecretResponse = secretsManagerClient.deleteSecret(deleteSecretRequest);
        } catch (ResourceNotFoundException e) {
            logger.error("Secret not found for deletion: {}", secretName, e);
            throw new ApiException(HttpStatus.NOT_FOUND, humanMessage(e, "Secret not found: " + secretName), e);
        } catch (SecretsManagerException e) {
            logger.error("AWS error deleting secret {}", secretName, e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, humanMessage(e, "AWS error deleting secret: " + secretName), e);
        } catch (RuntimeException e) {
            logger.error("Unexpected error deleting secret {}", secretName, e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, defaultMessage(e, "Unexpected error deleting secret: " + secretName), e);
        }

        logger.info("Delete secret {}", deleteSecretResponse.toString());
        return new DeleteSecretResponseModel(
                deleteSecretResponse.name(),
                deleteSecretResponse.arn(),
                deleteSecretResponse.deletionDate() != null ? deleteSecretResponse.deletionDate().toString() : null
        );
    }

    private String humanMessage(SecretsManagerException e, String fallback) {
        try {
            String msg = e.awsErrorDetails() != null ? e.awsErrorDetails().errorMessage() : null;
            if (msg != null && !msg.isBlank()) {
                return msg;
            }
        } catch (Exception ignored) { }
        String msg = e.getMessage();
        return (msg != null && !msg.isBlank()) ? msg : fallback;
    }

    private String defaultMessage(RuntimeException e, String fallback) {
        String msg = e.getMessage();
        return (msg != null && !msg.isBlank()) ? msg : fallback;
    }
}
