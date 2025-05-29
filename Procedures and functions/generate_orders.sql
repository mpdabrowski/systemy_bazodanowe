USE systemy_bazodanowe
GO

CREATE OR ALTER PROCEDURE GenerateSampleOrders
    @NumberOfOrders INT = 5000
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartDate DATETIME = DATEADD(YEAR, -4, GETDATE());
    DECLARE @EndDate DATETIME = GETDATE();
    DECLARE @Counter INT = 1;
    DECLARE @OrderNumber VARCHAR(100);
    DECLARE @RandomDate DATETIME;
    DECLARE @RandomStatus INT;
    DECLARE @RandomTransportMethod BIGINT;
    DECLARE @RandomUser BIGINT;
    DECLARE @RandomAddress BIGINT;
    DECLARE @RandomProduct BIGINT;
    DECLARE @RandomQuantity INT;
    
    -- Get min and max IDs for foreign keys
    DECLARE @MinTransportMethod BIGINT = (SELECT MIN(id_transport_method) FROM transport_method);
    DECLARE @MaxTransportMethod BIGINT = (SELECT MAX(id_transport_method) FROM transport_method);
    DECLARE @MinUser BIGINT = (SELECT MIN(id) FROM "user");
    DECLARE @MaxUser BIGINT = (SELECT MAX(id) FROM "user");
    DECLARE @MinAddress BIGINT = (SELECT MIN(id_address) FROM address);
    DECLARE @MaxAddress BIGINT = (SELECT MAX(id_address) FROM address);
    DECLARE @MinProduct BIGINT = (SELECT MIN(id_product) FROM product);
    DECLARE @MaxProduct BIGINT = (SELECT MAX(id_product) FROM product);
    
    WHILE @Counter <= @NumberOfOrders
    BEGIN
        -- Generate random date between start and end date
        SET @RandomDate = DATEADD(SECOND, 
            CAST(RAND() * DATEDIFF(SECOND, @StartDate, @EndDate) AS INT), 
            @StartDate);
        
        -- Generate random status (1-4)
        SET @RandomStatus = CAST(RAND() * 4 + 1 AS INT);
        
        -- Generate random transport method
        SET @RandomTransportMethod = @MinTransportMethod + 
            CAST(RAND() * (@MaxTransportMethod - @MinTransportMethod) AS BIGINT);
        
        -- Generate random user
        SET @RandomUser = @MinUser + 
            CAST(RAND() * (@MaxUser - @MinUser) AS BIGINT);
        
        -- Generate order number (format: ORD-YYYYMMDD-XXXX)
        SET @OrderNumber = 'ORD-' + 
            FORMAT(@RandomDate, 'yyyyMMdd') + '-' + 
            RIGHT('0000' + CAST(@Counter AS VARCHAR(4)), 4);
        
        -- Insert order
        INSERT INTO "order" (
            id_order,
            status,
            number,
            created_at,
            updated_at,
            id_transport_method,
            id_user
        )
        VALUES (
            @Counter,
            @RandomStatus,
            @OrderNumber,
            @RandomDate,
            CASE WHEN @RandomStatus > 1 THEN DATEADD(DAY, CAST(RAND() * 5 AS INT), @RandomDate) ELSE NULL END,
            @RandomTransportMethod,
            @RandomUser
        );
        
        -- Insert shipping address
        SET @RandomAddress = @MinAddress + 
            CAST(RAND() * (@MaxAddress - @MinAddress) AS BIGINT);
            
        INSERT INTO order_has_address (
            id_order_has_address,
            type,
            id_order,
            id_address
        )
        VALUES (
            @Counter * 2 - 1,
            1, -- Shipping address
            @Counter,
            @RandomAddress
        );
        
        -- Insert billing address (could be same as shipping)
        IF RAND() > 0.5
        BEGIN
            SET @RandomAddress = @MinAddress + 
                CAST(RAND() * (@MaxAddress - @MinAddress) AS BIGINT);
        END
        
        INSERT INTO order_has_address (
            id_order_has_address,
            type,
            id_order,
            id_address
        )
        VALUES (
            @Counter * 2,
            2, -- Billing address
            @Counter,
            @RandomAddress
        );
        
        -- Insert 1-5 random products
        DECLARE @ProductCount INT = CAST(RAND() * 4 + 1 AS INT);
        DECLARE @ProductCounter INT = 1;
        
        WHILE @ProductCounter <= @ProductCount
        BEGIN
            SET @RandomProduct = @MinProduct + 
                CAST(RAND() * (@MaxProduct - @MinProduct) AS BIGINT);
            SET @RandomQuantity = CAST(RAND() * 5 + 1 AS INT);
            
            INSERT INTO order_has_product (
                order_id_order,
                product_id_product,
                quantity
            )
            VALUES (
                @Counter,
                @RandomProduct,
                @RandomQuantity
            );
            
            SET @ProductCounter = @ProductCounter + 1;
        END
        
        SET @Counter = @Counter + 1;
    END
END
GO

-- Execute the procedure to generate 5000 orders
EXEC GenerateSampleOrders @NumberOfOrders = 5000;
GO 

