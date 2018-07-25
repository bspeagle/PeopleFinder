/*
Tbis isn't my brilliance. I grabbed it somewhere off a google search. Mad props to whomever I took this from! :)
*/

CREATE DEFINER=CURRENT_USER PROCEDURE `getLocations`(IN origLat DOUBLE, IN origLon DOUBLE, IN dist INT)
SELECT email_address, city, region, latitude, longitude, 3956 * 2 *
          ASIN(SQRT( POWER(SIN((origLat - abs(latitude))*pi()/180/2),2)
          +COS(origLat*pi()/180 )*COS(abs(latitude)*pi()/180)
          *POWER(SIN((origLon-longitude)*pi()/180/2),2))) 
          as distance FROM mizuno1 WHERE 
          longitude between (origLon-dist/abs(cos(radians(origLat))*69))
          and (origLon+dist/abs(cos(radians(origLat))*69))
          and latitude between (origLat-(dist/69))
          and (origLat+(dist/69))
          having distance < dist ORDER BY distance