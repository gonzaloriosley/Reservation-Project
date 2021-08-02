page 50100 NonReservedSalesLines
{

    Caption = 'Non Reserved Sales Lines';
    PageType = ListPart;
    SourceTable = "Sales Line";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that you are about to create.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number.';
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer.';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number.';
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of entity that will be posted for this sales line, such as Item, Resource, or G/L Account. The type that you enter in this field determines what you can select in the No. field.';
                }
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the entry of the product to be sold. To add a non-transactional text line, fill in the Description field only.';
                }
                field("Package Tracking No."; "Package Tracking No.")
                {
                    ToolTip = 'Specifies the shipping agent''s package number.';
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the inventory location from which the items sold should be picked and where the inventory decrease is registered.';
                    Visible = true;
                }
                field(Reserve; Reserve)
                {
                    ApplicationArea = Reservation;
                    ToolTip = 'Specifies whether a reservation can be made for items on this line.';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many units are being sold.';
                }
                field("Qty. to Ship"; "Qty. to Ship")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of items that remain to be shipped.';
                    Visible = false;
                }
                field("Reserved Qty. (Base)"; "Reserved Qty. (Base)")
                {
                    ApplicationArea = Reservation;
                    ToolTip = 'Specifies the value in the Reserved Quantity field, expressed in the base unit of measure.';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the net amount, excluding any invoice discount amount, that must be paid for products on the line.';
                }
                field("Job No."; "Job No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the related job. If you fill in this field and the Job Task No. field, then a job ledger entry will be posted together with the sales line.';
                    Visible = false;
                }
                field("Work Type Code"; "Work Type Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies which work type the resource applies to when the sale is related to a job.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
                field("Outstanding Quantity"; "Outstanding Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many units on the order line have not yet been shipped.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReserveAction)
            {
                ApplicationArea = All;
                Caption = '&Reserve';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Ellipsis = true;
                Image = Reserve;
                Enabled = Type = Type::Item;
                ToolTip = 'Reserve the quantity of the selected item that is required on the document line from which you opened this page. This action is available only for lines that contain an item.';

                trigger OnAction()
                begin
                    Rec.Find();
                    Rec.ShowReservation();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
    end;
}
