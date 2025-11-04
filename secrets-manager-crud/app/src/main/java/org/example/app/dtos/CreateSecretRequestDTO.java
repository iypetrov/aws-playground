package org.example.app.dtos;

import org.example.app.enums.SecretType;

public record CreateSecretRequestDTO(String name, String secret, SecretType type) {
}
