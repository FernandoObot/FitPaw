package com.fitpaw.backend.model;

import java.time.LocalDateTime;

public class Racha {

    int rachaId;
    int usuarioId;
    int conteoDias;
    LocalDateTime ultimaFechaActividad;

    public Racha() {}

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

    public LocalDateTime getUltimaFechaActividad() {
        return ultimaFechaActividad;
    }

    public void setUltimaFechaActividad(LocalDateTime ultimaFechaActividad) {
        this.ultimaFechaActividad = ultimaFechaActividad;
    }

}
