function [Alignment,Alignment_s,namelist] = SSalignment(subtitle,script,namelist,fps)
%SSALIGNMENT aligns subtitle and script,
%where subtitle is a M*3 cell, M is the number of subtitles, each subtitle
%contains 2 timestamps and 1 spoken line
%Similarly script is a N*2 cell, N is the number of scripts, each script
%contains 1 spoken line and 1 name
%aligning these 2 texts gives us WHO says WHAT at WHEN

    %initialize
    nbthresh=3; %neighborhood searching threshold
    M=length(subtitle);
    N=length(script);
    m=1;n=1;
    placeX=1;placeY=1;
    NotMatch=zeros(1,2);
    Alignment=cell(M,6); %Alignment contains 2 timestamps, subtitle line, script line, aligned line, and name.
    G=[];
    
    while (m<=M)&&(n<=N)
        dlg_scr=script{n,1};
        dlg_sub=subtitle{m,3};
        %analyzing relationship between two specific subtitle line
        %and script line
        [flag,placeX,placeY,sub,scr,series]=LCS_gap_penelty(dlg_sub,dlg_scr,placeX,placeY);
        switch flag
            case 1
                G(m,1)=n;%1-1
                Alignment=setAlignmentValue(Alignment,m,n,subtitle,script,sub,scr,series);
                m=m+1;n=n+1;
            case 2
               G(m,end+1)=n;%many-1
               Alignment=setAlignmentValue(Alignment,m,n,subtitle,script,sub,scr,series);
               m=m+1;
            case 3
               G(m,end+1)=n;%1-many
               Alignment=setAlignmentValue(Alignment,m,n,subtitle,script,sub,scr,series);
               n=n+1;
            case 4
                if(NotMatch(1)~=m)
                    NotMatch(1)=m;NotMatch(2)=n;%not match
                end
                n=n+1;
                if n>M/N*nbthresh+NotMatch(2)
                    Alignment{m,1}=subtitle{m,1};
                    Alignment{m,2}=subtitle{m,2};
                    Alignment{m,3}={sub};
                    Alignment{m,4}=scr;
                    m=NotMatch(1)+1;
                    n=NotMatch(2);
                end
        end
    end
    
    %generate simplified Alignment_s: 2 timestamps in frame format, names
    %per row
    len=size(Alignment,1);
    width=size(Alignment,2)-3;
    Alignment_s=cell(1,width); 
    alignedRow=0;
    for k=1:len
        if ~isempty(Alignment{k,5}) 
            names=Alignment(k,6:end);
            mIndex=[];%index for main actors in names
            %only reserve main actors
            for i=1:length(names)
                name=names{i};
                if ~isempty(name)
                    %judge whether these actors are main actors
                    sign=ismember(name,namelist);%if sign=1,the name is a main actor
                    if sign
                        mIndex=[mIndex,i];
                    end
                end
            end
            if isempty(mIndex)
                continue
            else
                names=names(mIndex);
                alignedRow=alignedRow+1;
                Alignment_s{alignedRow,1}=timegen_rv(Alignment{k,1},fps);%---------------------------23fps--------------------------------------------;
                Alignment_s{alignedRow,2}=timegen_rv(Alignment{k,2},fps);
                Alignment_s(alignedRow,3:2+length(names))=names;
            end
                
  
            
         
        end
    end

end

function Alignment=setAlignmentValue(Alignment,m,n,subtitle,script,sub,scr,series)
    if isempty(Alignment{m,1})
        Alignment{m,1}=subtitle{m,1};
        Alignment{m,2}=subtitle{m,2};
        Alignment{m,3}={sub};
        Alignment{m,4}={scr};
        Alignment{m,5}={series};
        Alignment{m,6}=script{n,2};
    else
        Alignment{m,3}{1,1}=[Alignment{m,3}{1,1} '_' sub];
        Alignment{m,4}{1,1}=[Alignment{m,4}{1,1} '_' scr];
        Alignment{m,5}{1,1}=[Alignment{m,5}{1,1} '_' series];
        i=6;
        while 1
            try
                if ~isempty(Alignment{m,i})
                    i=i+1;
                    continue
                else
                    Alignment(m,i)=script(n,2);
                    break    
                end
            catch
                Alignment(m,i)=script(n,2);
                break
            end
        end

    end
end


function frame=timegen_rv(t,fps)
    t(find(t==','))='.';
    [rows,b]=regexp(t,'\:','split');
    seconds=str2num(rows{1})*3600+str2num(rows{2})*60+str2num(rows{3});  
    frame=round(seconds*fps);        
end
