package com.fitpaw.backend.DTOs;

import java.time.LocalDate;

public class SaveCardioExerciseRequest {
    
    private String nombre;
    private Integer dificultad; // 1=Baja, 2=Media, 3=Alta
    private Integer tiempo_minutos;
    private LocalDate fecha;
    private Integer hora; // 6-23
    private Boolean completado; // false al crear

    public SaveCardioExerciseRequest() {
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Integer getDificultad() {
        return dificultad;
    }

    public void setDificultad(Integer dificultad) {
        this.dificultad = dificultad;
    }

    public Integer getTiempo_minutos() {
        return tiempo_minutos;
    }

    public void setTiempo_minutos(Integer tiempo_minutos) {
        this.tiempo_minutos = tiempo_minutos;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

    public Integer getHora() {
        return hora;
    }

    public void setHora(Integer hora) {
        this.hora = hora;
    }

    public Boolean getCompletado() {
        return completado;
    }

    public void setCompletado(Boolean completado) {
        this.completado = completado;
    }
}
