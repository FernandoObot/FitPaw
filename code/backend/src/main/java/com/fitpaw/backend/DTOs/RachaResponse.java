package com.fitpaw.backend.DTOs;

import java.time.LocalDate;

public class RachaResponse {
    private int rachaId;
    private int usuarioId;
    private int conteoDias;
    private LocalDate ultimaFechaActividad;
    private boolean activa;
    private LocalDate proximaFechaSinActividad;

    public RachaResponse() {}

    public RachaResponse(int rachaId, int usuarioId, int conteoDias, LocalDate ultimaFechaActividad, boolean activa) {
        this.rachaId = rachaId;
        this.usuarioId = usuarioId;
        this.conteoDias = conteoDias;
        this.ultimaFechaActividad = ultimaFechaActividad;
        this.activa = activa;
    }

    public int getRachaId() {
        return rachaId;
    }

    public void setRachaId(int rachaId) {
        this.rachaId = rachaId;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public int getConteoDias() {
        return conteoDias;
    }

    public void setConteoDias(int conteoDias) {
        this.conteoDias = conteoDias;
    }

    public LocalDate getUltimaFechaActividad() {
        return ultimaFechaActividad;
    }

    public void setUltimaFechaActividad(LocalDate ultimaFechaActividad) {
        this.ultimaFechaActividad = ultimaFechaActividad;
    }

    public boolean isActiva() {
        return activa;
    }

    public void setActiva(boolean activa) {
        this.activa = activa;
    }

    public LocalDate getProximaFechaSinActividad() {
        return proximaFechaSinActividad;
    }

    public void setProximaFechaSinActividad(LocalDate proximaFechaSinActividad) {
        this.proximaFechaSinActividad = proximaFechaSinActividad;
    }
}
