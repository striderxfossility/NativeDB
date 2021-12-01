
public class characterCreationSummaryMenu extends BaseCharacterCreationController {

  public edit let m_backstoryTitle: inkTextRef;

  public edit let m_backstoryIcon: inkImageRef;

  public edit let m_backstory: inkTextRef;

  public edit let m_attributeBodyValue: inkTextRef;

  public edit let m_attributeIntelligenceValue: inkTextRef;

  public edit let m_attributeReflexesValue: inkTextRef;

  public edit let m_attributeTechnicalAbilityValue: inkTextRef;

  public edit let m_attributeCoolValue: inkTextRef;

  public edit let m_previousPageBtn: inkWidgetRef;

  public edit let m_glitchBtn: inkWidgetRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_loadingAnimationProxy: ref<inkAnimProxy>;

  private let m_loadingFinished: Bool;

  private let m_glitchClicks: Int32;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.SetUpLifePath();
    this.SetUpAttribiutes();
    inkWidgetRef.RegisterToCallback(this.m_previousPageBtn, n"OnRelease", this, n"OnPreviousButton");
    inkWidgetRef.RegisterToCallback(this.m_glitchBtn, n"OnRelease", this, n"OnGlitchButton");
    this.m_glitchClicks = 0;
    this.m_loadingFinished = false;
    this.OnIntro();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected cb func OnPreviousButton(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Stop(n"ui_main_menu_cc_confirmation_screen_open");
      this.PriorMenu();
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected cb func OnGlitchButton(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_glitchClicks += 1;
      if this.m_glitchClicks > 2 {
        this.m_glitchClicks = 0;
        GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_hacking_access_denied");
        this.PlayAnim(n"malfunction", this.m_loadingAnimationProxy);
      };
    };
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsHandled() {
      if evt.IsAction(n"one_click_confirm") && this.m_loadingFinished {
        this.PlaySound(n"Button", n"OnPress");
        evt.Handle();
        this.NextMenu();
      };
      if evt.IsAction(n"back") {
        this.PlaySound(n"Button", n"OnPress");
        evt.Handle();
        this.PriorMenu();
      } else {
        return false;
      };
      evt.Handle();
    };
  }

  public final func SetUpLifePath() -> Void {
    if this.m_characterCustomizationState.GetLifePath() == t"LifePaths.Nomad" {
      inkTextRef.SetText(this.m_backstory, "LocKey#1586");
      inkTextRef.SetText(this.m_backstoryTitle, "LocKey#1799");
      inkImageRef.SetTexturePart(this.m_backstoryIcon, n"LifepathNomad");
    } else {
      if this.m_characterCustomizationState.GetLifePath() == t"LifePaths.StreetKid" {
        inkTextRef.SetText(this.m_backstory, "LocKey#1587");
        inkTextRef.SetText(this.m_backstoryTitle, "LocKey#1801");
        inkImageRef.SetTexturePart(this.m_backstoryIcon, n"LifepathStreetKid");
      } else {
        if this.m_characterCustomizationState.GetLifePath() == t"LifePaths.Corporate" {
          inkTextRef.SetText(this.m_backstory, "LocKey#1585");
          inkTextRef.SetText(this.m_backstoryTitle, "LocKey#1800");
          inkImageRef.SetTexturePart(this.m_backstoryIcon, n"LifepathCorpo");
        };
      };
    };
  }

  public final func SetUpAttribiutes() -> Void {
    let attributeType: gamedataStatType = gamedataStatType.Strength;
    inkTextRef.SetText(this.m_attributeBodyValue, ToString(this.m_characterCustomizationState.GetAttribute(attributeType)));
    attributeType = gamedataStatType.Intelligence;
    inkTextRef.SetText(this.m_attributeIntelligenceValue, ToString(this.m_characterCustomizationState.GetAttribute(attributeType)));
    attributeType = gamedataStatType.Reflexes;
    inkTextRef.SetText(this.m_attributeReflexesValue, ToString(this.m_characterCustomizationState.GetAttribute(attributeType)));
    attributeType = gamedataStatType.TechnicalAbility;
    inkTextRef.SetText(this.m_attributeTechnicalAbilityValue, ToString(this.m_characterCustomizationState.GetAttribute(attributeType)));
    attributeType = gamedataStatType.Cool;
    inkTextRef.SetText(this.m_attributeCoolValue, ToString(this.m_characterCustomizationState.GetAttribute(attributeType)));
  }

  protected func PriorMenu() -> Void {
    this.PriorMenu();
  }

  protected func NextMenu() -> Void {
    if !this.WaitForRunningInstalations() {
      this.PlaySound(n"CharacterCreationConfirmation", n"OnPress");
      this.OnOutro();
    };
  }

  private final func OnIntro() -> Void {
    this.PlayAnim(n"intro", n"OnLoadingComplete", this.m_loadingAnimationProxy);
    this.PlayAnim(n"intro_sound", n"OnIntroComplete", this.m_animationProxy);
  }

  private final func OnOutro() -> Void {
    this.PlayAnim(n"outro", n"OnOutroComplete", this.m_animationProxy);
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_main_menu_cc_confirmation_screen_close");
  }

  protected cb func OnOutroComplete(anim: ref<inkAnimProxy>) -> Bool {
    let system: ref<gameuiICharacterCustomizationSystem> = this.GetCharacterCustomizationSystem();
    system.FinalizeState();
    this.GetSystemRequestsHandler().StartNewGame(this.m_characterCustomizationState);
    this.GetTelemetrySystem().LogInitialChoiceSetStatege(telemetryInitalChoiceStage.Finished);
    this.GetTelemetrySystem().LogNewGameStarted();
    this.NextMenu();
  }

  protected cb func OnIntroComplete(anim: ref<inkAnimProxy>) -> Bool {
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_main_menu_cc_confirmation_screen_open");
  }

  protected cb func OnLoadingComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_loadingFinished = true;
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
}
