package com.fitpaw.backend.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.stereotype.Service;

import com.fitpaw.backend.DTOs.RecompensaRachaResponse.RecompensaItem;
import com.fitpaw.backend.repository.ConexionDB;

@Service
public class MascotaLogrosService {

    private static final String TIPO_ROPA = "ropa";
    private static final String TIPO_LOGIN = "login_primera_vez";
    private static final String TIPO_RACHA = "racha_dias";

    private static final List<DefinicionRecompensa> RECOMPENSAS = List.of(
            new DefinicionRecompensa("Conjunto Paw Celeste", TIPO_LOGIN, 1),
            new DefinicionRecompensa("Conjunto Paw Rosa", TIPO_LOGIN, 1),
            new DefinicionRecompensa("Vestido Azul", TIPO_RACHA, 20),
            new DefinicionRecompensa("Traje Pirata", TIPO_RACHA, 30),
            new DefinicionRecompensa("Traje con Lentes", TIPO_RACHA, 60)
    );

    private final ConexionDB conexionDB;

    public MascotaLogrosService(ConexionDB conexionDB) {
        this.conexionDB = conexionDB;
    }


    public void otorgarRecompensasPrimerLogin(int usuarioId) {
        validarUsuarioId(usuarioId);
        // Funcionalidad desactivada: las tablas mascota_catalogo_items y mascota_logros
        // no existen en el nuevo esquema de base de datos
        System.out.println("✓ Recompensas de primer login desactivadas para usuario: " + usuarioId);
    }

    public void agregarRecompensasPorRacha(Connection conn, int usuarioId, int conteoDias, List<RecompensaItem> recompensas)
            throws SQLException {
        validarUsuarioId(usuarioId);
        if (recompensas == null) {
            throw new IllegalArgumentException("La lista de recompensas es obligatoria");
        }
        // Funcionalidad desactivada: las tablas mascota_catalogo_items y mascota_logros
        // no existen en el nuevo esquema de base de datos
        System.out.println("✓ Recompensas por racha desactivadas para usuario: " + usuarioId);
    }

    private void validarUsuarioId(int usuarioId) {
        if (usuarioId <= 0) {
            throw new IllegalArgumentException("usuarioId invalido");
        }
    }

    private static class DefinicionRecompensa {
        final String nombreItem;
        final String tipoCondicion;
        final int valorRequerido;

        DefinicionRecompensa(String nombreItem, String tipoCondicion, int valorRequerido) {
            this.nombreItem = nombreItem;
            this.tipoCondicion = tipoCondicion;
            this.valorRequerido = valorRequerido;
        }
    }
}
