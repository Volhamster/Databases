use master;
go

if DB_ID (N'lab151') is not null
drop database lab151;
go

-- execute the CREATE DATABASE statement
create database lab151
on ( 
	NAME = lab151_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab151/lab151dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = lab151_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab151/lab151log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

use master;
go
if DB_ID (N'lab152') is not null
drop database lab152;
go

-- execute the CREATE DATABASE statement
create database lab152
on ( 
	NAME = lab152_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab152/lab152dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = lab152_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab152/lab152log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

--Создать в базах данных пункта 1 задания 13 связанные таблицы.

use lab151;
GO

if OBJECT_ID(N'Music') is not null
	drop table Music;
go

create table Music (
	recordId int PRIMARY KEY not null,
	artist_name varchar(50) unique not null,
	nationality varchar(30) null default '-',
	org_year int not null
        check (org_year > 1900 and org_year < 2020),
	genre varchar(30) null,
    songId int
    );
go

use lab152;
GO

if OBJECT_ID(N'record') is not null
	drop table record;
go

create TABLE record (
	songId int not null PRIMARY KEY,
	recordName VARCHAR(50) unique
)
GO

-- Создать необходимые элементы базы данных (представления, триггеры),
-- обеспечивающие работу с данными связанных таблиц
-- (выборку, вставку, изменение, удаление).


if OBJECT_ID(N'InsertTriggerRecord') is not null
	drop TRIGGER InsertTriggerRecord;
go

CREATE TRIGGER InsertTriggerRecord on record
    INSTEAD of INSERT
AS
BEGIN
    if EXISTS (SELECT a.songId
        FROM lab152.dbo.record as a, inserted as I
        WHERE a.songId = I.songId)
        begin
            exec sp_addmessage 50002, 15, N'ID is busy', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(50002, 15, -1)
        END
    ELSE
        BEGIN
            INSERT into lab152.dbo.record(songId, recordName)
            SELECT songId, recordName
            from inserted
        end
END
GO

if OBJECT_ID(N'UpdateTriggerRecord') is not null
	drop TRIGGER UpdateTriggerRecord;
go

CREATE TRIGGER UpdateTriggerRecord on record
    AFTER update
AS
BEGIN
    if update(songId)
        begin
            exec sp_addmessage 50003, 15, N'Cant chande ID', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(50003, 15, -1)
        END
    ELSE
    BEGIN
        update lab152.dbo.record
        set recordName = inserted.recordName
        from inserted
        where inserted.songId = lab152.dbo.record.songId
    END
END
GO

if OBJECT_ID(N'DeleteTriggerRecord') is not null
	drop TRIGGER DeleteTriggerRecord;
go

CREATE TRIGGER DeleteTriggerRecord on record
    INSTEAD of delete
AS
    BEGIN
        delete C from lab151.dbo.Music as c inner join deleted as D
        on C.songId = D.songId
        
        -- delete from lab151.dbo.Music songId
        -- WHERE songId in (select d.songId from deleted as d)

        -- UPDATE lab151.dbo.Music set songId = NULL
        -- where songId in (select a.songId
		-- 		from lab151.dbo.Music as a, deleted as d
        --         where a.songId=d.songId)

        delete C from lab152.dbo.record as c inner join deleted as D
        on C.songId = D.songId
    END
GO

use lab151;
GO
if OBJECT_ID(N'InsertTrigger') is not null
	drop TRIGGER InsertTrigger;
go

CREATE TRIGGER InsertTrigger on Music
    after INSERT
AS
BEGIN
        if update(songId)
        begin
        
        -- if exists (select id from inserted where id not in (select id from T))

        if not EXISTS (SELECT r.songId
        FROM lab152.dbo.record as r, inserted as I
        WHERE I.songId in (select r.songId))

        begin
            exec sp_addmessage 50005, 15, N'INSERT: There is no some record with this ID', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(50005, 15, -1)
        END
        end
END
GO

if OBJECT_ID(N'UpdateTrigger') is not null
	drop TRIGGER UpdateTrigger;
go

CREATE TRIGGER UpdateTrigger on Music
    after update
AS
BEGIN
    if update(songId)
    begin
    if not EXISTS (SELECT r.songId
        FROM lab152.dbo.record as r, inserted as I
        WHERE r.songId = I.songId
        )
        begin
            exec sp_addmessage 50008, 15, N'UPDATE: There is no record with this ID', @lang='us_english', @replace = 'REPLACE';
            RAISERROR(50008, 15, -1)
        END
        end
END
GO

if OBJECT_ID(N'MusicView') is not null
	drop view MusicView;
go

CREATE view MusicView AS
    SELECT a.recordId as recordId,
        a.artist_name as artist_name,
        a.nationality as nationality,
        a.org_year as org_year,
        a.genre as genre,
        b.*
    FROM lab151.dbo.Music as a right outer join lab152.dbo.record as b
    on a.songId = b.songId
go

insert into lab152.dbo.record(songId, recordName)
	values
        (101, 'Antivist'),
	    (102, 'Radioactive'),
        (103, 'Faradenza'),
        (104, 'Ocean'),
        (105, 'Orphan'),
	    (106, 'Bad guy'),
	    (107, 'Bury')
GO

insert into lab151.dbo.Music(recordId, artist_name, nationality, org_year, genre, songId)
	values
        (1, 'Bring me the horizon', 'UK', 2004, 'Rock', 101),
        (2, 'Imagine dragons', 'USA', 2008, 'Alternative', 102),
		(3, 'Little Big', 'Russia', 2013, 'Raiv', 103),
        (4, 'Our last night', 'USA', 2004, 'Rock', 104),
        (5, 'Slipknot', 'USA', 1995, 'Rock', 105),
        (6, 'Billy Eilish', 'USA', 2015, 'Pop', 106),
		(7, '30 STM', 'USA', 1998, 'Rock', 107)
GO

SELECT * from lab151.dbo.Music;
SELECT * from lab152.dbo.record;
go


DELETE FROM lab151.dbo.Music where genre = 'Raiv';
GO

DELETE FROM lab152.dbo.record WHERE recordName = 'Ocean';
GO

SELECT * from lab151.dbo.Music;
SELECT * from lab152.dbo.record;
go

INSERT into lab152.dbo.record(songId, recordName)
VALUES
(108, 'FATHER');
go

SELECT * from lab151.dbo.Music;
SELECT * from lab152.dbo.record;
go


update lab151.dbo.Music set genre = 'UPDATECHECKING' where org_year < 2000
go
UPDATE lab152.dbo.record set recordName = 'CHANGE' where songId = 102;
GO

SELECT * from lab151.dbo.Music;
SELECT * from lab152.dbo.record;
go

-- Errors
-- insert into lab151.dbo.Music(recordId, artist_name, nationality, org_year, genre)
-- 	values
--     (8, 'Billy Eilish', 'USA', 2015, 'Pop')
-- go

-- insert into lab152.dbo.record(songId, recordName)
-- VALUES
--     (102, 'Error')
-- go

insert into lab151.dbo.Music(recordId, artist_name, nationality, org_year, genre, songId)
	values
    (11, 'Katya', 'USA', 2015, 'Pop', 106)
go

UPDATE lab151.dbo.Music set songId = 102 where artist_name = 'Katya'
go

--err
-- insert into lab151.dbo.Music(recordId, artist_name, nationality, org_year, genre, songId)
-- 	values
--     (11, 'Katya', 'USA', 2015, 'Pop', 120)
-- go

-- UPDATE lab151.dbo.Music set songId = 112 where artist_name = 'Katya'
-- go

SELECT * from lab151.dbo.Music;
go

SELECT * from lab152.dbo.record;
go

SELECT * from MusicView;
go