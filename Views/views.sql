-- Widoki Regularne

-- Widok 1: Podsumowanie Zamówień Klienta
-- Pokazuje informacje o kliencie wraz ze szczegółami jego zamówień
CREATE VIEW vw_CustomerOrderSummary AS
SELECT 
    a.id_address,
    a.first_name,
    a.last_name,
    a.email,
    o.id_order,
    o.number as order_number,
    o.status as order_status,
    o.created_at as order_date,
    pt.amount as payment_amount,
    pt.currency
FROM address a
JOIN order_has_address oha ON a.id_address = oha.id_address
JOIN "order" o ON oha.id_order = o.id_order
LEFT JOIN payment_transaction pt ON o.id_order = pt.id_order
WHERE oha.type = 1;
GO

-- Przykładowe zapytanie do widoku vw_CustomerOrderSummary
-- Pobiera wszystkie zamówienia klienta o podanym adresie email
SELECT 
    first_name,
    last_name,
    order_number,
    order_status,
    payment_amount,
    currency
FROM vw_CustomerOrderSummary
WHERE email = 'przyklad@email.com'
ORDER BY order_date DESC;
GO

-- Widok 2: Hierarchia Kategorii Produktów
-- Pokazuje kategorie produktów wraz z ich kategoriami nadrzędnymi
CREATE VIEW vw_CategoryHierarchy AS
SELECT 
    c.id_category,
    c.name as category_name,
    c.description,
    pc.name as parent_category_name,
    c.created_at,
    c.updated_at
FROM category c
LEFT JOIN category pc ON c.category_id_category = pc.id_category
WHERE c.deleted_at IS NULL;
GO

-- Przykładowe zapytanie do widoku vw_CategoryHierarchy
-- Pobiera wszystkie kategorie, które nie mają kategorii nadrzędnej
SELECT 
    id_category,
    category_name,
    description
FROM vw_CategoryHierarchy
WHERE parent_category_name IS NULL
ORDER BY category_name;
GO

-- Widoki Indeksowane

-- Widok 3: Statystyki Zamówień (Indeksowany)
-- Pokazuje statystyki zamówień wraz z informacjami o płatnościach
CREATE VIEW vw_OrderStatistics WITH SCHEMABINDING AS
SELECT 
    o.id_order,
    o.number as order_number,
    o.status as order_status,
    o.created_at as order_date,
    COUNT_BIG(*) as total_items,
    SUM(pt.amount) as total_amount,
    pt.currency
FROM dbo."order" o
JOIN dbo.payment_transaction pt ON o.id_order = pt.id_order
GROUP BY o.id_order, o.number, o.status, o.created_at, pt.currency;
GO

-- Utworzenie unikalnego indeksu klastrowego dla widoku indeksowanego
CREATE UNIQUE CLUSTERED INDEX IX_OrderStatistics 
ON vw_OrderStatistics (id_order);
GO

-- Przykładowe zapytanie do widoku vw_OrderStatistics
-- Pobiera statystyki zamówień z ostatniego miesiąca
SELECT 
    order_number,
    order_status,
    total_items,
    total_amount,
    currency
FROM vw_OrderStatistics
WHERE order_date >= DATEADD(MONTH, -1, GETDATE())
ORDER BY total_amount DESC;
GO

-- Widok 4: Aktywne Powiadomienia (Indeksowany)
-- Pokazuje aktywne powiadomienia wraz z powiązanymi statusami zamówień
CREATE VIEW vw_ActiveNotifications WITH SCHEMABINDING AS
SELECT 
    n.id_notification,
    n.name as notification_name,
    n.content,
    n.type as notification_type,
    os.code as order_status_code,
    ost.translation as status_translation
FROM dbo.notification n
JOIN dbo.order_status_has_notification osn ON n.id_notification = osn.id_notification
JOIN dbo.order_status os ON osn.id_order_status = os.id_order_status
JOIN dbo.order_status_translation ost ON os.id_order_status = ost.id_order_status
WHERE n.active = 1;
GO

-- Utworzenie unikalnego indeksu klastrowego dla widoku indeksowanego
CREATE UNIQUE CLUSTERED INDEX IX_ActiveNotifications 
ON vw_ActiveNotifications (id_notification, order_status_code);
GO

-- Przykładowe zapytanie do widoku vw_ActiveNotifications
-- Pobiera wszystkie aktywne powiadomienia dla danego typu powiadomienia
SELECT 
    notification_name,
    content,
    order_status_code,
    status_translation
FROM vw_ActiveNotifications
WHERE notification_type = 1
ORDER BY notification_name;
GO
