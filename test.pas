//2016-12-30 18:48 tiger 不好意思刚刚提交的没有填写备注


//2016-12-30 18:47 tiger github测试修改!


function ExecSql(db, sql: string; cds: TClientDataSet=nil; outxml: boolean=false; GetLID: boolean=false):string;

    function GetLastID(McDB: TMcDB): TRESULT;
    var
        asql: string;
    begin
        result.Code := 0;
        result.Desc := '';
        asql:= 'select LAST_INSERT_ID()';
        if G.LogLevel>0 then G.Log.WriteAppLog('ExecSql() '+asql, G.MainHanlde);

        McDB.ExecSql(db, asql);
        result.Desc:= McDB.CDS.Fields[0].AsString;
        if (result.Desc='0') or (result.Desc='') then
        begin
            Result.Code := 999;
            Result.Desc := '【错误原因】必须在插入语句或更新语句之后使用本函数！也有可能是插入或更新操作失败';
        end;
    end;
var
    j: Integer;
    McDB: TMcDB;
    RET: TRESULT;
    Lines: TStrings;
    v, strName: string;
begin
    result:= '';

    db:= trim(db);
    sql:= trim(sql);

    McDB:=TMcDB.Create();
    RET:= McDB.ExecSql(db, sql);
    if RET.Code<>0 then
    begin
        McDB.Destroy;
        G.Log.WriteErrMsg(RET.Desc, G.MainHanlde);
        exit;
    end;
    result:= ret.Desc;

    if Assigned(cds) then
        CloneCDS(McDB.CDS, cds);

    //输出xml
    sql:= LowerCase(trim(sql));
    if (outxml) and Assigned(McDB.CDS) and ((Pos('select ', sql)>=1) or (Pos('show ',sql)>=1)) then
    begin
        Lines:= TStringList.Create;
        McDB.CDS.First;
        while not McDB.CDS.Eof do
        begin
            v:= '';

            for j:=0 to McDB.CDS.FieldCount-1 do
            begin
                strName   := McDB.CDS.Fields[j].FieldName;
                v  := v + '<'+strName+'>';
                v  := v + McDB.CDS.FieldByName(strName).AsString;
                v  := v + '</'+strName+'>';
            end;
            Lines.Add(v);
            McDB.CDS.Next;
        end;
        result:= Lines.Text;
        Lines.Destroy;
    end;

    //获取LAST ID
    if GetLID and ((Pos('update ', sql)>=1) or (Pos('update ',sql)>=1)) then
    begin
        result:= '';
        RET:= GetLastID(McDB);
        if RET.Code<>0 then
            G.Log.WriteErrMsg(RET.Desc, G.MainHanlde)
        else
            result:= ret.Desc;
    end;

    McDB.Destroy;
end;
