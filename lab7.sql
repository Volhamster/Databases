use GymnastCard2;
go
--________________________________________________________

--Создать представление на основе одной из таблиц задания 6.
if OBJECT_ID(N'GymnastView') is not NULL
    drop view GymnastView;
go

create view GymnastView AS
    SELECT *
    from gymnast
    where weightNum between 45 and 55;
GO

select * from GymnastView;
go

--Создать представление на основе полей обеих связанных таблиц задания 6.

if OBJECT_ID(N'ArtistsInfoView') is not NULL
    drop view ArtistsInfoView;
go

create view ArtistsInfoView AS
    SELECT a.artistID, a.artistName,
            r.recordID, r.artID, r.recordName
    from artist as a join record as r on r.artID=a.artistID 
GO

select * from ArtistsInfoView;
go

--Создать индекс для одной из таблиц задания 6, включив в него дополнительные неключевые поля.
if exists (select * from sys.indexes where name = N'Coach_Ind')
    DROP INDEX Coach_Ind on coach;
go

CREATE INDEX Coach_Ind
    on coach (coachName)
    INCLUDE (coachId, degree);
go

 select * from coach WHERE coachName = 'Elena Petrova';
 go

-- Создать индексированное представление.
if OBJECT_ID (N'CoachIndView') is not NULL
    drop view CoachIndView;
GO

CREATE VIEW CoachIndView with SCHEMABINDING
AS
    SELECT coachId, coachName, degree
    from dbo.coach
    where degree in ('MSMK');
go


DROP INDEX Coach_Ind on coach;
GO

CREATE UNIQUE CLUSTERED INDEX Coach_Degree
    on CoachIndView (coachId, coachName, degree);
GO

SELECT * from CoachIndView
go