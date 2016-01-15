function subtitledata=subtitleprocess_friends(subFile)
%subtitleprocess for friends, whose format is 
%Dialogue: 0,0:00:49.96,0:00:52.84,eng,,0,0,0,,There's nothing to tell....
    fid=fopen(subFile,'rt');
    data=fscanf(fid,'%c',inf);
    a=regexp(data,'\n','split');%split the file row by row
    a=a';
    [rows,b]=regexp(a,'\,','start','split');%split every row with the position of ","

    %initialize
    m=1;
    subtitledata=cell(length(b),3);
    subtitle_c=[];
    submark_c=[];

    for i=1:length(b)
        if ~isempty(rows{i,1})
            %timestamp for one subtitle
            subtitledata{m,1}=b{i}{1,2};
            subtitledata{m,2}=b{i}{1,3};

            %unify formats of dialogs: no punctation, lower case.
            %delete those (...) in the dialog
            dlg=b{i}(1,10:end);
            dlg=cell2mat(dlg);
            left=find(dlg=='{');
            if ~isempty(left)
                right=find(dlg=='}');
                for t=1:length(left)
                    dlg(left(1+length(left)-t):right(1+length(left)-t))=[];
                end
            end
            try s=regexp(dlg,'\w+','match');
            catch
                continue;
            end
            s=cell2mat(s);
            s=lower(s);        
            subtitledata{m,3}=s;

            m=m+1;
        end
    end
    subtitledata(m:end,:)=[];

end