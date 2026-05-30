package com.fitpaw.backend.service;

import com.fitpaw.backend.DTOs.RachaResponse;

public interface StreakQueryUseCase {
    RachaResponse obtenerRachaInfo(int usuarioId);
}
