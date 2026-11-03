   # Yelp New Orleans Restaurant Analysis

   MATH 167R Project 2. Analysis of New Orleans restaurants using the Yelp Open Dataset.

   ## Data
   Raw Yelp JSON files are not included because of their size. Download them from
   https://business.yelp.com/data/resources/open-dataset/ and update the file paths in `R/import.R`.

   `R/import.R` filters the data to 2,259 New Orleans restaurants and 476,421 reviews,
   then saves them as compressed RDS files in `data/new_orleans/`.