function [flag,placeX,placeY,XX,YY,series] = LCS_gap_penelty( X_all,Y_all,placeX,placeY )
%����������� num��ʾ������г��ȣ�series��ʾ����������У�c��ʾcost,d��ʾ�ƶ�����
X=X_all(placeX:end);
Y=Y_all(placeY:end);
M=length(X);
N=length(Y);
LCS=zeros(M+1,N+1);
GAP=zeros(M+1,N+1); %��¼��gap penalty��LCS
alpha=0.9;
gama=0.6;
thresh=0;
penalty=-1;%��¼����Ȩ��
reward=1;
count_r=zeros(M+1,N+1);%��������ƥ����������ֲ�ƥ��Ĵ���
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
            d(i,j)=0;%��ʾ����Ϊ����
        else
            count_r(i,j)=0;
            count_p(i,j)=count_p(i,j)+1;
            [GAP(i,j),dd]=max([GAP(i-1,j-1)+count_p(i,j)*penalty,GAP(i,j-1)+count_p(i,j)*penalty,GAP(i-1,j)+count_p(i,j)*penalty]);
            switch dd
                case 1
                    d(i,j)=0;%��ʾ����Ϊ����,�������滻������ƥ��
                    LCS(i,j)=LCS(i-1,j-1);
                case 2
                    d(i,j)=-1;%��ʾ����Ϊ<-
                    LCS(i,j)=LCS(i,j-1);
                case 3
                    d(i,j)=1;%��ʾ����Ϊ��
                    LCS(i,j)=LCS(i-1,j);
            end


        end
    end
end
[flag,XX,YY,placeX,placeY]=relationjudge(GAP,LCS,placeX,placeY,X,Y,M,N,alpha,gama,thresh);%�ж�һ��һ��һ�Զ࣬���1������ƥ������
if flag~=4
    series=output_LCS(d,Y);
else
    series=[];
end


end

function [flag,XX,YY,placeX,placeY]=relationjudge(GAP,LCS,oldX,oldY,X,Y,M,N,alpha,gama,thresh)
    [A,B]=find(GAP== max(max(GAP)));%A��ʾGAP���ֵ��X�е�λ�ã�B��ʾ��Y��..
    [c,d]=find(LCS==max(max(LCS)));%c��ʾLCS���ֵ��X�е�λ�ã�d��ʾ��Y��..
    if (LCS(c(1),d(1))>=min(M,N)*gama) && (A(end)-1>M*alpha)
        if B(end)-1>N*alpha
            XX=X;YY=Y;
            placeX=1;placeY=1;  %һ��һ���������һ�����н��ж���ʱֱ�Ӵ�ͷ��ʼ
            flag=1;
        else
            placeX=1;placeY=oldY+B(end)-1;  %���һ���������һ�����н��ж���ʱXֱ�Ӵ�ͷ��ʼ��YҪ����һ��ƥ�䵽�Ľ�����濪ʼ
            XX=X;YY=Y(1:B(end)-1);
            flag=2;
        end
    else
        if (LCS(c(1),d(1))>min(M,N)*gama)&&(B(end)-1>N*alpha)
            placeX=oldX+A(end)-1;placeY=1;  %һ�Զ���������һ�����н��ж���ʱYֱ�Ӵ�ͷ��ʼ��XҪ����һ��ƥ�䵽�Ľ�����濪ʼ
            XX=X(1:A(end)-1);YY=Y;
            flag=3;
        else
%             [c,d]=find(LCS==max(max(LCS)));
%             if LCS(c(1),d(1))>min(M,N)*gama
%                 if M<N
%                 placeX=1;placeY=oldY+d(1)-1;  %���һ���������һ�����н��ж���ʱֱ�Ӵ�ͷ��ʼ
%                 flag=2;
%                 else
%                     placeX=oldX+c(1)-1;placeY=1;
%                     flag=3;
%                 end
%             else
                placeX=1;placeY=1;  %��ƥ������
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