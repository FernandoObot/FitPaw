package com.fitpaw.backend.DTOs;

import com.fitpaw.backend.model.MetaUsuario;
import com.fitpaw.backend.model.RegistroActividad;
import com.fitpaw.backend.model.Racha;

public class CumplimientoMetaRequest {

    private MetaUsuario meta;
    private RegistroActividad registro;
    private Racha racha;

    public CumplimientoMetaRequest() {
    }

    public MetaUsuario getMeta() {
        return meta;
    }

    public void setMeta(MetaUsuario meta) {
        this.meta = meta;
    }

    public RegistroActividad getRegistro() {
        return registro;
    }

    public void setRegistro(RegistroActividad registro) {
        this.registro = registro;
    }

    public Racha getRacha() {
        return racha;
    }

    public void setRacha(Racha racha) {
        this.racha = racha;
    }
}