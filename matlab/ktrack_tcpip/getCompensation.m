function [xy0 g_prv g_f2f] = getCompensation( g_WC, g_prv, xy0, f )
global TKR;
if isempty(g_prv)
  g_prv = g_WC;
end

g_f2f = g_WC * (g_prv)^(-1);
% g_f2f(1:3,4) = 0; % zero out the translation ... hm...
% ^^ don't do that, only matters when frame to 
%     frame and distance to target scale are unknown
g_prv = g_WC;

u0 =  (xy0(1) - 640/2) * (1/f);
v0 = -(xy0(2) - 480/2) * (1/f);

z0 = 20.0;
uv = (g_f2f^(-1)) * [ u0(:)'; v0(:)'; z0*ones(1,numel(v0)); ones(1,numel(v0)) ];

x0 =  f * uv(1,:)./uv(3,:) + 640/2;
y0 = -f * uv(2,:)./uv(3,:) + 480/2;

xy0     = [x0,y0];

% store it for later use
TKR.g_f2f = g_f2f;
TKR.g_WC  = g_WC;
TKR.f     = f;

end
