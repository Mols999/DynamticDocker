codeunit 50101 WooService
{
    var
        Client: HttpClient;
        // WooCommerce API
        Ck: Label 'ck_b966c4018a5088e58b3f046e4275b15eac94b294';
        Cs: Label 'cs_56e1fe10a6ccfffba7b2c4dca4352bce02644d24';

    // Procedure to insert an item into WooCommerce
    procedure InsertItem(Item: Record Item)
    var
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;
        JsonBody: JsonObject;
        ImageJson: JsonObject;
        ImageArray: JsonArray;
        Body: Text;
    begin
        JsonBody.Add('name', Item.Description);
        JsonBody.Add('regular_price', Format(Item."Unit Price", 0, 2));
        JsonBody.Add('description', Item."Long Description");
        JsonBody.Add('type', 'simple');
        JsonBody.Add('status', 'publish');
        JsonBody.Add('manage_stock', true);
        JsonBody.Add('stock_quantity', Item.Inventory);
        ImageJson.Add('src', Item."Photo URL");
        ImageArray.Add(ImageJson);
        JsonBody.Add('images', ImageArray);

        JsonBody.WriteTo(Body);

        CreateHttpRequestMessage('POST', 'http://192.168.87.105:81/wordpress/wp-json/wc/v3/products', Body, Request);

        if Client.Send(Request, Response) then begin
            if Response.IsSuccessStatusCode() then begin
                JsonBody := GetBodyAsJsonObject(Response);
                Message('Product posted successfully: ' + GetFieldTextAsText(JsonBody, 'name'));
            end else begin
                HandleErrorResponse(Response);
            end;
        end else begin
            Message('Failed to post product: Unable to send request.');
        end;
    end;

    // Local procedure to set the authorization headers
    local procedure SetAuth()
    begin
        if not (Client.DefaultRequestHeaders.Contains('User-Agent') and
                Client.DefaultRequestHeaders.Contains('Authorization')) then begin
            Client.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
            Client.DefaultRequestHeaders.Add('Authorization', CreateAuthString());
        end;
    end;

    // Local procedure to create an HTTP request message
    local procedure CreateHttpRequestMessage(Method: Text; Url: Text; Body: Text; var Request: HttpRequestMessage)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
    begin
        SetAuth();
        Request.SetRequestUri(Url);
        Request.Method := Method;
        if Body <> '' then begin
            Content.WriteFrom(Body);
            Content.GetHeaders(Headers);
            Headers.Clear();
            Headers.Add('Content-Type', 'application/json');
            Request.Content := Content;
        end;
    end;

    // Local procedure to create an authorization string
    local procedure CreateAuthString() AuthString: Text
    var
        TypeHelper: Codeunit "Base64 Convert";
    begin
        AuthString := STRSUBSTNO('%1:%2', Ck, Cs);
        AuthString := TypeHelper.ToBase64(AuthString);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
    end;

    // Local procedure to get the body of an HTTP response as a JSON object
    local procedure GetBodyAsJsonObject(Response: HttpResponseMessage) JsonBody: JsonObject
    var
        Body: Text;
    begin
        Response.Content.ReadAs(Body);
        JsonBody.ReadFrom(Body);
    end;

    // Local procedure to get the text of a field from a JSON object
    local procedure GetFieldTextAsText(JObject: JsonObject; fieldName: Text): Text
    var
        returnVal: Text;
        JToken: JsonToken;
    begin
        if JObject.Get(fieldName, JToken) then
            returnVal := JToken.AsValue().AsText();

        exit(returnVal);
    end;

    // Local procedure to handle error responses
    local procedure HandleErrorResponse(Response: HttpResponseMessage)
    var
        ErrorMessage: Text;
        Body: Text;
        JsonBody: JsonObject;
    begin
        ErrorMessage := Format(Response.HttpStatusCode) + ' ' + Response.ReasonPhrase;
        if Response.Content.ReadAs(Body) then begin
            JsonBody.ReadFrom(Body);
            ErrorMessage := ErrorMessage + ': ' + GetFieldTextAsText(JsonBody, 'message');
        end;
        Message('Failed to post product: ' + ErrorMessage);
    end;
}
