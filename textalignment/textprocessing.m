function [Alignment,Alignment_s,namelist_main,align_time]=textprocessing(scrFile,subFile,fps);
tic
        [scriptdata,namelist_all,frequency]=scriptprocess(scrFile);
        subtitledata=subtitleprocess_friends(subFile);
        namelist_main=namelist_all([2,4,5,7,8,9]);
        [Alignment,Alignment_s,namelist] = SSalignment(subtitledata,scriptdata,namelist_main,fps);
toc
align_time=toc;
save textAlignFriends.mat Alignment Alignment_s namelist_all frequency namelist_main align_time
end
        