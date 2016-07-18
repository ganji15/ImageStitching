function [features, pyr, imp] = detect_features(img)
    %[features, pyr, imp] = detect_features_Harris(img);
    [features, pyr, imp] = detect_features_DoG(img);
end  