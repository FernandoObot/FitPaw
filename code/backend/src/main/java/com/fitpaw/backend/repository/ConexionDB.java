package com.fitpaw.backend.repository;

import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.springframework.stereotype.Repository;

@Repository
public class ConexionDB implements DatabaseConnectionProvider {

    private final DataSource dataSource;

    public ConexionDB(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public Connection conectar() throws SQLException {
        return dataSource.getConnection();
    }

    public void desconectar() {
    }

}
