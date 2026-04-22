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
