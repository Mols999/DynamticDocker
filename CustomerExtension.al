tableextension 50103 "Customer Extension" extends Customer
{//Table extension to add WooCommerce Username to the database
    fields
    {
        field(50100; WooCommerceUsername; Code[50])
        {
            Caption = 'WooCommerce Username';
        }
    }
}
