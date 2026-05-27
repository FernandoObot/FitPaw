package com.fitpaw.backend.DTOs;

public class PetFoodResponse {
    private String nombreComida;
    private Integer cantidad;
    private Integer beneficioPuntos;

    public PetFoodResponse() {}

    public PetFoodResponse(String nombreComida, Integer cantidad, Integer beneficioPuntos) {
        this.nombreComida = nombreComida;
        this.cantidad = cantidad;
        this.beneficioPuntos = beneficioPuntos;
    }

    public String getNombreComida() { return nombreComida; }
    public void setNombreComida(String nombreComida) { this.nombreComida = nombreComida; }

    public Integer getCantidad() { return cantidad; }
    public void setCantidad(Integer cantidad) { this.cantidad = cantidad; }

    public Integer getBeneficioPuntos() { return beneficioPuntos; }
    public void setBeneficioPuntos(Integer beneficioPuntos) { this.beneficioPuntos = beneficioPuntos; }
}
