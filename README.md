# Chinook
Tento repozitár obsahuje implementáciu ETL procesu pre Chinook databázu, zameraného na analýzu dát súvisiacich s hudobným obsahom. Projekt sa venuje skúmaniu správania používateľov a ich preferencií pri nákupe a počúvaní skladieb, pričom vychádza z histórie nákupov a ďalších dostupných údajov. Výsledný dátový model podporuje viacrozmernú analýzu a vizualizáciu dôležitých ukazovateľov.
# 1. Úvod a popis zdrojových dát
Cieľ semestrálneho projektu je analyzovať dáta týkajúce sa hudby,poslúchačov a ích nákupov. Táto analýza umožňuje odhaliť trendy v hudobných preferenciách, najobľúbenejšie skladby a správanie zákazníkov.
Dataset obsahuje:

1.Artist

Popis: Obsahuje údaje o hudobných interpretoch, napríklad meno interpreta.
Význam: Slúži na identifikáciu interpretov a prepojenie s albumami, čo umožňuje analýzu populárnosti interpretov.

2.Album
Popis: Obsahuje informácie o hudobných albumoch, vrátane názvu albumu a ID interpreta, ktorý album vytvoril.
Význam: Umožňuje organizáciu skladieb podľa albumov a prepojenie s interpretmi.

3.Track
Popis: Zahŕňa detaily o jednotlivých skladbách, ako sú názov, dĺžka, cena, žáner, album a formát média.
Význam: Predstavuje centrálnu tabuľku pre analýzu hudobného obsahu a predajných trendov.

4.Genre
Popis: Obsahuje názvy hudobných žánrov, ktoré sú prepojené s jednotlivými skladbami.
Význam: Umožňuje kategorizáciu skladieb podľa žánrov, čo je užitočné pre analýzu preferencií zákazníkov.

5.MediaType
Popis: Obsahuje informácie o formáte skladieb (napr. MPEG, AAC).
Význam: Pomáha identifikovať formáty používané pri distribúcii skladieb.

6.Customer
Popis: Obsahuje údaje o zákazníkoch, ako sú meno, adresa, telefón, email a krajina.
Význam: Dôležitá pre analýzu správania zákazníkov, geografických trendov a cielenie marketingu.

7.Invoice
Popis: Obsahuje informácie o faktúrach, ako sú dátum, celková suma a zákazník, ktorý nákup uskutočnil.
Význam: Predstavuje záznam o jednotlivých transakciách a umožňuje analýzu predaja.

8.InvoiceLine
Popis: Detailná tabuľka faktúr, ktorá obsahuje informácie o jednotlivých skladbách zakúpených na faktúre, vrátane ceny a množstva.
Význam: Prepája faktúry so skladbami a umožňuje detailnú analýzu predaja.

9.Playlist
Popis: Obsahuje údaje o playlistoch, ako sú názvy playlistov.
Význam: Slúži na organizáciu skladieb do playlistov, čo môže byť užitočné pri analýze používateľských preferencií.

10.PlaylistTrack
Popis: Prepája skladby s playlistmi, obsahuje ID skladby a ID playlistu.
Význam: Umožňuje sledovať, ktoré skladby sa nachádzajú v konkrétnych playlistoch.

11.Employee
Popis: Obsahuje informácie o zamestnancoch, vrátane mena, pracovnej pozície a kontaktných údajov.
Význam: Používa sa na riadenie zamestnancov a ich interakcie so zákazníkmi, napríklad pri zákazníckej podpore.
