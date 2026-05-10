package com.fitpaw.backend.DTOs;

import java.util.List;

public class RecompensaRachaResponse {
    private int usuarioId;
    private int conteoDias;
    private int diasActual;
    private List<RecompensaItem> recompensas;
    private boolean esNueva;

    public RecompensaRachaResponse() {}

    public RecompensaRachaResponse(int usuarioId, int conteoDias, List<RecompensaItem> recompensas) {
        this.usuarioId = usuarioId;
        this.conteoDias = conteoDias;
        this.recompensas = recompensas;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public int getConteoDias() {
        return conteoDias;
    }

    public void setConteoDias(int conteoDias) {
        this.conteoDias = conteoDias;
    }

    public int getDiasActual() {
        return diasActual;
    }

    public void setDiasActual(int diasActual) {
        this.diasActual = diasActual;
    }

    public List<RecompensaItem> getRecompensas() {
        return recompensas;
    }

    public void setRecompensas(List<RecompensaItem> recompensas) {
        this.recompensas = recompensas;
    }

    public boolean isEsNueva() {
        return esNueva;
    }

    public void setEsNueva(boolean esNueva) {
        this.esNueva = esNueva;
    }

    // Inner class para representar cada recompensa
    public static class RecompensaItem {
        private int itemId;
        private String nombre;
        private String tipo;
        private int cantidad;
        private String razon;

        public RecompensaItem() {}

        public RecompensaItem(int itemId, String nombre, String tipo, int cantidad, String razon) {
            this.itemId = itemId;
            this.nombre = nombre;
            this.tipo = tipo;
            this.cantidad = cantidad;
            this.razon = razon;
        }

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

        public int getCantidad() {
            return cantidad;
        }

        public void setCantidad(int cantidad) {
            this.cantidad = cantidad;
        }

        public String getRazon() {
            return razon;
        }

        public void setRazon(String razon) {
            this.razon = razon;
        }
    }
}
