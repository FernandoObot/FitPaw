package com.fitpaw.backend.repository;

import java.sql.Connection;
import java.sql.SQLException;

public interface DatabaseConnectionProvider {
    Connection conectar() throws SQLException;
}
