USE [DEVAAHOA_MSCRM]
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

SELECT  @lat1= aahoa_latitude,
        @long1 = aahoa_longitude 

FROM 
		Filteredaahoa_uspszipcodemapping z
WHERE 
		z.aahoa_zipcode = @ZipCode

SELECT
		c.bpt_memberid
		,c.fullname
		,c.address1_line1
		,c.address1_city
		,c.address1_stateorprovince
		,c.address1_postalcode

FROM
(
	SELECT  aahoa_primarycity,aahoa_longitude,aahoa_latitude,aahoa_zipcode,
			3958.75 * ( Atan(Sqrt(1 - power(((Sin(@Lat1/57.2958) * 
			Sin(aahoa_latitude/57.2958)) + (Cos(@Lat1/57.2958) * 
			Cos(aahoa_latitude/57.2958) * Cos((aahoa_longitude/57.2958) - 
			(@Long1/57.2958)))), 2)) / ((Sin(@Lat1/57.2958) * 
			Sin(aahoa_latitude/57.2958)) + (Cos(@Lat1/57.2958) * 
			Cos(aahoa_latitude/57.2958) * Cos((aahoa_longitude/57.2958) - 
			(@Long1/57.2958)))))) MileRadius
	FROM Filteredaahoa_uspszipcodemapping
)  Filteredaahoa_uspszipcodemapping 
		FULL OUTER JOIN FilteredContact as c on Filteredaahoa_uspszipcodemapping.aahoa_zipcode = c.address1_postalcode
    WHERE
 --       Filteredaahoa_uspszipcodemapping.aahoa_latitude between @Min_Lat and @Max_Lat
 --   AND
 --       Filteredaahoa_uspszipcodemapping.aahoa_longitude between @Min_Lng and @Max_Lng 
	--AND 
		c.address1_postalcode is not null
	AND
		Filteredaahoa_uspszipcodemapping.aahoa_primarycity = c.address1_city
	AND
		Filteredaahoa_uspszipcodemapping.MileRadius <= @GivenMileRadius
	AND 
		aahoa_zipcode <> @ZipCode
ORDER BY MileRadius
option (querytraceon 8780)

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
--        @primarycity = z.aahoa_primarycity,
--        @state = z.aahoa_state,
--        @zipcode = z.aahoa_zipcode,
--        @latitude = z.aahoa_latitude,
--        @longitude = z.aahoa_longitude
        
--    FROM
--        Filteredaahoa_uspszipcodemapping z
    
--	WHERE
--        z.aahoa_zipcode = @ZipCodeSelect
		
-- --   SET  @Min_Lat= @latitude - @flDegreeRadius
-- --   SET @Min_Lng = @longitude - @flDegreeRadius
--	--SET @Max_Lat = @latitude + @flDegreeRadius
--	--SET	@Max_Lng = @longitude + @flDegreeRadius
--	SET  @Min_Lat= @latitude - @flDegreeRadius
--    SET @Min_Lng = @longitude - @intMileRadius/ABS(cos(radians(@latitude))*@flMilesPerDegree)
--	SET @Max_Lat = @latitude + @flDegreeRadius
--	SET	@Max_Lng = @longitude + @intMileRadius/ABS(cos(radians(@latitude))*@flMilesPerDegree)


--    SELECT
--		c.bpt_memberid
--		,c.fullname
--		,c.address1_line1
--		,c.address1_city
--		,c.address1_stateorprovince
--		,c.address1_postalcode
--    FROM
--        Filteredaahoa_uspszipcodemapping z
--		FULL OUTER JOIN FilteredContact as c on z.aahoa_zipcode = c.address1_postalcode
--    WHERE
--        z.aahoa_latitude between @Min_Lat and @Max_Lat
--    AND
--        z.aahoa_longitude between @Min_Lng and @Max_Lng 
--	AND 
--		c.address1_postalcode is not null
--	AND
--		z.aahoa_primarycity = c.address1_city


--END 
--GO