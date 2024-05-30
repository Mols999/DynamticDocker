codeunit 50104 "CustomerManagement"
{
    [ServiceEnabled]

    // Procedure to create a new customer from a JSON string
    procedure CreateCustomer(customerJson: Text): Boolean;
    var
        JsonObj: JsonObject;
        CustomerRec: Record Customer;
        JCustomerNameToken: JsonToken;
        JCustomerEmailToken: JsonToken;
        JCustomerUsernameToken: JsonToken;
        EmailSubject: Text;
        EmailBody: Text;
        EmailSent: Boolean;
    begin
        //Get the JSON input
        JsonObj.ReadFrom(customerJson);
        JsonObj.Get('name', JCustomerNameToken);
        JsonObj.Get('email', JCustomerEmailToken);
        JsonObj.Get('username', JCustomerUsernameToken);

        //Initialize and filled in the Customer record
        CustomerRec.Init();
        CustomerRec.Validate(Name, JCustomerNameToken.AsValue().AsText());
        CustomerRec.Validate("E-Mail", JCustomerEmailToken.AsValue().AsText());
        CustomerRec.Validate(WooCommerceUsername, JCustomerUsernameToken.AsValue().AsText());
        CustomerRec.Validate("Gen. Bus. Posting Group", 'EU');
        CustomerRec.Validate("Customer Posting Group", 'EU');
        CustomerRec.Validate("Payment Terms Code", 'LM');


        if not CustomerRec.Insert(true) then
            exit(false);


        //Format the welcome email
        EmailSubject := 'Welcome to CompuTech';
        EmailBody := 'Dear ' + JCustomerNameToken.AsValue().AsText() +
                     ', Thank you for joining CompuTech. We are excited to have you as our customer! ';
        EmailSent := SendEmail(CustomerRec."E-Mail", EmailSubject, EmailBody);

        exit(EmailSent);
    end;

    //Local procedure to send an email
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
        EmailMessage.Create(ToRecipients, Subject, Body, false, CcRecipients, BccRecipients);
        IsEmailSent := Email.Send(EmailMessage);

        exit(IsEmailSent);
    end;
}
