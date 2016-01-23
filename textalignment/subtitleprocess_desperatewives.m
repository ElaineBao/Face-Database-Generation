function subtitledata=subtitleprocess_desperatewives(subFile)
%subtitleprocess for friends, whose format is
%00:00:17,183 --> 00:00:19,879
%My name is Mary Alice Young...
    fid=fopen(subFile,'rt');
    data=fscanf(fid,'%c',inf);
    a=regexp(data,'\n','split');%split row by row
    a=a';
    [rows,b]=regexp(a,'-->','start','split');%split timestamps
    
    %initialize
    k=1;%count number of subtitles
    subtitledata=cell(length(b),3);

    for i=1:length(b)
        if ~isempty(rows{i,1}) %find the timestamp line
            %timestamp for one subtitle
            subtitledata{k,1}=b{i}{1,1};
            subtitledata{k,2}=b{i}{1,2};
    
            %find the next timestamp line, and lines between them are
            %subtitle lines
            m=i;
                while isempty(rows{m+1,1})
                    m=m+1;
                    if m<length(b)
                        continue;
                    else
                        break;
                    end
                end
            
            
            %put together one subtitle split by several lines
            dlg=a(i+1:m-1);
            dlg=cell2mat(dlg');
            left=find(dlg=='(');
            
            %unify formats of dialogs: no punctation, lower case.
            %delete those (...) in the dialog
            if ~isempty(left)
                right=find(dlg==')');
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
            subtitledata{k,3}=s;
            fprintf('%d',k);
            
            k=k+1;
        end
    end
subtitledata(k:end,:)=[];
end