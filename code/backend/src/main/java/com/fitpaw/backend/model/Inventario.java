package com.fitpaw.backend.model;

public class Inventario {

    int inventarioId;
    int usuarioId;
    int itemId;
    int cantidad;
    boolean estaEquipado;

    public Inventario() {}

    public int getInventarioId() {
        return inventarioId;
    }

    public void setInventarioId(int inventarioId) {
        this.inventarioId = inventarioId;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public int getCantidad() {
        return cantidad;
    }

    public void setCantidad(int cantidad) {
        this.cantidad = cantidad;
    }

    public boolean isEstaEquipado() {
        return estaEquipado;
    }

    public void setEstaEquipado(boolean estaEquipado) {
        this.estaEquipado = estaEquipado;
    }

}
