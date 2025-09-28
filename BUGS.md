**Bugs:**

- 1) API request to https://app.boomnow.com/open_api/v1/auth/token, using params: {"client_id": "boom_3a21..4814", "client_secret": "76df8...7c76"}
failed to return JSON response but instead return a HTML page with next error message in the body:

    _We're sorry but dvr-dashboard doesn't work properly without JavaScript enabled. Please enable it to continue._
