package com.fitpaw.backend.DTOs;

public class OperacionResponse {

private String status;
private String endpoint;
private String mensaje;

    public OperacionResponse() {
    }

    public OperacionResponse(String status, String endpoint, String mensaje) {
        this.status = status;
        this.endpoint = endpoint;
        this.mensaje = mensaje;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getEndpoint() {
        return endpoint;
    }

    public void setEndpoint(String endpoint) {
        this.endpoint = endpoint;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

}
