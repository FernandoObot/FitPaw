package com.fitpaw.backend.DTOs;

public class TokenResponse {
    private String token;
    private int usuarioId;

    public TokenResponse() {
    }

    public TokenResponse(String token, int usuarioId) {
        this.token = token;
        this.usuarioId = usuarioId;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }
}
