--create database
use master;
go
if DB_ID (N'GymnastCard') is not null
drop database GymnastCard;
go

-- execute the CREATE DATABASE statement
create database GymnastCard
on ( 
	NAME = GymCard_dat, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab5/gymcarddat.mdf',
	SIZE = 10, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5 
	)
log on (
	NAME = GymCard_log, 
	FILENAME = '/Users/olgakotova/Documents/DataBasesLabs/lab5/gymcardlog.ldf',
	SIZE = 5, 
	MAXSIZE = 20, 
	FILEGROWTH = 5 
	);
go


--alter db
alter database GymnastCard
	add filegroup lab5fg;
go
alter database GymnastCard
	add file (
		name = extrafile,
		filename = '/Users/olgakotova/Documents/DataBasesLabs/lab5/gymcard_ex.ndf',
		size = 5,
		maxsize = 10,
		filegrowth = 1 
		)
	to filegroup lab5fg
go
alter database GymnastCard
	modify filegroup lab5fg default;
go
alter database GymnastCard
	modify filegroup [primary] default;
go


use GymnastCard
go
--create table
if OBJECT_ID(N'gymnast', N'U') is not null
	drop table gymnast;
go
create table gymnast (
	gymnastID int not null,
	gymnastName varchar(100) not null,
	height int not null,
	weightNum int not null,
	nationality varchar(30) not null,
	birthDate date not null,
	degree varchar(30) null
	);
go

insert into gymnast(gymnastID, gymnastName, height, weightNum, nationality, birthDate, degree)
	values (
		101, 
		'Margarita Mamun', 
		170, 
		50, 
		'Russian',
		'01-11-1995',
		'MSMK');

select * from gymnast;
go


--create extra table
if OBJECT_ID(N'extratable', N'U') is not null
	drop table extratable;
go
create table extratable (
	name varchar(35) null
	);
go


--remove filegroup
alter database GymnastCard
	remove file extrafile;
go
alter database GymnastCard
	remove filegroup lab5fg;
go

--create schema
if SCHEMA_ID(N'lab5schema') is not null
	drop schema lab5schema;
go
create schema lab5schema;
go

--modify schema
alter schema lab5schema 
	transfer extratable;
go
if OBJECT_ID(N'lab5schema.extratable', N'U') is not null
	drop table lab5schema.extratable;
go

--drop schema
drop schema lab5schema;
go
