USE systemy_bazodanowe
GO

-- Generate categories
CREATE OR ALTER PROCEDURE GenerateCategories
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Clear existing data
        DELETE FROM category;
        
        -- Insert main categories
        INSERT INTO category (
            id_category,
            name,
            description,
            category_id_category,
            created_at,
            parent_category_id
        )
        VALUES 
        (1, 'Electronics', 'Electronic devices and accessories', 1, GETDATE(), 1),
        (2, 'Clothing', 'Fashion and apparel', 2, GETDATE(), 2),
        (3, 'Books', 'Books and publications', 3, GETDATE(), 3),
        (4, 'Home & Garden', 'Home and garden supplies', 4, GETDATE(), 4),
        (5, 'Sports', 'Sports equipment and accessories', 5, GETDATE(), 5);
        
        -- Insert subcategories
        INSERT INTO category (
            id_category,
            name,
            description,
            category_id_category,
            created_at,
            parent_category_id
        )
        VALUES 
        -- Electronics subcategories
        (6, 'Smartphones', 'Mobile phones and accessories', 1, GETDATE(), 1),
        (7, 'Laptops', 'Portable computers and accessories', 1, GETDATE(), 1),
        (8, 'Audio', 'Audio equipment and accessories', 1, GETDATE(), 1),
        
        -- Clothing subcategories
        (9, 'Men''s Clothing', 'Men''s fashion and apparel', 2, GETDATE(), 2),
        (10, 'Women''s Clothing', 'Women''s fashion and apparel', 2, GETDATE(), 2),
        (11, 'Children''s Clothing', 'Children''s fashion and apparel', 2, GETDATE(), 2),
        
        -- Books subcategories
        (12, 'Fiction', 'Fiction books and novels', 3, GETDATE(), 3),
        (13, 'Non-Fiction', 'Non-fiction books and publications', 3, GETDATE(), 3),
        (14, 'Educational', 'Educational books and materials', 3, GETDATE(), 3),
        
        -- Home & Garden subcategories
        (15, 'Furniture', 'Home and office furniture', 4, GETDATE(), 4),
        (16, 'Decor', 'Home decoration items', 4, GETDATE(), 4),
        (17, 'Garden Tools', 'Garden equipment and tools', 4, GETDATE(), 4),
        
        -- Sports subcategories
        (18, 'Fitness', 'Fitness equipment and accessories', 5, GETDATE(), 5),
        (19, 'Team Sports', 'Team sports equipment', 5, GETDATE(), 5),
        (20, 'Outdoor Sports', 'Outdoor sports equipment', 5, GETDATE(), 5);
        
        COMMIT TRANSACTION;
        PRINT 'Categories generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error generating categories:';
        PRINT ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END
GO

-- Generate transport methods
CREATE OR ALTER PROCEDURE GenerateTransportMethods
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Clear existing data
        DELETE FROM transport_method;
        
        INSERT INTO transport_method (id_transport_method, name, price, active, created_at, max_weight)
        VALUES 
        (1, 'Standard Delivery', 15, 1, GETDATE(), 20),
        (2, 'Express Delivery', 30, 1, GETDATE(), 15),
        (3, 'Next Day Delivery', 25, 1, GETDATE(), 25),
        (4, 'International Shipping', 50, 1, GETDATE(), 30),
        (5, 'Local Pickup', 0, 1, GETDATE(), 50);
        
        COMMIT TRANSACTION;
        PRINT 'Transport methods generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error generating transport methods:';
        PRINT ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END
GO

-- Generate users
CREATE OR ALTER PROCEDURE GenerateUsers
    @NumberOfUsers INT = 1000
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Clear existing data
        DELETE FROM "user";
        
        DECLARE @Counter INT = 1;
        DECLARE @Email VARCHAR(100);
        DECLARE @Password VARCHAR(100) = 'password_123';
        
        WHILE @Counter <= @NumberOfUsers
        BEGIN
            SET @Email = 'user' + CAST(@Counter AS VARCHAR(10)) + '@gmail.com';
            
            INSERT INTO "user" (
                id,
                email,
                password,
                first_name,
                last_name,
                active,
                created_at
            )
            VALUES (
                @Counter,
                @Email,
                @Password,
                'FirstName' + CAST(@Counter AS VARCHAR(10)),
                'LastName' + CAST(@Counter AS VARCHAR(10)),
                1,
                DATEADD(DAY, -CAST(RAND() * 1460 AS INT), GETDATE())
            );
            
            SET @Counter = @Counter + 1;
        END
        
        COMMIT TRANSACTION;
        PRINT 'Users generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error generating users:';
        PRINT ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END
GO

-- Generate addresses
CREATE OR ALTER PROCEDURE GenerateAddresses
    @NumberOfAddresses INT = 2000
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Clear existing data
        DELETE FROM address;
        
        DECLARE @Counter INT = 1;
        DECLARE @Cities TABLE (City VARCHAR(50), Postcode VARCHAR(10));
        
        -- Sample Polish cities and postcodes
        INSERT INTO @Cities VALUES 
        ('Warszawa', '00-001'), ('Kraków', '30-001'), ('Wrocław', '50-001'),
        ('Poznań', '60-001'), ('Gdańsk', '80-001'), ('Łódź', '90-001'),
        ('Szczecin', '70-001'), ('Lublin', '20-001'), ('Katowice', '40-001'),
        ('Białystok', '15-001');
        
        WHILE @Counter <= @NumberOfAddresses
        BEGIN
            DECLARE @City VARCHAR(50);
            DECLARE @Postcode VARCHAR(10);
            
            SELECT TOP 1 @City = City, @Postcode = Postcode 
            FROM @Cities 
            ORDER BY NEWID();
            
            INSERT INTO address (
                id_address,
                first_name,
                last_name,
                email,
                nip,
                phone_number,
                street,
                house_number,
                appartment_number,
                postcode,
                city,
                country,
                created_at
            )
            VALUES (
                @Counter,
                'FirstName' + CAST(@Counter AS VARCHAR(10)),
                'LastName' + CAST(@Counter AS VARCHAR(10)),
                'address' + CAST(@Counter AS VARCHAR(10)) + '@example.com',
                CAST(CAST(RAND() * 9999999999 AS BIGINT) AS VARCHAR(10)),
                '+48' + RIGHT('000000000' + CAST(CAST(RAND() * 999999999 AS INT) AS VARCHAR(9)), 9),
                'Street ' + CAST(CAST(RAND() * 100 AS INT) AS VARCHAR(3)),
                CAST(CAST(RAND() * 100 AS INT) AS VARCHAR(3)),
                CASE WHEN RAND() > 0.5 THEN CAST(CAST(RAND() * 50 AS INT) AS VARCHAR(3)) ELSE NULL END,
                @Postcode,
                @City,
                'Poland',
                DATEADD(DAY, -CAST(RAND() * 1460 AS INT), GETDATE())
            );
            
            SET @Counter = @Counter + 1;
        END
        
        COMMIT TRANSACTION;
        PRINT 'Addresses generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error generating addresses:';
        PRINT ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END
GO

-- Generate products
CREATE OR ALTER PROCEDURE GenerateProducts
    @NumberOfProducts INT = 500
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Clear existing data
        DELETE FROM product;
        
        DECLARE @Counter INT = 1;
        DECLARE @Categories TABLE (Name VARCHAR(200), Description VARCHAR(500));
        
        -- Sample product categories
        INSERT INTO @Categories VALUES 
        ('Electronics', 'Electronic devices and accessories'),
        ('Clothing', 'Fashion and apparel'),
        ('Books', 'Books and publications'),
        ('Home & Garden', 'Home and garden supplies'),
        ('Sports', 'Sports equipment and accessories');
        
        WHILE @Counter <= @NumberOfProducts
        BEGIN
            DECLARE @CategoryName VARCHAR(200);
            DECLARE @CategoryDesc VARCHAR(500);
            DECLARE @RandomCategoryId INT;
            
            -- Get random category ID between 1 and 20
            SET @RandomCategoryId = CAST(RAND() * 19 + 1 AS INT);
            
            SELECT TOP 1 @CategoryName = Name, @CategoryDesc = Description 
            FROM @Categories 
            ORDER BY NEWID();
            
            INSERT INTO product (
                id_product,
                name,
                description,
                image_url,
                price,
                currency,
                stock,
                created_at,
                updated_at,
                id_category
            )
            VALUES (
                @Counter,
                @CategoryName + ' Product ' + CAST(@Counter AS VARCHAR(10)),
                'Description for ' + @CategoryName + ' product ' + CAST(@Counter AS VARCHAR(10)),
                'https://example.com/images/product' + CAST(@Counter AS VARCHAR(10)) + '.jpg',
                CAST(RAND() * 1000 + 10 AS INT), -- Random price between 10 and 1010
                'PLN',
                CAST(RAND() * 100 AS INT), -- Random stock between 0 and 100
                DATEADD(DAY, -CAST(RAND() * 1460 AS INT), GETDATE()),
                NULL,
                @RandomCategoryId
            );
            
            SET @Counter = @Counter + 1;
        END
        
        COMMIT TRANSACTION;
        PRINT 'Products generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error generating products:';
        PRINT ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END
GO

-- Main procedure to execute all generators
CREATE OR ALTER PROCEDURE GenerateAllSampleData
    @NumberOfUsers INT = 1000,
    @NumberOfAddresses INT = 2000,
    @NumberOfProducts INT = 500
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        PRINT 'Starting data generation...';
        
        EXEC GenerateCategories;
        EXEC GenerateTransportMethods;
        EXEC GenerateUsers @NumberOfUsers = @NumberOfUsers;
        EXEC GenerateAddresses @NumberOfAddresses = @NumberOfAddresses;
        EXEC GenerateProducts @NumberOfProducts = @NumberOfProducts;
        
        COMMIT TRANSACTION;
        PRINT 'All sample data generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error in main data generation:';
        PRINT ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END
GO

-- Execute the main procedure
EXEC GenerateAllSampleData;
GO 