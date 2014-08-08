function Z = palm_gtoz(G,df1,df2)
% Convert a G-statistic (or any of its particular cases)
% to a z-statistic (normally distributed).
%
% Usage:
% Z = gstat2pval(G,df1,df2)
%
% Inputs:
% G        : G statistic.
% df1, df2 : Degrees of freedom (non-infinite).
% 
% Outputs:
% Z        : Z-score
%
% If df2 = NaN and df1 = 1, G is treated as Pearson's r.
% If df2 = NaN and df1 > 1, G is treated as R^2.
% 
% _____________________________________
% Anderson Winkler
% FMRIB / University of Oxford
% Jan/2014
% http://brainder.org

% Note that for speed, there's no argument checking.

% If df2 is NaN, this is r or R^2
if isnan(df2),
    
    if df1 == 1,
        % If rank(C) = 1, i.e., df1 = 1, this is r, so
        % do a Fisher's r-to-z stransformation
        Z = atanh(G);
    elseif df1 > 1,
        % If rank(C) > 1, i.e., df1 > 1, this is R^2, so
        % use a probit transformation.
        Z = erfinv(2*G-1)*sqrt(2); %Z = norminv(G);
    end

else
    siz = size(G);
    Z   = zeros(siz);
    df2 = bsxfun(@times,ones(siz),df2);
    if df1 == 1,
        
        % Deal with precision issues working on each
        % tail separately
        idx = G > 0;
        Z( idx) = -erfinv(2*palm_gcdf(-G( idx),1,df2( idx))-1)*sqrt(2);
        Z(~idx) =  erfinv(2*palm_gcdf( G(~idx),1,df2(~idx))-1)*sqrt(2);
        
    else
        
        % G-vals above the upper half are treated as
        % "upper tail"; otherwise, "lower tail".
        thr = (1/betainv(.5,df2/2,df1/2)-1)*df2/df1;
        idx = G > thr;
        
        % Convert G-distributed variables to Beta-distributed
        % variables with parameters a=df1/2 and b=df2/2
        B = (df1.*G./df2)./(1+df1.*G./df2);
        a = df1/2;
        b = df2/2;
        
        % Convert to Z through a Beta incomplete function
        Z( idx) = -erfinv(2*betainc(1-B( idx),b( idx),a)-1)*sqrt(2);
        Z(~idx) =  erfinv(2*betainc(  B(~idx),a,b(~idx))-1)*sqrt(2);
        
    end
end