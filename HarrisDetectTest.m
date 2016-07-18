function HarrisDetectTest()

    clear;
    addpath('KeypointDetect');
    
    Image = imread('./data/yard1.jpg');                 % ��ȡͼ��  
    [features, ~, ~] = detect_features_Harris(Image);
    imshow(Image);
    hold on
    keys = features(:,1 : 2);
    scatter(keys(:, 1), keys(:, 2), 'g.');
    
end