package com.fitpaw.backend.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.regex.Pattern;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.auth0.jwt.exceptions.JWTCreationException;
import com.fitpaw.backend.model.User;
import com.fitpaw.backend.DTOs.LoginRequest;
import com.fitpaw.backend.DTOs.RegisterRequest;
import com.fitpaw.backend.DTOs.RegisterResponse;
import com.fitpaw.backend.DTOs.TokenResponse;
import com.fitpaw.backend.DTOs.UpdateProfileRequest;
import com.fitpaw.backend.DTOs.EditProfileRequest;
import com.fitpaw.backend.repository.ConexionDB;
import com.fitpaw.backend.util.JwtUtil;

@Service
public class AuthService {

    private static final Pattern PHONE_10_DIGITS = Pattern.compile("^\\d{10}$");

    private final ConexionDB conexionDB;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final MascotaLogrosService mascotaLogrosService;

    @Value("${app.default.role:USER}")
    private String defaultRole;

    public AuthService(ConexionDB conexionDB, BCryptPasswordEncoder passwordEncoder, JwtUtil jwtUtil,
            MascotaLogrosService mascotaLogrosService) {
        this.conexionDB = conexionDB;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.mascotaLogrosService = mascotaLogrosService;
    }

    public RegisterResponse register(RegisterRequest request) {
        System.out.println("\n\n🔴🔴🔴 [REGISTER] INICIO DEL REGISTRO 🔴🔴🔴");
        if (request == null) {
            throw new IllegalArgumentException("El body de registro es obligatorio");
        }

        String nombreCompleto = clean(request.getNombreCompleto());
        String telefono = clean(request.getTelefono());
        String password = clean(request.getPassword());
        
        System.out.println("[REGISTER] Nombre: " + nombreCompleto + " | Teléfono: " + telefono);

        if (nombreCompleto.isEmpty() || telefono.isEmpty() || password.isEmpty()) {
            throw new IllegalArgumentException("Todos los campos son obligatorios");
        }

        if (!PHONE_10_DIGITS.matcher(telefono).matches()) {
            throw new IllegalArgumentException("El telefono debe tener exactamente 10 digitos");
        }

        try (Connection conn = conexionDB.conectar()) {
            ensureAuthSchema(conn);
            sincronizarSecuenciaUsuarios(conn);

            String checkSql = "SELECT usuario_id FROM public.usuarios_cuenta WHERE telefono = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, telefono);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        throw new IllegalStateException("El telefono ya se encuentra registrado");
                    }
                }
            }

            String hashed = passwordEncoder.encode(password);
            String insertSql = "INSERT INTO public.usuarios_cuenta (nickname, telefono, password, rol, fecha_registro) VALUES (?, ?, ?, ?, ?) RETURNING usuario_id";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, nombreCompleto);
                ps.setString(2, telefono);
                ps.setString(3, hashed);
                ps.setString(4, defaultRole);
                ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int usuarioId = rs.getInt(1);
                        System.out.println("✅ Usuario creado con ID: " + usuarioId);
                        
                        // 🔑 Crear mascota en transacción SEPARADA pero ESPERAR resultado
                        try {
                            crearMascotaEnSegundoPlano(usuarioId);
                            // Pequeña pausa para permitir que el thread inicie
                            Thread.sleep(100);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                        
                        RegisterResponse response = new RegisterResponse();
                        response.setUsuarioId(usuarioId);
                        response.setNombreCompleto(nombreCompleto);
                        response.setTelefono(telefono);
                        response.setRol(defaultRole);
                        response.setMensaje("Registro exitoso");
                        return response;
                    } else {
                        throw new IllegalStateException("No se pudo crear el usuario");
                    }
                }
            }

        } catch (SQLException e) {
            throw new IllegalStateException("Error al acceder a la base de datos: " + e.getMessage());
        }
    }

    public TokenResponse login(LoginRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body de login es obligatorio");
        }

        String telefono = clean(request.getTelefono());
        String password = clean(request.getPassword());

        if (telefono.isEmpty() || password.isEmpty()) {
            throw new IllegalArgumentException("Telefono y contraseña son obligatorios");
        }

        if (!PHONE_10_DIGITS.matcher(telefono).matches()) {
            throw new IllegalArgumentException("El telefono debe tener exactamente 10 digitos");
        }

        try (Connection conn = conexionDB.conectar()) {
            ensureAuthSchema(conn);

            String query = "SELECT usuario_id, password FROM public.usuarios_cuenta WHERE telefono = ?";
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, telefono);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int usuarioId = rs.getInt("usuario_id");
                        String hashed = rs.getString("password");
                        if (passwordEncoder.matches(password, hashed)) {
                            mascotaLogrosService.otorgarRecompensasPrimerLogin(usuarioId);
                            try {
                                String token = jwtUtil.generateToken(usuarioId, telefono);
                                return new TokenResponse(token, usuarioId);
                            } catch (JWTCreationException ex) {
                                throw new IllegalStateException("Error generando token");
                            }
                        } else {
                            throw new IllegalStateException("Credenciales inválidas");
                        }
                    } else {
                        throw new IllegalStateException("Credenciales inválidas");
                    }
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al acceder a la base de datos: " + e.getMessage());
        }
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private void ensureAuthSchema(Connection conn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("ALTER TABLE public.usuarios_cuenta ADD COLUMN IF NOT EXISTS telefono character varying")) {
            ps.execute();
        }

        try (PreparedStatement ps = conn.prepareStatement("CREATE UNIQUE INDEX IF NOT EXISTS usuarios_cuenta_telefono_idx ON public.usuarios_cuenta (telefono)")) {
            ps.execute();
        }
    }

    private void sincronizarSecuenciaUsuarios(Connection conn) throws SQLException {
        String sql = "SELECT setval(pg_get_serial_sequence('public.usuarios_cuenta', 'usuario_id'), "
                + "COALESCE((SELECT MAX(usuario_id) FROM public.usuarios_cuenta), 0) + 1, false)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeQuery();
        }
    }

    public void updateProfile(int usuarioId, UpdateProfileRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body del perfil es obligatorio");
        }

        try (Connection conn = conexionDB.conectar()) {
            String updateSql = "UPDATE public.usuarios_cuenta SET genero = ?, fecha_nacimiento = ?, peso_actual = ?, estatura_cm = ? WHERE usuario_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, request.getGenero());
                if (request.getFechaNacimiento() != null && request.getFechaNacimiento() > 0) {
                    ps.setInt(2, request.getFechaNacimiento());
                } else {
                    ps.setNull(2, java.sql.Types.INTEGER);
                }
                ps.setDouble(3, request.getPesoActual() != null ? request.getPesoActual() : 0);
                ps.setInt(4, request.getEstaturaCm() != null ? request.getEstaturaCm() : 0);
                ps.setInt(5, usuarioId);

                int updated = ps.executeUpdate();
                if (updated == 0) {
                    throw new IllegalStateException("Usuario no encontrado");
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al actualizar el perfil: " + e.getMessage());
        }
    }

    public void editProfile(int usuarioId, EditProfileRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body del perfil es obligatorio");
        }

        List<Object> params = new ArrayList<>();
        StringBuilder sb = new StringBuilder("UPDATE public.usuarios_cuenta SET ");

        if (request.getNombre() != null) {
            String nombre = clean(request.getNombre());
            if (nombre.isEmpty()) {
                throw new IllegalArgumentException("El nombre no puede estar vacío");
            }
            sb.append("nickname = ?, ");
            params.add(nombre);
        }

        if (request.getPeso() != null) {
            sb.append("peso_actual = ?, ");
            params.add(request.getPeso());
        }

        if (request.getEstatura() != null) {
            sb.append("estatura_cm = ?, ");
            params.add(request.getEstatura());
        }

        if (params.isEmpty()) {
            throw new IllegalArgumentException("Al menos un campo a editar es obligatorio");
        }

        // remove trailing comma and space
        int len = sb.length();
        sb.delete(len - 2, len);
        sb.append(" WHERE usuario_id = ?");
        params.add(usuarioId);

        try (Connection conn = conexionDB.conectar()) {
            try (PreparedStatement ps = conn.prepareStatement(sb.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    Object p = params.get(i);
                    if (p instanceof String) {
                        ps.setString(i + 1, (String) p);
                    } else if (p instanceof Integer) {
                        ps.setInt(i + 1, (Integer) p);
                    } else if (p instanceof Double) {
                        ps.setDouble(i + 1, (Double) p);
                    } else if (p instanceof Float) {
                        ps.setDouble(i + 1, ((Float) p).doubleValue());
                    } else {
                        ps.setObject(i + 1, p);
                    }
                }

                int updated = ps.executeUpdate();
                if (updated == 0) {
                    throw new IllegalStateException("Usuario no encontrado");
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al editar el perfil: " + e.getMessage());
        }
    }

    public User getProfile(int usuarioId) {
        try (Connection conn = conexionDB.conectar()) {
            String sql = "SELECT usuario_id, nickname, genero, fecha_nacimiento, peso_actual, estatura_cm FROM public.usuarios_cuenta WHERE usuario_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        User user = new User();
                        user.setUsuarioId(rs.getInt("usuario_id"));
                        user.setNickname(rs.getString("nickname"));
                        user.setGenero(rs.getString("genero"));
                        Integer fechaNacimiento = rs.getInt("fecha_nacimiento");
                        if (!rs.wasNull()) {
                            user.setFechaNacimiento(fechaNacimiento);
                        }
                        Double peso = rs.getDouble("peso_actual");
                        if (!rs.wasNull()) user.setPesoActual(peso);
                        Integer estatura = rs.getInt("estatura_cm");
                        if (!rs.wasNull()) user.setEstaturaCm(estatura);
                        return user;
                    } else {
                        throw new IllegalStateException("Usuario no encontrado");
                    }
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener perfil: " + e.getMessage());
        }
    }

    /**
     * Crea una mascota por defecto cuando el usuario se registra
     * Usa timestamp en lugar de date
     */
    private void crearMascotaDefault(Connection conn, int usuarioId) throws SQLException {
        System.out.println("[MASCOTA] Iniciando creación para usuario " + usuarioId);
        
        // Verificar si ya existe mascota para este usuario
        String checkMascotaSql = "SELECT mascota_id FROM public.mascota_estado WHERE usuario_id = ?";
        try (PreparedStatement psCheck = conn.prepareStatement(checkMascotaSql)) {
            psCheck.setInt(1, usuarioId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    System.out.println("⚠️ [MASCOTA] Mascota ya existe para usuario " + usuarioId);
                    return;
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ [MASCOTA] Error verificar mascota: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        
        Timestamp ahora = Timestamp.valueOf(LocalDateTime.now());
        
        // 🔑 Sin RETURNING - usar RETURN_GENERATED_KEYS para columna IDENTITY
        String insertMascotaSql = "INSERT INTO public.mascota_estado (usuario_id, nombre, hambre, ultima_vez_alimentado) VALUES (?, ?, ?, ?)";
        int mascotaId = -1;
        try (PreparedStatement ps = conn.prepareStatement(insertMascotaSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, usuarioId);
            ps.setString(2, "Pingui");
            ps.setInt(3, 100);
            ps.setTimestamp(4, ahora);
            
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    mascotaId = rs.getInt(1);
                    System.out.println("✅ [MASCOTA] INSERT mascota_estado: mascota_id=" + mascotaId + " para usuario " + usuarioId);
                } else {
                    throw new SQLException("No se retornó mascota_id después del INSERT");
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ [MASCOTA] Error INSERT mascota_estado: " + e.getMessage());
            System.err.println("    SQL: " + e.getSQLState() + " | Code: " + e.getErrorCode());
            e.printStackTrace();
            throw e;
        }

        if (mascotaId > 0) {
            System.out.println("[MASCOTA] Creando comidas para mascota_id=" + mascotaId);
            crearComidassDefault(conn, mascotaId);
        } else {
            throw new SQLException("mascota_id no fue generado correctamente");
        }
    }

    /**
     * Crea las 4 comidas por defecto (con cantidad 0) para una mascota
     */
    private void crearComidassDefault(Connection conn, int mascotaId) throws SQLException {
        System.out.println("[COMIDAS] Iniciando creación para mascota " + mascotaId);
        String[] comidas = {"Krill", "Pez", "Calamar", "Coctel"};
        int[] beneficios = {15, 25, 50, 100};

        String insertComidaSql = "INSERT INTO public.mascota_alimento (mascota_id, nombre_comida, cantidad, beneficio_puntos) VALUES (?, ?, ?, ?)";
        
        for (int i = 0; i < comidas.length; i++) {
            try (PreparedStatement ps = conn.prepareStatement(insertComidaSql)) {
                ps.setInt(1, mascotaId);
                ps.setString(2, comidas[i]);
                ps.setInt(3, 0);
                ps.setInt(4, beneficios[i]);
                int rows = ps.executeUpdate();
                System.out.println("  ✅ [COMIDAS] " + comidas[i] + ": " + rows + " filas");
            } catch (SQLException e) {
                System.err.println("  ❌ [COMIDAS] Error " + comidas[i] + ": " + e.getMessage());
                System.err.println("     SQL: " + e.getSQLState() + " | Code: " + e.getErrorCode());
                e.printStackTrace();
                throw e;
            }
        }
        System.out.println("✅ [COMIDAS] Todas las comidas creadas para mascota " + mascotaId);
    }

    /**
     * Crea la mascota en una transacción SEPARADA
     * El usuario ya fue confirmado, así que si falla aquí, el usuario sigue existiendo
     */
    private void crearMascotaEnSegundoPlano(int usuarioId) {
        // Ejecutar en thread separado para no bloquear el registro
        Thread mascotaThread = new Thread(() -> {
            try {
                System.out.println("[ASYNC] 🚀 Thread iniciado para usuario " + usuarioId);
                try (Connection conn = conexionDB.conectar()) {
                    System.out.println("[ASYNC] 🔗 Conexión obtenida");
                    crearMascotaDefault(conn, usuarioId);
                    System.out.println("[ASYNC] ✅ Mascota y comidas creadas para usuario " + usuarioId);
                }
            } catch (Exception e) {
                System.err.println("[ASYNC] ❌ Error para usuario " + usuarioId + ": " + e.getMessage());
                e.printStackTrace();
            }
        }, "MascotaCreator-" + usuarioId);
        
        mascotaThread.setDaemon(false);
        mascotaThread.start();
        System.out.println("[MAIN] Thread lanzado para mascota del usuario " + usuarioId);
    }

}