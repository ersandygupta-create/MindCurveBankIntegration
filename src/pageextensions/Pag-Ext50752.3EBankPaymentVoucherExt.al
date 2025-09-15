pageextension 50752 "3E Bank Payment Voucher Ext" extends "Bank Payment Voucher"
{
    actions
    {
        addafter("Test Report")
        {
            action("Bank Payment NotePad")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Payment NotePad';
                Image = XmlPort;
                //RunObject = xmlport "3E Bank Payment Notepad";
                RunPageMode = Edit;
            }
        }
    }
}
