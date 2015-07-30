USE [yourservername]
--create fulltext catalog FullTextCatalog as default
GO
/****** Object:  StoredProcedure [dbo].[BP_GetNearbyContacts]    Script Date: 7/23/2015 10:53:21 AM ******/
SET NUMERIC_ROUNDABORT OFF 
GO 
SET ANSI_PADDING, NOCOUNT, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--********************************************************
--
-- [BP_GetNearbyContacts] -
--			
--

--			
-- Notes: This sproc returns all contacts within given mile radius of a zipcode (can easily change to city by changing parameter to city then change the first where clause to compare it to the new city parameter)	
--
--			
-- Author:		John Raesly; BroadPoint Technologies (jraesly@broadpoint.net)
--
-- Changes:		7-23-15	bc	Creation
--
								
--********************************************************



ALTER PROC [dbo].[BP_GetNearbyContacts]
(
	@ZipCode char(5) 
	, @GivenMileRadius int
)
AS

BEGIN

DECLARE @lat1 float, 
	@long1 float

SELECT  @lat1= latitude,
        @long1 = longitude 

FROM 
		Filterednew_uspszipcodemapping z
WHERE 
		z.zipcode = @ZipCode

SELECT
		c.memberid
		,c.fullname
		,c.address1_line1
		,c.address1_city
		,c.address1_stateorprovince
		,c.address1_postalcode

FROM
(
	SELECT  primarycity,longitude,latitude,zipcode,
			3958.75 * ( Atan(Sqrt(1 - power(((Sin(@Lat1/57.2958) * 
			Sin(latitude/57.2958)) + (Cos(@Lat1/57.2958) * 
			Cos(latitude/57.2958) * Cos((longitude/57.2958) - 
			(@Long1/57.2958)))), 2)) / ((Sin(@Lat1/57.2958) * 
			Sin(latitude/57.2958)) + (Cos(@Lat1/57.2958) * 
			Cos(latitude/57.2958) * Cos((longitude/57.2958) - 
			(@Long1/57.2958)))))) MileRadius
	FROM Filterednew_uspszipcodemapping
)  Filterednew_uspszipcodemapping 
		FULL OUTER JOIN FilteredContact as c on Filterednew_uspszipcodemapping.zipcode = c.address1_postalcode
    WHERE
 --       Filterednew_uspszipcodemapping.latitude between @Min_Lat and @Max_Lat
 --   AND
 --       Filterednew_uspszipcodemapping.longitude between @Min_Lng and @Max_Lng 
	--AND 
		c.address1_postalcode is not null
	AND
		Filterednew_uspszipcodemapping.primarycity = c.address1_city
	AND
		Filterednew_uspszipcodemapping.MileRadius <= @GivenMileRadius
	AND 
		zipcode <> @ZipCode
ORDER BY MileRadius
option (querytraceon 8780) -- Flag to optimize performance

END

--ALTER procedure [dbo].[BP_GetNearbyContacts]
--(
--	@intMileRadius int
--	, @ZipCodeSelect int
--)
--AS
--BEGIN
--	Declare @Min_Lat float
--	Declare @Min_Lng float
--	Declare @Max_Lat float
--	Declare @Max_Lng float
--	Declare @flMilesPerDegree decimal = 69.09
--	Declare @flDegreeRadius decimal = (@intMileRadius / @flMilesPerDegree)
--	Declare @primarycity nvarchar
--	Declare @state nvarchar
--	Declare @zipcode int
--	Declare @latitude float
--	Declare @longitude float
--	Declare @codezip nvarchar(30)

--	SELECT
--        @primarycity = z.primarycity,
--        @state = z.state,
--        @zipcode = z.zipcode,
--        @latitude = z.latitude,
--        @longitude = z.longitude
        
--    FROM
--        Filterednew_uspszipcodemapping z
    
--	WHERE
--        z.zipcode = @ZipCodeSelect
		
-- --   SET  @Min_Lat= @latitude - @flDegreeRadius
-- --   SET @Min_Lng = @longitude - @flDegreeRadius
--	--SET @Max_Lat = @latitude + @flDegreeRadius
--	--SET	@Max_Lng = @longitude + @flDegreeRadius
--	SET  @Min_Lat= @latitude - @flDegreeRadius
--    SET @Min_Lng = @longitude - @intMileRadius/ABS(cos(radians(@latitude))*@flMilesPerDegree)
--	SET @Max_Lat = @latitude + @flDegreeRadius
--	SET	@Max_Lng = @longitude + @intMileRadius/ABS(cos(radians(@latitude))*@flMilesPerDegree)


--    SELECT
--		c.memberid
--		,c.fullname
--		,c.address1_line1
--		,c.address1_city
--		,c.address1_stateorprovince
--		,c.address1_postalcode
--    FROM
--        Filterednew_uspszipcodemapping z
--		FULL OUTER JOIN FilteredContact as c on z.zipcode = c.address1_postalcode
--    WHERE
--        z.latitude between @Min_Lat and @Max_Lat
--    AND
--        z.longitude between @Min_Lng and @Max_Lng 
--	AND 
--		c.address1_postalcode is not null
--	AND
--		z.aahoa_primarycity = c.address1_city


--END 
--GO
