
public class characterCreationBodyMorphMenu extends BaseCharacterCreationController {

  @default(characterCreationBodyMorphMenu, UI_Hairs)
  public edit let m_defaultPreviewSlot: CName;

  public edit let m_optionsList: inkCompoundRef;

  public edit let m_colorPicker: inkWidgetRef;

  public edit let m_colorPickerBG: inkWidgetRef;

  public edit let m_colorPickerClose: inkWidgetRef;

  public edit let m_scrollArea: inkScrollAreaRef;

  public edit let m_optionList: wref<inkCompoundWidget>;

  public edit let m_previousPageBtn: inkWidgetRef;

  public edit let m_previousPageBtnBg: inkImageRef;

  public edit let m_nextPageBtnBg: inkImageRef;

  public edit let m_backConfirmation: inkWidgetRef;

  public edit let m_backConfirmationWidget: inkWidgetRef;

  public edit let m_ConfirmationConfirmBtn: inkWidgetRef;

  public edit let m_ConfirmationCloseBtn: inkWidgetRef;

  public edit let m_preset1: inkWidgetRef;

  public edit let m_preset2: inkWidgetRef;

  public edit let m_preset3: inkWidgetRef;

  public edit let m_randomize: inkWidgetRef;

  public edit let m_preset1Thumbnail: inkImageRef;

  public edit let m_preset2Thumbnail: inkImageRef;

  public edit let m_preset3Thumbnail: inkImageRef;

  public edit let m_randomizThumbnail: inkImageRef;

  public edit let m_preset1Bg: inkImageRef;

  public edit let m_preset2Bg: inkImageRef;

  public edit let m_preset3Bg: inkImageRef;

  public edit let m_randomizBg: inkImageRef;

  public edit let m_navigationButtons: inkWidgetRef;

  @default(characterCreationBodyMorphMenu, false)
  public let m_hideColorPickerNextFrame: Bool;

  public let m_colorPickerOwner: wref<inkWidget>;

  public let m_animationProxy: ref<inkAnimProxy>;

  public let m_confirmAnimationProxy: ref<inkAnimProxy>;

  public let m_optionListAnimationProxy: ref<inkAnimProxy>;

  @default(characterCreationBodyMorphMenu, false)
  public let m_optionsListInitialized: Bool;

  @default(characterCreationBodyMorphMenu, false)
  public let m_introPlayed: Bool;

  public let m_menuListController: wref<ListController>;

  public let m_cachedCursor: wref<inkWidget>;

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let morphMenuUserData: ref<MorphMenuUserData> = userData as MorphMenuUserData;
    this.m_optionsListInitialized = IsDefined(morphMenuUserData) && morphMenuUserData.m_optionsListInitialized;
  }

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    inkWidgetRef.RegisterToCallback(this.m_preset1, n"OnRelease", this, n"OnPreset1");
    inkWidgetRef.RegisterToCallback(this.m_preset2, n"OnRelease", this, n"OnPreset2");
    inkWidgetRef.RegisterToCallback(this.m_preset3, n"OnRelease", this, n"OnPreset3");
    inkWidgetRef.RegisterToCallback(this.m_randomize, n"OnRelease", this, n"OnRandomize");
    inkWidgetRef.RegisterToCallback(this.m_preset1, n"OnHoverOver", this, n"OnHoverOverPreset1");
    inkWidgetRef.RegisterToCallback(this.m_preset1, n"OnHoverOut", this, n"OnHoverOutPreset1");
    inkWidgetRef.RegisterToCallback(this.m_preset2, n"OnHoverOver", this, n"OnHoverOverPreset2");
    inkWidgetRef.RegisterToCallback(this.m_preset2, n"OnHoverOut", this, n"OnHoverOutPreset2");
    inkWidgetRef.RegisterToCallback(this.m_preset3, n"OnHoverOver", this, n"OnHoverOverPreset3");
    inkWidgetRef.RegisterToCallback(this.m_preset3, n"OnHoverOut", this, n"OnHoverOutPreset3");
    inkWidgetRef.RegisterToCallback(this.m_randomize, n"OnHoverOver", this, n"OnHoverOverRandomize");
    inkWidgetRef.RegisterToCallback(this.m_randomize, n"OnHoverOut", this, n"OnHoverOutRandomize");
    inkWidgetRef.RegisterToCallback(this.m_colorPickerClose, n"OnRelease", this, n"OnColorPickerClose");
    inkWidgetRef.RegisterToCallback(this.m_previousPageBtn, n"OnRelease", this, n"OnPrevious");
    this.m_optionList.RegisterToCallback(n"OnRelease", this, n"OnListRelease");
    inkWidgetRef.RegisterToCallback(this.m_previousPageBtn, n"OnHoverOver", this, n"OnHoverOverPreviousPageBtn");
    inkWidgetRef.RegisterToCallback(this.m_previousPageBtn, n"OnHoverOut", this, n"OnHoverOutPreviousPageBtn");
    inkWidgetRef.RegisterToCallback(this.m_nextPageHitArea, n"OnHoverOver", this, n"OnHoverOverNextPageBtn");
    inkWidgetRef.RegisterToCallback(this.m_nextPageHitArea, n"OnHoverOut", this, n"OnHoverOutNextPageBtn");
    inkWidgetRef.RegisterToCallback(this.m_ConfirmationConfirmBtn, n"OnRelease", this, n"OnConfirmationConfirm");
    inkWidgetRef.RegisterToCallback(this.m_ConfirmationCloseBtn, n"OnRelease", this, n"OnConfirmationClose");
    inkWidgetRef.SetVisible(this.m_colorPicker, false);
    inkWidgetRef.SetVisible(this.m_colorPickerBG, false);
    inkWidgetRef.RegisterToCallback(this.m_colorPicker, n"OnHoverOver", this, n"OnHoverOverColorPicker");
    inkWidgetRef.RegisterToCallback(this.m_colorPicker, n"OnColorSelected", this, n"OnColorSelected");
    this.GetTelemetrySystem().LogInitialChoiceSetStatege(telemetryInitalChoiceStage.Customizations);
    if this.m_optionsListInitialized {
      this.InitializeList();
      this.OnIntro();
    };
    this.m_menuListController = inkWidgetRef.GetController(this.m_optionsList) as ListController;
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    inkWidgetRef.UnregisterFromCallback(this.m_preset1, n"OnRelease", this, n"OnPreset1");
    inkWidgetRef.UnregisterFromCallback(this.m_preset2, n"OnRelease", this, n"OnPreset2");
    inkWidgetRef.UnregisterFromCallback(this.m_preset3, n"OnRelease", this, n"OnPreset3");
    inkWidgetRef.UnregisterFromCallback(this.m_randomize, n"OnRelease", this, n"OnRandomize");
    inkWidgetRef.UnregisterFromCallback(this.m_preset1, n"OnHoverOver", this, n"OnHoverOverPreset1");
    inkWidgetRef.UnregisterFromCallback(this.m_preset1, n"OnHoverOut", this, n"OnHoverOutPreset1");
    inkWidgetRef.UnregisterFromCallback(this.m_preset2, n"OnHoverOver", this, n"OnHoverOverPreset2");
    inkWidgetRef.UnregisterFromCallback(this.m_preset2, n"OnHoverOut", this, n"OnHoverOutPreset2");
    inkWidgetRef.UnregisterFromCallback(this.m_preset3, n"OnHoverOver", this, n"OnHoverOverPreset3");
    inkWidgetRef.UnregisterFromCallback(this.m_preset3, n"OnHoverOut", this, n"OnHoverOutPreset3");
    inkWidgetRef.UnregisterFromCallback(this.m_randomize, n"OnHoverOver", this, n"OnHoverOverRandomize");
    inkWidgetRef.UnregisterFromCallback(this.m_randomize, n"OnHoverOut", this, n"OnHoverOutRandomize");
    this.m_optionList.UnregisterFromCallback(n"OnRelease", this, n"OnListRelease");
    inkWidgetRef.UnregisterFromCallback(this.m_colorPickerClose, n"OnRelease", this, n"OnColorPickerClose");
    inkWidgetRef.UnregisterFromCallback(this.m_previousPageBtn, n"OnRelease", this, n"OnPrevious");
    inkWidgetRef.UnregisterFromCallback(this.m_previousPageBtn, n"OnHoverOver", this, n"OnHoverOverPreviousPageBtn");
    inkWidgetRef.UnregisterFromCallback(this.m_previousPageBtn, n"OnHoverOut", this, n"OnHoverOutPreviousPageBtn");
    inkWidgetRef.UnregisterFromCallback(this.m_ConfirmationConfirmBtn, n"OnRelease", this, n"OnConfirmationConfirm");
    inkWidgetRef.UnregisterFromCallback(this.m_ConfirmationCloseBtn, n"OnRelease", this, n"OnConfirmationClose");
    inkWidgetRef.UnregisterFromCallback(this.m_colorPicker, n"OnHoverOver", this, n"OnHoverOverColorPicker");
    inkWidgetRef.UnregisterFromCallback(this.m_colorPicker, n"OnColorSelected", this, n"OnColorSelected");
    this.OnOutro();
  }

  protected cb func OnInitializeOptionsList(evt: ref<gameuiCharacterCustomizationSystem_OnInitializeOptionsListEvent>) -> Bool {
    if this.m_characterCustomizationState.GetLifePath() == t"LifePaths.Nomad" {
      this.ApplyUIPreset(n"nomad", true);
    } else {
      if this.m_characterCustomizationState.GetLifePath() == t"LifePaths.StreetKid" {
        this.ApplyUIPreset(n"street", true);
      } else {
        if this.m_characterCustomizationState.GetLifePath() == t"LifePaths.Corporate" {
          this.ApplyUIPreset(n"corpo", true);
        };
      };
    };
  }

  protected cb func OnReInitializeOptionsList(evt: ref<gameuiCharacterCustomizationSystem_OnPresetAppliedEvent>) -> Bool {
    if !this.m_introPlayed {
      this.InitializeList();
      this.OnIntro();
      this.m_introPlayed = true;
    } else {
      this.RefreshList();
    };
  }

  public final func RefreshList() -> Void {
    let i: Int32;
    let j: Int32;
    let option: ref<CharacterCustomizationOption>;
    let options: array<ref<CharacterCustomizationOption>>;
    let system: ref<gameuiICharacterCustomizationSystem>;
    this.RequestCameraChange(this.m_defaultPreviewSlot);
    system = this.GetCharacterCustomizationSystem();
    options = system.GetUnitedOptions(true, true, true);
    this.UpdateVoiceOverWidget();
    i = this.UpdateVoiceOverWidget() ? 1 : 0;
    j = 0;
    while j < ArraySize(options) {
      option = options[j];
      if !option.info.hidden && option.isActive && !option.isCensored {
        this.UpdateOption(i, option, option);
        i = i + 1;
      };
      j += 1;
    };
  }

  public final func UpdateVoiceOverWidget() -> Bool {
    let switcherController: wref<characterCreationVoiceOverSwitcher> = inkCompoundRef.GetWidgetByIndex(this.m_optionsList, 0).GetController() as characterCreationVoiceOverSwitcher;
    if IsDefined(switcherController) {
      switcherController.SetIsBrainGenderMale(this.m_characterCustomizationState.IsBrainGenderMale());
      return true;
    };
    return false;
  }

  protected cb func OnRandomizeComplete(evt: ref<gameuiCharacterCustomizationSystem_OnRandomizeCompleteEvent>) -> Bool {
    this.RequestCameraChange(this.m_defaultPreviewSlot);
  }

  protected cb func OnAppearanceSwitched(evt: ref<gameuiCharacterCustomizationSystem_OnAppearanceSwitchedEvent>) -> Bool {
    let i: Int32;
    let pair: gameuiSwitchPair;
    let j: Int32 = 0;
    while j < ArraySize(evt.pairs) {
      pair = evt.pairs[j];
      if IsDefined(pair.prevOption) {
        i = 0;
        while i < inkCompoundRef.GetNumChildren(this.m_optionsList) {
          if this.UpdateOption(i, pair.prevOption, pair.currOption) {
          } else {
            i += 1;
          };
        };
      } else {
        if IsDefined(pair.currOption) {
          i = 0;
          while i < inkCompoundRef.GetNumChildren(this.m_optionsList) {
            if this.UpdateOption(i, pair.currOption, pair.currOption) {
            } else {
              i += 1;
            };
          };
        };
      };
      j += 1;
    };
  }

  protected cb func OnOptionUpdated(evt: ref<gameuiCharacterCustomizationSystem_OnOptionUpdatedEvent>) -> Bool {
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_optionsList) {
      if this.UpdateOption(i, evt.option, evt.option) {
      } else {
        i += 1;
      };
    };
  }

  public final func UpdateOption(i: Int32, const lookupOption: wref<CharacterCustomizationOption>, const newOption: wref<CharacterCustomizationOption>) -> Bool {
    let colorOptionController: ref<characterCreationBodyMorphColorOption>;
    let option: wref<CharacterCustomizationOption>;
    let optionController: ref<characterCreationBodyMorphOption> = inkCompoundRef.GetWidgetByIndex(this.m_optionsList, i).GetController() as characterCreationBodyMorphOption;
    if IsDefined(optionController) {
      option = optionController.GetSelectorOption();
      if Equals(lookupOption.info.uiSlot, option.info.uiSlot) {
        if IsDefined(newOption) && newOption.isActive && !newOption.isCensored {
          optionController.SetOption(newOption);
        } else {
          optionController.ResetOption();
        };
        return true;
      };
    };
    colorOptionController = inkCompoundRef.GetWidgetByIndex(this.m_optionsList, i).GetController() as characterCreationBodyMorphColorOption;
    if IsDefined(colorOptionController) {
      option = colorOptionController.GetColorPickerOption();
      if Equals(lookupOption.info.uiSlot, option.info.uiSlot) {
        if IsDefined(newOption) && newOption.isActive && !newOption.isCensored {
          colorOptionController.SetOption(newOption);
        } else {
          colorOptionController.ResetOption();
        };
        return true;
      };
    };
    return false;
  }

  protected cb func OnNextFrame(evt: ref<NextFrameEvent>) -> Bool {
    if this.m_hideColorPickerNextFrame {
      this.HideColorPicker(-1);
    };
  }

  protected cb func OnSliderChange(widget: wref<inkWidget>) -> Bool {
    let optionController: wref<characterCreationBodyMorphOption> = widget.GetController() as characterCreationBodyMorphOption;
    let option: ref<CharacterCustomizationOption> = optionController.GetSelectorOption();
    let index: Uint32 = optionController.GetSelectorIndex();
    if option.currIndex != index {
      this.GetCharacterCustomizationSystem().ApplyChangeToOption(option, index);
      this.RequestCameraChange(this.GetSlotName(option));
      this.GetTelemetrySystem().LogInitialChoiceOptionSelected(option, index);
    };
  }

  protected cb func OnColorPickerTriggered(widget: wref<inkWidget>) -> Bool {
    let appearanceInfo: ref<gameuiAppearanceInfo>;
    let colorOptionController: wref<characterCreationBodyMorphColorOption>;
    let pickerController: wref<characterCreationBodyMorphOptionColorPicker>;
    this.HideColorPicker(-1);
    colorOptionController = widget.GetController() as characterCreationBodyMorphColorOption;
    if colorOptionController.IsColorPickerTriggered() {
      this.m_colorPickerOwner = widget;
      this.m_colorPickerOwner.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverColorPickerOwner");
      pickerController = inkWidgetRef.GetController(this.m_colorPicker) as characterCreationBodyMorphOptionColorPicker;
      pickerController.FillGrid(colorOptionController.GetColorPickerOption());
      appearanceInfo = colorOptionController.GetColorPickerOption().info as gameuiAppearanceInfo;
      pickerController.SetTitle(appearanceInfo.localizedName);
      inkWidgetRef.SetVisible(this.m_colorPicker, true);
      inkWidgetRef.SetVisible(this.m_colorPickerBG, true);
      this.m_animationProxy = inkWidgetRef.GetController(this.m_colorPickerBG).PlayLibraryAnimation(n"color_picker_panel_intro");
      this.m_confirmAnimationProxy = this.PlayLibraryAnimation(n"color_picker_bg_intro");
      this.m_optionListAnimationProxy = this.PlayLibraryAnimation(n"option_list_hide");
      this.PlaySound(n"CharacterCreationConfirmationAnimation", n"OnClose");
      this.m_cachedCursor = widget;
      this.RequestCameraChange(this.GetSlotName(colorOptionController.GetColorPickerOption()));
    };
  }

  protected cb func OnPreset1(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.ApplyUIPreset(n"nomad");
    };
  }

  protected cb func OnPreset2(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.ApplyUIPreset(n"street");
    };
  }

  protected cb func OnPreset3(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.ApplyUIPreset(n"corpo");
    };
  }

  protected cb func OnRandomize(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GetCharacterCustomizationSystem().RandomizeOptions();
      this.GetTelemetrySystem().LogInitialChoicePresetSelected(n"random");
    };
  }

  protected cb func OnHoverOverPreset1(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_preset1Bg, n"preset_active");
  }

  protected cb func OnHoverOverPreset2(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_preset2Bg, n"preset_active");
  }

  protected cb func OnHoverOverPreset3(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_preset3Bg, n"preset_active");
  }

  protected cb func OnHoverOverRandomize(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_randomizBg, n"preset_active");
    inkWidgetRef.SetState(this.m_randomizThumbnail, n"Hover");
  }

  protected cb func OnHoverOutPreset1(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_preset1Bg, n"preset_idle");
  }

  protected cb func OnHoverOutPreset2(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_preset2Bg, n"preset_idle");
  }

  protected cb func OnHoverOutPreset3(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_preset3Bg, n"preset_idle");
  }

  protected cb func OnHoverOutRandomize(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_randomizBg, n"preset_idle");
    inkWidgetRef.SetState(this.m_randomizThumbnail, n"DEfault");
  }

  protected cb func OnColorPickerClose(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_hideColorPickerNextFrame = true;
      this.QueueEvent(new NextFrameEvent());
    };
  }

  protected cb func OnConfirmationClose(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.HideConfirmation();
    };
  }

  protected cb func OnConfirmationConfirm(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.PriorMenu();
    };
  }

  protected cb func OnPrevious(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      if !inkWidgetRef.IsVisible(this.m_backConfirmation) {
        this.ShowConfirmation();
      } else {
        this.PriorMenu();
      };
    };
  }

  protected cb func OnListRelease(e: ref<inkPointerEvent>) -> Bool {
    if e.IsHandled() {
      return false;
    };
    this.m_menuListController.HandleInput(e, this);
  }

  protected cb func OnHoverOutPreviousPageBtn(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_previousPageBtnBg, n"button_prev_idle");
  }

  protected cb func OnHoverOverPreviousPageBtn(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_previousPageBtnBg, n"button_prev_active");
  }

  protected cb func OnHoverOutNextPageBtn(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_nextPageBtnBg, n"button_next_idle");
  }

  protected cb func OnHoverOverNextPageBtn(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetTexturePart(this.m_nextPageBtnBg, n"button_next_active");
  }

  protected cb func OnHoverOverColorPickerOwner(e: ref<inkPointerEvent>) -> Bool {
    if e.GetTarget() == this.m_colorPickerOwner {
      this.m_hideColorPickerNextFrame = false;
    };
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsHandled() {
      if evt.IsAction(n"back") && !inkWidgetRef.IsVisible(this.m_colorPicker) && !inkWidgetRef.IsVisible(this.m_backConfirmation) {
        this.ShowConfirmation();
      } else {
        if evt.IsAction(n"back") && inkWidgetRef.IsVisible(this.m_backConfirmation) {
          this.PlaySound(n"Button", n"OnPress");
          this.HideConfirmation();
        } else {
          if evt.IsAction(n"back") && inkWidgetRef.IsVisible(this.m_colorPicker) {
            this.m_hideColorPickerNextFrame = true;
            this.QueueEvent(new NextFrameEvent());
          } else {
            if evt.IsAction(n"one_click_confirm") && inkWidgetRef.IsVisible(this.m_backConfirmation) {
              this.PlaySound(n"Button", n"OnPress");
              evt.Handle();
              this.PriorMenu();
            } else {
              if evt.IsAction(n"one_click_confirm") && !inkWidgetRef.IsVisible(this.m_colorPicker) {
                this.PlaySound(n"Button", n"OnPress");
                evt.Handle();
                this.NextMenu();
              } else {
                return false;
              };
            };
          };
        };
      };
      evt.Handle();
    };
  }

  protected cb func OnHoverOverColorPicker(e: ref<inkPointerEvent>) -> Bool {
    if e.GetTarget() == inkWidgetRef.Get(this.m_colorPicker) {
      this.m_hideColorPickerNextFrame = false;
    };
  }

  protected cb func OnColorSelected(widget: wref<inkWidget>) -> Bool {
    let colorOptionController: wref<characterCreationBodyMorphColorOption>;
    let pickerController: wref<characterCreationBodyMorphOptionColorPicker> = inkWidgetRef.GetController(this.m_colorPicker) as characterCreationBodyMorphOptionColorPicker;
    let option: ref<CharacterCustomizationOption> = pickerController.GetOption();
    let index: Uint32 = Cast(pickerController.GetSelectedIndex());
    if option.currIndex != index {
      this.GetCharacterCustomizationSystem().ApplyChangeToOption(option, index);
      this.RequestCameraChange(this.GetSlotName(option));
      this.GetTelemetrySystem().LogInitialChoiceOptionSelected(option, index);
    };
    colorOptionController = this.m_colorPickerOwner.GetController() as characterCreationBodyMorphColorOption;
    colorOptionController.RefreshColorPicker(Cast(index), false);
  }

  protected cb func OnColorChange(widget: wref<inkWidget>) -> Bool {
    let optionController: wref<characterCreationBodyMorphColorOption> = widget.GetController() as characterCreationBodyMorphColorOption;
    let option: ref<CharacterCustomizationOption> = optionController.GetColorPickerOption();
    let index: Uint32 = optionController.GetColorIndex();
    if option.currIndex != index {
      this.GetCharacterCustomizationSystem().ApplyChangeToOption(option, index);
      this.RequestCameraChange(this.GetSlotName(option));
      this.GetTelemetrySystem().LogInitialChoiceOptionSelected(option, index);
    };
  }

  protected cb func OnVoiceOverSwitched(widget: wref<inkWidget>) -> Bool {
    let switcherController: wref<characterCreationVoiceOverSwitcher> = widget.GetController() as characterCreationVoiceOverSwitcher;
    let isMale: Bool = switcherController.IsBrainGenderMale();
    if NotEquals(isMale, this.m_characterCustomizationState.IsBrainGenderMale()) {
      this.m_characterCustomizationState.SetIsBrainGenderMale(isMale);
      this.GetCharacterCustomizationSystem().TriggerVoiceToneSample();
      this.GetTelemetrySystem().LogInitialChoiceBrainGenderSelected(isMale);
    };
  }

  protected cb func OnHoverOverOption(e: ref<inkPointerEvent>) -> Bool {
    let colorOptionController: wref<characterCreationBodyMorphColorOption>;
    let optionController: wref<characterCreationBodyMorphOption>;
    let voiceOverSwitcher: wref<characterCreationVoiceOverSwitcher>;
    if !IsDefined(this.m_colorPickerOwner) {
      voiceOverSwitcher = e.GetTarget().GetController() as characterCreationVoiceOverSwitcher;
      if IsDefined(voiceOverSwitcher) {
        this.RequestCameraChange(n"UI_Hairs", true);
      };
      optionController = e.GetTarget().GetController() as characterCreationBodyMorphOption;
      if IsDefined(optionController) {
        this.RequestCameraChange(this.GetSlotName(optionController.GetSelectorOption()), true);
      };
      colorOptionController = e.GetTarget().GetController() as characterCreationBodyMorphColorOption;
      if IsDefined(colorOptionController) {
        this.RequestCameraChange(this.GetSlotName(colorOptionController.GetColorPickerOption()), true);
      };
    };
  }

  public final func InitializeList() -> Void {
    let i: Int32;
    let option: ref<CharacterCustomizationOption>;
    let options: array<ref<CharacterCustomizationOption>>;
    let system: ref<gameuiICharacterCustomizationSystem>;
    if this.m_characterCustomizationState.IsBodyGenderMale() {
      inkImageRef.SetTexturePart(this.m_preset1Thumbnail, n"preset_nom_m");
      inkImageRef.SetTexturePart(this.m_preset2Thumbnail, n"preset_str_m");
      inkImageRef.SetTexturePart(this.m_preset3Thumbnail, n"preset_cor_m");
      inkImageRef.SetTexturePart(this.m_randomizThumbnail, n"preset_random_m");
    } else {
      inkImageRef.SetTexturePart(this.m_preset1Thumbnail, n"preset_nom_f");
      inkImageRef.SetTexturePart(this.m_preset2Thumbnail, n"preset_str_f");
      inkImageRef.SetTexturePart(this.m_preset3Thumbnail, n"preset_cor_f");
      inkImageRef.SetTexturePart(this.m_randomizThumbnail, n"preset_random_f");
    };
    this.RequestCameraChange(this.m_defaultPreviewSlot);
    system = this.GetCharacterCustomizationSystem();
    options = system.GetUnitedOptions(true, true, true);
    inkCompoundRef.RemoveAllChildren(this.m_optionsList);
    if system.IsTransgenderAllowed() {
      this.CreateVoiceOverSwitcher();
    };
    i = 0;
    while i < ArraySize(options) {
      option = options[i];
      if !option.info.hidden && option.isActive && !option.isCensored {
        this.CreateEntry(option);
      };
      i += 1;
    };
  }

  public final func CreateVoiceOverSwitcher() -> Void {
    let switcherWidget: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_optionsList), n"VoiceOverSwitcher");
    let switcherController: wref<characterCreationVoiceOverSwitcher> = switcherWidget.GetController() as characterCreationVoiceOverSwitcher;
    switcherController.RegisterToCallback(n"OnVoiceOverSwitched", this, n"OnVoiceOverSwitched");
    switcherWidget.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverOption");
    switcherController.SetIsBrainGenderMale(this.m_characterCustomizationState.IsBrainGenderMale());
  }

  public final func CreateEntry(const option: ref<CharacterCustomizationOption>) -> wref<inkWidget> {
    let colorOptionController: wref<characterCreationBodyMorphColorOption>;
    let optionController: wref<characterCreationBodyMorphOption>;
    let optionWidget: wref<inkWidget>;
    let appearanceInfo: wref<gameuiAppearanceInfo> = option.info as gameuiAppearanceInfo;
    if IsDefined(appearanceInfo) && appearanceInfo.useThumbnails {
      optionWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_optionsList), n"ColorPicker");
      colorOptionController = optionWidget.GetController() as characterCreationBodyMorphColorOption;
      colorOptionController.SetOption(option);
      colorOptionController.RegisterToCallback(n"OnColorPickerTriggered", this, n"OnColorPickerTriggered");
      optionWidget.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverOption");
      colorOptionController.RegisterToCallback(n"OnColorChange", this, n"OnColorChange");
    } else {
      optionWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_optionsList), n"Selector");
      optionController = optionWidget.GetController() as characterCreationBodyMorphOption;
      optionController.SetOption(option);
      optionController.RegisterToCallback(n"OnSliderChange", this, n"OnSliderChange");
      optionWidget.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOverOption");
    };
    return optionWidget;
  }

  public final func HideColorPicker(index: Int32) -> Void {
    let colorOptionController: wref<characterCreationBodyMorphColorOption>;
    if inkWidgetRef.IsVisible(this.m_colorPicker) {
      if IsDefined(this.m_colorPickerOwner) {
        colorOptionController = this.m_colorPickerOwner.GetController() as characterCreationBodyMorphColorOption;
        if IsDefined(colorOptionController) {
          colorOptionController.RefreshColorPicker(Cast(colorOptionController.GetColorIndex()), false);
        };
      };
      this.m_colorPickerOwner.UnregisterFromCallback(n"OnHoverOver", this, n"OnHoverOverColorPickerOwner");
      this.m_colorPickerOwner = null;
      this.m_optionList.SetVisible(true);
      this.m_optionListAnimationProxy = this.PlayLibraryAnimation(n"option_list_show");
      inkWidgetRef.SetVisible(this.m_colorPicker, false);
      inkWidgetRef.SetVisible(this.m_colorPickerBG, false);
      this.SetCursorOverWidget(this.m_cachedCursor);
      this.PlaySound(n"CharacterCreationConfirmationAnimation", n"OnClose");
    };
  }

  public final func ApplyUIPreset(presetName: CName, opt fromInit: Bool) -> Void {
    this.GetCharacterCustomizationSystem().ApplyUIPreset(presetName);
    this.GetTelemetrySystem().LogInitialChoicePresetSelected(presetName, fromInit);
  }

  public final func OnIntro() -> Void {
    this.PlayAnim(n"intro", n"OnIntroComplete", this.m_animationProxy);
  }

  protected cb func OnIntroComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.SetCursorOverWidget(inkCompoundRef.GetWidgetByIndex(this.m_optionsList, 0));
  }

  public final func OnOutro() -> Void {
    this.PlayAnim(n"outro", this.m_animationProxy);
  }

  public final func ShowConfirmation() -> Void {
    this.PlaySound(n"SaveDeleteButton", n"OnPress");
    inkWidgetRef.SetVisible(this.m_backConfirmation, true);
    inkWidgetRef.SetVisible(this.m_navigationButtons, false);
    this.m_animationProxy = inkWidgetRef.GetController(this.m_backConfirmationWidget).PlayLibraryAnimation(n"confirmation_intro");
    this.m_confirmAnimationProxy = inkWidgetRef.GetController(this.m_backConfirmation).PlayLibraryAnimation(n"confirmation_popup_btns");
  }

  public final func HideConfirmation() -> Void {
    inkWidgetRef.SetVisible(this.m_backConfirmation, false);
    inkWidgetRef.SetVisible(this.m_navigationButtons, true);
  }

  protected func PriorMenu() -> Void {
    this.OnOutro();
    this.PriorMenu();
    this.PlaySound(n"Button", n"OnPress");
  }

  protected func NextMenu() -> Void {
    this.OnOutro();
    this.NextMenu();
  }

  public final func PlayAnim(animName: CName, opt callBack: CName, animProxy: ref<inkAnimProxy>) -> Void {
    if IsDefined(animProxy) && animProxy.IsPlaying() {
      animProxy.Stop();
    };
    animProxy = this.PlayLibraryAnimation(animName);
    if NotEquals(callBack, n"") {
      animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }

  public final func GetSlotName(option: ref<CharacterCustomizationOption>) -> CName {
    if Equals(option.bodyPart, gameuiCharacterCustomizationPart.Head) {
      if Equals(option.info.name, n"skin_color") || Equals(option.info.name, n"skin_type") || Equals(option.info.name, n"hairstyle") || Equals(option.info.uiSlot, n"hair_color") {
        return n"UI_Hairs";
      };
      if Equals(option.info.name, n"teeth") {
        return n"UI_Teeth";
      };
      return n"UI_HeadPreview";
    };
    if Equals(option.bodyPart, gameuiCharacterCustomizationPart.Arms) {
      return n"UI_FingerNails";
    };
    return n"UI_Preview";
  }
}
