local util = require 'xlua.util'
local config = require ('collaboration/ZLSR/MinigameWorkConfig')
xlua.private_accessible(CS.CommonAudioController)
xlua.private_accessible(CS.CommonController)
xlua.private_accessible(CS.ResManager)
xlua.private_accessible(CS.BattleManualSkillController)
xlua.private_accessible(CS.BattleMemberController)
xlua.private_accessible(CS.BattleFieldTeamHolder)
xlua.private_accessible(CS.BattleUILifeBarController)
xlua.private_accessible(CS.GF.Battle.BattleStatistics)
xlua.private_accessible(CS.GF.Battle.EffectManager)
xlua.private_accessible(CS.GF.Battle.BattleConditionList)
xlua.private_accessible(CS.GF.Battle.CharacterCondition)

local character
local playerFeverValue = -1
local feverGuageMax
local totalTimer = 0
local isUIPausing = false
local haloObj

local _imgTime1,_imgTime2,_imgTime3,_imgTime4,_imgFeverGauge
local txtFever
local spriteListTime
local BattleController
local spine
local dir = 1
Awake = function()
	
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	config:InitData()
	local RefreshFriendlyTargetList = function(self)
		self.listFriendlyTarget:Clear()
		for i=0,self.enemyTeamHolder.listCharacter.Count -1 do
			local target = self.enemyTeamHolder.listCharacter[i]
			if not target.isPhased then
				self.listFriendlyTarget:Add(target)
			end
		end
		if self.listFriendlyTarget.Count == 0 then
			self:CheckFormation()
		end
	end	
	local DisableRangeLine = function(self)
		return true
	end
	util.hotfix_ex(CS.GF.Battle.BattleController,'RefreshFriendlyTargetList',RefreshFriendlyTargetList)
	util.hotfix_ex(CS.BattleInteractionController,'DisableRangeLine',DisableRangeLine)
end
Start = function()
	
	
	BattleController = CS.GF.Battle.BattleController.Instance
	CS.BattleInteractionController.isGuideInteractable = false
	CS.BattleInteractionController.isGuideCanNotScale = false
	CS.BattleInteractionController.isGuideCanNotOffset = false
	CS.GF.Battle.SkillUtils.AutoSkill = false	
	BattleController.resetAutoSkill = true
	BattleController.resetCameraLock = true
	--BattleController.transform:Find("BattleField/CameraPositionDynamic/CameraPositionStatic/Main Camera/ShiningDust").gameObject:SetActive(false)
	haloObj = BattleController.transform:Find("Canvas/Halo").gameObject
	--haloObj:SetActive(false)
	
	BattleController.transform:Find("Canvas/UI/SafeUIRect/DPSSwitch").gameObject:SetActive(false)
	BattleController.transform:Find("Canvas/DynamicCanvas/DPS").gameObject:SetActive(false)
	BattleController.transform:Find("Canvas/UI/Top/Top_Time").gameObject:SetActive(false)
	BattleController.transform:Find("Canvas/UI/PausePanel").gameObject:SetActive(false)
	BattleController.transform:Find("Canvas/DynamicCanvas/TimerText").gameObject:SetActive(false)
	BattleController.transform:Find("Canvas/DynamicCanvas/ManualPanel").gameObject:SetActive(false)
	self.transform:SetParent(CS.BattleUIController.Instance.transform:Find('UI'),false)
	if character == nil then
		character = CS.BattleLuaUtility.GetCharacterByCode(spineCode)
	end
	feverGuageMax = energyMax
	totalTimer = totalTime
	_imgTime1 = imgTimeNum1:GetComponent(typeof(CS.ExImage))
	_imgTime2 = imgTimeNum2:GetComponent(typeof(CS.ExImage))
	_imgTime3 = imgTimeNum3:GetComponent(typeof(CS.ExImage))
	_imgTime4 = imgTimeNum4:GetComponent(typeof(CS.ExImage))
	_imgFeverGauge = feverGuage:GetComponent(typeof(CS.ExImage))
	txtFever = feverNum:GetComponent(typeof(CS.ExText))
	spriteListTime = holderTimeNum:GetComponent(typeof(CS.UGUISpriteHolder))
	JoyStrick:GetComponent(typeof(CS.Joystick)).JoystickMoveHandle = JoyStickMove
	JoyStrick:GetComponent(typeof(CS.Joystick)).JoystickEndHandle = JoyStickEnd
	JoyStrick:GetComponent(typeof(CS.Joystick)).JoystickBeginHandle = JoyStickBegin
	UpdateFever(0)
	
	btnPause:GetComponent(typeof(CS.ExButton)).onClick:AddListener(
		function()
			PauseGame(true)
		end)
	btnExit:GetComponent(typeof(CS.ExButton)).onClick:AddListener(
		function()
			ExitGame()
		end)
	btnContinue:GetComponent(typeof(CS.ExButton)).onClick:AddListener(
		function()
			PauseGame(false)
		end)
	--CS.BattleScaler.InitScalerByMaxNum(0)
	spine = character.listMember[0]
end
JoyStickMove = function(input)
	local XPara = speedXPara
	if input.value <= 0.01 then
		return
	end
	--print(input.value)
	local x =
	CS.Mathf.Clamp(
		character.transform.localPosition.x - math.sin(input.eulerAngle) * character.realtimeSpeed * XPara * input.value,
		minX,
		maxX
	)
	local y =
	CS.Mathf.Clamp(
		character.transform.localPosition.z + math.cos(input.eulerAngle) * character.realtimeSpeed * speedYPara * input.value,
		minY,
		maxY
	)
	if input.eulerAngle < math.pi then
		if dir >0 then
			dir = -1
			spine:SetDirection(-1)
		end		
		
	else
		if dir <0 then
			dir = 1
			spine:SetDirection(1)
		end
	end
	
	
	--print("原始速度:"..character.realtimeSpeed .." ".."最终速度:"..character.gun.speed * XPara * input.value)
	local offset = CS.UnityEngine.Vector3(x, 0, y)
	character.transform.localPosition = offset
end

JoyStickBegin = function(input)
	spine:SetSpine(GetMoveCode(),dir)
end

JoyStickEnd = function(input)
	print("End")
	spine:SetSpine(GetWaitCode(),dir)
end
OnDestroy = function()
	xlua.hotfix(CS.BattleInteractionController,'DisableRangeLine',nil)
	xlua.hotfix(CS.GF.Battle.BattleController,'RefreshFriendlyTargetList',nil)
end
Update = function()
	if haloObj ~= nil and haloObj.activeSelf then
		haloObj:SetActive(false)
	end
	MainLoop()
	
end
function MainLoop()
	totalTimer = totalTimer - CS.UnityEngine.Time.deltaTime
	UpdateRemainTime()
end
function GetMoveCode()
	return "move"
end
function GetWaitCode()
	return "spwait0"
end

function UpdateFever(feverCount)
	if playerFeverValue == feverCount then
		return
	end
	playerFeverValue = feverCount
	if playerFeverValue > feverGuageMax then
		playerFeverValue = feverGuageMax
	end
	if playerFeverValue < 0 then
		playerFeverValue = 0
	end
	local feverpercent = playerFeverValue / feverGuageMax
	_imgFeverGauge:DOFillAmount(feverpercent,0.01) 
	txtFever.text = string.format("%d",math.ceil(playerFeverValue)) ..'/'..feverGuageMax
end

function PauseGame(isPause)
	isUIPausing = isPause
	if isUIPausing then
		goPause:SetActive(true)
		CS.UnityEngine.Time.timeScale = 0
	else
		goPause:SetActive(false)
		CS.UnityEngine.Time.timeScale = 1
	end
end

function ExitGame()
	CS.UnityEngine.Time.timeScale = 1
	CS.BattleFrameManager.ResumeTime()
	CS.GF.Battle.BattleController.Instance:TriggerBattleFinishEvent(true)
	CS.UnityEngine.Object.Destroy(self.gameObject)
end

function ShowResult()
	goResultScoreItem:SetActive(false)
	goShow:SetActive(true)
	if CS.GameData.userInfo ~= nil then
		textResultName:GetComponent(typeof(CS.ExText)).text = CS.GameData.userInfo.name
		textResultID:GetComponent(typeof(CS.ExText)).text = CS.GameData.userInfo.userId
	end
	textResultCombo:GetComponent(typeof(CS.ExText)).text = math.floor(bestMaintain)
	textResultTime:GetComponent(typeof(CS.ExText)).text = totalTime
	local strScore = tostring(playerScore) 
	for i=1,string.len(strScore) do
		local num = tonumber(string.sub(strScore,i,i)) 
		local scoreitem =CS.UnityEngine.Object.Instantiate(goResultScoreItem) 
		scoreitem.transform:SetParent(transResultScore.transform,false)
		scoreitem:SetActive(true)
		scoreitem:GetComponent(typeof(CS.ExImage)).sprite = spriteListResultScore.listSprite[num]
	end
end
function EndGame()
	
	for i=CS.GF.Battle.BattleController.Instance.enemyTeamHolder.listCharacter.Count-1,0,-1 do
		local DamageInfo = CS.GF.Battle.BattleDamageInfo()
		CS.GF.Battle.BattleController.Instance.enemyTeamHolder.listCharacter[i]:UpdateLife(DamageInfo, -999999)
	end
	CS.BattleFrameManager.ResumeTime()
	CS.UnityEngine.Object.Destroy(GoResult)
	CS.UnityEngine.Object.Destroy(self.gameObject)
end
function UpdateRemainTime()
	local timeValue = math.floor(totalTimer)
	if timeValue <0 then
		timeValue = 0
	end
	local minute = math.floor(timeValue / 60)
	local second = timeValue - minute * 60
	if totalTime >= 60 then
		local minute1 = math.floor(minute / 10)
		local minute2 = minute - minute1 * 10
		_imgTime1.sprite = spriteListTime.listSprite[minute1]
		_imgTime2.sprite = spriteListTime.listSprite[minute2]
		
	end
	local sec1 = math.floor(second / 10)
	local sec2 = second - sec1 * 10
	_imgTime3.sprite = spriteListTime.listSprite[sec1]
	_imgTime4.sprite = spriteListTime.listSprite[sec2]
end