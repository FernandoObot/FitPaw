package com.fitpaw.backend.service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;

import com.fitpaw.backend.DTOs.RegisterRequest;
import com.fitpaw.backend.DTOs.RegisterResponse;
import com.fitpaw.backend.model.User;

@Service
public class AuthService {

    private static final Pattern PHONE_10_DIGITS = Pattern.compile("^\\d{10}$");

    private final Map<String, User> usersByPhone = new ConcurrentHashMap<>();
    private final AtomicInteger userIdSequence = new AtomicInteger(1);

    public RegisterResponse register(RegisterRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body de registro es obligatorio");
        }

        String nombreCompleto = clean(request.getNombreCompleto());
        String telefono = clean(request.getTelefono());
        String password = clean(request.getPassword());

        if (nombreCompleto.isEmpty() || telefono.isEmpty() || password.isEmpty()) {
            throw new IllegalArgumentException("Todos los campos son obligatorios");
        }

        if (!PHONE_10_DIGITS.matcher(telefono).matches()) {
            throw new IllegalArgumentException("El telefono debe tener exactamente 10 digitos");
        }

        if (usersByPhone.containsKey(telefono)) {
            throw new IllegalStateException("El telefono ya se encuentra registrado");
        }

        User newUser = new User();
        newUser.setUsuarioId(userIdSequence.getAndIncrement());
        newUser.setNickname(nombreCompleto);
        newUser.setTelefono(telefono);
        newUser.setPassword(password);
        newUser.setRol("USER");
        newUser.setFechaRegistro(LocalDateTime.now());

        usersByPhone.put(telefono, newUser);

        RegisterResponse response = new RegisterResponse();
        response.setUsuarioId(newUser.getUsuarioId());
        response.setNombreCompleto(newUser.getNickname());
        response.setTelefono(newUser.getTelefono());
        response.setRol(newUser.getRol());
        response.setMensaje("Registro exitoso");

        return response;
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }
}