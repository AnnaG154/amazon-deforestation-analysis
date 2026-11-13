## 📥 Etap: Tworzenie tabel    01_staging_tables.sql

Tabele `def_area`, `climate_events` oraz `fires_data` zostały utworzone ręcznie przy użyciu polecenia `CREATE TABLE` w edytorze SQL w narzędziu DBeaver.

Następnie dane zostały zaimportowane do każdej z tabel przy użyciu funkcji **„Import Data”**, wskazując odpowiednie pliki źródłowe. Import został przeprowadzony z wersji roboczych plików, które miały dopisek `_copy` w nazwie.

**Przykład:**

* Źródło danych: `def_area_2004_2019_copy.xlsx`
* Tabela docelowa: `def_area`

## 🧾 Import i weryfikacja danych

Import danych automatycznie dopasował zawartość arkuszy Excel do wcześniej zdefiniowanej struktury tabel.  
Zmienione w plikach roboczych nazwy kolumn (np. zamiana `"Anos/Estados"` na `"year"`) zostały odpowiednio dopasowane do nazw w tabelach docelowych.

Wszystkie typy danych – takie jak:
- liczby całkowite (INTEGER),
- liczby zmiennoprzecinkowe (FLOAT),
- tekst (TEXT)

zostały prawidłowo zinterpretowane, bez konieczności stosowania zapytań `INSERT`.

Każda tabela została wypełniona poprawnie na podstawie struktury pliku źródłowego.  
Proces ten pozwolił na sprawne przygotowanie danych do dalszego czyszczenia i analizy.

---

## 🧹 Data Cleaning      02_data_cleaning.sql

Po wykonaniu kontroli jakości danych w tabelach `def_area`, `climate_events` i `fires_data` **nie stwierdzono**:

- braków danych (`NULL`),
- wartości ujemnych tam, gdzie są niedozwolone,
- niepoprawnych nazw kategorii (np. stanów),
- ani niespójnych dat.

Dane uznano za **gotowe do dalszego czyszczenia**.

## 🧼 Standaryzacja struktury tabeli `def_area`

W tabeli `def_area` występowały niejednoznaczne lub niespójne nazwy kolumn, które mogły utrudniać dalszą analizę. W szczególności:

- Kolumna `"Ano/Estados"` zawierała dane o roku, ale jej nazwa była nieintuicyjna
- Występowały dwie możliwe nazwy dla kolumny sumarycznej: `"AMZ LEGAL"` i `"AMZ_LEGAL"`
- Kolumny nazw stanów zawierały poprawne skróty, jednak zapisane były wielkimi literami i zawierały spacje w nazwach ogólnych

### ✅ Działanie:

W celu standaryzacji i uproszczenia dalszej pracy, zamiast korygować dane na etapie tworzenia tabel, zdecydowano się na  utworzonie widoku `def_area_clean`, który:

- Zmienia `"Ano/Estados"` na `year`
- Zmienia `"AMZ LEGAL"` lub `"AMZ_LEGAL"` na `amz_legal` z użyciem funkcji `COALESCE`
- Zachowuje wszystkie kolumny stanów (AC, AM, AP, MA, MT, PA, RO, RR, TO) bez zmian, ponieważ są już w formie skrótów

Rozwiązanie to jest bezpieczniejsze i nie powoduje zmian w plikach źródłowych co bywa niebezpieczne.

## 🔍 Spójność nazw stanów – obserwacja bezpośrednia

Podczas przeglądu danych w tabeli `fires_data` oraz widoku `def_area_clean` stwierdzono jednoznacznie, że:

- W `fires_data` kolumna `state` zawiera pełne nazwy stanów (np. `ACRE`, `MATO GROSSO`, `PARA`)
- W `def_area_clean` stany występują jako kolumny o skróconych nazwach (np. `AC`, `MT`, `PA`)

Ponieważ dane są niewielkie i różnice jednoznaczne, uznano że tworzenie dodatkowego zapytania porównującego nie jest konieczne. 
Rozbieżności zostały **bezpośrednio potwierdzone wzrokowo**, a następnie udokumentowane.

### ✅ Decyzja:
Na tej podstawie utworzono widok `fires_data_mapped`, który przekształca pełne nazwy stanów na skrócone – zgodnie z widokiem `def_area_clean`.

Dzięki temu możliwe będzie bezproblemowe porównanie i łączenie danych między `fires_data_mapped` a `def_area_clean` w analizach deforestacji per stan.


## 🌍 Weryfikacja współrzędnych geograficznych w widoku `fires_data_mapped`

Ponad to przeprowadzono kontrolę zakresów szerokości i długości geograficznej dla widoku `fires_data`, aby upewnić się, że wszystkie rekordy dotyczą terytorium Amazonii Legalnej.

**Zakresy sprawdzane:**
- **Szerokość geograficzna (latitude):** od `-18.0` do `5.3`
- **Długość geograficzna (longitude):** od `-74.0` do `-44.0`

**Wynik zapytania:**

| min_latitude | max_latitude | min_longitude | max_longitude | latitude_status | longitude_status | out_of_bounds_count |
|--------------|--------------|----------------|----------------|------------------|-------------------|----------------------|
| -14.431908   | 4.151        | -73.085        | -44.188        | Latitude OK      | Longitude OK      | 0                    |

**Wnioski:**
- Wszystkie rekordy w widoku `fires_data_mapped` znajdują się w granicach Amazonii Legalnej.
- Nie stwierdzono żadnych punktów poza zakresem geograficznym.
- Dane są gotowe do dalszej analizy bez konieczności filtrowania po współrzędnych.

 ### 🛠️ 2025-05-15 – Poprawa widoku def_area_clean

- Odkryto, że pierwotna wersja widoku `def_area_clean` bazowała na kolumnie `"Ano/Estados"`, która po imporcie danych miała same `NULL`.
- Prawidłowa kolumna `year` istniała w tabeli `def_area`, ale nie była używana.
- Dodatkowo, w tabeli pozostały kolumny `"Ano/Estados"` i `"AMZ LEGAL"` — były puste i niepotrzebne.
- Wprowadzono poprawkę widoku z użyciem kolumny `year` oraz `COALESCE("AMZ_LEGAL", "AMZ LEGAL") AS amz_legal`.
- Błędy wynikły z różnic między nagłówkami pliku CSV a importem przez DBeaver.

➡️ Poprawiony kod znajduje się w pliku `sql/02_data_cleaning.sql`.

#### Zapytania pomocnicze użyte przy debugowaniu kolumny year:

```sql
SELECT DISTINCT "Ano/Estados" FROM def_area;

SELECT "Ano/Estados", LENGTH("Ano/Estados"::TEXT) AS len
FROM def_area
ORDER BY "Ano/Estados" NULLS LAST
LIMIT 10;

SELECT *
FROM def_area
WHERE "Ano/Estados" IS NULL;

CREATE OR REPLACE VIEW def_area_clean AS
SELECT
  year,
  "AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO",
  amz_legal
FROM def_area
WHERE year IS NOT NULL;

SELECT * FROM def_area_clean LIMIT 5;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'def_area_clean';

CREATE OR REPLACE VIEW def_area_clean AS
SELECT
  year,
  "AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO",
  COALESCE("AMZ_LEGAL", "AMZ LEGAL") AS amz_legal
FROM def_area
WHERE year IS NOT NULL;

### 📂 2025-05-15 – Analiza danych deforestacji (`03_forest_area_analysis.sql`)

Plik `03_forest_area_analysis.sql` zawiera zestaw kluczowych zapytań eksploracyjnych, które obrazują:

1. **Skalę ogólnej deforestacji** w latach 2004–2019, bazując na kolumnie `amz_legal` z widoku `def_area_clean`.
2. **Porównanie stanów** brazylijskich pod względem całkowitej deforestacji – od najbardziej do najmniej dotkniętego.
3. **Maksymalną punktową deforestację** – czyli rok i stan, w którym nastąpił największy roczny ubytek lasów.
4. **Minimalną punktową deforestację** – analogicznie, wskazanie stanu i roku z najniższą wartością wylesienia.
5. **Zaplanowano przekształconie danych do formatu „long” umożliwiające stworzenie łączonego wykresu:
   - linia: ogólna deforestacja (amz_legal),
   - słupki: deforestacja stanów.

### 📅 2025-05-15 – Widok do wykresu łączonego (deforestacja stanów + całościowa)

Utworzono widok SQL `deforestation_long_view`, który przekształca dane z `def_area_clean` do formatu długiego (long format), zawierając:
- `year`: rok
- `state`: kod stanu
- `deforestation`: wartość deforestacji dla danego stanu
- `amz_legal`: suma deforestacji całej Amazonii Legalnej w danym roku

Widok umożliwia stworzenie w Tableau wykresu łączonego:
- słupki: rozkład deforestacji między stanami (grupowanie po `state`)
- linia: ogólny trend w czasie (kolumna `amz_legal`)

📁 Widok zapisany w pliku: `sql/03a_tableau_views.sql`
📊 Wykres utworzony w Tableau Public na podstawie danych wyeksportowanych z widoku PostgreSQL jako plik `deforestation_long_view.csv`.

### 📊 2025-05-15 – Wykres łączony w Tableau: deforestacja Amazonii

Na podstawie widoku SQL `deforestation_long_view` utworzono wykres łączony przedstawiający skalę deforestacji w Amazonii Legalnej w latach 2004–2019:

- 📊 Słupki: Deforestacja poszczególnych stanów brazylijskich (pole `deforestation`, rozbite według `state`)
- 📈 Linia: Całkowita powierzchnia wycinki w Amazonii Legalnej (pole `amz_legal`)

#### 🔧 Szczegóły techniczne:
- Dane źródłowe: `deforestation_long_view.csv` (eksport z widoku SQL)
- Oś X: `Year of Observation`
- Oś Y (słupki): `Forest Loss (km²)`
- Oś Y (linia): `Annual Deforestation (km²)` (początkowo nazwy były bardziej ambitne, niestety musiuały zostać skrócone dla estetyki opisu osi)

#### 🛠️ Uwagi:
- Gradientowa legenda `AVG(amz_legal)` została usunięta z dashboardu dla przejrzystości prezentacji.
- Tytuł wykresu: *"Which Brazilian States Are Responsible for the Worst Forest Loss?"*
- Ostateczny wykres osadzono w dashboardzie jakO jeden z punktów narracji.

➡️ Kolejny etap analizy: `04_fire_climate_correlation.sql` – zależność między deforestacją a zjawiskami El Niño / La Niña.

1. **Przygotowanie danych wyjściowych**  
   Zaczęto od standaryzacji danych wejściowych, ujednolicenia nazw kolumn i konwersji nazw stanów do skrótów. Pozwoliło to połączyć dane o deforestacji z danymi o pożarach oraz klimacie.

2. **Tworzenie widoków upraszczających analizy**  
   Utworzono widoki `def_area_clean` oraz `fires_data_mapped`, aby uprościć dalsze zapytania, umożliwiając bezpośrednie łączenie informacji na poziomie stanu i roku.

3. **Agregacja i eksploracja danych**  
   Kolejne kwerendy agregowały dane po latach i stanach, wyliczając sumaryczną powierzchnię deforestacji i liczbę ognisk pożarów. Pozwoliło to wychwycić trendy czasowe i regionalne.

4. **Analiza korelacji**  
   Następnie powiązano dane o deforestacji i pożarach z ekstremalnymi zjawiskami klimatycznymi (np. El Niño, La Niña) w celu zbadania zależności między klimatem a zjawiskami w Amazonii.

5. **Tworzenie podstaw do wizualizacji**  
   Wyniki zapytań przygotowano w taki sposób, by można było je łatwo zaimportować i zwizualizować w Tableau, umożliwiając analizę interaktywną oraz prezentację wyników dla odbiorców projektu.


**Podsumowanie:**  
Każdy etap kwerend miał na celu uproszczenie struktury danych, wydobycie kluczowych zależności i przygotowanie gotowych zestawów wyników do dalszej eksploracji oraz prezentacji w narzędziu wizualizacyjnym.



# 🔥 Korelacja Pożarów i Wylesiania: Notatki do Wykresu FireCC w Tableau z oskarżającym tytułem :"Fires Are No Accident: A Map of Intentional Destruction"

## 🔍 Podstawa SQL

Wizualizacja oparta jest na ostatnim zapytaniu z pliku `04_fire_climate_correlation.sql`, zapisanym również jako widok w `04a_tableau_views.sql`. Zapytanie oblicza:

* łączną liczbę pożarów (SUMA `firespots`)
* maksymalny poziom wylesienia (MAX `deforestation`)

Dane są grupowane według: roku, stanu, szerokości i długości geograficznej.


## 📊 Przegląd

Ten wykres prezentuje współwystępowanie dwóch zjawisk — **pożarów lasów** oraz **wylesiania** — w brazylijskiej Amazonii. Wizualizacja ma na celu pokazanie, w których regionach i latach obie formy degradacji środowiska występowały jednocześnie, co może wskazywać na powiązania między nimi.

Dane obejmują lokalizacje geograficzne, lata, liczbę punktów pożarów oraz wartość wylesienia,jeszcze bez odniesienia do konkretnych zjawisk klimatycznych (np. El Niño / La Niña).

---

## 🗺️ Co przedstawia wykres

* **Czerwone/czarne punkty**: intensywność pożarów na podstawie liczby `firespots`.
* **cieniowanie lub warstwa**: poziom wylesienia (`deforestation`) w tych samych lokalizacjach.
* **Filtry**: możliwość wyboru konkretnego stanu i roku a nawet wyboru obszarów o okreslonej liczbe pożarów.
* **Podpowiedzi (tooltips)**: pokazują liczbę pożarów i wartość wylesienia dla wskazanej lokalizacji na mapie.

---

## 🧠 Kluczowe wnioski

* W wielu lokalizacjach pożary i wylesianie występują jednocześnie, co może świadczyć o ich powiązaniu.
* Największe natężenie pożarów i wycinki występuje zwykle w stanach takich jak **Pará** czy **Mato Grosso**.
* Dane te sugerują, że pożary mogą być wykorzystywane jako narzędzie do przygotowania terenu pod wycinkę lub rolnictwo.

> ⚠️ Uwaga interpretacyjna: Choć nie zawsze pożary są bezpośrednio związane z wycinką, ich współwystępowanie w wielu regionach może wskazywać na celowe działania prowadzące do przekształcania lasów.
---


### 🌦️ Analiza wpływu zjawisk klimatycznych El Niño i La Niña na deforestację

W tym etapie analizowano, jak obecność zjawisk klimatycznych El Niño i La Niña wpływała na poziom wylesiania w Amazonii Legalnej w poszczególnych stanach i latach.

Do analizy wykorzystano widoki:
- `climate_events` – zawiera dane o okresach trwania zjawisk klimatycznych,
- `deforestation_long_view` – ustandaryzowany widok zawierający dane o rocznej deforestacji w stanach.

#### 🔍 Co zrobiłam:

1. **Pierwsza kwerenda** wyznaczyła sumę deforestacji w każdym stanie i roku, przypisując ją do odpowiedniego zjawiska klimatycznego (na podstawie zakresu lat `start year` – `end year`).
   - Dane z tej kwerendy wyeksportowałam jako `el_nino_la_nina_impact.csv`
   - W Tableau na ich podstawie utworzony został wykres:  
     - **Columns**: `phenomenon`, `severity`  
     - **Rows**: `AVG(total_deforestation)`

2. **Druga kwerenda** wyliczyła średnią ogólnokrajową deforestację przypadającą na lata każdego zjawiska klimatycznego ale nie wykorzystałam tyc danych w wykresie.

---

#### 📌 Wnioski:

- Lata z występowaniem **El Niño** cechują się wysokim poziomem wylesiania w porównaniu do lat neutralnych lub z La Niña.
- Zjawiska klimatyczne nie są bezpośrednią przyczyną wycinki, ale **tworzą warunki sprzyjające deforestacji**, np. susze i łatwopalność biomasy.
- Siła zjawiska (`severity`) w przypadku **El Niño** nie wpywa znacząco na deforestacje
- Wbrew powszechnemu przekonaniu, nie tylko **El Niño**, ale także **La Niña znacząco zwiększa poziom deforestacji**.
- Lata z obecnością La Niña wykazują wysoki poziom wycinki, co może być skutkiem wydłużonego okresu wilgotnego, który sprzyja rozwojowi rolnictwa, a tym samym zwiększa presję na lasy, tutaj obserwujemy tez zaskaująco wplyw nateżenia zjawiska na deforestacje, która wzrasta przy severity strong
- Wpływ zjawisk klimatycznych jest bardziej złożony niż tylko efekt suszy – obie fazy (zarówno El Niño, jak i La Niña) oddziałują na ekosystem i działalność człowieka w sposób pośredni, ale istotny.
- Obserwowane wzorce wskazują, że **działania prewencyjne nie powinny ograniczać się wyłącznie do lat El Niño**, lecz obejmować także okresy La Niña.



### 🔥 Analiza sezonowości pożarów (Fire Seasonality Analysis)

W tej części analizowano sezonowość występowania pożarów w poszczególnych stanach Amazonii Legalnej. Zapytanie agreguje dane według roku, miesiąca i stanu, obliczając łączną liczbę ognisk pożarów (`firespots`) w każdym miesiącu.

Dane wyeksportowano do pliku `fire_seasonality_analysis.csv`, a następnie zaimportowano do Tableau w celu stworzenia wykresu:

- **Sheet name**: `Distrib_of_Fires`
- **Columns**: `month`
- **Rows**: `AVG(total_firespots)`
- **Typ wykresu**: słupkowy (bar chart)

---

#### 📌 Wnioski:

- **Szczyt aktywności pożarów przypada na sierpień, wrzesień i październik**, co pokrywa się ze szczytem pory suchej
- W tych miesiącach liczba pożarów jest znacznie wyższa niż w pozostałej części roku, co może tez wspomagac **celowe działania ludzi, np. wypalanie terenów**.
- Najniższe wartości odnotowano w miesiącach deszczowych (styczeń–kwiecień), co potwierdza silną zależność sezonową.
- Analiza ta sugeruje, że **działania prewencyjne i kontrole terenowe powinny być nasilone w drugiej połowie roku**, szczególnie w okresie od lipca do października.

### 📊 Budowa finalnego dashboardu

Na podstawie czterech głównych wykresów utworzono finalny dashboard podsumowujący wyniki analizy deforestacji w Amazonii w latach 1999–2019. Każdy z wykresów przedstawiał inny aspekt problemu:

1. **Distrib_of_Fires** – sezonowość pożarów (fire seasonality),
2. **ElNinoLaNina** – wpływ zjawisk klimatycznych na deforestację,
3. **FAA** – zestawienie średniej deforestacji w stanach na przestzreni lat objętych badaniem,
4. **FireCC** – mapa z lokalizacjami pożarów i intensywnością (heatmapa z koordynatami geograficznymi).

Do dwóch z tych wizualizacji dodano funkcję **zoomowania wykresu**:

- **W wykresie liniowym przedstawiającym deforestację w czasie (FAA)** – kliknięcie na wykres przenosi do jego powiększonej wersji,
- **Na mapie pożarów (FireCC)** – aktywacja funkcji zoom umożliwia eksplorację danych w pełnym widoku.

Przejścia między widokami zrealizowano za pomocą **akcji „Go to Dashboard”** (`Dashboard > Actions > Go to Dashboard`) przypisanych do konkretnych arkuszy. Na powiększonych widokach dodano przycisk **„← Back to Summary”**, który umożliwia powrót do głównego panelu.


Uwaga: Akcja działa tylko po kliknięciu w konkretny punkt danych (np. znacznik na mapie, element wykresu), nie w pusty obszar.


# 📌 Wnioski końcowe projektu: Wylesianie Amazonii (1999–2019)

## 🌍 1. Deforestacja to zjawisko trwałe, ale nierównomiernie rozmieszczone

* Największa skala wylesienia występuje w stanach **Pará, Mato Grosso i Rondônia**.
* Pomimo istnienia stref ochronnych (Amazonia Legalna), regiony te są pod silną presją rolniczą i gospodarczą.

---

## 🔥 2. Pożary są powiązane z deforestacją i często mają charakter celowy

* Wiele ognisk pożarów zbiega się z obszarami intensywnej wycinki.
* Dane wskazują, że **ogień bywa narzędziem przygotowania terenu pod dalszą eksploatację**.

---

## 🌦️ 3. El Niño i La Niña pogłębiają skutki działalności człowieka

* Lata z  **El Niño** wykazują lekko zwiększoną deforestację niz w latach  z **La Nina**.
* Zjawiska te nie są bezpośrednim źródłem wycinki, ale **tworzą warunki sprzyjające degradacji**, np. susze czy łatwopalność biomasy.

##   4.Analiza sezonowości pożarów w Amazonii 

* Analiza ta ujawnia silny i powtarzalny wzorzec — szczyt aktywności przypada na sierpień i wrzesień, co zbiega się z końcem pory * suchej. Zjawisko to występuje niemal we wszystkich stanach objętych analizą, ale jego intensywność różni się regionalnie. W * * * niektórych stanach (np. PA, MT) aktywność pożarowa utrzymuje się na podwyższonym poziomie przez więcej miesięcy w roku. Ta * * * sezonowość sugeruje, że działania prewencyjne i kontrole powinny być wzmożone w okresie od lipca do października, a interwencje * dopasowane do lokalnych warunków klimatycznych i gospodarczych.

## 🧩 5. Kluczowe zagrożenie to efekt synergii: klimat + gospodarka + polityka

* Największe skoki deforestacji występują, gdy zbiega się kilka czynników:

  * **anomalie klimatyczne**,
  * **brak skutecznej ochrony prawnej**,
  * **wzrost zapotrzebowania na ziemię**.

---

## 🧭 Ogólna konkluzja

> **Amazonia nie ginie przypadkiem. Jest systematycznie niszczona przez działania ludzi, potęgowaną przez zmieniający się klimat.**

---


### 🧰 Git – Dodawanie tylko nowych plików bez zmian w istniejących

Aby dodać do wersjonowania wyłącznie nowe pliki, które nie były jeszcze śledzone przez Git (tzw. *untracked*), zastosowałam polecenie:

```bash
git add $(git ls-files --others --exclude-standard)

🔎 Co robi ta komenda:
git ls-files --others --exclude-standard – wylistowuje tylko nowe, nieśledzone pliki (czyli takie, które nie zostały jeszcze dodane do repozytorium),

git add $(...) – dodaje tylko te konkretne pliki do obszaru staging.

✅ Dlaczego to zrobiłam:
Nie chciałam przypadkowo dodać zmienionych już plików (modified), które mogą być jeszcze w trakcie edycji lub wymagają przemyślenia przed commitem.

Uznałam to za  bezpieczny sposób na utrzymanie porządku w repozytorium i świadome dodawanie tylko tego, co nowe.

