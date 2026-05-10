---INICIO DE PROYECCTO

-- Creo Mi Base de datos
CREATE DATABASE Customer_Churn_DB;
GO
USE Customer_Churn_DB;
GO

-- Eliminar la tabla sucia del master
USE master;
DROP TABLE IF EXISTS Telco_Customer_Churn;
GO

--Crear la tabla limpia en la base correcta
USE Customer_Churn_DB;
GO

---CARGA MASIVA
CREATE TABLE Telco_Customer_Churn(
    customerID       NVARCHAR(50),
    gender           NVARCHAR(50),
    SeniorCitizen    NVARCHAR(50),
    Partner          NVARCHAR(50),
    Dependents       NVARCHAR(50),
    tenure           NVARCHAR(50),
    PhoneService     NVARCHAR(50),
    MultipleLines    NVARCHAR(50),
    InternetService  NVARCHAR(50),
    OnlineSecurity   NVARCHAR(50),
    OnlineBackup     NVARCHAR(50),
    DeviceProtection NVARCHAR(50),
    TechSupport      NVARCHAR(50),
    StreamingTV      NVARCHAR(50),
    StreamingMovies  NVARCHAR(50),
    Contract         NVARCHAR(50),
    PaperlessBilling NVARCHAR(50),
    PaymentMethod    NVARCHAR(50),
    MonthlyCharges   NVARCHAR(50),
    TotalCharges     NVARCHAR(50),
    Churn            NVARCHAR(50)
);

-- Cargar el CSV 
BULK INSERT Telco_Customer_Churn
FROM 'C:\Users\HP\OneDrive\Documentos\SQL Server Management Studio\PROYECTO SQL\DATA\WA_Fn-UseC_-Telco-Customer-Churn.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

SELECT COUNT(*) AS Total_Registros
FROM Telco_Customer_Churn;

-- PASO 1: DIMENSION CLIENTE

CREATE TABLE Dim_Cliente (
    ClienteID     INT IDENTITY(1,1) PRIMARY KEY,
    customerID    NVARCHAR(50),
    Gender        NVARCHAR(10),
    SeniorCitizen NVARCHAR(5),
    Partner       NVARCHAR(5),
    Dependents    NVARCHAR(5)
);

INSERT INTO Dim_Cliente (customerID, Gender, SeniorCitizen, Partner, Dependents)
SELECT DISTINCT 
    customerID, gender, SeniorCitizen, Partner, Dependents
FROM Telco_Customer_Churn;

SELECT COUNT(*) AS Total_Dim_Cliente FROM Dim_Cliente;


-- PASO 2: DIMENSION CONTRATO
CREATE TABLE Dim_Contrato (
    ContractID       INT IDENTITY(1,1) PRIMARY KEY,
    Contract         NVARCHAR(20),
    PaperlessBilling NVARCHAR(5),
    PaymentMethod    NVARCHAR(30)
);

INSERT INTO Dim_Contrato (Contract, PaperlessBilling, PaymentMethod)
SELECT DISTINCT 
    Contract, PaperlessBilling, PaymentMethod
FROM Telco_Customer_Churn;

SELECT COUNT(*) AS Total_Dim_Contrato FROM Dim_Contrato;


-- PASO 3: DIMENSION SERVICIOS

CREATE TABLE Dim_Servicios (
    ServicioID       INT IDENTITY(1,1) PRIMARY KEY,
    customerID       NVARCHAR(50),
    PhoneService     NVARCHAR(5),
    MultipleLines    NVARCHAR(20),
    InternetService  NVARCHAR(20),
    OnlineSecurity   NVARCHAR(20),
    OnlineBackup     NVARCHAR(20),
    DeviceProtection NVARCHAR(20),
    TechSupport      NVARCHAR(20),
    StreamingTV      NVARCHAR(20),
    StreamingMovies  NVARCHAR(20)
);

INSERT INTO Dim_Servicios (customerID, PhoneService, MultipleLines, InternetService,
    OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies)
SELECT 
    customerID, PhoneService, MultipleLines, InternetService,
    OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies
FROM Telco_Customer_Churn;

SELECT COUNT(*) AS Total_Dim_Servicios FROM Dim_Servicios;


-- PASO 4: DIMENSION CHURN

CREATE TABLE Dim_Churn (
    ChurnID          INT IDENTITY(1,1) PRIMARY KEY,
    customerID       NVARCHAR(50),
    Churn            NVARCHAR(5),
    SegmentoRiesgo   NVARCHAR(10) NULL,
    ClasificacionABC NVARCHAR(5)  NULL
);

INSERT INTO Dim_Churn (customerID, Churn)
SELECT customerID, Churn
FROM Telco_Customer_Churn;

SELECT COUNT(*) AS Total_Dim_Churn FROM Dim_Churn;

-- FACT TABLE: Fact_Customers
CREATE TABLE Fact_Customers (
    FactID         INT IDENTITY(1,1) PRIMARY KEY,
    customerID     NVARCHAR(50),
    ClienteID      INT,
    ServicioID     INT,
    ContractID     INT,
    ChurnID        INT,
    tenure         INT,
    MonthlyCharges FLOAT,
    TotalCharges   FLOAT,

    CONSTRAINT FK_Cliente   FOREIGN KEY (ClienteID)  REFERENCES Dim_Cliente(ClienteID),
    CONSTRAINT FK_Servicio  FOREIGN KEY (ServicioID) REFERENCES Dim_Servicios(ServicioID),
    CONSTRAINT FK_Contrato  FOREIGN KEY (ContractID) REFERENCES Dim_Contrato(ContractID),
    CONSTRAINT FK_Churn     FOREIGN KEY (ChurnID)    REFERENCES Dim_Churn(ChurnID)
);

-- POBLAR Fact_Customers

INSERT INTO Fact_Customers (customerID, ClienteID, ServicioID, ContractID, ChurnID,
    tenure, MonthlyCharges, TotalCharges)
SELECT
    t.customerID,
    c.ClienteID,
    s.ServicioID,
    ct.ContractID,
    ch.ChurnID,
    CAST(t.tenure AS INT),
    CAST(t.MonthlyCharges AS FLOAT),
    CAST(NULLIF(REPLACE(t.TotalCharges, ' ', ''), '') AS FLOAT)
FROM Telco_Customer_Churn t
JOIN Dim_Cliente    c  ON t.customerID      = c.customerID
JOIN Dim_Servicios  s  ON t.customerID      = s.customerID
JOIN Dim_Contrato   ct ON t.Contract        = ct.Contract
                       AND t.PaperlessBilling = ct.PaperlessBilling
                       AND t.PaymentMethod    = ct.PaymentMethod
JOIN Dim_Churn      ch ON t.customerID      = ch.customerID;

-- VERIFICAR
SELECT COUNT(*) AS Total_Fact_Customers FROM Fact_Customers;

----An�lisis Exploratorio de Datos e Insights (EDA)
----------------------------------------------------------------------
---- CASO EMPRESA DE TELECOMUNICACIONES FUGA DE CLIENTES
-- BLOQUE A - PREGUNTA 1
-- Term�metro de Churn Global
----------------------------------------------------------------------

---Pregunta #1 � Term�metro de Churn Global:** �Cu�l es la tasa de deserci�n
---total de la compa��a y cu�nto revenue mensual se pierde por los clientes
---que abandonaron el servicio?
-- BLOQUE A - PREGUNTA 1
-- Term�metro de Churn Global + Desglose por Contrato
SELECT
    ct.Contract                                                 AS Tipo_Contrato,
    COUNT(*)                                                    AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END)           AS Total_Churn,
    SUM(CASE WHEN ch.Churn = 'No'  THEN 1 ELSE 0 END)           AS Total_Activos,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2
    )                                                              AS Tasa_Churn_Pct,
    ROUND(SUM(CASE WHEN ch.Churn = 'Yes' THEN f.MonthlyCharges ELSE 0 END), 2)
                                                                   AS Revenue_En_Riesgo,
    ROUND(AVG(f.MonthlyCharges), 2)                               AS Cargo_Promedio
FROM Fact_Customers f
JOIN Dim_Churn    ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
GROUP BY ct.Contract
ORDER BY Tasa_Churn_Pct DESC;

-- BLOQUE A - PREGUNTA 2
-- Radar de Segmentaci�n Contractual 
--�Cu�l es la tasa de churn y el cargo mensual promedio por tipo de contrato para identificar qu� modalidad representa el mayor riesgo de deserci�n?
SELECT
    ct.Contract    AS Tipo_Contrato,
    ct.PaymentMethod      AS Metodo_Pago,
    COUNT(*)              AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END)      AS Total_Desertores,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2
    )                                                      AS Tasa_Desercion_Pct,
    ROUND(AVG(f.MonthlyCharges), 2)                        AS Cargo_Mensual_Promedio,
    ROUND(AVG(CAST(f.tenure AS FLOAT)), 2)                 AS Antiguedad_Promedio_Meses
FROM Fact_Customers f
JOIN Dim_Churn    ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
GROUP BY ct.Contract, ct.PaymentMethod
ORDER BY Tasa_Desercion_Pct DESC;

-- BLOQUE A - PREGUNTA 3
-- Auditor�a de M�todos de Pago 
--- �Qu� m�todo de pago concentra la mayor proporci�n de clientes con churn y c�mo se distribuye el revenue perdido entre cada modalidad de cobro?
SELECT TOP 4
    ct.PaymentMethod        AS Metodo_Pago,
    COUNT(*)                AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Desertores,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2) AS Tasa_Desercion_Pct,
    ROUND(SUM(CASE WHEN ch.Churn = 'Yes' THEN f.MonthlyCharges ELSE 0 END), 2)
                            AS Revenue_Perdido
FROM Fact_Customers f
JOIN Dim_Churn    ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
GROUP BY ct.PaymentMethod
ORDER BY Revenue_Perdido DESC;

-- BLOQUE A - PREGUNTA 4
-- Ranking de Servicios Cr�ticos
--- �Qu� servicios adicionales (soporte t�cnico, seguridad en l�nea, streaming) 
--tienen menor adopci�n entre los clientes que abandonaron, revelando los gaps de valor que aceleran la deserci�n?
SELECT TOP 3
    'Seguridad en Linea'    AS Servicio,
    SUM(CASE WHEN ch.Churn = 'Yes' AND s.OnlineSecurity = 'No' THEN 1 ELSE 0 END)
                            AS Desertores_Sin_Servicio
FROM Fact_Customers f
JOIN Dim_Churn     ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Servicios s  ON f.ServicioID = s.ServicioID
UNION ALL
SELECT 'Soporte Tecnico',
    SUM(CASE WHEN ch.Churn = 'Yes' AND s.TechSupport = 'No' THEN 1 ELSE 0 END)
FROM Fact_Customers f
JOIN Dim_Churn     ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Servicios s  ON f.ServicioID = s.ServicioID
UNION ALL
SELECT 'Respaldo en Nube',
    SUM(CASE WHEN ch.Churn = 'Yes' AND s.OnlineBackup = 'No' THEN 1 ELSE 0 END)
FROM Fact_Customers f
JOIN Dim_Churn     ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Servicios s  ON f.ServicioID = s.ServicioID;

-- BLOQUE A - PREGUNTA 5
-- Perfil Demogr�fico del Desertor
---�Cu�l es la distribuci�n de churn seg�n g�nero, condici�n de Senior Citizen, 
--presencia de pareja y dependientes para construir el perfil demogr�fico del cliente en riesgo?
SELECT TOP 10
    c.Gender                AS Genero,
    c.SeniorCitizen         AS Cliente_Mayor,
    c.Partner               AS Tiene_Pareja,
    c.Dependents            AS Tiene_Dependientes,
    COUNT(*)                AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Desertores,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2)AS Tasa_Desercion_Pct
FROM Fact_Customers f
JOIN Dim_Cliente c  ON f.ClienteID = c.ClienteID
JOIN Dim_Churn  ch  ON f.ChurnID   = ch.ChurnID
GROUP BY c.Gender, c.SeniorCitizen, c.Partner, c.Dependents
ORDER BY Tasa_Desercion_Pct DESC;

-- BLOQUE B - PREGUNTA 6
-- Estacionalidad del Abandono por Antig�edad
---�Cu�l es la tasa de churn agrupada en cohortes de antig�edad (0�12, 13�24, 25�48, 49�72 meses) 
--y en qu� horizonte temporal se concentra la mayor p�rdida de clientes?
SELECT
    CASE
        WHEN f.tenure BETWEEN 0  AND 12 THEN '0-12 meses'
        WHEN f.tenure BETWEEN 13 AND 24 THEN '13-24 meses'
        WHEN f.tenure BETWEEN 25 AND 48 THEN '25-48 meses'
        WHEN f.tenure BETWEEN 49 AND 72 THEN '49-72 meses'
    END                     AS Cohorte_Antiguedad,
    COUNT(*)                AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Desertores,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2) AS Tasa_Desercion_Pct,
    ROUND(AVG(f.MonthlyCharges), 2) AS Cargo_Mensual_Promedio
FROM Fact_Customers f
JOIN Dim_Churn ch ON f.ChurnID = ch.ChurnID
GROUP BY
    CASE
        WHEN f.tenure BETWEEN 0  AND 12 THEN '0-12 meses'
        WHEN f.tenure BETWEEN 13 AND 24 THEN '13-24 meses'
        WHEN f.tenure BETWEEN 25 AND 48 THEN '25-48 meses'
        WHEN f.tenure BETWEEN 49 AND 72 THEN '49-72 meses'
    END
ORDER BY Tasa_Desercion_Pct DESC;

-- BLOQUE B - PREGUNTA 7
-- Elasticidad del Cargo Mensual
----  �C�mo impactan los rangos de cargo mensual (bajo, medio, alto) 
--en la probabilidad de churn y qu� umbral de precio representa el punto de quiebre en la fidelizaci�n del cliente?
SELECT
    CASE
        WHEN f.MonthlyCharges <= 35  THEN 'Bajo (0-35)'
        WHEN f.MonthlyCharges <= 65  THEN 'Medio (36-65)'
        ELSE                              'Alto (66+)'
    END                      AS Rango_Cargo,
    COUNT(*)                 AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Desertores,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2) AS Tasa_Desercion_Pct,
    ROUND(AVG(f.MonthlyCharges), 2) AS Cargo_Promedio
FROM Fact_Customers f
JOIN Dim_Churn ch ON f.ChurnID = ch.ChurnID
GROUP BY
    CASE
        WHEN f.MonthlyCharges <= 35 THEN 'Bajo (0-35)'
        WHEN f.MonthlyCharges <= 65 THEN 'Medio (36-65)'
        ELSE                             'Alto (66+)'
    END
ORDER BY Tasa_Desercion_Pct DESC;

-- BLOQUE B - PREGUNTA 8
-- Clasificaci�n ABC por CLV
--- �Qu� clientes pertenecen a la clase A al representar el mayor Customer Lifetime Value acumulado (TotalCharges) 
--y cu�l es su tasa de churn frente a los segmentos B y C?
WITH ClasificacionABC AS (
    SELECT
        f.customerID,
        f.TotalCharges,
        ch.Churn,
        NTILE(3) OVER (ORDER BY f.TotalCharges DESC) AS Clase
    FROM Fact_Customers f
    JOIN Dim_Churn ch ON f.ChurnID = ch.ChurnID
    WHERE f.TotalCharges IS NOT NULL
)
SELECT
    CASE Clase
        WHEN 1 THEN 'A - Alto Valor'
        WHEN 2 THEN 'B - Valor Medio'
        WHEN 3 THEN 'C - Bajo Valor'
    END                  AS Clasificacion_ABC,
    COUNT(*)             AS Total_Clientes,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Desertores,
    ROUND(
        CAST(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2) AS Tasa_Desercion_Pct,
    ROUND(AVG(TotalCharges), 2) AS CLV_Promedio
FROM ClasificacionABC
GROUP BY Clase
ORDER BY Clase;

-- BLOQUE B - PREGUNTA 9
-- Oportunidades de Retenci�n por Paquete de Servicios
--- �Cu�l es el promedio de servicios contratados por cliente seg�n su condici�n de churn 
---para identificar el nivel m�nimo de adopci�n que act�a como barrera de salida?
SELECT TOP 5
    s.InternetService           AS Servicio_Internet,
    ch.Churn                    AS Estado_Cliente,
    COUNT(*)                    AS Total_Clientes,
    ROUND(AVG(f.MonthlyCharges), 2) AS Cargo_Promedio
FROM Fact_Customers f
JOIN Dim_Churn     ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Servicios s  ON f.ServicioID = s.ServicioID
GROUP BY s.InternetService, ch.Churn
ORDER BY Total_Clientes DESC;

-- BLOQUE B - PREGUNTA 10
-- Evoluci�n del Revenue en Riesgo por Cohorte
---�Cu�l es el cargo mensual total en riesgo por cada grupo de antig�edad y en qu� segmento se concentra la mayor p�rdida econ�mica proyectada?
WITH RevenuePorCohorte AS (
    SELECT
        CASE
            WHEN f.tenure BETWEEN 0  AND 12 THEN '0-12 meses'
            WHEN f.tenure BETWEEN 13 AND 24 THEN '13-24 meses'
            WHEN f.tenure BETWEEN 25 AND 48 THEN '25-48 meses'
            WHEN f.tenure BETWEEN 49 AND 72 THEN '49-72 meses'
        END                  AS Grupo_Antiguedad,
        f.MonthlyCharges,
        ch.Churn
    FROM Fact_Customers f
    JOIN Dim_Churn ch ON f.ChurnID = ch.ChurnID
)
SELECT
    Grupo_Antiguedad,
    COUNT(*)                 AS Total_Clientes,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS Total_Desertores,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END), 2)
                             AS Revenue_En_Riesgo,
    ROUND(AVG(CASE WHEN Churn = 'Yes' THEN MonthlyCharges END), 2)
                             AS Cargo_Promedio_Desertor
FROM RevenuePorCohorte
GROUP BY Grupo_Antiguedad
ORDER BY Revenue_En_Riesgo DESC;

-- BLOQUE C - PREGUNTA 11
-- Monitor de Valor Acumulado (Running Total)
---�Cu�l es la evoluci�n acumulada del TotalCharges por segmento de contrato y en qu� punto cada
--grupo alcanza el primer hito cr�tico de valor generado para la compa��a?
WITH TotalPorContrato AS (
    SELECT
        ct.Contract             AS Tipo_Contrato,
        f.customerID,
        f.TotalCharges,
        SUM(f.TotalCharges) OVER (
            PARTITION BY ct.Contract
            ORDER BY f.TotalCharges DESC
        )                       AS Acumulado_Revenue
    FROM Fact_Customers f
    JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
    WHERE f.TotalCharges IS NOT NULL
)
SELECT TOP 10
    Tipo_Contrato,
    ROUND(MAX(Acumulado_Revenue), 2) AS Revenue_Total_Acumulado,
    COUNT(customerID)                AS Total_Clientes,
    ROUND(MIN(TotalCharges), 2)      AS CLV_Minimo,
    ROUND(MAX(TotalCharges), 2)      AS CLV_Maximo
FROM TotalPorContrato
GROUP BY Tipo_Contrato
ORDER BY Revenue_Total_Acumulado DESC;

-- BLOQUE C - PREGUNTA 12
-- Scoring de Riesgo de Churn
---- �C�mo se clasifican todos los clientes activos en segmentos de riesgo Alto, Medio y Bajo utilizando 
--un score compuesto de variables contractuales, de servicio y de valor, para priorizar las acciones de retenci�n?
WITH ScoreClientes AS (
    SELECT
        f.customerID,
        ct.Contract,
        f.MonthlyCharges,
        f.tenure,
        CASE WHEN ct.Contract      = 'Month-to-month' THEN 3
             WHEN ct.Contract      = 'One year'        THEN 2
             ELSE                                           1
        END +
        CASE WHEN f.MonthlyCharges >= 66 THEN 3
             WHEN f.MonthlyCharges >= 36 THEN 2
             ELSE                             1
        END +
        CASE WHEN f.tenure <= 12 THEN 3
             WHEN f.tenure <= 24 THEN 2
             ELSE                     1
        END                         AS Score_Riesgo
    FROM Fact_Customers f
    JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
    JOIN Dim_Churn    ch ON f.ChurnID    = ch.ChurnID
    WHERE ch.Churn = 'No'
)
SELECT
    CASE WHEN Score_Riesgo >= 7 THEN 'Alto Riesgo'
         WHEN Score_Riesgo >= 5 THEN 'Riesgo Medio'
         ELSE                        'Bajo Riesgo'
    END                         AS Segmento_Riesgo,
    COUNT(*)                    AS Total_Clientes,
    ROUND(AVG(MonthlyCharges), 2) AS Cargo_Promedio,
    ROUND(AVG(CAST(tenure AS FLOAT)), 2) AS Antiguedad_Promedio
FROM ScoreClientes
GROUP BY
    CASE WHEN Score_Riesgo >= 7 THEN 'Alto Riesgo'
         WHEN Score_Riesgo >= 5 THEN 'Riesgo Medio'
         ELSE                        'Bajo Riesgo'
    END
ORDER BY Total_Clientes DESC;

-- BLOQUE C - PREGUNTA 13
-- Benchmarking de Clientes en Riesgo
----�Cu�les son los clientes activos cuyo perfil de antig�edad, cargo mensual y servicios contratados es 
--m�s similar al perfil promedio hist�rico de los clientes que ya realizaron churn?
WITH PerfilChurn AS (
    SELECT
        AVG(f.MonthlyCharges)        AS Promedio_Cargo,
        AVG(CAST(f.tenure AS FLOAT)) AS Promedio_Antiguedad
    FROM Fact_Customers f
    JOIN Dim_Churn ch ON f.ChurnID = ch.ChurnID
    WHERE ch.Churn = 'Yes'
)
SELECT TOP 10
    f.customerID                    AS ID_Cliente,
    f.MonthlyCharges                AS Cargo_Mensual,
    f.tenure                        AS Antiguedad_Meses,
    ROUND(ABS(f.MonthlyCharges - p.Promedio_Cargo), 2)        AS Diferencia_Cargo,
    ROUND(ABS(f.tenure         - p.Promedio_Antiguedad), 2)   AS Diferencia_Antiguedad,
    ROUND(ABS(f.MonthlyCharges - p.Promedio_Cargo) +
          ABS(f.tenure         - p.Promedio_Antiguedad), 2)   AS Score_Similitud
FROM Fact_Customers f
JOIN Dim_Churn ch ON f.ChurnID = ch.ChurnID
CROSS JOIN PerfilChurn p
WHERE ch.Churn = 'No'
ORDER BY Score_Similitud ASC;

-- BLOQUE C - PREGUNTA 14
-- Auditor�a de Brecha de Retenci�n por Segmento
--- �Cu�l es la diferencia en tasa de churn de cada segmento de contrato respecto al est�ndar global 
---de la compa��a, y qu� m�todos de pago amplifican m�s esa brecha de deserci�n?
WITH TasaGlobal AS (
    SELECT
        ROUND(
            CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
            / COUNT(*) * 100, 2) AS Tasa_Global
    FROM Fact_Customers f
    JOIN Dim_Churn ch ON f.ChurnID = ch.ChurnID
)
SELECT
    ct.Contract                 AS Tipo_Contrato,
    ct.PaymentMethod            AS Metodo_Pago,
    COUNT(*)                    AS Total_Clientes,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2)    AS Tasa_Segmento,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2) - tg.Tasa_Global AS Brecha_vs_Global
FROM Fact_Customers f
JOIN Dim_Churn    ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
CROSS JOIN TasaGlobal tg
GROUP BY ct.Contract, ct.PaymentMethod, tg.Tasa_Global
ORDER BY Brecha_vs_Global DESC;

-- BLOQUE C - PREGUNTA 15
-- Proyecci�n de Carga de Retenci�n (Workload)
---�Cu�ntos clientes activos de alto riesgo proyecta cada segmento contractual para el pr�ximo 
--horizonte de an�lisis, utilizando el perfil hist�rico de churn para anticipar la presi�n sobre el equipo de Customer Success?
WITH TasaHistorica AS (
    SELECT
        ct.Contract                  AS Tipo_Contrato,
        ROUND(
            CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
            / COUNT(*) * 100, 2)     AS Tasa_Historica_Churn
    FROM Fact_Customers f
    JOIN Dim_Churn    ch ON f.ChurnID    = ch.ChurnID
    JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
    GROUP BY ct.Contract
),
ClientesActivos AS (
    SELECT
        ct.Contract                  AS Tipo_Contrato,
        COUNT(*)                     AS Total_Activos,
        ROUND(AVG(f.MonthlyCharges), 2) AS Cargo_Promedio
    FROM Fact_Customers f
    JOIN Dim_Churn    ch ON f.ChurnID    = ch.ChurnID
    JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
    WHERE ch.Churn = 'No'
    GROUP BY ct.Contract
)
SELECT
    ca.Tipo_Contrato,
    ca.Total_Activos,
    th.Tasa_Historica_Churn,
    ca.Cargo_Promedio,
    ROUND(ca.Total_Activos * th.Tasa_Historica_Churn / 100, 0)
                                     AS Clientes_En_Riesgo_Proyectado,
    ROUND(ca.Total_Activos * th.Tasa_Historica_Churn / 100
          * ca.Cargo_Promedio, 2)    AS Revenue_Proyectado_En_Riesgo
FROM ClientesActivos ca
JOIN TasaHistorica   th ON ca.Tipo_Contrato = th.Tipo_Contrato
ORDER BY Clientes_En_Riesgo_Proyectado DESC;