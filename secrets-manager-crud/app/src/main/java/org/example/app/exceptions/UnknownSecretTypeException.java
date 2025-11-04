package org.example.app.exceptions;

public class UnknownSecretTypeException extends RuntimeException {
    public UnknownSecretTypeException(String message) {
        super(message);
    }
}
