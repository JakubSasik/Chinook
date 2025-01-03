-- Graf 1: Predaje podľa krajín – Top 10
SELECT 
    c.Country AS country,
    SUM(fs.total_amount) AS total_sales
FROM fact_sales fs
JOIN dim_customers c ON fs.dim_customerId = c.dim_customerId
GROUP BY c.Country
ORDER BY total_sales DESC
LIMIT 10;


-- Graf 2: Predaje podľa žánrov
SELECT 
    g.genre_name AS genre,
    SUM(fs.total_amount) AS total_sales
FROM fact_sales fs
JOIN dim_tracks t ON fs.dim_trackId = t.dim_trackId
JOIN dim_genres_media g ON t.GenreId = g.dim_genreId
GROUP BY g.genre_name
ORDER BY total_sales DESC;

-- Graf 3: Trend predajov v čase
SELECT 
    d.year,
    COUNT(DISTINCT fs.dim_customerId) AS unique_customers,
    COUNT(fs.fact_salesId) AS total_transactions
FROM fact_sales fs
JOIN dim_date d ON fs.dateID = d.dim_dateId
WHERE d.year BETWEEN YEAR(CURRENT_DATE) - 5 AND YEAR(CURRENT_DATE)
GROUP BY d.year
ORDER BY d.year;

-- Graf 4: Top 5 zákazníkov podľa celkových predajov v roku 2024
SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(fs.total_amount) DESC) AS rank,
    c.full_name,
    SUM(fs.total_amount) AS total_sales
FROM fact_sales fs
JOIN dim_customers c ON fs.dim_customerId = c.dim_customerId
JOIN dim_date d ON fs.dateID = d.dim_dateId
WHERE d.year = 2024
GROUP BY c.full_name
ORDER BY total_sales DESC
LIMIT 5;

-- Graf 5: Predaje podľa mediálnych formátov v kvartáloch počas covidu
SELECT 
    d.quarter, 
    m.media_type, 
    SUM(fs.total_amount) AS total_sales
FROM fact_sales fs
JOIN dim_genres_media m ON fs.media_type = m.dim_mediaTypeId
JOIN dim_date d ON fs.dateID = d.dim_dateId
WHERE d.year BETWEEN 2020 AND 2022
GROUP BY d.quarter, m.media_type
ORDER BY d.quarter, m.media_type;
