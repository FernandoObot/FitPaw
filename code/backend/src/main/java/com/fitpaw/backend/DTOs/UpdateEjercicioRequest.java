package com.fitpaw.backend.DTOs;

public class UpdateEjercicioRequest {

    private String nombre;
    private String grupoMuscular;
    private String descripcion;
    private String instruccionesJson;
    private String urlMedia;

    public UpdateEjercicioRequest() {
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getGrupoMuscular() {
        return grupoMuscular;
    }

    public void setGrupoMuscular(String grupoMuscular) {
        this.grupoMuscular = grupoMuscular;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getInstruccionesJson() {
        return instruccionesJson;
    }

    public void setInstruccionesJson(String instruccionesJson) {
        this.instruccionesJson = instruccionesJson;
    }

    public String getUrlMedia() {
        return urlMedia;
    }

    public void setUrlMedia(String urlMedia) {
        this.urlMedia = urlMedia;
    }
}
