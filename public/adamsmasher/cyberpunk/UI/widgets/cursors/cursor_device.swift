
public class cursorDeviceGameController extends inkGameController {

  private let m_bbUIData: wref<IBlackboard>;

  private let m_bbWeaponInfo: wref<IBlackboard>;

  private let m_bbWeaponEventId: ref<CallbackHandle>;

  private let m_bbPlayerTierEventId: ref<CallbackHandle>;

  private let m_interactionBlackboardId: ref<CallbackHandle>;

  private let m_upperBodyStateBlackboardId: ref<CallbackHandle>;

  private let m_sceneTier: GameplayTier;

  private let m_upperBodyState: gamePSMUpperBodyStates;

  private let m_isUnarmed: Bool;

  private let m_cursorDevice: wref<inkImage>;

  private let m_fadeOutAnimation: ref<inkAnimDef>;

  private let m_fadeInAnimation: ref<inkAnimDef>;

  private let m_wasLastInteractionWithDevice: Bool;

  private let m_interactionDeviceState: Bool;

  protected cb func OnInitialize() -> Bool {
    let bbPlayerSM: ref<IBlackboard>;
    let playerPuppet: wref<GameObject>;
    let playerSMDef: ref<PlayerStateMachineDef>;
    this.m_wasLastInteractionWithDevice = false;
    this.m_bbUIData = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    this.m_interactionBlackboardId = this.m_bbUIData.RegisterListenerVariant(GetAllBlackboardDefs().UIGameData.InteractionData, this, n"OnInteractionStateChange");
    this.m_bbWeaponInfo = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    this.m_bbWeaponEventId = this.m_bbWeaponInfo.RegisterListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.WeaponRecordID, this, n"OnWeaponSwap");
    this.m_cursorDevice = this.GetWidget(n"cursor_device") as inkImage;
    this.m_cursorDevice.SetOpacity(0.00);
    this.m_isUnarmed = true;
    this.m_interactionDeviceState = false;
    this.m_upperBodyState = gamePSMUpperBodyStates.Default;
    this.m_interactionDeviceState = false;
    playerPuppet = this.GetOwnerEntity() as PlayerPuppet;
    playerSMDef = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      bbPlayerSM = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(bbPlayerSM) {
        this.m_upperBodyStateBlackboardId = bbPlayerSM.RegisterListenerInt(playerSMDef.UpperBody, this, n"OnUpperBodyChange");
      };
    };
    this.CreateAnimations();
  }

  protected cb func OnUninitialize() -> Bool {
    let bbPlayerSM: ref<IBlackboard>;
    let playerPuppet: wref<GameObject>;
    let playerSMDef: ref<PlayerStateMachineDef>;
    if IsDefined(this.m_bbUIData) {
      this.m_bbUIData.UnregisterListenerVariant(GetAllBlackboardDefs().UIGameData.InteractionData, this.m_interactionBlackboardId);
    };
    if IsDefined(this.m_bbWeaponInfo) {
      this.m_bbWeaponInfo.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.WeaponRecordID, this.m_bbWeaponEventId);
    };
    playerPuppet = this.GetOwnerEntity() as PlayerPuppet;
    playerSMDef = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      bbPlayerSM = this.GetPSMBlackboard(playerPuppet);
      if IsDefined(bbPlayerSM) {
        bbPlayerSM.UnregisterListenerInt(playerSMDef.UpperBody, this.m_upperBodyStateBlackboardId);
      };
    };
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    this.RegisterPSMListeners(playerGameObject);
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(playerGameObject);
  }

  protected final func RegisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let bbSceneTier: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(bbSceneTier) {
      this.m_bbPlayerTierEventId = bbSceneTier.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier, this, n"OnSceneTierChange");
    };
  }

  protected final func UnregisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let bbSceneTier: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(bbSceneTier) {
      bbSceneTier.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier, this.m_bbPlayerTierEventId);
    };
  }

  protected cb func OnWeaponSwap(value: Variant) -> Bool {
    this.m_isUnarmed = FromVariant(value) == TDBID.undefined();
  }

  protected cb func OnSceneTierChange(argTier: Int32) -> Bool {
    this.m_sceneTier = IntEnum(argTier);
  }

  protected cb func OnUpperBodyChange(state: Int32) -> Bool {
    this.m_upperBodyState = IntEnum(state);
    this.UpdateIsInteractingWithDevice();
  }

  protected cb func OnInteractionStateChange(value: Variant) -> Bool {
    let interactionData: bbUIInteractionData = FromVariant(value);
    this.m_interactionDeviceState = interactionData.terminalInteractionActive;
    this.UpdateIsInteractingWithDevice();
  }

  private final func UpdateIsInteractingWithDevice() -> Void {
    let isInteractingWithDevice: Bool = this.m_interactionDeviceState && NotEquals(this.m_upperBodyState, gamePSMUpperBodyStates.Aim);
    if NotEquals(isInteractingWithDevice, this.m_wasLastInteractionWithDevice) {
      if isInteractingWithDevice && (this.m_isUnarmed || NotEquals(this.m_sceneTier, GameplayTier.Tier1_FullGameplay)) {
        this.m_cursorDevice.StopAllAnimations();
        this.m_cursorDevice.SetOpacity(1.00);
      } else {
        if isInteractingWithDevice {
          this.m_cursorDevice.StopAllAnimations();
          this.m_cursorDevice.PlayAnimation(this.m_fadeInAnimation);
        } else {
          if this.m_wasLastInteractionWithDevice {
            this.m_cursorDevice.StopAllAnimations();
            this.m_cursorDevice.PlayAnimation(this.m_fadeOutAnimation);
          };
        };
      };
    };
    this.m_wasLastInteractionWithDevice = isInteractingWithDevice;
  }

  private final func CreateAnimations() -> Void {
    let fadeOutInterp: ref<inkAnimTransparency>;
    this.m_fadeInAnimation = new inkAnimDef();
    let fadeInInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeInInterp.SetStartDelay(0.75);
    fadeInInterp.SetStartTransparency(0.00);
    fadeInInterp.SetEndTransparency(0.85);
    fadeInInterp.SetDuration(0.20);
    fadeInInterp.SetType(inkanimInterpolationType.Quadratic);
    fadeInInterp.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_fadeInAnimation.AddInterpolator(fadeInInterp);
    this.m_fadeOutAnimation = new inkAnimDef();
    fadeOutInterp = new inkAnimTransparency();
    fadeOutInterp.SetStartTransparency(1.00);
    fadeOutInterp.SetEndTransparency(0.00);
    fadeOutInterp.SetDuration(0.10);
    fadeOutInterp.SetType(inkanimInterpolationType.Quadratic);
    fadeOutInterp.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_fadeOutAnimation.AddInterpolator(fadeOutInterp);
  }
}
