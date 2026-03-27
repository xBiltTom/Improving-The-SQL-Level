--Base de datos a usar:
USE Northwind;

-- 1.
SELECT 
	ProductName as [Nombre del Producto],
	UnitPrice	as [Precio unitario],
	UnitsInStock as Stock
FROM Products;

--2.
SELECT 
	* 
FROM products
WHERE UnitPrice > 20
AND UnitsInStock > 0;

--3.
SELECT 
	* 
FROM Customers 
WHERE Country = 'USA';

--4.
SELECT 
	*
FROM Products
ORDER BY UnitPrice DESC;

--5.
SELECT 
	P.ProductName,
	C.CategoryName
FROM Products P
INNER JOIN Categories C ON C.CategoryID = P.CategoryID;

--6.
SELECT 
	C.CompanyName,
	O.OrderDate
FROM Customers C 
INNER JOIN Orders O ON O.CustomerID = C.CustomerID;

--7.
SELECT 
	P.ProductName,
	SUM(OD.Quantity) as CantidadVendida
FROM Products P
INNER JOIN [Order Details] OD on OD.ProductID = P.ProductID
GROUP BY P.ProductName;

--8.
SELECT 
	C.CompanyName,
	P.ProductName
FROM Customers C
INNER JOIN Orders O on O.CustomerID = C.CustomerID
INNER JOIN [Order Details] OD on OD.OrderID = O.OrderID
INNER JOIN Products P on P.ProductID = OD.ProductID
GROUP BY ProductName, CompanyName
ORDER BY CompanyName;

--9.
SELECT 
	C.CategoryName,
	COUNT(P.ProductID) as [Cantidad de productos]
FROM Categories C
INNER JOIN Products P on P.CategoryID = C.CategoryID
GROUP BY C.CategoryName;

--10.
SELECT 
	C.CompanyName as Cliente,
	COUNT(O.orderID)
FROM Customers C
INNER JOIN Orders O on O.CustomerID = C.CustomerID
GROUP BY C.CompanyName;

--11.
SELECT 
	P.ProductName,
	SUM(OD.UnitPrice*Quantity) as Ventas
FROM Products P
INNER JOIN [Order Details] OD on OD.ProductID = P.ProductID
GROUP BY P.ProductName;

--12.
SELECT TOP 5
	C.CompanyName,
	SUM(OD.Quantity*OD.UnitPrice)
FROM Customers C
INNER JOIN Orders O on O.CustomerID = C.CustomerID
INNER JOIN [Order Details] OD on OD.OrderID = O.OrderID
GROUP BY C.CompanyName
ORDER BY SUM(OD.Quantity*UnitPrice) DESC;

--13.
SELECT 
	C.CategoryName as Categoria,
	COUNT(P.ProductID) as Productos
FROM Categories C
INNER JOIN Products P on P.CategoryID = C.CategoryID
GROUP BY C.CategoryName
HAVING COUNT(P.ProductID) > 10;

--14.
SELECT 
	C.CompanyName as Cliente,
	COUNT(O.OrderID) as Pedidos
FROM Orders O
INNER JOIN Customers C on C.CustomerID = O.CustomerID
GROUP BY C.CompanyName
HAVING COUNT(O.OrderID) > 5;

--15.
SELECT 
	P.ProductName
FROM Products P
LEFT JOIN [Order Details] OD on OD.ProductID = P.ProductID
WHERE OD.ProductID IS NULL;

--16.
SELECT TOP 3 
	P.ProductName as Producto,
	SUM(OD.Quantity) as CantidadVendida
FROM Products P
JOIN [Order Details] OD on OD.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY SUM(OD.Quantity) DESC;

--17.
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

--18.
SELECT 
	C.CompanyName as Cliente,
	SUM(OD.Quantity*OD.UnitPrice) as Total
FROM Customers C
INNER JOIN Orders O on O.CustomerID = C.CustomerID
INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY C.CompanyName
HAVING SUM(OD.Quantity*OD.UnitPrice) > 1000;

--19.
SELECT TOP 1
	YEAR(O.OrderDate) as Año,
	DATENAME(MONTH, O.OrderDate) as Mes,
	SUM(OD.Quantity*OD.UnitPrice) as Ventas
From Orders O
INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
GROUP BY YEAR(O.OrderDate),DATENAME(MONTH, O.OrderDate)
ORDER BY SUM(OD.Quantity*OD.UnitPrice) DESC;

--20.
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
