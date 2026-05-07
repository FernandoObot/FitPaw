package com.fitpaw.backend.DTOs;

public class PhotoSlotResponse {

    private int slot;
    private ProgressPhotoResponse foto;

    public int getSlot() {
        return slot;
    }

    public void setSlot(int slot) {
        this.slot = slot;
    }

    public ProgressPhotoResponse getFoto() {
        return foto;
    }

    public void setFoto(ProgressPhotoResponse foto) {
        this.foto = foto;
    }
}