-- ============================================================
-- SIGAS - Sistema de Gestión de Activos
-- Schema v3.1 - Restricciones de Llaves Únicas Garantizadas
-- ============================================================

CREATE DATABASE IF NOT EXISTS sigas;
USE sigas;

-- ============================================================
-- 1. CATÁLOGOS BASE
-- ============================================================
CREATE TABLE IF NOT EXISTS estatus (
  id_Estatus INT AUTO_INCREMENT PRIMARY KEY,
  Estado     VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS sexo (
  ID_Sexo INT AUTO_INCREMENT PRIMARY KEY,
  Nombre  VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS departamentos (
  ID_Departamentos INT AUTO_INCREMENT PRIMARY KEY,
  Nombre            VARCHAR(50) NOT NULL,
  Estatus_id_Estatus INT NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS roles (
  ID_roles         INT AUTO_INCREMENT PRIMARY KEY,
  Nombre           VARCHAR(50) NOT NULL,
  Estatus_ID_Estatus INT NOT NULL DEFAULT 1
);

-- ============================================================
-- 2. INSERCIONES DE CONTROL INMEDIATAS
-- ============================================================
INSERT IGNORE INTO estatus (id_Estatus, Estado) VALUES (1, 'Activo'), (2, 'Inactivo');
INSERT IGNORE INTO sexo (ID_Sexo, Nombre) VALUES (1, 'Masculino'), (2, 'Femenino'), (3, 'Otro');
INSERT IGNORE INTO roles (ID_roles, Nombre) VALUES (1, 'Administrador');
INSERT IGNORE INTO departamentos (ID_Departamentos, Nombre) VALUES (1, 'Sistemas');

-- ============================================================
-- 3. TABLAS DEPENDIENTES
-- ============================================================
CREATE TABLE IF NOT EXISTS salones (
  ID_Salon                          INT AUTO_INCREMENT PRIMARY KEY,
  Departamentos_ID_Departamentos    INT NOT NULL,
  Nombre_Salon                      VARCHAR(60) NOT NULL,
  CONSTRAINT FK_Salones_Departamentos FOREIGN KEY (Departamentos_ID_Departamentos) REFERENCES departamentos(ID_Departamentos)
);

CREATE TABLE IF NOT EXISTS usuarios (
  ID_Usuarios                       INT AUTO_INCREMENT PRIMARY KEY,
  Estatus_id_Estatus                INT NOT NULL DEFAULT 1,
  Sexo_ID_Sexo                      INT NOT NULL,
  Roles_ID_roles                    INT NOT NULL,
  Departamentos_ID_Departamentos    INT NOT NULL,
  Pass                              VARCHAR(255) NOT NULL,
  Nombre                            VARCHAR(50)  NOT NULL,
  Paterno                           VARCHAR(50)  NULL,
  Materno                           VARCHAR(50)  NULL,
  Correo                            VARCHAR(100) NOT NULL UNIQUE,
  Telefono                          BIGINT       NULL,
  CONSTRAINT FK_Usuarios_Estatus        FOREIGN KEY (Estatus_id_Estatus)             REFERENCES estatus(id_Estatus),
  CONSTRAINT FK_Usuarios_Sexo           FOREIGN KEY (Sexo_ID_Sexo)                   REFERENCES sexo(ID_Sexo),
  CONSTRAINT FK_Usuarios_Roles          FOREIGN KEY (Roles_ID_roles)                 REFERENCES roles(ID_roles),
  CONSTRAINT FK_Usuarios_Departamentos  FOREIGN KEY (Departamentos_ID_Departamentos) REFERENCES departamentos(ID_Departamentos)
);

CREATE TABLE IF NOT EXISTS equipos (
  Id_equipo          INT AUTO_INCREMENT PRIMARY KEY,
  Estatus_id_Estatus INT NOT NULL DEFAULT 1,
  Salones_ID_Salon   INT NOT NULL,
  Nombre             VARCHAR(50)  NOT NULL,
  Fecha_Entrada      DATE         NULL,
  Fecha_Salida       DATE         NULL,
  Tipo               VARCHAR(50)  NULL,
  ClaveUnicaEquipo   VARCHAR(20)  NOT NULL UNIQUE,
  Motivo             VARCHAR(255) NULL,
  CONSTRAINT FK_Equipos_Estatus  FOREIGN KEY (Estatus_id_Estatus) REFERENCES estatus(id_Estatus),
  CONSTRAINT FK_Equipos_Salones  FOREIGN KEY (Salones_ID_Salon)   REFERENCES salones(ID_Salon)
);

CREATE TABLE IF NOT EXISTS componentes (
  ID_Componentes  INT AUTO_INCREMENT PRIMARY KEY,
  Equipos_Id_equipo INT NULL,
  Nombre          VARCHAR(50)  NOT NULL,
  Marca           VARCHAR(50)  NULL,
  Descripcion     VARCHAR(200) NULL,
  CONSTRAINT FK_Componentes_Equipos FOREIGN KEY (Equipos_Id_equipo) REFERENCES equipos(Id_equipo)
);

CREATE TABLE IF NOT EXISTS registro_fallas (
  ID_Falla           INT AUTO_INCREMENT PRIMARY KEY,
  Equipos_Id_equipo  INT  NOT NULL,
  Fecha_falla        DATE NOT NULL DEFAULT (CURDATE()),
  Descripcion_Falla  VARCHAR(1000) NOT NULL,
  Severidad          ENUM('Baja','Media','Alta','Critica') NOT NULL DEFAULT 'Media',
  Estatus_Falla      ENUM('Pendiente','En proceso','Resuelta') NOT NULL DEFAULT 'Pendiente',
  Fecha_Resolucion   DATE NULL,
  Notas_Resolucion   VARCHAR(500) NULL,
  CONSTRAINT FK_Fallas_Equipos FOREIGN KEY (Equipos_Id_equipo) REFERENCES equipos(Id_equipo)
);

CREATE TABLE IF NOT EXISTS movimientos (
  ID_Movimiento      INT AUTO_INCREMENT PRIMARY KEY,
  Equipos_Id_equipo  INT NOT NULL,
  Tipo_Movimiento    ENUM('Alta','Baja','Traslado') NOT NULL,
  Fecha_Movimiento   DATE NOT NULL DEFAULT (CURDATE()),
  Motivo             VARCHAR(255) NULL,
  CONSTRAINT FK_Movimientos_Equipos FOREIGN KEY (Equipos_Id_equipo) REFERENCES equipos(Id_equipo)
);

-- ============================================================
-- 4. INYECTAR ADMINISTRADOR AL FINAL DE TODO
-- ============================================================
INSERT IGNORE INTO usuarios (Estatus_id_Estatus, Sexo_ID_Sexo, Roles_ID_roles, Departamentos_ID_Departamentos, Pass, Nombre, Paterno, Materno, Correo, Telefono) 
VALUES (1, 1, 1, 1, '1234', 'Admin', 'General', 'SIGAS', 'admin@sigas.com', 8441112233);
