pageextension 50103 "Customer Card Extension" extends "Customer Card"
{//Page extension to add WooCommerce Username to Customer Card
    layout
    {
        addfirst(Content)
        {
            field(WooCommerceUsername; Rec.WooCommerceUsername)
            {
                ApplicationArea = All;
            }
        }
    }
}
