USE systemy_bazodanowe
GO

-- 1. Tworzenie grup plików dla każdej partycji (ostatnie 4 lata)
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_Orders_2021')
    ALTER DATABASE systemy_bazodanowe ADD FILEGROUP [FG_Orders_2021];
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_Orders_2022')
    ALTER DATABASE systemy_bazodanowe ADD FILEGROUP [FG_Orders_2022];
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_Orders_2023')
    ALTER DATABASE systemy_bazodanowe ADD FILEGROUP [FG_Orders_2023];
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_Orders_2024')
    ALTER DATABASE systemy_bazodanowe ADD FILEGROUP [FG_Orders_2024];
GO

-- 2. Dodawanie plików do każdej grupy plików
-- Używamy ścieżki do katalogu DATA bazy danych
DECLARE @DataPath NVARCHAR(256);
SELECT @DataPath = physical_name 
FROM sys.database_files 
WHERE file_id = 1;

SET @DataPath = LEFT(@DataPath, LEN(@DataPath) - CHARINDEX('\', REVERSE(@DataPath))) + '\Orders_Data\';

-- Tworzenie katalogu jeśli nie istnieje
DECLARE @CreateDirCmd NVARCHAR(4000) = 'IF NOT EXISTS (SELECT 1 FROM sys.dm_os_file_exists(''' + @DataPath + ''')) EXEC xp_cmdshell ''mkdir "' + @DataPath + '"''';
EXEC sp_executesql @CreateDirCmd;
GO

-- 2021
DECLARE @DataPath2021 NVARCHAR(256);
SELECT @DataPath2021 = physical_name 
FROM sys.database_files 
WHERE file_id = 1;
SET @DataPath2021 = LEFT(@DataPath2021, LEN(@DataPath2021) - CHARINDEX('\', REVERSE(@DataPath2021))) + '\Orders_Data\';

IF NOT EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'Orders_2021_Data')
BEGIN
    DECLARE @SQL2021 NVARCHAR(MAX) = 'ALTER DATABASE systemy_bazodanowe 
    ADD FILE (
        NAME = N''Orders_2021_Data'',
        FILENAME = ''' + @DataPath2021 + 'Orders_2021_Data.ndf'',
        SIZE = 100MB,
        MAXSIZE = UNLIMITED,
        FILEGROWTH = 100MB
    ) TO FILEGROUP [FG_Orders_2021]';
    EXEC sp_executesql @SQL2021;
END
GO

-- 2022
DECLARE @DataPath2022 NVARCHAR(256);
SELECT @DataPath2022 = physical_name 
FROM sys.database_files 
WHERE file_id = 1;
SET @DataPath2022 = LEFT(@DataPath2022, LEN(@DataPath2022) - CHARINDEX('\', REVERSE(@DataPath2022))) + '\Orders_Data\';

IF NOT EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'Orders_2022_Data')
BEGIN
    DECLARE @SQL2022 NVARCHAR(MAX) = 'ALTER DATABASE systemy_bazodanowe 
    ADD FILE (
        NAME = N''Orders_2022_Data'',
        FILENAME = ''' + @DataPath2022 + 'Orders_2022_Data.ndf'',
        SIZE = 100MB,
        MAXSIZE = UNLIMITED,
        FILEGROWTH = 100MB
    ) TO FILEGROUP [FG_Orders_2022]';
    EXEC sp_executesql @SQL2022;
END
GO

-- 2023
DECLARE @DataPath2023 NVARCHAR(256);
SELECT @DataPath2023 = physical_name 
FROM sys.database_files 
WHERE file_id = 1;
SET @DataPath2023 = LEFT(@DataPath2023, LEN(@DataPath2023) - CHARINDEX('\', REVERSE(@DataPath2023))) + '\Orders_Data\';

IF NOT EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'Orders_2023_Data')
BEGIN
    DECLARE @SQL2023 NVARCHAR(MAX) = 'ALTER DATABASE systemy_bazodanowe 
    ADD FILE (
        NAME = N''Orders_2023_Data'',
        FILENAME = ''' + @DataPath2023 + 'Orders_2023_Data.ndf'',
        SIZE = 100MB,
        MAXSIZE = UNLIMITED,
        FILEGROWTH = 100MB
    ) TO FILEGROUP [FG_Orders_2023]';
    EXEC sp_executesql @SQL2023;
END
GO

-- 2024
DECLARE @DataPath2024 NVARCHAR(256);
SELECT @DataPath2024 = physical_name 
FROM sys.database_files 
WHERE file_id = 1;
SET @DataPath2024 = LEFT(@DataPath2024, LEN(@DataPath2024) - CHARINDEX('\', REVERSE(@DataPath2024))) + '\Orders_Data\';

IF NOT EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'Orders_2024_Data')
BEGIN
    DECLARE @SQL2024 NVARCHAR(MAX) = 'ALTER DATABASE systemy_bazodanowe 
    ADD FILE (
        NAME = N''Orders_2024_Data'',
        FILENAME = ''' + @DataPath2024 + 'Orders_2024_Data.ndf'',
        SIZE = 100MB,
        MAXSIZE = UNLIMITED,
        FILEGROWTH = 100MB
    ) TO FILEGROUP [FG_Orders_2024]';
    EXEC sp_executesql @SQL2024;
END
GO

-- 3. Usuwanie istniejących indeksów i ograniczeń
-- Najpierw usuwamy nieklastrowany indeks
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'order_id_idx' AND object_id = OBJECT_ID('order'))
    DROP INDEX order_id_idx ON [order];
GO

-- Następnie usuwamy ograniczenie PRIMARY KEY
IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_order' AND parent_object_id = OBJECT_ID('order'))
BEGIN
    ALTER TABLE [order] DROP CONSTRAINT PK_order;
END
GO

-- Usuwamy istniejący indeks klastrowany jeśli istnieje
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'order_part_PK' AND object_id = OBJECT_ID('order'))
BEGIN
    DROP INDEX order_part_PK ON [order];
END
GO

-- 4. Usuwanie istniejącego schematu partycji (jeśli istnieje)
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_Order_By_Year')
    DROP PARTITION SCHEME PS_Order_By_Year;
GO

-- 5. Usuwanie istniejącej funkcji partycji (jeśli istnieje)
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'PF_Order_By_Year')
    DROP PARTITION FUNCTION PF_Order_By_Year;
GO

-- 6. Tworzenie funkcji partycji
CREATE PARTITION FUNCTION PF_Order_By_Year (DATETIME)
AS RANGE RIGHT FOR VALUES (
    '2021-01-01',
    '2022-01-01',
    '2023-01-01',
    '2024-01-01'
);
GO

-- 7. Tworzenie schematu partycji z określonymi grupami plików
CREATE PARTITION SCHEME PS_Order_By_Year
AS PARTITION PF_Order_By_Year
TO (
    [PRIMARY],           -- dla danych starszych niż 2021
    [FG_Orders_2021],    -- dla danych z 2021
    [FG_Orders_2022],    -- dla danych z 2022
    [FG_Orders_2023],    -- dla danych z 2023
    [FG_Orders_2024]     -- dla danych z 2024 i nowszych
);
GO

-- 8. Tworzenie nowego partycjonowanego indeksu
CREATE NONCLUSTERED INDEX order_part_PK 
ON [order] (created_at)
ON PS_Order_By_Year(created_at);
GO

-- 9. Dodawanie nieklastrowanego indeksu na id_order
CREATE UNIQUE NONCLUSTERED INDEX order_id_idx
ON [order] (id_order);
GO

-- 10. Wyświetlanie informacji o partycjach
SELECT 
    p.partition_number AS 'Numer partycji',
    fg.name AS 'Grupa plików',
    rv.value AS 'Wartość graniczna',
    p.rows AS 'Liczba wierszy',
    au.total_pages AS 'Całkowita liczba stron',
    au.used_pages AS 'Użyte strony'
FROM sys.partitions p
INNER JOIN sys.destination_data_spaces dds
    ON p.partition_number = dds.destination_id
INNER JOIN sys.filegroups fg
    ON dds.data_space_id = fg.data_space_id
INNER JOIN sys.partition_schemes ps
    ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN sys.partition_functions pf
    ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values rv
    ON pf.function_id = rv.function_id
    AND p.partition_number = rv.boundary_id
INNER JOIN sys.allocation_units au
    ON p.hobt_id = au.container_id
WHERE p.object_id = OBJECT_ID('order')
ORDER BY p.partition_number;
GO 