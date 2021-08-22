codeunit 50100 AzureFunctions
{
    procedure SolveReservations()
    begin
        ProcessSolution(CallService(GetData()));
    end;

    //Function 2 the HTTP Call

    procedure CallService(RequestBodyJson: JsonObject) ResponseBody: JsonObject
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
        RequestUrl: Text;
        Body: Text;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
    begin
        //Change the URL for the one given to you by your Power Automate Flow
        RequestUrl := 'https://my-first-function-app2.azurewebsites.net/api/multiplyby2';
        RequestHeaders := Client.DefaultRequestHeaders();
        RequestBodyJson.WriteTo(Body);
        RequestContent.WriteFrom(Body);
        RequestContent.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        Client.Post(RequestURL, RequestContent, ResponseMessage);
        if ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content().ReadAs(ResponseText);
            JsonResponse.ReadFrom(ResponseText);
            exit(JsonResponse);
        end;
    end;


    //Function 3 Builds the Record as a JSON
    procedure RecToJson(RecRef: RecordRef) RecJson: JsonObject
    var
        FieldRef: FieldRef;
        Field: Record Field;
        pDecimal: Decimal;
        pText: Text;
        pDate: Date;
        pInteger: Integer;
    begin
        Clear(RecJson);
        Field.SetRange(TableNo, RecRef.Number);
        if Field.FindSet() then
            repeat
                FieldRef := RecRef.Field(Field."No.");
                if Field.Class = Field.Class::FlowField then
                    FieldRef.CalcField();
                //Obviously incomplete
                case Field.Type of
                    Field.Type::Decimal:
                        begin
                            pDecimal := FieldRef.Value;
                            RecJson.Add(Field.FieldName, pDecimal);
                        end;
                    Field.Type::Integer:
                        begin
                            pInteger := FieldRef.Value;
                            RecJson.Add(Field.FieldName, pInteger);
                        end;
                    Field.Type::Text, Field.Type::Code:
                        begin
                            pText := FieldRef.Value;
                            RecJson.Add(Field.FieldName, pText);
                        end;
                    Field.Type::Date:
                        begin
                            pDate := FieldRef.Value;
                            RecJson.Add(Field.FieldName, pDate);
                        end;
                    else begin
                            begin
                                RecJson.Add(Field.FieldName, Format(FieldRef.Value));
                            end;
                        end;
                end;
            until Field.Next() = 0;
    end;

    procedure GetData() data: JsonObject
    begin
        data.Add('supplylines', GetPurchaseLines());
        data.Add('demandlines', GetSalesLines());
        data.Add('reservationline', GetReservationLines());
    end;

    procedure GetSalesLines() data: JsonArray
    var
        saleslineobject: JsonObject;
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("No.", 'A');
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                Clear(saleslineobject);
                saleslineobject.Add('id', DelChr(SalesLine."Document No.", '=', '-') + '#' + Format(SalesLine."Line No."));
                saleslineobject.Add('itemno', SalesLine."No.");
                saleslineobject.Add('quantity', SalesLine.Quantity);
                saleslineobject.Add('deliverydate', SalesLine."Planned Delivery Date");
                data.Add(saleslineobject);
            until SalesLine.Next() = 0;
    end;

    procedure GetPurchaseLines() data: JsonArray
    var
        purchaselineobject: JsonObject;
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("No.", 'A');
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        if PurchaseLine.FindSet() then
            repeat
                Clear(purchaselineobject);
                purchaselineobject.Add('id', purchaseLine."Document No." + '#' + Format(purchaseLine."Line No."));
                purchaselineobject.Add('itemno', purchaseLine."No.");
                purchaselineobject.Add('quantity', purchaseLine.Quantity);
                purchaselineobject.Add('receiptdate', purchaseLine."Planned Receipt Date");
                data.Add(purchaselineobject);
            until purchaseLine.Next() = 0;
    end;

    procedure GetReservationLines() data: JsonArray
    var
        reservationlineobject: JsonObject;
        ReservationEntry: Record "Reservation Entry";
        ReservationEntry2: Record "Reservation Entry";
    begin
        ReservationEntry.SetRange("Item No.", 'A');
        ReservationEntry.SetRange(Positive, true);
        if ReservationEntry.FindSet() then
            repeat
                Clear(reservationlineobject);
                reservationlineobject.Add('supplyline', ReservationEntry."Source ID" + '#' + Format(ReservationEntry."Source Ref. No."));
                ReservationEntry2.get(ReservationEntry."Entry No.", false);
                reservationlineobject.Add('demandline', ReservationEntry2."Source ID" + '#' + Format(ReservationEntry2."Source Ref. No."));
                reservationlineobject.Add('id', Format(ReservationEntry."Entry No."));
                reservationlineobject.Add('itemno', ReservationEntry."Item No.");
                reservationlineobject.Add('quantity', ReservationEntry.Quantity);
                data.Add(reservationlineobject);
            until ReservationEntry.Next() = 0;
    end;

    procedure ProcessSolution(JsonResponse: JsonObject)
    var
        JToken: JsonToken;
        JFieldToken: JsonToken;
        JSolutionToken: JsonToken;
        ReservationEntry: Record "Reservation Entry";
        ReservationEntry2: Record "Reservation Entry";
    begin
        JsonResponse.Get('solution', JToken);
        /*
        if JToken.AsValue().AsText() = 'no optimal solution' then
            Error(JToken.AsValue().AsText());
            */
        ReservationEntry.SetRange("Item No.", 'A');
        ReservationEntry.DeleteAll();
        ReservationEntry.LockTable();
        foreach JSolutionToken in JToken.AsArray() do begin
            ReservationEntry.Init();
            ReservationEntry."Entry No." := ReservationEntry.GetLastEntryNo() + 1;
            ReservationEntry.Positive := false;
            ReservationEntry.Validate("Item No.", 'A');
            ReservationEntry2 := ReservationEntry;
            JSolutionToken.AsObject().Get('quantity', JFieldToken);
            ReservationEntry.Validate("Quantity (Base)", -JFieldToken.AsValue().AsDecimal());
            ReservationEntry.Validate("Source Type", Database::"Sales Line");
            ReservationEntry.Validate("Source Subtype", 1);
            JSolutionToken.AsObject().Get('demandline', JFieldToken);
            ReservationEntry.Validate("Source ID", GetDocument(FixSalesNo(JFieldToken.AsValue().AsText())));
            ReservationEntry.Validate("Source Ref. No.", GetLineNo(JFieldToken.AsValue().AsText()));
            //Entry2
            ReservationEntry2.Positive := true;
            ReservationEntry2.Validate("Quantity (Base)", -ReservationEntry."Quantity (Base)");
            ReservationEntry2.Validate("Source Type", Database::"Purchase Line");
            ReservationEntry2.Validate("Source Subtype", 1);
            JSolutionToken.AsObject().Get('supplyline', JFieldToken);
            ReservationEntry2.Validate("Source ID", GetDocument(JFieldToken.AsValue().AsText()));
            ReservationEntry2.Validate("Source Ref. No.", GetLineNo(JFieldToken.AsValue().AsText()));
            ReservationEntry.Insert();
            ReservationEntry2.Insert();
        end;
    end;

    //This function is to add proper - symbol because python library gets rid of it
    procedure FixSalesNo(SalesNo: text): text
    begin
        exit(InsStr(SalesNo, '-', 2))
    end;

    procedure GetDocument(SourceID: text): text
    begin
        exit(PadStr(SourceID, StrPos(SourceID, '#') - 1));
    end;

    procedure GetLineNo(SourceRef: text) LineNo: Integer
    begin
        Evaluate(LineNo, CopyStr(SourceRef, StrPos(SourceRef, '#') + 1));
    end;

    procedure GetSankeyData() SankeyData: JsonObject
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ReservationEntry: Record "Reservation Entry";
        ReservationEntry2: Record "Reservation Entry";
        label: JsonArray;
        color: JsonArray;
        linksource: JsonArray;
        linktarget: JsonArray;
        linkvalue: JsonArray;
    begin
        //supply
        PurchaseLine.SetRange("No.", 'A');
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        if PurchaseLine.FindSet() then
            repeat
                label.Add(purchaseLine."Document No." + '#' + Format(purchaseLine."Line No."));
                color.Add('blue');
            until PurchaseLine.Next() = 0;
        //demand
        SalesLine.SetRange("No.", 'A');
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                label.Add(SalesLine."Document No." + '#' + Format(SalesLine."Line No."));
                color.Add('green');
            until SalesLine.Next() = 0;
        //link
        ReservationEntry.SetRange("Item No.", 'A');
        ReservationEntry.SetRange(Positive, true);
        if ReservationEntry.FindSet() then
            repeat
                linksource.Add(GetTextPositionInArray(label, ReservationEntry."Source ID" + '#' + Format(ReservationEntry."Source Ref. No.")));
                ReservationEntry2.get(ReservationEntry."Entry No.", false);
                linktarget.Add(GetTextPositionInArray(label, ReservationEntry2."Source ID" + '#' + Format(ReservationEntry2."Source Ref. No.")));
                linkvalue.Add(ReservationEntry.Quantity);
            until ReservationEntry.Next() = 0;
        SankeyData.Add('label', label);
        SankeyData.Add('color', color);
        SankeyData.Add('source', linksource);
        SankeyData.Add('target', linktarget);
        SankeyData.Add('value', linkvalue);
    end;

    procedure GetTextPositionInArray(JArray: JsonArray; Value: text): Integer
    var
        JToken: JsonToken;
        i: Integer;
    begin
        i := 0;
        foreach JToken in JArray do begin
            if (JToken.AsValue().AsText() = Value) then
                exit(i)
            else
                i += 1;
        end;
    end;


}