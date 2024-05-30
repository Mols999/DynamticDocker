codeunit 50105 "SalesOrderManagement"
{
    // Procedure to create a sales order from a JSON string
    [ServiceEnabled]
    procedure CreateSalesOrder(salesOrderJson: Text): Boolean;
    var
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        customerEmail: Text;
        productNumber: Text;
        quantity: Decimal;
        EmailSubject: Text;
        EmailBody: Text;
        EmailSent: Boolean;
    begin

        JsonObj.ReadFrom(salesOrderJson);

        //Get the JSON input
        JsonObj.Get('customerEmail', JsonToken);
        customerEmail := JsonToken.AsValue().AsText();
        JsonObj.Get('productNumber', JsonToken);
        productNumber := JsonToken.AsValue().AsText();
        JsonObj.Get('quantity', JsonToken);
        quantity := JsonToken.AsValue().AsDecimal();

        Customer.SetRange("E-Mail", customerEmail);
        if not Customer.FindFirst() then
            Error('Customer with email %1 not found', customerEmail);

        if not Item.Get(productNumber) then
            Error('Product %1 not found', productNumber);

        // Initialize and filled in the Sales Header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Insert(true);

        // Initialize and filled in the Sales Line
        SalesLine.Init();
        SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine.Validate("Type", SalesLine."Type"::Item);
        SalesLine.Validate("No.", productNumber);
        SalesLine.Validate("Quantity", quantity);
        SalesLine."Unit Price" := Item."Unit Price";
        SalesLine."Line Amount" := SalesLine."Unit Price" * SalesLine.Quantity;
        SalesLine.Insert(true);
        SalesHeader.Modify(true);

        // Format the order confirmation email
        EmailSubject := 'Order Confirmation';
        EmailBody := '<html><body>';
        EmailBody += 'Dear ' + Customer.Name + ',<br/><br/>';
        EmailBody += 'Thank you for your order. Here are the details:<br/>';
        EmailBody += '<table border="1" style="border-collapse: collapse;">';
        EmailBody += '<tr><th>Product No.</th><th>Description</th><th>Quantity</th><th>Unit Price</th><th>Total Price</th></tr>';
        EmailBody += '<tr><td>' + productNumber + '</td><td>' + Item.Description + '</td><td>' + Format(quantity) + '</td><td>' + Format(SalesLine."Unit Price") + '</td><td>' + Format(SalesLine."Line Amount") + '</td></tr>';
        EmailBody += '</table>';
        EmailBody += '</body></html>';

        EmailSent := SendEmail(Customer."E-Mail", EmailSubject, EmailBody);

        exit(EmailSent);
    end;

    // Local procedure to send an email
    local procedure SendEmail(Recipient: Text; Subject: Text; Body: Text): Boolean;
    var
        Email: Codeunit "Email";
        EmailMessage: Codeunit "Email Message";
        IsEmailSent: Boolean;
        ToRecipients: List of [Text];
        CcRecipients: List of [Text];
        BccRecipients: List of [Text];
    begin
        ToRecipients.Add(Recipient);
        EmailMessage.Create(ToRecipients, Subject, Body, true, CcRecipients, BccRecipients);
        IsEmailSent := Email.Send(EmailMessage);
        exit(IsEmailSent);
    end;
}
