package org.example.app.models;

public class DeleteSecretResponseModel {
    String name;
    String arn;
    String deletionDate;

    public DeleteSecretResponseModel(String name, String arn, String deletionDate) {
        this.name = name;
        this.arn = arn;
        this.deletionDate = deletionDate;
    }

    public String getName() {
        return name;
    }

    public String getArn() {
        return arn;
    }

    public String getDeletionDate() {
        return deletionDate;
    }
}


