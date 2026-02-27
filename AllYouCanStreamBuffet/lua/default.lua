local goty2_keys = {0,0,0,0,0,0,0,0}
--An input handler, taken from TaroNuke's Spider Dance file, modified to suit what I need in the current file. -Kid
local InputHandler = function( event )

	-- if (somehow) there's no event, bail
	if not event then return end

	if event.type == "InputEventType_FirstPress" then

		if event.button == "Left" and event.PlayerNumber == PLAYER_1 then
			goty2_keys[1] = 1
		end
		if event.button == "Down" and event.PlayerNumber == PLAYER_1 then
			goty2_keys[2] = 1
		end
		if event.button == "Up" and event.PlayerNumber == PLAYER_1 then
			goty2_keys[3] = 1
		end
		if event.button == "Right" and event.PlayerNumber == PLAYER_1 then
			goty2_keys[4] = 1
		end
		if event.button == "Left" and event.PlayerNumber == PLAYER_2 then
			goty2_keys[5] = 1
		end
		if event.button == "Down" and event.PlayerNumber == PLAYER_2 then
			goty2_keys[6] = 1
		end
		if event.button == "Up" and event.PlayerNumber == PLAYER_2 then
			goty2_keys[7] = 1
		end
		if event.button == "Right" and event.PlayerNumber == PLAYER_2 then
			goty2_keys[8] = 1
		end

	end

	if event.type == "InputEventType_Release" then

		if event.button == "Left" and event.PlayerNumber == PLAYER_1 then
			goty2_keys[1] = 0
		end
		if event.button == "Down" and event.PlayerNumber == PLAYER_1 then
			goty2_keys[2] = 0
		end
		if event.button == "Up" and event.PlayerNumber == PLAYER_1 then
			goty2_keys[3] = 0
		end
		if event.button == "Right" and event.PlayerNumber == PLAYER_1 then
			goty2_keys[4] = 0
		end
		if event.button == "Left" and event.PlayerNumber == PLAYER_2 then
			goty2_keys[5] = 0
		end
		if event.button == "Down" and event.PlayerNumber == PLAYER_2 then
			goty2_keys[6] = 0
		end
		if event.button == "Up" and event.PlayerNumber == PLAYER_2 then
			goty2_keys[7] = 0
		end
		if event.button == "Right" and event.PlayerNumber == PLAYER_2 then
			goty2_keys[8] = 0
		end

	end

end
local cond_a_result= GAMESTATE:IsHumanPlayer(0)

local cond_c_result= GAMESTATE:IsHumanPlayer(0) and GAMESTATE:IsHumanPlayer(1)

local cond_b_result= GAMESTATE:IsHumanPlayer(1)
--Because speedmod check. -Kid
local poptions = {GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions('ModsLevel_Song'),GAMESTATE:GetPlayerState(PLAYER_2):GetPlayerOptions('ModsLevel_Song')}

local function optional_actor(cond, actor)
	if cond then return actor end
	return Def.Actor{}
end
local function diff_to_number(difficult)--Low-grade code for compatibility reasons. -Kid
    if difficult == 'Difficulty_Beginner' then return 0
    elseif difficult == 'Difficulty_Easy' then return 1
    elseif difficult == 'Difficulty_Medium' then return 2
    elseif difficult == 'Difficulty_Hard' then return 3
    elseif difficult == 'Difficulty_Challenge' then return 4
    elseif difficult == 'Difficulty_Edit' then return 5
    end
end

--Scaling variables. -Kid
local goty2_height_ratio = SCREEN_HEIGHT/480
local goty2_width_ratio = SCREEN_WIDTH/640
local goty2_sdwidth_ratio = (480*(SCREEN_WIDTH/SCREEN_HEIGHT))/640


--[[
TODO:
	Test it
]]

--GetSaved isn't a thing. -Kid
--taroProfile = PROFILEMAN:GetMachineProfile():GetSaved()
--taroProfile.UKSRT7Stream = taroProfile.UKSRT7Stream or { highScore = 0 }

--Also, we can't use the machine profile as it doesn't have a data table. -Kid
local taroProfile = PROFILEMAN:GetProfile(PLAYER_1):GetUserTable() or PROFILEMAN:GetProfile(PLAYER_2):GetUserTable()
--Do we exist? -Kid
if taroProfile then
    taroProfile.UKSRT7Stream = taroProfile.UKSRT7Stream or { highScore = 0 }
else
    taroProfile = { UKSRT7Stream = { highScore = 0 } }
end

local goty2_stream_highScore = tonumber(taroProfile.UKSRT7Stream.highScore);--Make damn sure it's actually a number. -Kid

if not goty2_stream_todayBest then goty2_stream_todayBest = 0 end

local function goty2_round(num)
	return math.floor((num * 100) + 0.5) / 100
end
local function goty2_round1(num)
	return math.floor((num * 10) + 0.5) / 10
end
local function goty2_round0(num)
	return math.floor(num + 0.5)
end

local checked = false;

local songName = GAMESTATE:GetCurrentSong():GetSongDir();

goty2_difficultyP1 = 3;
goty2_difficultyP2 = 3;

goty2_stream_held = {0,0,0,0,0,0,0,0};

goty2_stream_score = {0,0};
goty2_stream_multiplier = {1,1};

if GAMESTATE:IsPlayerEnabled(PLAYER_1) then--We want actual numbers. -Kid
	goty2_difficultyP1 = diff_to_number(GAMESTATE:GetCurrentSteps(PLAYER_1):GetDifficulty());
	--Better speedmod detection. -Kid
	if PlayerOptions.AMod and poptions[1]:AMod() then goty2_stream_multiplier[1] = goty2_round(poptions[1]:AMod()/150)
	elseif poptions[1]:MMod() then goty2_stream_multiplier[1] = goty2_round(poptions[1]:MMod()/150)
	elseif poptions[1]:XMod() then goty2_stream_multiplier[1] = goty2_round(poptions[1]:XMod())
	elseif poptions[1]:CMod() then goty2_stream_multiplier[1] = goty2_round(poptions[1]:CMod()/150) end

end
if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	goty2_difficultyP2 = diff_to_number(GAMESTATE:GetCurrentSteps(PLAYER_2):GetDifficulty());
	--Better speedmod detection. -Kid
	if PlayerOptions.AMod and poptions[2]:AMod() then goty2_stream_multiplier[2] = goty2_round(poptions[2]:AMod()/150)
	elseif poptions[2]:MMod() then goty2_stream_multiplier[2] = goty2_round(poptions[2]:MMod()/150)
	elseif poptions[2]:XMod() then goty2_stream_multiplier[2] = goty2_round(poptions[2]:XMod())
	elseif poptions[2]:CMod() then goty2_stream_multiplier[2] = goty2_round(poptions[2]:CMod()/150) end
end

goty2_stream_note = {{},{}}
goty2_stream_nptr = {1,1};
goty2_stream_dirs = {90,0,180,-90}

goty2_stream_show = 12;

goty2_stream_notespacing = {SCREEN_HEIGHT*0.08,SCREEN_HEIGHT*0.08};

goty2_stream_diff = {1,1,1,1,2,3}

goty2_stream_patterns = {
	{1,2,3,4,3,2},
	{1,3,2,4,2,3},
	{1,2,1,4,2,4},
	{1,3,1,4,3,4},
	{1,2,1,4,1,2,1,4},
	{1,3,1,4,1,3,1,4},
	{1,4,1,4,2,4,2,4},
	{1,4,1,4,1,2,1,2},
	{1,2,1,2,3,4,3,4},
	{1,3,1,3,2,4,2,4},
	{1,2,3,4,2,3},
	{1,3,2,4,3,2},
	{1,2,3,4},
	{1,3,2,4},
	{1,4,3,2},
	{1,4,2,3},
	{1,4,1,3,1,2},
	{1,4,1,2,1,3},
	{1,2,3,4,2,3,2,3},
	{1,3,2,4,3,2,3,2},
}

goty2_stream_patterns2 = {
	{1,2,4,2},
	{1,3,4,3},
	{1,2,4,2,3,4},
	{1,3,4,3,2,4},
	{1,2,4,1,3,4},
	{1,3,4,1,2,4},
	{1,2,3,2,4,2},
	{1,3,2,3,4,3},
	{1,2,4,1,4,2},
	{1,3,4,1,4,3},
	{1,2,4,2,4,2},
	{1,3,4,3,4,3},
}

goty2_stream_patterns3 = {
	{1,2,2,4},
	{1,3,3,4},
	{1,2,2,3},
	{1,3,3,2},
	{1,4,3,3},
	{1,4,2,2},
}

--generate one chart per day, so everyone in the tournament plays the same chart*
--*unless the machine shits the bed
if not goty2_stream_chart1 then
	goty2_stream_chart1 = {};

	local n = 1;
	local r = -1;
	for j=1,200 do
		n = math.random(1,table.getn(goty2_stream_patterns));
		for i=1,table.getn(goty2_stream_patterns[n]) do
			table.insert(goty2_stream_chart1,goty2_stream_patterns[n][i]);
		end
	end

end

if not goty2_stream_chart2 then
	goty2_stream_chart2 = {};

	local n = 1;
	local r = -1;
	for j=1,200 do
		if math.mod(j,8) == 0 then
			n = math.random(1,table.getn(goty2_stream_patterns3));
			for i=1,table.getn(goty2_stream_patterns3[n]) do
				table.insert(goty2_stream_chart2,goty2_stream_patterns3[n][i]);
			end
		elseif math.mod(j,8) == 3 or math.mod(j,8) == 4 or math.mod(j,8) == 7 then
			n = math.random(1,table.getn(goty2_stream_patterns2));
			for i=1,table.getn(goty2_stream_patterns2[n]) do
				table.insert(goty2_stream_chart2,goty2_stream_patterns2[n][i]);
			end
		else
			n = math.random(1,table.getn(goty2_stream_patterns));
			for i=1,table.getn(goty2_stream_patterns[n]) do
				table.insert(goty2_stream_chart2,goty2_stream_patterns[n][i]);
			end
		end
	end

end

if not goty2_stream_chart3 then
	goty2_stream_chart3 = {};

	local n = 1;
	local r = -1;
	for j=1,200 do
		if math.mod(j,4) ~= 0 then
			n = math.random(1,table.getn(goty2_stream_patterns2));
			for i=1,table.getn(goty2_stream_patterns2[n]) do
				table.insert(goty2_stream_chart3,goty2_stream_patterns2[n][i]);
			end
		else
			n = math.random(1,table.getn(goty2_stream_patterns3));
			for i=1,table.getn(goty2_stream_patterns3[n]) do
				table.insert(goty2_stream_chart3,goty2_stream_patterns3[n][i]);
			end
		end
	end

end

local function goty2_stream_nextn(pn)
	goty2_stream_nptr[pn] = goty2_stream_nptr[pn]+1;
	if goty2_stream_nptr[pn] > table.getn(goty2_stream_note[pn]) then
		goty2_stream_nptr[pn] = 1
	end
end

local function goty2_stream_gety(n)
	return SCREEN_HEIGHT*0.25;
end

goty2_stream_scale = 0.8;
goty2_stream_speedmod = 1.5;

goty2_stream_axs = {-96,-32,32,96};

local function goty2_stream_color(obj, n)
	if n == 4 then obj:diffuse(1,0.4,0.3,1); end
	if n == 8 then obj:diffuse(0.3,0.7,1,1); end
	if n == 12 then obj:diffuse(1,0.4,1,1); end
	if n == 16 then obj:diffuse(0.3,1,0.4,1); end
	if n == 32 then obj:diffuse(1,0.8,0.3,1); end
	if n == 64 then obj:diffuse(0.3,1,0.7,1); end
end

local function goty2_stream_quantize(obj, b)
	b = b/4;
	local r = b-math.floor(b)
	if r == 0 then goty2_stream_color(obj,4)
	elseif r == 0.5 then goty2_stream_color(obj,8)
	elseif (r > 0.33 and r < 0.34) or (r > 0.66 and r < 0.67) then goty2_stream_color(obj,12)
	elseif r == 0.25 or r == 0.75 then goty2_stream_color(obj,16)
	elseif (r > 0.166 and r < 0.167) or (r > 0.83 and r < 0.84) then goty2_stream_color(obj,12)
	elseif r == 0.125 or r == 0.375 or r == 0.625 or r == 0.875 then goty2_stream_color(obj,32)
	else goty2_stream_color(obj,64) end
end

local function goty2_stream_placenote(pn,time,dir)
	local h = goty2_stream_notespacing[pn];

	--Trace('nptr: '..goty2_stream_nptr[pn]);
	--Trace('Place Note for P'..pn);

	local a = goty2_stream_note[pn][goty2_stream_nptr[pn]];
	if not a then return end

	local b = a.actor;

	table.insert(goty2_stream_mynotes[pn],b);

	b:visible(true);

	goty2_stream_quantize(b, time-1);
	b:zoom(goty2_height_ratio)--Scale zoom and position. -Kid
	b:rotationz(goty2_stream_dirs[dir]);
	b:x((SCREEN_WIDTH*-0.25)+((pn)*SCREEN_CENTER_X)+(goty2_stream_axs[dir])*goty2_height_ratio);
	b:y(goty2_stream_gety(0)+((time-1)*h));

	--Trace(b:GetX());

	goty2_stream_nextn(pn);
end

goty2_stream_curnotep1 = 1;
goty2_stream_curnotep2 = 1;

local function goty2_stream_update(pn,move)

	--Trace('Update player '..pn);

	if not goty2_stream_mynotes[pn] then
		return;
	end

	if not goty2_stream_mynotes[pn][1] then
		return;
	end

	if move then
		goty2_stream_mynotes[pn][1]:linear(1/math.max(goty2_stream_nps[pn],10));
		goty2_stream_mynotes[pn][1]:diffusealpha(-1);
		goty2_stream_mynotes[pn][1]:zoom(1.4*goty2_height_ratio);--Scale zooms and positioning. -Kid
		goty2_stream_mynotes[pn][1]:sleep(0);
		goty2_stream_mynotes[pn][1]:diffusealpha(1);
		goty2_stream_mynotes[pn][1]:zoom(goty2_height_ratio);

		local ind = _G['goty2_stream_curnotep'..pn]
		local head = _G['goty2_stream_chart'..goty2_stream_diff[_G['goty2_difficultyP'..pn]+1]][ind]
		goty2_stream_mynotes[pn][1]:x((SCREEN_WIDTH*-0.25)+((pn)*SCREEN_CENTER_X)+(goty2_stream_axs[head])*goty2_height_ratio);
		goty2_stream_mynotes[pn][1]:rotationz(goty2_stream_dirs[head]);
		goty2_stream_quantize(goty2_stream_mynotes[pn][1], ind-1);
	end

	for i=2,goty2_stream_show do
		if move then
			goty2_stream_mynotes[pn][i]:linear(1/math.max(goty2_stream_nps[pn],10));
			goty2_stream_mynotes[pn][i]:y(goty2_stream_gety(0)+(goty2_stream_notespacing[pn]*(i-2)));
			goty2_stream_mynotes[pn][i]:sleep(0);
			goty2_stream_mynotes[pn][i]:y(goty2_stream_gety(0)+(goty2_stream_notespacing[pn]*(i-1)));

			local ind = _G['goty2_stream_curnotep'..pn]+i-1
			local body = _G['goty2_stream_chart'..goty2_stream_diff[_G['goty2_difficultyP'..pn]+1]][ind]
			goty2_stream_mynotes[pn][i]:x((SCREEN_WIDTH*-0.25)+((pn)*SCREEN_CENTER_X)+(goty2_stream_axs[body])*goty2_height_ratio);--Scale positioning. -Kid
			goty2_stream_mynotes[pn][i]:rotationz(goty2_stream_dirs[body]);
			goty2_stream_quantize(goty2_stream_mynotes[pn][i], ind-1);
		else
			goty2_stream_mynotes[pn][i]:linear(0.1);
			goty2_stream_mynotes[pn][i]:y(goty2_stream_gety(0)+(goty2_stream_notespacing[pn]*(i-1)));
		end
	end

end
goty2_sounds = {}
return Def.ActorFrame{
	Name= "actor_d",
	--SOUNDS--
	Def.Sound{ File=songName..'lua/gung.ogg', InitCommand= function(self) goty2_sounds.gung = self end },
	Def.Sound{ File=songName..'lua/airhorn.ogg', InitCommand= function(self) goty2_sounds.airhorn = self end },
	Def.Sound{ File=songName..'lua/bang.ogg', InitCommand= function(self) goty2_sounds.bang = self end },
	Def.Sound{ File=songName..'lua/record.ogg', InitCommand= function(self) goty2_sounds.record = self end },
	Def.Actor{ OnCommand= function(self) self:sleep(9e9) end },
	Def.Actor{
		Name= "actor_f",
		EndCommand= function(self)
			if SCREENMAN:GetTopScreen() then screen:RemoveInputCallback( InputHandler ); end
		end,--Alright, pick up your toys and go. -Kid
		InitCommand= function (self)


		end,
		KillCommand= function(self)
			--any cleanup, if necessary
		end,
		StartMessageCommand= function(self)

			if GAMESTATE:GetSongBeat()>=0 and not checked then

				----------------------
				-- grab everything? --
				----------------------
				if SCREENMAN:GetTopScreen():GetChild('LifeP1') then LifeP1 = SCREENMAN:GetTopScreen():GetChild('LifeP1') end
				if SCREENMAN:GetTopScreen():GetChild('LifeP2') then LifeP2 = SCREENMAN:GetTopScreen():GetChild('LifeP2') end
				if SCREENMAN:GetTopScreen():GetChild('ScoreP1') then ScoreP1 = SCREENMAN:GetTopScreen():GetChild('ScoreP1') end
				if SCREENMAN:GetTopScreen():GetChild('ScoreP2') then ScoreP2 = SCREENMAN:GetTopScreen():GetChild('ScoreP2') end
				if SCREENMAN:GetTopScreen():GetChild('BPMDisplay') then BPMDisplay = SCREENMAN:GetTopScreen():GetChild('BPMDisplay') end
				if SCREENMAN:GetTopScreen():GetChild('LifeFrame') then LifeFrame = SCREENMAN:GetTopScreen():GetChild('LifeFrame') end
				if SCREENMAN:GetTopScreen():GetChild('ScoreFrame') then ScoreFrame = SCREENMAN:GetTopScreen():GetChild('ScoreFrame') end
				if SCREENMAN:GetTopScreen():GetChild('Lyrics') then Lyrics = SCREENMAN:GetTopScreen():GetChild('Lyrics') end
				if SCREENMAN:GetTopScreen():GetChild('SongForeground') then SongForeground = SCREENMAN:GetTopScreen():GetChild('SongForeground') end
				if SCREENMAN:GetTopScreen():GetChild('SongBackground') then SongBackground = SCREENMAN:GetTopScreen():GetChild('SongBackground') end
				if SCREENMAN:GetTopScreen():GetChild('Overlay') then Overlay = SCREENMAN:GetTopScreen():GetChild('Overlay') end
				if SCREENMAN:GetTopScreen():GetChild('Underlay') then Underlay = SCREENMAN:GetTopScreen():GetChild('Underlay') end

				--------------------------
				-- hide everything? y/n --
				--------------------------
				mod_hideall = true;
				if mod_hideall == true then
					if LifeFrame then LifeFrame:visible(false) end
					if LifeP1 then LifeP1:visible(false) end
					if LifeP2 then LifeP2:visible(false) end
					if ScoreP1 then ScoreP1:visible(false) end
					if ScoreP2 then ScoreP2:visible(false) end
					if SCREENMAN:GetTopScreen():GetChild('BPMDisplay') then BPMDisplay:visible(false) end
					if Overlay then Overlay:visible(false) end
					if Underlay then Underlay:visible(false) end
					if SCREENMAN:GetTopScreen():GetChild('ScoreFrame') then ScoreFrame:visible(false) end
					--Hide more things. -Kid
					if SCREENMAN:GetTopScreen():GetChild('StageDisplay') then SCREENMAN:GetTopScreen():GetChild('StageDisplay'):visible(false) end
					if SCREENMAN:GetTopScreen():GetChild('SongTitle') then SCREENMAN:GetTopScreen():GetChild('SongTitle'):visible(false) end
					if SCREENMAN:GetTopScreen():GetChild("SongMeterDisplayP1") then SCREENMAN:GetTopScreen():GetChild("SongMeterDisplayP1"):visible(false) end
					if SCREENMAN:GetTopScreen():GetChild("StepsDisplayP1") then SCREENMAN:GetTopScreen():GetChild("StepsDisplayP1"):visible(false) end
					if SCREENMAN:GetTopScreen():GetChild("SongMeterDisplayP2") then SCREENMAN:GetTopScreen():GetChild("SongMeterDisplayP2"):visible(false) end
					if SCREENMAN:GetTopScreen():GetChild("StepsDisplayP2") then SCREENMAN:GetTopScreen():GetChild("StepsDisplayP2"):visible(false) end
					--Old Lambda-specific things. -Kid
					if SCREENMAN:GetTopScreen():GetChild("LifeMeterBarP1") then SCREENMAN:GetTopScreen():GetChild('LifeMeterBarP1'):visible(false) end
					if SCREENMAN:GetTopScreen():GetChild("LifeMeterBarP2") then SCREENMAN:GetTopScreen():GetChild('LifeMeterBarP2'):visible(false) end
				end

				P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
				P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
				--aliases for old times sake

				screen = SCREENMAN:GetTopScreen();
				screen:AddInputCallback( InputHandler )--The fun begins. -Kid
				checked = true;
			end

			--[[
			--reset screen reset (alt for ctrl+f)
			--reload screen if not using the correct noteskin
			if not EditMode and not GAMESTATE:IsDemonstration() then
				--SCREENMAN:SystemMessage(tostring(mimi_divine));
				if not (GAMESTATE:IsHumanPlayer(0) and GAMESTATE:PlayerIsUsingModifier(0,'DivinEntity'))
				or not (GAMESTATE:IsHumanPlayer(1) and GAMESTATE:PlayerIsUsingModifier(1,'DivinEntity'))
				and not mimi_screenresets then
					GAMESTATE:SetTemporaryEventMode(true);
					GAMESTATE:ApplyGameCommand('mod,DivinEntity');
					SCREENMAN:SetNewScreen('ScreenGameplay')
					mimi_screenresets = true;
					--SCREENMAN:SystemMessage(tostring(mimi_divine));
				else
					GAMESTATE:SetTemporaryEventMode(false);
					mimi_screenresets = false;
					if not DIVINE_ENTITY then
						MESSAGEMAN:Broadcast('NoteskinWarning');
						mimi_divine = false;
					else
						mimi_divine = true;
						mimi_god = false;
					end
					--SCREENMAN:SystemMessage(tostring(mimi_divine));
				end
			end
			]]

			--No need for DivinEntity check. -Kid

			goty2_stream_mynotes = {{},{}};

			goty2_stream_score = {0,0};

			goty2_stream_wrongnotes = {0,0}

			goty2_stream_nps = {1,1}
			goty2_stream_nps_count = {0,0}
			goty2_stream_nps_timer = {0,0}
			goty2_stream_nps_hitdelay = {0,0}

			goty2_stream_wrongwait = {0,0}

			goty2_stream_started = {0,0}


			for pn=1,2 do
				if GAMESTATE:IsHumanPlayer(pn-1) then
					for i=1,goty2_stream_show do
						goty2_stream_placenote(pn,i,_G['goty2_stream_chart'..goty2_stream_diff[_G['goty2_difficultyP'..pn]+1]][i]);
					end
				end
			end

			self:sleep(0.1);
			self:queuecommand('Update');

		end,
    UpdateCommand= function(self)

			--game logic

			--if goty2_stream_started[1] == 1 then
				--Trace(goty2_stream_nps[1]..' nps');
				--Trace(goty2_stream_notespacing[1]..' spacing');
			--end

			for pn=1,2 do

				if goty2_stream_wrongwait[pn] > 0 then
					goty2_stream_wrongwait[pn] = goty2_stream_wrongwait[pn]-0.02;
				end

				if goty2_stream_started[pn] == 1 then
					goty2_stream_nps_timer[pn] = goty2_stream_nps_timer[pn]+0.02
					goty2_stream_nps_hitdelay[pn] = goty2_stream_nps_hitdelay[pn]+0.02
				end

				if goty2_stream_nps_hitdelay[pn]>0.4 and GAMESTATE:GetSongBeat()<78.6 then
					goty2_stream_nps_hitdelay[pn] = 0;
					goty2_stream_nps_timer[pn] = 0;
					goty2_stream_nps_count[pn] = 0;
					goty2_stream_started[pn] = 0;
					goty2_stream_nps[pn] = (goty2_stream_nps_count[pn]/math.max(goty2_stream_nps_timer[pn],1))*1.5;
					goty2_stream_notespacing[pn] = (SCREEN_HEIGHT*0.08)+(SCREEN_HEIGHT*0.1*(goty2_stream_nps[pn]/25))*goty2_stream_multiplier[pn]*0.33
					goty2_stream_update(pn);
				end

				--_G['goty2_stream_p'..pn..'mtext']:settext(goty2_round1(goty2_stream_nps[pn]));
				_G['goty2_stream_p'..pn..'mtext']:settext('');

				goty2_stream_nps[pn] = (goty2_stream_nps_count[pn]/math.max(goty2_stream_nps_timer[pn],1))*1.5;
				goty2_stream_notespacing[pn] = (SCREEN_HEIGHT*0.08)+(SCREEN_HEIGHT*0.1*(goty2_stream_nps[pn]/25))*goty2_stream_multiplier[pn]*0.33

				if GAMESTATE:IsHumanPlayer(pn-1) then
					_G['goty2_stream_p'..pn]:y(goty2_stream_gety(0));
				else
					_G['goty2_stream_p'..pn]:y(-1000*goty2_height_ratio);
				end

				local bpn = pn-1;
				for i=1,4 do

					--Trace(goty2_keys[i+(bpn*4)]);

					----------------------handle button presses-------------------
					if GAMESTATE:IsHumanPlayer(pn-1) and GAMESTATE:GetSongBeat()>16 and GAMESTATE:GetSongBeat()<78.6 and goty2_stream_wrongwait[pn] <= 0 then
						if goty2_keys[i+(bpn*4)] == 1 and goty2_stream_held[i+(bpn*4)] == 0 then

							if i==_G['goty2_stream_chart'..goty2_stream_diff[_G['goty2_difficultyP'..pn]+1]][_G['goty2_stream_curnotep'..pn]] then

								goty2_stream_started[pn] = 1;
								goty2_stream_nps_hitdelay[pn] = 0;

								_G['goty2_stream_curnotep'..pn] = _G['goty2_stream_curnotep'..pn]+1;

								goty2_stream_nps_count[pn] = goty2_stream_nps_count[pn]+1;
								goty2_stream_update(pn,true);

								goty2_stream_wrongnotes[pn] = 0;

								goty2_stream_score[pn] = goty2_stream_score[pn]+1;

								_G['goty2_stream_p'..pn..'ctext']:finishtweening();
								_G['goty2_stream_p'..pn..'ctext']:settext(goty2_stream_score[pn]);
								_G['goty2_stream_p'..pn..'ctext']:diffusealpha(0.5);
								_G['goty2_stream_p'..pn..'ctext']:zoom(math.min(0.8+(goty2_stream_score[pn]/200),1.3)*goty2_height_ratio);--Scale zooms. -Kid
								_G['goty2_stream_p'..pn..'ctext']:linear(0.2);
								_G['goty2_stream_p'..pn..'ctext']:zoom(math.min(0.7+(goty2_stream_score[pn]/200),1.2)*goty2_height_ratio);

								_G['goty2_stream_p'..pn..'ctexta']:settext(goty2_stream_score[pn]);
								_G['goty2_stream_p'..pn..'ctexta']:zoom(math.min(0.7+(goty2_stream_score[pn]/200),1.2)*goty2_height_ratio);

							else

								if goty2_stream_wrongnotes[pn] > 2 then
									goty2_stream_wrongnotes[pn] = 0;
									goty2_stream_wrongwait[pn] = 0.8;

									goty2_stream_nps_hitdelay[pn] = 0;
									goty2_stream_nps_timer[pn] = 0;
									goty2_stream_nps_count[pn] = 0;
									goty2_stream_started[pn] = 0;
									goty2_stream_nps[pn] = (goty2_stream_nps_count[pn]/math.max(goty2_stream_nps_timer[pn],1))*1.5;
									goty2_stream_notespacing[pn] = (SCREEN_HEIGHT*0.08)+(SCREEN_HEIGHT*0.1*(goty2_stream_nps[pn]/25))*goty2_stream_multiplier[pn]*0.33
									goty2_stream_update(pn);

									goty2_sounds.gung:play()

									_G['goty2_stream_nfp'..pn]:decelerate(0.4);
									_G['goty2_stream_nfp'..pn]:addy(160*goty2_height_ratio);--Scale movement. -Kid
									_G['goty2_stream_nfp'..pn]:accelerate(0.4);
									_G['goty2_stream_nfp'..pn]:addy(-160*goty2_height_ratio);
								else
									goty2_stream_wrongnotes[pn] = goty2_stream_wrongnotes[pn]+1;
								end

							end

							goty2_stream_held[i+(bpn*4)] = 1

						end
					end

					----------------------don't touch this------------------------
					--release all buttons - used for detecting if a button is newly pressed, as opposed to held
					if goty2_keys[i+(bpn*4)] == 0 then
						goty2_stream_held[i+(bpn*4)] = 0
					end
					---------------------end don't touch this----------------------

				end

			end

			self:sleep(0.02);
			self:queuecommand('Update');

		end,
	},
	Def.Sprite{
		Name= "actor_g",
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):diffuse(color('0.6,0.6,0.6,1')) end,
		Texture= "Cranked Pastry-BG.png",
	},
	cond_a_result and Def.BitmapText{
		Name= "actor_h",
		Font= "Combo numbers",--Added zoom. -Kid
		InitCommand= function(self) goty2_stream_p1ctext = self end,
		OnCommand= function(self)
			self:x(SCREEN_WIDTH*0.25):y(SCREEN_HEIGHT*0.5):diffusealpha(0.5):zoom(goty2_height_ratio):shadowlength(0) end,
		Text= "",
	} or Def.Actor{},
	cond_b_result and Def.BitmapText{
		Name= "actor_i",
		Font= "Combo numbers",--Added zoom. -Kid
		InitCommand= function(self) goty2_stream_p2ctext = self end,
		OnCommand= function(self)
			self:x(SCREEN_WIDTH*0.75):y(SCREEN_HEIGHT*0.5):diffusealpha(0.5):zoom(goty2_height_ratio):shadowlength(0) end,
		Text= "",
	} or Def.Actor{},
	Def.BitmapText{
		Name= "actor_j",
		Font= "ScoreDisplayPercentage percent text",
		InitCommand= function(self) goty2_stream_p1mtext = self end,--Fixed & scaled positioning, scaled zoom. -Kid
		OnCommand= function(self)
			self:horizalign(left):x(goty2_width_ratio*3+(SCREEN_WIDTH*0.25)):y(SCREEN_HEIGHT*0.5+60*goty2_height_ratio)
			:zoom(0.5*goty2_height_ratio):diffusealpha(0.5):shadowlength(0) end,
		Text= "0",
	},
	Def.BitmapText{
		Name= "actor_k",
		Font= "ScoreDisplayPercentage percent text",
		InitCommand= function(self) goty2_stream_p2mtext = self end,
		OnCommand= function(self)
			self:horizalign(left):x(goty2_width_ratio*3+(SCREEN_WIDTH*0.75)):y(SCREEN_HEIGHT*0.5+60*goty2_height_ratio)
			:zoom(0.5*goty2_height_ratio):diffusealpha(0.5):shadowlength(0) end,
		Text= "0",
	},
	Def.ActorFrame{
		Name= "actor_l",
		InitCommand= function(self) goty2_stream_p1 = self end,
		OnCommand= function(self) self:x(SCREEN_WIDTH*0.25):y(SCREEN_CENTER_Y) end,
		--For all receptors, unconverted & scaled x pos, added zoom, lowercased EffectColor/Offset/Clock & DiffuseRamp functions, Enclosed clock parameters and EffectDelay -> effect_hold_at_full. -Kid
		Def.Sprite{
			Name= "actor_m",
			Frames= {
				{Frame= 0, Delay= 1},
				{Frame= 1, Delay= 1},
				{Frame= 2, Delay= 1},
				{Frame= 3, Delay= 1},
			},
			OnCommand= function(self)
				self:x(-96*goty2_height_ratio):zoom(goty2_height_ratio):rotationz(90):effectclock("beat")
				:diffuseramp():effectcolor1(0.4,0.4,0.4,1):effectcolor2(1,1,1,1,1):effectperiod(0.5)
				:effect_hold_at_full(0.5):effectoffset(0.05) end,
			Texture= "./receptor 4x1.png",
		},
		Def.Sprite{
			Name= "actor_n",
			Frames= {
				{Frame= 0, Delay= 1},
				{Frame= 1, Delay= 1},
				{Frame= 2, Delay= 1},
				{Frame= 3, Delay= 1},
			},
			OnCommand= function(self)
				self:x(-32*goty2_height_ratio):zoom(goty2_height_ratio):rotationz(0):effectclock("beat")
				:diffuseramp():effectcolor1(0.4,0.4,0.4,1):effectcolor2(1,1,1,1,1):effectperiod(0.5)
				:effect_hold_at_full(0.5):effectoffset(0.05) end,
			Texture= "./receptor 4x1.png",
		},
		Def.Sprite{
			Name= "actor_o",
			Frames= {
				{Frame= 0, Delay= 1},
				{Frame= 1, Delay= 1},
				{Frame= 2, Delay= 1},
				{Frame= 3, Delay= 1},
			},
			OnCommand= function(self)
				self:x(32*goty2_height_ratio):zoom(goty2_height_ratio):rotationz(180):effectclock("beat")
				:diffuseramp():effectcolor1(0.4,0.4,0.4,1):effectcolor2(1,1,1,1,1):effectperiod(0.5)
				:effect_hold_at_full(0.5):effectoffset(0.05) end,
			Texture= "./receptor 4x1.png",
		},
		Def.Sprite{
			Name= "actor_p",
			Frames= {
				{Frame= 0, Delay= 1},
				{Frame= 1, Delay= 1},
				{Frame= 2, Delay= 1},
				{Frame= 3, Delay= 1},
			},
			OnCommand= function(self)
				self:x(96*goty2_height_ratio):zoom(goty2_height_ratio):rotationz(-90):effectclock("beat")
				:diffuseramp():effectcolor1(0.4,0.4,0.4,1):effectcolor2(1,1,1,1,1):effectperiod(0.5)
				:effect_hold_at_full(0.5):effectoffset(0.05) end,
			Texture= "./receptor 4x1.png",
		},
	},
	Def.ActorFrame{
		Name= "actor_q",
		InitCommand= function(self) goty2_stream_p2 = self end,
		OnCommand= function(self) self:x(SCREEN_WIDTH*0.75):y(SCREEN_CENTER_Y) end,
		--For all receptors, unconverted & scaled x pos, added zoom, lowercased EffectColor/Offset/Clock & DiffuseRamp functions, Enclosed clock parameters and EffectDelay -> effect_hold_at_full. -Kid
		Def.Sprite{
			Name= "actor_r",
			Frames= {
				{Frame= 0, Delay= 1},
				{Frame= 1, Delay= 1},
				{Frame= 2, Delay= 1},
				{Frame= 3, Delay= 1},
			},
			OnCommand= function(self)
				self:x(-96*goty2_height_ratio):zoom(goty2_height_ratio):rotationz(90):effectclock("beat")
				:diffuseramp():effectcolor1(0.4,0.4,0.4,1):effectcolor2(1,1,1,1,1):effectperiod(0.5)
				:effect_hold_at_full(0.5):effectoffset(0.05) end,
			Texture= "./receptor 4x1.png",
		},
		Def.Sprite{
			Name= "actor_s",
			Frames= {
				{Frame= 0, Delay= 1},
				{Frame= 1, Delay= 1},
				{Frame= 2, Delay= 1},
				{Frame= 3, Delay= 1},
			},
			OnCommand= function(self)
				self:x(-32*goty2_height_ratio):zoom(goty2_height_ratio):rotationz(0):effectclock("beat")
				:diffuseramp():effectcolor1(0.4,0.4,0.4,1):effectcolor2(1,1,1,1,1):effectperiod(0.5)
				:effect_hold_at_full(0.5):effectoffset(0.05) end,
			Texture= "./receptor 4x1.png",
		},
		Def.Sprite{
			Name= "actor_t",
			Frames= {
				{Frame= 0, Delay= 1},
				{Frame= 1, Delay= 1},
				{Frame= 2, Delay= 1},
				{Frame= 3, Delay= 1},
			},
			OnCommand= function(self)
				self:x(32*goty2_height_ratio):zoom(goty2_height_ratio):rotationz(180):effectclock("beat")
				:diffuseramp():effectcolor1(0.4,0.4,0.4,1):effectcolor2(1,1,1,1,1):effectperiod(0.5)
				:effect_hold_at_full(0.5):effectoffset(0.05) end,
			Texture= "./receptor 4x1.png",
		},
		Def.Sprite{
			Name= "actor_u",
			Frames= {
				{Frame= 0, Delay= 1},
				{Frame= 1, Delay= 1},
				{Frame= 2, Delay= 1},
				{Frame= 3, Delay= 1},
			},
			OnCommand= function(self)
				self:x(96*goty2_height_ratio):zoom(goty2_height_ratio):rotationz(-90):effectclock("beat")
				:diffuseramp():effectcolor1(0.4,0.4,0.4,1):effectcolor2(1,1,1,1,1):effectperiod(0.5)
				:effect_hold_at_full(0.5):effectoffset(0.05) end,
			Texture= "./receptor 4x1.png",
		},
	},
	Def.ActorFrame{
		Name= "actor_v",
		InitCommand= function(self) goty2_stream_nfp1 = self; end,
		Def.Sprite{
			Name= "actor_w",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_x",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_y",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_z",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_A",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_B",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_C",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_D",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_E",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_F",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_ab",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_bb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_cb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_db",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_eb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_fb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_gb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_hb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_ib",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_jb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[1],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
	},
	Def.ActorFrame{
		Name= "actor_kb",
		InitCommand= function(self) goty2_stream_nfp2 = self; end,
		Def.Sprite{
			Name= "actor_lb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_mb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_nb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_ob",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_pb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_qb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_rb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_sb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_tb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_ub",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_vb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_wb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_xb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_yb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_zb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_Ab",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_Bb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_Cb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_Db",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
		Def.Sprite{
			Name= "actor_Eb",
			Frames= {
				{Frame= 0, Delay= 0.0625},
				{Frame= 1, Delay= 0.0625},
				{Frame= 2, Delay= 0.0625},
				{Frame= 3, Delay= 0.0625},
				{Frame= 4, Delay= 0.0625},
				{Frame= 5, Delay= 0.0625},
				{Frame= 6, Delay= 0.0625},
				{Frame= 7, Delay= 0.0625},
				{Frame= 8, Delay= 0.0625},
				{Frame= 9, Delay= 0.0625},
				{Frame= 10, Delay= 0.0625},
				{Frame= 11, Delay= 0.0625},
				{Frame= 12, Delay= 0.0625},
				{Frame= 13, Delay= 0.0625},
				{Frame= 14, Delay= 0.0625},
				{Frame= 15, Delay= 0.0625},
			},
			HideCommand= function(self) self:visible(false); end,
			OnCommand= function(self) self:visible(false):sleep(0.02):queuecommand("SetMe") end,
			SetMeCommand= function(self) table.insert(goty2_stream_note[2],{actor = self}) end,
			Texture= "./robot 4x4.png",
		},
	},
	--Quad full of input message commands is replaced with an InputHandler function. -Kid
	Def.Quad{
		Name= "actor_ac",--Unconverted & scaled positions and scaled zooms. -Kid
		OnCommand= function(self)
			self:horizalign(left):x(98*goty2_width_ratio):y(52*goty2_height_ratio)
			:zoomto((SCREEN_WIDTH-200*goty2_width_ratio)+4*goty2_width_ratio,20*goty2_height_ratio):diffuse(0,0,0,1) end,
		StartTimerMessageCommand= function(self)--Made diffuse use numbers. -Kid
			self:linear((79-16)*(60/150)):zoomto(4*goty2_width_ratio,20*goty2_height_ratio):diffuse(0,0,0,1) end,
		TimeUpMessageCommand= function(self) self:finishtweening():zoom(0) end,
	},
	Def.Quad{
		Name= "actor_bc",--Unconverted & scaled positions and scaled zooms. -Kid
		OnCommand= function(self)--Made diffuse use numbers. -Kid
			self:horizalign(left):x(100*goty2_width_ratio):y(52*goty2_height_ratio)
			:zoomto(SCREEN_WIDTH-200*goty2_width_ratio,16*goty2_height_ratio):diffuse(0,2,0,1) end,
		StartTimerMessageCommand= function(self)
			self:linear((79-16)*(60/150)):zoomto(0,16*goty2_height_ratio):diffuse(2,0,0,1) end,
	},
	Def.ActorFrame{
		Name= "actor_cc",--Unconverted and scaled positions and scaled zoom; 70 -> 80. -Kid
		OnCommand= function(self)--effectdelay -> effect_hold_at_full -Kid
			self:x(80*goty2_width_ratio):y(45*goty2_height_ratio):zoom(0.45*goty2_height_ratio):pulse()
			:effectmagnitude(1.2,1,0):effectclock("bgm"):effectperiod(.5):effect_hold_at_full(.5):effectoffset(0.6) end,
		TimeUpMessageCommand= function(self) self:visible(false) end,
		Def.Sprite{
			Name= "actor_dc",
			InitCommand= function(self) self:zbuffer(1) end,
			Texture= "stopwatch.png",
		},
		Def.ActorFrame{
		Name= "actor_ec",--Unconverted positions; also +45 isn't right. -Kid
			OnCommand= function(self) self:x(8):y(16):rotationz(15):spin():effectmagnitude(0,0,45):effectclock("bgm") end,
			Def.Sprite{
				Name= "actor_fc",--Unconverted positions. -Kid
				InitCommand= function(self) self:zbuffer(1):horizalign(right):vertalign(bottom):x(24):y(16) end,
				Texture= "hand.png",
			},
		},
		Def.Sprite{
			Name= "actor_gc",--Unconverted positions. -Kid
			InitCommand= function(self) self:zbuffer(1):horizalign(right):vertalign(bottom):x(36):y(36):visible(true) end,
			Texture= "center.png",
		},
	},
	Def.Sprite{
		Name= "actor_hc",
		Frames= {
			{Frame= 0, Delay= 0.05},
			{Frame= 1, Delay= 0.05},
			{Frame= 2, Delay= 0.05},
			{Frame= 3, Delay= 0.05},
			{Frame= 4, Delay= 0.05},
			{Frame= 5, Delay= 0.05},
			{Frame= 6, Delay= 0.05},
			{Frame= 7, Delay= 0.05},
			{Frame= 8, Delay= 0.05},
			{Frame= 9, Delay= 0.05},
			{Frame= 10, Delay= 0.05},
			{Frame= 11, Delay= 0.05},
			{Frame= 12, Delay= 0.05},
			{Frame= 13, Delay= 0.05},
			{Frame= 14, Delay= 0.05},
			{Frame= 15, Delay= 0.05},
			{Frame= 16, Delay= 0.05},
			{Frame= 17, Delay= 0.05},
			{Frame= 18, Delay= 0.05},
			{Frame= 19, Delay= 0.05},
			{Frame= 20, Delay= 0.05},
			{Frame= 21, Delay= 0.05},
			{Frame= 22, Delay= 0.05},
			{Frame= 23, Delay= 0.05},
			{Frame= 24, Delay= 0.05},
		},
		OnCommand= function(self) self:zoom(0) end,
		Texture= "./_explosion 5x5.png",--Same positioning as the watch and scale zoom. -Kid
		TimeUpMessageCommand= function(self)
			self:animate(1):setstate(0):x(80*goty2_width_ratio):y(45*goty2_height_ratio)
			:zoom(2*goty2_height_ratio):sleep(1.25):zoom(0) end,
	},
	Def.Sprite{
		Name= "actor_ic",
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
			:sleep(14*(60/150)):linear(60/150):diffusealpha(0) end,
		Texture= "_black.png",
	},
	Def.Sprite{
		Name= "actor_jc",--Scale zoom. -Kid
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):zoom(goty2_height_ratio):diffusealpha(0):sleep(0)
			:linear(0.4):diffusealpha(1):sleep(8*(60/150)):linear(0.4):diffusealpha(0) end,
		Texture= "text1.png",
	},
	Def.Sprite{
		Name= "actor_kc",--Scale zoom. -Kid
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):zoom(goty2_height_ratio):diffusealpha(0):sleep(8*(60/150)+0.4)
			:linear(0.4):diffusealpha(1):sleep(6*(60/150)-0.8):linear(0):diffusealpha(0) end,
		Texture= "text2.png",
	},
	Def.Sprite{
		Name= "actor_lc",--Scale zoom. -Kid
		OnCommand= function(self)
			self:vibrate():effectmagnitude(2,2,2):x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):zoom(goty2_height_ratio)
			:diffusealpha(0):sleep(14*(60/150)):linear(0):diffusealpha(1):sleep(1):linear(0.4):diffusealpha(0) end,
		Texture= "text3.png",
	},
	--[[Def.Quad{
		Name= "actor_mc",
		InitCommand= function(self) goty2_stream_controller = self end,
	},]]
	Def.Actor{
		Name= "actor_nc",
		OnCommand= function(self)
			goty2_started = false;
			mod_firstSeenBeat = GAMESTATE:GetSongBeat();
			fgcurcommand = 1;
			self:sleep(0.02);
			self:queuecommand('Update');
		end,
		UpdateCommand= function(self)

			local beat = GAMESTATE:GetSongBeat();

			if beat > mod_firstSeenBeat+1 and not goty2_started then
				MESSAGEMAN:Broadcast('Start');
				goty2_started = true;
			end

			if beat > 13.6 and fgcurcommand == 1 then
				goty2_sounds.airhorn:play()
				fgcurcommand = fgcurcommand+1;
			end

			if beat > 16 and fgcurcommand == 2 then
				MESSAGEMAN:Broadcast('StartTimer');
				fgcurcommand = fgcurcommand+1;
			end

			if beat > 78.6 and fgcurcommand == 3 then
				goty2_sounds.airhorn:play()
				goty2_sounds.bang:play()
				fgcurcommand = fgcurcommand+1;
			end

			if beat > 79 and fgcurcommand == 4 then
				MESSAGEMAN:Broadcast('TimeUp');

				local maxscore = math.max(goty2_stream_score[1], goty2_stream_score[2])
				if maxscore > goty2_stream_todayBest then
					goty2_stream_todayBest = maxscore
					goty2_sounds.record:play()
					MESSAGEMAN:Broadcast('UpdateTodayBest');
				end
				if maxscore > goty2_stream_highScore then
					taroProfile.UKSRT7Stream.highScore = maxscore
					goty2_stream_highScore = maxscore;
					MESSAGEMAN:Broadcast('UpdateHighScore');
				end

				if _G['goty2_stream_p1ctexta'] then
					_G['goty2_stream_p1ctexta']:diffusealpha(1);
				end
				if _G['goty2_stream_p2ctexta'] then
					_G['goty2_stream_p2ctexta']:diffusealpha(1);
				end

				for pn=1,2 do
					if goty2_stream_score[pn] == maxscore then
						if _G['goty2_stream_p'..pn..'ctexta'] then
							_G['goty2_stream_p'..pn..'ctexta']:rainbow();
						end
					end
				end

				fgcurcommand = fgcurcommand+1;
			end

			self:sleep(0.02);
			self:queuecommand('Update');
		end,
	},
	cond_c_result and Def.BitmapText{
		Name= "actor_oc",
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X-160*goty2_width_ratio):y(SCREEN_CENTER_Y-14*goty2_height_ratio-35*goty2_height_ratio)
			:zoom(1.3*goty2_height_ratio):diffusealpha(0):sleep(0) end,
		Text= "WINNER",
		TimeUpMessageCommand= function(self)
			if goty2_stream_score[1] > goty2_stream_score[2] then
				self:settext('WINNER');
				if _G['goty2_stream_p1ctexta'] then
					_G['goty2_stream_p1ctexta']:rainbow();
				end
				self:rainbow();
			end
			if goty2_stream_score[1] < goty2_stream_score[2] then
				self:settext('LOSE...');
				self:diffuse(0.4,0.6,1,1);
				self:zoom(1.1*goty2_height_ratio);
			end
			if goty2_stream_score[1] == goty2_stream_score[2] then
				self:settext('DRAW');
				self:zoom(1.1*goty2_height_ratio);
			end
			self:diffusealpha(1);
		end,
	} or Def.Actor{},
	cond_c_result and Def.BitmapText{
		Name= "actor_pc",
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X+160*goty2_width_ratio):y(SCREEN_CENTER_Y-14*goty2_height_ratio-35*goty2_height_ratio)
			:zoom(1.3*goty2_height_ratio):diffusealpha(0):sleep(0) end,
		Text= "WINNER",
		TimeUpMessageCommand= function(self)
			if goty2_stream_score[1] < goty2_stream_score[2] then
				self:settext('WINNER');
				if _G['goty2_stream_p2ctexta'] then
					_G['goty2_stream_p2ctexta']:rainbow();
				end
				self:rainbow();
			end
			if goty2_stream_score[1] > goty2_stream_score[2] then
				self:settext('LOSE...');
				self:diffuse(0.4,0.6,1,1);
				self:zoom(1.1*goty2_height_ratio);
			end
			if goty2_stream_score[1] == goty2_stream_score[2] then
				self:settext('DRAW');
				self:zoom(1.1*goty2_height_ratio);
			end
			self:diffusealpha(1);
		end,
	} or Def.Actor{},
	cond_a_result and Def.BitmapText{
		Name= "actor_qc",
		Font= "Combo numbers",--Scale zoom. -Kid
		InitCommand= function(self) goty2_stream_p1ctexta = self end,
		OnCommand= function(self)
			self:x(SCREEN_WIDTH*0.25):y(SCREEN_HEIGHT*0.5):zoom(goty2_height_ratio):diffusealpha(0):shadowlength(0) end,
		Text= "0",
	} or Def.Actor{},
	cond_b_result and Def.BitmapText{
		Name= "actor_rc",
		Font= "Combo numbers",--Scale zoom. -Kid
		InitCommand= function(self) goty2_stream_p2ctexta = self end,
		OnCommand= function(self)
			self:x(SCREEN_WIDTH*0.75):y(SCREEN_HEIGHT*0.5):zoom(goty2_height_ratio):diffusealpha(0):shadowlength(0) end,
		Text= "0",
	} or Def.Actor{},
	cond_a_result and Def.BitmapText{
		Name= "actor_sc",
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X-160*goty2_width_ratio):y(SCREEN_CENTER_Y-14*goty2_height_ratio+70*goty2_height_ratio)
			:zoom(0.8*goty2_height_ratio):diffusealpha(0):sleep(0) end,
		Text= "Average nps",
		TimeUpMessageCommand= function(self) self:diffusealpha(1) end,
	} or Def.Actor{},
	cond_a_result and Def.BitmapText{
		Name= "actor_tc",
		DoCommand= function(self)
			self:settext(goty2_round(goty2_stream_nps[1]/1.5));
			self:linear(0.5);
			self:diffusealpha(1);
		end,
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X-160*goty2_width_ratio):y(SCREEN_CENTER_Y+14*goty2_height_ratio+70*goty2_height_ratio)
			:zoom(0.8*goty2_height_ratio):diffusealpha(0):sleep(0) end,
		Text= "",
		TimeUpMessageCommand= function(self) self:playcommand("Do") end,
	} or Def.Actor{},
	cond_b_result and Def.BitmapText{
		Name= "actor_uc",
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X+160*goty2_width_ratio):y(SCREEN_CENTER_Y-14*goty2_height_ratio+70*goty2_height_ratio)
			:zoom(0.8*goty2_height_ratio):diffusealpha(0):sleep(0) end,
		Text= "Average nps",
		TimeUpMessageCommand= function(self) self:diffusealpha(1) end,
	} or Def.Actor{},
	cond_b_result and Def.BitmapText{
		Name= "actor_vc",
		DoCommand= function(self)
			self:settext(goty2_round(goty2_stream_nps[2]/1.5));
			self:linear(0.5);
			self:diffusealpha(1);
		end,
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:x(SCREEN_CENTER_X+160*goty2_width_ratio):y(SCREEN_CENTER_Y+14*goty2_height_ratio+70*goty2_height_ratio)
			:zoom(0.8*goty2_height_ratio):diffusealpha(0):sleep(0) end,
		Text= "",
		TimeUpMessageCommand= function(self) self:playcommand("Do") end,
	} or Def.Actor{},
	Def.BitmapText{
		Name= "actor_wc",
		Font= "_eurostile outline",
		OnCommand= function(self)
			self:vertalign(top):x(SCREEN_CENTER_X):y(SCREEN_BOTTOM-80*goty2_height_ratio)
			:zoom(0.8*goty2_height_ratio):diffusealpha(0):sleep(0):linear(0.5):diffusealpha(1) end,
		Text= "HIGH SCORE",
	},
	Def.BitmapText{
		Name= "actor_xc",
		DoCommand= function(self)
			self:settext(goty2_stream_highScore);
			self:linear(0.5);
			self:diffusealpha(1);
		end,
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:vertalign(top):x(SCREEN_CENTER_X):y(SCREEN_BOTTOM-52*goty2_height_ratio)
			:zoom(0.8*goty2_height_ratio):diffusealpha(0):sleep(0):queuecommand("Do") end,
		Text= "",
		UpdateHighScoreMessageCommand= function(self) self:rainbow():playcommand("Do") end,
	},
	Def.BitmapText{
		Name= "actor_yc",
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:vertalign(top):x(SCREEN_CENTER_X):y(SCREEN_BOTTOM-80*goty2_height_ratio-56*goty2_height_ratio)
			:zoom(0.8*goty2_height_ratio):diffusealpha(0):sleep(0):linear(0.5):diffusealpha(1) end,
		Text= "TODAY'S BEST",
	},
	Def.BitmapText{
		Name= "actor_zc",
		DoCommand= function(self)
			self:settext(goty2_stream_todayBest);
			self:linear(0.5);
			self:diffusealpha(1);
		end,
		Font= "_eurostile outline",--Scale positioning and zoom. -Kid
		OnCommand= function(self)
			self:vertalign(top):x(SCREEN_CENTER_X):y(SCREEN_BOTTOM-52*goty2_height_ratio-56*goty2_height_ratio)
			:zoom(0.8*goty2_height_ratio):diffusealpha(0):sleep(0):queuecommand("Do") end,
		Text= "",
		UpdateTodayBestMessageCommand= function(self) self:rainbow():playcommand("Do") end,
	},
	--No need for NoteskinWarning. -Kid
}
