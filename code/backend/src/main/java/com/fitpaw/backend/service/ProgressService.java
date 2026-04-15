package com.fitpaw.backend.service;

import java.time.LocalDate;

import org.springframework.stereotype.Service;

@Service
public class ProgressService {

    public int actualizarRacha(LocalDate ultimaFecha, int rachaActual) {
        LocalDate hoy = LocalDate.now();

        // Racha sin romper
        if (ultimaFecha != null && ultimaFecha.plusDays(1).equals(hoy)){
            return rachaActual +1;
        }

        // Racha sin cambio
        if (ultimaFecha != null && ultimaFecha.equals(hoy)){
            return rachaActual;

        }

        // Racha rota
        return 1;
    }

}
