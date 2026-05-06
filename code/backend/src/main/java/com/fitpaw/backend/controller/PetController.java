package com.fitpaw.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import com.fitpaw.backend.DTOs.FeedRequest;
import com.fitpaw.backend.DTOs.PetStatusResponse;
import com.fitpaw.backend.service.PetService;

@RestController
@RequestMapping("/pet")
public class PetController {

    private final PetService petService;

    public PetController(PetService petService) {
        this.petService = petService;
    }

    private int getUsuarioIdFromAuth() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) throw new IllegalStateException("No autenticado");
        Object d = auth.getDetails();
        if (d instanceof Integer) return (Integer) d;
        if (d instanceof String) return Integer.parseInt((String) d);
        throw new IllegalStateException("No se pudo obtener usuarioId del token");
    }

    @GetMapping("/status")
    public ResponseEntity<?> status() {
        int usuarioId = getUsuarioIdFromAuth();
        PetStatusResponse resp = petService.getPetStatus(usuarioId);
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/feed")
    public ResponseEntity<?> feed(@RequestBody FeedRequest request) {
        int usuarioId = getUsuarioIdFromAuth();
        PetStatusResponse resp = petService.feedPet(usuarioId, request);
        return ResponseEntity.ok(resp);
    }
}
