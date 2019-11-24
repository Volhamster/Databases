--create database
use master;
go
if DB_ID (N'GymnastCard2') is not null
drop database GymnastCard2;
go

-- execute the CREATE DATABASE statement
create database GymnastCard2
on ( 
	NAME = GymCard_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab6/gymcarddat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = GymCard_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab6/gymcardlog.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

use GymnastCard2;
go

--создание таблицы с автоинкрементным первичным ключом

--таблица с добавлением полей, для который используются ограничения (CHECK) и
--значения по умолчанию (DEFAULT)

--create table
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
	degree varchar(30) null
        check (degree in ('MSMK', 'MS')),
    age varchar(30) default ('Doesnotmatter')
	);
go

insert into gymnast(gymnastName, height, weightNum, nationality, birthDate, degree)
	values
        ('Margarita Mamun', 170, 50, 'Russia', '01-11-1995', 'MSMK'),
        ('Yana Kudryavtseva', 175, 49, 'Russia', '10-05-1997', 'MS'),
        ('Lubov Ivanova', 139, 72, 'Germany', '10-12-1997', null)
        --Errors
        --,('Katya Petrova', 195, 91, 'England', '09-22-1987', 'no')

select * from gymnast;
-- IDENT_CURRENT не ограничена областью действия и сеансом, но ограничена указанной таблицей
-- SCOPE_IDENTITY и @@IDENTITY возвращают последние значения идентификатора, созданные в любой таблице во время текущего сеанса
-- SCOPE_IDENTITY возвращает значения, вставленные только в рамках текущей области
-- @@IDENTITY не ограничивается никакими областями
go


--таблица с первичным ключом на основе глобального уникального идентификатора

if OBJECT_ID(N'coach') is not null
	drop table coach;
go

create table coach (
	coachID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT (NEWID()),
	coachName varchar(100) not null
	);
go

insert into coach(coachName)
	values
        ('Irina Viner'),
        ('Amina Zaripova')
go

insert into coach(coachID, coachName)
    VALUES
    (NEWID(), 'Eugeniya Kanaeva')

select * from coach;
go


--таблица с первичным ключом на основе последовательности
if OBJECT_ID(N'award') is not null
	drop table award;
go

create table award (
	awardID int PRIMARY KEY,
	awardName varchar(100) not null
	);
go

CREATE SCHEMA awardScheme;
go

create SEQUENCE awardScheme.Seq
    start with 1
    increment by 1
    maxvalue 30;
go

INSERT into award(awardID, awardName)
    VALUES
    (next value for awardScheme.Seq, 'Moscow Competition'),
    (next value for awardScheme.Seq, 'World Championat')
go

select * from award;
go

--2 связанные таблицы.
--Протестировать различные варианты действия для ограничений ссылочной целостности
-- (NO ACTION | CASCADE | SET NULL | SET DEFAULT)

if OBJECT_ID(N'artist') is not null
	drop table artist;
go

CREATE TABLE artist (
	artistID int PRIMARY KEY not null,
	artistName VARCHAR(50)
)

if OBJECT_ID(N'record') is not null
	drop table record;
go

create TABLE record (
	recordID int IDENTITY(100,1) PRIMARY KEY,
	artID int null,
	recordName VARCHAR(50),
	CONSTRAINT artistID_fkr FOREIGN KEY (artID)
		REFERENCES artist (artistID)
		ON UPDATE CASCADE
		-- ON UPDATE SET NULL
		-- ON UPDATE SET DEFAULT
		-- ON DELETE NO ACTION
		ON DELETE CASCADE
		-- ON DELETE SET NULL
		-- ON DELETE SET DEFAULT
)

INSERT into artist(artistID, artistName)
	values 
	(1, 'Bring me the horizon'),
	(2, 'Imagine dragons'),
	(3, 'Our last night'),
	(4, 'Slipknot')
go

INSERT into record([artID], [recordName])
	VALUES
	(1, 'Antivist'),
	(2, 'Radioactive'),
	(3, 'Ocean'),
	(4, 'Orphan')
GO

select * FROM artist;
GO

SELECT * from record;
go

-- delete from artist
-- where (artistID = 3);

-- select * FROM artist;
-- GO

-- SELECT * from record;
-- go
