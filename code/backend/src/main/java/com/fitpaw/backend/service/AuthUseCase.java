package com.fitpaw.backend.service;

import com.fitpaw.backend.DTOs.EditProfileRequest;
import com.fitpaw.backend.DTOs.LoginRequest;
import com.fitpaw.backend.DTOs.RegisterRequest;
import com.fitpaw.backend.DTOs.RegisterResponse;
import com.fitpaw.backend.DTOs.TokenResponse;
import com.fitpaw.backend.DTOs.UpdateProfileRequest;
import com.fitpaw.backend.model.User;

public interface AuthUseCase {
    RegisterResponse register(RegisterRequest request);
    TokenResponse login(LoginRequest request);
    void updateProfile(int usuarioId, UpdateProfileRequest request);
    User getProfile(int usuarioId);
    void editProfile(int usuarioId, EditProfileRequest request);
}
