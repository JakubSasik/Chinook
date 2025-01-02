# Chinook
Tento repozitár obsahuje implementáciu ETL procesu pre Chinook databázu, zameraného na analýzu dát súvisiacich s hudobným obsahom. Projekt sa venuje skúmaniu správania používateľov a ich preferencií pri nákupe a počúvaní skladieb, pričom vychádza z histórie nákupov a ďalších dostupných údajov. Výsledný dátový model podporuje viacrozmernú analýzu a vizualizáciu dôležitých ukazovateľov.
# 1. Úvod a popis zdrojových dát
Cieľ semestrálneho projektu je analyzovať dáta týkajúce sa hudby,poslúchačov a ích nákupov. Táto analýza umožňuje odhaliť trendy v hudobných preferenciách, najobľúbenejšie skladby a správanie zákazníkov.
Dataset obsahuje:

- 1.Artist
Popis: Obsahuje údaje o hudobných interpretoch, napríklad meno interpreta.
Význam: Slúži na identifikáciu interpretov a prepojenie s albumami, čo umožňuje analýzu populárnosti interpretov.

- 2.Album
Popis: Obsahuje informácie o hudobných albumoch, vrátane názvu albumu a ID interpreta, ktorý album vytvoril.
Význam: Umožňuje organizáciu skladieb podľa albumov a prepojenie s interpretmi.

- 3.Track
Popis: Zahŕňa detaily o jednotlivých skladbách, ako sú názov, dĺžka, cena, žáner, album a formát média.
Význam: Predstavuje centrálnu tabuľku pre analýzu hudobného obsahu a predajných trendov.

- 4.Genre
Popis: Obsahuje názvy hudobných žánrov, ktoré sú prepojené s jednotlivými skladbami.
Význam: Umožňuje kategorizáciu skladieb podľa žánrov, čo je užitočné pre analýzu preferencií zákazníkov.

- 5.MediaType
Popis: Obsahuje informácie o formáte skladieb (napr. MPEG, AAC).
Význam: Pomáha identifikovať formáty používané pri distribúcii skladieb.

- 6.Customer
Popis: Obsahuje údaje o zákazníkoch, ako sú meno, adresa, telefón, email a krajina.
Význam: Dôležitá pre analýzu správania zákazníkov, geografických trendov a cielenie marketingu.

- 7.Invoice
Popis: Obsahuje informácie o faktúrach, ako sú dátum, celková suma a zákazník, ktorý nákup uskutočnil.
Význam: Predstavuje záznam o jednotlivých transakciách a umožňuje analýzu predaja.

- 8.InvoiceLine
Popis: Detailná tabuľka faktúr, ktorá obsahuje informácie o jednotlivých skladbách zakúpených na faktúre, vrátane ceny a množstva.
Význam: Prepája faktúry so skladbami a umožňuje detailnú analýzu predaja.

- 9.Playlist
Popis: Obsahuje údaje o playlistoch, ako sú názvy playlistov.
Význam: Slúži na organizáciu skladieb do playlistov, čo môže byť užitočné pri analýze používateľských preferencií.

- 10.PlaylistTrack
Popis: Prepája skladby s playlistmi, obsahuje ID skladby a ID playlistu.
Význam: Umožňuje sledovať, ktoré skladby sa nachádzajú v konkrétnych playlistoch.

- 11.Employee
Popis: Obsahuje informácie o zamestnancoch, vrátane mena, pracovnej pozície a kontaktných údajov.
Význam: Používa sa na riadenie zamestnancov a ich interakcie so zákazníkmi, napríklad pri zákazníckej podpore.

Účelom ETL procesu bolo tieto dáta pripraviť, transformovať a sprístupniť pre viacdimenzionálnu analýzu.

# 1.1 Dátová architektúra
ERD diagram

Surové dáta sú usporiadané v relačnom modeli, ktorý je znázornený na entitno-relačnom diagrame (ERD):
![Chinook_ERD](https://github.com/user-attachments/assets/de87b1ff-3ea9-4710-92c1-8a377dc0a4be)
+ Obrázok 1 Entito-relačná schéma Chinook
# 2.Dimenzonálny model
Navrhnutý bol hviezdicový model, pre efektívnu analýzu kde centrálny bod predstavuje faktová tabuľka fact_sales, ktorá je prepojená s nasledujúcimi dimenziami:

- Dim_Track: Obsahuje informácie o skladbách, ako sú názov, dĺžka, album, interpret a podobne.
- Dim_Genre: Obsahuje demografické údaje o používateľoch, ako sú vekové kategórie, pohlavie, povolanie a vzdelanie.
- Dim_Date: Zahrňuje informácie o dátumoch hodnotení ako deň, mesiac, rok, štvrťrok.
- Dim_Time: Obsahuje podrobné časové údaje hodina, AM/PM.
- Dim_Customer: Obsahuje údaje o zákazníkoch, ako sú meno, krajina, pohlavie, typ predplatného a ďalšie.
- Dim_MediaType: Obsahuje informácie o type média, ako je MP3, WAV, atď.
  
Štruktúra hviezdicového modelu je znázornená na diagrame nižšie. Diagram ukazuje prepojenia medzi faktovou tabuľkou a dimenziami, čo zjednodušuje pochopenie a implementáciu modelu.
![dimTabulka](https://github.com/user-attachments/assets/e54ffd8b-e20d-4991-ba5f-a675ffc7275e)

+ Obrázok 2 Schéma hviezdy pre Chinook
  
# 3. ETL proces v Snowflake
Proces ETL je rozdelený do troch základných krokov: extrakcia (Extract), transformácia (Transform) a načítanie (Load). Tento postup je realizovaný v Snowflake, aby sa zdrojové dáta zo staging vrstvy spracovali a pripravili na analytické a vizualizačné účely v rámci viacdimenzionálneho modelu.
# 3.1 Extract
Pôvodné dáta v formáte .csv boli najprv importované do Snowflake pomocou interného stage úložiska s názvom my_stage. V Snowflake slúži stage ako dočasný priestor na nahrávanie alebo sťahovanie dát. Stage bol vytvorený pomocou nasledovného príkazu:
![Snímka obrazovky 2025-01-01 152456](https://github.com/user-attachments/assets/13aac5a5-9046-46f7-a341-bbac4030bd91)

Do stage boli následne nahraté súbory obsahujúce údaje o knihách, používateľoch, hodnoteniach, zamestnaniach a úrovniach vzdelania. Dáta boli importované do staging tabuliek pomocou príkazu COPY INTO. Pre každú tabuľku sa použil podobný príkaz:![Snímka obrazovky 2025-01-01 152824](https://github.com/user-attachments/assets/2f04ed25-babb-4be3-9cb5-de0f4143dc9e)

V prípade nekonzistentných záznamov bol použitý parameter `ON_ERROR = 'CONTINUE', ktorý zabezpečil pokračovanie procesu bez prerušenia pri chybách. Tento prístup umožnil spracovať všetky riadky aj v prípade, že niektoré údaje neboli správne naformátované alebo obsahovali neštandardné hodnoty, čím sa minimalizovalo riziko prerušenia ETL procesu.

Okrem toho bol použitý parameter FIELD_OPTIONALLY_ENCLOSED_BY, ktorý zabezpečuje, že hodnoty v CSV súboroch môžu byť obklopené úvodzovkami. Tento parameter je dôležitý pre spracovanie údajov, ktoré môžu obsahovať oddeľovače (napr. čiarky), pričom obklopenie hodnôt úvodzovkami zabraňuje nesprávnemu rozdeleniu údajov do stĺpcov.

Na zabezpečenie plynulého načítania dát bol tiež použitý parameter ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE, ktorý umožňuje pokračovanie procesu aj v prípade, že počet stĺpcov v niektorých riadkoch CSV súboru nevyhovuje počtu stĺpcov v cieľovej tabuľke. Tento parameter bol nastavený tak, aby sa vyhli prerušeniam spracovania pri nezrovnalostiach v počte stĺpcov, čím sa zabezpečilo, že proces bude pokračovať a spracuje všetky dostupné dáta.
# 3.2 Transfor
V tejto fáze boli dáta zo staging tabuliek vyčistené, transformované a obohatené. Hlavným cieľom bolo pripraviť dimenzie a faktovú tabuľku, ktoré umožnia jednoduchú a efektívnu analýzu.

Analyzoval som predaj skladieb a zameral som sa na to, ktoré žánre a typy médií sú medzi zákazníkmi najobľúbenejšie. Chcel som získať prehľad o tom, ako zákazníci nakupujú hudbu na základe rôznych faktorov, ako sú typ skladby, album, žáner a čas nákupu. Skúmal som, ktoré skladby a albumy sa najviac predávajú a ako sa tieto predaje menia v závislosti od obdobia. Na analýzu som použil dimenzionálny model typu hviezda, kde som prepojil dimenzionálne tabuľky so faktovou tabuľkou predajov. Týmto spôsobom som získal komplexný obraz o preferenciách zákazníkov a trendoch v predaji hudby.

![Snímka obrazovky 2025-01-02 132010](https://github.com/user-attachments/assets/4b09c632-40fb-4ab7-9e71-6f0d1428939f)

1. dim_customers
 + Táto tabuľka obsahuje informácie o zákazníkoch. Skladá sa z identifikátora zákazníka (dim_customerId), mena (full_name), adresy, mesta, štátu, krajiny, poštového kódu, telefónneho čísla a emailu. Tento dátový model umožňuje efektívne spracovávať a analyzovať údaje o zákazníkoch.

![Snímka obrazovky 2025-01-02 132017](https://github.com/user-attachments/assets/5b3adef5-f0a1-44d0-a344-aa9d319fa614)

2. dim_tracks
+ Táto tabuľka obsahuje informácie o skladbách. Zahŕňa identifikátor skladby (dim_trackId), názov skladby (track_name), identifikátor albumu (AlbumId), názov albumu (album_name), žáner (genre_name), typ média (media_type) a cenu za jednotku (UnitPrice). Táto tabuľka je užitočná na analýzu predaja skladieb na základe rôznych atribútov ako je album, žáner, či typ média.

![Snímka obrazovky 2025-01-02 132026](https://github.com/user-attachments/assets/2d6a5fee-e5e0-41fc-a94b-3a9d1bbb7211)

3. dim_date
+ Táto tabuľka obsahuje informácie o dátumoch. Každý záznam má jedinečný identifikátor (dim_dateId) a zobrazuje rôzne časové aspekty: deň (day), deň v týždni (dayOfWeek), názov dňa (dayOfWeekAsString), mesiac (month), rok (year) a kvartál (quarter). Je kľúčová pre analýzu predaja na základe času a pre agregovanie dát podľa rôznych časových jednotiek.

![Snímka obrazovky 2025-01-02 132032](https://github.com/user-attachments/assets/6e937a8f-4d6f-4648-9327-5e7680d8d4b8)

4. dim_genres_media
+ Táto tabuľka obsahuje kombináciu informácií o žánroch a typoch médií. Pre každý žáner (dim_genreId) je spojený s médiom (dim_mediaTypeId), čo umožňuje analyzovať predaje podľa žánru a typu média, ako sú napríklad rôzne formáty (mp3, CD, atď.).

![Snímka obrazovky 2025-01-02 132038](https://github.com/user-attachments/assets/deca2679-f4f5-400d-a20c-02b85189a301)

5. fact_sales
+ Táto faktová tabuľka obsahuje informácie o predajoch. Zahŕňa identifikátor predaja (fact_salesId), identifikátory zákazníka (dim_customerId) a skladby (dim_trackId), dátum predaja (sale_date), celkovú hodnotu predaja (total_amount), množstvo predaných kusov (quantity_sold), typ média (media_type) a žáner (genre_id). Táto tabuľka je hlavná pre analýzu predajov, poskytuje detailné informácie o transakciách a umožňuje spracovanie predajných dát podľa rôznych dimenzií (zákazníci, skladby, čas, typ média, žáner).



# 3.3 Load

Po úspešnom vytvorení dimenzií a faktovej tabuľky boli dáta prenesené do finálnej štruktúry. Na záver boli staging tabuľky vymazané s cieľom optimalizovať využitie úložného priestoru.

![Snímka obrazovky 2025-01-02 132948](https://github.com/user-attachments/assets/5292e986-0de3-4f67-b2b8-4fb05c17bd14)

ETL proces v Snowflake umožnil transformáciu pôvodných dát z formátu .csv do viacdimenzionálneho modelu typu hviezda. Tento proces zahŕňal kroky čistenia, obohacovania a reorganizácie dát. Výsledný model poskytuje základ pre analýzu čitateľských preferencií a správania používateľov, čím zároveň vytvára predpoklady pre tvorbu vizualizácií a reportov.




