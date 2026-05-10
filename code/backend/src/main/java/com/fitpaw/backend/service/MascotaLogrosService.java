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
        try (Connection conn = conexionDB.conectar()) {
            asegurarCatalogoYLogros(conn);
            otorgarSiFalta(conn, usuarioId, "Conjunto Paw Celeste");
            otorgarSiFalta(conn, usuarioId, "Conjunto Paw Rosa");
            sincronizarEquipamientoRopa(conn, usuarioId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al otorgar recompensas de primer login: " + e.getMessage());
        }
    }

    public void agregarRecompensasPorRacha(Connection conn, int usuarioId, int conteoDias, List<RecompensaItem> recompensas)
            throws SQLException {
        validarUsuarioId(usuarioId);
        if (recompensas == null) {
            throw new IllegalArgumentException("La lista de recompensas es obligatoria");
        }

        asegurarCatalogoYLogros(conn);

        agregarRecompensaSiCorresponde(conn, usuarioId, 20, "Vestido Azul", conteoDias, recompensas);
        agregarRecompensaSiCorresponde(conn, usuarioId, 30, "Traje Pirata", conteoDias, recompensas);
        agregarRecompensaSiCorresponde(conn, usuarioId, 60, "Traje con Lentes", conteoDias, recompensas);
        sincronizarEquipamientoRopa(conn, usuarioId);
    }

    private void agregarRecompensaSiCorresponde(Connection conn, int usuarioId, int umbralDias, String nombreItem,
            int conteoDias, List<RecompensaItem> recompensas) throws SQLException {
        if (conteoDias < umbralDias) {
            return;
        }

        int itemId = obtenerIdItemPorNombre(conn, nombreItem);
        if (itemId <= 0) {
            return;
        }

        if (otorgarSiFalta(conn, usuarioId, nombreItem)) {
            recompensas.add(new RecompensaItem(itemId, nombreItem, TIPO_ROPA, 1,
                    "Recompensa por " + umbralDias + " dias de racha"));
        }
    }

    private void asegurarCatalogoYLogros(Connection conn) throws SQLException {
        sincronizarSecuencias(conn);
        for (DefinicionRecompensa recompensa : RECOMPENSAS) {
            int itemId = obtenerOCrearItem(conn, recompensa.nombreItem);
            upsertLogro(conn, recompensa.nombreItem, recompensa.tipoCondicion, recompensa.valorRequerido, itemId);
        }
    }

    private void sincronizarSecuencias(Connection conn) throws SQLException {
        sincronizarSecuencia(conn, "public.mascota_catalogo_items", "item_id");
        sincronizarSecuencia(conn, "public.mascota_logros", "logro_id");
        sincronizarSecuencia(conn, "public.mascota_inventario", "inventario_id");
    }

    private void sincronizarSecuencia(Connection conn, String tabla, String columna) throws SQLException {
        String sql = "SELECT setval(pg_get_serial_sequence('" + tabla + "', '" + columna + "'), "
                + "COALESCE((SELECT MAX(" + columna + ") FROM " + tabla + "), 0) + 1, false)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeQuery();
        }
    }

    private int obtenerOCrearItem(Connection conn, String nombreItem) throws SQLException {
        int itemId = obtenerIdItemPorNombre(conn, nombreItem);
        if (itemId > 0) {
            return itemId;
        }

        String insertSql = "INSERT INTO public.mascota_catalogo_items (nombre, tipo, beneficio_puntos, url_imagen) "
                + "VALUES (?, ?, ?, ?) RETURNING item_id";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setString(1, nombreItem);
            ps.setString(2, TIPO_ROPA);
            ps.setInt(3, 0);
            ps.setString(4, null);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("item_id");
                }
            }
        }

        throw new IllegalStateException("No se pudo crear el item de mascota: " + nombreItem);
    }

    private void upsertLogro(Connection conn, String nombre, String tipoCondicion, int valorRequerido, int itemId)
            throws SQLException {
        String selectSql = "SELECT logro_id FROM public.mascota_logros WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setString(1, nombre);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int logroId = rs.getInt("logro_id");
                    String updateSql = "UPDATE public.mascota_logros SET tipo_condicion = ?, valor_requerido = ?, recompensa_item_id = ? WHERE logro_id = ?";
                    try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                        ups.setString(1, tipoCondicion);
                        ups.setInt(2, valorRequerido);
                        ups.setInt(3, itemId);
                        ups.setInt(4, logroId);
                        ups.executeUpdate();
                    }
                    return;
                }
            }
        }

        String insertSql = "INSERT INTO public.mascota_logros (nombre, tipo_condicion, valor_requerido, recompensa_item_id) "
                + "VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setString(1, nombre);
            ps.setString(2, tipoCondicion);
            ps.setInt(3, valorRequerido);
            ps.setInt(4, itemId);
            ps.executeUpdate();
        }
    }

    private boolean otorgarSiFalta(Connection conn, int usuarioId, String nombreItem) throws SQLException {
        int itemId = obtenerIdItemPorNombre(conn, nombreItem);
        if (itemId <= 0) {
            return false;
        }

        String checkSql = "SELECT inventario_id FROM public.mascota_inventario WHERE usuario_id = ? AND item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, usuarioId);
            ps.setInt(2, itemId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return false;
                }
            }
        }

        String insertSql = "INSERT INTO public.mascota_inventario (usuario_id, item_id, cantidad, esta_equipado) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setInt(1, usuarioId);
            ps.setInt(2, itemId);
            ps.setInt(3, 1);
            ps.setBoolean(4, esItemRopa(conn, itemId));
            ps.executeUpdate();
        }
        return true;
    }

    private void sincronizarEquipamientoRopa(Connection conn, int usuarioId) throws SQLException {
        String sql = "UPDATE public.mascota_inventario i "
                + "SET esta_equipado = TRUE "
                + "FROM public.mascota_catalogo_items c "
                + "WHERE i.item_id = c.item_id "
                + "AND i.usuario_id = ? "
                + "AND COALESCE(i.esta_equipado, FALSE) = FALSE "
                + "AND (LOWER(COALESCE(c.tipo, '')) LIKE '%ropa%' "
                + "OR LOWER(COALESCE(c.nombre, '')) LIKE 'conjunto %' "
                + "OR LOWER(COALESCE(c.nombre, '')) LIKE 'traje %' "
                + "OR LOWER(COALESCE(c.nombre, '')) LIKE 'vestido %')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.executeUpdate();
        }
    }

    private boolean esItemRopa(Connection conn, int itemId) throws SQLException {
        String sql = "SELECT tipo, nombre FROM public.mascota_catalogo_items WHERE item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String tipo = normalizar(rs.getString("tipo"));
                    String nombre = normalizar(rs.getString("nombre"));
                    return tipo.contains("ropa")
                            || nombre.startsWith("conjunto ")
                            || nombre.startsWith("traje ")
                            || nombre.startsWith("vestido ");
                }
            }
        }
        return false;
    }

    private String normalizar(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase()
                .replace('á', 'a')
                .replace('é', 'e')
                .replace('í', 'i')
                .replace('ó', 'o')
                .replace('ú', 'u')
                .replace('ñ', 'n');
    }

    private int obtenerIdItemPorNombre(Connection conn, String nombre) throws SQLException {
        String sql = "SELECT item_id FROM public.mascota_catalogo_items WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("item_id");
                }
            }
        }
        return -1;
    }

    private void validarUsuarioId(int usuarioId) {
        if (usuarioId <= 0) {
            throw new IllegalArgumentException("usuarioId invalido");
        }
    }

    private static final class DefinicionRecompensa {
        private final String nombreItem;
        private final String tipoCondicion;
        private final int valorRequerido;

        private DefinicionRecompensa(String nombreItem, String tipoCondicion, int valorRequerido) {
            this.nombreItem = nombreItem;
            this.tipoCondicion = tipoCondicion;
            this.valorRequerido = valorRequerido;
        }
    }
}