use master;
go

if DB_ID (N'lab141') is not null
drop database lab141;
go

-- execute the CREATE DATABASE statement
create database lab141
on ( 
	NAME = lab141_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab141/lab141dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = lab141_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab141/lab141log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

use master;
go
if DB_ID (N'lab142') is not null
drop database lab142;
go

-- execute the CREATE DATABASE statement
create database lab142
on ( 
	NAME = lab142_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab142/lab142dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = lab142_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab142/lab142log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

--Создать в базах данных пункта 1 задания 13 таблицы,
--содержащие вертикально фрагментированные данные.

use lab141;
GO

if OBJECT_ID(N'Music') is not null
	drop table Music;
go

create table Music (
	recordId int PRIMARY KEY not null,
	artist_name varchar(50) not null,
	nationality varchar(30) null default '-',
	-- org_year int not null
    --     check (org_year > 1900 and org_year < 2020),
	-- genre varchar(30) null
    )
go

use lab142;
GO

if OBJECT_ID(N'Music') is not null
	drop table Music;
go

create table Music (
	recordId int PRIMARY KEY not null,
	-- artist_name varchar(50) not null,
	-- nationality varchar(30) null default '-',
	org_year int not null
        check (org_year > 1900 and org_year < 2020),
	genre varchar(30) null
    )
GO


--Создать необходимые элементы базы данных (представления, триггеры),
--обеспечивающие работу с данными вертикально фрагментированных таблиц
--(выборку, вставку, изменение, удаление).

if OBJECT_ID(N'MusicView') is not null
	drop view MusicView;
go

CREATE view MusicView AS
    SELECT a.*, b.org_year, b.genre
    FROM lab141.dbo.Music a, lab142.dbo.Music b
    where a.recordId = b.recordId
go

if OBJECT_ID(N'InsertTrigger') is not null
	drop TRIGGER InsertTrigger;
go

CREATE TRIGGER InsertTrigger on MusicView
    INSTEAD of INSERT
AS
BEGIN
    if EXISTS (SELECT a.recordId
        FROM lab141.dbo.Music as a, lab142.dbo.Music as b, inserted as I
        WHERE a.artist_name = I.artist_name
        )
        begin
            exec sp_addmessage 50001, 15, N'Artist is already exists', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(50001, 15, -1)
        END
    ELSE
        if EXISTS (SELECT a.recordId
        FROM lab141.dbo.Music as a, inserted as I
        WHERE a.recordId = I.recordId
        )
        begin
            exec sp_addmessage 50002, 15, N'ID is busy', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(50002, 15, -1)
        END
        ELSE
        BEGIN
            INSERT into lab141.dbo.Music(recordId, artist_name, nationality)
            SELECT recordId, artist_name, nationality
            from inserted

            INSERT into lab142.dbo.Music(recordId, org_year, genre)
            SELECT recordId, org_year, genre
            from inserted
        end
END
GO

insert into MusicView(recordId, artist_name, nationality, org_year, genre)
	values
        (1, 'Bring me the horizon', 'UK', 2004, 'Rock'),
        (2, 'Imagine dragons', 'USA', 2008, 'Alternative'),
		(3, 'Little Big', 'Russia', 2013, 'Raiv'),
        (4, 'Our last night', 'USA', 2004, 'Rock'),
        (5, 'Slipknot', 'USA', 1995, 'Rock'),
        (6, 'Billy Eilish', 'USA', 2015, 'Pop'),
		(7, '30 STM', 'USA', 1998, 'Rock')
GO

-- insert into MusicView(recordId, artist_name, nationality, org_year, genre)
-- 	values
--     (8, 'Billy Eilish', 'USA', 2015, 'Pop')
-- go

SELECT * from lab141.dbo.Music;
SELECT * from lab142.dbo.Music;

SELECT * FROM MusicView;
GO

if OBJECT_ID(N'UpdateTrigger') is not null
	drop TRIGGER UpdateTrigger;
go

CREATE TRIGGER UpdateTrigger on MusicView
    INSTEAD of update
AS
BEGIN
    if update(recordId)
        begin
            exec sp_addmessage 50003, 15, N'Cant chande ID', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(50003, 15, -1)
        END

    update lab142.dbo.Music
    set genre = inserted.genre, org_year = inserted.org_year
    from inserted
    where inserted.recordId = lab142.dbo.Music.recordId
END
GO

update MusicView set genre = 'UPDATECHECKING' where org_year < 2000
go

update MusicView set org_year = 1997 where org_year = 1998
go

-- update MusicView set recordId = 107 where org_year > 2014
-- GO

select * from MusicView
go

if OBJECT_ID(N'DeleteTrigger') is not null
	drop TRIGGER DeleteTrigger;
go

CREATE TRIGGER DeleteTrigger on MusicView
    INSTEAD of delete
AS
    BEGIN
        delete C from lab141.dbo.Music as c inner join deleted as D
        on C.recordId = D.recordId
        delete C from lab142.dbo.Music as c inner join deleted as D
        on C.recordId = D.recordId
    END
GO

delete from MusicView where genre = 'Rock'
go

select * from MusicView
go

SELECT * from lab141.dbo.Music;
SELECT * from lab142.dbo.Music;