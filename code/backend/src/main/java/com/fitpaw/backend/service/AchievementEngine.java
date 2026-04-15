package com.fitpaw.backend.service;

import org.springframework.stereotype.Service;

@Service
public class AchievementEngine {

    public String verificarLogros(int racha, int experiencia) {
        // Ejemplos de logros basados en racha y experiencia
        // Logro 1: primer entrenamiento
        if (experiencia > 0){
            return "Logro desbloqueado: Primer entrenamiento";
        }

        // Logro 2: racha de 3 días
        if (racha >= 3){
            return "Logro desbloqueado: Racha de 3 días";
        }

        return null;// Sin logros desbloqueados
    }

}
