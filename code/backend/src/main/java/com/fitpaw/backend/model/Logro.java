package com.fitpaw.backend.model;

public class Logro {

    int logroId;
    String nombre;
    String tipoCondicion;
    int valorRequerido;
    int recompensaItemId;

    public Logro() {}

    public int getLogroId() {
        return logroId;
    }

    public void setLogroId(int logroId) {
        this.logroId = logroId;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTipoCondicion() {
        return tipoCondicion;
    }

    public void setTipoCondicion(String tipoCondicion) {
        this.tipoCondicion = tipoCondicion;
    }

    public int getValorRequerido() {
        return valorRequerido;
    }

    public void setValorRequerido(int valorRequerido) {
        this.valorRequerido = valorRequerido;
    }

}
