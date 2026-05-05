package com.fitpaw.backend.controller;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitpaw.backend.DTOs.RegisterRequest;
import com.fitpaw.backend.DTOs.RegisterResponse;
import com.fitpaw.backend.DTOs.UpdateProfileRequest;
import com.fitpaw.backend.DTOs.EditProfileRequest;
import com.fitpaw.backend.service.AuthService;
import com.fitpaw.backend.DTOs.LoginRequest;
import com.fitpaw.backend.DTOs.TokenResponse;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        try {
            RegisterResponse response = authService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("mensaje", e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            TokenResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("mensaje", e.getMessage()));
        }
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@RequestBody UpdateProfileRequest request) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            int usuarioId = (int) auth.getDetails();
            
            authService.updateProfile(usuarioId, request);
            return ResponseEntity.ok(Map.of("mensaje", "Perfil actualizado exitosamente"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", "Error interno: " + e.getMessage()));
        }
    }

    @PutMapping("/profile/edit")
    public ResponseEntity<?> editProfile(@RequestBody EditProfileRequest request) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            int usuarioId = (int) auth.getDetails();
            
            authService.editProfile(usuarioId, request);
            return ResponseEntity.ok(Map.of("mensaje", "Perfil editado exitosamente"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("mensaje", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("mensaje", "Error interno: " + e.getMessage()));
        }
    }
}