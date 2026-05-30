package com.fitpaw.backend.controller;

import com.fitpaw.backend.DTOs.RachaResponse;
import com.fitpaw.backend.service.StreakService;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class ApiRachaController {

    private final StreakService streakService;

    public ApiRachaController(StreakService streakService) {
        this.streakService = streakService;
    }

    @GetMapping("/racha/{usuarioId}")
    public ResponseEntity<?> obtenerRachaPorUsuario(@PathVariable int usuarioId) {
        return ResponseEntity.ok(toApiResponse(streakService.obtenerRachaInfo(usuarioId)));
    }

    @GetMapping("/racha/me")
    public ResponseEntity<?> obtenerRachaAutenticada(Authentication auth) {
        if (auth == null || auth.getDetails() == null) {
            return ResponseEntity.status(401).body(Map.of("mensaje", "No autenticado"));
        }
        int usuarioId = (int) auth.getDetails();
        return ResponseEntity.ok(toApiResponse(streakService.obtenerRachaInfo(usuarioId)));
    }

    private Map<String, Object> toApiResponse(RachaResponse racha) {
        return Map.of(
                "usuario_id", racha.getUsuarioId(),
                "cantidad_dias", racha.getConteoDias()
        );
    }
}
