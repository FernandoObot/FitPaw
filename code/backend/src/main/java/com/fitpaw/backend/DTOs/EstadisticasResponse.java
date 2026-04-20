package com.fitpaw.backend.DTOs;

import java.util.List;

public class EstadisticasResponse {

    private int rachaActual;
    private int volumenTotal;
    private List<String> prs;

    public EstadisticasResponse() {
    }

    public EstadisticasResponse(int rachaActual, int volumenTotal, List<String> prs) {
        this.rachaActual = rachaActual;
        this.volumenTotal = volumenTotal;
        this.prs = prs;
    }

    public int getRachaActual() {
        return rachaActual;
    }

    public void setRachaActual(int rachaActual) {
        this.rachaActual = rachaActual;
    }

    public int getVolumenTotal() {
        return volumenTotal;
    }

    public void setVolumenTotal(int volumenTotal) {
        this.volumenTotal = volumenTotal;
    }

    public List<String> getPrs() {
        return prs;
    }

    public void setPrs(List<String> prs) {
        this.prs = prs;
    }

}
