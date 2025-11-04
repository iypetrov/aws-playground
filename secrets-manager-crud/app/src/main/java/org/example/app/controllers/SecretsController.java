package org.example.app.controllers;

import org.example.app.dtos.CreateSecretRequestDTO;
import org.example.app.dtos.CreateSecretResponseDTO;
import org.example.app.dtos.GetSecretResponseDTO;
import org.example.app.dtos.UpdateSecretRequestDTO;
import org.example.app.dtos.UpdateSecretResponseDTO;
import org.example.app.dtos.DeleteSecretResponseDTO;
import org.example.app.models.CreateSecretResponseModel;
import org.example.app.models.GetSecretResponseModel;
import org.example.app.models.UpdateSecretResponseModel;
import org.example.app.models.DeleteSecretResponseModel;
import org.example.app.services.SecretService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/secrets")
public class SecretsController {
    private final SecretService secretService;

    public SecretsController(SecretService secretService) {
        this.secretService = secretService;
    }

    @PostMapping
    public ResponseEntity<CreateSecretResponseDTO> createSecret(
            @RequestBody CreateSecretRequestDTO createSecretRequestDTO
    ) {
        CreateSecretResponseModel secretResponseModel = secretService.createSecret(
                createSecretRequestDTO.name(),
                createSecretRequestDTO.secret()
        );
        return ResponseEntity.ok(
                new CreateSecretResponseDTO(
                        secretResponseModel.getName(),
                        secretResponseModel.getArn(),
                        secretResponseModel.getVersionId()
                )
        );
    }

    @GetMapping("/{name}")
    public ResponseEntity<GetSecretResponseDTO> getSecret(
            @PathVariable String name
    ) {
        GetSecretResponseModel secretResponseModel = secretService.getSecret(name);
        return ResponseEntity.ok(
                new GetSecretResponseDTO(secretResponseModel.getSecret())
        );
    }

    @PutMapping
    public ResponseEntity<UpdateSecretResponseDTO> updateSecret(
            @RequestBody UpdateSecretRequestDTO updateSecretRequestDTO
    ) {
        UpdateSecretResponseModel updateSecretResponseModel = secretService.updateSecret(
                updateSecretRequestDTO.name(),
                updateSecretRequestDTO.secret()
        );
        return ResponseEntity.ok(
                new UpdateSecretResponseDTO(
                        updateSecretResponseModel.getName(),
                        updateSecretResponseModel.getArn(),
                        updateSecretResponseModel.getVersionId()
                )
        );
    }

    @DeleteMapping("/{name}")
    public ResponseEntity<DeleteSecretResponseDTO> deleteSecret(
            @PathVariable String name
    ) {
        DeleteSecretResponseModel deleteSecretResponseModel = secretService.deleteSecret(name);
        return ResponseEntity.ok(
                new DeleteSecretResponseDTO(
                        deleteSecretResponseModel.getName(),
                        deleteSecretResponseModel.getArn(),
                        deleteSecretResponseModel.getDeletionDate()
                )
        );
    }
}
