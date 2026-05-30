package com.fitpaw.backend.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.fitpaw.backend.DTOs.DailyProgressPhotosResponse;
import com.fitpaw.backend.DTOs.ProgressPhotoResponse;
import com.fitpaw.backend.service.ProgressPhotoUseCase;

@RestController
@RequestMapping("/fotos-progreso")
public class ProgressPhotoController {

    private final ProgressPhotoUseCase storageService;

    public ProgressPhotoController(ProgressPhotoUseCase storageService) {
        this.storageService = storageService;
    }

    private int getUsuarioIdFromAuth() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getDetails() == null) {
            throw new IllegalStateException("No autenticado");
        }
        Object details = auth.getDetails();
        if (details instanceof Integer) {
            return (Integer) details;
        }
        if (details instanceof String) {
            return Integer.parseInt((String) details);
        }
        throw new IllegalStateException("No se pudo obtener usuarioId del token");
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> subirFoto(
            @RequestParam("foto") MultipartFile foto,
            @RequestParam(value = "posicion", required = false) Integer posicion) {
        try {
            int usuarioId = getUsuarioIdFromAuth();
            DailyProgressPhotosResponse response = storageService.subirFotoProgreso(usuarioId, foto, posicion);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("mensaje", e.getReason()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", "Error interno: " + e.getMessage()));
        }
    }

    @GetMapping("/hoy")
    public ResponseEntity<?> fotosDeHoy() {
        try {
            int usuarioId = getUsuarioIdFromAuth();
            DailyProgressPhotosResponse response = storageService.obtenerFotosHoy(usuarioId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", "Error interno: " + e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<?> todasLasFotos() {
        try {
            int usuarioId = getUsuarioIdFromAuth();
            List<ProgressPhotoResponse> fotos = storageService.obtenerTodasLasFotos(usuarioId);
            return ResponseEntity.ok(fotos);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", "Error interno: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{fotoId}")
    public ResponseEntity<?> eliminarFoto(@PathVariable int fotoId) {
        try {
            int usuarioId = getUsuarioIdFromAuth();
            storageService.eliminarFotoProgreso(usuarioId, fotoId);
            return ResponseEntity.ok(Map.of("mensaje", "Foto eliminada"));
        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("mensaje", e.getReason()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", "Error interno: " + e.getMessage()));
        }
    }
}
