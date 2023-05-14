-----------------------
-------VARIABLES-------
-----------------------


local ADDON_NAME, namespace = ...;
local variables = namespace.variables;
local functions = namespace.functions;
local locale = namespace.locale;


-----------------------
------UI FACTORIES-----
-----------------------


--Button factory to be used by both the leader and user window.
function functions.startButton(frame, firstAnchor, secondAnchor, xValue, yValue, title, xLength, yLength, func)
	local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate");
	button:SetPoint(firstAnchor, frame, secondAnchor, xValue, yValue);
	button:SetSize(xLength,yLength);
	button:SetText(title);
	button:SetScript("OnClick", func);
	return button;
end

--List factory.
function functions.scrollFrameFactory(frame, config, xValue, yValue, title, width, height)
	frame.width  = width;
	frame.height = height;
	frame:SetSize(frame.width, frame.height);
	frame:SetPoint("LEFT", config, "LEFT", xValue, yValue);
	frame:EnableMouse(true);
	frame:EnableMouseWheel(true);

	frame.title = frame:CreateFontString(nil,"OVERLAY");
	frame.title:SetFontObject("GameFontHighLight");
	frame.title:SetPoint("TOP", frame, "TOP", 0, 1);
	frame.title:SetText(title);

	--ScrollingMessageFrame
	local messageFrame = CreateFrame("ScrollingMessageFrame", nil, frame);
	messageFrame:SetPoint("TOPLEFT", 0, -17);
	messageFrame:SetPoint("BOTTOMRIGHT", 0, 38);
	messageFrame:SetFontObject("GameFontNormalSmall");
	messageFrame:SetTextColor(1, 1, 1, 1);
	messageFrame:SetJustifyH("LEFT");
	messageFrame:SetHyperlinksEnabled(true);
	messageFrame:SetFading(false);
	messageFrame:SetMaxLines(300);
	frame.messageFrame = messageFrame;

	local tex = messageFrame:CreateTexture(nil,"BACKGROUND");
	tex:SetAllPoints();
	tex:SetColorTexture(0, 0, 0);

	local backDrop = CreateFrame("Frame", nil, messageFrame, BackdropTemplateMixin and "BackdropTemplate");
	backDrop:SetPoint("TOPLEFT", -5, 6);
	backDrop:SetPoint("BOTTOMRIGHT", 2, -6);

	backDrop:SetBackdrop(
		{
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets =
			{
				left = 4,
				right = 4,
				top = 4,
				bottom = 4
			}
		});
	backDrop:SetBackdropColor(0,0,0,0);

	--Scroll bar
	local scrollBar = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate");
	scrollBar:SetPoint("RIGHT", frame, "RIGHT", 4, 11);
	scrollBar:SetSize(30, frame.height - 85);
	scrollBar:SetMinMaxValues(0, 0);
	scrollBar:SetValueStep(1);
	scrollBar:SetObeyStepOnDrag(true);
	scrollBar.scrollStep = 1;
	frame.scrollBar = scrollBar;

	scrollBar:SetScript("OnValueChanged", 
		function(self, value)
			messageFrame:SetScrollOffset(select(2, scrollBar:GetMinMaxValues()) - value);
		end
	);

	scrollBar:SetValue(0);

	frame:SetScript("OnMouseWheel", 
		function(self, delta)
			local cur_val = scrollBar:GetValue();
			local min_val, max_val = scrollBar:GetMinMaxValues();

			if delta < 0 and cur_val < max_val then
				cur_val = min(max_val, cur_val + 1);
				scrollBar:SetValue(cur_val);
			elseif delta > 0 and cur_val > min_val then
				cur_val = max(min_val, cur_val - 1);
				scrollBar:SetValue(cur_val);
			end
		end
	);
end

--Check button factory.
function functions.checkButtonFactory(name, parent, x_loc, y_loc, displayname, tooltip)
	local checkbutton = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate");
	checkbutton:SetPoint("TOPLEFT", x_loc, y_loc);
	_G[checkbutton:GetName().."Text"]:SetText(displayname);
	checkbutton.tooltip = tooltip;
end

--Function for creating the roll setting frames.
function functions.editBoxFactory(frame, frameEditbox, parent, x, y, title, linkedFrame, numeric, maxLetter, width, height)
	frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", x, y);
	frame:SetSize(100, 200);

	--Create and set title of the setting.
	frame.title = frame:CreateFontString(nil,"OVERLAY");
	frame.title:SetFontObject("GameFontHighLight");
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 5);
	frame.title:SetText(title);

	--Create the editbox for the setting.
	frame.editBox = frameEditbox;
	frame.editBox:SetPoint("CENTER", frame, "CENTER", 0, -15);
	frame.editBox:SetSize(width or 40, height or 40);
	frame.editBox:SetAutoFocus(false);
	frame.editBox:SetNumeric(numeric or false);
	frame.editBox:SetMaxLetters(maxLetter or 4);
	frame.editBox:SetFontObject("GameFontHighLight");

	frame.editBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus();
	end);

	if linkedFrame then
		frame.editBox:SetScript("OnKeyDown", 
			function (self, key)
				if key == "TAB" then
					linkedFrame.editBox:SetFocus();
				end
			end
		);
	end
end

--Function for creating the sliders.
function functions.sliderFactory(frame, frameSlider, x, y, title)
	frameSlider.tooltipText = "Sets scale (1 is default).";
	frameSlider:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", x, y);
	frameSlider:SetMinMaxValues(0.5, 2);
	frameSlider:SetWidth(120);
	frameSlider:SetOrientation("HORIZONTAL");
	frameSlider.stepValue = 0.1;
	frameSlider:SetValueStep(frameSlider.stepValue);
	
	_G[frameSlider:GetName().."Low"]:SetText("0.5");
	_G[frameSlider:GetName().."High"]:SetText("2");
	
	frameSlider.title = frameSlider:CreateFontString(nil, "OVERLAY");
	frameSlider.title:SetFontObject("GameFontHighLight");
	frameSlider.title:SetPoint("CENTER", frameSlider, "CENTER", 0, 30);
	frameSlider.title:SetText(title);
end