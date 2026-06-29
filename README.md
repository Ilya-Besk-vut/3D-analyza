# 3D-analyza
# Spektrální geometrie: Extrakce kostry 3D modelů pomocí Laplace-Beltramiova operátoru

Tento repozitář obsahuje semestrální projekt zaměřený na zpracování 3D mračen bodů a analýzu jejich diferenciální geometrie v prostředí MATLAB.

Cílem projektu je vývoj a implementace algoritmu pro detekování význačných rysů a následnou efektivní extrakci topologického skeletu (kostry) 3D objektů.

## Teoretický základ
Implementace je založena na detailním studiu vědecké publikace *„Geometric Understanding of Point Clouds Using Laplace-Beltrami Operator“* z oblasti spektrální geometrie. 

Algoritmus odhaduje diskrétní Laplace-Beltramiův operátor na mračnu bodů pomocí lokální aproximace povrchu polynomy 2. řádu s přihlédnutím k riemannovské metrice. Následná spektrální analýza (výpočet Fiedlerova vektoru) umožňuje vrstevnatou segmentaci objektu a konstrukci výsledné kostry.

## Struktura projektu

Projekt je rozdělen do logických celků (kód a data) pro optimalizaci výpočetního času:

* `src/` — Zdrojové kódy v MATLABu (`main_processing.m`, `skeleton_extraction.m`, etc.)
* `data/` — 3D modely (`.ply`) a předpočítané matice operátoru (`.mat`) pro optimalizaci výpočetního času.

## Výsledky vizualizace

Níže jsou zobrazeny výsledky běhu algoritmu na zmenšeném modelu:

<img width="1971" height="901" alt="panacek_cely_test_level_contours" src="https://github.com/user-attachments/assets/a6282376-c45d-4cc6-bf9c-41a3ca89e847" />
<img width="595" height="856" alt="panacek_cely_test_otrisovki_2" src="https://github.com/user-attachments/assets/29c7eca7-1384-42dc-8ef6-c25c32d3b3de" />

