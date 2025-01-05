--  Vytvorenie stage pre načítanie .csv súborov 
CREATE OR REPLACE STAGE my_stage;

-- Vytvorenie tabuľky album
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

--  -- Vytvorenie tabuľky trackov
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

-- -- Vytvorenie tabuľky playlisttrack
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

-- -- Vytvorenie tabuľky playlist
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

-- -- Vytvorenie tabuľky mediatype
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

-- -- Vytvorenie tabuľky invoiceline
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

-- -- Vytvorenie tabuľky invoice
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

-- Vytvorenie tabuľky genre
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

-- Vytvorenie tabuľky employee
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

-- Vytvorenie tabuľky customer
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

-- Vytvorenie tabuľky artist
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


-- Tvorba dimenzie zákazníkov
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
    c.Email,
    CURRENT_DATE() AS effective_date,  
    NULL AS expiration_date,          
    TRUE AS is_current                
FROM CUSTOMER_STAGING c;

-- Tvorba dimenzie albumov
CREATE TABLE dim_album AS
SELECT DISTINCT
    a.AlbumId AS dim_album_id,
    a.Title AS album_title,
    ar.Name AS artist_name
FROM album_staging a
LEFT JOIN artist_staging ar ON a.ArtistId = ar.ArtistId;

-- Tvorba dimenzie track
CREATE TABLE dim_track AS
SELECT DISTINCT
    t.TrackId AS dim_track_id,
    t.Name AS track_name,
    t.Composer AS composer,
    t.Milliseconds AS duration_milliseconds,
    t.Bytes AS file_size_bytes,
    t.UnitPrice AS unit_price
FROM track_staging t;

-- Tvorba dimenzie genre
CREATE TABLE dim_genre AS
SELECT DISTINCT
    g.GenreId AS dim_genre_id,
    g.Name AS genre_name
FROM genre_staging g;

-- Tvorba dimenzie media_type
CREATE TABLE dim_media_type AS
SELECT DISTINCT
    m.MediaTypeId AS dim_media_type_id,
    m.Name AS media_type_name
FROM mediatype_staging m;

-- Tvorba dimenzie playlist
CREATE TABLE dim_playlist AS
SELECT DISTINCT
    p.PlaylistId AS dim_playlist_id,
    p.Name AS playlist_name
FROM playlist_staging p;

-- Tvorba dimenzie dátumu
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

--fact_sales
CREATE TABLE fact_sales AS
SELECT 
    inv.InvoiceId AS fact_sales_id,
    inv.InvoiceDate AS invoice_date,
    inv.Total AS total_amount,
    d.dim_dateId AS dim_dateId,
    c.dim_customerId AS dim_customerId,
    tr.dim_track_id AS dim_track_id,
    g.dim_genre_id AS dim_genre_id,
    m.dim_media_type_id AS dim_media_type_id,
    p.dim_playlist_id AS dim_playlist_id,
    a.dim_album_id AS dim_album_id
FROM invoice_staging inv
JOIN dim_date d ON CAST(inv.InvoiceDate AS DATE) = d.date
JOIN dim_customers c ON inv.CustomerId = c.dim_customerId AND c.is_current = TRUE 
LEFT JOIN invoiceline_staging il ON inv.InvoiceId = il.InvoiceId
LEFT JOIN dim_track tr ON il.TrackId = tr.dim_track_id
LEFT JOIN track_staging ts ON il.TrackId = ts.TrackId
LEFT JOIN dim_genre g ON ts.GenreId = g.dim_genre_id
LEFT JOIN dim_media_type m ON ts.MediaTypeId = m.dim_media_type_id
LEFT JOIN playlisttrack_staging pts ON ts.TrackId = pts.TrackId
LEFT JOIN dim_playlist p ON pts.PlaylistId = p.dim_playlist_id
LEFT JOIN dim_album a ON ts.AlbumId = a.dim_album_id;

-- Drop stagging tables
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
