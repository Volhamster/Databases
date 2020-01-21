--create database
use master;
go
if DB_ID (N'lab9') is not null
drop database lab9;
go


-- execute the CREATE DATABASE statement
create database lab9
on ( 
	NAME = lab9_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab9/lab9dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = lab9_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab9/lab9log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

use lab9;
go

if OBJECT_ID(N'coach') is not null
	drop table coach;
go

CREATE TABLE coach (
	coachID int PRIMARY KEY not null,
	coachName VARCHAR(50),
	degree varchar(30) null
)

if OBJECT_ID(N'gymnast') is not null
	drop table gymnast;
go

create table gymnast (
	gymnastID int IDENTITY(101,1) PRIMARY KEY,
	gymnastName varchar(100) not null,
	height int not null,
	weightNum int not null,
	nationality varchar(30),
	birthDate date not null,
	degreeG varchar(30) null
        check (degreeG in ('MSMK', 'MS')),
    -- age varchar(30) default ('Doesnotmatter'),
	coachID int NOT null
	);
go

insert into gymnast(gymnastName, height, weightNum, nationality, birthDate, degreeG, coachID)
	values
        ('Margarita Mamun', 170, 50, 'Russia', '01-11-1995', 'MSMK', 1),
        ('Yana Kudryavtseva', 175, 49, 'Russia', '10-05-1997', 'MS', 2),
        ('Lubov Ivanova', 139, 72, 'Germany', '10-12-1997', null, 3)


SELECT * from gymnast;
go

use lab9;
go

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
		from coach as c
		where c.coachID = 1)
		BEGIN
			UPDATE gymnast
			SET coachID = 1
			where coachID in (select g.coachID
				from gymnast as g, deleted as d
				where d.coachID in (select coachID from gymnast))
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

if OBJECT_ID(N'Update_Coach_Trigger') is not null
	drop TRIGGER Update_Coach_Trigger;
go

CREATE TRIGGER Update_Coach_Trigger on coach
    Instead of update
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
        set coachName = inserted.coachName, degree = inserted.degree
        from inserted
        where inserted.coachID = coach.coachID
    END
END
GO

if OBJECT_ID(N'Insert_Coach_Record') is not null
	drop TRIGGER Insert_Coach_Record;
go

CREATE TRIGGER Insert_Coach_Record on coach
    INSTEAD of INSERT
AS
BEGIN
    if EXISTS (SELECT a.coachID
        FROM coach as a, inserted as I
        WHERE I.coachID in (select coachID from coach) or I.coachName in (select coachName from coach))
        begin
            exec sp_addmessage 80004, 15, N'Coach is already exists', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(80004, 15, -1)
        END
	ELSE
		if exists (SELECT I.coachName
        	FROM inserted as I
        	WHERE I.coachName != 'Irina Viner' and I.coachID = 1)
			begin
            	exec sp_addmessage 80008, 15, N'Wrong main trainer', @lang='us_english', @replace = 'REPLACE';
            	RAISERROR(80008, 15, -1)
        	END
    ELSE
        BEGIN
            INSERT into coach(coachId, coachName, degree)
            SELECT coachID, coachName, degree
            from inserted
        end
END
GO

--err
-- insert into coach(coachID, coachName, degree)
-- 	values
--         (1, 'Irinnna Viner', 'MSMK'),
--         (2, 'Amina Zaripova', 'MSMK'),
-- 		(3, 'Elena Petrova', null)
-- go

insert into coach(coachID, coachName, degree)
	values
        (1, 'Irina Viner', 'MSMK'),
        (2, 'Amina Zaripova', 'MSMK'),
		(3, 'Elena Petrova', null)
go

SELECT * from coach
go

Delete from coach where coachID = 2
-- Error
-- Delete from coach where coachID in (1, 2)

SELECT * from coach
go

--Err
-- insert into coach(coachID, coachName, degree)
-- 	values
--         (2, 'Amina Zaripova', 'MSMK')
-- go

insert into coach(coachID, coachName, degree)
	values
        (2, 'Amina Zaripova', 'MSMK')
go

-- Error
-- UPDATE coach set coachID = 7;
UPDATE coach set degree = 'MS' where coachName = 'Elena Petrova'
GO

SELECT * FROM gymnast
SELECT * from coach
go

UPDATE gymnast set coachID=2 where gymnastName = 'Yana Kudryavtseva'


SELECT * FROM gymnast
SELECT * from coach
go

-- 2. Для представления пункта 2 задания 7 создать триггеры на вставку,
-- удаление и добавление, обеспечивающие возможность выполнения операций
-- с данными непосредственно через представление.

if OBJECT_ID(N'CardView') is not NULL
    drop view CardView;
go

create view CardView AS
    SELECT
	a.gymnastID, a.gymnastName, a.height, a.weightNum, a.nationality, a.birthDate, a.degreeG,
    b.coachID, b.coachName, b.degree
    from gymnast as a inner join coach as b on a.coachID=b.coachID 
GO

select * from CardView;
go


if OBJECT_ID (N'Delete_View_Trig') is not NULL
	drop TRIGGER Delete_View_Trig
GO

CREATE TRIGGER Delete_View_Trig
	on CardView INSTEAD of DELETE
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
			Delete from coach where coachName in (Select coachName from deleted)
		END
END
GO

Delete from CardView where coachName = 'Elena Petrova'
-- Err
-- Delete from coach where coachID in (1, 2)

Select * FROM CardView
GO

if OBJECT_ID(N'Update_View_Trigger') is not null
	drop TRIGGER Update_View_Trigger;
go

CREATE TRIGGER Update_View_Trigger on CardView
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
            exec sp_addmessage 80007, 15, N'Cant change ID', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(80007, 15, -1)
        END
    ELSE
	-- if update(coachName)
    --     begin
    --         exec sp_addmessage 80008, 15, N'Cant change coachs name', @lang='us_english', @replace = 'REPLACE';
    --         RAISERROR(80008, 15, -1)
    --     END
    -- ELSE
    BEGIN
		UPDATE coach set
		degree = inserted.degree,
		coachName = inserted.coachName
		FROM inserted where coach.coachID=inserted.coachID

		UPDATE gymnast set
		gymnastName = inserted.gymnastName,
		height = inserted.height,
		weightNum = inserted.weightNum,
		nationality = inserted.nationality,
		birthDate = inserted.birthDate,
		degreeG = inserted.degreeG,
		coachID = inserted.coachID
		FROM inserted where gymnast.gymnastID = inserted.gymnastID
    END
END
GO

-- Error
-- UPDATE CardView set coachId = 8 where height = 170;

-- закомменченный кусок
-- UPDATE CardView set coachName = 'rrr' where coachName = 'Irina Viner'

UPDATE CardView set degree = 'MS' where coachName = 'Amina Zaripova'
GO

SELECT * FROM CardView
go

if OBJECT_ID(N'Insert_View_Trigger') is not null
	drop TRIGGER Insert_View_Trigger;
go

CREATE TRIGGER Insert_View_Trigger on CardView
    INSTEAD of INSERT
AS
BEGIN
	if EXISTS (SELECT a.gymnastName
        FROM gymnast as a, inserted as I
        WHERE I.gymnastName in (select gymnastName from gymnast))
        begin
            exec sp_addmessage 80010, 15, N'Gymnast is already exists', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(80010, 15, -1)
        END
    ELSE
	if exists (SELECT I.coachName
        	FROM inserted as I
        	WHERE I.coachName != 'Irina Viner' and I.coachID = 1)
			begin
            	exec sp_addmessage 80011, 15, N'Wrong main trainer', @lang='us_english', @replace = 'REPLACE';
            	RAISERROR(80011, 15, -1)
        	END
	ELSE
        BEGIN

		if exists (select i.coachID
			from inserted as i
			where i.coachID not in (select coachID from coach))
				begin
					INSERT into coach(coachID, coachName, degree)
            		SELECT distinct l.coachID, l.coachName, l.degree
            		from inserted as l
				end
		
			INSERT into gymnast(gymnastName, height, weightNum, nationality, birthDate, degreeG, coachID)
			SELECT gymnastName, height, weightNum, nationality, birthDate, degreeG, coachID
			from inserted
        end
END
GO

-- Error
-- insert into CardView(gymnastName, height, weightNum, nationality, birthDate, degreeG, coachID, coachName, degree)
-- 	values
--         ('Alisa', 170, 54, 'USA', '09-21-1995', 'MS', 7, 'Kostya', 'MSMK')
-- go


insert into CardView(gymnastName, height, weightNum, nationality, birthDate, degreeG, coachID, coachName, degree)
	values
        ('Alisa', 170, 54, 'USA', '09-21-1995', 'MS', 7, 'Kostya', 'MSMK'),
		('Liza', 170, 54, 'USA', '09-21-1995', 'MS', 7, 'Kostya', 'MSMK')
go

select * from CardView
go