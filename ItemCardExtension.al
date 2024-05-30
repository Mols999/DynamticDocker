pageextension 50100 ItemCardExtension extends "Item Card"
{ //Page extension to add Photo URL and Description 
    layout
    {
        addfirst(Content)
        {
            group("WooCommerce Integration")
            {
                field("Photo URL"; Rec."Photo URL")
                {
                    ApplicationArea = All;
                }
                field("Long Description"; Rec."Long Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions  // Action to post the item to WooCommerce
    {
        addfirst(Processing)
        {
            action("Post to WooCommerce")
            {
                ApplicationArea = All;
                Caption = 'Post to WooCommerce';
                Image = Export;

                trigger OnAction()
                var
                    WooCommerceService: Codeunit "WooService";
                begin
                    WooCommerceService.InsertItem(Rec);
                end;
            }
        }
    }
}
