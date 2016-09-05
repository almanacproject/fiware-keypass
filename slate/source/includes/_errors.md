# Errors


The API uses the following error codes:


Error Code | Meaning
---------- | -------
400 | Bad Request -- Your request is wrong
401 | Unauthorized -- Your credentials are wrong
403 | Forbidden -- The resource requested has restricted access
404 | Not Found -- The specified resource could not be found
405 | Method Not Allowed -- You tried to access a resource with an invalid method
406 | Not Acceptable -- You requested a format that isn't JSON or XML
410 | Gone -- The resource requested has been removed from our servers
429 | Too Many Requests -- You're querying too frequently, we are throttling the service.
500 | Internal Server Error -- We had a problem with our server. Try again later.
503 | Service Unavailable -- We're temporarially offline for maintanance. Please try again later.
