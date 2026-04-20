package com.fitpaw.backend.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.fitpaw.backend.DTOs.EjercicioCatalogoResponse;
import com.fitpaw.backend.DTOs.EstadisticasResponse;
import com.fitpaw.backend.DTOs.OperacionResponse;
import com.fitpaw.backend.DTOs.CumplimientoMetaRequest;
import com.fitpaw.backend.DTOs.RegistrarDeporteExtraRequest;
import com.fitpaw.backend.DTOs.RegistrarSerieRequest;
import com.fitpaw.backend.model.MetaUsuario;
import com.fitpaw.backend.model.RegistroActividad;
import com.fitpaw.backend.model.Racha;

@Service
public class TrainingAppService {

    private final MetaEvaluacionService metaEvaluacionService;

    public TrainingAppService(MetaEvaluacionService metaEvaluacionService) {
        this.metaEvaluacionService = metaEvaluacionService;
    }

    public OperacionResponse registrarSerie(RegistrarSerieRequest request) {
        return new OperacionResponse(
                "ok",
                "POST /training/series",
                "Stub listo para registrar serie de fuerza"
        );
    }

    public OperacionResponse registrarDeporteExtra(RegistrarDeporteExtraRequest request) {
        return new OperacionResponse(
                "ok",
                "POST /training/deporte-extra",
                "Stub listo para registrar deporte extra"
        );
    }

    public List<EjercicioCatalogoResponse> getCatalogoEjercicios() {
        return List.of();
    }

    public EstadisticasResponse getEstadisticas(int usuarioId) {
        return new EstadisticasResponse(0, 0, List.of());
    }

    public OperacionResponse procesarCumplimientoMeta(CumplimientoMetaRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("request no puede ser nulo");
        }

        MetaUsuario meta = request.getMeta();
        RegistroActividad registro = request.getRegistro();
        Racha racha = request.getRacha();

        if (meta == null || registro == null || racha == null) {
            throw new IllegalArgumentException("meta, registro y racha son obligatorios");
        }

        boolean cumplio = metaEvaluacionService.cumpleMeta(meta, registro);
        metaEvaluacionService.aplicarCumplimiento(meta, registro);

        if (!cumplio) {
            return new OperacionResponse(
                    "ok",
                    "POST /training/cumplimiento-meta",
                    "Meta no cumplida. No se actualiza racha."
            );
        }

        metaEvaluacionService.actualizarRacha(racha, registro);
        String recompensa = metaEvaluacionService.determinarRecompensa(racha);

        if (!metaEvaluacionService.recompensaYaAsignada(registro)) {
            metaEvaluacionService.marcarRecompensaAsignada(registro);
        }

        return new OperacionResponse(
                "ok",
                "POST /training/cumplimiento-meta",
                "Meta cumplida. Racha actual: " + racha.getConteoDias() + ". Recompensa: " + recompensa
        );
    }
}
