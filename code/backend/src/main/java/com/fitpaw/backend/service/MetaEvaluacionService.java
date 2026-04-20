package com.fitpaw.backend.service;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.springframework.stereotype.Service;

import com.fitpaw.backend.model.MetaUsuario;
import com.fitpaw.backend.model.RegistroActividad;
import com.fitpaw.backend.model.Racha;

@Service
public class MetaEvaluacionService {

    public boolean cumpleMeta(MetaUsuario meta, RegistroActividad registro) {
        if (meta == null || registro == null) {
            throw new IllegalArgumentException("meta y registro no pueden ser nulos");
        }
        if (meta.getValorObjetivo() == null || registro.getValorRealizado() == null) {
            return false;
        }

        if (meta.getUnidad() != null && registro.getUnidad() != null) {
            if (!meta.getUnidad().equalsIgnoreCase(registro.getUnidad())) {
                return false;
            }
        }

        return registro.getValorRealizado() >= meta.getValorObjetivo();
    }

    public MetaUsuario aplicarCumplimiento(MetaUsuario meta, RegistroActividad registro) {
        if (cumpleMeta(meta, registro)) {
            meta.setCumplida(true);
            meta.setFechaCumplimiento(registro.getFechaActividad() != null ? registro.getFechaActividad() : LocalDateTime.now());
        }
        return meta;
    }

    public Racha actualizarRacha(Racha racha, RegistroActividad registro) {
        if (racha == null || registro == null) {
            throw new IllegalArgumentException("racha y registro no pueden ser nulos");
        }

        LocalDate fechaActividad = registro.getFechaActividad() != null
                ? registro.getFechaActividad().toLocalDate()
                : LocalDate.now();

        LocalDate ultimaFecha = racha.getUltimaFechaActividad() != null
                ? racha.getUltimaFechaActividad().toLocalDate()
                : null;

        if (ultimaFecha == null) {
            racha.setConteoDias(1);
        } else if (ultimaFecha.plusDays(1).equals(fechaActividad)) {
            racha.setConteoDias(racha.getConteoDias() + 1);
        } else if (!ultimaFecha.equals(fechaActividad)) {
            racha.setConteoDias(1);
        }

        racha.setUltimaFechaActividad(fechaActividad.atStartOfDay());
        return racha;
    }

    public String determinarRecompensa(Racha racha) {
        if (racha == null) {
            throw new IllegalArgumentException("racha no puede ser nula");
        }

        if (racha.getConteoDias() >= 30) {
            return "ROPA";
        }

        if (racha.getConteoDias() >= 1) {
            return "COMIDA";
        }

        return "SIN_RECOMPENSA";
    }

    public boolean recompensaYaAsignada(RegistroActividad registro) {
        if (registro == null) {
            throw new IllegalArgumentException("registro no puede ser nulo");
        }
        return registro.isRecompensaAsignada();
    }

    public RegistroActividad marcarRecompensaAsignada(RegistroActividad registro) {
        if (registro == null) {
            throw new IllegalArgumentException("registro no puede ser nulo");
        }
        registro.setRecompensaAsignada(true);
        return registro;
    }
}
