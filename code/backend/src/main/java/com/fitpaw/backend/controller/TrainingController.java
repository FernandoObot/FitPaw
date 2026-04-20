package com.fitpaw.backend.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitpaw.backend.DTOs.EjercicioCatalogoResponse;
import com.fitpaw.backend.DTOs.EstadisticasResponse;
import com.fitpaw.backend.DTOs.OperacionResponse;
import com.fitpaw.backend.DTOs.CumplimientoMetaRequest;
import com.fitpaw.backend.DTOs.RegistrarDeporteExtraRequest;
import com.fitpaw.backend.DTOs.RegistrarSerieRequest;
import com.fitpaw.backend.service.TrainingAppService;

@RestController
@RequestMapping("/training")
public class TrainingController {

    private final TrainingAppService trainingAppService;

    public TrainingController(TrainingAppService trainingAppService) {
        this.trainingAppService = trainingAppService;
    }

    @PostMapping("/series")
    public ResponseEntity<OperacionResponse> registrarSeries(@RequestBody RegistrarSerieRequest body) {
        return ResponseEntity.ok(trainingAppService.registrarSerie(body));
    }

    @PostMapping("/deporte-extra")
    public ResponseEntity<OperacionResponse> registrarDeporteExtra(@RequestBody RegistrarDeporteExtraRequest body) {
        return ResponseEntity.ok(trainingAppService.registrarDeporteExtra(body));
    }

    @GetMapping("/ejercicios")
    public ResponseEntity<List<EjercicioCatalogoResponse>> getCatalogoEjercicios() {
        return ResponseEntity.ok(trainingAppService.getCatalogoEjercicios());
    }

    @GetMapping("/estadisticas/{usuarioId}")
    public ResponseEntity<EstadisticasResponse> getEstadisticas(@PathVariable int usuarioId) {
        return ResponseEntity.ok(trainingAppService.getEstadisticas(usuarioId));
    }

    @PostMapping("/cumplimiento-meta")
    public ResponseEntity<OperacionResponse> procesarCumplimientoMeta(@RequestBody CumplimientoMetaRequest body) {
        return ResponseEntity.ok(trainingAppService.procesarCumplimientoMeta(body));
    }
}