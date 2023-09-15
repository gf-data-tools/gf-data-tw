local util = require 'xlua.util'
xlua.private_accessible(CS.DailyGameAutoPlanController)

local CheckAutoPlanInDailyGame = function()
	CS.DailyGameAutoPlanController.CheckAutoPlanInDailyGame();
	CS.RewardBoxController.boxes:Clear();
end

util.hotfix_ex(CS.DailyGameAutoPlanController,'CheckAutoPlanInDailyGame',CheckAutoPlanInDailyGame)

