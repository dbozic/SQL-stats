-- (1) What percentage of students have an SAT score
--     greater than 2100?

--     Answer: Before we answer that, let's see how many
--     rows have NULL in any columns. If less than 5%, we will
--     discard those rows from the entire analysis.
--     Q1: How many rows in total?

 WITH total_number AS
  (SELECT COUNT(*)
   FROM tutorial.sat_scores), 
   
-- A1: 135 entries, so we need less than 7 entries (5% of 135 entries).

 no_empty_entries AS 
  (SELECT COUNT(*)
   FROM tutorial.sat_scores 
   WHERE hrs_studied IS NULL), 
   
-- A2: Exactly 7 entries, so let's drop those
-- and define a total_score column as well.

 total_hours_added AS
  (SELECT *, (sat_writing + sat_verbal + sat_math) AS total_score
   FROM tutorial.sat_scores
   WHERE hrs_studied IS NOT NULL) 
   
-- Now, we will extract the percentage of
-- students with scores above 2100.

SELECT ROUND(((COUNT(*))*100)::numeric / (
                                            (SELECT COUNT(*)
                                             FROM total_hours_added)::numeric), 2) AS percentage
FROM total_hours_added
WHERE total_score > 2100;