package com.fitpaw.backend.DTOs;

import java.time.LocalDate;

public class RegistroCorrerRequest {

    private int usuarioId;
    private String dificultad;
    private int tiempoCorridoMinutos;
    private LocalDate fecha;

    public RegistroCorrerRequest() {
    }

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

    public int getTiempoCorridoMinutos() {
        return tiempoCorridoMinutos;
    }

    public void setTiempoCorridoMinutos(int tiempoCorridoMinutos) {
        this.tiempoCorridoMinutos = tiempoCorridoMinutos;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }
}
