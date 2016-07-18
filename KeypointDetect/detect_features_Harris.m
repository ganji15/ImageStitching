function [features, pyr, imp] = detect_features_Harris(img)
%%%Prewitt Operator Corner Detection.m  
 %%%时间优化--相邻像素用取差的方法  
 %%  
Image = im2uint8(rgb2gray(img));     
    
  
dx = [-1 0 1;-1 0 1;-1 0 1];  %dx：横向Prewitt差分模版  
Ix2 = filter2(dx,Image).^2;     
Iy2 = filter2(dx',Image).^2;                                           
Ixy = filter2(dx,Image).*filter2(dx',Image);  
   
%生成 9*9高斯窗口。窗口越大，探测到的角点越少。  
 h= fspecial('gaussian',9,2);       
A = filter2(h,Ix2);       % 用高斯窗口差分Ix2得到A   
B = filter2(h,Iy2);                                   
C = filter2(h,Ixy);                                    
nrow = size(Image,1);                              
ncol = size(Image,2);                               
Corner = zeros(nrow,ncol); %矩阵Corner用来保存候选角点位置,初值全零，值为1的点是角点  
                            %真正的角点在137和138行由(row_ave,column_ave)得到  
 %参数t:点(i,j)八邻域的“相似度”参数，只有中心点与邻域其他八个点的像素值之差在  
 %（-t,+t）之间，才确认它们为相似点，相似点不在候选角点之列  
 t=20;  
 %我并没有全部检测图像每个点，而是除去了边界上boundary个像素，  
 %因为我们感兴趣的角点并不出现在边界上  
 boundary=8;  
 for i=boundary:nrow-boundary+1   
    for j=boundary:ncol-boundary+1  
         nlike=0; %相似点个数  
         if Image(i-1,j-1)>Image(i,j)-t && Image(i-1,j-1)<Image(i,j)+t   
            nlike=nlike+1;  
         end  
         if Image(i-1,j)>Image(i,j)-t && Image(i-1,j)<Image(i,j)+t    
            nlike=nlike+1;  
         end  
         if Image(i-1,j+1)>Image(i,j)-t && Image(i-1,j+1)<Image(i,j)+t    
            nlike=nlike+1;  
         end    
        if Image(i,j-1)>Image(i,j)-t && Image(i,j-1)<Image(i,j)+t    
            nlike=nlike+1;  
         end  
         if Image(i,j+1)>Image(i,j)-t && Image(i,j+1)<Image(i,j)+t    
            nlike=nlike+1;  
         end  
         if Image(i+1,j-1)>Image(i,j)-t && Image(i+1,j-1)<Image(i,j)+t    
            nlike=nlike+1;  
         end  
         if Image(i+1,j)>Image(i,j)-t && Image(i+1,j)<Image(i,j)+t    
            nlike=nlike+1;  
         end  
         if Image(i+1,j+1)>Image(i,j)-t && Image(i+1,j+1)<Image(i,j)+t    
            nlike=nlike+1;  
         end  
         if nlike>=2 && nlike<=6  
             Corner(i,j)=1;%如果周围有0，1，7，8个相似与中心的（i,j）  
                           %那(i,j)就不是角点，所以，直接忽略  
         end;  
     end;  
 end;  
CRF = zeros(nrow,ncol);    % CRF用来保存角点响应函数值,初值全零  
 CRFmax = 0;                % 图像中角点响应函数的最大值，作阈值之用   
t=0.05;     
% 计算CRF  
 %工程上常用CRF(i,j) =det(M)/trace(M)计算CRF，那么此时应该将下面第105行的  
 %比例系数t设置大一些，t=0.1对采集的这几幅图像来说是一个比较合理的经验值  
 for i = boundary:nrow-boundary+1   
for j = boundary:ncol-boundary+1  
     if Corner(i,j)==1  %只关注候选点  
         M = [A(i,j) C(i,j);  
              C(i,j) B(i,j)];        
         CRF(i,j) = det(M)-t*(trace(M))^2;  
         if CRF(i,j) > CRFmax   
            CRFmax = CRF(i,j);      
        end;              
    end  
 end;               
end;    
%CRFmax  
 count = 0;       % 用来记录角点的个数  
 t=0.01;           
% 下面通过一个3*3的窗口来判断当前位置是否为角点  
 for i = boundary:nrow-boundary+1   
for j = boundary:ncol-boundary+1  
         if Corner(i,j)==1  %只关注候选点的八邻域  
             if CRF(i,j) > t*CRFmax && CRF(i,j) >CRF(i-1,j-1) ......  
                && CRF(i,j) > CRF(i-1,j) && CRF(i,j) > CRF(i-1,j+1) ......  
                && CRF(i,j) > CRF(i,j-1) && CRF(i,j) > CRF(i,j+1) ......  
                && CRF(i,j) > CRF(i+1,j-1) && CRF(i,j) > CRF(i+1,j)......  
                && CRF(i,j) > CRF(i+1,j+1)   
            count=count+1;%这个是角点，count加1  
             else % 如果当前位置（i,j）不是角点，则在Corner(i,j)中删除对该候选角点的记录  
                 Corner(i,j) = 0;       
            end;  
         end;   
end;   
end;   
% disp('角点个数');  
 % disp(count)  
% toc(t1)  
keys = [];
 for i=boundary:nrow-boundary+1   
for j=boundary:ncol-boundary+1  
         column_ave=0;  
         row_ave=0;  
         k=0;  
        if Corner(i,j)==1  
             for x=i-3:i+3  %7*7邻域  
                 for y=j-3:j+3  
                     if Corner(x,y)==1  
 % 用算数平均数作为角点坐标，如果改用几何平均数求点的平均坐标，对角点的提取意义不大  
                         row_ave=row_ave+x;  
                         column_ave=column_ave+y;  
                         k=k+1;  
                     end  
                 end  
             end  
         end  
         if k>0 %周围不止一个角点             
             keys = [keys; column_ave/k,row_ave/k];
         end  
 end;   
end;

pyr = [];
imp{1} = Image;
features = zeros(size(keys, 1), 9);
features(:, 8) = keys(:, 1);
features(:, 9) = keys(:, 2);
features(:, 1) = keys(:, 1);
features(:, 2) = keys(:, 2);
features(:, 3) = ones(size(keys, 1), 1);

end  