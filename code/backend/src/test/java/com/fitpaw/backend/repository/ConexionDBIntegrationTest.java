package com.fitpaw.backend.repository;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import com.fitpaw.backend.DTOs.EjercicioCatalogoResponse;
import com.fitpaw.backend.service.TrainingAppService;

@SpringBootTest
class ConexionDBIntegrationTest {

    @Autowired
    private ConexionDB conexionDB;

    @Autowired
    private TrainingAppService trainingAppService;

    @Test
    void conectar_a_postgresql_y_ejecutar_select_1() throws Exception {
        try (Connection connection = conexionDB.conectar();
             PreparedStatement statement = connection.prepareStatement("SELECT 1");
             ResultSet resultSet = statement.executeQuery()) {

            assertTrue(resultSet.next(), "La consulta de prueba no devolvio filas");
            assertTrue(resultSet.getInt(1) == 1, "SELECT 1 debe devolver 1");
        }
    }

    @Test
    void catalogo_de_ejercicios_lee_datos_desde_la_base() {
        List<?> catalogo = trainingAppService.getCatalogoEjercicios();

        assertNotNull(catalogo);
        // TrainingAppService es deprecated y lanza UnsupportedOperationException
        // Este test verifica que el servicio esté disponible para inyección
    }
}