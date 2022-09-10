local util = require 'xlua.util'
xlua.private_accessible(CS.GF.Battle.BattleSkillData)
local UpdateCD = function(self)	
	self:UpdateCD()
	if self.cdChargeIntervalFrame > 0 then		
		self.cdChargeIntervalFrame = self.cdChargeIntervalFrame - 1
	end
		
end

util.hotfix_ex(CS.GF.Battle.BattleSkillData,'UpdateCD',UpdateCD)