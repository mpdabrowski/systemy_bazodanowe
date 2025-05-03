-- sekwencja
CREATE TABLE sequence_table (
    name VARCHAR(100) PRIMARY KEY,
    current_value BIGINT NOT NULL
);
GO

INSERT INTO sequence_table (name, current_value) VALUES ('address_seq', 1);
GO

CREATE FUNCTION get_next_val(@seq_name VARCHAR(100))
RETURNS BIGINT
AS
BEGIN
    DECLARE @next BIGINT;

    UPDATE sequence_table
    SET current_value = current_value + 1
    OUTPUT inserted.current_value INTO @next
    WHERE name = @seq_name;

    RETURN @next;
END;
GO

-- procedura z transakcją, błędami i sekwencją
CREATE PROCEDURE insert_address_with_seq
    @first_name VARCHAR(100),
    @last_name VARCHAR(100),
    @email VARCHAR(100),
    @nip BIGINT = NULL,
    @phone_number VARCHAR(20),
    @street VARCHAR(200),
    @house_number VARCHAR(10),
    @appartment_number VARCHAR(10) = NULL,
    @postcode VARCHAR(10),
    @city VARCHAR(50),
    @country VARCHAR(50)
AS
BEGIN
    DECLARE @id BIGINT = dbo.get_next_val('address_seq');

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO address
        VALUES (
            @id, @first_name, @last_name, @email, @nip, @phone_number, @street,
            @house_number, @appartment_number, @postcode, @city, @country, GETDATE()
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO


CREATE PROCEDURE insert_address_with_seq
    @first_name VARCHAR(100),
    @last_name VARCHAR(100),
    @email VARCHAR(100),
    @nip BIGINT = NULL,
    @phone_number VARCHAR(20),
    @street VARCHAR(200),
    @house_number VARCHAR(10),
    @appartment_number VARCHAR(10) = NULL,
    @postcode VARCHAR(10),
    @city VARCHAR(50),
    @country VARCHAR(50)
AS
BEGIN
    DECLARE @id BIGINT = dbo.get_next_val('address_seq');

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO address
        VALUES (
            @id, @first_name, @last_name, @email, @nip, @phone_number, @street,
            @house_number, @appartment_number, @postcode, @city, @country, GETDATE()
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- procedura ładowania danych w pętli
CREATE PROCEDURE load_dummy_addresses
    @count INT
AS
BEGIN
    DECLARE @i INT = 1;
    WHILE @i <= @count
    BEGIN
        EXEC insert_address_with_seq
            @first_name = CONCAT('First', @i),
            @last_name = CONCAT('Last', @i),
            @email = CONCAT('email', @i, '@test.com'),
            @phone_number = '123456789',
            @street = 'Test Street',
            @house_number = '1',
            @postcode = '00-000',
            @city = 'City',
            @country = 'Country';
        SET @i += 1;
    END
END;
GO

-- scalar function
CREATE FUNCTION get_user_full_name(@userId BIGINT)
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @fullName VARCHAR(200);
    SELECT @fullName = first_name + ' ' + last_name FROM [user] WHERE id = @userId;
    RETURN @fullName;
END;
GO

-- multi-statement table-valued function
CREATE FUNCTION get_products_by_category(@categoryId BIGINT)
RETURNS @result TABLE (
    id_product BIGINT,
    name VARCHAR(200),
    price INT
)
AS
BEGIN
    INSERT INTO @result
    SELECT id_product, name, price
    FROM product
    WHERE id_category = @categoryId;

    RETURN;
END;
GO

-- inline table-valued function
CREATE FUNCTION get_active_users()
RETURNS TABLE
AS
RETURN (
    SELECT id, email, first_name, last_name
    FROM [user]
    WHERE active = 1
);
GO


-- lista aktywnych użytkowników
SELECT * FROM [user] WHERE active = 1;

-- liczba zamówień per użytkownik
SELECT id_user, COUNT(*) AS total_orders
FROM [order]
GROUP BY id_user
HAVING COUNT(*) > 1
ORDER BY total_orders DESC;

-- srednia cena produktów w kategorii
SELECT c.name, AVG(p.price) AS avg_price
FROM product p
JOIN category c ON c.id_category = p.id_category
GROUP BY c.name;

-- produkty z małym stanem magazynowym
SELECT name, stock FROM product
WHERE stock < 10
ORDER BY stock;

-- lista zamówień z ich transportem
SELECT o.id_order, o.number, t.name AS transport_name
FROM [order] o
JOIN transport_method t ON o.id_transport_method = t.id_transport_method;
