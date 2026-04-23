package com.fitpaw.backend.repository;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import org.springframework.stereotype.Repository;

@Repository
public class ConexionDB {
    private static final String HOST = "db.qymbwyvmudplnyvwmkkp.supabase.co";
    private static final String DB = "postgres";
    private static final String USER = "postgres";
    private static final String PASSWORD = "JorgitoFitpat";
    private static final String PORT = "5432";

    private static final String URL = "jdbc:postgresql://" + HOST + ":" + PORT + "/" + DB;
    private Connection conexion;

    public ConexionDB() {
        // Constructor por defecto
    }

    public Connection conectar() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
            conexion = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Conectado a Supabase (FitPaw)");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver no encontrado");
            e.printStackTrace();
        }
        return conexion;
    }

    public void desconectar() {
        try {
            if (conexion != null && !conexion.isClosed()) {
                conexion.close();
                System.out.println("Conexión cerrada");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void guardarUrlEnBaseDatos(int usuarioId, String urlFoto) {
        String sql = "INSERT INTO prueba_eve (\"Foto\") VALUES (?)";
        try (Connection conn = this.conectar();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, urlFoto);
            int filasAfectadas = pstmt.executeUpdate();
            if (filasAfectadas > 0) {
                System.out.println("¡Registro insertado exitosamente en la tabla prueba_eve!");
            }
        } catch (SQLException e) {
            System.err.println("Error al guardar URL en BD:");
            e.printStackTrace();
        }
    }
}
