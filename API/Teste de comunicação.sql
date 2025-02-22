DECLARE @Object INT;
DECLARE @ResponseText NVARCHAR(MAX);
DECLARE @URL NVARCHAR(500) = 'https://www.google.com';

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
EXEC sp_OAMethod @Object, 'open', NULL, 'GET', @URL, 'false';
EXEC sp_OAMethod @Object, 'send';
EXEC sp_OAGetProperty @Object, 'responseText', @ResponseText OUT;
EXEC sp_OADestroy @Object;

SELECT @ResponseText AS API_Response;




