# Customer & Sales Analytics — Olist E-commerce

## 1. Sommario Esecutivo
Progetto di analisi end-to-end su un dataset e-commerce brasiliano reale (Olist, ~100.000 ordini,
periodo 2016–2018). L'obiettivo è ricostruire il percorso cliente dall'acquisto alla consegna,
segmentare la base clienti per comportamento d'acquisto, misurare le performance dei venditori e
la retention nel tempo, fornendo una dashboard Power BI pronta per il management.

**Dataset**: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(Kaggle, 9 tabelle, licenrezzi non sono inclusi in ttura ricalcati d) e checklist file p
er l'upload GitHub. Rilevate 2 discrepanze da correggere prima de
l caricamento: export_gold_csv.ps1 punta ancora alle view gold ve
cchie (non a gold.overview/customers/delivery/sellers/cohort di 0        5_gold_views_v2.sscript ha un buco (0
4 mancante, 05 marcato "v2") da sistemare rinominando 05_gold_vie
ws_v2.sql → 04_gold_views.sql. |
| 2026-06-29 20:00 | GENERATE | Creati 5 script numerati in docs/
 (stessa struttura del progetto OEE): 00_database_setup, 01_bronz
e_load, 02_bronze_quality_check, 03_silver_transform, 04_gold_vie
ws. |
| 2026-06-29 19:00 | UPDATE | Aggiunte a gold_views.sql le view m
ancanti: gold.seller_performance (KPI per venditore) e gold.cohor
t_retention (retention mensile per coorti). |

Fatto. Riepilogo di quello che serve fare quando organizzi la cartella del repo:

- docs/progetto_customers_analysis.ipynb → va in notebooks/progetto_customers_analysis.ipynb                                      - crea una cartella datasccanto a notebooks/ — è dove il notebook (e chi ctrovare i CSV scaricati daKaggle
- docs/README.md → alla root del repo
                                                                                 Il notebook resta identicM, cohort, delivery) — hotoccato solo le due celle di setup.

✻ Crunched for 1m 16s

※ recap: We're prepping your Olist portfolio dashboard for GitHub upload: README and Python notebook are fixed and ready. Next: reorganize files into the repo structure (notebooks/, dataset/, docs/) and regenerate the gold CSV exports before pushing.

> dammi qui il file readme da incollare su github

  Read 1 file                                                                     
                                                                                   Ecco il contenuto completREADME.md alla root delrepo:

# Customer & Sales Analytics — Olist E-commerce                                 .000 ordini,
periodo 2016–2018). L'obiettivo è ricostruire il percorso cliente dall'acquisto alla consegna,
segmentare la base clienti per comportamento d'acquisto, misurare le performance dei venditori e
la retention nel tempo, fornendo una dashboard Power BI pronta per il management.

**Dataset**: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(Kaggle, 9 tabelle, licenza CC BY-NC-SA 4.0). I CSV grezzi non sono inclusi in questo repository —
scaricali dal link sopra ed estraili in una cartella `dataset/` nella root del repo (allo stesso
livello di `notebooks/`) per eseguire il notebook Python in locale.              ---

## 2. Problema di Business
Un marketplace e-commerce con migliaia di venditori indipendenti deve rispondere a queste domande:
- Quali categorie di prodotto generano più ricavi e come si muove il trend mese
su mese?
- Come si segmenta la base clienti in base al comportamento d'acquisto (RFM) e quali metodi di
  pagamento preferisce?
- Le consegne rispettano tano i ritardi sullerecensioni dei clienti?
- Quali venditori performano meglio (ricavi, puntualità, recensioni) e quali richiedono attenzione?
- Quanti clienti tornano ad acquistare dopo il primo ordine, e con quale frequenza?

---

## 3. Metodologia
Il progetto segue una pipeline in tre fasi: **Python → SQL (Architettura Medallion) → Power BI**.

**Python** (`notebooks/progetto_customers_analysis.ipynb`) è stato usato per l'EDA iniziale sui 9
CSV originali, il calcolo (Recency, Frequency,
CSV originali, il calcolo (Recency, Frequency,Monetary) su
`customer_unique_id` e la costruzione della logica di **cohort analysis**, poi caricati in SQL
Server come tabelle di su

Il **Bronze Layer** contiene il dato grezzo ingestito dai 9 CSV Olist senza trasformazioni, con
controlli completi di qualità: valori nulli, duplicati, outlier su prezzo e pagamenti, inversioni
temporali tra le date di consegna (~1.300 casi individuati).

Il **Silver Layer** pulisce e tipizza il dato: distingue `customer_id` (per ordine) da
`customer_unique_id` (persona reale, chiave per l'RFM), calcola i giorni di consegna e il flag di
ritardo, traduce le categ all'inglese.

Il **Gold Layer** espone 5 view, una per pagina dashboard così i filtri
incrociati funzionano su
tutti i visual contemporaneamente: `gold.overview`, `gold.customers`, `gold.delivery`,
`gold.sellers`, `gold.cohort`.

La **dashboard Power BI** è strutturata in 5 pagine — Overview, Clienti, Consegne, Venditori,
Retention — con un tema custom dark disegnato per coerenza visiva con gli altri
progetti del
portfolio.

---

## 4. Competenze Tecniche| Area | Strumenti e Tecn
|---|---|
| Analisi esplorativa | Python (pandas) — EDA, RFM segmentation, cohort analysis |                                                                            | Architettura dati | MedSilver/Gold) |
| Storage | SQL Server |
| Trasformazione dati | SQL — CTE, Window Functions (DATEDIFF, MIN OVER), CASE WHEN, JOIN multi-tabella |                                                   | Qualità del dato | Nullrenza temporale tra date,outlier su prezzo/pagamenti |
| Reporting | Power BI — misure DAX, formattazione condizionale, tema custom, drill tra pagine |

---

## 5. Risultati
                                                                             ### Overview
Nel periodo analizzato lo store genera **$15,79M** di ricavi su **99,15K ordini**, per uno                                                            scontrino medio di **$154itizie sono health_beauty($1,44M) e
watches_gifts ($1,30M). Il trend mensile mostra una forte tenuta tra gennaio e agosto (tra $1,24M
e $1,74M/mese), seguita da un calo marcato negli ultimi mesi (fino a $0,72M) — è una caratteristica                                                           nota del dataset Olist, colo fino a settembre 2018:gli ultimi mesi
sono sotto-rappresentati per troncamento della raccolta, non per un reale calo di mercato.
                                                                             ### ClientiIl credit_card è il metod,41% del valore, $12,4M),seguito da boleto
(17,93%). La segmentazione RFM evidenzia una base clienti in gran parte "Hibernating" (4.785                                                         clienti) e "Lost" (3.439)ion" — un profilo tipico diun marketplace a
bassissima frequenza di riacquisto, coerente con quanto noto sul dataset Olist.

### Consegne                                                                 Il 7,81% degli ordini arr medio di consegna di 17,48giorni. Il
punteggio medio recensioni è 3,34/5. La categoria con le recensioni migliori è cds_dvds_musicals
(4,43), quella con le peggiori è food_drink (3,90). A livello geografico gli stati del nord (AP,
AM, AC) registrano i punteggi più alti, quelli più periferici (PE, BA, CE) i più bassi.

### Venditori
Su oltre 3.061 venditori attivi, lo stato di San Paolo (SP) domina nettamente il fatturato rispetto
a tutti gli altri stati — segnale di forte concentrazione geografica dell'offerta.

### Retention
Solo lo **0,47%** dei clienti acquista in due mesi consecutivi — un tasso di riacquisto molto
basso, coerente con la letteratura pubblica sul dataset Olist (marketplace a bassissima
fidelizzazione). La cohorerma che la stragrandemaggioranza del valore
generato da ogni coorte arriva dal mese dell'acquisto iniziale.

---

## 6. Prossimi Passi
- Segnalare esplicitamente in dashboard gli ultimi mesi del dataset (raccolta troncata), per
  evitare interpretazioni errate del trend di fine periodo
- Analizzare la correlazione tra tempi di consegna e stato del cliente per prioritizzare interventi
  logistici per area geografica
- Costruire un modello di propensione al riacquisto in Python per individuare i clienti a rischio
  abbandono prima che diventino "Lost"
- Automatizzare il refresQL → Power BI) con unoscheduler

---

## Dashboard Preview

### Overview
![Overview](images/page1_overview.png)

### Clienti
![Clienti](images/page2_clienti.png)

### Consegne
![Consegne](images/page3_consegne.png)

### Venditori
![Venditori](images/page4_venditori.png)

### Retention
![Retention](images/page5

## Come utilizzare la Dashboard

Per esplorare la dashboard in modo interattivo, scaricare il file `.pbix` dalla cartella
`Power_BI/` e aprirlo con **Power BI Desktop** (scaricabile gratuitamente da
[qui](https://powerbi.microsoft.com/it-it/desktop/)). I dati sono già incorporati nel file — non è
necessario installare SQL Server o scaricare file aggiuntivi.

---

## Autore
**Matti Falchi**
- LinkedIn: www.linkedin.com/in/mattia-falco-4b8b3033b
- GitHub: https://github.com/Mattia2220/customer-sales-analytics-olist
