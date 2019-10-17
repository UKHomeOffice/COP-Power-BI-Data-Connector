// Power BI Data Connector
// Connect to REST API with authentication provided by Keycloak
// Written by Matthew Bradley
[Version = "0.1.0"]
section REST_API_Keycloak;

//OAuth2 values
client_id = "<client>";
redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html";
token_uri = "<token>";
authorize_uri = "<auth>";
logout_uri = "<logout>";

[DataSource.Kind="REST_API_Keycloak", Publish="REST_API_Keycloak.Publish"]
shared REST_API_Keycloak.Contents = Value.ReplaceType(REST_API_KeycloakImpl, type function (url as Uri.Type) as any);

REST_API_KeycloakImpl = (url as text) =>
    let
        source = Web.Contents(url),
        json = Json.Document(source)
    in
        json;

// Data Source Kind description
REST_API_Keycloak = [
    TestConnection = (dataSourcePath) => {"REST_API_Keycloak.Contents", dataSourcePath},
    Authentication = [
         OAuth = [
            StartLogin=StartLogin,
            FinishLogin=FinishLogin,
            Refresh=Refresh,
            Logout=Logout
        ]
        // Key = [],
        // UsernamePassword = [],
        // Windows = [],
        //Implicit = []
    ],
    Label = Extension.LoadString("REST API") //Friendly display name for this extension in credential dialogs
];

// Data Source UI publishing description
REST_API_Keycloak.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = REST_API_Keycloak.Icons,
    SourceTypeImage = REST_API_Keycloak.Icons
];

REST_API_Keycloak.Icons = [
    Icon16 = { Extension.Contents("REST_API_Keycloak16.png"), Extension.Contents("REST_API_Keycloak20.png"), Extension.Contents("REST_API_Keycloak24.png"), Extension.Contents("REST_API_Keycloak32.png") },
    Icon32 = { Extension.Contents("REST_API_Keycloak32.png"), Extension.Contents("REST_API_Keycloak40.png"), Extension.Contents("REST_API_Keycloak48.png"), Extension.Contents("REST_API_Keycloak64.png") }
];

// Helper functions for OAuth2: StartLogin, FinishLogin, Refresh, Logout

StartLogin = (resourceUrl, state, display) =>
    let
        authorizeUrl = authorize_uri & "?" & Uri.BuildQueryString([
            response_type = "code",
            client_id = client_id,  
            redirect_uri = redirect_uri,
            state = state
        ])
    in
        [
            LoginUri = authorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = 720,
            WindowWidth = 1024,
            Context = null
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        // parse the full callbackUri, and extract the Query string
        parts = Uri.Parts(callbackUri)[Query],
        // if the query string contains an "error" field, raise an error
        // otherwise call TokenMethod to exchange our code for an access_token
        result = if (Record.HasFields(parts, {"error", "error_description"})) then 
                    error Error.Record(parts[error], parts[error_description], parts)
                 else
                    TokenMethod("authorization_code", "code", parts[code])
    in
        result;

Refresh = (resourceUrl, refresh_token) => TokenMethod("refresh_token", "refresh_token", refresh_token);

Logout = (token) => logout_uri;

//Converts the 'code' to an access_token OR requests a refresh token based on the grantType parameter
TokenMethod = (grantType, tokenField, code) =>
    let
        queryString = [
            grant_type = grantType,
            redirect_uri = redirect_uri,
            client_id = client_id
        ],
        queryWithCode = Record.AddField(queryString, tokenField, code),
        
        tokenResponse = Web.Contents(token_uri, [
            Content = Text.ToBinary(Uri.BuildQueryString(queryWithCode)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"
            ],
            ManualStatusHandling = {400} 
        ]),
        body = Json.Document(tokenResponse),
        result = if (Record.HasFields(body, {"error", "error_description"})) then 
                    error Error.Record(body[error], body[error_description], body)
                 else
                    body
    in
        result;
