--create database
use master;
go

--Создать две базы данных на одном экземпляре СУБД SQL Server 2012.
if DB_ID (N'lab131') is not null
drop database lab131;
go

-- execute the CREATE DATABASE statement
create database lab131
on ( 
	NAME = lab131_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab131/lab131dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = lab131_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab131/lab131log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

use master;
go
if DB_ID (N'lab132') is not null
drop database lab132;
go

-- execute the CREATE DATABASE statement
create database lab132
on ( 
	NAME = lab132_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab132/lab132dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = lab132_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab132/lab132log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

--Создать в базах данных п.1. горизонтально фрагментированные таблицы.

use lab131;
GO

if OBJECT_ID(N'Music') is not null
	drop table Music;
go

create table Music (
	recordId int PRIMARY KEY check (recordId <= 3),
	artist_name varchar(50) not null,
	nationality varchar(30) null default '-',
	org_year int not null
        check (org_year > 1900 and org_year < 2020),
	genre varchar(30) null
    )
go

use lab132;
GO

if OBJECT_ID(N'Music') is not null
	drop table Music;
go

create table Music (
	recordId int PRIMARY KEY check (recordId > 3),
	artist_name varchar(50) not null,
	nationality varchar(30) null default '-',
	org_year int not null
        check (org_year > 1900 and org_year < 2020),
	genre varchar(30) null
    )
go

--Создать секционированные представления, обеспечивающие
--работу с данными таблиц (выборку, вставку, изменение, удаление).

use lab131;
GO

if OBJECT_ID(N'MusicView') is not null
	drop view MusicView;
go

CREATE view MusicView AS
    SELECT * FROM lab131.dbo.Music
    UNION ALL
    SELECT * FROM lab132.dbo.Music
go

use lab132;
GO

if OBJECT_ID(N'MusicView') is not null
	drop view MusicView;
go

CREATE view MusicView AS
    SELECT * FROM lab131.dbo.Music
    UNION ALL
    SELECT * FROM lab132.dbo.Music
go

insert into MusicView
	values
        (1, 'Bring me the horizon', 'UK', 2004, 'Rock'),
        (2, 'Imagine dragons', 'USA', 2008, 'Alternative'),
		(3, 'Little Big', 'Russia', 2013, 'Raiv'),
        (4, 'Our last night', 'USA', 2004, 'Rock'),
        (5, 'Slipknot', 'USA', 1995, 'Rock'),
        (6, 'Billy Eilish', 'USA', 2015, 'Pop'),
		(7, '30 STM', 'USA', 1998, 'Rock')

SELECT * FROM MusicView;

SELECT * FROM lab131.dbo.Music;
SELECT * FROM lab132.dbo.Music;

DELETE FROM MusicView where genre = 'Raiv';

SELECT * FROM lab131.dbo.Music;
SELECT * FROM lab132.dbo.Music;

UPDATE MusicView set nationality = 'UNKNOWN' where genre = 'Pop';


SELECT * FROM lab131.dbo.Music;
SELECT * FROM lab132.dbo.Music;