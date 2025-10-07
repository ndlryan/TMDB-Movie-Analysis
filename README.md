# TMDB Movie Dataset Analysis

[![Shell Script](https://img.shields.io/badge/Built%20With-Bash-blue)](https://www.gnu.org/software/bash/)
[![csvkit](https://img.shields.io/badge/Tools-csvkit%20%7C%20gawk-lightgrey)](https://csvkit.readthedocs.io/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Data Source](https://img.shields.io/badge/Data-TMDB-lightblue)](https://www.themoviedb.org/)

---

## Overview

This repository contains a Bash-based data pipeline to analyze the TMDB movie dataset.  
The workflow downloads, cleans, and extracts insights such as revenue, profit, ratings, genres, and cast information — all using command-line tools.

No Python or R dependencies are required.

---

## Getting Started

Clone this repository:

```bash
git clone https://github.com/ndlryan/TMDB-Movie-Analysis.git
cd TMDB-Movie-Analysis
```

Ensure the analysis script is executable:
```bash
chmod +x movie_analysis.sh
```

Then run the analysis:
```bash
bash movie_analysis.sh
```

---

## Workflow

The pipeline performs:

Dataset download → data.csv

Schema inspection → lists all column headers

Sorting → by release date (descending)

Filtering → movies with vote_average ≥ 7.5

Revenue extremes → highest and lowest revenue

Aggregation → total revenue grouped by movie

Profit ranking → top 10 movies by (revenue − budget)

Director analysis → director with most films

Actor analysis → most frequently appearing actor

Genre statistics → count per genre

Genre combinations → frequency of unique genre sets

Each step outputs a CSV file into the project directory.

---

## Outputs

| File                       | Description                               |
| -------------------------- | ----------------------------------------- |
| `movies-sorted.csv`        | Movies ordered by release date descending |
| `movies-rating.csv`        | Movies with `vote_average ≥ 7.5`          |
| `highest_rev.csv`          | Movie with the highest revenue            |
| `lowest_rev.csv`           | Movie with the lowest revenue             |
| `total_rev.csv`            | Total revenue per movie                   |
| `top10_profit.csv`         | Top 10 most profitable movies             |
| `top_director.csv`         | Director with the most films              |
| `top_actor.csv`            | Actor with the most appearances           |
| `movies_genre.csv`         | Count of movies per genre                 |
| `movies_genre_summary.csv` | Frequency of each genre combination       |

---

## Example Output

To preview the top 5 most profitable movies:

```bash
head -n 5 top10_profit.csv
```
Example output:
```yaml
original_title,total_profit
Avatar,2787965087
Titanic,2187463944
Star Wars: The Force Awakens,2068223624
…
```

---

## Dependencies

Install required tools:

### macOS:
```bash
brew install csvkit gawk
```

### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y csvkit gawk
```

---

## Notes

Works on macOS and Linux.

Built entirely with CLI tools (csvkit, awk, curl).

UTF-8 CSV outputs are compatible with PostgreSQL, Pandas, or Tableau.

Script halts automatically on errors for reliable batch processing.

---

## Author

**Ryan**  
[GitHub Profile](https://github.com/ndlryan)

*TMDB Movie Dataset Analysis — Lightweight, Reproducible, and Fast.*
