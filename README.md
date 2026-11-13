# 🌳 Deforestation in the Brazilian Amazon (1999–2019)

## 🎯 Project Goal

The purpose of this project is to analyze the scale and drivers of deforestation in the Brazilian Amazon between 1999 and 2019. Special attention is given to the impact of climate phenomena (El Niño, La Niña), fire outbreaks, and the effectiveness of regional protection policies like the Amazonia Legal initiative.

The Brazilian Amazon is being systematically degraded through the combined impact of human activity and climatic events. This dashboard guides the viewer through interactive visualizations that reveal how fire intensity, seasonal trends, and phenomena like El Niño and La Niña correlate with deforestation. By focusing on both spatial and temporal patterns, the analysis highlights key regions and time periods where forest loss is most critical — and where interventions are urgently needed.

---

## 📊 Data Sources

- [Kaggle Dataset](https://www.kaggle.com/datasets/mbogernetto/brazilian-amazon-rainforest-degradation):  
  Includes fire locations, deforestation by state, and climate events (1999–2019)
- Climate and fire data cleaned, mapped, and transformed using SQL (PostgreSQL)
- Tableau Public used for interactive dashboard creation

---

## 🛠 Tools and Technologies

- PostgreSQL (via DBeaver) – data cleaning and transformation  
- Tableau Public (v2025.1.1) – visualization and dashboard storytelling  
- Git & GitHub – project version control and documentation

---

## 📂 Project Structure

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


---
## 📈 Key Visualizations

1. **Deforestation overall FAA** – displays deforestation per year and state
2. **Climate Phenomena vs. Deforestation ElNinoLaNina** – shows how El Niño and La Niña events correlate with deforestation according to phenomenon severity  
3. **Fire Impact Overview FireCC** – A spatial heatmap displaying fire hotspots based on geolocation data (latitude & longitude). The map overlays fire density with deforestation metrics to reveal geographic patterns and potential causal links between fire activity and forest loss 
4. **Fire Seasonality Analysis Distrib_of_Fires** – reveals the monthly concentration of fires, highlighting August to October as peak fire months  
5. **Final Insight Dashboard AmazonDeforestationSummary** – integrates all visualizations in an interactive layout, allowing users to explore patterns across time, region, and climate conditions  


> **Dashboard Title: AmazonDeforestationSummary** 
> 🔗 [View on Tableau Public](https://public.tableau.com/app/profile/anna.gruszczy.ska/viz/AmazonDeforestationSummary/AmazonDeforestationSummary)

---

## 📌 Final Project Insights: Amazon Deforestation (1999–2019)

1. **Deforestation is persistent but geographically concentrated**, especially in Pará, Mato Grosso, and Rondônia.

2. **Certain states (e.g., PA, MT) account for the majority of total forest loss**, highlighting localized drivers of deforestation.

3. **Deforestation fluctuates over time but shows an upward trend in recent years**, despite existing legal protections.

4. **Fires are closely linked to deforestation**, often used intentionally to clear land for agricultural expansion.

5. **El Niño and La Niña amplify human-driven forest loss** by creating dry, fire-prone conditions.

6. **Fire activity peaks between August and October**, showing a clear seasonal pattern that varies by region.

7. **The most severe deforestation occurs when climate, policy failure, and economic pressure combine.**


---

## 🙋 Author

**Anna Gruszczyńska**  
Environmental Chemist & Aspiring Data Scientist  
📧 Contact: [annaszakula83@gmail.com]  
🌐 GitHub: [https://github.com/AnnaG154]


---

