local util = require 'xlua.util'
xlua.private_accessible(CS.OPSPanelController)

local ShowOPSSpineMissionUI = function(self,code)
	self:ShowOPSSpineMissionUI(code);
	if not self.moudleSpineUIObj.gameObject.activeInHierarchy then
		self.useOPSmissions:Clear();
		local trans = self.panalMissionTrans:GetEnumerator();
		while trans:MoveNext() do
			local key = trans.Current.Key;
			local value = trans.Current.Value;
			self:CheckOPSMissionItem(key,value);
			if value.gameObject.activeSelf then
				self.useOPSmissions:Add(key);
			end
		end
		self.num = self.useOPSmissions.Count;
		self.checkPosMax = self.currentPanelConfig.moudleSpineUI.selectPosX;
		self.distance = self.currentPanelConfig.moudleSpineUI.eachDistance;
		self.moudleSpineUIObj.gameObject:SetActive(true);
	end
end

local CanGetPoint = function(self,itemid)
	if CS.MissionSelectionController.normalActivityCampaion:Contains(self.campaionId) then
		return true;
	end
	return self:CanGetPoint(itemid);
end

util.hotfix_ex(CS.OPSPanelController,'ShowOPSSpineMissionUI',ShowOPSSpineMissionUI)
util.hotfix_ex(CS.OPSPanelController,'CanGetPoint',CanGetPoint)