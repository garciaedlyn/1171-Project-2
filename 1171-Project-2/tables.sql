--Edlyn Garcia Project 2 

--LOG INTO sudo -u postgres psql
--CREATE DATABASE ub_students;
--\c ub_students
--CREATE ROLE ub_students WITH LOGIN PASSWORD '4567';
--log out and log in back with user
--psql --host=localhost --dbname=ub_students --username ub_students

DROP TABLE IF EXISTS programs CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS courses_programs CASCADE;
DROP TABLE IF EXISTS feeder CASCADE;
DROP TABLE IF EXISTS student_information CASCADE;
DROP TABLE IF EXISTS grades CASCADE;

CREATE TABLE programs(               
  program_id INT PRIMARY KEY,
  program_code VARCHAR(50),
  program_name TEXT NOT NULL,
  degree_id INT,
  degree TEXT NOT NULL
 
);

CREATE TABLE courses(               
course_id INT PRIMARY KEY,
course_code CHAR(50) NOT NULL,
course_title TEXT NOT NULL,
course_credits INT NOT NULL
 
);
CREATE TABLE courses_programs( --linking table
  co_pro INT PRIMARY KEY,
  program_id INT NOT NULL,
  course_id INT NOT NULL,
 FOREIGN KEY (course_id)
 REFERENCES courses(course_id),
 FOREIGN KEY (program_id)
 REFERENCES programs(program_id)

);


CREATE TABLE feeder(               
  feeder_id INT PRIMARY KEY,
  school_name VARCHAR(100),
  management TEXT NOT NULL,
  urban_rural TEXT NOT NULL,
  municipality TEXT ,
  funding VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL
 
);

CREATE TABLE student_information(
student_id INT PRIMARY KEY,
gender CHAR(1) NOT NULL,
ethnicity TEXT NOT NULL,
city  TEXT,
district TEXT NOT NULL,
program_start VARCHAR(100) NOT NULL,
program_status VARCHAR(100) NOT NULL,
programEND VARCHAR(100),
grad_date VARCHAR(100),
feeder_id INT,
 FOREIGN KEY (feeder_id)
  REFERENCES feeder(feeder_id)
);



CREATE TABLE grades(
  grade_id INT PRIMARY KEY,
  semester VARCHAR(50) NOT NULL,
  course_grade CHAR(2),
  course_points DECIMAL ,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  FOREIGN KEY (student_id)
  REFERENCES student_information(student_id),
  FOREIGN KEY (course_id)
  REFERENCES courses(course_id)
  
);

\COPY programs       --works
FROM '/home/edlyn/Downloads/Project2/programs.csv' 
DELIMITER ','
CSV HEADER;

\COPY courses            --works
FROM '/home/edlyn/Downloads/Project2/courses.csv' 
DELIMITER ','
CSV HEADER;

\COPY courses_programs   --works
FROM '/home/edlyn/Downloads/Project2/courses_programs.csv' 
DELIMITER ','
CSV HEADER;

\COPY feeder               --works                  
FROM '/home/edlyn/Downloads/Project2/feeder.csv'  
DELIMITER ','
CSV HEADER;


\COPY student_information --works
FROM '/home/edlyn/Downloads/Project2/student_information.csv'          
DELIMITER ','
CSV HEADER;

\COPY grades      --works
FROM '/home/edlyn/Downloads/Project2/grades.csv' 
DELIMITER ','
CSV HEADER;


--Lecturer Queries

--1. Find the total number of students and average course points by feeder institutions. --works
SELECT COUNT(s.student_id),AVG(g.course_points),f.feeder_id,f.school_name
FROM feeder AS f
INNER JOIN student_information AS s
ON f.feeder_id=s.feeder_id
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY f.feeder_id,f.school_name;
--2. Find the total number of students and average course points by gender.--works
SELECT COUNT(s.student_id),AVG(g.course_points),s.gender
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.gender;

--3. Find the total number of students and average course points by ethnicity.--works
SELECT COUNT(s.student_id),AVG(g.course_points),s.ethnicity
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.ethnicity;
--4. Find the total number of students and average course points by city.--works
SELECT COUNT(s.student_id),AVG(g.course_points),s.city
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.city;
--5. Find the total number of students and average course points by district.--works
SELECT COUNT(s.student_id),AVG(g.course_points),s.district
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.district;
--6. Find the total number and percentage of students by program status. --works
SELECT COUNT(s.student_id) AS total_students,
       (COUNT(s.student_id) * 100.0 / SUM(COUNT(s.student_id)) OVER ()) AS percentage,
       s.program_status
FROM student_information AS s
INNER JOIN grades AS g ON s.student_id = g.student_id
GROUP BY s.program_status;
--7. Find the letter grade breakdown (how many A, A-,B,B+,...)for each of the following courses:
--Fundamentals of Computing 
--Principles of Programming I 
--Algebra
--Trigonometry 
--College English I 
SELECT COUNT(g.course_grade), c.course_id, c.course_code, c.course_title, g.course_grade
FROM courses AS c
INNER JOIN grades AS g
ON c.course_id=g.course_id
WHERE c.course_title IN ('FUNDAMENTALS OF COMPUTING', 'PROGRAMMING I', 'ALGEBRA 1', 'TRIGONOMETRY 1', 'COLLEGE ENGLISH I')
GROUP BY c.course_id, c.course_code, c.course_title, g.course_grade;

--My Queries 1-10
--1.How many courses belong to CMPS? --works
SELECT course_id, course_code,course_title
FROM courses
WHERE course_code LIKE 'CMPS%';
--2.Find which district has the most students? --works
SELECT COUNT(student_id), district
FROM student_information
GROUP BY district
ORDER BY district DESC;
--3. List the courses that are 4 credits. --works
SELECT course_id, course_code, course_title,course_credits
FROM courses
WHERE course_credits='4';
--4. List student_id of students who's feeder is University of Belize --works

SELECT s.student_id, f.feeder_id,f.school_name
FROM feeder AS f
INNER JOIN student_information AS s
ON f.feeder_id=s.feeder_id
WHERE f.school_name='University of Belize';

--5 .Amount of students who's feeder is Toledo Community College. --works
SELECT count(s.student_id), f.feeder_id,f.school_name
FROM feeder AS f
INNER JOIN student_information AS s
ON f.feeder_id=s.feeder_id
WHERE f.school_name='Toledo Community College'
GROUP BY f.feeder_id,f.school_name;
--6. Highest amount of student currently enrolled based on gender and total students. --works
SELECT MAX(gender) AS gender,COUNT(student_id) AS student_id, program_status
FROM student_information
WHERE program_status='In Process'
GROUP BY program_status;
--7.Courses and grades for student_id 1217.--works
SELECT c.course_code,c. course_title,g.course_grade,s.student_id
FROM courses AS c
INNER JOIN grades AS g
ON c.course_id=g.course_id
INNER JOIN student_information AS s
ON s.student_id=g.student_id
WHERE s.student_id='1217';

--8. Find students with the most credits based on course taken. --works
SELECT s.student_id, SUM(c.course_credits) as total_credits
FROM student_information AS s 
INNER JOIN grades AS g 
ON s.student_id = g.student_id
INNER JOIN courses AS c 
ON c.course_id = g.course_id
GROUP BY s.student_id
ORDER BY total_credits DESC;

--9.List the most difficult courses based on their grades (C+ and below). --works
SELECT c.course_code,c. course_title,g.course_grade
FROM courses AS c
INNER JOIN grades AS g
ON c.course_id=g.course_id
WHERE g.course_grade >= 'C+';

--10. Find students who are part-time(3 courses per semester) and show the course_name --works
SELECT s.student_id
FROM student_information AS s 
INNER JOIN grades AS g 
ON s.student_id = g.student_id
GROUP BY s.student_id, g.semester
HAVING COUNT(*) = 3; --having instead of where because having can be used with aggregate function