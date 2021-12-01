
public class StaminabarWidgetGameController extends inkHUDGameController {

  private edit let m_staminaControllerRef: inkWidgetRef;

  private edit let m_staminaPercTextPath: inkTextRef;

  private edit let m_staminaStatusTextPath: inkTextRef;

  private let m_bbPSceneTierEventId: ref<CallbackHandle>;

  private let m_bbPStaminaPSMEventId: ref<CallbackHandle>;

  private let m_staminaController: wref<NameplateBarLogicController>;

  private let m_RootWidget: wref<inkWidget>;

  private let m_animLongFade: ref<inkAnimDef>;

  private let m_animHideStaminaProxy: ref<inkAnimProxy>;

  @default(StaminabarWidgetGameController, 100.f)
  private let m_currentStamina: Float;

  @default(StaminabarWidgetGameController, GameplayTier.Tier1_FullGameplay)
  private let m_sceneTier: GameplayTier;

  @default(StaminabarWidgetGameController, gamePSMStamina.Rested)
  private let m_staminaState: gamePSMStamina;

  private let m_staminaPoolListener: ref<StaminaPoolListener>;

  protected cb func OnInitialize() -> Bool {
    let playerPuppet: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(playerPuppet.GetGame());
    this.m_RootWidget = this.GetRootWidget();
    this.m_RootWidget.SetVisible(false);
    this.m_staminaController = inkWidgetRef.GetController(this.m_staminaControllerRef) as NameplateBarLogicController;
    this.m_staminaPoolListener = new StaminaPoolListener();
    this.m_staminaPoolListener.BindStaminaBar(this);
    statPoolsSystem.RequestRegisteringListener(Cast(playerPuppet.GetEntityID()), gamedataStatPoolType.Stamina, this.m_staminaPoolListener);
    this.CreateAnimations();
    this.EvaluateStaminaBarVisibility();
  }

  protected cb func OnUninitialize() -> Bool {
    let player: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    if IsDefined(this.m_staminaPoolListener) {
      GameInstance.GetStatPoolsSystem(player.GetGame()).RequestUnregisteringListener(Cast(player.GetEntityID()), gamedataStatPoolType.Stamina, this.m_staminaPoolListener);
      this.m_staminaPoolListener = null;
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
        this.m_sceneTier = IntEnum(playerStateMachineBlackboard.GetInt(playerSMDef.SceneTier));
        this.m_staminaState = IntEnum(playerStateMachineBlackboard.GetInt(playerSMDef.Stamina));
        this.m_bbPSceneTierEventId = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.SceneTier, this, n"OnSceneTierChange");
        this.m_bbPStaminaPSMEventId = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.Stamina, this, n"OnStaminaPSMChange");
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
        playerStateMachineBlackboard.UnregisterDelayedListener(playerSMDef.Stamina, this.m_bbPStaminaPSMEventId);
      };
    };
  }

  public final func UpdateStaminaValue(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_currentStamina = newValue;
    if Equals(this.m_staminaState, gamePSMStamina.Exhausted) {
      inkWidgetRef.SetOpacity(this.m_staminaControllerRef, 0.50);
    } else {
      inkWidgetRef.SetOpacity(this.m_staminaControllerRef, 1.00);
    };
    this.m_staminaController.SetNameplateBarProgress(newValue / 100.00, false);
    inkTextRef.SetTextFromParts(this.m_staminaPercTextPath, IntToString(Cast(newValue)), "Common-Characters-Percetage", "");
    this.UpdateStaminaLevelWarningFluffTexts(this.m_staminaState);
  }

  public final func UpdateStaminaLevelWarningFluffTexts(staminaState: gamePSMStamina) -> Void {
    if Equals(staminaState, gamePSMStamina.Exhausted) {
      inkTextRef.SetText(this.m_staminaStatusTextPath, "LocKey#40314");
    } else {
      inkTextRef.SetText(this.m_staminaStatusTextPath, "LocKey#40311");
    };
  }

  public final func EvaluateStaminaBarVisibility() -> Void {
    let animFade: ref<inkAnimDef>;
    switch this.m_sceneTier {
      case GameplayTier.Tier1_FullGameplay:
        this.m_RootWidget.SetVisible(true);
        break;
      default:
        this.m_RootWidget.SetVisible(false);
    };
    if this.ShouldHide() {
      animFade = this.m_animLongFade;
      this.m_RootWidget.SetVisible(false);
      if this.m_RootWidget.IsVisible() && (!IsDefined(this.m_animHideStaminaProxy) || !this.m_animHideStaminaProxy.IsPlaying()) {
        this.m_animHideStaminaProxy = this.m_RootWidget.PlayAnimation(animFade);
        this.m_animHideStaminaProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnStaminaHideAnimationFinished");
      };
    } else {
      if IsDefined(this.m_animHideStaminaProxy) && this.m_animHideStaminaProxy.IsPlaying() {
        this.m_animHideStaminaProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnStaminaHideAnimationFinished");
        this.m_animHideStaminaProxy.Stop();
      };
      this.m_RootWidget.SetOpacity(1.00);
      this.m_RootWidget.SetVisible(true);
    };
  }

  private final func ShouldHide() -> Bool {
    let isMaxStamina: Bool = this.m_currentStamina >= 100.00;
    let isMultiplayer: Bool = this.IsPlayingMultiplayer();
    return isMaxStamina && !isMultiplayer || Equals(this.m_sceneTier, GameplayTier.Tier4_FPPCinematic) || Equals(this.m_sceneTier, GameplayTier.Tier5_Cinematic);
  }

  private final func IsPlayingMultiplayer() -> Bool {
    let playerPuppet: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    return IsDefined(playerPuppet) && GameInstance.GetRuntimeInfo(playerPuppet.GetGame()).IsMultiplayer();
  }

  protected cb func OnStaminaHideAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_RootWidget.SetVisible(false);
  }

  private final func CreateAnimations() -> Void {
    this.m_animLongFade = new inkAnimDef();
    let fadeInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeInterp.SetStartDelay(10.00);
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(0.00);
    fadeInterp.SetDuration(0.35);
    this.m_animLongFade.AddInterpolator(fadeInterp);
  }

  protected cb func OnSceneTierChange(argTier: Int32) -> Bool {
    this.m_sceneTier = IntEnum(argTier);
    this.EvaluateStaminaBarVisibility();
  }

  protected cb func OnStaminaPSMChange(arg: Int32) -> Bool {
    this.m_staminaState = IntEnum(arg);
  }

  protected cb func OnForceHide() -> Bool {
    this.EvaluateStaminaBarVisibility();
  }

  protected cb func OnForceTierVisibility(tierVisibility: Bool) -> Bool {
    this.EvaluateStaminaBarVisibility();
  }
}

public class StaminaPoolListener extends ScriptStatPoolsListener {

  private let m_staminaBar: wref<StaminabarWidgetGameController>;

  public final func BindStaminaBar(bar: wref<StaminabarWidgetGameController>) -> Void {
    this.m_staminaBar = bar;
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_staminaBar.UpdateStaminaValue(oldValue, newValue, percToPoints);
    this.m_staminaBar.EvaluateStaminaBarVisibility();
  }
}
