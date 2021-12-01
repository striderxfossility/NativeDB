
public native class gameuiCrosshairContainerController extends inkHUDGameController {

  private edit let m_sprintWidget: inkWidgetRef;

  private let m_bbUIData: wref<IBlackboard>;

  private let m_bbWeaponInfo: wref<IBlackboard>;

  private let m_bbPlayerTierEventId: ref<CallbackHandle>;

  private let m_bbWeaponEventId: ref<CallbackHandle>;

  private let m_interactionBlackboardId: ref<CallbackHandle>;

  private let m_crosshairStateBlackboardId: ref<CallbackHandle>;

  private let m_isMountedBlackboardId: ref<CallbackHandle>;

  private let m_rootWidget: wref<inkCanvas>;

  private let m_fadeOutAnimation: ref<inkAnimDef>;

  private let m_fadeInAnimation: ref<inkAnimDef>;

  private let m_sceneTier: GameplayTier;

  private let m_isUnarmed: Bool;

  @default(gameuiCrosshairContainerController, false)
  private let m_isMounted: Bool;

  @default(gameuiCrosshairContainerController, 0.0f)
  private let m_fadeOutValue: Float;

  private let m_wasLastInteractionWithDevice: Bool;

  private let m_CombatStateBlackboardId: ref<CallbackHandle>;

  private let m_hiddenAnimProxy: ref<inkAnimProxy>;

  private let m_Player: wref<PlayerPuppet>;

  private edit let HiddenTextCanvas: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    this.m_bbUIData = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    this.m_interactionBlackboardId = this.m_bbUIData.RegisterListenerVariant(GetAllBlackboardDefs().UIGameData.InteractionData, this, n"OnInteractionStateChange");
    this.m_bbWeaponInfo = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    this.m_bbWeaponEventId = this.m_bbWeaponInfo.RegisterListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.WeaponRecordID, this, n"OnWeaponSwap");
    this.m_isUnarmed = true;
    this.m_rootWidget = this.GetRootWidget() as inkCanvas;
    inkWidgetRef.SetVisible(this.m_sprintWidget, false);
    this.m_wasLastInteractionWithDevice = false;
    inkWidgetRef.SetVisible(this.HiddenTextCanvas, false);
    this.CreateAnimations();
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_bbUIData) {
      this.m_bbUIData.UnregisterListenerVariant(GetAllBlackboardDefs().UIGameData.InteractionData, this.m_interactionBlackboardId);
    };
    if IsDefined(this.m_bbWeaponInfo) {
      this.m_bbWeaponInfo.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.WeaponRecordID, this.m_bbWeaponEventId);
    };
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    this.RegisterPSMListeners(playerGameObject);
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(playerGameObject);
  }

  protected final func RegisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let bbCrosshairInfo: ref<IBlackboard>;
    let bbVehicleInfo: ref<IBlackboard>;
    this.m_Player = playerPuppet as PlayerPuppet;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      bbCrosshairInfo = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(bbCrosshairInfo) {
        this.m_crosshairStateBlackboardId = bbCrosshairInfo.RegisterListenerInt(playerSMDef.Crosshair, this, n"OnPSMCrosshairStateChanged");
        this.m_bbPlayerTierEventId = bbCrosshairInfo.RegisterListenerInt(playerSMDef.SceneTier, this, n"OnSceneTierChange");
      };
    };
    if IsDefined(this.m_Player) && this.m_Player.IsControlledByLocalPeer() {
      bbVehicleInfo = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
      this.m_isMountedBlackboardId = bbVehicleInfo.RegisterListenerBool(GetAllBlackboardDefs().UI_ActiveVehicleData.IsPlayerMounted, this, n"OnMountChanged");
    };
  }

  protected final func UnregisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let bbCrosshairInfo: ref<IBlackboard>;
    let bbVehicleInfo: ref<IBlackboard>;
    let playerSMBB: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      bbCrosshairInfo = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(bbCrosshairInfo) {
        bbCrosshairInfo.UnregisterListenerInt(playerSMDef.Crosshair, this.m_crosshairStateBlackboardId);
        bbCrosshairInfo.UnregisterListenerInt(playerSMDef.SceneTier, this.m_bbPlayerTierEventId);
      };
    };
    playerSMBB = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(this.m_crosshairStateBlackboardId) {
      playerSMBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.Crosshair, this.m_crosshairStateBlackboardId);
    };
    if IsDefined(this.m_CombatStateBlackboardId) {
      playerSMBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.Combat, this.m_CombatStateBlackboardId);
    };
    if IsDefined(this.m_isMountedBlackboardId) {
      bbVehicleInfo = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveVehicleData);
      bbVehicleInfo.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ActiveVehicleData.IsPlayerMounted, this.m_isMountedBlackboardId);
    };
  }

  private final native func GetActiveCrosshairWidget() -> wref<inkWidget>;

  private final native func GetActiveCrosshairGameController() -> wref<gameuiCrosshairBaseGameController>;

  protected cb func OnPSMCrosshairStateChanged(value: Int32) -> Bool {
    let newState: gamePSMCrosshairStates = IntEnum(value);
    inkWidgetRef.SetVisible(this.m_sprintWidget, NotEquals(newState, gamePSMCrosshairStates.Aim) && NotEquals(newState, gamePSMCrosshairStates.Scanning) && NotEquals(newState, gamePSMCrosshairStates.LeftHandCyberware) && NotEquals(newState, gamePSMCrosshairStates.QuickHack));
  }

  protected cb func OnMountChanged(mounted: Bool) -> Bool {
    this.m_isMounted = mounted;
    this.UpdateRootVisibility();
  }

  private final func UpdateRootVisibility() -> Void {
    this.GetRootWidget().SetVisible(!this.m_isUnarmed || !this.m_isMounted);
  }

  protected cb func OnInteractionStateChange(value: Variant) -> Bool {
    let interactionData: bbUIInteractionData = FromVariant(value);
    if NotEquals(interactionData.terminalInteractionActive, this.m_wasLastInteractionWithDevice) {
      if interactionData.terminalInteractionActive && (this.m_isUnarmed || NotEquals(this.m_sceneTier, GameplayTier.Tier1_FullGameplay)) {
        this.m_rootWidget.StopAllAnimations();
        this.m_rootWidget.SetOpacity(this.m_fadeOutValue);
      } else {
        if interactionData.terminalInteractionActive {
          this.m_rootWidget.StopAllAnimations();
          this.m_rootWidget.PlayAnimation(this.m_fadeOutAnimation);
        } else {
          if this.m_wasLastInteractionWithDevice {
            this.m_rootWidget.StopAllAnimations();
            this.m_rootWidget.PlayAnimation(this.m_fadeInAnimation);
          };
        };
      };
    };
    this.m_wasLastInteractionWithDevice = interactionData.terminalInteractionActive;
  }

  protected cb func OnWeaponSwap(value: Variant) -> Bool {
    this.m_isUnarmed = FromVariant(value) == TDBID.undefined();
    this.UpdateRootVisibility();
  }

  protected cb func OnSceneTierChange(argTier: Int32) -> Bool {
    this.m_sceneTier = IntEnum(argTier);
  }

  private final func CreateAnimations() -> Void {
    let fadeInInterp: ref<inkAnimTransparency>;
    this.m_fadeOutAnimation = new inkAnimDef();
    let fadeOutInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeOutInterp.SetStartDelay(0.75);
    fadeOutInterp.SetStartTransparency(1.00);
    fadeOutInterp.SetEndTransparency(this.m_fadeOutValue);
    fadeOutInterp.SetDuration(0.20);
    fadeOutInterp.SetType(inkanimInterpolationType.Quadratic);
    fadeOutInterp.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_fadeOutAnimation.AddInterpolator(fadeOutInterp);
    this.m_fadeInAnimation = new inkAnimDef();
    fadeInInterp = new inkAnimTransparency();
    fadeInInterp.SetStartTransparency(this.m_rootWidget.GetOpacity());
    fadeInInterp.SetEndTransparency(1.00);
    fadeInInterp.SetDuration(0.10);
    fadeOutInterp.SetType(inkanimInterpolationType.Quadratic);
    fadeOutInterp.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_fadeInAnimation.AddInterpolator(fadeInInterp);
  }
}
