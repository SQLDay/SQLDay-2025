/* #############################################
   ##  WYSY£ANIE ZAPYTANIA DO API OPENAI    ##
   ##  PRZYK£AD WYKORZYSTANIA              ##
   ##  sp_invoke_external_rest_endpoint    ##
   ############################################# */


/* 1. Deklaracja zmiennych do wysy³ania zapytania */
DECLARE @url NVARCHAR(4000) = N'podaj swoj endpoint';
DECLARE @headers NVARCHAR(102) = N'{"api-key":"podaj swoj api key"}';

/* 2. Tworzenie JSON-a z zapytaniem do API OpenAI */
DECLARE @payload NVARCHAR(MAX) = '{
    "model": "gpt-4",
    "messages": [
        {"role": "system", "content": "Jestes swietnym asystentem, który pomaga w zwiedzaniu miast"},
        {"role": "user", "content": "Opowiedz mi o hali stulecia?"}
    ],
    "max_tokens": 100
}';

/* 3. Deklaracja zmiennych na wynik zapytania */
DECLARE @ret INT, @response NVARCHAR(MAX);

/* 4. Wykonanie zapytania do API OpenAI */
EXEC @ret = sp_invoke_external_rest_endpoint
    @url = @url,
    @method = 'POST',
    @headers = @headers,
    @payload = @payload,
    @timeout = 230,
    @response = @response OUTPUT;

/* 5. Wyœwietlenie wyniku odpowiedzi API */
SELECT 
    @ret AS ReturnCode, 
    @response AS Response, 
    JSON_VALUE(@response, '$.result.choices[0].message.content') AS Content;
