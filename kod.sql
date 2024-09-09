-- Создание таблицы сотрудников
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    date_of_birth DATE,
    start_date DATE,
    position VARCHAR(100),
    employee_level VARCHAR(10),
    salary NUMERIC,
    department_id INTEGER,
    has_permission BOOLEAN
);

-- Добавление исходных данных в таблицу сотрудников
INSERT INTO employees (full_name, date_of_birth, start_date, position, employee_level, salary, department_id, has_permission)
VALUES
    ('Иванов Иван Иванович', '1990-05-15', '2015-08-01', 'Менеджер', 'senior', 50000, 1, true),
    ('Петров Петр Петрович', '1985-10-20', '2018-02-15', 'Разработчик', 'middle', 40000, 2, true),
    ('Сидорова Ольга Петровна', '1993-12-10', '2019-06-10', 'Тестировщик', 'jun', 30000, 1, false),
    ('Козлова Екатерина Сергеевна', '1987-03-25', '2020-01-20', 'Аналитик', 'senior', 60000, 2, true),
    ('Морозов Артем Владимирович', '1995-08-30', '2021-04-05', 'Дизайнер', 'middle', 45000, 1, true);

-- Создание таблицы отделов
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    manager_name VARCHAR(100),
    employee_count INTEGER
);

-- Добавление исходных данных в таблицу отделов
INSERT INTO departments (department_name, manager_name, employee_count)
VALUES
    ('Отдел разработки', 'Иванов Иван Иванович', 10),
    ('Отдел тестирования', 'Сидорова Ольга Петровна', 5),
    ('Отдел управления проектами', 'Новиков Никита Дмитриевич', 7),
    ('Отдел Интеллектуального анализа данных', 'Ким Юлия Владимировна', 3);

-- Создание таблицы оценок сотрудников за квартал
CREATE TABLE employee_ratings (
    rating_id SERIAL PRIMARY KEY,
    employee_id INTEGER,
    quarter INTEGER,
    rating CHAR(1)
);

-- Добавление исходных данных в таблицу оценок сотрудников за квартал
INSERT INTO employee_ratings (employee_id, quarter, rating)
VALUES
    (1, 1, 'A'),
    (1, 2, 'B'),
    (1, 3, 'C'),
    (1, 4, 'D'),
    (2, 1, 'C'),
    (2, 2, 'B'),
    (2, 3, 'B'),
    (2, 4, 'A'),
    (3, 1, 'E'),
    (3, 2, 'D'),
    (3, 3, 'C'),
    (3, 4, 'D'),
    (4, 1, 'A'),
    (4, 2, 'A'),
    (4, 3, 'B'),
    (4, 4, 'C'),
    (5, 1, 'C'),
    (5, 2, 'C'),
    (5, 3, 'D'),
    (5, 4, 'E'),
    (6, 1, 'B'),
    (6, 2, 'B'),
    (6, 3, 'A'),
    (6, 4, 'A');

    -- 6.1 Уникальный номер сотрудника, его ФИО и стаж работы – для всех сотрудников компании
SELECT employee_id, full_name, AGE(CURRENT_DATE, start_date) AS experience
FROM employees;

-- 6.2 Уникальный номер сотрудника, его ФИО и стаж работы – только первых 3-х сотрудников
SELECT employee_id, full_name, AGE(CURRENT_DATE, start_date) AS experience
FROM employees
ORDER BY start_date
LIMIT 3;

-- 6.3 Уникальный номер сотрудников - водителей (допустим, их должности содержат слово "водитель")
SELECT employee_id, full_name
FROM employees
WHERE position ILIKE '%водитель%';

-- 6.4 Выведите номера сотрудников, которые хотя бы за 1 квартал получили оценку D или E
SELECT DISTINCT er.employee_id, e.full_name
FROM employee_ratings er
JOIN employees e ON er.employee_id = e.employee_id
WHERE er.rating IN ('D', 'E');

-- 6.5 Выведите самую высокую зарплату в компании
SELECT MAX(salary) AS max_salary
FROM employees;

-- 6.6 * Выведите название самого крупного отдела
SELECT department_name
FROM departments
ORDER BY employee_count DESC
LIMIT 1;

-- 6.7 * Выведите номера сотрудников от самых опытных до вновь прибывших
SELECT employee_id, full_name, start_date
FROM employees
ORDER BY start_date;

-- 6.8 * Рассчитайте среднюю зарплату для каждого уровня сотрудников
SELECT employee_level, AVG(salary) AS avg_salary
FROM employees
GROUP BY employee_level;

-- 6.9 * Добавьте столбец с информацией о коэффициенте годовой премии к основной таблице
ALTER TABLE employees
ADD COLUMN annual_bonus_coefficient NUMERIC;

UPDATE employees
SET annual_bonus_coefficient = 1.0; -- Установим базовое значение коэффициента 1.0

UPDATE employees
SET annual_bonus_coefficient = CASE
    WHEN EXISTS (SELECT * FROM employee_ratings WHERE employee_id = employees.employee_id AND rating = 'A') THEN annual_bonus_coefficient * 1.2
    WHEN EXISTS (SELECT * FROM employee_ratings WHERE employee_id = employees.employee_id AND rating = 'B') THEN annual_bonus_coefficient * 1.1
    WHEN EXISTS (SELECT * FROM employee_ratings WHERE employee_id = employees.employee_id AND rating = 'C') THEN annual_bonus_coefficient
    WHEN EXISTS (SELECT * FROM employee_ratings WHERE employee_id = employees.employee_id AND rating = 'D') THEN annual_bonus_coefficient * 0.9
    WHEN EXISTS (SELECT * FROM employee_ratings WHERE employee_id = employees.employee_id AND rating = 'E') THEN annual_bonus_coefficient * 0.8
    ELSE annual_bonus_coefficient
END;

-- a. Вывести фамилию сотрудника с самой высокой зарплатой
SELECT full_name
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);

-- b. Вывести фамилии сотрудников в алфавитном порядке
SELECT full_name
FROM employees
ORDER BY full_name;

-- c. Рассчитать средний стаж для каждого уровня сотрудников
SELECT employee_level, AVG(EXTRACT(YEAR FROM (AGE(CURRENT_DATE, start_date)))) AS avg_experience_years
FROM employees
GROUP BY employee_level;

-- d. Вывести фамилию сотрудника и название отдела, в котором он работает
SELECT e.full_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

--e.Вывести название отдела и фамилию сотрудника с самой высокой зарплатой в данном отделе и саму зарплату
SELECT d.department_name, e.full_name, e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE (e.department_id, e.salary) IN (SELECT department_id, MAX(salary) FROM employees GROUP BY department_id);

-- f. Вывести название отдела, сотрудники которого получат наибольшую премию по итогам года
SELECT d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY SUM(e.salary * e.annual_bonus_coefficient) DESC
LIMIT 1;

-- g. Проиндексируйте зарплаты сотрудников с учетом коэффициента премии
UPDATE employees
SET salary = CASE
    WHEN annual_bonus_coefficient > 1.2 THEN salary * 1.2
    WHEN annual_bonus_coefficient >= 1 AND annual_bonus_coefficient <= 1.2 THEN salary * 1.1
    ELSE salary
END;

