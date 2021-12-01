
public class HDRSettingsVarListener extends ConfigVarListener {

  private let m_ctrl: wref<HDRSettingsGameController>;

  public final func RegisterController(ctrl: ref<HDRSettingsGameController>) -> Void {
    this.m_ctrl = ctrl;
  }

  public func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    Log("HDRSettingsVarListener::OnVarModified");
    this.m_ctrl.OnVarModified(groupPath, varName, varType, reason);
  }
}

public native class HDRSettingsGameController extends gameuiMenuGameController {

  private let s_maxBrightnessGroup: CName;

  private let s_paperWhiteGroup: CName;

  private let s_toneMappingeGroup: CName;

  private let s_calibrationImageDay: CName;

  private let s_calibrationImageNight: CName;

  private let s_currentCalibrationImage: CName;

  private edit let m_paperWhiteOptionSelector: inkCompoundRef;

  private edit let m_maxBrightnessOptionSelector: inkCompoundRef;

  private edit let m_toneMappingOptionSelector: inkCompoundRef;

  private edit let m_targetImageWidget: inkWidgetRef;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_settings: ref<UserSettings>;

  private let m_settingsListener: ref<HDRSettingsVarListener>;

  private let m_SettingsElements: array<wref<SettingsSelectorController>>;

  private let m_isPreGame: Bool;

  private let m_calibrationImagesCycleAnimDef: ref<inkAnimDef>;

  private let m_calibrationImagesCycleProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.s_maxBrightnessGroup = n"/video/display";
    this.s_paperWhiteGroup = n"/video/display";
    this.s_toneMappingeGroup = n"/video/display";
    this.s_calibrationImageDay = n"hdr_day";
    this.s_calibrationImageNight = n"hdr_night";
    this.m_settings = this.GetSystemRequestsHandler().GetUserSettings();
    this.m_isPreGame = this.GetSystemRequestsHandler().IsPreGame();
    this.m_settingsListener = new HDRSettingsVarListener();
    this.m_settingsListener.RegisterController(this);
    this.m_settingsListener.Register(this.s_paperWhiteGroup);
    this.m_settingsListener.Register(this.s_maxBrightnessGroup);
    this.m_settingsListener.Register(this.s_toneMappingeGroup);
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    ArrayClear(this.m_SettingsElements);
    this.SetOptionSelector(n"MaxMonitorBrightness");
    this.SetOptionSelector(n"PaperWhiteLevel");
    this.SetOptionSelector(n"TonemappingMidpoint");
    this.PrepareHDRCycleAnimations();
    this.s_currentCalibrationImage = this.s_calibrationImageNight;
    this.SetTexturePart(this.s_currentCalibrationImage);
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.SetHDRCalibrationScreen(false);
  }

  private final func SetOptionSelector(optionName: CName) -> Void {
    let option: ref<ConfigVar>;
    let selector: wref<SettingsSelectorController>;
    let selectorWidget: inkCompoundRef;
    if Equals(optionName, n"MaxMonitorBrightness") {
      selectorWidget = this.m_maxBrightnessOptionSelector;
    } else {
      if Equals(optionName, n"PaperWhiteLevel") {
        selectorWidget = this.m_paperWhiteOptionSelector;
      } else {
        selectorWidget = this.m_toneMappingOptionSelector;
      };
    };
    option = this.m_settings.GetVar(this.s_maxBrightnessGroup, optionName);
    if this.m_isPreGame ? option.IsInPreGame() : option.IsInGame() {
      selector = inkWidgetRef.Get(selectorWidget).GetController() as SettingsSelectorController;
      if IsDefined(selector) {
        selector.Setup(option, this.m_isPreGame);
        ArrayPush(this.m_SettingsElements, selector);
      };
    };
  }

  public final func OnVarModified(groupPath: CName, varName: CName, varType: ConfigVarType, reason: ConfigChangeReason) -> Void {
    let i: Int32;
    let item: ref<SettingsSelectorController>;
    let size: Int32;
    Log("[VAR] modified groupPath: " + NameToString(groupPath) + " varName: " + NameToString(varName));
    size = ArraySize(this.m_SettingsElements);
    i = 0;
    while i < size {
      item = this.m_SettingsElements[i];
      if Equals(item.GetGroupPath(), groupPath) && Equals(item.GetVarName(), varName) {
        this.m_SettingsElements[i].Refresh();
      };
      i += 1;
    };
  }

  private final func PrepareHDRCycleAnimations() -> Void {
    let options: inkAnimOptions;
    options.loopType = inkanimLoopType.Cycle;
    options.loopInfinite = true;
    this.m_calibrationImagesCycleAnimDef = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(0.00);
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(5.00);
    alphaInterpolator.SetStartDelay(0.25);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_calibrationImagesCycleAnimDef.AddInterpolator(alphaInterpolator);
    this.m_calibrationImagesCycleProxy = inkWidgetRef.PlayAnimationWithOptions(this.m_targetImageWidget, this.m_calibrationImagesCycleAnimDef, options);
    this.m_calibrationImagesCycleProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnCalibrationImageEndLoop");
    this.m_calibrationImagesCycleProxy.RegisterToCallback(inkanimEventType.OnStart, this, n"OnCalibrationImageAnimStart");
  }

  protected cb func OnCalibrationImageAnimStart(anim: ref<inkAnimProxy>) -> Bool {
    this.SetHDRCalibrationScreen(true);
  }

  protected cb func OnCalibrationImageEndLoop(anim: ref<inkAnimProxy>) -> Bool {
    if Equals(this.s_currentCalibrationImage, this.s_calibrationImageNight) {
      this.s_currentCalibrationImage = this.s_calibrationImageDay;
    } else {
      this.s_currentCalibrationImage = this.s_calibrationImageNight;
    };
    this.SetTexturePart(this.s_currentCalibrationImage);
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  private final native func SetTexturePart(partName: CName) -> Void;

  private final native func SetHDRCalibrationScreen(enabled: Bool) -> Void;

  private final native func SetRenderGameInBackground(enabled: Bool) -> Void;
}
