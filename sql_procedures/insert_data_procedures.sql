use systemy_bazodanowe
go

-- dodawanie nowego adresu
CREATE SEQUENCE AddressSequence START WITH 1 INCREMENT BY 1;

CREATE OR ALTER PROCEDURE dbo.Insert_Address
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Email VARCHAR(100),
    @PhoneNumber VARCHAR(20),
    @Street VARCHAR(200),
    @HouseNumber VARCHAR(10),
    @Postcode VARCHAR(10),
    @City VARCHAR(50),
    @Country VARCHAR(50),
    @NIP BIGINT = NULL,
    @ApartmentNumber VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewAddressId BIGINT;
    DECLARE @ReturnValue INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @FirstName IS NULL OR @LastName IS NULL OR @Email IS NULL
            OR @PhoneNumber IS NULL OR @Street IS NULL OR @HouseNumber IS NULL
            OR @Postcode IS NULL OR @City IS NULL OR @Country IS NULL
        BEGIN
            RAISERROR('Wszystkie wymagane parametry muszą być podane', 16, 1);
        END
        
        SET @NewAddressId = NEXT VALUE FOR dbo.AddressSequence;
        
        INSERT INTO address (
            id_address, first_name, last_name, email, nip, phone_number,
            street, house_number, appartment_number, postcode, city, country, created_at
        )
        VALUES (
            @NewAddressId,
            @FirstName, @LastName, @Email, @NIP, @PhoneNumber,
            @Street, @HouseNumber, @ApartmentNumber, @Postcode, @City, @Country, GETDATE()
        );
        
        COMMIT TRANSACTION;
        SET @ReturnValue = 1; -- Sukces
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        INSERT INTO ErrorLog (ErrorMessage, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine)
        VALUES (@ErrorMessage, @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE());
        
        SET @NewAddressId = -1;
        SET @ReturnValue = -1;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    
    SELECT @NewAddressId AS NewAddressId, @ReturnValue AS ReturnStatus;
    
    RETURN @ReturnValue;
END;
GO

-- Wywołanie
EXEC Insert_Address
	@FirstName  = 'John',
    @LastName = 'Cena',
    @Email = 'john.cena@example.com',
    @PhoneNumber = '+48123456789',
    @Street = 'Test',
    @HouseNumber = '121',
    @Postcode = '00-001',
    @City = 'Warszawa',
    @Country = 'Polska',
    @NIP = 865521212,
    @ApartmentNumber = NULL


 -- Dodawanie nowego użytkownika

CREATE SEQUENCE seq_user_id AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE OR ALTER PROCEDURE registerUser
    @Email VARCHAR(100),
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Password TEXT,
    @PhoneNumber VARCHAR(20),
    @Street VARCHAR(200),
    @HouseNumber VARCHAR(10),
    @AppartmentNumber VARCHAR(10) = NULL,
    @Postcode VARCHAR(10),
    @City VARCHAR(50),
    @Country VARCHAR(50),
    @NIP BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserID BIGINT;
    DECLARE @AddressID BIGINT;
    DECLARE @ReturnValue INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate required parameters
        IF @Email IS NULL OR @FirstName IS NULL OR @LastName IS NULL 
           OR @Password IS NULL OR @PhoneNumber IS NULL OR @Street IS NULL 
           OR @HouseNumber IS NULL OR @Postcode IS NULL OR @City IS NULL 
           OR @Country IS NULL
        BEGIN
            RAISERROR('Wszystkie wymagane parametry muszą być podane', 16, 1);
        END

        -- Check if email already exists
        IF EXISTS (SELECT 1 FROM [user] WHERE email = @Email)
        BEGIN
            RAISERROR('Użytkownik z podanym adresem email już istnieje', 16, 1);
        END

        SET @UserID = NEXT VALUE FOR seq_user_id;
        SET @AddressID = NEXT VALUE FOR AddressSequence;

        INSERT INTO [user] (id, email, first_name, last_name, password, created_at)
        VALUES (@UserID, @Email, @FirstName, @LastName, @Password, GETDATE());

        INSERT INTO address (
            id_address, first_name, last_name, email, phone_number, street,
            house_number, appartment_number, postcode, city, country, created_at, nip
        )
        VALUES (
            @AddressID, @FirstName, @LastName, @Email, @PhoneNumber, @Street,
            @HouseNumber, @AppartmentNumber, @Postcode, @City, @Country, GETDATE(), @NIP
        );

        COMMIT TRANSACTION;
        SET @ReturnValue = 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        INSERT INTO ErrorLog (ErrorMessage, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine)
        VALUES (@ErrorMessage, @ErrorSeverity, @ErrorState, ERROR_PROCEDURE(), ERROR_LINE());
        
        SET @UserID = -1;
        SET @ReturnValue = -1;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    
    SELECT @UserID AS NewUserId, @ReturnValue AS ReturnStatus;
    RETURN @ReturnValue;
END;
GO

EXEC registerUser
    @Email = 'john.cena@gmail.com',
    @FirstName = 'John',
    @LastName = 'Cena',
    @Password = 'password',
    @PhoneNumber = '+48666666666',
    @Street = 'Testowa',
    @HouseNumber = '1',
    @AppartmentNumber = NULL,
    @Postcode = '96-200',
    @City = 'Rawa Mazowiecka',
    @Country = 'PL',
    @NIP = NULL


-- Dodanie kategorii

CREATE SEQUENCE categories_id_seq WITH 1 INCREMENT BY 1;

CREATE OR ALTER PROCEDURE addMultipleCategories
    @Count INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ReturnValue INT = 0;
    DECLARE @CategoriesAdded INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Count <= 0
        BEGIN
            RAISERROR('Liczba kategorii musi być większa od 0', 16, 1);
        END

        DECLARE @i INT = 1;
        WHILE @i <= @Count
        BEGIN
            INSERT INTO category (id_category, name, description, parent_category_id, created_at)
            VALUES (NEXT VALUE FOR categories_id_seq, CONCAT('Category ', @i), CONCAT('Description ', @i), @i-1, GETDATE());
            SET @i = @i + 1;
            SET @CategoriesAdded = @CategoriesAdded + 1;
        END

        COMMIT TRANSACTION;
        SET @ReturnValue = 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        SET @ReturnValue = -1;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    
    SELECT @CategoriesAdded AS CategoriesAdded, @ReturnValue AS ReturnStatus;
    RETURN @ReturnValue;
END;
GO

EXEC addMultipleCategories @Count = 55;


-- Dodanie produktów
CREATE SEQUENCE seq_product_id AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE OR ALTER PROCEDURE addMultipleProducts
    @Count INT,
    @BaseCategoryID BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ReturnValue INT = 0;
    DECLARE @ProductsAdded INT = 0;
    DECLARE @TranStarted BIT = 0;

    BEGIN TRY
        IF @Count <= 0
        BEGIN
            RAISERROR('Liczba produktów musi być większa od 0', 16, 1);
        END

        IF NOT EXISTS (SELECT 1 FROM category WHERE id_category = @BaseCategoryID)
        BEGIN
            RAISERROR('Podana kategoria nie istnieje', 16, 1);
        END

        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @TranStarted = 1;
        END

        DECLARE @i INT = 1;
        WHILE @i <= @Count
        BEGIN
            DECLARE @ProductID BIGINT = NEXT VALUE FOR seq_product_id;
            DECLARE @Name NVARCHAR(255) = CONCAT('Product ', @i);
            DECLARE @Price DECIMAL(10, 2) = CAST(ABS(CHECKSUM(NEWID()) % 10000) AS DECIMAL(10, 2)) / 100 + 1;
            DECLARE @Stock INT = ABS(CHECKSUM(NEWID()) % 100) + 1;
            DECLARE @CreatedAt DATETIME = GETDATE();

            INSERT INTO product (id_product, name, price, created_at, currency, stock, id_category)
            VALUES (@ProductID, @Name, @Price, @CreatedAt, 'PLN', @Stock, @BaseCategoryID);

            SET @i += 1;
            SET @ProductsAdded += 1;
        END

        IF @TranStarted = 1
        BEGIN
            COMMIT TRANSACTION;
        END

        SET @ReturnValue = 1;
    END TRY
    BEGIN CATCH
        IF @TranStarted = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        SET @ReturnValue = -1;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    
    SELECT @ProductsAdded AS ProductsAdded, @ReturnValue AS ReturnStatus;
    RETURN @ReturnValue;
END;
GO

EXEC addMultipleProducts @Count = 1000, @BaseCategoryID = 10;


-- Dodanie metod transportu
CREATE SEQUENCE seq_transport_method_id AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE OR ALTER PROCEDURE addTransportMethods
    @Count INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    WHILE @i <= @Count
    BEGIN
        DECLARE @ID BIGINT = NEXT VALUE FOR seq_transport_method_id;
        DECLARE @Name VARCHAR(100) = CONCAT('Transport Method ', @i);
        DECLARE @Price INT = 50 + (@i * 10);
        DECLARE @MaxWeight INT = 100 + (@i * 5);
        DECLARE @Active BIT = 1;
        DECLARE @CreatedAt DATETIME = GETDATE();

        INSERT INTO transport_method (id_transport_method, name, price, max_weight, active, created_at)
        VALUES (@ID, @Name, @Price, @MaxWeight, @Active, @CreatedAt);

        SET @i += 1;
    END
END;
GO

EXEC addTransportMethods @Count = 50;


-- Składanie zamówienia
CREATE SEQUENCE seq_order_id AS BIGINT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_order_status_history_id AS BIGINT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_order_has_address_id AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE TYPE BigIntList AS TABLE
(
    product_id BIGINT
);

CREATE OR ALTER PROCEDURE placeOrder
    @UserID BIGINT,
    @TransportMethodID BIGINT,
    @BillingAddressID BIGINT,
    @ShippingAddressID BIGINT,
    @ProductIDs BigIntList READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TranStarted BIT = 0;

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @TranStarted = 1;
        END

        DECLARE @OrderID BIGINT = NEXT VALUE FOR seq_order_id;
        DECLARE @Now DATETIME = GETDATE();

        INSERT INTO [order] (id_order, status, number, created_at, id_transport_method, id_user)
        VALUES (
            @OrderID, 1, CONCAT('ORD-', FORMAT(@Now, 'yyyyMMddHHmmss')), @Now,
            @TransportMethodID, @UserID
        );

        INSERT INTO order_has_address (id_order_has_address, type, id_order, id_address)
        VALUES 
            (NEXT VALUE FOR seq_order_has_address_id, 1, @OrderID, @BillingAddressID),
            (NEXT VALUE FOR seq_order_has_address_id, 2, @OrderID, @ShippingAddressID);

        INSERT INTO order_has_product (order_id_order, product_id_product)
        SELECT @OrderID, product_id FROM @ProductIDs;

        DECLARE @StatusHistoryID BIGINT = NEXT VALUE FOR seq_order_status_history_id;
        INSERT INTO order_status_history (
            id_order_status_history, created_at, order_id_order, order_status_id_order_status
        )
        VALUES (
            @StatusHistoryID, @Now, @OrderID, 1
        );

        DECLARE @NotificationID BIGINT;
        SELECT TOP 1 @NotificationID = id_notification
        FROM order_status_has_notification
        WHERE id_order_status = 1;

        IF @NotificationID IS NOT NULL
        BEGIN
            DECLARE @Content CHAR(1000);
            SELECT @Content = content FROM notification WHERE id_notification = @NotificationID;

            PRINT 'Notyfikacja: ' + @Content;
        END;

        IF @TranStarted = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @TranStarted = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;



DECLARE @ProductIDs AS BigIntList;

INSERT INTO @ProductIDs (product_id) VALUES (120);
INSERT INTO @ProductIDs (product_id) VALUES (222);
INSERT INTO @ProductIDs (product_id) VALUES (333);

EXEC placeOrder
    @UserID = 1,
    @TransportMethodID = 2,
    @BillingAddressID = 5,
    @ShippingAddressID = 6,
    @ProductIDs = @ProductIDs;


select * from "user";