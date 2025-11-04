package org.example.app.enums;

import org.example.app.exceptions.UnknownSecretTypeException;

public enum SecretType {
    INFRA("INFRA"),
    APP("APP");

    private final String name;

    SecretType(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public static SecretType fromCode(String code) {
        for (SecretType type : SecretType.values()) {
            if (type.getName().equalsIgnoreCase(code)) {
                return type;
            }
        }
        throw new UnknownSecretTypeException("Unknown secret type: " + code);
    }
}
