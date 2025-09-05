#!/bin/bash

# -----------------------------------------
# Get data
# -----------------------------------------
# Download file to local
curl https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv -o data.csv

# -----------------------------------------
# Check columns
# -----------------------------------------
head -n 1 data.csv | tr "," "\n" | nl

# -----------------------------------------
# Sort by release date descending
# -----------------------------------------
csvsort -c release_date -r data.csv > movies-sorted.csv

# -----------------------------------------
# Movies with vote_average >= 7.5
# -----------------------------------------
csvsql --query "SELECT * FROM data WHERE vote_average >= 7.5 ORDER BY vote_average DESC" data.csv > movies-rating.csv

# -----------------------------------------
# Highest and lowest revenue
# -----------------------------------------
csvsort -c revenue -r data.csv | csvcut -c original_title,revenue | tail -n +2 | head -n 1 > highest_rev.csv
csvsort -c revenue data.csv | csvcut -c original_title,revenue | tail -n +2 | head -n 1 > lowest_rev.csv

# -----------------------------------------
# Total revenue by movie
# -----------------------------------------
csvsql --query "SELECT original_title, SUM(revenue) AS total_revenue FROM data GROUP BY original_title ORDER BY total_revenue DESC" data.csv > total_rev.csv

# -----------------------------------------
# Top 10 highest profit movies
# -----------------------------------------
csvsql --query "SELECT original_title, (SUM(revenue) - SUM(budget)) AS total_profit FROM data GROUP BY original_title ORDER BY total_profit DESC LIMIT 10" data.csv > top10_profit.csv

# -----------------------------------------
# Top director by number of movies
# -----------------------------------------
csvsql --query "SELECT director, COUNT(*) AS movie_count FROM data GROUP BY director ORDER BY movie_count DESC LIMIT 1" data.csv > top_director.csv

# -----------------------------------------
# Top actor
# -----------------------------------------
awk -v FPAT='"([^"]|"")*"|[^,]*' 'NR>1 {
    n=split($7,a,"|"); 
    for(i=1;i<=n;i++){
        gsub(/^"|"$/,"",a[i]); 
        gsub(/^ +| +$/,"",a[i]); 
        count[a[i]]++
    }
} END {
    for(actor in count) print actor "," count[actor]
}' data.csv | sort -t, -k2 -nr | head -n 1 > top_actor.csv

# -----------------------------------------
# Movies by genres
# -----------------------------------------
(
  echo "Genre,NumMovies"
  csvcut -c 14 data.csv | tail -n +2 | tr '|' '\n' | sed 's/^"\(.*\)"$/\1/; s/^ *//; s/ *$//' | sort | uniq -c | awk '{print "\"" $2 "\", " $1}' | sort -t, -k2 -nr
) > movies_genre.csv

# -----------------------------------------
# Extra: Genre combinations summary
# -----------------------------------------
(
  echo "NumGenres,GenreCombo,NumMovies"
  csvcut -c 14 data.csv | tail -n +2 | gawk '{
      gsub(/^"|"$/, ""); 
      n=split($0,a,"|"); 
      for(i=1;i<=n;i++) gsub(/^ +| +$/,"",a[i]); 
      asort(a); 
      combo=a[1]; 
      for(i=2;i<=n;i++) combo=combo "|" a[i]; 
      count[n","combo]++
  } END {
      for(k in count) print k "," count[k]
  }' | sort -t, -k1,1nr -k3,3nr
) > movies_genre_summary.csv

