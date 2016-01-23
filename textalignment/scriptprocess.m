function [scriptdata, namelist,frequency]=scriptprocess(scrFile)
    fid=fopen(scrFile,'rt');
    data=fscanf(fid,'%c',inf);
    a=regexp(data,'\n','split');%split the file row by row
    a=a';
    [splitpoint,container]=regexp(a,'\:','start','split');%split every row with the position of ":"

    %initialize
    namelist=[];
    len=length(container);
    scriptdata=cell(len,2);
    m=1;
    % old_name=[];

    for i=1:len
        name=container{i}{1};
        if (isempty(splitpoint{i}))%||(~isempty(regexp(name,'\W','start')))  %if there's no name in this row(it cannot be splitted by ":")or a fake name like [scene exists
            continue;
        end
    %     if(i>1)
    %        if(strcmp(name,old_name)
    %            m=m-1;
    %            text=scriptdata{m,1};
    %            scriptdata{m,1}=[text,b{i}{2}];
    %            m=m+1;
    %        else


        %unify formats of dialogs: no punctation, lower case.
        %delete those (...) in the dialog
        dlg=container{i}{2};
        left=find(dlg=='(');  
        if ~isempty(left)
            right=find(dlg==')');
            for t=1:length(left)
                try dlg(left(1+length(left)-t):right(1+length(left)-t))=[];
                catch fprintf('%d\n',i);
                end
            end
        end    
        s=regexp(dlg,'\w+','match');
        s=cell2mat(s);
        s=lower(s);

        %store script data
        scriptdata{m,1}=s;
        scriptdata{m,2}=name;
        m=m+1;           
    %   old_name=name;        

    end

    scriptdata(m:end,:)=[];
    name=scriptdata(:,2);
    namelist=unique(name);
    frequency=tabulate(name);
end