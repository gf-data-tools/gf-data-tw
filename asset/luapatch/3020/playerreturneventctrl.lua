local util = require 'xlua.util'
xlua.private_accessible(CS.PlayerReturnEventCtrl)
xlua.private_accessible(CS.PlayerReturnFundCtrl)

local Awake = function(self)
	self:Awake();
	if CS.HotUpdateController.instance.mUsePlatform == CS.HotUpdateController.EUsePlatform.ePlatform_Tw or CS.HotUpdateController.instance.mUsePlatform == CS.HotUpdateController.EUsePlatform.ePlatform_Korea then
		local imageTrans1 = self.transform:Find("FundsContent/ActivateCard/Img_Bg");
		if imageTrans1~= nil then
			local obj1 = CS.ResManager.GetObjectByPath("AtlasClips3010/回归基金");
			imageTrans1:GetComponent(typeof(CS.ExImage)).sprite = obj1:GetComponent(typeof(CS.UnityEngine.UI.Image)).sprite;
		end
	end
end
local _RefreshPriceLabel = function(self)
	self:RefreshPriceLabel();
	if self.fundGood ~= nil then
		--local Tex_Money = self.transform:Find("ActivateCard/Img_Bg/Tex_Money");
		local Tex_Count = self.transform:Find("ActivateCard/Img_Bg/Tex_Count");
		--Tex_Money:GetComponent(typeof(CS.ExText)).text = self.fundGood.currency;
		Tex_Count:GetComponent(typeof(CS.ExText)).text = ""..self.fundGood.pointPrice;
	end
end
if CS.HotUpdateController.instance.mUsePlatform == CS.HotUpdateController.EUsePlatform.ePlatform_Tw or CS.HotUpdateController.instance.mUsePlatform == CS.HotUpdateController.EUsePlatform.ePlatform_Korea then
 util.hotfix_ex(CS.PlayerReturnFundCtrl,'RefreshPriceLabel',_RefreshPriceLabel)
end
--util.hotfix_ex(CS.PlayerReturnEventCtrl,'Awake',Awake)
