--create database
use master;
go
if DB_ID (N'lab8') is not null
drop database lab8;
go

-- execute the CREATE DATABASE statement
create database lab8
on ( 
	NAME = lab8_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab8/lab8dat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = lab8_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab8/lab8log.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go

use lab8;
go

if OBJECT_ID(N'Music') is not null
	drop table Music;
go

create table Music (
	recordId int IDENTITY(101,1) PRIMARY KEY,
	artist_name varchar(50) not null,
	nationality varchar(30) null default '-',
	org_year int not null
        check (org_year > 1900 and org_year < 2020),
	genre varchar(30) null
        check (genre in ('Rock', 'Pop', 'Rap', 'Alternative', 'Blues', 'Raiv'))
	);
go

insert into Music(artist_name, nationality, org_year, genre)
	values
        ('Bring me the horizon', 'UK', 2004, 'Rock'),
        ('Imagine dragons', 'USA', 2008, 'Alternative'),
		('Little Big', 'Russia', 2013, 'Raiv'),
        ('Our last night', 'USA', 2004, 'Rock'),
        ('Slipknot', 'USA', 1995, 'Rock'),
        ('Billy Eilish', 'USA', 2015, 'Pop'),
		('30 STM', 'USA', 1998, 'Rock')
go

select * from Music;
go

-- Создать хранимую процедуру, производящую выборку
-- из некоторой таблицы и возвращающую результат выборки в виде курсора

if OBJECT_ID(N'task1', N'P') is not NULL
    DROP PROCEDURE task1;
GO

CREATE PROCEDURE task1
    @cursor CURSOR VARYING OUTPUT
    AS
        set @cursor = CURSOR
        Forward_only static for
        SELECT artist_name, org_year
        from Music
		where org_year > 2008
        open @cursor;
go

DECLARE @music_cursor1 CURSOR;
DECLARE @chosenArtist1 varchar(50);
DECLARE @orgYear1 varchar(50);

EXEC task1 @cursor = @music_cursor1 output;

fetch next FROM @music_cursor1 into @chosenArtist1, @orgYear1;
print '   Artists organaized after 2008:   ';
PRINT @chosenArtist1;
WHILE (@@FETCH_STATUS =0)
BEGIN
    FETCH NEXT FROM @music_cursor1 into @chosenArtist1, @orgYear1;
	if (@@FETCH_STATUS =0)
	BEGIN
		PRINT @chosenArtist1;
	END
END

CLOSE @music_cursor1;
deallocate @music_cursor1;
go


-- Модифицировать хранимую процедуру п.1. таким образом, чтобы
-- выборка осуществлялась с формированием столбца, значение которого
-- формируется пользовательской функцией.
if OBJECT_ID(N'age_calc') is NOT NULL
    DROP FUNCTION age_calc;
go

CREATE FUNCTION age_calc (@year int)
    returns INT
    AS
        BEGIN
            DECLARE @ageRes INT
            SET @ageRes = 2019 - @year
            return (@ageRes)
        end;
GO
    

if OBJECT_ID(N'task2', N'P') is not NULL
    DROP PROCEDURE task2;
GO

CREATE PROCEDURE task2
    @cursor CURSOR VARYING OUTPUT
    AS
        set @cursor = CURSOR
        Forward_only static for
        SELECT artist_name, nationality, org_year, genre, dbo.age_calc(org_year) as age
        from Music
        open @cursor;
go

DECLARE @music_cursor2 CURSOR;
DECLARE @chosenArtist2 varchar(50);
DECLARE @artist_name2 varchar(50);
DECLARE @nationality2 varchar(50);
DECLARE @org_year2 varchar(50);
DECLARE @genre2 varchar(50);
DECLARE @age2 varchar(50);

EXEC task2 @cursor = @music_cursor2 output;

fetch next FROM @music_cursor2 into @artist_name2, @nationality2, @org_year2, @genre2, @age2;
print '   TASK 2   ';
Select @chosenArtist2 = @artist_name2 + ' - ' + @age2;
PRINT @chosenArtist2;
WHILE (@@FETCH_STATUS =0)
BEGIN
fetch next FROM @music_cursor2 into @artist_name2, @nationality2, @org_year2, @genre2, @age2;
	if (@@FETCH_STATUS =0)
	BEGIN
		Select @chosenArtist2 = @artist_name2 + ' - ' + @age2;
		PRINT @chosenArtist2;
	END
END

CLOSE @music_cursor2;
deallocate @music_cursor2;
go

-- Создать хранимую процедуру, вызывающую процедуру п.1., осуществляющую
-- прокрутку возвращаемого курсора и выводящую сообщения, сформированные
-- из записей при выполнении условия, заданного еще одной пользовательской
-- функцией.


if OBJECT_ID(N'task3', N'P') is not NULL
    DROP PROCEDURE task3;
GO

CREATE PROCEDURE task3
AS
    DECLARE @music_cursor3 CURSOR
	DECLARE @chosenArtist3 varchar(50)
	DECLARE @orgYear3 varchar(50)
	DECLARE @age3 varchar(50)

	EXEC task1 @cursor = @music_cursor3 output;

	print '   Artists organaized after 2008 older then 5 years:   ';
		
	fetch next FROM @music_cursor3 into @chosenArtist3, @orgYear3;

	WHILE (@@FETCH_STATUS =0)
		BEGIN
    	select @age3 = dbo.age_calc(@orgYear3)
		if (@age3 > 5)
			BEGIN
				PRINT 'art: ' + @chosenArtist3 + ', orgYear: ' + @orgYear3 + ', age: ' + @age3;
			END
		fetch next FROM @music_cursor3 into @chosenArtist3, @orgYear3;
		END

	CLOSE @music_cursor3;
	deallocate @music_cursor3;
go

EXEC dbo.task3
go

-- Модифицировать хранимую процедуру п.2. таким образом, чтобы выборка
-- формировалась с помощью табличной функции.
if OBJECT_ID(N'func4', N'P') is not NULL
    DROP FUNCTION func4;
GO

CREATE FUNCTION func4()
RETURNS TABLE
AS
RETURN(
	select recordId, artist_name, nationality, org_year, genre, dbo.age_calc(org_year) as age
	from Music
	where (org_year > 2013)
)
go

-- if OBJECT_ID(N'func42', N'P') is not NULL
--     DROP FUNCTION func42;
-- GO

-- CREATE FUNCTION func42()
-- RETURNS
--     @cursor TABLE (
-- 		recordId int IDENTITY(101,1) PRIMARY KEY,
-- 		artist_name varchar(50) not null,
-- 		nationality varchar(30) null default '-',
-- 		org_year int not null
--         	check (org_year > 1900 and org_year < 2020),
-- 		genre varchar(30) null
--         	check (genre in ('Rock', 'Pop', 'Rap', 'Alternative', 'Blues', 'Raiv'))
-- 	)
--     AS
-- 	BEGIN
--         DECLARE @temp TABLE (
-- 			recordId int IDENTITY(101,1) PRIMARY KEY,
-- 			artist_name varchar(50) not null,
-- 			nationality varchar(30) null default '-',
-- 			org_year int not null
--         		check (org_year > 1900 and org_year < 2020),
-- 			genre varchar(30) null
--         		check (genre in ('Rock', 'Pop', 'Rap', 'Alternative', 'Blues', 'Raiv'))
-- 		)
-- 		INSERT @temp
-- 		select recordId, artist_name, nationality, org_year, genre
-- 		from Music
-- 		where (org_year > 2013)
-- 		INSERT @cursor
-- 		SELECT recordId, artist_name, nationality, org_year, genre
-- 			from @temp
-- 			rerurn
-- end
-- go

if OBJECT_ID(N'task4', N'P') is not NULL
    DROP PROCEDURE task4;
GO

CREATE PROCEDURE task4
    @cursor4 cursor VARYING OUTPUT
    AS
	set @cursor4 = CURSOR Forward_only static for
	select * from dbo.func4() -- inner join dbo.func4() on a.id = b.id
	open @cursor4
go

DECLARE @music_cursor4 CURSOR
DECLARE @artName4 VARCHAR(50)

EXECUTE task4 @cursor4 = @music_cursor4 OUTPUT;

FETCH NEXT FROM @music_cursor4;
WHILE (@@FETCH_STATUS = 0)
	BEGIN
		FETCH NEXT FROM @music_cursor4
	END

CLOSE @music_cursor4;
DEALLOCATE @music_cursor4;
GO