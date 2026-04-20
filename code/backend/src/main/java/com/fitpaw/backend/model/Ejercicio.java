package com.fitpaw.backend.model;

public class Ejercicio {

    private int ejercicioId;
    private String nombre;
    private String grupoMuscular;
    private String descripcion;
    private String instruccionesJson;
    private String urlMedia;
    private boolean activo;

    public Ejercicio() {}

    public int getEjercicioId() {
        return ejercicioId;
    }

    public void setEjercicioId(int ejercicioId) {
        this.ejercicioId = ejercicioId;
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

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

}
