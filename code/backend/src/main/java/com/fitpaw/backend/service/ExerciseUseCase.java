package com.fitpaw.backend.service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import com.fitpaw.backend.DTOs.ExerciseCompletionResponse;
import com.fitpaw.backend.DTOs.SaveCardioExerciseRequest;
import com.fitpaw.backend.DTOs.SaveFuerzaExerciseRequest;

public interface ExerciseUseCase {
    void saveCardioExercise(int usuarioId, SaveCardioExerciseRequest request);
    void saveFuerzaExercise(int usuarioId, SaveFuerzaExerciseRequest request);
    List<Map<String, Object>> getExercisesByDate(int usuarioId, LocalDate fecha);
    ExerciseCompletionResponse markExerciseCompleted(int usuarioId, String nombre, LocalDate fecha);
    void deleteExercise(int usuarioId, String nombre, LocalDate fecha);
}
