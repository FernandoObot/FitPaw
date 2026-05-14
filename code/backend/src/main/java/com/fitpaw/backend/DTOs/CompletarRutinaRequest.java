package com.fitpaw.backend.DTOs;

public class CompletarRutinaRequest {

    private int diaSemana;
    private String ejercicioEtiqueta;
    private String detalle;

    public CompletarRutinaRequest() {
    }

    public int getDiaSemana() {
        return diaSemana;
    }

    public void setDiaSemana(int diaSemana) {
        this.diaSemana = diaSemana;
    }

    public String getEjercicioEtiqueta() {
        return ejercicioEtiqueta;
    }

    public void setEjercicioEtiqueta(String ejercicioEtiqueta) {
        this.ejercicioEtiqueta = ejercicioEtiqueta;
    }

    public String getDetalle() {
        return detalle;
    }

    public void setDetalle(String detalle) {
        this.detalle = detalle;
    }
}