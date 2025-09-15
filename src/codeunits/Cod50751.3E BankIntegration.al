codeunit 50751 "3E Bank Integration"
{
    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10])
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        GenJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if not GenJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName)then begin
            if not GenJnlBatch.FindFirst()then begin
                GenJnlBatch.Init();
                GenJnlBatch."Journal Template Name":=CurrentJnlTemplateName;
                GenJnlBatch.SetupNewBatch();
                GenJnlBatch.Name:=Text004;
                GenJnlBatch.Description:=Text005;
                GenJnlBatch.Insert(true);
                Commit();
            end;
            CurrentJnlBatchName:=GenJnlBatch.Name end;
    end;
    procedure TemplateSelectionSimple(var GenJnlTemplate: Record "Gen. Journal Template"; TemplateType: Enum "Gen. Journal Template Type"; RecurringJnl: Boolean): Boolean begin
        GenJnlTemplate.Reset();
        GenJnlTemplate.SetRange(Type, TemplateType);
        GenJnlTemplate.SetRange(Recurring, RecurringJnl);
        exit(FindTemplateFromSelection(GenJnlTemplate, TemplateType, RecurringJnl));
    end;
    local procedure FindTemplateFromSelection(var GenJnlTemplate: Record "Gen. Journal Template"; TemplateType: Enum "Gen. Journal Template Type"; RecurringJnl: Boolean)TemplateSelected: Boolean begin
        TemplateSelected:=true;
        case GenJnlTemplate.Count of 0: begin
            GenJnlTemplate.Init();
            GenJnlTemplate.Type:=TemplateType;
            GenJnlTemplate.Recurring:=RecurringJnl;
            if not RecurringJnl then begin
                GenJnlTemplate.Name:=GetAvailableGeneralJournalTemplateName(Format(GenJnlTemplate.Type, MaxStrLen(GenJnlTemplate.Name)));
                if TemplateType = GenJnlTemplate.Type::Assets then GenJnlTemplate.Description:=Text000
                else
                    GenJnlTemplate.Description:=StrSubstNo(Text001, GenJnlTemplate.Type);
            end
            else
            begin
                GenJnlTemplate.Name:=Text002;
                GenJnlTemplate.Description:=Text003;
            end;
            GenJnlTemplate.Validate(Type);
            OnFindTemplateFromSelectionOnBeforeGenJnlTemplateInsert(GenJnlTemplate);
            GenJnlTemplate.Insert();
            Commit();
        end;
        1: GenJnlTemplate.FindFirst();
        else
            TemplateSelected:=PAGE.RunModal(0, GenJnlTemplate) = ACTION::LookupOK;
        end;
    end;
    procedure GetAvailableGeneralJournalTemplateName(TemplateName: Code[10]): Code[10]var
        GenJnlTemplate: Record "Gen. Journal Template";
        PotentialTemplateName: Code[10];
        PotentialTemplateNameIncrement: Integer;
    begin
        // Make sure proposed value + incrementer will fit in Name field
        if StrLen(TemplateName) > 9 then TemplateName:=Format(TemplateName, 9);
        GenJnlTemplate.Init();
        PotentialTemplateName:=TemplateName;
        PotentialTemplateNameIncrement:=0;
        // Expecting few naming conflicts, but limiting to 10 iterations to avoid possible infinite loop.
        while PotentialTemplateNameIncrement < 10 do begin
            GenJnlTemplate.SetFilter(Name, PotentialTemplateName);
            if GenJnlTemplate.Count = 0 then exit(PotentialTemplateName);
            PotentialTemplateNameIncrement:=PotentialTemplateNameIncrement + 1;
            PotentialTemplateName:=TemplateName + Format(PotentialTemplateNameIncrement);
        end;
    end;
    local procedure OnFindTemplateFromSelectionOnBeforeGenJnlTemplateInsert(var GenJnlTemplate: Record "Gen. Journal Template")
    begin
    end;
    var Text000: Label 'Fixed Asset G/L Journal';
    #pragma warning disable AA0470
    Text001: Label '%1 journal';
    #pragma warning restore AA0470
    Text002: Label 'RECURRING';
    Text003: Label 'Recurring General Journal';
    Text004: Label 'DEFAULT';
    Text005: Label 'Default Journal';
}
