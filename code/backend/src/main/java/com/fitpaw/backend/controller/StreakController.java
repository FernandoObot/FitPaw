package com.fitpaw.backend.controller;

import java.util.NoSuchElementException;
import java.util.function.Supplier;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fitpaw.backend.DTOs.OperacionResponse;
import com.fitpaw.backend.DTOs.RachaResponse;
import com.fitpaw.backend.service.StreakQueryUseCase;

@RestController
@RequestMapping("/streak")
public class StreakController {

    private final StreakQueryUseCase streakService;

    public StreakController(StreakQueryUseCase streakService) {
        this.streakService = streakService;
    }

    /**
     * GET /streak/info?usuarioId={id}
     * Obtiene la información actual de la racha del usuario
     */
    @GetMapping("/info")
    public ResponseEntity<?> obtenerInfoRacha(
            @RequestParam(value = "usuarioId", required = false) Integer usuarioId,
            Authentication auth) {
        Integer resolvedUsuarioId = usuarioId;
        if (resolvedUsuarioId == null && auth != null && auth.getDetails() != null) {
            resolvedUsuarioId = (int) auth.getDetails();
        }
        if (resolvedUsuarioId == null) {
            OperacionResponse error = new OperacionResponse();
            error.setStatus("error");
            error.setMensaje("usuarioId es requerido");
            return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
        }
        final int id = resolvedUsuarioId;
        return run(() -> streakService.obtenerRachaInfo(id), HttpStatus.OK);
    }

    // ==================== MÉTODO AUXILIAR ====================

    private ResponseEntity<?> run(Supplier<Object> action, HttpStatus status) {
        try {
            return new ResponseEntity<>(action.get(), status);
        } catch (IllegalArgumentException | IllegalStateException e) {
            OperacionResponse error = new OperacionResponse();
            error.setStatus("error");
            error.setMensaje(e.getMessage());
            return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
        } catch (NoSuchElementException e) {
            OperacionResponse error = new OperacionResponse();
            error.setStatus("error");
            error.setMensaje(e.getMessage());
            return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            OperacionResponse error = new OperacionResponse();
            error.setStatus("error");
            error.setMensaje("Error interno: " + e.getMessage());
            return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
