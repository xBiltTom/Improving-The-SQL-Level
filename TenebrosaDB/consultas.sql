USE TenebrosaOLTP;

-- Comando para visualizar las tablas que contiene la base de datos
SELECT
	TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

-- Explorando la base de datos

-- 1. Explorando las tablas maestras (Catálogos)
-- 1.1. Analizar el inventario crítico
-- Esta consulta permitirá ver el estado del inventario, cruzando el producto con 
-- sus respectivas marcas y líneas, y filtrando aquellos que necesitan rebastecimiento
-- urgente (donde el stock actual es menor al mínimo)

SELECT 
	P.Producto as CodigoProducto,
	P.Descripcion as NombreProducto,
	M.Descripcion as Marca,
	L.Descripcion as Linea,
	P.StockAc as StockActual,
	P.StockMin as StockMinimo,
	P.PrecVenta as PrecioVenta
FROM PRODUCTO P
INNER JOIN MARCA M ON P.Marca = M.Marca
INNER JOIN LINEA L on M.Linea = L.Linea
WHERE 
	P.StockAc <= P.StockMin
ORDER BY 
	P.StockAc ASC;

-- 1.2. Perfil de los clientes VIP
-- Esta consulta sirve para identificar los clienes con mayor línea de crédito aprobada, 
-- lo cual es vital para el módulo de cuentas por cobrar

SELECT TOP 10
	*
FROM CLIENTE C
WHERE 
	credito = 1 -- Clientes con crédito aprobado
ORDER BY topeCredito DESC;

-- 2. Analizando la transaccionalidad
-- 2.1. Radiografía de las últimas facturas/boletas
-- Esta consulta simular lo que vería el endpoint que solicita el historial de compras
-- de la tienda, mostrando qué empleado vendió que productos y a qué cliente

SELECT
	D.Documento AS NroDocumento,
	D.Fecha,
	C.Nombre AS Cliente,
	PER.Nombre AS Vendedor,
	P.Descripcion AS ProductoVendido,
	DD.Cantidad,
	DD.PrecUnit as PrecioUnitario,
	(DD.Cantidad*DD.PrecUnit) AS SubTotalItem
FROM DOCUMENTO D
INNER JOIN DETADOC DD on D.Documento = DD.Documento AND D.TipoDoc = DD.TipoDoc
INNER JOIN CLIENTE C ON D.Cliente = C.Cliente
INNER JOIN PERSONAL PER ON D.Personal = PER.Personal
INNER JOIN PRODUCTO P ON DD.Producto = P.Producto
ORDER BY 
	D.Fecha DESC;

-- 3. Finanzas y reglas de negocio
-- 3.1. Monitoreo del cronograma de pagos
-- Se consulta las cuotas programadas que aún no han sido pagadas, ordenadas por
-- su fecha de vencimiento.

SELECT
	CR.Documento, 
	C.Nombre as Cliente,
	CR.NroCuota,
	CR.Importe AS Capital,
	CR.Interes,
	(CR.Importe+CR.Interes+CR.IgvInteres) AS TotalCuota,
	CR.feVence AS FechaVencimiento
FROM CRONOGRAMA CR
INNER JOIN DOCUMENTO D ON CR.Documento = D.Documento
INNER JOIN CLIENTE C ON D.Cliente = C.Cliente
WHERE 
	CR.estado = 'P' -- Asumiendo que 'P' significa Pendiente o programado
ORDER BY
	CR.feVence ASC;