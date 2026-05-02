package com.fitpaw.backend.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class User {

    private int usuarioId;
    private String nickname;
    private String telefono;
    private String password;
    private String rol;
    private String genero;
    private LocalDate fechaNacimiento;
    private Double pesoActual;
    private Integer estaturaCm;
    private String objetivoPrincipal;
    private LocalDateTime fechaRegistro;

    public User() {
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
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

    public String getObjetivoPrincipal() {
        return objetivoPrincipal;
    }

    public void setObjetivoPrincipal(String objetivoPrincipal) {
        this.objetivoPrincipal = objetivoPrincipal;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

}
