# Chinook
Tento repozitár obsahuje implementáciu ETL procesu pre Chinook databázu, zameraného na analýzu dát súvisiacich s hudobným obsahom. Projekt sa venuje skúmaniu správania používateľov a ich preferencií pri nákupe a počúvaní skladieb, pričom vychádza z histórie nákupov a ďalších dostupných údajov. Výsledný dátový model podporuje viacrozmernú analýzu a vizualizáciu dôležitých ukazovateľov.
# 1. Úvod a popis zdrojových dát
Cieľ semestrálneho projektu je analyzovať dáta týkajúce sa hudby,poslúchačov a ích nákupov. Táto analýza umožňuje odhaliť trendy v hudobných preferenciách, najobľúbenejšie skladby a správanie zákazníkov.
Dataset obsahuje:

- `1.Artist`
+ Popis: Obsahuje údaje o hudobných interpretoch, napríklad meno interpreta.
+ Význam: Slúži na identifikáciu interpretov a prepojenie s albumami, čo umožňuje analýzu populárnosti interpretov.

- `2.Album`
+ Popis: Obsahuje informácie o hudobných albumoch, vrátane názvu albumu a ID interpreta, ktorý album vytvoril.
+ Význam: Umožňuje organizáciu skladieb podľa albumov a prepojenie s interpretmi.

- `3.Track`
+ Popis: Zahŕňa detaily o jednotlivých skladbách, ako sú názov, dĺžka, cena, žáner, album a formát média.
+ Význam: Predstavuje centrálnu tabuľku pre analýzu hudobného obsahu a predajných trendov.

- `4.Genre`
+ Popis: Obsahuje názvy hudobných žánrov, ktoré sú prepojené s jednotlivými skladbami.
+ Význam: Umožňuje kategorizáciu skladieb podľa žánrov, čo je užitočné pre analýzu preferencií zákazníkov.

- `5.MediaType`
+ Popis: Obsahuje informácie o formáte skladieb (napr. MPEG, AAC).
+ Význam: Pomáha identifikovať formáty používané pri distribúcii skladieb.

- `6.Customer`
+ Popis: Obsahuje údaje o zákazníkoch, ako sú meno, adresa, telefón, email a krajina.
+ Význam: Dôležitá pre analýzu správania zákazníkov, geografických trendov a cielenie marketingu.

- `7.Invoice`
+ Popis: Obsahuje informácie o faktúrach, ako sú dátum, celková suma a zákazník, ktorý nákup uskutočnil.
+ Význam: Predstavuje záznam o jednotlivých transakciách a umožňuje analýzu predaja.

- `8.InvoiceLine`
+ Popis: Detailná tabuľka faktúr, ktorá obsahuje informácie o jednotlivých skladbách zakúpených na faktúre, vrátane ceny a množstva.
+ Význam: Prepája faktúry so skladbami a umožňuje detailnú analýzu predaja.

- `9.Playlist`
+ Popis: Obsahuje údaje o playlistoch, ako sú názvy playlistov.
+ Význam: Slúži na organizáciu skladieb do playlistov, čo môže byť užitočné pri analýze používateľských preferencií.

- `10.PlaylistTrack`
+ Popis: Prepája skladby s playlistmi, obsahuje ID skladby a ID playlistu.
+ Význam: Umožňuje sledovať, ktoré skladby sa nachádzajú v konkrétnych playlistoch.

- `11.Employee`
+ Popis: Obsahuje informácie o zamestnancoch, vrátane mena, pracovnej pozície a kontaktných údajov.
+ Význam: Používa sa na riadenie zamestnancov a ich interakcie so zákazníkmi, napríklad pri zákazníckej podpore.

Účelom ETL procesu bolo tieto dáta pripraviť, transformovať a sprístupniť pre viacdimenzionálnu analýzu.

# 1.1 Dátová architektúra
### *ERD diagram*

Surové dáta sú usporiadané v relačnom modeli, ktorý je znázornený na entitno-relačnom diagrame (ERD):
<p align="center">
  <img src="https://github.com/user-attachments/assets/de87b1ff-3ea9-4710-92c1-8a377dc0a4be" alt="ERD Schema">
  <br>
  <em>Obrázok 1 Entitno-relačná schéma Chinook</em>
</p>

# 2.Dimenzonálny model
Navrhnutý bol hviezdicový model, pre efektívnu analýzu kde centrálny bod predstavuje faktová tabuľka `fact_sales`, ktorá je prepojená s nasledujúcimi dimenziami:

- `Dim_Track`: Obsahuje informácie o skladbách, ako sú názov, dĺžka, album, interpret a podobne.
- `Dim_Genre`: Obsahuje demografické údaje o používateľoch, ako sú vekové kategórie, pohlavie, povolanie a vzdelanie.
- `Dim_Date`: Zahrňuje informácie o dátumoch hodnotení ako deň, mesiac, rok, štvrťrok.
- `Dim_Time`: Obsahuje podrobné časové údaje hodina, AM/PM.
- `Dim_Customer`: Obsahuje údaje o zákazníkoch, ako sú meno, krajina, pohlavie, typ predplatného a ďalšie.
- `Dim_MediaType`: Obsahuje informácie o type média, ako je MP3, WAV, atď.
  
Štruktúra hviezdicového modelu je znázornená na diagrame nižšie. Diagram ukazuje prepojenia medzi faktovou tabuľkou a dimenziami, čo zjednodušuje pochopenie a implementáciu modelu.
<p align="center">
  <img src="https://github.com/user-attachments/assets/e54ffd8b-e20d-4991-ba5f-a675ffc7275e" alt="Star Schema">
  <br>
  <em>Obrázok 2 Schéma hviezdy pre Chinook</em>
</p>

  
# 3. ETL proces v Snowflake
Proces ETL je rozdelený do troch základných krokov: `extrakcia` (Extract), `transformácia` (Transform) a `načítanie` (Load). Tento postup je realizovaný v Snowflake, aby sa zdrojové dáta zo staging vrstvy spracovali a pripravili na analytické a vizualizačné účely v rámci viacdimenzionálneho modelu.
# 3.1 Extract
Pôvodné dáta v formáte .csv boli najprv importované do Snowflake pomocou interného stage úložiska s názvom `my_stage`. V Snowflake slúži stage ako dočasný priestor na nahrávanie alebo sťahovanie dát. Stage bol vytvorený pomocou nasledovného príkazu:
```sql
CREATE OR REPLACE STAGE my_stage;
```

Do stage boli následne nahraté súbory obsahujúce údaje o knihách, používateľoch, hodnoteniach, zamestnaniach a úrovniach vzdelania. Dáta boli importované do staging tabuliek pomocou príkazu `COPY INTO`. Pre každú tabuľku sa použil podobný príkaz:
```sql
COPY INTO album_staging
FROM @my_stage/album.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';
```

V prípade nekonzistentných záznamov bol použitý parameter **`ON_ERROR = 'CONTINUE'`**, ktorý zabezpečil pokračovanie procesu bez prerušenia pri chybách. Tento prístup umožnil spracovať všetky riadky aj v prípade, že niektoré údaje neboli správne naformátované alebo obsahovali neštandardné hodnoty, čím sa minimalizovalo riziko prerušenia ETL procesu.

Okrem toho bol použitý parameter **`FIELD_OPTIONALLY_ENCLOSED_BY`**, ktorý zabezpečuje, že hodnoty v CSV súboroch môžu byť obklopené úvodzovkami. Tento parameter je dôležitý pre spracovanie údajov, ktoré môžu obsahovať oddeľovače (napr. čiarky), pričom obklopenie hodnôt úvodzovkami zabraňuje nesprávnemu rozdeleniu údajov do stĺpcov.

Na zabezpečenie plynulého načítania dát bol tiež použitý parameter **`ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE`**, ktorý umožňuje pokračovanie procesu aj v prípade, že počet stĺpcov v niektorých riadkoch CSV súboru nevyhovuje počtu stĺpcov v cieľovej tabuľke. Tento parameter bol nastavený tak, aby sa vyhli prerušeniam spracovania pri nezrovnalostiach v počte stĺpcov, čím sa zabezpečilo, že proces bude pokračovať a spracuje všetky dostupné dáta.
# 3.2 Transfor
V tejto fáze boli dáta zo staging tabuliek vyčistené, transformované a obohatené. Hlavným cieľom bolo pripraviť dimenzie a faktovú tabuľku, ktoré umožnia jednoduchú a efektívnu analýzu.

Analyzoval som predaj skladieb a zameral som sa na to, ktoré žánre a typy médií sú medzi zákazníkmi najobľúbenejšie. Chcel som získať prehľad o tom, ako zákazníci nakupujú hudbu na základe rôznych faktorov, ako sú typ skladby, album, žáner a čas nákupu. Skúmal som, ktoré skladby a albumy sa najviac predávajú a ako sa tieto predaje menia v závislosti od obdobia. Na analýzu som použil dimenzionálny model typu hviezda, kde som prepojil dimenzionálne tabuľky so faktovou tabuľkou predajov. Týmto spôsobom som získal komplexný obraz o preferenciách zákazníkov a trendoch v predaji hudby.

1. `dim_customers`
 + Typ SCD(Slowly Changing Dimension): Typ 2 (Uchovávanie histórie)
   + Dôvod: Zákazníci môžu meniť svoje údaje (ako adresu alebo telefónne číslo), a preto je dôležité uchovávať historické záznamy. SCD Type 2 nám umožňuje sledovať tieto zmeny ako nové záznamy a uchovať historické dáta.
 + Táto tabuľka obsahuje informácie o zákazníkoch. Skladá sa z identifikátora zákazníka (dim_customerId), mena (full_name), adresy, mesta, štátu, krajiny, poštového kódu, telefónneho čísla a emailu. Tento dátový model umožňuje efektívne spracovávať a analyzovať údaje o zákazníkoch.
```sql
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
```
2. `dim_tracks`
+ Typ SCD(Slowly Changing Dimension): Typ 2 (Uchovávanie histórie)
  + Dôvod: Skladby môžu meniť svoje atribúty (napr. cenu, album alebo žáner), a tieto zmeny chceme uchovávať v historických dátach. SCD Type 2 nám umožňuje zaznamenávať tieto zmeny a zachovať historické verzie skladieb.
+ Táto tabuľka obsahuje informácie o skladbách. Zahŕňa identifikátor skladby (dim_trackId), názov skladby (track_name), identifikátor albumu (AlbumId), názov albumu (album_name), žáner (genre_name), typ média (media_type) a cenu za jednotku (UnitPrice). Táto tabuľka je užitočná na analýzu predaja skladieb na základe rôznych atribútov ako je album, žáner, či typ média.
```sql
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

```
3. `dim_date`
+ Typ SCD(Slowly Changing Dimension): Typ 1 (Prepisovanie)
  + Dôvod: Dátumy sú statické a nemenné, takže nie je potrebné uchovávať historické verzie dátumov. SCD Type 1 sa používa na aktualizáciu dát bez uchovávania histórie.
+ Táto tabuľka obsahuje informácie o dátumoch. Každý záznam má jedinečný identifikátor (dim_dateId) a zobrazuje rôzne časové aspekty: deň (day), deň v týždni (dayOfWeek), názov dňa (dayOfWeekAsString), mesiac (month), rok (year) a kvartál (quarter). Je kľúčová pre analýzu predaja na základe času a pre agregovanie dát podľa rôznych časových jednotiek.
```sql
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

```
4. `dim_genres_media`
+ Typ SCD(Slowly Changing Dimension): Typ 1 (Prepisovanie)
  + Dôvod: Žánre a typy médií sa zvyčajne nemenia, a ak sa zmena vyskytne, nebude potrebné uchovávať staré hodnoty. SCD Type 1 je vhodný na prepisovanie týchto údajov bez uchovávania historických zmien.
+ Táto tabuľka obsahuje kombináciu informácií o žánroch a typoch médií. Pre každý žáner (dim_genreId) je spojený s médiom (dim_mediaTypeId), čo umožňuje analyzovať predaje podľa žánru a typu média, ako sú napríklad rôzne formáty (mp3, CD, atď.).
```sql
CREATE TABLE dim_genres_media AS
SELECT DISTINCT
    gs.GenreId AS dim_genreId,
    gs.Name AS genre_name,
    mts.MediaTypeId AS dim_mediaTypeId,
    mts.Name AS media_type
FROM GENRE_STAGING gs
JOIN MEDIATYPE_STAGING mts ON gs.GenreId = mts.MediaTypeId;

```
5. `fact_sales`
+ Typ SCD(Slowly Changing Dimension): Typ 1 (Prepisovanie)
  + Dôvod: Faktové tabuľky obsahujú transakčné údaje, ktoré po vložení už nebudú upravované. SCD Type 1 sa používa, keď nie je potrebné uchovávať historické údaje a každá transakcia je samostatný záznam.
    
***Primárne kľúče a cudzie kľúče***
   
`fact_salesId` (Primárny kľúč)
+ Popis: Identifikuje každý záznam v tabuľke. Zvyčajne je unikátny pre každú faktovú transakciu.
+ Zdroj: InvoiceLineId z tabuľky INVOICELINE_STAGING.
  
`dim_customerId` (Cudzí kľúč)
+ Popis: Referencia na dimenziu zákazníka, identifikuje, ktorý zákazník uskutočnil predaj.
+ Zdroj: CustomerId z tabuľky INVOICE_STAGING.
  
`dim_trackId` (Cudzí kľúč)
+ Popis: Referencia na dimenziu skladby, identifikuje predanú skladbu.
+ Zdroj: TrackId z tabuľky INVOICELINE_STAGING.
  
`dateID` (Cudzí kľúč)
+ Popis: Referencia na dimenziu dátumu, umožňuje analýzu podľa dátumu predaja.
+ Zdroj: Vygenerované prepojením InvoiceDate s dimenziou dim_date.
  
`media_type` (Cudzí kľúč)
+ Popis: Identifikuje typ média skladby (napr. digitálne, CD).
+ Zdroj: MediaTypeId z tabuľky TRACK_STAGING.
  
`genre_id` (Cudzí kľúč)
+ Popis: Referencia na dimenziu žánru skladby.
+ Zdroj: GenreId z tabuľky GENRE_STAGING.

***Metriky***

`total_amount`
+ Popis: Celková suma predaja pre daný záznam (jednotková cena × množstvo). Táto metrika umožňuje sledovať tržby.
+ Zdroj: Výpočet: UnitPrice * Quantity.
  
`quantity_sold`
+ Popis: Počet predaných kusov skladby pre daný záznam.
+ Zdroj: Quantity z tabuľky INVOICELINE_STAGING.

***Dôležitosť pre analýzu***

`Analýza predaja podľa zákazníkov`
Pomocou dim_customerId možno sledovať nákupné správanie jednotlivých zákazníkov.

`Analýza predaja podľa skladieb a žánrov`
dim_trackId a genre_id umožňujú zistiť, ktoré skladby a žánre sú najpredávanejšie.

`Analýza podľa času`
sale_date a dateID umožňujú sledovať trendy predaja v čase (denne, týždenne, mesačne, ročne).

`Segmentácia podľa typu média`
media_type poskytuje možnosť analyzovať, ktoré typy médií sú populárne.

`Výpočet výnosov a predajných trendov`
Metriky total_amount a quantity_sold slúžia na sledovanie výnosov a objemu predaja.

**Táto faktová tabuľka je navrhnutá tak, aby podporovala rôzne pohľady na predaje a umožňovala analýzy, ako je hodnotenie tržieb, identifikácia populárnych skladieb a zákazníckych preferencií v rôznych časových obdobiach.**
  ```sql
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
```
# 3.3 Load

Po úspešnom vytvorení dimenzií a faktovej tabuľky boli dáta prenesené do finálnej štruktúry. Na záver boli staging tabuľky vymazané s cieľom optimalizovať využitie úložného priestoru.

```sql
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
```

ETL proces v Snowflake umožnil transformáciu pôvodných dát z formátu `.csv` do viacdimenzionálneho modelu typu hviezda. Tento proces zahŕňal kroky čistenia, obohacovania a reorganizácie dát. Výsledný model poskytuje základ pre analýzu čitateľských preferencií a správania používateľov, čím zároveň vytvára predpoklady pre tvorbu vizualizácií a reportov.

# 4 Vizualizácia dát
Tento dashboard ponúka komplexný prehľad o predajoch a správaní zákazníkov. Identifikácia trendov v predaji, obľúbených formátov médií a preferencií podľa žánrov umožňuje lepšie rozhodovanie o budúcich stratégiách.

<p align="center">
  <img src="https://github.com/user-attachments/assets/1a0c1ab7-85b9-43cb-a2d9-2abe207f7148" alt="ERD Schema">
  <br>
  <em>Obrázok 3 Dashboard Chinook datasetu</em>
</p>

---
### **Graf 1: Najviac hodnotené knihy (Top 10 kníh)**
Vizualizácia zobrazuje 10 krajín s najvyšším objemom predajov. Umožňuje identifikovať najvýznamnejšie trhy a zameranie sa na ne v marketingových alebo predajných stratégiách. Graf jasne ukazuje, ktoré krajiny generujú najväčší objem predajov, čo môže byť užitočné pri plánovaní distribúcie a lokalizácie produktov.

```sql
SELECT 
    c.Country AS country,
    SUM(fs.total_amount) AS total_sales
FROM fact_sales fs
JOIN dim_customers c ON fs.dim_customerId = c.dim_customerId
GROUP BY c.Country
ORDER BY total_sales DESC
LIMIT 10;
```
---
### **Graf 2: Predaje podľa žánrov**
Vizualizácia zobrazuje predaje rozdelené podľa jednotlivých hudobných žánrov. Pomáha identifikovať najpopulárnejšie žánre, ktoré generujú najväčšie tržby. Výstup ukazuje, aké sú preferencie zákazníkov, a môže byť využitý pri tvorbe marketingových kampaní alebo optimalizácii ponuky.
```sql
SELECT 
    g.genre_name AS genre,
    SUM(fs.total_amount) AS total_sales
FROM fact_sales fs
JOIN dim_tracks t ON fs.dim_trackId = t.dim_trackId
JOIN dim_genres_media g ON t.GenreId = g.dim_genreId
GROUP BY g.genre_name
ORDER BY total_sales DESC;
```
---
### **Graf 3: Trend zákazníkov a transakcií za posledných 5 rokov**
Vizualizácia sleduje počet unikátnych zákazníkov a celkový počet transakcií za posledných 5 rokov. Umožňuje identifikovať trendy v zákazníckom správaní a objeme transakcií v priebehu času, čo môže pomôcť pochopiť dynamiku trhu.
```sql
SELECT 
    d.year,
    COUNT(DISTINCT fs.dim_customerId) AS unique_customers,
    COUNT(fs.fact_salesId) AS total_transactions
FROM fact_sales fs
JOIN dim_date d ON fs.dateID = d.dim_dateId
WHERE d.year BETWEEN YEAR(CURRENT_DATE) - 5 AND YEAR(CURRENT_DATE)
GROUP BY d.year
ORDER BY d.year;
```
---
### **Graf 4: Top 5 zákazníkov podľa predajov v roku 2024**
Vizualizácia zobrazuje päť najvýznamnejších zákazníkov podľa celkového objemu predajov v roku 2024. Umožňuje identifikovať kľúčových zákazníkov, ktorí prispeli najväčšou sumou k tržbám.
```sql
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
```
---
### **Graf 5: Predaje podľa mediálnych formátov v kvartáloch počas COVID-u (2020–2022)**
Vizualizácia zobrazuje rozdelenie predajov podľa rôznych mediálnych formátov počas jednotlivých kvartálov rokov 2020 až 2022, čo pokrýva obdobie pandémie COVID-19. Umožňuje analyzovať preferencie zákazníkov počas tohto špecifického obdobia.
```sql
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

```
Dashboard poskytuje komplexný prehľad o kľúčových dátach, ktoré odhaľujú preferencie a správanie zákazníkov. Vizualizácie umožňujú jednoduchú interpretáciu informácií a identifikáciu dôležitých trendov. Tieto poznatky môžu byť využité na zlepšenie odporúčacích systémov a marketingových stratégií. Okrem toho pomáhajú prispôsobiť ponuku zákazníkom a zlepšiť poskytované služby.

---
**AUTOR: Jakub Šášik**
