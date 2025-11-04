package org.example.app.models;

public class GetSecretResponseModel {
    String secret;

    public GetSecretResponseModel(String secret) {
        this.secret = secret;
    }

    public String getSecret() {
        return secret;
    }
}
