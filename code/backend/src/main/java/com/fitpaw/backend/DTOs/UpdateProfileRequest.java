package com.fitpaw.backend.DTOs;

import java.time.LocalDate;

public class UpdateProfileRequest {

    private String genero;
    private LocalDate fechaNacimiento;
    private Double pesoActual;
    private Integer estaturaCm;

    public UpdateProfileRequest() {
    }

    public String getGenero() {
        return genero;
    }

    public void setGenero(String genero) {
        this.genero = genero;
    }

    public LocalDate getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(LocalDate fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public Double getPesoActual() {
        return pesoActual;
    }

    public void setPesoActual(Double pesoActual) {
        this.pesoActual = pesoActual;
    }

    public Integer getEstaturaCm() {
        return estaturaCm;
    }

    public void setEstaturaCm(Integer estaturaCm) {
        this.estaturaCm = estaturaCm;
    }
}
