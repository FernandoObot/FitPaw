package com.fitpaw.backend.DTOs;

import java.time.LocalDateTime;

public class RutinaCompletadaResponse {

    private int completadoId;
    private int usuarioId;
    private int diaSemana;
    private String ejercicioEtiqueta;
    private String detalle;
    private LocalDateTime completadoEn;

    public RutinaCompletadaResponse() {
    }

    public int getCompletadoId() {
        return completadoId;
    }

    public void setCompletadoId(int completadoId) {
        this.completadoId = completadoId;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
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

    public LocalDateTime getCompletadoEn() {
        return completadoEn;
    }

    public void setCompletadoEn(LocalDateTime completadoEn) {
        this.completadoEn = completadoEn;
    }
}