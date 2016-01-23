function [Alignment,Alignment_s,namelist_main,align_time]=textprocessing(scrFile,subFile,fps);
tic
        [scriptdata,namelist_all,frequency]=scriptprocess(scrFile);
        subtitledata=subtitleprocess_desperatewives(subFile);
        namelist_main=namelist_all([2,3,6,8,9,13,25]);
        [Alignment,Alignment_s,namelist] = SSalignment(subtitledata,scriptdata,namelist_main,fps);
toc
align_time=toc;
save textAlignDespwives.mat Alignment Alignment_s namelist_all frequency namelist_main align_time
end
        