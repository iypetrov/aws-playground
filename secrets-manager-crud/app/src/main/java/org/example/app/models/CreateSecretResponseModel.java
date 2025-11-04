package org.example.app.models;

public class CreateSecretResponseModel {
    String name;
    String arn;
    String versionId;

    public CreateSecretResponseModel(String name, String arn, String versionId) {
        this.name = name;
        this.arn = arn;
        this.versionId = versionId;
    }

    public String getName() {
        return name;
    }

    public String getArn() {
        return arn;
    }

    public String getVersionId() {
        return versionId;
    }
}
