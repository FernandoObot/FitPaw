package com.fitpaw.backend.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.fitpaw.backend.DTOs.DailyProgressPhotosResponse;
import com.fitpaw.backend.DTOs.ProgressPhotoResponse;

public interface ProgressPhotoUseCase {
    DailyProgressPhotosResponse subirFotoProgreso(int usuarioId, MultipartFile foto, Integer posicionSolicitada);
    DailyProgressPhotosResponse obtenerFotosHoy(int usuarioId);
    List<ProgressPhotoResponse> obtenerTodasLasFotos(int usuarioId);
    void eliminarFotoProgreso(int usuarioId, int fotoId);
}
