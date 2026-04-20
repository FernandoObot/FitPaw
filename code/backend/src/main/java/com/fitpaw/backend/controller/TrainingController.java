package com.fitpaw.backend.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitpaw.backend.DTOs.RegistrarDeporteExtraRequest;
import com.fitpaw.backend.DTOs.RegistrarSerieRequest;
import com.fitpaw.backend.DTOs.EjercicioCatalogoResponse;
import com.fitpaw.backend.DTOs.EstadisticasResponse;
import com.fitpaw.backend.DTOs.OperacionResponse;

@RestController
@RequestMapping("/training")
public class TrainingController {

    @PostMapping("/series")
    public ResponseEntity<OperacionResponse> registrarSeries(@RequestBody RegistrarSerieRequest body) {
        return ResponseEntity.ok(new OperacionResponse(
        "ok",
        "POST /training/series",
        "Stub listo para registrar serie de fuerza"
        ));
    }

    @PostMapping("/deporte-extra")
    public ResponseEntity<OperacionResponse> registrarDeporteExtra(@RequestBody RegistrarDeporteExtraRequest body) {
        return ResponseEntity.ok(new OperacionResponse(
        "ok",
        "POST /training/deporte-extra",
        "Stub listo para registrar deporte extra"
        ));
    }

    @GetMapping("/ejercicios")
    public ResponseEntity<List<EjercicioCatalogoResponse>> getCatalogoEjercicios() {
        List<EjercicioCatalogoResponse> items = new ArrayList<>();

        return ResponseEntity.ok(items);
    }

    @GetMapping("/estadisticas/{usuarioId}")
    public ResponseEntity<EstadisticasResponse> getEstadisticas(@PathVariable int usuarioId) {
        EstadisticasResponse data = new EstadisticasResponse(0, 0, List.of());
        return ResponseEntity.ok(data);
    }

}
