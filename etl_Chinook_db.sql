-- Vytvorenie stage pre načítanie .csv súborov
CREATE OR REPLACE STAGE my_stage;

-- Vytvorenie staging tabuľky pre albumy
CREATE OR REPLACE TABLE album_staging (
    AlbumId INT,
    Title STRING,
    ArtistId INT
);

-- Načítanie dát zo súboru album.csv do staging tabuľky
COPY INTO album_staging
FROM @my_stage/album.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre skladby
CREATE OR REPLACE TABLE track_staging (
    TrackId INT,
    Name STRING,
    AlbumId INT,
    MediaTypeId INT,
    GenreId INT,
    Composer STRING,
    Milliseconds INT,
    Bytes INT,
    UnitPrice FLOAT
);

-- Načítanie dát zo súboru track.csv do staging tabuľky
COPY INTO track_staging
FROM @my_stage/track.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre playlisty skladieb
CREATE OR REPLACE TABLE playlisttrack_staging (
    PlaylistId INT,
    TrackId INT
);

-- Načítanie dát zo súboru playlisttrack.csv do staging tabuľky
COPY INTO playlisttrack_staging
FROM @my_stage/playlisttrack.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre playlisty
CREATE OR REPLACE TABLE playlist_staging (
    PlaylistId INT,
    Name STRING
);

-- Načítanie dát zo súboru playlist.csv do staging tabuľky
COPY INTO playlist_staging
FROM @my_stage/playlist.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre typy médií
CREATE OR REPLACE TABLE mediatype_staging (
    MediaTypeId INT,
    Name STRING
);

-- Načítanie dát zo súboru mediatype.csv do staging tabuľky
COPY INTO mediatype_staging
FROM @my_stage/mediatype.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre faktúry
CREATE OR REPLACE TABLE invoiceline_staging (
    InvoiceLineId INT,
    InvoiceId INT,
    TrackId INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT
);

-- Načítanie dát zo súboru invoiceline.csv do staging tabuľky
COPY INTO invoiceline_staging
FROM @my_stage/invoiceline.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre faktúry
CREATE OR REPLACE TABLE invoice_staging (
    InvoiceId INT,
    CustomerId INT,
    InvoiceDate TIMESTAMP_LTZ,
    BillingAddress STRING,
    BillingCity STRING,
    BillingState STRING,
    BillingCountry STRING,
    BillingPostalCode STRING,
    Total DECIMAL(10, 2)
);

-- Načítanie dát zo súboru invoice.csv do staging tabuľky
COPY INTO invoice_staging
FROM @my_stage/invoice.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre žánre
CREATE OR REPLACE TABLE genre_staging (
    GenreId INT,
    Name STRING
);

-- Načítanie dát zo súboru genre.csv do staging tabuľky
COPY INTO genre_staging
FROM @my_stage/genre.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre zamestnancov
CREATE OR REPLACE TABLE employee_staging (
    EmployeeId INT,
    LastName STRING,
    FirstName STRING,
    Title STRING,
    ReportsTo INT,
    BirthDate DATE,
    HireDate DATE,
    Address STRING,
    City STRING,
    State STRING,
    Country STRING,
    PostalCode STRING,
    Phone STRING,
    Fax STRING,
    Email STRING
);

-- Načítanie dát zo súboru employee.csv do staging tabuľky
COPY INTO employee_staging
FROM @my_stage/employee.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    NULL_IF = ('NULL')
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre zákazníkov
CREATE OR REPLACE TABLE customer_staging (
    CustomerId INT,
    FirstName STRING,
    LastName STRING,
    Company STRING,
    Address STRING,
    City STRING,
    State STRING,
    Country STRING,
    PostalCode STRING,
    Phone STRING,
    Fax STRING,
    Email STRING,
    SupportRepId INT
);

-- Načítanie dát zo súboru customer.csv do staging tabuľky
COPY INTO customer_staging
FROM @my_stage/customer.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie staging tabuľky pre umelcov
CREATE OR REPLACE TABLE artist_staging (
    ArtistId INT,
    Name STRING
);

-- Načítanie dát zo súboru artist.csv do staging tabuľky
COPY INTO artist_staging
FROM @my_stage/artist.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vytvorenie dimenzií a faktových tabuliek

-- Dimenzia zákazníkov
CREATE TABLE dim_customers AS
SELECT DISTINCT
    c.CUSTOMERID AS dim_customerId,
    c.FirstName || ' ' || c.LastName AS full_name,
    c.Address,
    c.City,
    c.State,
    c.Country,
    c.PostalCode,
    c.Phone,
    c.Email
FROM CUSTOMER_STAGING c;

-- Dimenzia skladieb
CREATE TABLE dim_tracks AS
SELECT DISTINCT
    ts.TrackId AS dim_trackId,
    ts.Name AS track_name,
    ts.AlbumId,
    a.Title AS album_name,
    ts.GenreId,
    g.Name AS genre_name,
    ts.MediaTypeId,
    mt.Name AS media_type,
    ts.UnitPrice
FROM TRACK_STAGING ts
LEFT JOIN ALBUM_STAGING a ON ts.AlbumId = a.AlbumId
LEFT JOIN GENRE_STAGING g ON ts.GenreId = g.GenreId
LEFT JOIN MEDIATYPE_STAGING mt ON ts.MediaTypeId = mt.MediaTypeId;

-- Dimenzia dátumu
CREATE TABLE dim_date AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY CAST(inv.InvoiceDate AS DATE)) AS dim_dateId,
    CAST(inv.InvoiceDate AS DATE) AS date,
    DATE_PART(day, inv.InvoiceDate) AS day,
    DATE_PART(dow, inv.InvoiceDate) + 1 AS dayOfWeek,
    CASE DATE_PART(dow, inv.InvoiceDate) + 1
        WHEN 1 THEN 'Pondelok'
        WHEN 2 THEN 'Utorok'
        WHEN 3 THEN 'Streda'
        WHEN 4 THEN 'Štvrtok'
        WHEN 5 THEN 'Piatok'
        WHEN 6 THEN 'Sobota'
        WHEN 7 THEN 'Nedeľa'
    END AS dayOfWeekAsString,
    DATE_PART(month, inv.InvoiceDate) AS month,
    DATE_PART(year, inv.InvoiceDate) AS year,
    DATE_PART(quarter, inv.InvoiceDate) AS quarter
FROM INVOICE_STAGING inv;

-- Dimenzia žánrov a médií
CREATE TABLE dim_genres_media AS
SELECT DISTINCT
    gs.GenreId AS dim_genreId,
    gs.Name AS genre_name,
    mts.MediaTypeId AS dim_mediaTypeId,
    mts.Name AS media_type
FROM GENRE_STAGING gs
JOIN MEDIATYPE_STAGING mts ON gs.GenreId = mts.MediaTypeId;

-- Faktová tabuľka predajov
CREATE TABLE fact_sales AS
SELECT 
    il.InvoiceLineId AS fact_salesId,
    i.CustomerId AS dim_customerId,
    il.TrackId AS dim_trackId,
    CAST(i.InvoiceDate AS DATE) AS sale_date,
    dd.dim_dateId AS dateID,
    il.UnitPrice * il.Quantity AS total_amount,
    il.Quantity AS quantity_sold,
    t.MediaTypeId AS media_type,
    g.GenreId AS genre_id
FROM INVOICELINE_STAGING il
JOIN INVOICE_STAGING i ON il.InvoiceId = i.InvoiceId
JOIN dim_date dd ON CAST(i.InvoiceDate AS DATE) = dd.date
JOIN TRACK_STAGING t ON il.TrackId = t.TrackId
JOIN GENRE_STAGING g ON t.GenreId = g.GenreId;

-- Odstránenie staging tabuliek po transformáciách
DROP TABLE IF EXISTS CUSTOMER_STAGING;
DROP TABLE IF EXISTS TRACK_STAGING;
DROP TABLE IF EXISTS GENRE_STAGING;
DROP TABLE IF EXISTS ALBUM_STAGING;
DROP TABLE IF EXISTS MEDIATYPE_STAGING;
DROP TABLE IF EXISTS INVOICE_STAGING;
DROP TABLE IF EXISTS INVOICELINE_STAGING;
DROP TABLE IF EXISTS ARTIST_STAGING;
DROP TABLE IF EXISTS EMPLOYEE_STAGING;
DROP TABLE IF EXISTS PLAYLIST_STAGING;
DROP TABLE IF EXISTS PLAYLISTTRACK_STAGING;
