![Banner](./Picture/Barner.png)
# PROYECTO_FINAL_CUSTOMER_CHURN_SQL

## Resumen (Overview)
_Una empresa de telecomunicaciones busca reducir su tasa de abandono de clientes (churn) y mejorar la rentabilidad de su cartera, donde la compañía enfrenta retos críticos en la identificación temprana de clientes en riesgo de fuga, la segmentación ineficiente de su base de usuarios y la falta de visibilidad sobre los patrones de comportamiento que anteceden la cancelación del servicio.
Mi objetivo dentro de SQL Server Management Studio (SSMS) es normalizar y transformar datos transaccionales brutos de clientes en KPIs estratégicos de retención a través de técnicas avanzadas como CTEs, Window Functions y subconsultas correlacionadas._

## Estructura del Proyecto
- [Sobre los Datos](#sobre-los-datos)
- [Habilidades SQL Aplicadas](#habilidades-sql-aplicadas)
- [Tareas](#tareas)
- [Preparación de Datos y Modelado](#preparación-de-datos-y-modelado)
- [Análisis Exploratorio de Datos e Insights (EDA)](#análisis-exploratorio-de-datos-e-insights-eda)
- [Conclusiones Generales](#conclusiones-generales)

---

## Sobre los Datos

El conjunto de datos captura información detallada sobre el comportamiento y perfil de los clientes de una empresa de telecomunicaciones, incluyendo:

- **Perfil del cliente:** Género, edad (Senior Citizen), estado civil (Partner) y dependientes (Dependents).
- **Servicios contratados:** Telefonía, múltiples líneas, internet (DSL / Fibra óptica), seguridad en línea, respaldo en la nube, protección de dispositivos y soporte técnico.
- **Condiciones contractuales:** Tipo de contrato (mensual, anual, bienal), facturación electrónica y método de pago.
- **Métricas de valor:** Antigüedad del cliente en meses (`tenure`), cargo mensual (`MonthlyCharges`) y cargo total acumulado (`TotalCharges`).
- **Variable objetivo:** Indicador binario de churn (`Churn`: Yes / No).

Para mayor información sobre la fuente de datos original puedes encontrarla en este [Link](https://www.kaggle.com/datasets/itszubi/customer-churn-dataset).

El modelo cuenta con una tabla de hechos principal (`Fact_Customers`) y múltiples dimensiones para un análisis granular del comportamiento de deserción.
![Esquema Estrella](./Picture/StarSchema.png)

---
## Habilidades SQL Aplicadas

| Categoría | Técnica |
|---|---|
| Modelado | Normalización en esquema estrella, creación de tablas de hechos y dimensiones |
| Transformación | `CAST`, `CASE WHEN`, `ISNULL`, limpieza de nulos en `TotalCharges` |
| Agregación | `GROUP BY`, `HAVING`, `COUNT`, `AVG`, `SUM`, `ROUND` |
| Avanzado | CTEs (`WITH`), Window Functions (`ROW_NUMBER`, `RANK`, `NTILE`, `LAG`) |
| Segmentación | Clasificación ABC de clientes por valor y riesgo, scoring de churn |
| Análisis temporal | Cohortes por `tenure`, horizontes de retención por antigüedad |
| Subqueries | Subconsultas correlacionadas para métricas de comparación |
| Vistas | `CREATE VIEW` para KPIs reutilizables por el equipo de BI |

---
## Tareas (Tasks)

En este análisis, complemento al departamento de Customer Success a responder
lo siguiente, dividido en tres bloques:

### BLOQUE A: Fundamentos de Retención y KPIs de Deserción

1. **Termómetro de Churn Global:** ¿Cuál es la tasa de deserción total de la compañía
y cuánto revenue mensual se pierde por los clientes que abandonaron el servicio?

2. **Radar de Segmentación Contractual:** ¿Cuál es la tasa de churn y el cargo mensual
promedio por tipo de contrato para identificar qué modalidad representa el mayor riesgo
de deserción?

3. **Auditoría de Métodos de Pago:** ¿Qué método de pago concentra la mayor proporción
de clientes con churn y cómo se distribuye el revenue perdido entre cada modalidad
de cobro?

4. **Ranking de Servicios Críticos:** ¿Qué servicios adicionales (soporte técnico,
seguridad en línea, streaming) tienen menor adopción entre los clientes que abandonaron,
revelando los gaps de valor que aceleran la deserción?

5. **Perfil Demográfico del Desertor:** ¿Cuál es la distribución de churn según género,
condición de Senior Citizen, presencia de pareja y dependientes para construir el perfil
demográfico del cliente en riesgo?

### BLOQUE B: Inteligencia de Negocio y Segmentación de Valor

6. **Estacionalidad del Abandono por Antigüedad:** ¿Cuál es la tasa de churn agrupada
en cohortes de antigüedad (0–12, 13–24, 25–48, 49–72 meses) y en qué horizonte temporal
se concentra la mayor pérdida de clientes?

7. **Elasticidad del Cargo Mensual:** ¿Cómo impactan los rangos de cargo mensual
(bajo, medio, alto) en la probabilidad de churn y qué umbral de precio representa
el punto de quiebre en la fidelización del cliente?

8. **Clasificación ABC de Clientes por CLV:** ¿Qué clientes pertenecen a la clase A
al representar el mayor Customer Lifetime Value acumulado (`TotalCharges`) y cuál
es su tasa de churn frente a los segmentos B y C?

9. **Oportunidades de Retención por Paquete de Servicios:** ¿Cuál es el promedio de
servicios contratados por cliente según su condición de churn para identificar el nivel
mínimo de adopción que actúa como barrera de salida?

10. **Evolución del Revenue en Riesgo por Cohorte:** ¿Cuál es el cargo mensual total
en riesgo por cada cohorte de antigüedad y en qué segmento se concentra la mayor
pérdida económica proyectada?

### BLOQUE C: Inteligencia Predictiva y Scoring de Retención

11. **Monitor de Valor Acumulado (Running Total):** ¿Cuál es la evolución acumulada
del `TotalCharges` por segmento de contrato y en qué punto cada grupo alcanza
el primer hito crítico de valor generado para la compañía?

12. **Scoring de Riesgo de Churn:** ¿Cómo se clasifican todos los clientes activos
en segmentos de riesgo Alto, Medio y Bajo utilizando un score compuesto de variables
contractuales, de servicio y de valor, para priorizar las acciones de retención?

13. **Benchmarking de Clientes en Riesgo:** ¿Cuáles son los clientes activos cuyo
perfil de antigüedad, cargo mensual y servicios contratados es más similar al
perfil promedio histórico de los clientes que ya realizaron churn?

14. **Auditoría de Brecha de Retención por Segmento:** ¿Cuál es la diferencia en
tasa de churn de cada segmento de contrato respecto al estándar global de la compañía,
y qué métodos de pago amplifican más esa brecha de deserción?

15. **Proyección de Carga de Retención (Workload):** ¿Cuántos clientes activos de
alto riesgo proyecta cada segmento contractual para el próximo horizonte de análisis,
utilizando el perfil histórico de churn para anticipar la presión sobre el equipo
de Customer Success?

## Preparación de Datos y Modelado

El dataset original se entrega como una tabla plana de **7,043 registros y 21 columnas**.
El proceso de modelado lo descompone en un **esquema estrella (Star Schema)** dentro de
SQL Server Management Studio (SSMS), separando atributos descriptivos en dimensiones
y concentrando las métricas cuantitativas en la tabla de hechos central.

---
### 1. Importe y Carga de Datos

Debido a las restricciones de importación en **SQL Server (SSMS)**, se optó
por `BULK INSERT` como estrategia de carga, configurando inicialmente todas
las columnas como `NVARCHAR` para evitar pérdida de datos en la importación.

- Se creó la tabla staging `Telco_Customer_Churn` con todas las columnas en texto plano.
- **Cambio de Tipos:** Mediante scripts SQL se transformaron las columnas numéricas
a sus formatos correctos (`FLOAT`, `INT`), garantizando el manejo de datos posterior.

```sql
-- Fragmento del proceso de carga
BULK INSERT Telco_Customer_Churn
FROM 'C:\...\WA_Fn-UseC_-Telco-Customer-Churn.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n');
```


### 2. Normalización de Datos (Star Schema)

Para optimizar las consultas, se realizó una **Normalización**, separando
la tabla plana en un **Esquema Estrella (Star Schema)**:

- **Tabla de Hechos:** `Fact_Customers`
- **Tablas de Dimensiones:** `Dim_Cliente`, `Dim_Contrato`, `Dim_Servicios` y `Dim_Churn`

```sql
-- Fragmento del proceso de normalización (se aplicó la misma lógica para cada tabla)
CREATE TABLE Dim_Cliente (
    ClienteID     INT IDENTITY(1,1) PRIMARY KEY,
    customerID    NVARCHAR(50),
    Gender        NVARCHAR(10),
    SeniorCitizen NVARCHAR(5),
    Partner       NVARCHAR(5),
    Dependents    NVARCHAR(5)
);

-- Insertar los datos únicos
INSERT INTO Dim_Cliente (customerID, Gender, SeniorCitizen, Partner, Dependents)
SELECT DISTINCT customerID, gender, SeniorCitizen, Partner, Dependents
FROM Telco_Customer_Churn;
```
### 3. Limpieza y Verificación de Datos

A pesar de la calidad general del dataset, se ejecutaron scripts para
asegurar el análisis óptimo:

- **Verificación:** Se identificaron **11 registros** con `TotalCharges` vacío,
correspondientes a clientes nuevos con `tenure = 0`.
- **Conversión de Tipos:** Las columnas `MonthlyCharges` y `TotalCharges`
se convirtieron de `NVARCHAR` a `FLOAT`, y `tenure` de `NVARCHAR` a `INT`.
- **Eliminación de Redundancias:** Los valores vacíos en `TotalCharges`
se trataron con `NULLIF` y `REPLACE` para evitar errores en cálculos.

```sql
-- Verificación de registros vacíos
SELECT COUNT(*) AS TotalCharges_Vacios
FROM Telco_Customer_Churn
WHERE TotalCharges = ' ' OR TotalCharges IS NULL;

-- Conversión de tipos aplicada en Fact_Customers
CAST(t.tenure AS INT)                                     AS tenure,
CAST(t.MonthlyCharges AS FLOAT)                           AS MonthlyCharges,
CAST(NULLIF(REPLACE(t.TotalCharges,' ',''),'') AS FLOAT)  AS TotalCharges
```
## Análisis Exploratorio de Datos e Insights (EDA)

En este apartado, se plantearon 15 casuísticas agrupadas por bloques,
planteando una solución e interpretación para cada caso.

---
### BLOQUE A: Fundamentos de Retención y KPIs de Deserción

**Pregunta #1 — Termómetro de Churn Global:** ¿Cuál es la tasa de deserción
total de la compañía y cuánto revenue mensual se pierde por los clientes
que abandonaron el servicio?

Para determinar el estado general de deserción utilicé funciones de agregación
como `SUM`, `COUNT` y `AVG` combinadas con `CASE WHEN` para separar clientes
activos de desertores por tipo de contrato, calculando el revenue en riesgo
mediante `Fact_Customers` unida a `Dim_Churn` y `Dim_Contrato` con `INNER JOIN`.

```sql
SELECT
    ct.Contract                                                    AS Tipo_Contrato,
    COUNT(*)                                                       AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END)            AS Total_Churn,
    SUM(CASE WHEN ch.Churn = 'No'  THEN 1 ELSE 0 END)            AS Total_Activos,
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
```

![P1 Termómetro Churn Global](./Picture/P1_Churn_Global.png)

**Resultado Obtenido:**

Los resultados revelan una brecha crítica entre modalidades contractuales.
Los clientes **Mes a Mes** presentan la tasa de churn más alarmante con
un **42.71%**, concentrando **$120,847.10** del revenue mensual en riesgo 
el **86.9% del total perdido**  con 1,655 desertores sobre 3,875 clientes.
En contraste, los contratos **Dos años** muestran una tasa mínima de apenas
**2.83%** con solo $4,165.30 en riesgo, confirmando que el compromiso
contractual a largo plazo es el principal escudo contra la deserción.
La compañía debe priorizar la migración de clientes mensuales hacia
contratos anuales o bianuales como estrategia central de retención.

**Pregunta #2 — Radar de Segmentación Contractual:** ¿Cuál es la tasa de churn
y el cargo mensual promedio por tipo de contrato para identificar qué modalidad
representa el mayor riesgo de deserción?

Para identificar qué combinación de contrato y método de pago concentra mayor
deserción, utilicé `GROUP BY` múltiple sobre `Dim_Contrato` combinado con
`CASE WHEN` para calcular la tasa de deserción y `AVG` para obtener el cargo
mensual promedio y la antigüedad media por segmento, uniendo `Fact_Customers`
con `Dim_Churn` y `Dim_Contrato` mediante `INNER JOIN`.

```sql
SELECT
    ct.Contract                                                         AS Tipo_Contrato,
    ct.PaymentMethod                                                    AS Metodo_Pago,
    COUNT(*)                                                            AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END)                 AS Total_Desertores,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2
    )                                                                   AS Tasa_Desercion_Pct,
    ROUND(AVG(f.MonthlyCharges), 2)                                    AS Cargo_Mensual_Promedio,
    ROUND(AVG(CAST(f.tenure AS FLOAT)), 2)                             AS Antiguedad_Promedio_Meses
FROM Fact_Customers f
JOIN Dim_Churn    ch ON f.ChurnID    = ch.ChurnID
JOIN Dim_Contrato ct ON f.ContractID = ct.ContractID
GROUP BY ct.Contract, ct.PaymentMethod
ORDER BY Tasa_Desercion_Pct DESC;
```

![P2 Radar Segmentación Contractual](./Picture/P2_Radar_Contractual.png)

**Resultado Obtenido:**

El análisis revela que la combinación más crítica es **Mes a Mes con Cheque
Electrónico**, alcanzando una tasa de deserción del **53.73%** — más de la
mitad de sus 1,850 clientes abandonó el servicio — con un cargo mensual
promedio de $74.99 y apenas 17.97 meses de antigüedad promedio, la más baja
de todos los segmentos. En contraste, los clientes con contrato **Dos Años
con Tarjeta de Crédito** presentan la tasa más baja con apenas **2.24%**
y una antigüedad promedio de 59.81 meses, casi el triple. Esto confirma que
la combinación de contrato mensual y método de pago manual es la señal de
alerta más temprana de deserción, mientras que los métodos automáticos
combinados con contratos largos generan mayor fidelización y estabilidad
en la base de clientes.

**Pregunta #3 — Auditoría de Métodos de Pago:** ¿Qué método de pago concentra
la mayor proporción de clientes con churn y cómo se distribuye el revenue
perdido entre cada modalidad de cobro?

Para identificar qué método de pago concentra mayor deserción y pérdida
económica, utilicé `GROUP BY` sobre `Dim_Contrato`, combinando `CASE WHEN`
para separar desertores de activos y una **Window Function** `SUM() OVER()`
para calcular la participación porcentual de cada método sobre el revenue
total perdido.

```sql
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
```

![P3 Auditoría Métodos de Pago](./Picture/P3_Auditoria_Metodos_Pago.png)

**Resultado Obtenido:**

El **Cheque Electrónico** se posiciona como el método de pago más crítico,
concentrando el **60.58% del revenue mensual perdido** con $84,288.75 en
riesgo y una tasa de deserción del 45.29% — la más alta de los cuatro
métodos. Sus 1,071 desertores sobre 2,365 clientes revelan que casi 1 de
cada 2 usuarios con este método abandona el servicio. En contraste, los
métodos automáticos (**Transferencia Bancaria** y **Tarjeta de Crédito**)
presentan tasas significativamente menores de 16.71% y 15.24%
respectivamente, confirmando que la automatización del cobro actúa como
factor de retención al reducir la fricción en el proceso de pago. El equipo
comercial debería incentivar la migración hacia métodos automáticos como
palanca de fidelización inmediata.

**Pregunta #4 — Ranking de Servicios Críticos:** ¿Qué servicios adicionales
(soporte técnico, seguridad en línea, respaldo en nube) tienen menor adopción
entre los clientes que abandonaron, revelando los gaps de valor que aceleran
la deserción?

Para identificar los servicios con menor adopción entre desertores, utilicé
`UNION ALL` para consolidar múltiples servicios en una sola tabla de resultados,
combinando `CASE WHEN` para filtrar desertores sin cada servicio contratado,
uniendo `Fact_Customers` con `Dim_Churn` y `Dim_Servicios` mediante `INNER JOIN`.

```sql
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
```

![P4 Ranking Servicios Críticos](./Picture/P4_Ranking_Servicios.png)

**Resultado Obtenido:**

Los resultados evidencian que la **Seguridad en Línea** es el servicio con
mayor ausencia entre desertores, con el **78.17%** de los clientes que
abandonaron sin tenerlo contratado, seguido de **Soporte Técnico** con
77.37% y **Respaldo en Nube** con 65.97%. Esto confirma que los clientes
que no tienen servicios de valor agregado contratados tienen significativamente
mayor probabilidad de abandonar, al no percibir suficiente valor en su
suscripción. La compañía debería implementar estrategias de adopción de
estos servicios como barrera de salida, ofreciendo periodos de prueba
gratuitos a clientes en riesgo para incrementar su nivel de compromiso
con la plataforma.

**Pregunta #5 — Perfil Demográfico del Desertor:** ¿Cuál es la distribución
de churn según género, condición de Senior Citizen, presencia de pareja y
dependientes para construir el perfil demográfico del cliente en riesgo?

Para construir el perfil demográfico del desertor utilicé `GROUP BY` múltiple
sobre `Dim_Cliente` combinando `CASE WHEN` para calcular la tasa de deserción
por cada combinación de atributos demográficos, con `TOP 10` para mostrar
los segmentos más críticos ordenados por mayor tasa de deserción.

```sql
SELECT TOP 10
    c.Gender                AS Genero,
    c.SeniorCitizen         AS Cliente_Mayor,
    c.Partner               AS Tiene_Pareja,
    c.Dependents            AS Tiene_Dependientes,
    COUNT(*)                AS Total_Clientes,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Desertores,
    ROUND(
        CAST(SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2) AS Tasa_Desercion_Pct
FROM Fact_Customers f
JOIN Dim_Cliente c  ON f.ClienteID = c.ClienteID
JOIN Dim_Churn  ch  ON f.ChurnID   = ch.ChurnID
GROUP BY c.Gender, c.SeniorCitizen, c.Partner, c.Dependents
ORDER BY Tasa_Desercion_Pct DESC;
```

![P5 Perfil Demográfico del Desertor](./Picture/P5_Perfil_Demografico.png)

**Resultado Obtenido:**

El perfil más crítico de deserción corresponde a **mujeres mayores (Senior)
sin pareja y sin dependientes**, con una tasa del **49.84%** sobre 317
clientes. En general, los clientes clasificados como **Senior Citizen**
(valor 1) dominan los primeros 5 puestos del ranking con tasas entre
33% y 49%, muy por encima del promedio global de 26.54%. Los clientes
sin pareja y sin dependientes presentan consistentemente mayor deserción,
sugiriendo que la ausencia de vínculos familiares reduce el compromiso
con el servicio. La compañía debería diseñar campañas de retención
específicas para clientes mayores sin núcleo familiar, al ser el segmento
demográfico de mayor riesgo.



