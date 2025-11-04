package org.example.app.services;

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
        } catch (Exception e) {
            logger.error("Error while creating the secret", e.getMessage());
            throw e;
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
        } catch (Exception e) {
            logger.error("Error while creating the secret", e.getMessage());
            throw e;
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
        } catch (Exception e) {
            logger.error("Error while updating the secret", e.getMessage());
            throw e;
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
        } catch (Exception e) {
            logger.error("Error while deleting the secret", e.getMessage());
            throw e;
        }

        logger.info("Delete secret {}", deleteSecretResponse.toString());
        return new DeleteSecretResponseModel(
                deleteSecretResponse.name(),
                deleteSecretResponse.arn(),
                deleteSecretResponse.deletionDate() != null ? deleteSecretResponse.deletionDate().toString() : null
        );
    }
}
