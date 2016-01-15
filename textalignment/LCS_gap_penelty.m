function [flag,placeX,placeY,XX,YY,series] = LCS_gap_penelty( X_all,Y_all,placeX,placeY )
%最长公共子序列 num表示输出序列长度，series表示最长公共子序列，c表示cost,d表示移动方向
X=X_all(placeX:end);
Y=Y_all(placeY:end);
M=length(X);
N=length(Y);
LCS=zeros(M+1,N+1);
GAP=zeros(M+1,N+1); %记录带gap penalty的LCS
alpha=0.9;
gama=0.6;
thresh=0;
penalty=-1;%记录奖惩权重
reward=1;
count_r=zeros(M+1,N+1);%连续出现匹配或连续出现不匹配的次数
count_p=zeros(M+1,N+1);
GAP(1,:)=0:-1:-N;
GAP(:,1)=0:-1:-M;
d=zeros(M+1,N+1);

for i=2:M+1
    for j=2:N+1
        if(X(i-1)==Y(j-1))
            count_r(i,j)=count_r(i-1,j-1)+1;
            count_p(i,j)=0;
            LCS(i,j)=LCS(i-1,j-1)+1;
            GAP(i,j)=GAP(i-1,j-1)+count_r(i,j)*reward;
            d(i,j)=0;%表示方向为左上
        else
            count_r(i,j)=0;
            count_p(i,j)=count_p(i,j)+1;
            [GAP(i,j),dd]=max([GAP(i-1,j-1)+count_p(i,j)*penalty,GAP(i,j-1)+count_p(i,j)*penalty,GAP(i-1,j)+count_p(i,j)*penalty]);
            switch dd
                case 1
                    d(i,j)=0;%表示方向为左上,但是是替换，不是匹配
                    LCS(i,j)=LCS(i-1,j-1);
                case 2
                    d(i,j)=-1;%表示方向为<-
                    LCS(i,j)=LCS(i,j-1);
                case 3
                    d(i,j)=1;%表示方向为个
                    LCS(i,j)=LCS(i-1,j);
            end


        end
    end
end
[flag,XX,YY,placeX,placeY]=relationjudge(GAP,LCS,placeX,placeY,X,Y,M,N,alpha,gama,thresh);%判断一对一，一对多，多对1，即不匹配的情况
if flag~=4
    series=output_LCS(d,Y);
else
    series=[];
end


end

function [flag,XX,YY,placeX,placeY]=relationjudge(GAP,LCS,oldX,oldY,X,Y,M,N,alpha,gama,thresh)
    [A,B]=find(GAP== max(max(GAP)));%A表示GAP最大值在X中的位置，B表示在Y中..
    [c,d]=find(LCS==max(max(LCS)));%c表示LCS最大值在X中的位置，d表示在Y中..
    if (LCS(c(1),d(1))>=min(M,N)*gama) && (A(end)-1>M*alpha)
        if B(end)-1>N*alpha
            XX=X;YY=Y;
            placeX=1;placeY=1;  %一对一的情况，下一对序列进行对齐时直接从头开始
            flag=1;
        else
            placeX=1;placeY=oldY+B(end)-1;  %多对一的情况，下一对序列进行对齐时X直接从头开始，Y要从这一次匹配到的结果后面开始
            XX=X;YY=Y(1:B(end)-1);
            flag=2;
        end
    else
        if (LCS(c(1),d(1))>min(M,N)*gama)&&(B(end)-1>N*alpha)
            placeX=oldX+A(end)-1;placeY=1;  %一对多的情况，下一对序列进行对齐时Y直接从头开始，X要从这一次匹配到的结果后面开始
            XX=X(1:A(end)-1);YY=Y;
            flag=3;
        else
%             [c,d]=find(LCS==max(max(LCS)));
%             if LCS(c(1),d(1))>min(M,N)*gama
%                 if M<N
%                 placeX=1;placeY=oldY+d(1)-1;  %多对一的情况，下一对序列进行对齐时直接从头开始
%                 flag=2;
%                 else
%                     placeX=oldX+c(1)-1;placeY=1;
%                     flag=3;
%                 end
%             else
                placeX=1;placeY=1;  %不匹配的情况
                XX=X;YY=0;
                flag=4;
%              end
         end
    end
end

function series =output_LCS(d,y)
series=[];
[row, col]=size(d);
i=row;
j=col;
while (i>1)&&(j>1)
    switch d(i,j)
        case 0
            series=[series y(j-1)];
            i=i-1;j=j-1;
        case -1
            j=j-1;
        case 1
            i=i-1;
    end
end
series=fliplr(series);
end