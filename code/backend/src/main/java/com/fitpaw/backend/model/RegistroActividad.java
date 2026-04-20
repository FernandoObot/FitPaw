package com.fitpaw.backend.model;

import java.time.LocalDateTime;

public class RegistroActividad {

    private int registroId;
    private int usuarioId;
    private int deporteId;
    private int metaId;
    private LocalDateTime fechaActividad;
    private Double valorRealizado;
    private String unidad;
    private boolean cumplida;
    private String observacion;
    private boolean recompensaAsignada;

    public RegistroActividad() {
    }

    public int getRegistroId() {
        return registroId;
    }

    public void setRegistroId(int registroId) {
        this.registroId = registroId;
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

    public int getMetaId() {
        return metaId;
    }

    public void setMetaId(int metaId) {
        this.metaId = metaId;
    }

    public LocalDateTime getFechaActividad() {
        return fechaActividad;
    }

    public void setFechaActividad(LocalDateTime fechaActividad) {
        this.fechaActividad = fechaActividad;
    }

    public Double getValorRealizado() {
        return valorRealizado;
    }

    public void setValorRealizado(Double valorRealizado) {
        this.valorRealizado = valorRealizado;
    }

    public String getUnidad() {
        return unidad;
    }

    public void setUnidad(String unidad) {
        this.unidad = unidad;
    }

    public boolean isCumplida() {
        return cumplida;
    }

    public void setCumplida(boolean cumplida) {
        this.cumplida = cumplida;
    }

    public String getObservacion() {
        return observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

    public boolean isRecompensaAsignada() {
        return recompensaAsignada;
    }

    public void setRecompensaAsignada(boolean recompensaAsignada) {
        this.recompensaAsignada = recompensaAsignada;
    }
}
