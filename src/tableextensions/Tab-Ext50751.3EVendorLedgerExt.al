tableextension 50751 "3E Vendor Ledger Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(50751; "Create Payment"; Boolean)
        {
            Caption = 'Create Payment';
            DataClassification = CustomerContent;
        }
        field(50752; "Payment Created"; Boolean)
        {
            Caption = 'Payment Created';
            DataClassification = CustomerContent;
        }
    }
}
