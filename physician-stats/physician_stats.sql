-- We first define a CTE with all the relevant
-- statistics on the patients per each physician.

 WITH general_patient_stats AS
  (SELECT 
  -- number of patients/clients per physician
 physician_last_name,
 COUNT(patient_id) AS patients_per_physician, 
 -- age of patients/clients per physician
 ROUND(AVG(age)::numeric, 1) AS avg_patient_age,
 MAX(age) AS oldest_patient_age,
 MIN(age) AS youngest_patient_age, 
 -- height of patients/clients per physician
 ROUND(AVG(height_inches)::numeric, 1) AS avg_patient_height,
 MAX(height_inches) AS tallest_patient_height,
 MIN(height_inches) AS shortest_patient_height, 
 -- weight of patients/clients per physician
 ROUND(AVG(weight_lbs)::numeric, 1) AS avg_patient_weight,
 MAX(weight_lbs) AS heaviest_patient_weight,
 MIN(weight_lbs) AS lightest_patient_weight
   FROM tutorial.patient_list
   GROUP BY physician_last_name
   ORDER BY physician_last_name ASC), 
   
-- We then make a new CTE that also calculates what percentage
-- of all patients in the dataset a specific physician has,
-- as well as whether that number is above or below average.

 no_patients_stats AS
  (SELECT physician_last_name,
          patients_per_physician,
          ROUND(patients_per_physician * 100 / SUM(patients_per_physician) OVER (), 1) AS percentage_of_patients,
          CASE
              WHEN patients_per_physician < AVG(patients_per_physician) OVER () THEN 'Less than average'
              WHEN patients_per_physician > AVG(patients_per_physician) OVER () THEN 'More than average'
              ELSE 'Average'
          END AS no_clients
   FROM general_patient_stats
   GROUP BY physician_last_name,
            patients_per_physician
   ORDER BY percentage_of_patients DESC), 
   
-- We continue with a new CTE that selects the patient age statistics
-- per physician and then also checks how the age of patients
-- per each physician compares to that of average.

 age_patient_stats AS
  (SELECT physician_last_name,
          avg_patient_age,
          CASE
              WHEN avg_patient_age < AVG(avg_patient_age) OVER () THEN 'Younger than average'
              WHEN avg_patient_age > AVG(avg_patient_age) OVER () THEN 'Older than average'
              ELSE 'Average'
          END AS patient_age,
          oldest_patient_age,
          youngest_patient_age
   FROM general_patient_stats
   GROUP BY physician_last_name,
            avg_patient_age,
            oldest_patient_age,
            youngest_patient_age
   ORDER BY avg_patient_age DESC), 

-- This is followed by a CTE that selects the patient height statistics
-- per physician and then also checks how the height of patients
-- per each physician compares to that of average.

 height_patient_stats AS
  (SELECT physician_last_name,
          avg_patient_height,
          CASE
              WHEN avg_patient_height < AVG(avg_patient_height) OVER () THEN 'Shorter than average'
              WHEN avg_patient_height > AVG(avg_patient_height) OVER () THEN 'Taller than average'
              ELSE 'Average'
          END AS patient_height,
          tallest_patient_height,
          shortest_patient_height
   FROM general_patient_stats
   GROUP BY physician_last_name,
            avg_patient_height,
            tallest_patient_height,
            shortest_patient_height
   ORDER BY avg_patient_height DESC), 

-- The last CTE selects the patient weight statistics
-- per physician and then also checks how the weight of patients
-- per each physician compares to that of average.

 weight_patient_stats AS
  (SELECT physician_last_name,
          avg_patient_weight,
          CASE
              WHEN avg_patient_weight < AVG(avg_patient_weight) OVER () THEN 'Lighter than average'
              WHEN avg_patient_weight > AVG(avg_patient_weight) OVER () THEN 'Heavier than average'
              ELSE 'Average'
          END AS patient_weight,
          heaviest_patient_weight,
          lightest_patient_weight
   FROM general_patient_stats
   GROUP BY physician_last_name,
            avg_patient_weight,
            heaviest_patient_weight,
            lightest_patient_weight
   ORDER BY avg_patient_weight DESC) 
   
-- In the end, all the necessary information
-- is extracted through multiple joins and ordered
-- by the number of patients per each physician.

SELECT n.physician_last_name,
       n.patients_per_physician,
       n.percentage_of_patients,
       n.no_clients,
       a.avg_patient_age,
       a.patient_age,
       a.oldest_patient_age,
       a.youngest_patient_age,
       h.avg_patient_height,
       h.patient_height,
       h.tallest_patient_height,
       h.shortest_patient_height,
       w.avg_patient_weight,
       w.patient_weight,
       w.heaviest_patient_weight,
       w.lightest_patient_weight
FROM no_patients_stats n
INNER JOIN age_patient_stats a
  ON n.physician_last_name = a.physician_last_name
INNER JOIN height_patient_stats h
  ON n.physician_last_name = h.physician_last_name
INNER JOIN weight_patient_stats w
  ON n.physician_last_name = w.physician_last_name
ORDER BY n.patients_per_physician DESC;

