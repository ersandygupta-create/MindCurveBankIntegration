pageextension 50751 "3E Vendor Ledger Ext" extends "Vendor Ledger Entries"
{
    layout
    {
        addafter("Message to Recipient")
        {
            field("Create Payment"; Rec."Create Payment")
            {
                Caption = 'Create Payment';
                ApplicationArea = All;
                ToolTip = 'Create Payment';
            }
            field("Payment Created"; Rec."Payment Created")
            {
                Caption = 'Payment Created';
                ApplicationArea = All;
                ToolTip = 'Payment Created';
            }
        }
    }
    actions
    {
        addbefore("&Navigate")
        {
            action("Create Bank Payment")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Bank Payment';
                Image = SuggestVendorPayments;
                ToolTip = 'Create a payment journal based on the selected invoices.';

                trigger OnAction()
                var
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                    GenJournalBatch: Record "Gen. Journal Batch";
                    GenJnlManagement: Codeunit GenJnlManagement;
                    CreatePayment: Page "Create Bank Payment";
                begin
                    CurrPage.SetSelectionFilter(VendorLedgerEntry);
                    if CreatePayment.RunModal() = ACTION::OK then begin
                        CreatePayment.MakeGenJnlLines(VendorLedgerEntry);
                        GetBatchRecords(GenJournalBatch, CreatePayment);
                        GenJnlManagement.TemplateSelectionFromBatch(GenJournalBatch);
                        if VendorLedgerEntry.FindSet()then repeat VendorLedgerEntry."Payment Created":=true;
                                VendorLedgerEntry.Modify(true);
                            until VendorLedgerEntry.Next() = 0;
                        Clear(CreatePayment);
                    end
                    else
                        Clear(CreatePayment);
                end;
            }
        }
    }
    local procedure GetBatchRecords(var GenJournalBatch: Record "Gen. Journal Batch"; CreatePayment: Page "Create Bank Payment")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
    begin
        JournalTemplateName:=CreatePayment.GetTemplateName();
        JournalBatchName:=CreatePayment.GetBatchNumber();
        GenJournalTemplate.Get(JournalTemplateName);
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);
    end;
}
