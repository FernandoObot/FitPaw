package com.fitpaw.backend.model;

public class CatalogoItem {

    int itemId;
    String nombre;
    String tipo;
    int beneficioPuntos;
    String urlImagen;

    public CatalogoItem() {}

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public int getBeneficioPuntos() {
        return beneficioPuntos;
    }

    public void setBeneficioPuntos(int beneficioPuntos) {
        this.beneficioPuntos = beneficioPuntos;
    }

    public String getUrlImagen() {
        return urlImagen;
    }

    public void setUrlImagen(String urlImagen) {
        this.urlImagen = urlImagen;
    }
    
}
