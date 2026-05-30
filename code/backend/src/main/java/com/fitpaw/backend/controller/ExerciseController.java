package com.fitpaw.backend.controller;

import com.fitpaw.backend.DTOs.SaveCardioExerciseRequest;
import com.fitpaw.backend.DTOs.SaveFuerzaExerciseRequest;
import com.fitpaw.backend.DTOs.ExerciseCompletionResponse;
import com.fitpaw.backend.service.ExerciseUseCase;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.time.LocalDate;

@RestController
@RequestMapping({"/ejercicios", "/api/ejercicios"})
public class ExerciseController {

    private final ExerciseUseCase exerciseService;

    public ExerciseController(ExerciseUseCase exerciseService) {
        this.exerciseService = exerciseService;
    }

    /**
     * Guardar ejercicio cardio
     * POST /ejercicios/cardio
     */
    @PostMapping("/cardio")
    public ResponseEntity<?> saveCardioExercise(
            @RequestBody SaveCardioExerciseRequest request,
            Authentication auth) {
        
        if (auth == null || auth.getDetails() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("mensaje", "No autenticado"));
        }

        try {
            int usuarioId = (int) auth.getDetails();
            exerciseService.saveCardioExercise(usuarioId, request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("mensaje", "Ejercicio cardio guardado exitosamente");
            response.put("usuario_id", usuarioId);
            response.put("nombre", request.getNombre());
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("mensaje", "Error al guardar ejercicio: " + e.getMessage()));
        }
    }

    /**
     * Guardar ejercicio de fuerza
     * POST /ejercicios/fuerza
     */
    @PostMapping("/fuerza")
    public ResponseEntity<?> saveFuerzaExercise(
            @RequestBody SaveFuerzaExerciseRequest request,
            Authentication auth) {
        
        if (auth == null || auth.getDetails() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("mensaje", "No autenticado"));
        }

        try {
            int usuarioId = (int) auth.getDetails();
            exerciseService.saveFuerzaExercise(usuarioId, request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("mensaje", "Ejercicio de fuerza guardado exitosamente");
            response.put("usuario_id", usuarioId);
            response.put("nombre", request.getNombre());
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("mensaje", "Error al guardar ejercicio: " + e.getMessage()));
        }
    }

    /**
     * Listar ejercicios por fecha (cardio + fuerza)
     * GET /ejercicios?fecha=YYYY-MM-DD
     */
    @GetMapping
    public ResponseEntity<?> listExercisesByDate(@RequestParam String fecha, Authentication auth) {
        if (auth == null || auth.getDetails() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("mensaje", "No autenticado"));
        }

        try {
            int usuarioId = (int) auth.getDetails();
            LocalDate date = LocalDate.parse(fecha);
            List<Map<String, Object>> ejercicios = exerciseService.getExercisesByDate(usuarioId, date);
            return ResponseEntity.ok(ejercicios);
        } catch (java.time.format.DateTimeParseException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "Formato de fecha inválido"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("mensaje", "Error al listar ejercicios: " + e.getMessage()));
        }
    }

    /**
     * Marcar ejercicio como completado
     * POST/PATCH /ejercicios/completar
     * 
     * Retorna: ExerciseCompletionResponse con racha actualizada, recompensas y desbloqueos
     */
    @RequestMapping(value = "/completar", method = {RequestMethod.POST, RequestMethod.PATCH})
    public ResponseEntity<?> markExerciseCompleted(
            @RequestBody Map<String, Object> request,
            Authentication auth) {
        
        if (auth == null || auth.getDetails() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("mensaje", "No autenticado"));
        }

        try {
            int usuarioId = (int) auth.getDetails();
            String nombre = (String) request.get("nombre");
            String fecha = (String) request.get("fecha");
            
            if (nombre == null || fecha == null) {
                return ResponseEntity.badRequest()
                        .body(Map.of("mensaje", "nombre y fecha son requeridos"));
            }

            LocalDate date = LocalDate.parse(fecha);
            
            ExerciseCompletionResponse response = exerciseService.markExerciseCompleted(usuarioId, nombre, date);
            
            return ResponseEntity.ok(response);
        } catch (java.time.format.DateTimeParseException e) {
            ExerciseCompletionResponse response = new ExerciseCompletionResponse();
            response.setSuccess(false);
            response.setMensaje("Formato de fecha inválido: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (IllegalArgumentException e) {
            ExerciseCompletionResponse response = new ExerciseCompletionResponse();
            response.setSuccess(false);
            response.setMensaje(e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        } catch (Exception e) {
            ExerciseCompletionResponse response = new ExerciseCompletionResponse();
            response.setSuccess(false);
            response.setMensaje("Error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * Eliminar ejercicio
     * DELETE /ejercicios/eliminar?nombre=...&fecha=YYYY-MM-DD
     */
    @DeleteMapping("/eliminar")
    public ResponseEntity<?> deleteExercise(
            @RequestParam String nombre,
            @RequestParam String fecha,
            Authentication auth) {
        
        if (auth == null || auth.getDetails() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("mensaje", "No autenticado"));
        }

        try {
            int usuarioId = (int) auth.getDetails();
            LocalDate date = LocalDate.parse(fecha);
            
            exerciseService.deleteExercise(usuarioId, nombre, date);
            
            return ResponseEntity.ok(Map.of(
                    "mensaje", "Ejercicio eliminado",
                    "nombre", nombre,
                    "fecha", fecha
            ));
        } catch (java.time.format.DateTimeParseException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "Formato de fecha inválido"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("mensaje", "Error: " + e.getMessage()));
        }
    }
}
