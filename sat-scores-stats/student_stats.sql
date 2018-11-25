-- (2) For each high school and each teacher, obtain the following:
-- Highest SAT score
-- Lowest SAT score
-- How many students scored above 600 in reading
-- How many students scored above 600 in math
-- How many students scored above 600 in writing
-- Average number of hours spent studying per student
-- Is that number of hours lesser or greater than the global average?
 -- Let's start with CTEs that express total_hours of studying
-- We will drop all the rows where number of studying is NULL. 
 
 WITH total_scores AS 
  (SELECT school, 
          teacher, 
          sat_writing, 
          sat_verbal, 
          sat_math, 
          (sat_writing + sat_verbal + sat_math) AS total_score, 
          hrs_studied 
   FROM tutorial.sat_scores 
   WHERE hrs_studied IS NOT NULL), 
   
-- Let's count the number of students per teacher who scored
-- more than 600 in each category.

 high_scoring_students AS
  (SELECT school,
          teacher,
          SUM(CASE
                  WHEN sat_writing > 600 THEN 1
                  ELSE 0
              END) AS no_writing_600,
          SUM(CASE
                  WHEN sat_verbal > 600 THEN 1
                  ELSE 0
              END) AS no_verbal_600,
          SUM(CASE
                  WHEN sat_math > 600 THEN 1
                  ELSE 0
              END) AS no_math_600
   FROM total_scores
   GROUP BY school,
            teacher
   ORDER BY school ASC), 
   
-- Now, we group for each school & teacher and
-- extract the max and min scores, as well as
-- the average number of hours studied.

 basic_stats AS
  (SELECT teacher,
          MAX(total_score) AS highest_score,
          MIN(total_score) AS lowest_score,
          ROUND(AVG(hrs_studied)::numeric, 2) AS avg_hours_studied
   FROM total_scores
   GROUP BY teacher
   ORDER BY teacher ASC), 
   
-- Let's now assign whether these hours spent studying 
-- were above or below global average. 

 descriptive_stats AS 
  (SELECT teacher, 
          avg_hours_studied, 
          CASE 
              WHEN avg_hours_studied < AVG(avg_hours_studied) OVER () THEN 'Less than average' 
              WHEN avg_hours_studied > AVG(avg_hours_studied) OVER () THEN 'More than average' 
              ELSE 'Average'
          END AS hrs_studied_relative
   FROM basic_stats
   GROUP BY teacher,
            avg_hours_studied
   ORDER BY teacher ASC) 
   
-- And, we finally extract all the necessary values.

SELECT t1.school,
       t1.teacher,
       t1.no_writing_600,
       t1.no_verbal_600,
       t1.no_math_600,
       t2.highest_score,
       t2.lowest_score,
       t3.avg_hours_studied,
       t3.hrs_studied_relative
FROM high_scoring_students t1
JOIN basic_stats t2
  ON t1.teacher = t2.teacher
JOIN descriptive_stats t3
  ON t2.teacher = t3.teacher
ORDER BY t1.school ASC;