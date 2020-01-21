--create database
use master;
go
if DB_ID (N'lab11') is not null
drop database lab11;
go


-- execute the CREATE DATABASE statement
create database lab11
on ( 
	NAME = lab11_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab11/lab11dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 10 
	)
log on (
	NAME = lab11_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab11/lab11log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

use lab11;
go

-- Создание таблиц бд, последующее добавление в них значений

-- Тренер

if OBJECT_ID(N'coach') is not null
	drop table coach;
go

CREATE TABLE coach (
	coachID int PRIMARY KEY not null,
	coachName VARCHAR(50) not null,
	degreeCoach varchar(30) null
        check (degreeCoach in ('MSMK', 'MS')),
    education VARCHAR(1000) null,
    startCareer date NULL default '18-01-2020',
    CONSTRAINT unique_Coach UNIQUE(coachName)
)

insert into coach(coachID, coachName, degreeCoach, education, startCareer)
	values
        (1, 'Irina Viner', 'MSMK', 'Uzbekistan Institute of Phisical Activity', '01-01-1972'),
        (2, 'Amina Zaripova', 'MSMK', 'SCOLIPE', '01-01-1999'),
		(3, 'Elena Petrova', null, null, null),
		(4, 'Vera Shatalina', null, null, '01-01-1990'),
        (8, 'Fiona Petrova', null, null, null)
go

-- Гимнастка

if OBJECT_ID(N'gymnast') is not null
	drop table gymnast;
go

create table gymnast (
	gymnastID int IDENTITY(101,1) PRIMARY KEY not null,
	gymnastName varchar(100) not null,
	height int not null,
	weightNum int not null,
	nationality varchar(30) default 'Russia',
	birthDate date not null,
	degreeGymnast varchar(30) null,
	coachID int NOT null
    CONSTRAINT gymnastCoachID_fkr FOREIGN KEY (coachID)
		REFERENCES coach (coachID)
		ON UPDATE CASCADE
		ON DELETE CASCADE
	);
go

insert into gymnast(gymnastName, height, weightNum, nationality, birthDate, degreeGymnast, coachID)
	values
        ('Margarita Mamun', 170, 50, 'Russia', '01-11-1995', 'MSMK', 1),
        ('Lubov Ivanova', 139, 72, 'Germany', '10-12-1997', null, 3),
        ('Alina Kabaeva', 166, 47, 'Russia', '12-05-1983', 'MSMK', 1)
GO

-- Проверка default значения
insert into gymnast(gymnastName, height, weightNum, birthDate, degreeGymnast, coachID)
	values
	('Dina Averina', 164, 45, '08-13-1996', 'MS', 4),
    ('Yana Kudryavtseva', 175, 49, '10-05-1997', 'MS', 2)
go

-- Награды

if OBJECT_ID(N'award') is not null
	drop table award;
go

CREATE TABLE award (
	awardID int PRIMARY KEY not null,
	awardName VARCHAR(300) not null,
    dateOFAward date not NULL,
	competition varchar(100) not null,
    place tinyInt not null
        check (place in (1, 2, 3)),
    gymnastID int NOT null
    CONSTRAINT awardGymnastID_fkr FOREIGN KEY (gymnastID)
		REFERENCES gymnast (gymnastID)
		ON UPDATE CASCADE
		ON DELETE CASCADE
)

insert into award(awardID, awardName, dateOFAward, competition, place, gymnastID)
	values
        (10001, 'Olimpic Games Winner', '07-09-2016', '88 olimpic games', 1, 101),
        (10002, 'Olimpic Games Prizer', '07-09-2016', '88 olimpic games', 2, 103),
		(10003, 'World Championat Winner', '01-17-2017', 'World Championat 2017', 1, 104)
go

--Травмы

if OBJECT_ID(N'trauma') is not null
	drop table trauma;
go

CREATE TABLE trauma (
	traumaID int PRIMARY KEY not null,
	traumaName VARCHAR(300) not null,
    dateOfTrauma date not NULL,
	typeOfTrauma varchar(100) not null,
    rehabilitationPeriod varchar(100) not null,
    doctor VARCHAR(100) null,
    gymnastID int NOT null
    CONSTRAINT traumaGymnastID_fkr FOREIGN KEY (gymnastID)
		REFERENCES gymnast (gymnastID)
		ON UPDATE CASCADE
		ON DELETE CASCADE
)

insert into trauma(traumaID, traumaName, dateOfTrauma, typeOfTrauma, rehabilitationPeriod, doctor, gymnastID)
	values
        (50001, 'Ustalostniy perelom', '07-09-2016', 'Perelom', '07-09-2016 - 08-10-2017', 'Aleksand Petrenko', 101),
        (50002, 'Rastyazhenie', '02-05-2018', 'Rastyazhenie', '02-05-2018 - 22-05-2018', 'Petr Smirnov', 103),
        (50004, 'Rastyazhenie', '03-05-2018', 'Rastyazhenie', '03-05-2018 - 22-05-2018', 'Petr Smirnov', 101)
go

select * FROM coach
SELECT * from gymnast
select * from award
select * from trauma
go

use lab11;
go

--триггеры для таблиц

-- Тренер
if OBJECT_ID (N'Delete_Coach_Trig') is not NULL
	drop TRIGGER Delete_Coach_Trig
GO

CREATE TRIGGER Delete_Coach_Trig
	on coach INSTEAD of DELETE
AS
BEGIN
	if exists (select * from deleted where coachName = 'Irina Viner')
	begin
		exec sp_addmessage 80001, 15, N'Cant delete the main trainer', @lang = 'us_english', @replace='REPLACE';
		RAISERROR(80001, 15, -1)
	end
	ELSE
	begin
		if exists (select c.coachID
		from coach as c, deleted as d
		where c.coachID = d.coachID-1)
		BEGIN
			UPDATE gymnast
			SET coachID = 
				(select c.coachID
				from coach as c, deleted as d
				where c.coachID = d.coachID-1)
			where coachID in (select g.coachID
				from gymnast as g, deleted as d
				where g.coachID = d.coachID)
			DELETE FROM coach where coachID in (SELECT coachID from deleted)
		END
		ELSE
		BEGIN
			exec sp_addmessage 80002, 15, N'Cantdelete', @lang = 'us_english', @replace='REPLACE';
			RAISERROR(80002, 15, -1)
		END
	END
END
GO

-- Delete from coach where coachID = 2

-- Error
-- Delete from coach where coachID in (1, 2)

-- SELECT * FROM gymnast
-- SELECT * from coach
-- go

if OBJECT_ID(N'Update_Coach_Trigger') is not null
	drop TRIGGER Update_Coach_Trigger;
go

CREATE TRIGGER Update_Coach_Trigger on coach
    AFTER update
AS
BEGIN
	if update(coachId)
        begin
            exec sp_addmessage 80003, 15, N'Cant chande ID', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(80003, 15, -1)
        END
    ELSE
    BEGIN
        update coach
        set coachName = inserted.coachName, degreeCoach = inserted.degreeCoach
        from inserted
        where inserted.coachID = coach.coachID
    END
END
GO

-- Error
-- UPDATE coach set coachID = 7;
UPDATE coach set degreeCoach = 'MS' where coachName = 'Elena Petrova'
GO

SELECT * FROM gymnast
SELECT * from coach
go

if OBJECT_ID(N'Insert_Coach_Record') is not null
	drop TRIGGER Insert_Coach_Record;
go

CREATE TRIGGER Insert_Coach_Record on coach
    INSTEAD of INSERT
AS
BEGIN
    if EXISTS (SELECT a.coachID
        FROM coach as a, inserted as I
        WHERE a.coachID = I.coachID or a.coachName = I.coachName)
        begin
            exec sp_addmessage 80004, 15, N'Coach is already exists', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(80004, 15, -1)
        END
    ELSE
        BEGIN
            INSERT into coach(coachId, coachName, degreeCoach, education, startCareer)
            SELECT coachID, coachName, degreeCoach, education, startCareer
            from inserted
        end
END
GO

--Err
-- insert into coach(coachID, coachName, degreeCoach, education, startCareer)
-- 	values
--         (2, 'Amina Zaripova', 'MSMK', 'SCOLIPE', '01-01-1999')
-- go
insert into coach(coachID, coachName, degreeCoach, education, startCareer)
	values
        (5, 'Olga Kopranova', 'MSMK', 'PEDAGOGICHESKY', '11-02-2004')
go

UPDATE gymnast set coachID=5 where gymnastName = 'Yana Kudryavtseva'


SELECT * FROM gymnast
SELECT * from coach
go

-- триггеры для изменения тренера для гимнастки

if OBJECT_ID(N'Update_Gymnast_Trigger') is not null
	drop TRIGGER Update_Gymnast_Trigger;
go

CREATE TRIGGER Update_Gymnast_Trigger on gymnast
    after update
AS
BEGIN
	if update(coachId)
        begin
			if exists (select c.coachID
				from coach as c, inserted as i
				where i.coachID = c.coachID)
				BEGIN
					UPDATE gymnast
					SET coachID = (select i.coachID from inserted as i)
					where gymnastID in (select i.gymnastID
						from gymnast as g, inserted as i
						where g.gymnastID = i.gymnastID)	
				END
			else
				begin
            	exec sp_addmessage 80020, 15, N'Cant chande Coach besause inserted doesnt exists', @lang='us_english', @replace = 'REPLACE';
            	RAISERROR(80020, 15, -1)
				end
		END
end
GO

-- Error
-- UPDATE gymnast set coachID = 10 where gymnastName = 'Alina Kabaeva'

-- Right
-- UPDATE gymnast set coachID = 4 where gymnastName = 'Alina Kabaeva'
-- GO

-- SELECT * FROM gymnast
-- SELECT * from coach
-- go

-- Проверка на каскадное удаление без триггеров
-- Delete from gymnast where gymnastID = 101
-- select * from gymnast
-- SELECT * from trauma


-- функция возвращающая рандомное число в качестве места

IF OBJECT_ID(N'random_number',N'FN') IS NOT NULL
	DROP FUNCTION random_number
go

IF OBJECT_ID(N'view_number',N'V') IS NOT NULL
	DROP VIEW view_number
go

CREATE VIEW view_number AS
	SELECT CAST(CAST(NEWID() AS binary(3)) AS INT) AS NextID
go

CREATE FUNCTION random_number(@a int,@b int)
	RETURNS int
	AS
		BEGIN
			DECLARE @number int
			SELECT TOP 1 @number=NextID from view_number
			SET @number = @number % @b + @a
			RETURN (@number)
		END;
go

IF OBJECT_ID(N'dbo.select_proc_with_add', N'P') IS NOT NULL
	DROP PROCEDURE dbo.select_proc_with_add
GO

CREATE PROCEDURE dbo.select_proc_with_add
	@cursor CURSOR VARYING OUTPUT
AS
	SET @cursor = CURSOR 
	FORWARD_ONLY STATIC FOR
	SELECT a.awardID, a.awardName,
		   g.gymnastName, g.degreeGymnast,
		   dbo.random_number(1,100) as place
	FROM award as a
	INNER JOIN gymnast g on g.gymnastID = a.gymnastID
	OPEN @cursor;
GO

----------VIEW-----------------------------------------------------------------
--создание представлений и триггеры
if OBJECT_ID(N'Coach_Gymnast_View') is not NULL
    drop view Coach_Gymnast_View;
go

create view Coach_Gymnast_View AS
    SELECT
	a.gymnastID, a.gymnastName, a.height, a.weightNum, a.nationality, a.birthDate, a.degreeGymnast, a.coachID,
    b.coachName, b.degreeCoach, b.education, b.startCareer
    from gymnast as a inner join coach as b on a.coachID=b.coachID 
GO

select * from Coach_Gymnast_View;
go


if OBJECT_ID (N'Delete_View_Trig') is not NULL
	drop TRIGGER Delete_View_Trig
GO

CREATE TRIGGER Delete_View_Trig
	on Coach_Gymnast_View INSTEAD of DELETE
AS
BEGIN
	if exists (select * from deleted where coachName = 'Irina Viner')
	begin
		exec sp_addmessage 80005, 15, N'View: Cant delete the main trainer', @lang = 'us_english', @replace='REPLACE';
		RAISERROR(80005, 15, -1)
	end
	ELSE
		BEGIN
			Delete from gymnast WHERE gymnastName in (Select gymnastName from deleted)
		END
END
GO

Delete from Coach_Gymnast_View where coachName = 'Elena Petrova'
-- Err
-- Delete from coach where coachID in (1, 2)

Select * FROM Coach_Gymnast_View
GO

if OBJECT_ID(N'Update_View_Trigger') is not null
	drop TRIGGER Update_View_Trigger;
go

CREATE TRIGGER Update_View_Trigger on Coach_Gymnast_View
    INSTEAD of update
AS
BEGIN
	if update(gymnastID)
        begin
            exec sp_addmessage 80006, 15, N'Cant chande ID', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(80006, 15, -1)
        END
    ELSE
	if update(coachID)
        begin
            exec sp_addmessage 80007, 15, N'Cant chande ID', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(80007, 15, -1)
        END
    ELSE
	-- if update(coachName)
    --     begin
    --         exec sp_addmessage 80008, 15, N'Cant chande coachs name', @lang='us_english', @replace = 'REPLACE';
    --         RAISERROR(80008, 15, -1)
    --     END
    -- ELSE
    BEGIN
		UPDATE coach set
        degreeCoach = inserted.degreeCoach,
		coachName = inserted.coachName
		FROM inserted where coach.coachID=inserted.coachID

		UPDATE gymnast set
        gymnastName = inserted.gymnastName,
		nationality = inserted.nationality
		FROM inserted where gymnast.gymnastID = inserted.gymnastID
    END
END
GO

-- Error
-- UPDATE Coach_Gymnast_View set coachId = 8 where height = 170;

-- Тест для закомментированной части приведенного выше триггера
-- UPDATE Coach_Gymnast_View set coachName = 'rrr' where coachName = 'Irina Viner'

UPDATE Coach_Gymnast_View set degreeCoach = 'MS' where coachName = 'Olga Kopranova'
GO

SELECT * FROM Coach_Gymnast_View
go


--представление для попарных таблиц (в том числе SELECT с JOIN)

if OBJECT_ID(N'Gymnast_Trauma_View_L') is not NULL
    drop view Gymnast_Trauma_View_L;
go

create view Gymnast_Trauma_View_L AS
    SELECT
	a.gymnastID, a.gymnastName, a.height, a.weightNum, a.nationality, a.birthDate,
    t.traumaID, t.traumaName, t.typeOfTrauma, t.doctor
    from gymnast as a left outer join trauma as t on a.gymnastID=t.gymnastID 
GO

select * from Gymnast_Trauma_View_L;
go

if OBJECT_ID(N'Gymnast_Trauma_View_R') is not NULL
    drop view Gymnast_Trauma_View_R;
go

create view Gymnast_Trauma_View_R AS
    SELECT
	a.gymnastID, a.gymnastName, a.height, a.weightNum, a.nationality, a.birthDate,
    t.traumaID, t.traumaName, t.typeOfTrauma, t.doctor
    from gymnast as a right outer join trauma as t on a.gymnastID=t.gymnastID 
GO

select * from Gymnast_Trauma_View_R;
go

if OBJECT_ID(N'Gymnast_Award_View_F') is not NULL
    drop view Gymnast_Award_View_F;
go

create view Gymnast_Award_View_F AS
    SELECT
	a.gymnastID, a.gymnastName, a.height, a.weightNum, a.nationality, a.birthDate,
    aw.awardID, aw.awardName, aw.competition, aw.dateOFAward, aw.place
    from gymnast as a full outer join award as aw on a.gymnastID=aw.gymnastID 
GO

select * from Gymnast_Award_View_F;
go


--null, like
SELECT * from coach where education is null
go

SELECT * from coach where education is not null
go

-- set ansi_nulls off
-- SELECT * from coach where education = null
-- go

-- set ansi_nulls on
-- SELECT * from coach where education = null
-- go

DELETE from trauma where typeOfTrauma like 'Rast%'
go
select * FROM trauma
go

--asc / desc
SELECT * from Gymnast_Award_View_F
ORDER BY weightNum ASC
GO

SELECT * from Gymnast_Award_View_F
ORDER BY weightNum DESC
GO

-- GROUPING
SELECT Count(gymnastID) as count_counting
from Gymnast_Award_View_F
GROUP by nationality
having nationality in ('Russia')
go

SELECT AVG(weightNum) as avg_counting
from Gymnast_Award_View_F
GROUP by nationality
having nationality in ('Russia')
go

SELECT SUM(height) as sum_counting
from Gymnast_Award_View_F
GROUP by nationality
having nationality in ('Russia')
go

SELECT min(height) as min_sel
from Gymnast_Award_View_F
GROUP by nationality
having nationality in ('Russia')
go

SELECT max(height) as max_sel
from Gymnast_Award_View_F
GROUP by nationality
having nationality in ('Russia')
go

-- GROUP BY + HAVING
SELECT gymnastName, sum(height)
from gymnast
GROUP by gymnastName
having sum(height) > 169
go

--DISTINCT
SELECT * from trauma

SELECT distinct traumaName
as doubled from Gymnast_Trauma_View_L

--Вложенные запросы и псевдонимы
SELECT gymnastID as GYMNASTKAAIDI, gymnastName as NAAAAME
FROM gymnast
where gymnastID in
	(SELECT MAX(gymnastID)
     FROM gymnast)
GO

select * FROM gymnast

-- UNIONS
Select * from gymnast where weightNum < 48
UNION select * from gymnast where weightNum > 48

Select * from gymnast where weightNum < 100
UNION all select * from gymnast where height > 100

Select * from gymnast where weightNum < 100
except select * from gymnast where height > 173

Select * from gymnast where weightNum < 50
INTERSECT select * from gymnast where weightNum > 45