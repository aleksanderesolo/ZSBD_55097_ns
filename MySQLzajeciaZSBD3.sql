SELECT * FROM EMPLOYEES;

CREATE VIEW v_wysokie_pensje AS SELECT *
FROM EMPLOYEES
WHERE salary > 6000;

SELECT * FROM v_wysokie_pensje;

DROP VIEW v_wysokie_pensje;

CREATE VIEW v_wysokie_pensje AS SELECT *
FROM employees
WHERE salary > 12000;

DROP VIEW v_wysokie_pensje;

SELECT * FROM DEPARTMENTS;

CREATE VIEW v_finance_pracownicy AS
SELECT 
    e.employee_id,
    e.last_name,
    e.first_name
FROM EMPLOYEES e JOIN DEPARTMENTS d ON e.department_id = d.department_id
WHERE d.department_name = 'Finance';

SELECT * FROM v_finance_pracownicy;

CREATE VIEW v_pracownicy_5000_12000 AS
SELECT 
    employee_id,
    last_name,
    first_name,
    salary,
    job_id,
    email,
    hire_date
FROM EMPLOYEES
WHERE salary BETWEEN 5000 AND 12000;

SELECT * FROM v_pracownicy_5000_12000;

--mozna edytowac tylko jesli ma salary od 5000 w gore gdyz tylko widoki 1 i 3 spelniaja warunki modyfikowalnosci
UPDATE v_pracownicy_5000_12000
SET salary = 18000
WHERE employee_id = 103;

UPDATE v_wysokie_pensje
SET salary = 9000
WHERE employee_id = 103;

CREATE VIEW v_statystyki_dzialow AS
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS liczba_pracownikow,
    ROUND(AVG(e.salary)) AS srednia_pensja,
    MAX(e.salary) AS najwyzsza_pensja
FROM DEPARTMENTS d JOIN EMPLOYEES e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) >= 4;

SELECT * FROM v_statystyki_dzialow;
--NIE mozna edytowac gdyz widok nie spelnia warunkow modyfikowalnosci

CREATE OR REPLACE VIEW v_pracownicy_5000_12000 AS
SELECT
    employee_id,
    last_name,
    first_name,
    salary,
    job_id,
    email,
    hire_date
FROM EMPLOYEES
WHERE salary BETWEEN 5000 AND 12000
WITH CHECK OPTION;

SELECT * FROM v_statystyki_dzialow;

INSERT INTO v_pracownicy_5000_12000 (employee_id, last_name, first_name, salary, job_id, email, hire_date) 
VALUES (
    300, 'Nowak', 'Anna', 8000, 'IT_PROG', 'anowak@example.com', SYSDATE
);

SELECT * FROM v_pracownicy_5000_12000;
--mozna dodawac pracownika z pensja pomiedzy 5000 a 12000 gdyz spelni wtedy warunki modyfikowalnosci
--NIE mozna dodawac pracownika z pensja powyzej 12000 gdyz widok nie spelnia warunkow modyfikowalnosci

DELETE FROM v_pracownicy_5000_12000
WHERE employee_id = 300;

SELECT * FROM DEPARTMENTS;

CREATE MATERIALIZED VIEW v_managerowie
BUILD IMMEDIATE REFRESH ON DEMAND AS
SELECT DISTINCT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM EMPLOYEES e JOIN DEPARTMENTS d ON e.department_id = d.department_id
WHERE e.employee_id IN (
    SELECT DISTINCT manager_id
    FROM EMPLOYEES
    WHERE manager_id IS NOT NULL
);

SELECT * FROM v_managerowie;

CREATE VIEW v_najlepiej_oplacani AS SELECT *
FROM EMPLOYEES
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;

SELECT * FROM v_najlepiej_oplacani;