-- Drop existing tables if they exist to avoid conflicts
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Books;

-- Create Books Table
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);

-- Create Customers Table
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

-- Create Orders Table
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

-- Retrieve All Data from Tables
SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;

-- ======================= ANALYSIS QUERIES =======================

-- 1. Retrieve all books in the Fiction genre
SELECT * FROM Books WHERE Genre = 'Fiction';

-- 2. Find books published after 1950
SELECT * FROM Books WHERE Published_Year > 1950;

-- 3. List customers from Canada
SELECT * FROM Customers WHERE Country = 'Canada';

-- 4. Retrieve orders placed in November 2023
SELECT * FROM Orders WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5. Retrieve the total stock of books available
SELECT SUM(Stock) AS Total_Stock FROM Books;

-- 6. Find the details of the most expensive book
SELECT Title, Price FROM Books ORDER BY Price DESC LIMIT 1;

-- 7. List all customers who ordered more than 1 book
SELECT DISTINCT Customers.Customer_ID, Customers.Name
FROM Customers
JOIN Orders ON Customers.Customer_ID = Orders.Customer_ID
WHERE Orders.Quantity > 1;

-- 8. Retrieve all orders where the total amount exceeds $20
SELECT * FROM Orders WHERE Total_Amount > 20;

-- 9. List all unique genres available in the Books table
SELECT DISTINCT Genre FROM Books;

-- 10. Find the book with the lowest stock
SELECT Book_ID, Title, Stock FROM Books ORDER BY Stock ASC LIMIT 1;

-- 11. Calculate the total revenue generated from all orders
SELECT SUM(Total_Amount) AS Total_Revenue FROM Orders;

-- 12. Retrieve the total number of books sold for each genre
SELECT Books.Genre, SUM(Orders.Quantity) AS Total_Sold_Books
FROM Orders
JOIN Books ON Orders.Book_ID = Books.Book_ID
GROUP BY Books.Genre;

-- 13. Find the average price of books in the "Fantasy" genre
SELECT AVG(Price) AS Average_Price FROM Books WHERE Genre = 'Fantasy';

-- 14. List customers who have placed at least 2 orders
SELECT Customer_ID, Name FROM Customers
WHERE Customer_ID IN (
    SELECT Customer_ID FROM Orders GROUP BY Customer_ID HAVING COUNT(Order_ID) >= 2
);

-- 15. Find the most frequently ordered book
SELECT Book_ID, Title FROM Books
WHERE Book_ID IN (
    SELECT Book_ID FROM Orders GROUP BY Book_ID ORDER BY COUNT(Order_ID) DESC LIMIT 1
);

-- 16. Show the top 3 most expensive books in the 'Fantasy' genre
SELECT Title, Price FROM Books WHERE Genre = 'Fantasy' ORDER BY Price DESC LIMIT 3;

-- 17. Retrieve the total quantity of books sold by each author
SELECT Author, SUM(Quantity) AS Total_Books_Sold
FROM (
    SELECT B.Author, O.Quantity FROM Orders O JOIN Books B ON O.Book_ID = B.Book_ID
) AS Subquery
GROUP BY Author;

-- 18. List the cities where customers who spent over $30 are located
SELECT C.City FROM Customers C
JOIN Orders O ON C.Customer_ID = O.Customer_ID
GROUP BY C.City
HAVING SUM(O.Total_Amount) > 30;

-- 19. Find the customer who spent the most on orders
SELECT Customers.Customer_ID, Customers.Name, SUM(Orders.Total_Amount) AS Total_Spent
FROM Customers
JOIN Orders ON Customers.Customer_ID = Orders.Customer_ID
GROUP BY Customers.Customer_ID, Customers.Name
ORDER BY Total_Spent DESC LIMIT 1;

-- 20. Calculate the stock remaining after fulfilling all orders
SELECT Books.Book_ID, Books.Title,
       Books.Stock - COALESCE(SUM(Orders.Quantity), 0) AS Remaining_Stock
FROM Books
LEFT JOIN Orders ON Books.Book_ID = Orders.Book_ID
GROUP BY Books.Book_ID, Books.Title, Books.Stock;
