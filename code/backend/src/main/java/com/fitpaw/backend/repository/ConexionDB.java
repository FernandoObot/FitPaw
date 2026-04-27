package com.fitpaw.backend.repository;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;

@Repository
public class ConexionDB {

    @Value("${db.HOST}")
    private String HOST;

    @Value("${db.DB}")
    private String DB;

    @Value("${db.USER}")
    private String USER;

    @Value("${db.PASSWORD}")
    private String PASSWORD;

    @Value("${db.PORT}")
    private String PORT;

    private Connection conexion;

    public ConexionDB() {
    }

    public Connection conectar() throws SQLException {
        String url = "jdbc:postgresql://" + HOST + ":" + PORT + "/" + DB;
        try {
            Class.forName("org.postgresql.Driver");
            conexion = DriverManager.getConnection(url, USER, PASSWORD);
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

}
