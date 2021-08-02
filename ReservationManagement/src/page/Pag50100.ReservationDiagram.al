page 50120 "Reservation Management"
{

    Caption = 'Reservation Management';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            usercontrol(D3; D3)
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    CurrPage.D3.Refresh(format(AzureFunction.GetSankeyData()));
                end;
            }
            group(NonReservedLines)
            {
                part(UnReservedLines; NonReservedSalesLines)
                {
                    ApplicationArea = All;
                    SubPageLink = "No." = const('A'), "Reserved Qty. (Base)" = const(0);
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Refresh;
                trigger OnAction()
                begin
                    CurrPage.D3.Refresh(format(AzureFunction.GetSankeyData()));
                end;
            }
            action(Optimize)
            {
                ApplicationArea = All;
                Caption = 'Optimize';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Calculate;
                trigger OnAction()
                begin
                    AzureFunction.SolveReservations();
                    CurrPage.D3.Refresh(format(AzureFunction.GetSankeyData()));
                    //CurrPage.UnReservedLines.Page.Update(false);
                end;
            }
            action(ReservationEntries)
            {
                ApplicationArea = All;
                Caption = 'Reservation Entries';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ReservationLedger;
                trigger OnAction()
                begin
                    PAGE.Run(page::"ReservationEntries");
                    CurrPage.UnReservedLines.Page.Update(false);
                end;
            }
        }
    }

    var
        AzureFunction: Codeunit AzureFunctions;
        string: text;

}
