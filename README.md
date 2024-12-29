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
![Snímka obrazovky 2024-12-29 162831](https://github.com/user-attachments/assets/ecc86996-22e9-4636-b43b-ff19dc5bca01)
+ Obrázok 2 Schéma hviezdy pre Chinook

