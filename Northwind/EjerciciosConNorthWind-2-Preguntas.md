# Preguntas - Ejercicios Northwind 2

## Básico
1. Obtener la cantidad de clientes agrupados por país, ordenados de mayor a menor. Solo mostrar los países con más de 3 clientes.
2. Listar todos los productos que tienen UnitsInStock = 0 o están descontinuados (Discontinued = 1). Muestra nombre, unidades y si está descontinuado.
3. Muestra todas las órdenes realizadas durante el año 1997. Incluye OrderID, CustomerID y OrderDate.

## Intermedio
4. Encuentra los 5 productos más vendidos en cantidad total de unidades. Muestra el nombre del producto y el total de unidades vendidas.
5. Muestra cada empleado con su nombre completo y el total en dinero que ha generado en ventas (considera UnitPrice * Quantity * (1 - Discount)).
6. Lista los clientes que no tienen ninguna orden registrada. Intenta resolverlo de dos formas: con LEFT JOIN y con NOT EXISTS.
7. Calcula el promedio de días entre OrderDate y ShippedDate por cada empresa de transporte (Shippers). Excluye órdenes no enviadas.

## Avanzado

## Window Functions

## CTEs