DECLARE @GeoTable TABLE 
(
    id int identity(1,1),
    location geography
)
--Using geography::STGeomFromText
INSERT INTO @GeoTable 
SELECT geography::STGeomFromText('POINT(-3.8158099839714685 -38.506202424611146)', 4326)


DECLARE @DistanceFromPoint geography
SET @DistanceFromPoint =  geography::STGeomFromText('POINT(-3.8880850100802693 -38.48568571920507)', 4326);

--Retorna a distancia entre os dois pontos em metros
SELECT id,location.Lat Lat,location.Long Long,location.STDistance(@DistanceFromPoint)Distance
FROM @GeoTable;

--Retorna a distancia entre os dois pontos em km
SELECT id,location.Lat Lat,location.Long Long,location.STDistance(@DistanceFromPoint) / 1000 Distance
FROM @GeoTable;
