package com.fitpaw.backend.DTOs;

import java.util.List;

public class DailyProgressPhotosResponse {

    private int limiteDiario;
    private int subidasHoy;
    private int restantesHoy;
    private boolean puedeSubirHoy;
    private List<PhotoSlotResponse> slots;
    private List<PhotoSlotResponse> slotsHace15Dias;
    private ProgressPhotoResponse fotoGuardada;

    public int getLimiteDiario() {
        return limiteDiario;
    }

    public void setLimiteDiario(int limiteDiario) {
        this.limiteDiario = limiteDiario;
    }

    public int getSubidasHoy() {
        return subidasHoy;
    }

    public void setSubidasHoy(int subidasHoy) {
        this.subidasHoy = subidasHoy;
    }

    public int getRestantesHoy() {
        return restantesHoy;
    }

    public void setRestantesHoy(int restantesHoy) {
        this.restantesHoy = restantesHoy;
    }

    public boolean isPuedeSubirHoy() {
        return puedeSubirHoy;
    }

    public void setPuedeSubirHoy(boolean puedeSubirHoy) {
        this.puedeSubirHoy = puedeSubirHoy;
    }

    public List<PhotoSlotResponse> getSlots() {
        return slots;
    }

    public void setSlots(List<PhotoSlotResponse> slots) {
        this.slots = slots;
    }

    public List<PhotoSlotResponse> getSlotsHace15Dias() {
        return slotsHace15Dias;
    }

    public void setSlotsHace15Dias(List<PhotoSlotResponse> slotsHace15Dias) {
        this.slotsHace15Dias = slotsHace15Dias;
    }

    public ProgressPhotoResponse getFotoGuardada() {
        return fotoGuardada;
    }

    public void setFotoGuardada(ProgressPhotoResponse fotoGuardada) {
        this.fotoGuardada = fotoGuardada;
    }
}