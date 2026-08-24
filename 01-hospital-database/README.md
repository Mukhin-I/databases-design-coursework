# Assignment 1 — Hospital Database

Учебная работа по проектированию и реализации реляционной базы данных для больничной информационной системы.

## Tasks

### 1. ER Diagram

Разработана Entity-Relationship Diagram для предметной области больницы.

Диаграмма включает сущности:

- Department
- Doctor
- Patient
- Appointment
- Diagnosis
- Procedure

Для всех сущностей определены атрибуты, связи и кардинальности. Использована нотация Chen ER.

### 2. PostgreSQL Database Schema + Data Load

На основе разработанной ER-модели реализована реляционная база данных в PostgreSQL.

В SQL-скрипте реализованы:

- создание базы данных;
- создание таблиц;
- первичные ключи (PRIMARY KEY);
- внешние ключи (FOREIGN KEY);
- ограничения NOT NULL;
- ограничения UNIQUE;
- ограничения CHECK;
- связи между таблицами;
- заполнение таблиц тестовыми данными.

Каждая таблица содержит не менее 10 записей.

## Technologies

- PostgreSQL
- SQL
- pgAdmin
- Draw.io

## Files

- `er-diagram.png` — ER-диаграмма базы данных.
- `hospital_database.sql` — SQL-скрипт создания и заполнения базы данных.
