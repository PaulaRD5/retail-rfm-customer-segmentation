# Estrategia de Segmentación de Clientes: Análisis RFM en Online Retail II

## Descripción del Proyecto
Este proyecto realiza un análisis integral de los datos de un retail online para identificar comportamientos de compra y segmentar a los clientes según su valor estratégico. Utilizando el modelo **RFM (Recency, Frequency, Monetary)**, el objetivo es transformar datos transaccionales crudos en insights accionables para marketing y retención de clientes.

---

## Stack Tecnológico
* **Procesamiento de Datos:** Python (Pandas) / SQL (MySQL).
* **Análisis Estadístico:** Segmentación por quintiles y puntuación RFM.
* **Visualización de Datos:** Power BI.
* **Métricas Clave:** Ingresos Totales, Análisis de Pareto (80/20), Distribución de Segmentos.

---

## Flujo de Trabajo

### 1. Limpieza y Preparación (Python/SQL)
Se procesó el dataset "Online Retail II" para:
* Eliminar registros duplicados y valores nulos en `CustomerID`.
* Tratar devoluciones (cantidades negativas) y asegurar la integridad de los precios.
* Calcular el `TotalPrice` por transacción.

### 2. Segmentación RFM (SQL)
Se desarrollaron scripts avanzados en SQL para calcular:
* **Recency (Recencia):** Días desde la última compra.
* **Frequency (Frecuencia):** Número total de pedidos únicos.
* **Monetary (Monetario):** Valor total gastado por el cliente.

Posteriormente, se asignaron puntuaciones del 1 al 5 y se categorizaron los clientes en segmentos como: **Champions, Loyal Customers, At Risk, Hibernating, etc.**

### 3. Visualización Interactiva (Power BI)
Se diseñó un Dashboard estratégico que incluye:
* **KPIs Principales:** Ingresos totales ($8.91M) con formato profesional.
* **Análisis de Pareto:** Gráfico combinado para identificar la concentración de ingresos por clientes.
* **Treemap de Segmentos:** Visualización del peso de cada categoría de cliente en el negocio.
* **Gráfico de Dispersión (RFM):** Análisis visual del comportamiento (Frecuencia vs Recencia) por segmento.
* **Filtros Geográficos:** Segmentación dinámica por país.

---

## Insights Clave
* **Concentración de Ingresos:** Se validó la regla de Pareto, donde un pequeño porcentaje de clientes (Champions) representa la mayor parte del flujo de caja.
* **Oportunidades de Retención:** El gráfico de dispersión permitió identificar clientes en el segmento "At Risk", fundamentales para campañas de reactivación.
* **Distribución Geográfica:** El Reino Unido representa la mayor base de clientes, permitiendo optimizar la logística y el marketing localizado.

---

## Autor
**Paula Ramos Delgado** - Analista de Datos
