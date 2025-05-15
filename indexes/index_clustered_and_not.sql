use systemy_bazodanowe
go

-- Create table notification
CREATE TABLE notification 
    (
     id_notification BIGINT NOT NULL , 
     type TINYINT NOT NULL DEFAULT 1 , 
     name VARCHAR (200) NOT NULL , 
     content CHAR (1000) NOT NULL , 
     active TINYINT NOT NULL , 
     created_at DATETIME NOT NULL , 
     updated_at DATETIME 
    )
GO 

ALTER TABLE notification 
    ADD CONSTRAINT notification_types 
    CHECK ( type IN (1, 2) ) 
GO

-- Create nonclustered primary key for notification
ALTER TABLE notification ADD CONSTRAINT notification_PK PRIMARY KEY NONCLUSTERED (id_notification)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- Create clustered index for created_at
ALTER TABLE notification ADD CONSTRAINT notification_PK PRIMARY KEY NONCLUSTERED (id_notification)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

-- Create sequence notification_seq
DROP SEQUENCE notification_seq;

CREATE SEQUENCE notification_seq START WITH 1 INCREMENT BY 1

-- Insert data into notification
DECLARE @i INTEGER
SET @i=1
WHILE @i<20001
	BEGIN
		INSERT INTO notification VALUES (NEXT VALUE FOR notification_seq,
		FLOOR(RAND()*(2-1+1)+1),
		'Notification' + cast(@i as varchar(100)),
		CONVERT(CHAR(1000), CAST(CRYPT_GEN_RANDOM(500) AS UNIQUEIDENTIFIER), 2),
		ROUND(RAND(), 0),
		DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3653), '2014-01-01'),
		null
		)
		SET @i=@i+1
	END
GO

-- Select data from notification
SELECT * FROM notification
go

--DROP TABLE order_status_has_notification;

--TRUNCATE TABLE notification;

--DROP TABLE notification;


set statistics io on

SELECT * FROM notification WHERE id_notification = 10000;
