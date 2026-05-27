package com.fitpaw.backend.model;

import java.time.LocalDateTime;

public class Pet {

    private int mascotaId;
    private int usuarioId;
    private String nombre;
    private int hambre;
    private LocalDateTime ultimaVezAlimentado;

    public Pet() {}

    public int getMascotaId() {
        return mascotaId;
    }

    public void setMascotaId(int mascotaId) {
        this.mascotaId = mascotaId;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getHambre() {
        return hambre;
    }

    public void setHambre(int hambre) {
        this.hambre = hambre;
    }

    public LocalDateTime getUltimaVezAlimentado() {
        return ultimaVezAlimentado;
    }

    public void setUltimaVezAlimentado(LocalDateTime ultimaVezAlimentado) {
        this.ultimaVezAlimentado = ultimaVezAlimentado;
    }

}
