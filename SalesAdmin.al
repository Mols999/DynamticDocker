codeunit 50106 "Sales Admin"
{
    trigger OnRun()
    begin
        SendDailySalesSummary();
    end;

    // Procedure to send a daily summary of open sales orders via email
    procedure SendDailySalesSummary()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        EmailMsg: Codeunit "Email Message";
        EmailBody: Text;
        TotalTurnover: Decimal;
        IsEmailSent: Boolean;
        ToRecipients: List of [Text];
        CCRecipients: List of [Text];
        BCCRecipients: List of [Text];
    begin
        Clear(TempSalesLine);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);

        if SalesHeader.FindSet() then begin
            repeat
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindSet() then begin
                    repeat
                        if not TempSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then begin
                            TempSalesLine := SalesLine;
                            TempSalesLine.Insert();
                        end
                        else begin
                            TempSalesLine.Quantity += SalesLine.Quantity;
                            TempSalesLine.Amount += SalesLine.Amount;
                            TempSalesLine.Modify();
                        end;
                        TotalTurnover += SalesLine.Amount;
                    until SalesLine.Next() = 0;
                end;
            until SalesHeader.Next() = 0;
        end;

        // Format the email body
        EmailBody := '<html><body>';
        EmailBody += '<h1>Open Sales Orders Overview</h1>';
        EmailBody += '<table border="1" style="border-collapse: collapse;"><tr><th>Product No.</th><th>Description</th><th>Quantity Ordered</th><th>Amount</th></tr>';
        if TempSalesLine.FindSet() then begin
            repeat
                EmailBody += '<tr><td>' + TempSalesLine."No." + '</td><td>' + TempSalesLine.Description + '</td><td>' +
                             Format(TempSalesLine.Quantity) + '</td><td>' + Format(TempSalesLine.Amount) + '</td></tr>';
            until TempSalesLine.Next() = 0;
        end;
        EmailBody += '</table>';
        EmailBody += '<p>Total Open Order Value: ' + Format(TotalTurnover) + '</p>';
        EmailBody += '</body></html>';

        ToRecipients.Add('t.f.m@live.dk');
        IsEmailSent := SendEmail(ToRecipients, 'Daily Open Sales Orders Summary', EmailBody);

        if not IsEmailSent then
            Error('Failed to send the open sales orders summary email.');
    end;

    // Local procedure to send an email
    local procedure SendEmail(ToRecipients: List of [Text]; Subject: Text; Body: Text): Boolean;
    var
        Email: Codeunit "Email";
        EmailMessage: Codeunit "Email Message";
        IsEmailSent: Boolean;
        CCRecipients: List of [Text];
        BCCRecipients: List of [Text];
    begin
        EmailMessage.Create(ToRecipients, Subject, Body, true, CCRecipients, BCCRecipients);
        IsEmailSent := Email.Send(EmailMessage);

        exit(IsEmailSent);
    end;
}
