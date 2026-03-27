--Base de datos a usar:
USE Northwind;

-- 1. Listar todos los productos con nombre.
SELECT 
	ProductName as [Nombre del Producto],
	UnitPrice	as [Precio unitario],
	UnitsInStock as Stock
FROM Products;

--2. Mostrar todos los productos que cuestan mas de 20 y tienen un stock mayor a 0.
SELECT 
	* 
FROM products
WHERE UnitPrice > 20
AND UnitsInStock > 0;

--3.Lista los clientes de USA
SELECT 
	* 
FROM Customers 
WHERE Country = 'USA';

--4.Ordenar los productos por precio de mayor a menor
SELECT 
	*
FROM Products
ORDER BY UnitPrice DESC;

--5.Listar nombre del producto y el nombre de la categoría
SELECT 
	P.ProductName,
	C.CategoryName
FROM Products P
INNER JOIN Categories C ON C.CategoryID = P.CategoryID;

--6.Listar el nombre del cliente y la fecha de la orden. Tablas: Customers, Orders
SELECT 
	C.CompanyName,
	O.OrderDate
FROM Customers C 
INNER JOIN Orders O ON O.CustomerID = C.CustomerID;

--7. Listar el nombre del producto y la cantidad vendida. Tablas: Order details, Products.
SELECT 
	P.ProductName,
	SUM(OD.Quantity) as CantidadVendida
FROM Products P
INNER JOIN [Order Details] OD on OD.ProductID = P.ProductID
GROUP BY P.ProductName;

--8. Listar el nombre del cliente y el nombre del producto que ha comprado. Tablas: Customers, Orders, Order Details, Products.
SELECT 
	C.CompanyName,
	P.ProductName
FROM Customers C
INNER JOIN Orders O on O.CustomerID = C.CustomerID
INNER JOIN [Order Details] OD on OD.OrderID = O.OrderID
INNER JOIN Products P on P.ProductID = OD.ProductID
GROUP BY ProductName, CompanyName
ORDER BY CompanyName;

--9. Contar cuantos productos hay por categoria
SELECT 
	C.CategoryName,
	COUNT(P.ProductID) as [Cantidad de productos]
FROM Categories C
INNER JOIN Products P on P.CategoryID = C.CategoryID
GROUP BY C.CategoryName;

--10. Total de órdenes por cliente
SELECT 
	C.CompanyName as Cliente,
	COUNT(O.orderID)
FROM Customers C
INNER JOIN Orders O on O.CustomerID = C.CustomerID
GROUP BY C.CompanyName;

--11. Calcular el total vendido por producto:
SELECT 
	P.ProductName,
	SUM(OD.UnitPrice*Quantity) as Ventas
FROM Products P
INNER JOIN [Order Details] OD on OD.ProductID = P.ProductID
GROUP BY P.ProductName;

--12. Calcular el top 5 de clientes que mas compraron
SELECT TOP 5
	C.CompanyName,
	SUM(OD.Quantity*OD.UnitPrice)
FROM Customers C
INNER JOIN Orders O on O.CustomerID = C.CustomerID
INNER JOIN [Order Details] OD on OD.OrderID = O.OrderID
GROUP BY C.CompanyName
ORDER BY SUM(OD.Quantity*UnitPrice) DESC;

--13. Categorías con mas de 10 productos
SELECT 
	C.CategoryName as Categoria,
	COUNT(P.ProductID) as Productos
FROM Categories C
INNER JOIN Products P on P.CategoryID = C.CategoryID
GROUP BY C.CategoryName
HAVING COUNT(P.ProductID) > 10;

--14. Clientes que hicieron mas de 5 pedidos
SELECT 
	C.CompanyName as Cliente,
	COUNT(O.OrderID) as Pedidos
FROM Orders O
INNER JOIN Customers C on C.CustomerID = O.CustomerID
GROUP BY C.CompanyName
HAVING COUNT(O.OrderID) > 5;

--15. Productos que nunca se han vendido
SELECT 
	P.ProductName
FROM Products P
LEFT JOIN [Order Details] OD on OD.ProductID = P.ProductID
WHERE OD.ProductID IS NULL;

--16. Top 3 productos mas vendidos por cantidad
SELECT TOP 3 
	P.ProductName as Producto,
	SUM(OD.Quantity) as CantidadVendida
FROM Products P
JOIN [Order Details] OD on OD.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY SUM(OD.Quantity) DESC;

--17. Para cada una de las ordenes calcular el total de dinero de la orden
SELECT 
	O.OrderID,
	O.OrderDate,
	SUM(OD.Quantity*OD.UnitPrice) as Total
FROM Orders O
LEFT JOIN [Order Details] OD on OD.OrderID = O.OrderID
GROUP BY O.OrderID, O.OrderDate;
-- version corta sin join:
SELECT 
	OD.OrderID,
	SUM(OD.Quantity*OD.UnitPrice) as Total
FROM [Order Details] OD
GROUP BY OD.orderID;

--18. Clientes que han comprado mas de 1000 en total
SELECT 
	C.CompanyName as Cliente,
	SUM(OD.Quantity*OD.UnitPrice) as Total
FROM Customers C
INNER JOIN Orders O on O.CustomerID = C.CustomerID
INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY C.CompanyName
HAVING SUM(OD.Quantity*OD.UnitPrice) > 1000;

--19. Mes con mas ventas
SELECT TOP 1
	YEAR(O.OrderDate) as Año,
	DATENAME(MONTH, O.OrderDate) as Mes,
	SUM(OD.Quantity*OD.UnitPrice) as Ventas
From Orders O
INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY YEAR(O.OrderDate),DATENAME(MONTH, O.OrderDate)
ORDER BY SUM(OD.Quantity*OD.UnitPrice) DESC;

--20. Clientes que compraron todos los productos de una categoría
SELECT 
	C.CompanyName as Cliente,
	Ct.CategoryName as Categoria,
	COUNT(DISTINCT P1.ProductID) as [Productos Diferentes Comprados]
FROM Customers C
JOIN Orders O on O.CustomerID = C.CustomerID
JOIN [Order Details] OD on OD.OrderID = O.OrderID
JOIN Products P1 on P1.ProductID = OD.ProductID
JOIN Categories Ct on Ct.CategoryID = P1.CategoryID
JOIN (
    SELECT CategoryID, COUNT(ProductID) as TotalEnCategoria
    FROM Products 
    GROUP BY CategoryID
) as CProducts on CProducts.CategoryID = Ct.CategoryID
GROUP BY 
    C.CompanyName, 
    Ct.CategoryName,
    CProducts.TotalEnCategoria
HAVING COUNT(DISTINCT P1.ProductID) = CProducts.TotalEnCategoria;
