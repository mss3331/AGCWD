function enhanced_image = AGCWD(input_image,varargin)
%AGCWD implemenation code for Efficient contrast enhancement Using
%adaptive gamma correction with weighting distribution
%implementation of image contrast enhancment method in paper:https://ieeexplore.ieee.org/document/6336819/
%--------------------------------------------------------------------------
%   Inputs:
%          input_image: can be either gray image or colorful image
%          parameter  : (optional) weighting parameter for the histogram
%          can be [0,1]. Default is 0.5
%
weighting_parameter=0.5;
if(length(varargin)==1)
    weighting_parameter=varargin{1};
end

image = input_image;

%if the input image is colorful, extract it's V channel (HSV color model)
is_colorful = size(input_image,3)>1;
if(is_colorful)
    image=extractValueChannel(input_image);
end


%get the pdf of an image
pdf=get_pdf(image);

%modify the pdf
    %get min and max of pdf
    Max=max(pdf);
    Min=min(pdf);
pdf_w = Max*(((pdf-Min)/(Max - Min)).^weighting_parameter);

%get the cdf of the wieghted pdf
cdf_w=cumsum(pdf_w)/sum(pdf_w);

%create the transformation function
l = (0:255);
l_max = 255;% maximum
for i=1:256
    l(i)=l_max * (l(i)/l_max)^(1-cdf_w(i));
end
l=uint8(l);

enhanced_image = image;

%apply the new transformation to the image
[height, width] = size(image);
for i = 1:height
    for j = 1:width
        intensity = enhanced_image(i,j);
        enhanced_image(i,j) = l(intensity+1);
    end
end
if(is_colorful) % if the image is colorful then add the enhanced gray image to the colofrul image
    enhanced_image = setValueChannel(input_image,enhanced_image);
end

end
% *************** helper functions ********************
function valueChannel=extractValueChannel(color_image)
%get the value channel from colorful image
valueChannel = rgb2hsv(color_image);
valueChannel = valueChannel(:,:,3) * 255;
valueChannel = uint8(valueChannel);
end

function pdf = get_pdf(image)
%get the probability density function of an image
% Get histogram:
[pixelCounts, ~] = imhist(image);
% Compute probability density function:
pdf = pixelCounts / numel(image);

end

function color_image = setValueChannel(color_image, value_channel)
%add the enhanced value_channel to a colorful image
value_channel = double(value_channel);
value_channel = value_channel / 255;
color_image = rgb2hsv(color_image);
color_image(:,:,3) = value_channel;
color_image = uint8(round(hsv2rgb(color_image)*255));
end
