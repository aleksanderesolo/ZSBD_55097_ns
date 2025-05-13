DROP TABLE EMPLOYEES CASCADE CONSTRAINTS;
DROP TABLE COUNTRIES CASCADE CONSTRAINTS;
DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS;
DROP TABLE JOB_HISTORY CASCADE CONSTRAINTS;
DROP TABLE JOBS CASCADE CONSTRAINTS;
DROP TABLE LOCATIONS CASCADE CONSTRAINTS;
DROP TABLE REGIONS CASCADE CONSTRAINTS;

CREATE TABLE EMPLOYEES AS SELECT * FROM HR.EMPLOYEES;
CREATE TABLE COUNTRIES AS SELECT * FROM HR.COUNTRIES;
CREATE TABLE DEPARTMENTS AS SELECT * FROM HR.DEPARTMENTS;
CREATE TABLE JOB_HISTORY AS SELECT * FROM HR.JOB_HISTORY;
CREATE TABLE JOBS AS SELECT * FROM HR.JOBS;
CREATE TABLE LOCATIONS AS SELECT * FROM HR.LOCATIONS;
CREATE TABLE REGIONS AS SELECT * FROM HR.REGIONS;

ALTER TABLE REGIONS ADD CONSTRAINT region_id_pk PRIMARY KEY (region_id);
ALTER TABLE COUNTRIES ADD CONSTRAINT country_id_pk PRIMARY KEY (country_id);
ALTER TABLE COUNTRIES ADD CONSTRAINT region_id_in_countries FOREIGN KEY (region_id) REFERENCES REGIONS(region_id);
ALTER TABLE LOCATIONS ADD CONSTRAINT location_id_pk PRIMARY KEY (location_id);
ALTER TABLE LOCATIONS ADD CONSTRAINT country_id_in_locations FOREIGN KEY (country_id) REFERENCES COUNTRIES(country_id);
ALTER TABLE DEPARTMENTS ADD CONSTRAINT department_id_pk PRIMARY KEY (department_id);
ALTER TABLE DEPARTMENTS ADD CONSTRAINT location_id_in_departments FOREIGN KEY (location_id) REFERENCES LOCATIONS (location_id);
ALTER TABLE EMPLOYEES ADD CONSTRAINT employee_id_pk PRIMARY KEY (employee_id);
ALTER TABLE EMPLOYEES ADD CONSTRAINT manager_id_in_employees FOREIGN KEY (manager_id) REFERENCES EMPLOYEES (employee_id);
ALTER TABLE EMPLOYEES ADD CONSTRAINT department_id_in_employees FOREIGN KEY (department_id) REFERENCES DEPARTMENTS (department_id);
ALTER TABLE DEPARTMENTS ADD CONSTRAINT manager_id_in_departements FOREIGN KEY (manager_id) REFERENCES EMPLOYEES (employee_id);
ALTER TABLE JOB_HISTORY ADD CONSTRAINT employee_id_start_date_pk PRIMARY KEY (EMPLOYEE_ID, START_DATE);
ALTER TABLE JOB_HISTORY ADD CONSTRAINT department_id_in_job_history FOREIGN KEY (department_id) REFERENCES DEPARTMENTS (department_id);
ALTER TABLE JOB_HISTORY ADD CONSTRAINT employee_id_in_job_history FOREIGN KEY (employee_id) REFERENCES EMPLOYEES (employee_id);
ALTER TABLE JOBS ADD CONSTRAINT job_id_pk PRIMARY KEY (job_id);
ALTER TABLE JOB_HISTORY ADD CONSTRAINT job_id_in_job_history FOREIGN KEY (job_id) REFERENCES JOBS (job_id);
ALTER TABLE EMPLOYEES ADD CONSTRAINT job_id_in_employees FOREIGN KEY (job_id) REFERENCES JOBS (job_id);

SELECT * FROM EMPLOYEES;

SELECT last_name || ' ' || salary AS wynagrodzenie FROM EMPLOYEES WHERE department_id IN (20, 50) AND salary BETWEEN 2000 AND 7000 ORDER BY last_name;

SELECT hire_date, last_name, salary FROM EMPLOYEES WHERE manager_id IS NOT NULL AND EXTRACT(YEAR FROM hire_date) = 2005 ORDER BY salary;

SELECT first_name || ' ' || last_name AS kto, salary, phone_number FROM EMPLOYEES WHERE SUBSTR(last_name, 3, 1) = 'e' AND LOWER(first_name) LIKE '%an%' ORDER BY 1 DESC, 2 ASC;

SELECT first_name, last_name,  ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS miesiace,
    CASE
        WHEN MONTHS_BETWEEN(SYSDATE, hire_date) <= 150 THEN salary * 1.10
        WHEN MONTHS_BETWEEN(SYSDATE, hire_date) <= 200 THEN salary * 1.20
        ELSE salary * 1.30
    END AS wysokosc_dodatku FROM EMPLOYEES ORDER BY miesiace;

SELECT department_id, ROUND(SUM(salary)) AS suma_zarobkow, ROUND(AVG(salary)) AS srednia_zarobkow FROM EMPLOYEES GROUP BY department_id HAVING MIN(salary) > 5000;

SELECT * FROM LOCATIONS;
SELECT * FROM DEPARTMENTS;

SELECT e.last_name, e.department_id, d.department_name, e.job_id 
FROM EMPLOYEES e JOIN DEPARTMENTS d ON e.department_id = d.department_id JOIN LOCATIONS l ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

SELECT j.first_name || ' ' || j.last_name AS pracownik_jennifer, w.first_name || ' ' || w.last_name AS wspolpracownik
FROM EMPLOYEES j LEFT JOIN EMPLOYEES w ON j.department_id = w.department_id AND j.employee_id != w.employee_id
WHERE j.first_name = 'Jennifer';

SELECT department_id, department_name FROM DEPARTMENTS WHERE department_id NOT IN (SELECT DISTINCT department_id FROM EMPLOYEES WHERE department_id IS NOT NULL);

SELECT e.first_name  || ' ' ||  e.last_name as kto, e.job_id, d.department_name, e.salary,
    CASE
        WHEN e.salary > 7000 THEN 'A'
        WHEN e.salary BETWEEN 3000 AND 7000 THEN 'B'
        ELSE 'C'
    END AS grade
FROM EMPLOYEES e JOIN DEPARTMENTS d ON e.department_id = d.department_id;

SELECT first_name || ' ' ||  last_name, salary FROM EMPLOYEES WHERE salary > (SELECT AVG(salary) FROM EMPLOYEES) ORDER BY salary DESC;

SELECT employee_id, first_name, last_name FROM EMPLOYEES WHERE department_id IN 
(
    SELECT DISTINCT department_id FROM EMPLOYEES WHERE LOWER(last_name) LIKE '%u%' AND department_id IS NOT NULL
);

SELECT first_name || ' ' || last_name, hire_date, ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS przepracowane_miesiace FROM EMPLOYEES
WHERE MONTHS_BETWEEN(SYSDATE, hire_date) > (SELECT AVG(MONTHS_BETWEEN(SYSDATE, hire_date)) FROM EMPLOYEES) 
ORDER BY przepracowane_miesiace DESC;

SELECT d.department_name || '(' || d.department_id || ')', COUNT(e.employee_id) AS liczba_pracownikow,  ROUND(AVG(e.salary)) AS srednie_wynagrodzenie
FROM DEPARTMENTS d LEFT JOIN EMPLOYEES e ON d.department_id = e.department_id
GROUP BY d.department_name, d.department_id ORDER BY liczba_pracownikow DESC;

SELECT first_name || ' ' || last_name FROM EMPLOYEES
WHERE salary < (
    SELECT MIN(salary) FROM EMPLOYEES
    WHERE department_id = (
        SELECT department_id FROM DEPARTMENTS
        WHERE department_name = 'IT'
    )
);

SELECT DISTINCT d.department_name 
FROM DEPARTMENTS d JOIN EMPLOYEES e ON d.department_id = e.department_id
WHERE e.salary > (
    SELECT AVG(salary) FROM EMPLOYEES
);

SELECT * FROM JOBS;

SELECT j.job_title, ROUND(AVG(salary)) AS srednia_zarobkow 
FROM JOBS j LEFT JOIN EMPLOYEES e ON j.job_id = e.job_id
GROUP BY j.job_title ORDER BY AVG(salary) DESC
FETCH FIRST 5 ROWS ONLY;

SELECT * FROM REGIONS;
SELECT * FROM COUNTRIES;

SELECT r.region_name, COUNT(DISTINCT c.country_id) AS liczba_krajow, COUNT(e.employee_id) AS liczba_pracownikow
FROM REGIONS r LEFT JOIN COUNTRIES c ON r.region_id = c.region_id LEFT JOIN LOCATIONS l ON c.country_id = l.country_id LEFT JOIN DEPARTMENTS d ON l.location_id = d.location_id LEFT JOIN EMPLOYEES e ON d.department_id = e.department_id
GROUP BY r.region_name;

SELECT e.first_name || ' ' || e.last_name
FROM EMPLOYEES e JOIN EMPLOYEES m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

SELECT EXTRACT(MONTH FROM hire_date)  AS miesiac, COUNT(*) AS liczba_pracownikow
FROM EMPLOYEES
GROUP BY EXTRACT(MONTH FROM hire_date)  ORDER BY miesiac;

SELECT department_id, ROUND(AVG(salary)) AS srednie_wynagrodzenie
FROM EMPLOYEES
GROUP BY department_id ORDER BY AVG(salary) DESC
FETCH FIRST 3 ROWS ONLY;