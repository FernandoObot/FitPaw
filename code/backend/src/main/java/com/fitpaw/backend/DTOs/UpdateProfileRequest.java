package com.fitpaw.backend.DTOs;

import com.fasterxml.jackson.annotation.JsonAnySetter;

public class UpdateProfileRequest {

    private String genero;
    private Integer fechaNacimiento; // Año de nacimiento (1920-2010) o fecha ISO string
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

    public Integer getFechaNacimiento() {
        return fechaNacimiento;
    }

    /**
     * Acepta tanto Integer (año) como String (fecha ISO o año string)
     */
    public void setFechaNacimiento(Object fechaNacimiento) {
        if (fechaNacimiento == null) {
            this.fechaNacimiento = null;
        } else if (fechaNacimiento instanceof Integer) {
            this.fechaNacimiento = (Integer) fechaNacimiento;
        } else if (fechaNacimiento instanceof String) {
            String str = (String) fechaNacimiento;
            try {
                // Si es un string de año simple (e.g., "2005")
                if (str.matches("\\d{4}")) {
                    this.fechaNacimiento = Integer.parseInt(str);
                } else if (str.contains("-")) {
                    // Si es una fecha ISO (e.g., "2005-01-01"), extraer el año
                    this.fechaNacimiento = Integer.parseInt(str.substring(0, 4));
                } else {
                    // Intentar parsear como integer
                    this.fechaNacimiento = Integer.parseInt(str);
                }
            } catch (Exception e) {
                throw new IllegalArgumentException("No se pudo parsear fecha de nacimiento: " + str, e);
            }
        } else {
            throw new IllegalArgumentException("fechaNacimiento debe ser Integer o String");
        }
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
