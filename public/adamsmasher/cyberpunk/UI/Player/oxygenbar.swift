
public class OxygenbarWidgetGameController extends inkHUDGameController {

  private edit let m_oxygenControllerRef: inkWidgetRef;

  private edit let m_oxygenPercTextPath: inkTextRef;

  private edit let m_oxygenStatusTextPath: inkTextRef;

  private let m_bbPSceneTierEventId: ref<CallbackHandle>;

  private let m_swimmingStateBlackboardId: ref<CallbackHandle>;

  private let m_oxygenController: wref<NameplateBarLogicController>;

  private let m_RootWidget: wref<inkWidget>;

  private let m_animHideTemp: ref<inkAnimDef>;

  private let m_animShortFade: ref<inkAnimDef>;

  private let m_animLongFade: ref<inkAnimDef>;

  private let m_animHideOxygenProxy: ref<inkAnimProxy>;

  @default(OxygenbarWidgetGameController, 100.f)
  private let m_currentOxygen: Float;

  @default(OxygenbarWidgetGameController, GameplayTier.Tier1_FullGameplay)
  private let m_sceneTier: GameplayTier;

  private let m_currentSwimmingState: gamePSMSwimming;

  private let m_oxygenListener: ref<OxygenListener>;

  protected cb func OnInitialize() -> Bool {
    let playerPuppet: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(playerPuppet.GetGame());
    this.m_RootWidget = this.GetRootWidget();
    this.m_RootWidget.SetVisible(false);
    this.m_oxygenController = inkWidgetRef.GetController(this.m_oxygenControllerRef) as NameplateBarLogicController;
    this.m_oxygenListener = new OxygenListener();
    this.m_oxygenListener.BindOxygenBar(this);
    statPoolsSystem.RequestRegisteringListener(Cast(playerPuppet.GetEntityID()), gamedataStatPoolType.Oxygen, this.m_oxygenListener);
    this.CreateAnimations();
    this.EvaluateOxygenBarVisibility();
  }

  protected cb func OnUninitialize() -> Bool {
    let player: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    if IsDefined(this.m_oxygenListener) {
      GameInstance.GetStatPoolsSystem(player.GetGame()).RequestUnregisteringListener(Cast(player.GetEntityID()), gamedataStatPoolType.Oxygen, this.m_oxygenListener);
      this.m_oxygenListener = null;
    };
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    this.RegisterPSMListeners(playerGameObject);
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(playerGameObject);
  }

  protected final func RegisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if playerPuppet.IsControlledByLocalPeer() {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(playerStateMachineBlackboard) {
        this.m_bbPSceneTierEventId = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.SceneTier, this, n"OnSceneTierChange");
        this.m_swimmingStateBlackboardId = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.Swimming, this, n"OnPSMSwimmingStateChanged");
      };
    };
  }

  protected final func UnregisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if playerPuppet.IsControlledByLocalPeer() {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(playerStateMachineBlackboard) {
        playerStateMachineBlackboard.UnregisterDelayedListener(playerSMDef.SceneTier, this.m_bbPSceneTierEventId);
        playerStateMachineBlackboard.UnregisterDelayedListener(playerSMDef.Swimming, this.m_swimmingStateBlackboardId);
      };
    };
  }

  public final func UpdateOxygenValue(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_currentOxygen = newValue;
    let oxygenPerc: Int32 = Cast(100.00 * this.m_currentOxygen / 100.00);
    this.m_oxygenController.SetNameplateBarProgress(newValue / 100.00, false);
    inkTextRef.SetTextFromParts(this.m_oxygenPercTextPath, IntToString(Cast(newValue)), "Common-Characters-Percetage", "");
    this.UpdateOxygenLevelWarningFluffTexts(oxygenPerc);
  }

  public final func UpdateOxygenLevelWarningFluffTexts(oxygenPerc: Int32) -> Void {
    let critOxygenThreshold: Float = TweakDBInterface.GetFloat(t"player.oxygenThresholds.critOxygenThreshold", 10.00);
    let lowOxygenThreshold: Float = TweakDBInterface.GetFloat(t"player.oxygenThresholds.lowOxygenThreshold", 20.00);
    if oxygenPerc <= 0 {
      inkTextRef.SetText(this.m_oxygenStatusTextPath, "UI-ScriptExports-OutOfOxygen0");
    } else {
      if oxygenPerc <= Cast(critOxygenThreshold) {
        inkTextRef.SetText(this.m_oxygenStatusTextPath, "UI-Cyberpunk-Player-STATUS_CRITICAL");
      } else {
        if oxygenPerc <= Cast(lowOxygenThreshold) {
          inkTextRef.SetText(this.m_oxygenStatusTextPath, "UI-Cyberpunk-Player-STATUS_WARNING");
        } else {
          inkTextRef.SetText(this.m_oxygenStatusTextPath, "UI-Cyberpunk-Player-STATUS_READINGS_NOMINAL");
        };
      };
    };
  }

  public final func EvaluateOxygenBarVisibility() -> Void {
    let animFade: ref<inkAnimDef>;
    let isMaxOxygen: Bool = this.m_currentOxygen > 99.00;
    let isMultiplayer: Bool = this.IsPlayingMultiplayer();
    switch this.m_currentSwimmingState {
      case gamePSMSwimming.Diving:
        this.m_RootWidget.SetVisible(true);
        break;
      default:
        this.m_RootWidget.SetVisible(false);
    };
    this.m_RootWidget.SetVisible(NotEquals(this.m_sceneTier, GameplayTier.Tier3_LimitedGameplay) && NotEquals(this.m_sceneTier, GameplayTier.Tier4_FPPCinematic) && NotEquals(this.m_sceneTier, GameplayTier.Tier5_Cinematic));
    if isMaxOxygen && !isMultiplayer {
      animFade = this.m_animLongFade;
      this.m_RootWidget.SetVisible(false);
      if this.m_RootWidget.IsVisible() && (!IsDefined(this.m_animHideOxygenProxy) || !this.m_animHideOxygenProxy.IsPlaying()) {
        this.m_animHideOxygenProxy = this.m_RootWidget.PlayAnimation(animFade);
        this.m_animHideOxygenProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOxygenHideAnimationFinished");
      };
    } else {
      if IsDefined(this.m_animHideOxygenProxy) && this.m_animHideOxygenProxy.IsPlaying() {
        this.m_animHideOxygenProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnOxygenHideAnimationFinished");
        this.m_animHideOxygenProxy.Stop();
      };
      this.m_RootWidget.SetOpacity(1.00);
      this.m_RootWidget.SetVisible(true);
    };
  }

  protected cb func OnOxygenHideAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_RootWidget.SetVisible(false);
  }

  private final func IsPlayingMultiplayer() -> Bool {
    let playerPuppet: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    return IsDefined(playerPuppet) && GameInstance.GetRuntimeInfo(playerPuppet.GetGame()).IsMultiplayer();
  }

  private final func CreateAnimations() -> Void {
    let animStartDelay: Float = 1.00;
    this.m_animShortFade = new inkAnimDef();
    let fadeInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeInterp.SetStartDelay(0.20);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.35);
    this.m_animShortFade.AddInterpolator(fadeInterp);
    this.m_animLongFade = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(10.00);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.35);
    this.m_animLongFade.AddInterpolator(fadeInterp);
    this.m_animHideTemp = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartDelay(animStartDelay + 0.26);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.22);
    this.m_animHideTemp.AddInterpolator(fadeInterp);
  }

  protected cb func OnPSMSwimmingStateChanged(value: Int32) -> Bool {
    this.m_currentSwimmingState = IntEnum(value);
    this.EvaluateOxygenBarVisibility();
  }

  protected cb func OnSceneTierChange(argTier: Int32) -> Bool {
    this.m_sceneTier = IntEnum(argTier);
    this.EvaluateOxygenBarVisibility();
  }

  protected cb func OnForceHide() -> Bool {
    this.EvaluateOxygenBarVisibility();
  }

  protected cb func OnForceTierVisibility(tierVisibility: Bool) -> Bool {
    this.EvaluateOxygenBarVisibility();
  }
}

public class OxygenListener extends ScriptStatPoolsListener {

  private let m_oxygenBar: wref<OxygenbarWidgetGameController>;

  public final func BindOxygenBar(bar: wref<OxygenbarWidgetGameController>) -> Void {
    this.m_oxygenBar = bar;
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_oxygenBar.UpdateOxygenValue(oldValue, newValue, percToPoints);
    this.m_oxygenBar.EvaluateOxygenBarVisibility();
  }
}
