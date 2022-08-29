local util = require 'xlua.util'
xlua.private_accessible(CS.DormExplorationFormationController)

local _OnRequestExploreGetAdaptiveTeam = function(self,request)
	self:OnRequestExploreGetAdaptiveTeam(request);
	self:RefreshAdaptivePanel(); 
end

util.hotfix_ex(CS.DormExplorationFormationController,'OnRequestExploreGetAdaptiveTeam',_OnRequestExploreGetAdaptiveTeam)
