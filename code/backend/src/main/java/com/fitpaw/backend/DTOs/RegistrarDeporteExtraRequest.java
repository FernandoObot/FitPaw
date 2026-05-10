package com.fitpaw.backend.DTOs;

import java.time.LocalDate;

public class RegistrarDeporteExtraRequest {

    private int usuarioId;
    private String dificultad;
    private double distanciaKm;
    private LocalDate fecha;

    public RegistrarDeporteExtraRequest() {}

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getDificultad() {
        return dificultad;
    }

    public void setDificultad(String dificultad) {
        this.dificultad = dificultad;
    }

    public double getDistanciaKm() {
        return distanciaKm;
    }

    public void setDistanciaKm(double distanciaKm) {
        this.distanciaKm = distanciaKm;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

}
