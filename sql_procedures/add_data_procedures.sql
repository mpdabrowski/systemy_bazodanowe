-- Create sequence and procedure for inserting address
CREATE SEQUENCE AddressSequence START WITH 1 INCREMENT BY 1;

CREATE PROCEDURE Insert_Address
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
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO address (
            id_address, first_name, last_name, email, nip, phone_number,
            street, house_number, appartment_number, postcode, city, country, created_at
        )
        VALUES (
            NEXT VALUE FOR AddressSequence,
            @FirstName, @LastName, @Email, @NIP, @PhoneNumber,
            @Street, @HouseNumber, @ApartmentNumber, @Postcode, @City, @Country, GETDATE()
        );
        
        COMMIT TRANSACTION;
        RETURN SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        THROW;
        RETURN -1;
    END CATCH
END;
GO