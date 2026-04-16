--Base de datos
USE Northwind;

--BÁSICO:
--Obtener la cantidad de clientes agrupados por pais, ordenados de mayor a menor. Solo mostrar países con más de 3 clientes. 
SELECT 
	C.Country as País,
	COUNT(C.CompanyName) as Cliente
FROM Customers C
GROUP BY C.Country
HAVING COUNT(DISTINCT C.CompanyName) > 3
ORDER BY COUNT(DISTINCT C.CompanyName) ASC;

--Lista todos los productos que tienen UnitsInStock = 0 o están descontinuados (Discontinued = 1). Muestra nombre, unidades y si está descontinuado.
SELECT 
	*
FROM Products P
WHERE P.UnitsInStock = 0 OR P.Discontinued = 1;

--Muestra todas las órdenes realizadas durante el año 1997. Incluye OrderID, CustomerID y OrderDate.
SELECT 
	OrderID, CustomerID, OrderDate
FROM Orders
WHERE OrderDate >= '1997-01-01' --WHERE o BETWEEN para aprovechar índices y hacer mas eficiente la consulta.
AND OrderDate < '1998-01-01';

--INTERMEDIO:
--Top 5 productos mas vendidos.
--Encuentra los 5 productos más vendidos en cantidad total de unidades. Muestra el nombre del producto y el total de unidades vendidas.
SELECT TOP 5
	P.ProductName as Producto,
	SUM(OD.Quantity) as TotalVendido
FROM [Order Details] OD
JOIN Products P on P.ProductID = OD.ProductID
GROUP BY P.ProductName
ORDER BY SUM(OD.Quantity) DESC;

--Empleados y sus ventas totales
--Muestra cada empleado con su nombre completo y el total en dinero que ha generado en ventas
SELECT 
	E.FirstName + ' ' + E.LastName as Empleado,
	ROUND(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),2) as TotalVendido
FROM Orders O 
JOIN Employees E on E.EmployeeID = O.EmployeeID
JOIN [Order Details] OD on OD.OrderID = O.OrderID
GROUP BY E.FirstName + ' ' + E.LastName 
ORDER BY SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) DESC;

--Clientes que nunca han ordenado
--Lista los clientes que no tienen ninguna orden registrada. Intenta resolverlo de dos formas: con LEFT JOIN y con NOT EXISTS.
--Con Left Join:
SELECT 
	C.CompanyName as Cliente
FROM Customers C
LEFT JOIN Orders O on O.CustomerID = C.CustomerID
WHERE O.OrderID IS NULL;

--Con NOT EXISTS (Subconsulta)
SELECT 
	C.CompanyName as Cliente
FROM Customers C
WHERE NOT EXISTS (
	SELECT 1 FROM Orders O WHERE O.CustomerID = C.CustomerID
);

--Promedio de días de entrega por transportista
--Calcula el promedio de días entre OrderDate y ShippedDate por cada empresa de transporte (Shippers). Excluye órdenes no enviadas.
SELECT 
  s.CompanyName AS Transportista,
  AVG(DATEDIFF(day, o.OrderDate, o.ShippedDate)) AS PromedioDiasEntrega
FROM Orders o
INNER JOIN Shippers s ON o.ShipVia = s.ShipperID
WHERE o.ShippedDate IS NOT NULL
GROUP BY s.CompanyName
ORDER BY PromedioDiasEntrega;


--ZONA DE CTE
--Con un CTE, calcula el ingreso total y el precio promedio por categoría. Luego ordena las categorías por ingreso total descendente.

WITH IngresoCategorias AS (
	SELECT 
		c.CategoryName,
		ROUND(SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)),2) as IngresoTotal,
		ROUND(AVG(P.UnitPrice), 2) as PrecioPromedio
	FROM Categories C
	INNER JOIN Products P on P.CategoryID = C.CategoryID
	INNER JOIN [Order Details] OD on OD.ProductID = P.ProductID
	GROUP BY C.CategoryName
)
SELECT * FROM IngresoCategorias ORDER BY IngresoTotal DESC;

--La tabla Employees tiene la columna ReportsTo. Usa un CTE recursivo para mostrar la jerarquía completa de empleados (quién reporta a quién) con su nivel de profundidad.

WITH Jerarquia AS (
	--Caso base
	SELECT 
		EmployeeID,
		LastName + ' ' + FirstName AS Nombre,
		ReportsTo,
		0 AS nivel
	FROM Employees
	WHERE ReportsTo IS NULL

	UNION ALL
	--Caso recursivo
	SELECT 
		E.EmployeeID,
		E.LastName + ' ' + E.FirstName AS Nombre,
		E.ReportsTo,
		J.nivel + 1
	FROM Employees E
	INNER JOIN Jerarquia J on J.EmployeeID = E.ReportsTo
)

SELECT 
	REPLICATE(' ',nivel) + Nombre,
	nivel 
FROM Jerarquia;

-- Crea una vista llamada vw_VentasDetalle que consolide: nombre del cliente, empleado, producto, 
-- cantidad, precio unitario e ingreso neto (con descuento). Luego consulta la vista para obtener el
-- top 10 de ingresos.

CREATE OR ALTER VIEW vw_VentasDetalle AS 
SELECT
	c.CompanyName as Cliente,
	e.FirstName + ' ' + e.LastName as Empleado,
	p.ProductName as Producto,
	od.Quantity as Cantidad,
	od.UnitPrice as PrecioUnitario,
	ROUND((od.UnitPrice*od.Quantity*(1-od.Discount)),2) as IngresoNeto
FROM Orders O
INNER JOIN Customers C on C.CustomerID = O.CustomerID
INNER JOIN Employees E on E.EmployeeID = O.EmployeeID
INNER JOIN [Order Details] OD on OD.OrderID = O.OrderID
INNER JOIN Products P on P.ProductID = OD.ProductID

-- Consultar la vista
SELECT TOP 10 * FROM vw_VentasDetalle ORDER BY IngresoNeto DESC