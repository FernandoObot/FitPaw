package com.fitpaw.backend.DTOs;

import java.time.LocalDateTime;

public class PetStatusResponse {
    private Integer mascotaId;
    private String nombre;
    private Integer nivel;
    private Integer experienciaActual;
    private Integer hambre; // 0..100 computed
    private LocalDateTime ultimaVezAlimentado;

    public PetStatusResponse() {}

    public Integer getMascotaId() { return mascotaId; }
    public void setMascotaId(Integer mascotaId) { this.mascotaId = mascotaId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public Integer getNivel() { return nivel; }
    public void setNivel(Integer nivel) { this.nivel = nivel; }

    public Integer getExperienciaActual() { return experienciaActual; }
    public void setExperienciaActual(Integer experienciaActual) { this.experienciaActual = experienciaActual; }

    public Integer getHambre() { return hambre; }
    public void setHambre(Integer hambre) { this.hambre = hambre; }

    public LocalDateTime getUltimaVezAlimentado() { return ultimaVezAlimentado; }
    public void setUltimaVezAlimentado(LocalDateTime ultimaVezAlimentado) { this.ultimaVezAlimentado = ultimaVezAlimentado; }
}
