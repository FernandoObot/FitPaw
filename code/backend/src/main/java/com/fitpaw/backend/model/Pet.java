package com.fitpaw.backend.model;

import java.time.LocalDateTime;

public class Pet {

    private int mascotaId;
    private int usuarioId;
    private String nombre;
    private int nivel;
    private int experienciaActual;
    private int hambre;
    private int salud;
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

    public int getNivel() {
        return nivel;
    }

    public void setNivel(int nivel) {
        this.nivel = nivel;
    }

    public int getExperienciaActual() {
        return experienciaActual;
    }

    public void setExperienciaActual(int experienciaActual) {
        this.experienciaActual = experienciaActual;
    }

    public int getHambre() {
        return hambre;
    }

    public void setHambre(int hambre) {
        this.hambre = hambre;
    }

    public int getSalud() {
        return salud;
    }

    public void setSalud(int salud) {
        this.salud = salud;
    }

    public LocalDateTime getUltimaVezAlimentado() {
        return ultimaVezAlimentado;
    }

    public void setUltimaVezAlimentado(LocalDateTime ultimaVezAlimentado) {
        this.ultimaVezAlimentado = ultimaVezAlimentado;
    }

}
