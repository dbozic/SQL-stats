-- Let's get an ordered list of albums and their  
-- genres in which they belong.  
WITH albums_in_multiple_genres 
     AS (SELECT DISTINCT( album_id ) AS album_id, 
                        genre_id 
         FROM   genres_music 
         ORDER  BY album_id, 
                   genre_id ASC), 
     -- Now, for each album, we will extract the number 
     -- of genres it appears in.  
     genres_per_album 
     AS (SELECT album_id, 
                Count(genre_id) AS no_genres 
         FROM   albums_in_multiple_genres 
         GROUP  BY album_id 
         ORDER  BY album_id), 
     -- Now, let's join the last two tables 
     -- so that each album has its corresponding 
     -- album_id as well as the number of genres 
     -- it is distributed across.  
     all_albums 
     AS (SELECT t1.album_id, 
                t2.no_genres 
         FROM   album_in_multiple_genres t1 
                JOIN genres_per_album t2 
                  ON t1.album_id = t2.album_id), 
     -- Now, we will join this onto the very 
     -- first table so that each genre name has 
     -- its specific album list, with the number 
     -- of distributed genres for each album. We 
     -- will use these numbers to calculate the  
     -- average and the maximum number of genres. 
     ordered_genres 
     AS (SELECT t1.name, 
                t2.album_id, 
                t2.no_genres 
         FROM   genres t1 
                JOIN all_albums t2 
                  ON t1.id = t2.genre_id 
         ORDER  BY t1.name) 
-- The final select statement will display  
-- the average number of genres for all 
-- albums in that genre, as well as 
-- the maximum number of genres for  
-- all albums in that genre. 
SELECT name, 
       ROUND(AVG(no_genres), 2) AS average_no_genres, 
       MAX(no_genres)           AS max_no_genres 
FROM   ordered_genres 
GROUP  BY name 
ORDER  BY average_no_genres ASC; 
