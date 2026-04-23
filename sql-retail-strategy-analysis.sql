/*
==========================================================================
ANÁLISIS ESTRATÉGICO 360°: CLIENTES, PRODUCTOS Y RENTABILIDAD
==========================================================================
Analista: Paula
Dataset: Online Retail II
Objetivo: Generar insights para Marketing, Ventas y Finanzas.
*/

USE online_retail_ii;

-- 1. SALUD GLOBAL POR SEGMENTOS
-- Objetivo: Foto general del volumen de clientes y valor monetario por grupo.
SELECT
    Segment, 
    COUNT(*) AS Total_Clientes,  
    ROUND(AVG(Monetary), 2) AS Gasto_Promedio, 
    ROUND(SUM(Monetary), 2) AS Ingresos_Totales
FROM fact_rfm_segments
GROUP BY Segment
ORDER BY Ingresos_Totales DESC; 

-- 2. PARETO DE SEGMENTOS (DISTRIBUCIÓN DE PESO)
-- Objetivo: Identificar qué segmentos concentran el porcentaje mayor de ventas.
SELECT
    Segment, 
    COUNT(*) AS Num_Clientes, 
    ROUND(SUM(Monetary), 2) AS Ingresos_Totales, 
    ROUND(AVG(Monetary), 2) AS Ticket_Promedio_Cliente, 
    ROUND((SUM(Monetary) / (SELECT SUM(Monetary) FROM fact_rfm_segments) * 100), 2) AS Pct_Ventas
FROM fact_rfm_segments
GROUP BY Segment
ORDER BY Ingresos_Totales DESC; 

-- 3. FOCO EN RIESGO: TOP 10 CLIENTES A PUNTO DE PERDER
-- Objetivo: Listado accionable para campañas de re-activación urgente.
SELECT
    CustomerID, 
    Recency, 
    Monetary, 
    Segment
FROM fact_rfm_segments
WHERE Segment IN ('At Risk', 'Cant Loose Them', 'Hibernating')
ORDER BY Monetary DESC
LIMIT 10; 

-- 4. VALIDACIÓN DE PRODUCTOS ESTRELLA (SEGMENTO CHAMPIONS)
-- Objetivo: Conocer los productos preferidos de los clientes más leales.
SELECT 
    s.Segment, 
    v.Description, 
    SUM(v.Quantity) AS Total_Vendido
FROM fact_sales_clean v
JOIN fact_rfm_segments s ON v.CustomerID = s.CustomerID
WHERE s.Segment = 'Champions'
GROUP BY s.Segment, v.Description
ORDER BY Total_Vendido DESC
LIMIT 5;

-- 5. RENTABILIDAD: "DROGAS DE DESCUENTO"
-- Objetivo: Detectar clientes con alta actividad pero bajo margen (cazaofertas).
SELECT 
    CustomerID, 
    Frequency, 
    Monetary,
    ROUND((Monetary / Frequency), 2) AS Ticket_Medio
FROM fact_rfm_segments
WHERE Frequency > 5 
  AND (Monetary / Frequency) < (SELECT AVG(Monetary / Frequency) FROM fact_rfm_segments)
ORDER BY Frequency DESC
LIMIT 10;

-- 6. PARETO INDIVIDUAL (CONCENTRACIÓN REAL DE CAJA)
-- Objetivo: ¿Cuántos clientes representan el 80% de los ingresos totales?
WITH VentasAcumuladas AS (
    SELECT 
        CustomerID,
        Monetary,
        SUM(Monetary) OVER (ORDER BY Monetary DESC) AS Acumulado,
        SUM(Monetary) OVER () AS Total_Global
    FROM fact_rfm_segments
)
SELECT 
    COUNT(*) AS Num_Clientes_VIP_Pareto,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_rfm_segments), 2) AS Pct_Sobre_Base_Total
FROM VentasAcumuladas
WHERE Acumulado <= (Total_Global * 0.80);

-- 7. ANÁLISIS SENIOR: STICKY PRICE (ELASTICIDAD PRECIO)
-- Objetivo: Identificar clientes que bajaron volumen tras un incremento de precio.
WITH PriceComparison AS (
    SELECT 
        CustomerID,
        AVG(Price) AS Precio_Medio,
        SUM(Quantity) AS Volumen_Total,
        YEAR(InvoiceDate) AS Anio
    FROM fact_sales_clean
    GROUP BY CustomerID, YEAR(InvoiceDate)
)
SELECT 
    prev.CustomerID,
    prev.Precio_Medio AS Precio_Anterior,
    curr.Precio_Medio AS Precio_Actual,
    prev.Volumen_Total AS Vol_Anterior,
    curr.Volumen_Total AS Vol_Actual,
    ROUND(((curr.Precio_Medio - prev.Precio_Medio) / prev.Precio_Medio) * 100, 2) AS Incremento_Precio_Pct
FROM PriceComparison prev
JOIN PriceComparison curr ON prev.CustomerID = curr.CustomerID AND prev.Anio = curr.Anio - 1
WHERE curr.Volumen_Total < prev.Volumen_Total 
  AND curr.Precio_Medio > prev.Precio_Medio;

-- 8. ANÁLISIS DE COHORTES (RETENCIÓN MENSUAL)
-- Objetivo: Tasa de fidelidad por mes de adquisición.
WITH FirstPurchase AS (
    SELECT CustomerID, MIN(DATE_FORMAT(InvoiceDate, '%Y-%m-01')) AS Mes_Inicio
    FROM fact_sales_clean
    GROUP BY CustomerID
),
CohortActivity AS (
    SELECT 
        f.Mes_Inicio,
        DATE_FORMAT(s.InvoiceDate, '%Y-%m-01') AS Mes_Actividad,
        COUNT(DISTINCT s.CustomerID) AS Clientes_Activos
    FROM fact_sales_clean s
    JOIN FirstPurchase f ON s.CustomerID = f.CustomerID
    GROUP BY 1, 2
)
SELECT 
    Mes_Inicio,
    Mes_Actividad,
    Clientes_Activos,
    ROUND(Clientes_Activos * 100.0 / FIRST_VALUE(Clientes_Activos) OVER (PARTITION BY Mes_Inicio ORDER BY Mes_Actividad), 2) AS Pct_Retencion
FROM CohortActivity;

-- 9. CONTROL DE CALIDAD: DETECCIÓN DE ANOMALÍAS
-- Objetivo: Identificar pedidos sospechosos fuera de la norma estadística (Z-Score).
WITH EstadisticasCliente AS (
    SELECT 
        CustomerID,
        Invoice,
        SUM(TotalPrice) AS Total_Pedido,
        AVG(SUM(TotalPrice)) OVER(PARTITION BY CustomerID) AS Media_Historica,
        STDDEV(SUM(TotalPrice)) OVER(PARTITION BY CustomerID) AS Desviacion_Historica
    FROM fact_sales_clean
    GROUP BY CustomerID, Invoice
)
SELECT *
FROM EstadisticasCliente
WHERE Total_Pedido > (Media_Historica + (3 * Desviacion_Historica))
  AND Total_Pedido > 500
ORDER BY Total_Pedido DESC;