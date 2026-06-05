

-- ============================================================
-- SIGAS - Sistema de Gestión de Activos
-- Schema v2.0 - Reingeniería Completa
-- ============================================================

CREATE DATABASE IF NOT EXISTS SIGAS;
USE SIGAS;

-- ============================================================
-- 1. TABLAS MAESTRAS (Sin dependencias)
-- ============================================================

CREATE TABLE IF NOT EXISTS Departamentos (
  ID_Departamentos INT AUTO_INCREMENT PRIMARY KEY,
  Nombre           VARCHAR(50) NOT NULL,
  Estatus_id_Estatus INT NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS Estatus (
  id_Estatus INT AUTO_INCREMENT PRIMARY KEY,
  Estado     VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS Roles (
  ID_roles         INT AUTO_INCREMENT PRIMARY KEY,
  Nombre           VARCHAR(50) NOT NULL,
  Estatus_ID_Estatus INT NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS Sexo (
  ID_Sexo INT AUTO_INCREMENT PRIMARY KEY,
  Nombre  VARCHAR(50) NOT NULL
);

-- ============================================================
-- 2. DATOS INICIALES REQUERIDOS
-- ============================================================

INSERT IGNORE INTO Estatus (id_Estatus, Estado) VALUES
  (1, 'Activo'),
  (2, 'Inactivo');

INSERT IGNORE INTO Sexo (ID_Sexo, Nombre) VALUES
  (1, 'Masculino'),
  (2, 'Femenino'),
  (3, 'Otro');

-- ============================================================
-- 3. TABLAS CON DEPENDENCIAS
-- ============================================================

CREATE TABLE IF NOT EXISTS Salones (
  ID_Salon                          INT AUTO_INCREMENT PRIMARY KEY,
  Departamentos_ID_Departamentos    INT NOT NULL,
  Nombre_Salon                      VARCHAR(60) NOT NULL,
  CONSTRAINT FK_Salones_Deptos FOREIGN KEY (Departamentos_ID_Departamentos)
    REFERENCES Departamentos(ID_Departamentos)
);

CREATE TABLE IF NOT EXISTS Usuarios (
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
  CONSTRAINT FK_Usuarios_Estatus  FOREIGN KEY (Estatus_id_Estatus)             REFERENCES Estatus(id_Estatus),
  CONSTRAINT FK_Usuarios_Sexo     FOREIGN KEY (Sexo_ID_Sexo)                   REFERENCES Sexo(ID_Sexo),
  CONSTRAINT FK_Usuarios_Roles    FOREIGN KEY (Roles_ID_roles)                 REFERENCES Roles(ID_roles),
  CONSTRAINT FK_Usuarios_Deptos   FOREIGN KEY (Departamentos_ID_Departamentos) REFERENCES Departamentos(ID_Departamentos)
);

CREATE TABLE IF NOT EXISTS Equipos (
  Id_equipo          INT AUTO_INCREMENT PRIMARY KEY,
  Estatus_id_Estatus INT NOT NULL DEFAULT 1,
  Salones_ID_Salon   INT NOT NULL,
  Nombre             VARCHAR(50)  NOT NULL,
  Fecha_Entrada      DATE         NULL,
  Fecha_Salida       DATE         NULL,
  Tipo               VARCHAR(50)  NULL,
  ClaveUnicaEquipo   VARCHAR(20)  NOT NULL UNIQUE,
  Motivo             VARCHAR(255) NULL,
  CONSTRAINT FK_Equipos_Estatus FOREIGN KEY (Estatus_id_Estatus) REFERENCES Estatus(id_Estatus),
  CONSTRAINT FK_Equipos_Salones FOREIGN KEY (Salones_ID_Salon)   REFERENCES Salones(ID_Salon)
);

CREATE TABLE IF NOT EXISTS Componentes (
  ID_Componentes  INT AUTO_INCREMENT PRIMARY KEY,
  Equipos_Id_equipo INT NULL,
  Nombre          VARCHAR(50)  NOT NULL,
  Marca           VARCHAR(50)  NULL,
  Descripcion     VARCHAR(200) NULL,
  CONSTRAINT FK_Componentes_Equipos FOREIGN KEY (Equipos_Id_equipo)
    REFERENCES Equipos(Id_equipo)
);

-- ============================================================
-- 4. TABLA REGISTRO_FALLAS (Módulo nuevo)
--    Se añaden: Severidad, Estatus_Falla, Reportado_por
-- ============================================================

CREATE TABLE IF NOT EXISTS Registro_fallas (
  ID_Falla           INT AUTO_INCREMENT PRIMARY KEY,
  Equipos_Id_equipo  INT  NOT NULL,
  Fecha_falla        DATE NOT NULL DEFAULT (CURDATE()),
  Descripcion_Falla  VARCHAR(1000) NOT NULL,
  Severidad          ENUM('Baja','Media','Alta','Critica') NOT NULL DEFAULT 'Media',
  Estatus_Falla      ENUM('Pendiente','En proceso','Resuelta') NOT NULL DEFAULT 'Pendiente',
  Fecha_Resolucion   DATE NULL,
  Notas_Resolucion   VARCHAR(500) NULL,
  CONSTRAINT FK_Fallas_Equipos FOREIGN KEY (Equipos_Id_equipo)
    REFERENCES Equipos(Id_equipo)
);

-- ============================================================
-- 5. TABLA MOVIMIENTOS (Historial de altas y bajas)
-- ============================================================

CREATE TABLE IF NOT EXISTS Movimientos (
  ID_Movimiento      INT AUTO_INCREMENT PRIMARY KEY,
  Equipos_Id_equipo  INT NOT NULL,
  Tipo_Movimiento    ENUM('Alta','Baja','Traslado') NOT NULL,
  Fecha_Movimiento   DATE NOT NULL DEFAULT (CURDATE()),
  Motivo             VARCHAR(255) NULL,
  CONSTRAINT FK_Movimientos_Equipos FOREIGN KEY (Equipos_Id_equipo)
    REFERENCES Equipos(Id_equipo)
);

-- ============================================================
-- 6. RELACIONES FALTANTES (FK diferidas para Departamentos/Roles)
-- ============================================================

ALTER TABLE Departamentos
  ADD CONSTRAINT FK_Deptos_Estatus
  FOREIGN KEY (Estatus_id_Estatus) REFERENCES Estatus(id_Estatus);

ALTER TABLE Roles
  ADD CONSTRAINT FK_Roles_Estatus
  FOREIGN KEY (Estatus_ID_Estatus) REFERENCES Estatus(id_Estatus);


INSERT IGNORE INTO Roles (ID_roles, Nombre) VALUES (1, 'Administrador');
INSERT IGNORE INTO Sexo (ID_Sexo) VALUES (1); -- usando el truco de compatibilidad si es necesario
INSERT IGNORE INTO Departamentos (ID_Departamentos, Nombre) VALUES (1, 'Sistemas');
INSERT IGNORE INTO Estatus (id_Estatus, Estado) VALUES (1, 'Activo');
