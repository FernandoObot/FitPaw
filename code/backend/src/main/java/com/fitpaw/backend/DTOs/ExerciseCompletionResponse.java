package com.fitpaw.backend.DTOs;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Response DTO for exercise completion endpoints.
 * Contains information about the exercise that was completed and the updated streak status.
 */
public class ExerciseCompletionResponse {
    
    @JsonProperty("usuario_id")
    private Integer usuarioId;
    
    @JsonProperty("success")
    private boolean success;
    
    @JsonProperty("mensaje")
    private String mensaje;
    
    @JsonProperty("dias_racha")
    private int diasRacha;
    
    @JsonProperty("racha_activa")
    private boolean rachaActiva;

    @JsonProperty("recompensas")
    private java.util.List<java.util.Map<String, Object>> recompensas = new java.util.ArrayList<>();

    @JsonProperty("atuendos_desbloqueados")
    private boolean atuendosDesbloqueados;

    @JsonProperty("atuendos_nuevos")
    private java.util.List<String> atuendosNuevos = new java.util.ArrayList<>();

    // Constructors
    public ExerciseCompletionResponse() {
    }

    public ExerciseCompletionResponse(Integer usuarioId, boolean success, String mensaje, int diasRacha, boolean rachaActiva) {
        this.usuarioId = usuarioId;
        this.success = success;
        this.mensaje = mensaje;
        this.diasRacha = diasRacha;
        this.rachaActiva = rachaActiva;
    }

    // Getters and Setters
    public Integer getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(Integer usuarioId) {
        this.usuarioId = usuarioId;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public int getDiasRacha() {
        return diasRacha;
    }

    public void setDiasRacha(int diasRacha) {
        this.diasRacha = diasRacha;
    }

    public boolean isRachaActiva() {
        return rachaActiva;
    }

    public void setRachaActiva(boolean rachaActiva) {
        this.rachaActiva = rachaActiva;
    }

    public java.util.List<java.util.Map<String, Object>> getRecompensas() {
        return recompensas;
    }

    public void setRecompensas(java.util.List<java.util.Map<String, Object>> recompensas) {
        this.recompensas = recompensas != null ? recompensas : new java.util.ArrayList<>();
    }

    public boolean isAtuendosDesbloqueados() {
        return atuendosDesbloqueados;
    }

    public void setAtuendosDesbloqueados(boolean atuendosDesbloqueados) {
        this.atuendosDesbloqueados = atuendosDesbloqueados;
    }

    public java.util.List<String> getAtuendosNuevos() {
        return atuendosNuevos;
    }

    public void setAtuendosNuevos(java.util.List<String> atuendosNuevos) {
        this.atuendosNuevos = atuendosNuevos != null ? atuendosNuevos : new java.util.ArrayList<>();
    }

    @Override
    public String toString() {
        return "ExerciseCompletionResponse{" +
                "usuarioId=" + usuarioId +
                ", success=" + success +
                ", mensaje='" + mensaje + '\'' +
                ", diasRacha=" + diasRacha +
                ", rachaActiva=" + rachaActiva +
                ", recompensas=" + recompensas +
                ", atuendosDesbloqueados=" + atuendosDesbloqueados +
                ", atuendosNuevos=" + atuendosNuevos +
                '}';
    }
}
