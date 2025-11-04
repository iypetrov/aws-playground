package org.example.app.dtos;

import org.example.app.enums.SecretType;

public record UpdateSecretRequestDTO(String name, String secret, SecretType type) {
}

