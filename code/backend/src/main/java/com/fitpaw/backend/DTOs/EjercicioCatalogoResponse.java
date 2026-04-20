package com.fitpaw.backend.DTOs;

public class EjercicioCatalogoResponse {

    private int ejercicioId;
    private String nombre;
    private String grupoMuscular;
    private String descripcion;
    private String urlMedia;

    public EjercicioCatalogoResponse() {}

    public EjercicioCatalogoResponse(int ejercicioId, String nombre, String grupoMuscular, String descripcion, String urlMedia) {
        this.ejercicioId = ejercicioId;
        this.nombre = nombre;
        this.grupoMuscular = grupoMuscular;
        this.descripcion = descripcion;
        this.urlMedia = urlMedia;
    }

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

    public String getUrlMedia() {
        return urlMedia;
    }

    public void setUrlMedia(String urlMedia) {
        this.urlMedia = urlMedia;
    }

}
