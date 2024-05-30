tableextension 50100 ItemExtension extends Item
{
    fields //Table extension to add Photo URL and Long Description to the database
    {
        field(50100; "Photo URL"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Long Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
}