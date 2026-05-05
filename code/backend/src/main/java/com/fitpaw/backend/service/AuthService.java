package com.fitpaw.backend.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.regex.Pattern;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.auth0.jwt.exceptions.JWTCreationException;
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

    @Value("${app.default.role:USER}")
    private String defaultRole;

    public AuthService(ConexionDB conexionDB, BCryptPasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.conexionDB = conexionDB;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

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

        try (Connection conn = conexionDB.conectar()) {
            ensureAuthSchema(conn);

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
                        int id = rs.getInt(1);
                        RegisterResponse response = new RegisterResponse();
                        response.setUsuarioId(id);
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

    public void updateProfile(int usuarioId, UpdateProfileRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body del perfil es obligatorio");
        }

        try (Connection conn = conexionDB.conectar()) {
            String updateSql = "UPDATE public.usuarios_cuenta SET genero = ?, fecha_nacimiento = ?, peso_actual = ?, estatura_cm = ? WHERE usuario_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, request.getGenero());
                if (request.getFechaNacimiento() != null) {
                    ps.setDate(2, java.sql.Date.valueOf(request.getFechaNacimiento()));
                } else {
                    ps.setNull(2, java.sql.Types.DATE);
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
}