function [outputX,outputY] = intersect(inputAX,inputAY,inputBX,inputBY)
%INTERSECT Summary of this function goes here
%   Detailed explanation goes here
    x1 = inputAX(1);
    x2 = inputAX(2);
    x3 = inputBX(1);
    x4 = inputBX(2);
    y1 = inputAY(1);
    y2 = inputAY(2);
    y3 = inputBY(1);
    y4 = inputBY(2);

    A = [ det([x1 y1; x2 y2]) det([x1 1; x2 1])
          det([x3 y3; x4 y4]) det([x3 1; x4 1])];
    B = [ det([x1 1; x2 1]) det([y1 1; y2 1])
          det([x3 1; x4 1]) det([y3 1; y4 1])];

    outputX = det(A)/det(B);


    C = [ det([x1 y1; x2 y2]) det([y1 1; y2 1])
          det([x3 y3; x4 y4]) det([y3 1; y4 1])];
    D = [ det([x1 1; x2 1]) det([y1 1; y2 1])
          det([x3 1; x4 1]) det([y3 1; y4 1])];

    outputY = det(C)/det(D);

    if outputX < min([x1 x2 x3 x4]) || max([x1 x2 x3 x4]) < outputX
        outputX = NaN;
        outputY = NaN;
    end

    if outputY < min([y1 y2 y3 y4]) || max([y1 y2 y3 y4]) < outputY
        outputX = NaN;
        outputY = NaN;
    end
end