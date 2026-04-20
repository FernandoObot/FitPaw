package com.fitpaw.backend.model;

import jakarta.websocket.Decoder.Text;

public class Ejercicio {

    int ejercicioId;
    String nombre;
    String grupoMuscular;
    Text descripcion;
    Text instruccionesJson;
    String urlMedia;

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

    public Text getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(Text descripcion) {
        this.descripcion = descripcion;
    }

    public Text getInstruccionesJson() {
        return instruccionesJson;
    }

    public void setInstruccionesJson(Text instruccionesJson) {
        this.instruccionesJson = instruccionesJson;
    }

    public String getUrlMedia() {
        return urlMedia;
    }

    public void setUrlMedia(String urlMedia) {
        this.urlMedia = urlMedia;
    }

}
