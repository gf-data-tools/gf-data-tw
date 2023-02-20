local util = require 'xlua.util'
xlua.private_accessible(CS.TheaterMissiontSettlementController)

local Start = function(self)
	self:Start();
	self.scoreText.gameObject:SetActive(true);
end


util.hotfix_ex(CS.TheaterMissiontSettlementController,'Start',Start)