package com.fitpaw.backend.DTOs;

import com.fitpaw.backend.model.Pet;

public class TrainingResponse {

    private Pet pet;
    private int racha;
    private String logro;

    public TrainingResponse(){}

    public Pet getPet() {
        return pet;
    }

    public void setPet(Pet pet) {
        this.pet = pet;
    }

    public int getRacha() {
        return racha;
    }

    public void setRacha(int racha) {
        this.racha = racha;
    }

    public String getLogro() {
        return logro;
    }

    public void setLogro(String logro) {
        this.logro = logro;
    }

}
