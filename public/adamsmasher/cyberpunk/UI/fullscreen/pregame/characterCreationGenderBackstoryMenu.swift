
public class CharacterCreationBackstorySelectionMenu extends BaseCharacterCreationController {

  public edit let m_nomad: inkWidgetRef;

  public edit let m_streetRat: inkWidgetRef;

  public edit let m_corpo: inkWidgetRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_clickTarget: String;

  private let m_nomadTarget: String;

  private let m_streetTarget: String;

  private let m_corpoTarget: String;

  protected cb func OnInitialize() -> Bool {
    this.GetCharacterCustomizationSystem().InitializeState();
    super.OnInitialize();
    this.m_nomadTarget = "N";
    this.m_streetTarget = "S";
    this.m_corpoTarget = "C";
    this.SetupLifePathButtons();
    this.GetTelemetrySystem().LogInitialChoiceSetStatege(telemetryInitalChoiceStage.LifePath);
    this.OnIntro();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.OnOutro();
  }

  private final func SetupLifePathButtons() -> Void {
    this.SetupLifePathButton(inkWidgetRef.Get(this.m_nomad), n"LocKey#1586", n"lifepath_nomad", r"base\\movies\\misc\\character_creation\\nomad.bk2", n"LocKey#1799", n"OnPressNomad", n"OnReleaseNomad");
    this.SetupLifePathButton(inkWidgetRef.Get(this.m_streetRat), n"LocKey#1587", n"lifepath_street", r"base\\movies\\misc\\character_creation\\street_kid.bk2", n"LocKey#1801", n"OnPressStreet", n"OnReleaseStreet");
    this.SetupLifePathButton(inkWidgetRef.Get(this.m_corpo), n"LocKey#1585", n"lifepath_corpo", r"base\\movies\\misc\\character_creation\\corpo.bk2", n"LocKey#1800", n"OnPressCorpo", n"OnReleaseCorpo");
  }

  private final func SetupLifePathButton(widget: wref<inkWidget>, desc: CName, imagePath: CName, videoPath: ResRef, label: CName, onPressEvent: CName, onReleaseEvent: CName) -> Void {
    let logController: wref<characterCreationLifePathBtn>;
    if IsDefined(widget) {
      logController = widget.GetController() as characterCreationLifePathBtn;
      if IsDefined(logController) {
        logController.SetDescription(desc, imagePath, videoPath, label);
        logController.RegisterToCallback(n"OnPress", this, onPressEvent);
        logController.RegisterToCallback(n"OnRelease", this, onReleaseEvent);
      };
    };
  }

  protected cb func OnReleaseNomad(e: ref<inkPointerEvent>) -> Bool {
    let lifePath: TweakDBID;
    if e.IsAction(n"click") && Equals(this.m_clickTarget, this.m_nomadTarget) {
      GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_hacking_access_granted");
      lifePath = t"LifePaths.Nomad";
      this.m_characterCustomizationState.SetLifePath(lifePath);
      this.GetTelemetrySystem().LogInitialChoiceLifePathSelected(lifePath);
      this.m_eventDispatcher.SpawnEvent(n"OnAccept");
      this.m_clickTarget = "";
    };
  }

  protected cb func OnReleaseStreet(e: ref<inkPointerEvent>) -> Bool {
    let lifePath: TweakDBID;
    if e.IsAction(n"click") && Equals(this.m_clickTarget, this.m_streetTarget) {
      GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_hacking_access_granted");
      lifePath = t"LifePaths.StreetKid";
      this.m_characterCustomizationState.SetLifePath(lifePath);
      this.GetTelemetrySystem().LogInitialChoiceLifePathSelected(lifePath);
      this.m_eventDispatcher.SpawnEvent(n"OnAccept");
      this.m_clickTarget = "";
    };
  }

  protected cb func OnReleaseCorpo(e: ref<inkPointerEvent>) -> Bool {
    let lifePath: TweakDBID;
    if e.IsAction(n"click") && Equals(this.m_clickTarget, this.m_corpoTarget) {
      GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_hacking_access_granted");
      lifePath = t"LifePaths.Corporate";
      this.m_characterCustomizationState.SetLifePath(lifePath);
      this.GetTelemetrySystem().LogInitialChoiceLifePathSelected(lifePath);
      this.m_eventDispatcher.SpawnEvent(n"OnAccept");
      this.m_clickTarget = "";
    };
  }

  protected cb func OnPressNomad(e: ref<inkPointerEvent>) -> Bool {
    this.m_clickTarget = this.m_nomadTarget;
  }

  protected cb func OnPressStreet(e: ref<inkPointerEvent>) -> Bool {
    this.m_clickTarget = this.m_streetTarget;
  }

  protected cb func OnPressCorpo(e: ref<inkPointerEvent>) -> Bool {
    this.m_clickTarget = this.m_corpoTarget;
  }

  protected func PriorMenu() -> Void {
    this.GetCharacterCustomizationSystem().ClearState();
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_main_menu_loop_start");
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"mus_game_menus_01_main_menu");
    this.PriorMenu();
  }

  public final func PlayAnim(animName: CName, opt callBack: CName) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    if NotEquals(callBack, n"") {
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }

  private final func OnIntro() -> Void {
    this.PlayAnim(n"intro", n"OnIntroComplete");
  }

  private final func OnOutro() -> Void {
    this.PlayAnim(n"outro");
  }

  protected cb func OnIntroComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.PlaySound(n"CharacterCreationLoading", n"OnOpen");
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_main_menu_loop_stop");
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"mus_game_menus_02_character_creation");
  }
}

public class CharacterCreationGenderSelectionMenu extends BaseCharacterCreationController {

  public edit let m_streetRat_male: inkWidgetRef;

  public edit let m_streetRat_female: inkWidgetRef;

  private let m_clickTarget: inkWidgetRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_maleAnimProxy: ref<inkAnimProxy>;

  private let m_femaleAnimProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    inkWidgetRef.RegisterToCallback(this.m_streetRat_male, n"OnRelease", this, n"OnReleaseMale");
    inkWidgetRef.RegisterToCallback(this.m_streetRat_female, n"OnRelease", this, n"OnReleaseFemale");
    inkWidgetRef.RegisterToCallback(this.m_streetRat_male, n"OnPress", this, n"OnPressMale");
    inkWidgetRef.RegisterToCallback(this.m_streetRat_female, n"OnPress", this, n"OnPressFemale");
    inkWidgetRef.RegisterToCallback(this.m_streetRat_male, n"OnHoverOver", this, n"OnHoverOverMale");
    inkWidgetRef.RegisterToCallback(this.m_streetRat_female, n"OnHoverOver", this, n"OnHoverOverFemale");
    inkWidgetRef.RegisterToCallback(this.m_streetRat_male, n"OnHoverOut", this, n"OnHoverOutMale");
    inkWidgetRef.RegisterToCallback(this.m_streetRat_female, n"OnHoverOut", this, n"OnHoverOutFemale");
    this.SetAttributePreset(this.m_characterCustomizationState.GetLifePath());
    this.GetTelemetrySystem().LogInitialChoiceSetStatege(telemetryInitalChoiceStage.Gender);
    this.OnIntro();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    this.OnOutro();
  }

  protected cb func OnPuppetReadyToBeDisplayed(evt: ref<gameuiPuppetPreview_ReadyToBeDisplayed>) -> Bool {
    if evt.isMale {
      this.PlayLibraryAnimation(n"male_preview_intro");
    } else {
      this.PlayLibraryAnimation(n"female_preview_intro");
    };
  }

  protected cb func OnHoverOverMale(e: ref<inkPointerEvent>) -> Bool {
    this.PlayAnim(n"male_highlight_intro", this.m_maleAnimProxy);
  }

  protected cb func OnHoverOutMale(e: ref<inkPointerEvent>) -> Bool {
    this.PlayAnim(n"male_highlight_outro", this.m_maleAnimProxy);
  }

  protected cb func OnHoverOverFemale(e: ref<inkPointerEvent>) -> Bool {
    this.PlayAnim(n"female_highlight_intro", this.m_femaleAnimProxy);
  }

  protected cb func OnHoverOutFemale(e: ref<inkPointerEvent>) -> Bool {
    this.PlayAnim(n"female_highlight_outro", this.m_femaleAnimProxy);
  }

  protected cb func OnReleaseMale(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") && this.m_clickTarget == this.m_streetRat_male {
      this.PlaySound(n"Button", n"OnPress");
      this.m_characterCustomizationState.SetIsBodyGenderMale(true);
      this.m_characterCustomizationState.SetIsBrainGenderMale(true);
      this.GetTelemetrySystem().LogInitialChoiceBodyGenderSelected(true);
      this.m_eventDispatcher.SpawnEvent(n"OnAccept");
    };
  }

  protected cb func OnReleaseFemale(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") && this.m_clickTarget == this.m_streetRat_female {
      this.PlaySound(n"Button", n"OnPress");
      this.m_characterCustomizationState.SetIsBodyGenderMale(false);
      this.m_characterCustomizationState.SetIsBrainGenderMale(false);
      this.GetTelemetrySystem().LogInitialChoiceBodyGenderSelected(false);
      this.m_eventDispatcher.SpawnEvent(n"OnAccept");
    };
  }

  protected cb func OnPressMale(e: ref<inkPointerEvent>) -> Bool {
    this.m_clickTarget = this.m_streetRat_male;
  }

  protected cb func OnPressFemale(e: ref<inkPointerEvent>) -> Bool {
    this.m_clickTarget = this.m_streetRat_female;
  }

  public final func PlayAnim(animName: CName, opt animProxy: ref<inkAnimProxy>, opt callBack: CName) -> Void {
    let currentAnimProxy: ref<inkAnimProxy> = IsDefined(animProxy) ? animProxy : this.m_animationProxy;
    if currentAnimProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    currentAnimProxy = this.PlayLibraryAnimation(animName);
  }

  private final func SetAttributePreset(lifePath: TweakDBID) -> Void {
    let UIAttRecords: array<wref<UICharacterCreationAttribute_Record>>;
    let i: Int32;
    let preset: TweakDBID;
    this.m_characterCustomizationState.SetAttributePointsAvailable(7u);
    if lifePath == t"LifePaths.Nomad" {
      preset = t"UIAttributePresets.Preset1";
    } else {
      if lifePath == t"LifePaths.StreetKid" {
        preset = t"UIAttributePresets.Preset2";
      } else {
        if lifePath == t"LifePaths.Corporate" {
          preset = t"UIAttributePresets.Preset3";
        };
      };
    };
    TweakDBInterface.GetUICharacterCreationAttributesPresetRecord(preset).Attributes(UIAttRecords);
    i = 0;
    while i < ArraySize(UIAttRecords) {
      this.m_characterCustomizationState.SetAttribute(UIAttRecords[i].Attribute().StatType(), Cast(UIAttRecords[i].Value()));
      i += 1;
    };
  }

  private final func OnIntro() -> Void {
    this.PlayAnim(n"intro", this.m_animationProxy);
  }

  private final func OnOutro() -> Void {
    this.PlayAnim(n"outro", this.m_animationProxy);
  }
}

public class CharacterCreationGenderBackstoryPathHeader extends inkLogicController {

  public edit let m_label: inkTextRef;

  public edit let m_desc: inkTextRef;

  public edit let m_bg: inkWidgetRef;

  private let m_selectedColor: Color;

  private let m_unSelectedColor: Color;

  private let m_textSelectedColor: Color;

  private let m_textUnselectedColor: Color;

  protected cb func OnInitialize() -> Bool {
    this.m_unSelectedColor.Red = 39u;
    this.m_unSelectedColor.Green = 51u;
    this.m_unSelectedColor.Blue = 51u;
    this.m_selectedColor.Red = 160u;
    this.m_selectedColor.Green = 190u;
    this.m_selectedColor.Blue = 190u;
    this.m_textSelectedColor = this.m_unSelectedColor;
    this.m_textUnselectedColor = this.m_selectedColor;
  }

  public final func Select() -> Void {
    inkWidgetRef.SetTintColor(this.m_label, this.m_textSelectedColor);
    inkWidgetRef.SetTintColor(this.m_bg, this.m_selectedColor);
  }

  public final func UnSelect() -> Void {
    inkWidgetRef.SetTintColor(this.m_label, this.m_textUnselectedColor);
    inkWidgetRef.SetTintColor(this.m_bg, this.m_unSelectedColor);
  }

  public final func SetData(title: String, desc: String) -> Void {
    inkTextRef.SetText(this.m_label, title);
    inkTextRef.SetText(this.m_desc, desc);
  }
}
