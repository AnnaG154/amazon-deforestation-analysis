# Projekt: Analiza deforestacji w Amazonii (maj 2025)

**Cel:** Zbadanie zależności między pożarami, zjawiskami El Niño / La Niña a wylesieniem w Brazylii.  
**Odbiorca:** NGO przygotowujący raport na konferencję międzynarodową.  
**Forma oddania:** skrypty SQL, dashboard w Tableau, repozytorium GitHub.

---

## 📊 Tabele i dane

### 1. `def_area`
- Dane o deforestacji w 9 stanach Amazonii Legalnej (2004–2019)
- Kolumny: `year`, `AC`, `AM`, `AP`, `MA`, `MT`, `PA`, `RO`, `RR`, `TO`, `AMZ_LEGAL`
- Jednostka: km²

### 2. `climate_events`
- Dane o zjawiskach El Niño i La Niña
- Kolumny: `start year`, `end year`, `phenomenon` (`El Nino` / `La Nina`), `severity` (`Weak`, `Moderate`, `Strong`, `Very Strong`)
- Zakres: lata 1999–2019

### 3. `fires_data`
- Dane o miesięcznej liczbie pożarów w stanach Amazonii (1999–2019)
- Kolumny: `year`, `month`, `state`, `latitude`, `longitude`, `firespots`

---

## 🗂️ Struktura folderów projektu

```
/projekt_deforestacja
├── /data/
├── raw/
│   ├── def_area_2004_2019.csv
│   ├── el_nino_la_nina_1999_2019.csv
│   └── inpe_brazilian_amazon_fires_1999_2019.csv
└── processed/
    ├── def_area.sql
    ├── climate_events.sql
    └── fires_data.sql
├── /sql/
    ├── 01_staging_tables.sql              
    ├── 02_data_cleaning.sql               
    ├── 03_forest_area_analysis.sql    
    ├── 04_fire_climate_corelation.sql   
    ├── 05_el_nino_la_nina_impact.sql     
    └──06_fire_sesonality_analysis.sql 
├── tableau/
│   └── data_sources
    │   ├── deforestation_long_view.csv
    │   ├── el_nino_la_nina_impact.csv
    │   ├── fire_climat_correlation_data.csv
    │   └── fire_sesonality_analysis.csv
    └── workbooks
        ├── AmazonDeforestationSummary.twbx
        └── deforestation_story.md
├── documentation/
│   ├── kaggle_data_description.md
│   └── work_notes.md
└── README.md
```




