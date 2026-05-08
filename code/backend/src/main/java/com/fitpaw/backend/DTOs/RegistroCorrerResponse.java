package com.fitpaw.backend.DTOs;

import java.time.LocalDate;

public class RegistroCorrerResponse {

    private int registroExtraId;
    private int usuarioId;
    private int deporteId;
    private String dificultad;
    private int tiempoCorridoMinutos;
    private LocalDate fecha;

    public RegistroCorrerResponse() {
    }

    public int getRegistroExtraId() {
        return registroExtraId;
    }

    public void setRegistroExtraId(int registroExtraId) {
        this.registroExtraId = registroExtraId;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public int getDeporteId() {
        return deporteId;
    }

    public void setDeporteId(int deporteId) {
        this.deporteId = deporteId;
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
