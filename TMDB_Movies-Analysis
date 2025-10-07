#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------
# Configuration
# -----------------------------------------
DATA_URL="https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv"
DATA_FILE="data.csv"

# Output filenames
OUT_SORTED="movies-sorted.csv"
OUT_HIGH_RATING="movies-rating.csv"
OUT_HIGH_REV="highest_rev.csv"
OUT_LOW_REV="lowest_rev.csv"
OUT_TOTAL_REV="total_rev.csv"
OUT_TOP10_PROFIT="top10_profit.csv"
OUT_TOP_DIRECTOR="top_director.csv"
OUT_TOP_ACTOR="top_actor.csv"
OUT_GENRE="movies_genre.csv"
OUT_GENRE_SUMMARY="movies_genre_summary.csv"

# -----------------------------------------
# Utility: check command exists
# -----------------------------------------
require_cmd() {
  local cmd=$1
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: required command '$cmd' not found." >&2
    exit 1
  fi
}

# -----------------------------------------
# Initialize: check prerequisites
# -----------------------------------------
check_prerequisites() {
  require_cmd curl
  require_cmd csvsort
  require_cmd csvsql
  require_cmd csvcut
  require_cmd gawk
}

# -----------------------------------------
# Step 1: Download data
# -----------------------------------------
fetch_data() {
  echo "Fetching dataset from $DATA_URL …"
  curl -sSL "$DATA_URL" -o "$DATA_FILE"
  echo "Saved to $DATA_FILE."
}

# -----------------------------------------
# Step 2: Inspect schema
# -----------------------------------------
inspect_columns() {
  echo "Inspecting columns in $DATA_FILE …"
  head -n 1 "$DATA_FILE" | tr "," "\n" | nl
}

# -----------------------------------------
# Step 3: Sort by release date (descending)
# -----------------------------------------
sort_by_date() {
  echo "Sorting by release_date descending → $OUT_SORTED …"
  csvsort -c release_date -r "$DATA_FILE" > "$OUT_SORTED"
}

# -----------------------------------------
# Step 4: Filter high-rated movies
# -----------------------------------------
filter_high_rating() {
  echo "Filtering movies with vote_average ≥ 7.5 → $OUT_HIGH_RATING …"
  csvsql --query \
    "SELECT * FROM data WHERE vote_average >= 7.5 ORDER BY vote_average DESC" \
    "$DATA_FILE" > "$OUT_HIGH_RATING"
}

# -----------------------------------------
# Step 5: Highest / lowest revenue
# -----------------------------------------
extract_revenue_extremes() {
  echo "Finding highest revenue movie → $OUT_HIGH_REV …"
  csvsort -c revenue -r "$DATA_FILE" \
    | csvcut -c original_title,revenue \
    | tail -n +2 \
    | head -n 1 > "$OUT_HIGH_REV"

  echo "Finding lowest revenue movie → $OUT_LOW_REV …"
  csvsort -c revenue "$DATA_FILE" \
    | csvcut -c original_title,revenue \
    | tail -n +2 \
    | head -n 1 > "$OUT_LOW_REV"
}

# -----------------------------------------
# Step 6: Total revenue per movie
# -----------------------------------------
aggregate_total_revenue() {
  echo "Aggregating total revenue per movie → $OUT_TOTAL_REV …"
  csvsql --query \
    "SELECT original_title, SUM(revenue) AS total_revenue \
     FROM data GROUP BY original_title \
     ORDER BY total_revenue DESC" \
    "$DATA_FILE" > "$OUT_TOTAL_REV"
}

# -----------------------------------------
# Step 7: Top 10 profitable movies
# -----------------------------------------
compute_top_profit() {
  echo "Computing top 10 movies by profit → $OUT_TOP10_PROFIT …"
  csvsql --query \
    "SELECT original_title, (SUM(revenue) - SUM(budget)) AS total_profit \
     FROM data GROUP BY original_title \
     ORDER BY total_profit DESC LIMIT 10" \
    "$DATA_FILE" > "$OUT_TOP10_PROFIT"
}

# -----------------------------------------
# Step 8: Director with most movies
# -----------------------------------------
top_director() {
  echo "Determining top director → $OUT_TOP_DIRECTOR …"
  csvsql --query \
    "SELECT director, COUNT(*) AS movie_count \
     FROM data GROUP BY director \
     ORDER BY movie_count DESC LIMIT 1" \
    "$DATA_FILE" > "$OUT_TOP_DIRECTOR"
}

# -----------------------------------------
# Step 9: Actor frequency
# -----------------------------------------
top_actor() {
  echo "Calculating top actor → $OUT_TOP_ACTOR …"
  awk -v FPAT='"([^"]|"")*"|[^,]*' 'NR>1 {
      n = split($7, actors, "|")
      for (i = 1; i <= n; i++) {
        actor = actors[i]
        gsub(/^"|"$/, "", actor)
        gsub(/^ +| +$/, "", actor)
        count[actor]++
      }
    }
    END {
      for (a in count) print a "," count[a]
    }' "$DATA_FILE" \
    | sort -t, -k2 -nr \
    | head -n 1 > "$OUT_TOP_ACTOR"
}

# -----------------------------------------
# Step 10: Movies by genre
# -----------------------------------------
genre_breakdown() {
  echo "Counting movies per genre → $OUT_GENRE …"
  {
    echo "Genre,NumMovies"
    csvcut -c 14 "$DATA_FILE" \
      | tail -n +2 \
      | tr '|' '\n' \
      | sed 's/^"\(.*\)"$/\1/; s/^ *//; s/ *$//' \
      | sort \
      | uniq -c \
      | awk '{ print "\"" $2 "\", " $1 }' \
      | sort -t, -k2 -nr
  } > "$OUT_GENRE"
}

# -----------------------------------------
# Step 11: Genre combination summary
# -----------------------------------------
genre_combinations() {
  echo "Generating genre combination frequency → $OUT_GENRE_SUMMARY …"
  {
    echo "NumGenres,GenreCombo,NumMovies"
    csvcut -c 14 "$DATA_FILE" \
      | tail -n +2 \
      | gawk '{
          gsub(/^"|"$/, "")
          n = split($0, arr, "|")
          for (i = 1; i <= n; i++) gsub(/^ +| +$/, "", arr[i])
          asort(arr)
          combo = arr[1]
          for (i = 2; i <= n; i++) combo = combo "|" arr[i]
          count[n "," combo]++
        }
        END {
          for (key in count) print key "," count[key]
        }' \
      | sort -t, -k1,1nr -k3,3nr
  } > "$OUT_GENRE_SUMMARY"
}

# -----------------------------------------
# Main execution
# -----------------------------------------
main() {
  check_prerequisites

  fetch_data
  inspect_columns
  sort_by_date
  filter_high_rating
  extract_revenue_extremes
  aggregate_total_revenue
  compute_top_profit
  top_director
  top_actor
  genre_breakdown
  genre_combinations

  echo "✅ All tasks complete. Outputs written to current directory."
}

main "$@"
