
public class SetGameplayRoleEvent extends Event {

  public let gameplayRole: EGameplayRole;

  public final func GetFriendlyDescription() -> String {
    return "Set Gameplay Role";
  }
}

public class ToggleGameplayMappinVisibilityEvent extends Event {

  public let isHidden: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Toggle Gameplay Mappin Visibility";
  }
}

public class GameplayRoleComponent extends ScriptableComponent {

  @attrib(category, "Gameplay Role")
  @default(GameplayRoleComponent, EGameplayRole.UnAssigned)
  private let m_gameplayRole: EGameplayRole;

  @attrib(category, "Gameplay Role")
  @default(GameplayRoleComponent, true)
  private let m_autoDeterminGameplayRole: Bool;

  @default(GameplayRoleComponent, EMappinDisplayMode.MINIMALISTIC)
  private let m_mappinsDisplayMode: EMappinDisplayMode;

  @default(GameplayRoleComponent, false)
  private let m_displayAllRolesAsGeneric: Bool;

  @default(GameplayRoleComponent, true)
  private let m_alwaysCreateMappinAsDynamic: Bool;

  private let m_mappins: array<SDeviceMappinData>;

  @default(GameplayRoleComponent, 0.04f)
  private let m_offsetValue: Float;

  private let m_isBeingScanned: Bool;

  private let m_isCurrentTarget: Bool;

  private let m_isShowingMappins: Bool;

  private let m_canShowMappinsByTask: Bool;

  private let m_canHideMappinsByTask: Bool;

  private let m_isHighlightedInFocusMode: Bool;

  @default(GameplayRoleComponent, EGameplayRole.UnAssigned)
  private let m_currentGameplayRole: EGameplayRole;

  private let m_isGameplayRoleInitialized: Bool;

  private let m_isForceHidden: Bool;

  private let m_isForcedVisibleThroughWalls: Bool;

  private final func DeterminGamplayRoleByTask() -> Void {
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).QueueTask(this, null, n"DeterminGamplayRoleTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func DeterminGamplayRoleTask(data: ref<ScriptTaskData>) -> Void {
    this.DeterminGamplayRole();
  }

  protected func ShowRoleMappinsByTask() -> Void {
    this.m_canShowMappinsByTask = true;
    this.m_canHideMappinsByTask = false;
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).QueueTask(this, null, n"ShowRoleMappinsTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func ShowRoleMappinsTask(data: ref<ScriptTaskData>) -> Void {
    if this.m_canShowMappinsByTask {
      this.m_canShowMappinsByTask = false;
      this.ShowRoleMappins();
    };
  }

  protected func HideRoleMappinsByTask() -> Void {
    if !this.m_isShowingMappins {
      return;
    };
    this.m_canShowMappinsByTask = false;
    this.m_canHideMappinsByTask = true;
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).QueueTask(this, null, n"HideRoleMappinsTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func HideRoleMappinsTask(data: ref<ScriptTaskData>) -> Void {
    if this.m_canHideMappinsByTask {
      this.m_canHideMappinsByTask = false;
      this.HideRoleMappins();
    };
  }

  protected func ClearAllRoleMappinsByTask() -> Void {
    this.m_canShowMappinsByTask = false;
    this.m_canHideMappinsByTask = false;
    GameInstance.GetDelaySystem(this.GetOwner().GetGame()).QueueTask(this, null, n"ClearAllRoleMappinsTask", gameScriptTaskExecutionStage.Any);
  }

  protected final func ClearAllRoleMappinsTask(data: ref<ScriptTaskData>) -> Void {
    this.ClearAllRoleMappins();
  }

  protected cb func OnPostInitialize(evt: ref<entPostInitializeEvent>) -> Bool {
    this.m_currentGameplayRole = this.m_gameplayRole;
    this.DeterminGamplayRole();
    this.InitializeQuickHackIndicator();
    this.InitializePhoneCallIndicator();
  }

  protected cb func OnPreUninitialize(evt: ref<entPreUninitializeEvent>) -> Bool {
    this.UnregisterAllMappins();
  }

  protected final func OnGameAttach() -> Void;

  protected final func OnGameDetach() -> Void;

  protected cb func OnSetGameplayRole(evt: ref<SetGameplayRoleEvent>) -> Bool {
    this.m_gameplayRole = evt.gameplayRole;
    this.SetCurrentGameplayRoleWithNotification(evt.gameplayRole);
    this.ReEvaluateGameplayRole();
  }

  protected cb func OnSetCurrentGameplayRole(evt: ref<SetCurrentGameplayRoleEvent>) -> Bool {
    this.SetCurrentGameplayRoleWithNotification(evt.gameplayRole);
    this.ReEvaluateGameplayRole();
  }

  protected cb func OnReEvaluateGameplayRole(evt: ref<EvaluateGameplayRoleEvent>) -> Bool {
    if !this.IsGameplayRoleStatic() || evt.force {
      if evt.force {
        this.m_currentGameplayRole = this.m_gameplayRole;
      };
      this.ReEvaluateGameplayRole();
    };
  }

  private final func SetCurrentGameplayRoleWithNotification(role: EGameplayRole) -> Void {
    let evt: ref<GameplayRoleChangeNotification>;
    if NotEquals(this.m_currentGameplayRole, role) {
      evt = new GameplayRoleChangeNotification();
      evt.oldRole = this.m_currentGameplayRole;
      evt.newRole = role;
      this.GetOwner().QueueEvent(evt);
    };
    this.m_currentGameplayRole = role;
  }

  protected cb func OnLookedAtEvent(evt: ref<LookedAtEvent>) -> Bool {
    this.m_isCurrentTarget = evt.isLookedAt;
  }

  protected cb func OnScanningLookedAt(evt: ref<ScanningLookAtEvent>) -> Bool {
    this.m_isBeingScanned = evt.state;
  }

  private final const func IsHighlightedInFocusMode() -> Bool {
    return this.m_isHighlightedInFocusMode;
  }

  protected cb func OnLogicReady(evt: ref<SetLogicReadyEvent>) -> Bool {
    this.RequestHUDRefresh();
  }

  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    if Equals(evt.braindanceInstructions.GetState(), InstanceState.ON) {
      if this.GetOwner().IsBraindanceBlocked() || this.GetOwner().IsPhotoModeBlocked() {
        this.m_isHighlightedInFocusMode = false;
        this.HideRoleMappinsByTask();
        return false;
      };
    };
    this.m_isForcedVisibleThroughWalls = evt.iconsInstruction.isForcedVisibleThroughWalls;
    if Equals(evt.iconsInstruction.GetState(), InstanceState.ON) {
      this.m_isHighlightedInFocusMode = true;
      this.ShowRoleMappinsByTask();
    } else {
      if evt.highlightInstructions.WasProcessed() {
        this.m_isHighlightedInFocusMode = false;
        this.HideRoleMappinsByTask();
      };
    };
  }

  protected cb func OnUploadProgressStateChanged(evt: ref<UploadProgramProgressEvent>) -> Bool {
    let iconRecord: wref<ChoiceCaptionIconPart_Record>;
    let visualData: ref<GameplayRoleMappinData> = new GameplayRoleMappinData();
    visualData.statPoolType = evt.statPoolType;
    if Equals(evt.state, EUploadProgramState.STARTED) {
      visualData.m_mappinVisualState = EMappinVisualState.Default;
      visualData.m_duration = evt.duration;
      visualData.m_progressBarType = evt.progressBarType;
      visualData.m_progressBarContext = evt.progressBarContext;
      visualData.m_visibleThroughWalls = true;
      if Equals(evt.progressBarContext, EProgressBarContext.QuickHack) {
        iconRecord = evt.action.GetInteractionIcon();
        if IsDefined(iconRecord) {
          visualData.m_textureID = iconRecord.TexturePartID().GetID();
        };
        this.ActivateQuickHackIndicator(visualData);
      } else {
        if Equals(evt.progressBarContext, EProgressBarContext.PhoneCall) {
          iconRecord = evt.iconRecord;
          if IsDefined(iconRecord) {
            visualData.m_textureID = iconRecord.TexturePartID().GetID();
          };
          this.ActivatePhoneCallIndicator(visualData);
        };
      };
    } else {
      if Equals(evt.state, EUploadProgramState.COMPLETED) {
        if Equals(evt.progressBarContext, EProgressBarContext.QuickHack) {
          this.DeactivateQuickHackIndicator();
        } else {
          if Equals(evt.progressBarContext, EProgressBarContext.PhoneCall) {
            this.DeactivatePhoneCallIndicator();
          };
        };
      };
    };
  }

  protected cb func OnPerformedAction(evt: ref<PerformedAction>) -> Bool {
    this.EvaluateMappins();
  }

  private final func ActivateQuickHackIndicator(visualData: ref<GameplayRoleMappinData>) -> Void {
    this.HideRoleMappins();
    this.ToggleMappin(gamedataMappinVariant.QuickHackVariant, true, true, visualData);
  }

  private final func DeactivateQuickHackIndicator() -> Void {
    this.ToggleMappin(gamedataMappinVariant.QuickHackVariant, false);
    this.RequestHUDRefresh();
  }

  protected cb func OnDeactivateQuickHackIndicator(evt: ref<DeactivateQuickHackIndicatorEvent>) -> Bool {
    this.DeactivateQuickHackIndicator();
  }

  private final func ActivatePhoneCallIndicator(visualData: ref<GameplayRoleMappinData>) -> Void {
    this.ToggleMappin(gamedataMappinVariant.PhoneCallVariant, true, true, visualData);
  }

  private final func DeactivatePhoneCallIndicator() -> Void {
    this.ToggleMappin(gamedataMappinVariant.PhoneCallVariant, false);
  }

  protected cb func OnEvaluateMappinVisualStateEvent(evt: ref<EvaluateMappinsVisualStateEvent>) -> Bool {
    if this.m_isShowingMappins {
      this.HideRoleMappins();
      this.ShowRoleMappins();
    };
  }

  protected cb func OnShowSingleMappin(evt: ref<ShowSingleMappinEvent>) -> Bool {
    this.ShowSingleMappin(evt.index);
  }

  protected cb func OnHideSingleMappin(evt: ref<HideSingleMappinEvent>) -> Bool {
    this.HideSingleMappin(evt.index);
  }

  private final func DeterminGamplayRole() -> Void {
    if this.m_autoDeterminGameplayRole && Equals(this.m_currentGameplayRole, EGameplayRole.UnAssigned) {
      this.m_currentGameplayRole = this.GetOwner().DeterminGameplayRole();
    };
    if NotEquals(this.m_currentGameplayRole, IntEnum(1l)) && NotEquals(this.m_currentGameplayRole, EGameplayRole.UnAssigned) {
      this.InitializeGamepleyRoleMappin();
    };
  }

  private final func InitializeQuickHackIndicator() -> Void {
    let mappin: SDeviceMappinData;
    mappin.mappinType = t"Mappins.DeviceMappinDefinition";
    mappin.enabled = false;
    mappin.active = false;
    mappin.permanent = true;
    mappin.checkIfIsTarget = false;
    mappin.mappinVariant = gamedataMappinVariant.QuickHackVariant;
    mappin.gameplayRole = IntEnum(1l);
    this.AddMappin(mappin);
  }

  private final func InitializePhoneCallIndicator() -> Void {
    let mappin: SDeviceMappinData;
    mappin.mappinType = t"Mappins.DeviceMappinDefinition";
    mappin.enabled = false;
    mappin.active = false;
    mappin.permanent = true;
    mappin.checkIfIsTarget = false;
    mappin.mappinVariant = gamedataMappinVariant.PhoneCallVariant;
    mappin.gameplayRole = IntEnum(1l);
    this.AddMappin(mappin);
  }

  private final func InitializeGamepleyRoleMappin() -> Void {
    if this.GetOwner().IsAttached() {
      if Equals(this.m_currentGameplayRole, EGameplayRole.UnAssigned) || Equals(this.m_currentGameplayRole, IntEnum(1l)) {
        this.m_currentGameplayRole = this.GetOwner().DeterminGameplayRole();
      };
      this.m_isGameplayRoleInitialized = this.AddMappin(this.GetMappinDataForGamepleyRole(this.m_currentGameplayRole));
    };
  }

  private final const func GetMappinDataForGamepleyRole(role: EGameplayRole) -> SDeviceMappinData {
    let mappin: SDeviceMappinData;
    if NotEquals(role, IntEnum(1l)) && NotEquals(role, EGameplayRole.UnAssigned) || !this.HasMappin(role) {
      mappin.enabled = false;
      mappin.active = false;
      mappin.range = 35.00;
      mappin.mappinVariant = this.GetCurrentMappinVariant(role);
      mappin.mappinType = t"Mappins.DeviceMappinDefinition";
    };
    mappin.gameplayRole = role;
    return mappin;
  }

  private final const func GetCurrentMappinVariant(role: EGameplayRole) -> gamedataMappinVariant {
    let mappinVariant: gamedataMappinVariant;
    if this.m_displayAllRolesAsGeneric {
      mappinVariant = gamedataMappinVariant.GenericRoleVariant;
    } else {
      if Equals(this.m_mappinsDisplayMode, EMappinDisplayMode.PLAYSTYLE) {
        mappinVariant = this.GetPlaystyleMappinVariant();
      } else {
        if Equals(this.m_mappinsDisplayMode, EMappinDisplayMode.ROLE) {
          mappinVariant = this.GetRoleMappinVariant(role);
        } else {
          if Equals(this.m_mappinsDisplayMode, EMappinDisplayMode.MINIMALISTIC) {
            mappinVariant = this.GetMinimalisticMappinVariant();
          };
        };
      };
    };
    return mappinVariant;
  }

  private final const func GetMinimalisticMappinVariant() -> gamedataMappinVariant {
    let mappinVariant: gamedataMappinVariant;
    if this.GetOwner().IsAnyClueEnabled() {
      mappinVariant = gamedataMappinVariant.FocusClueVariant;
    } else {
      if this.GetOwner().IsContainer() {
        mappinVariant = gamedataMappinVariant.LootVariant;
      } else {
        if !this.GetOwner().IsActive() {
          mappinVariant = gamedataMappinVariant.Invalid;
        } else {
          if this.GetOwner().IsNPC() {
            if this.GetOwner().IsInvestigating() || this.GetOwner().HasHighlight(EFocusForcedHighlightType.INVALID, EFocusOutlineType.DISTRACTION) {
              mappinVariant = gamedataMappinVariant.EffectDistractVariant;
            } else {
              if this.GetOwner().IsHackingPlayer() {
                mappinVariant = gamedataMappinVariant.NetrunnerVariant;
              } else {
                if this.GetOwner().IsActiveBackdoor() {
                  mappinVariant = gamedataMappinVariant.EffectControlNetworkVariant;
                } else {
                  mappinVariant = gamedataMappinVariant.Invalid;
                };
              };
            };
          } else {
            if this.GetOwner().IsBodyDisposalPossible() {
              mappinVariant = gamedataMappinVariant.EffectHideBodyVariant;
            } else {
              if this.GetOwner().IsActiveBackdoor() {
                mappinVariant = gamedataMappinVariant.EffectControlNetworkVariant;
              } else {
                if this.GetOwner().IsExplosive() {
                  mappinVariant = gamedataMappinVariant.EffectExplodeLethalVariant;
                } else {
                  if IsDefined(this.GetOwner() as DisposalDevice) && !this.GetOwner().IsQuickHackAble() {
                    mappinVariant = gamedataMappinVariant.EffectHideBodyVariant;
                  } else {
                    if this.GetOwner().HasImportantInteraction() {
                      mappinVariant = gamedataMappinVariant.ImportantInteractionVariant;
                    } else {
                      if this.GetOwner().IsControllingDevices() {
                        mappinVariant = gamedataMappinVariant.EffectControlOtherDeviceVariant;
                      } else {
                        if this.GetOwner().HasAnyDirectInteractionActive() {
                          mappinVariant = gamedataMappinVariant.GenericRoleVariant;
                        } else {
                          mappinVariant = gamedataMappinVariant.Invalid;
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    return mappinVariant;
  }

  private final const func GetPlaystyleMappinVariant() -> gamedataMappinVariant {
    let mappinVariant: gamedataMappinVariant;
    if this.GetOwner().IsAnyClueEnabled() {
      mappinVariant = gamedataMappinVariant.FocusClueVariant;
    } else {
      if this.GetOwner().IsNetrunner() && this.GetOwner().IsSolo() && this.GetOwner().IsTechie() {
        mappinVariant = gamedataMappinVariant.NetrunnerSoloTechieVariant;
      } else {
        if this.GetOwner().IsNetrunner() && this.GetOwner().IsSolo() {
          mappinVariant = gamedataMappinVariant.NetrunnerSoloVariant;
        } else {
          if this.GetOwner().IsNetrunner() && this.GetOwner().IsTechie() {
            mappinVariant = gamedataMappinVariant.NetrunnerTechieVariant;
          } else {
            if this.GetOwner().IsSolo() && this.GetOwner().IsTechie() {
              mappinVariant = gamedataMappinVariant.SoloTechieVariant;
            } else {
              if this.GetOwner().IsNetrunner() {
                mappinVariant = gamedataMappinVariant.NetrunnerVariant;
              } else {
                if this.GetOwner().IsTechie() {
                  mappinVariant = gamedataMappinVariant.TechieVariant;
                } else {
                  if this.GetOwner().IsSolo() {
                    mappinVariant = gamedataMappinVariant.SoloVariant;
                  } else {
                    mappinVariant = gamedataMappinVariant.GenericRoleVariant;
                  };
                };
              };
            };
          };
        };
      };
    };
    return mappinVariant;
  }

  private final const func GetRoleMappinVariant(role: EGameplayRole) -> gamedataMappinVariant {
    let mappinVariant: gamedataMappinVariant;
    if this.GetOwner().IsAnyClueEnabled() {
      mappinVariant = gamedataMappinVariant.FocusClueVariant;
    } else {
      switch role {
        case EGameplayRole.Alarm:
          mappinVariant = gamedataMappinVariant.EffectAlarmVariant;
          break;
        case EGameplayRole.ControlNetwork:
          mappinVariant = gamedataMappinVariant.EffectControlNetworkVariant;
          break;
        case EGameplayRole.ControlOtherDevice:
          mappinVariant = gamedataMappinVariant.EffectControlOtherDeviceVariant;
          break;
        case EGameplayRole.ControlSelf:
          mappinVariant = gamedataMappinVariant.EffectControlSelfVariant;
          break;
        case EGameplayRole.CutPower:
          mappinVariant = gamedataMappinVariant.EffectCutPowerVariant;
          break;
        case EGameplayRole.Distract:
          mappinVariant = gamedataMappinVariant.EffectDistractVariant;
          break;
        case EGameplayRole.DropPoint:
          mappinVariant = gamedataMappinVariant.EffectDropPointVariant;
          break;
        case EGameplayRole.ExplodeLethal:
          mappinVariant = gamedataMappinVariant.EffectExplodeLethalVariant;
          break;
        case EGameplayRole.ExplodeNoneLethal:
          mappinVariant = gamedataMappinVariant.EffectExplodeNonLethalVariant;
          break;
        case EGameplayRole.Fall:
          mappinVariant = gamedataMappinVariant.EffectFallVariant;
          break;
        case EGameplayRole.FastTravel:
          mappinVariant = gamedataMappinVariant.FastTravelVariant;
          break;
        case EGameplayRole.GrantInformation:
          mappinVariant = gamedataMappinVariant.EffectGrantInformationVariant;
          break;
        case EGameplayRole.Clue:
          mappinVariant = gamedataMappinVariant.FocusClueVariant;
          break;
        case EGameplayRole.HazardWarning:
          mappinVariant = gamedataMappinVariant.HazardWarningVariant;
          break;
        case EGameplayRole.HideBody:
          mappinVariant = gamedataMappinVariant.EffectHideBodyVariant;
          break;
        case EGameplayRole.Loot:
          mappinVariant = gamedataMappinVariant.EffectLootVariant;
          break;
        case EGameplayRole.OpenPath:
          mappinVariant = gamedataMappinVariant.EffectOpenPathVariant;
          break;
        case EGameplayRole.Push:
          mappinVariant = gamedataMappinVariant.EffectPushVariant;
          break;
        case EGameplayRole.ServicePoint:
          mappinVariant = gamedataMappinVariant.EffectServicePointVariant;
          break;
        case EGameplayRole.Shoot:
          mappinVariant = gamedataMappinVariant.EffectShootVariant;
          break;
        case EGameplayRole.SpreadGas:
          mappinVariant = gamedataMappinVariant.EffectSpreadGasVariant;
          break;
        case EGameplayRole.StoreItems:
          mappinVariant = gamedataMappinVariant.EffectStoreItemsVariant;
          break;
        case EGameplayRole.GenericRole:
          mappinVariant = gamedataMappinVariant.GenericRoleVariant;
          break;
        default:
          mappinVariant = gamedataMappinVariant.Invalid;
      };
    };
    return mappinVariant;
  }

  private final func HasOffscreenArrow() -> Bool {
    if this.GetOwner().IsNPC() && (this.GetOwner().IsInvestigating() || this.GetOwner().HasHighlight(EFocusForcedHighlightType.INVALID, EFocusOutlineType.DISTRACTION)) {
      return true;
    };
    return false;
  }

  private final func ReEvaluateGameplayRole() -> Void {
    let evt: ref<GameplayRoleChangeNotification>;
    let newRole: EGameplayRole;
    let isShowingMappins: Bool = this.m_isShowingMappins;
    let oldRole: EGameplayRole = this.m_currentGameplayRole;
    this.ClearAllRoleMappins();
    this.DeterminGamplayRole();
    newRole = this.m_currentGameplayRole;
    if isShowingMappins {
      this.ShowRoleMappinsByTask();
    };
    if Equals(this.GetCurrentGameplayRole(), IntEnum(1l)) {
      this.UpdateDefaultHighlight();
    };
    if NotEquals(newRole, oldRole) {
      evt = new GameplayRoleChangeNotification();
      evt.oldRole = oldRole;
      evt.newRole = newRole;
      this.GetOwner().QueueEvent(evt);
    };
  }

  private final func GetMappinSystem() -> ref<MappinSystem> {
    return GameInstance.GetMappinSystem(this.GetOwner().GetGame());
  }

  private func EvaluateMappins() -> Void {
    let isRoleValid: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if NotEquals(this.m_mappins[i].gameplayRole, IntEnum(1l)) && NotEquals(this.m_mappins[i].gameplayRole, EGameplayRole.UnAssigned) {
        isRoleValid = this.GetOwner().IsGameplayRoleValid(this.m_mappins[i].gameplayRole);
        this.ToggleMappin(i, isRoleValid);
      };
      i += 1;
    };
  }

  private final func EvaluatePositions() -> Void {
    let currentOffset: Vector4;
    let currentPos: Vector4;
    let offsetValue: Float;
    let direction: Int32 = 0;
    let slotTransform: WorldTransform = this.GetOwner().GetPlaystyleMappinSlotWorldTransform();
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if !this.m_mappins[i].enabled {
      } else {
        if direction != 0 {
          direction *= -1;
          offsetValue += this.m_offsetValue * Cast(direction);
        } else {
          if direction == 0 {
            offsetValue = 0.00;
            direction = 1;
          };
        };
        currentOffset = this.m_mappins[i].offset;
        currentOffset.X = currentOffset.X + offsetValue;
        currentPos = WorldPosition.ToVector4(WorldTransform.TransformPoint(slotTransform, currentOffset));
        this.m_mappins[i].position = currentPos;
        currentOffset = new Vector4(0.00, 0.00, 0.00, 0.00);
        currentPos = new Vector4(0.00, 0.00, 0.00, 0.00);
      };
      i += 1;
    };
  }

  private final func GetNextAxis(currentAxis: EAxisType) -> EAxisType {
    let axisValue: Int32;
    let nextAxis: EAxisType;
    if EnumInt(currentAxis) < 3 {
      axisValue += 1;
      nextAxis = IntEnum(axisValue);
    } else {
      nextAxis = IntEnum(0);
    };
    return nextAxis;
  }

  public final func ShowRoleMappins() -> Void {
    let currentVariant: gamedataMappinVariant;
    let i: Int32;
    let invalidID: NewMappinID;
    let shouldUpdate: Bool;
    let shouldUpdateVariant: Bool;
    let visualData: ref<GameplayRoleMappinData>;
    let owner: ref<GameObject> = this.GetOwner();
    let lootContainer: ref<gameLootContainerBase> = owner as gameLootContainerBase;
    let deviceBase: ref<DeviceBase> = owner as DeviceBase;
    if IsDefined(deviceBase) && !deviceBase.IsLogicReady() || IsDefined(lootContainer) && !lootContainer.IsLogicReady() {
      return;
    };
    if this.HasActiveMappin(gamedataMappinVariant.QuickHackVariant) {
      return;
    };
    if this.IsForceHidden() {
      return;
    };
    if !this.m_isGameplayRoleInitialized {
      this.InitializeGamepleyRoleMappin();
    };
    this.EvaluateMappins();
    if !this.m_alwaysCreateMappinAsDynamic {
      this.EvaluatePositions();
    };
    i = 0;
    while i < ArraySize(this.m_mappins) {
      if !this.m_mappins[i].enabled {
      } else {
        if Equals(this.m_mappins[i].gameplayRole, IntEnum(1l)) || Equals(this.m_mappins[i].gameplayRole, EGameplayRole.UnAssigned) {
        } else {
          if Equals(this.m_mappins[i].gameplayRole, EGameplayRole.Loot) && GameInstance.GetSceneSystem(this.GetOwner().GetGame()).GetScriptInterface().IsRewindableSectionActive() {
          } else {
            this.m_isShowingMappins = true;
            this.m_canShowMappinsByTask = false;
            this.m_canHideMappinsByTask = false;
            currentVariant = this.GetCurrentMappinVariant(this.m_mappins[i].gameplayRole);
            if NotEquals(currentVariant, this.m_mappins[i].mappinVariant) {
              this.m_mappins[i].mappinVariant = currentVariant;
              shouldUpdate = true;
              shouldUpdateVariant = true;
            };
            visualData = this.CreateRoleMappinData(this.m_mappins[i]);
            if !shouldUpdate && !this.CompareRoleMappinsData(visualData, this.m_mappins[i].visualStateData) {
              shouldUpdate = true;
            };
            if NotEquals(this.m_mappins[i].id, invalidID) && shouldUpdate {
              this.UpdateSingleMappinData(i, visualData, shouldUpdateVariant);
              return;
            };
            if Equals(this.m_mappins[i].id, invalidID) {
              this.ShowSingleMappin(i);
            } else {
              if NotEquals(this.m_mappins[i].id, invalidID) {
                this.ActivateSingleMappin(i);
              };
            };
            i += 1;
          };
        };
      };
    };
  }

  private final func CreateRoleMappinData(data: SDeviceMappinData) -> ref<GameplayRoleMappinData> {
    let showOnMiniMap: Bool;
    let roleMappinData: ref<GameplayRoleMappinData> = new GameplayRoleMappinData();
    roleMappinData.m_mappinVisualState = this.GetOwner().DeterminGameplayRoleMappinVisuaState(data);
    roleMappinData.m_isTagged = this.GetOwner().IsTaggedinFocusMode();
    roleMappinData.m_isQuest = this.GetOwner().IsQuest() || this.GetOwner().IsAnyClueEnabled() && !this.GetOwner().IsClueInspected();
    roleMappinData.m_visibleThroughWalls = this.m_isForcedVisibleThroughWalls || this.GetOwner().IsObjectRevealed() || this.IsCurrentTarget();
    roleMappinData.m_range = this.GetOwner().DeterminGameplayRoleMappinRange(data);
    roleMappinData.m_isCurrentTarget = this.IsCurrentTarget();
    roleMappinData.m_gameplayRole = this.m_currentGameplayRole;
    roleMappinData.m_braindanceLayer = this.GetOwner().GetBraindanceLayer();
    roleMappinData.m_quality = this.GetOwner().GetLootQuality();
    roleMappinData.m_isIconic = this.GetOwner().GetIsIconic();
    roleMappinData.m_hasOffscreenArrow = this.HasOffscreenArrow();
    roleMappinData.m_isScanningCluesBlocked = this.GetOwner().IsAnyClueEnabled() && this.GetOwner().IsScaningCluesBlocked();
    roleMappinData.m_textureID = this.GetIconIdForMappinVariant(data.mappinVariant);
    if roleMappinData.m_isQuest && roleMappinData.m_textureID != t"MappinIcons.ShardMappin" || roleMappinData.m_isTagged {
      showOnMiniMap = true;
    } else {
      if NotEquals(data.mappinVariant, gamedataMappinVariant.LootVariant) && (roleMappinData.m_isCurrentTarget || roleMappinData.m_visibleThroughWalls) {
        showOnMiniMap = true;
      } else {
        showOnMiniMap = false;
      };
    };
    roleMappinData.m_showOnMiniMap = showOnMiniMap;
    return roleMappinData;
  }

  private final func CompareRoleMappinsData(data1: ref<GameplayRoleMappinData>, data2: ref<GameplayRoleMappinData>) -> Bool {
    if data1 == null && data2 != null {
      return false;
    };
    if data1 != null && data2 == null {
      return false;
    };
    if NotEquals(data1.m_isTagged, data2.m_isTagged) {
      return false;
    };
    if NotEquals(data1.m_mappinVisualState, data2.m_mappinVisualState) {
      return false;
    };
    if NotEquals(data1.m_visibleThroughWalls, data2.m_visibleThroughWalls) {
      return false;
    };
    if NotEquals(data1.m_isCurrentTarget, data2.m_isCurrentTarget) {
      return false;
    };
    if NotEquals(data1.m_isQuest, data2.m_isQuest) {
      return false;
    };
    if NotEquals(data1.m_isIconic, data2.m_isIconic) {
      return false;
    };
    if data1.m_textureID != data2.m_textureID {
      return false;
    };
    if NotEquals(data1.m_quality, data2.m_quality) {
      return false;
    };
    if NotEquals(data1.m_isScanningCluesBlocked, data2.m_isScanningCluesBlocked) {
      return false;
    };
    if NotEquals(data1.m_gameplayRole, data2.m_gameplayRole) {
      return false;
    };
    if NotEquals(data1.m_braindanceLayer, data2.m_braindanceLayer) {
      return false;
    };
    if NotEquals(data1.m_showOnMiniMap, data2.m_showOnMiniMap) {
      return false;
    };
    return true;
  }

  private final func GetIconIdForMappinVariant(mappinVariant: gamedataMappinVariant) -> TweakDBID {
    let id: TweakDBID;
    if Equals(mappinVariant, gamedataMappinVariant.NPCVariant) {
      id = t"MappinIcons.NPCMappin";
    } else {
      if Equals(mappinVariant, gamedataMappinVariant.FastTravelVariant) {
        id = t"MappinIcons.FastTravelMappin";
      } else {
        if Equals(mappinVariant, gamedataMappinVariant.DistractVariant) {
          id = t"MappinIcons.DistractMappin";
        } else {
          if Equals(mappinVariant, gamedataMappinVariant.LootVariant) {
            if this.GetOwner().IsShardContainer() {
              id = t"MappinIcons.ShardMappin";
            } else {
              if this.GetOwner().IsQuest() {
                id = t"MappinIcons.QuestMappin";
              } else {
                id = t"MappinIcons.LootMappin";
              };
            };
          } else {
            if Equals(mappinVariant, gamedataMappinVariant.EffectExplodeLethalVariant) {
              id = t"MappinIcons.ExplosiveDevice";
            } else {
              if Equals(mappinVariant, gamedataMappinVariant.EffectDropPointVariant) {
                id = t"MappinIcons.DropPointMappin";
              } else {
                if Equals(mappinVariant, gamedataMappinVariant.FocusClueVariant) {
                  id = t"MappinIcons.ClueMappin";
                } else {
                  if Equals(mappinVariant, gamedataMappinVariant.PhoneCallVariant) {
                    id = t"MappinIcons.PhoneCallMappin";
                  } else {
                    if Equals(mappinVariant, gamedataMappinVariant.EffectControlNetworkVariant) {
                      id = t"MappinIcons.BackdoorDeviceMappin";
                    } else {
                      if Equals(mappinVariant, gamedataMappinVariant.EffectControlOtherDeviceVariant) {
                        id = t"MappinIcons.ControlPanleDeviceMappin";
                      } else {
                        if Equals(mappinVariant, gamedataMappinVariant.NetrunnerVariant) {
                          id = t"MappinIcons.EnemyNetrunnerMappin";
                        } else {
                          if Equals(mappinVariant, gamedataMappinVariant.EffectHideBodyVariant) {
                            id = t"MappinIcons.HideBodyMappin";
                          } else {
                            if Equals(mappinVariant, gamedataMappinVariant.ImportantInteractionVariant) {
                              if this.GetOwner().IsQuickHackAble() {
                                id = t"MappinIcons.HackableDeviceMappin";
                              } else {
                                id = t"MappinIcons.InteractiveDeviceMappin";
                              };
                            } else {
                              if Equals(mappinVariant, gamedataMappinVariant.GenericRoleVariant) {
                                id = t"MappinIcons.GenericDeviceMappin";
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    return id;
  }

  public final func HideRoleMappins() -> Void {
    let invalidID: NewMappinID;
    this.m_isShowingMappins = false;
    this.m_canShowMappinsByTask = false;
    this.m_canHideMappinsByTask = false;
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].gameplayRole, IntEnum(1l)) && Equals(this.m_mappins[i].gameplayRole, EGameplayRole.UnAssigned) {
      } else {
        if this.m_mappins[i].permanent && this.m_mappins[i].active {
        } else {
          if this.m_mappins[i].active || !this.m_mappins[i].active && NotEquals(this.m_mappins[i].id, invalidID) {
            this.DeactivateSingleMappin(i);
          };
        };
      };
      i += 1;
    };
  }

  private final func ClearAllRoleMappins() -> Void {
    this.m_canShowMappinsByTask = false;
    this.m_canHideMappinsByTask = false;
    let i: Int32 = ArraySize(this.m_mappins) - 1;
    while i >= 0 {
      if NotEquals(this.m_mappins[i].gameplayRole, IntEnum(1l)) && NotEquals(this.m_mappins[i].gameplayRole, EGameplayRole.UnAssigned) {
        if this.m_mappins[i].active {
          this.HideSingleMappin(i);
        };
        ArrayErase(this.m_mappins, i);
      };
      i -= 1;
    };
  }

  public final func UnregisterAllRoleMappins() -> Void {
    this.m_isShowingMappins = false;
    this.m_canShowMappinsByTask = false;
    this.m_canHideMappinsByTask = false;
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].gameplayRole, IntEnum(1l)) || Equals(this.m_mappins[i].gameplayRole, EGameplayRole.UnAssigned) {
      } else {
        if this.m_mappins[i].active {
          this.HideSingleMappin(i);
        };
      };
      i += 1;
    };
  }

  protected cb func OnUnregisterAllMappinsEvent(evt: ref<UnregisterAllMappinsEvent>) -> Bool {
    this.UnregisterAllMappins();
  }

  public final func UnregisterAllMappins() -> Void {
    let invalidID: NewMappinID;
    this.m_isShowingMappins = false;
    this.m_canShowMappinsByTask = false;
    this.m_canHideMappinsByTask = false;
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if this.m_mappins[i].active || NotEquals(this.m_mappins[i].id, invalidID) {
        this.HideSingleMappin(i);
      };
      i += 1;
    };
  }

  private final func HideSingleMappin_Event(index: Int32) -> Void {
    let evt: ref<HideSingleMappinEvent> = new HideSingleMappinEvent();
    evt.index = index;
    this.QueueEntityEvent(evt);
  }

  private final func HideSingleMappin(index: Int32) -> Void {
    let invalidID: NewMappinID;
    this.GetMappinSystem().UnregisterMappin(this.m_mappins[index].id);
    this.m_mappins[index].id = invalidID;
    this.m_mappins[index].active = false;
    if !IsFinal() {
      LogDevices(this.GetOwner(), "MAPPIN " + ToString(this.m_mappins[index].gameplayRole) + " HIDDEN");
    };
  }

  private final func DeactivateSingleMappin(index: Int32) -> Void {
    this.m_mappins[index].active = false;
    this.GetMappinSystem().SetMappinActive(this.m_mappins[index].id, false);
    if !IsFinal() {
      LogDevices(this.GetOwner(), "MAPPIN " + ToString(this.m_mappins[index].gameplayRole) + " HIDDEN");
    };
  }

  private final func ShowSingleMappin_Event(index: Int32) -> Void {
    let evt: ref<ShowSingleMappinEvent>;
    if index < 0 || index > ArraySize(this.m_mappins) - 1 {
      return;
    };
    this.m_mappins[index].active = true;
    evt = new ShowSingleMappinEvent();
    evt.index = index;
    this.QueueEntityEvent(evt);
  }

  private final func ShowSingleMappin(index: Int32, visualData: ref<GameplayRoleMappinData>) -> Void {
    let mappinData: MappinData;
    let slotname: CName;
    if index < 0 || index > ArraySize(this.m_mappins) - 1 {
      return;
    };
    mappinData.mappinType = this.m_mappins[index].mappinType;
    mappinData.variant = this.m_mappins[index].mappinVariant;
    mappinData.active = true;
    mappinData.debugCaption = this.m_mappins[index].caption;
    mappinData.scriptData = visualData;
    mappinData.visibleThroughWalls = visualData.m_visibleThroughWalls;
    this.m_mappins[index].active = true;
    this.m_mappins[index].visualStateData = visualData;
    if this.IsMappinDynamic() {
      if Equals(this.m_mappins[index].mappinVariant, gamedataMappinVariant.PhoneCallVariant) {
        slotname = this.GetOwner().GetPhoneCallIndicatorSlotName();
      } else {
        if Equals(this.m_mappins[index].mappinVariant, gamedataMappinVariant.QuickHackVariant) {
          slotname = this.GetOwner().GetQuickHackIndicatorSlotName();
        } else {
          slotname = this.GetOwner().GetRoleMappinSlotName();
        };
      };
      if IsNameValid(slotname) {
        this.m_mappins[index].id = this.GetMappinSystem().RegisterMappinWithObject(mappinData, this.GetOwner(), slotname);
      } else {
        this.m_mappins[index].id = this.GetMappinSystem().RegisterMappin(mappinData, this.m_mappins[index].position);
      };
    } else {
      this.m_mappins[index].id = this.GetMappinSystem().RegisterMappin(mappinData, this.m_mappins[index].position);
    };
    this.GetMappinSystem().SetMappinActive(this.m_mappins[index].id, true);
    if !IsFinal() {
      LogDevices(this.GetOwner(), "MAPPIN " + ToString(this.m_mappins[index].gameplayRole) + " SHOWN");
    };
  }

  private final func ShowSingleMappin(index: Int32) -> Void {
    let mappinData: MappinData;
    let slotname: CName;
    let visualData: ref<GameplayRoleMappinData>;
    let worldOffset: Vector3;
    if index < 0 || index > ArraySize(this.m_mappins) - 1 {
      return;
    };
    visualData = this.CreateRoleMappinData(this.m_mappins[index]);
    mappinData.mappinType = this.m_mappins[index].mappinType;
    mappinData.variant = this.m_mappins[index].mappinVariant;
    mappinData.active = true;
    mappinData.debugCaption = this.m_mappins[index].caption;
    mappinData.scriptData = visualData;
    mappinData.visibleThroughWalls = visualData.m_visibleThroughWalls;
    this.m_mappins[index].active = true;
    this.m_mappins[index].visualStateData = visualData;
    if this.IsMappinDynamic() {
      if Equals(this.m_mappins[index].mappinVariant, gamedataMappinVariant.PhoneCallVariant) {
        slotname = this.GetOwner().GetPhoneCallIndicatorSlotName();
      } else {
        if Equals(this.m_mappins[index].mappinVariant, gamedataMappinVariant.QuickHackVariant) {
          slotname = this.GetOwner().GetQuickHackIndicatorSlotName();
        } else {
          slotname = this.GetOwner().GetRoleMappinSlotName();
        };
      };
      if Equals(this.m_mappins[index].mappinVariant, gamedataMappinVariant.LootVariant) && this.GetOwner().IsNPC() {
        worldOffset = new Vector3(0.00, 0.00, 0.16);
      };
      this.m_mappins[index].id = this.GetMappinSystem().RegisterMappinWithObject(mappinData, this.GetOwner(), slotname, worldOffset);
    } else {
      this.m_mappins[index].id = this.GetMappinSystem().RegisterMappin(mappinData, this.m_mappins[index].position);
    };
    this.GetMappinSystem().SetMappinActive(this.m_mappins[index].id, true);
    if !IsFinal() {
      LogDevices(this.GetOwner(), "MAPPIN " + ToString(this.m_mappins[index].gameplayRole) + " SHOWN");
    };
  }

  private final func UpdateSingleMappinData(index: Int32, visualData: ref<GameplayRoleMappinData>, shouldUpdateVariant: Bool) -> Void {
    if index < 0 || index > ArraySize(this.m_mappins) - 1 {
      return;
    };
    if shouldUpdateVariant {
      this.HideSingleMappin(index);
      this.ShowSingleMappin(index, visualData);
      return;
    };
    this.m_mappins[index].visualStateData = visualData;
    this.GetMappinSystem().SetMappinScriptData(this.m_mappins[index].id, visualData);
  }

  private final func ActivateSingleMappin(index: Int32) -> Void {
    this.m_mappins[index].active = true;
    this.GetMappinSystem().SetMappinActive(this.m_mappins[index].id, true);
    if !IsFinal() {
      LogDevices(this.GetOwner(), "MAPPIN " + ToString(this.m_mappins[index].gameplayRole) + " HIDDEN");
    };
  }

  public final const func HasActiveMappin(mappinVariant: gamedataMappinVariant) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, mappinVariant) && this.m_mappins[i].active {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final const func HasMappin(mappinVariant: gamedataMappinVariant) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, mappinVariant) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final const func HasMappin(data: SDeviceMappinData) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, data.mappinVariant) && this.m_mappins[i].mappinType == data.mappinType && Equals(this.m_mappins[i].caption, data.caption) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final const func HasMappin(gameplayRole: EGameplayRole) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].gameplayRole, gameplayRole) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsMappinDataValid(mappinData: SDeviceMappinData) -> Bool {
    if NotEquals(mappinData.mappinVariant, gamedataMappinVariant.Invalid) && TDBID.IsValid(mappinData.mappinType) {
      return true;
    };
    return false;
  }

  private final func IsMappinDynamic() -> Bool {
    return this.m_alwaysCreateMappinAsDynamic || this.GetOwner().IsNetworkLinkDynamic();
  }

  private final const func IsCurrentTarget() -> Bool {
    return this.m_isBeingScanned || this.m_isCurrentTarget;
  }

  public final func ToggleMappin(mappinVariant: gamedataMappinVariant, enable: Bool, show: Bool, visualData: ref<GameplayRoleMappinData>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, mappinVariant) {
        this.m_mappins[i].enabled = enable;
        if !enable {
          if this.m_mappins[i].active {
            this.HideSingleMappin(i);
          };
        } else {
          if show && !this.m_mappins[i].active {
            this.EvaluatePositions();
            this.ShowSingleMappin(i, visualData);
          };
        };
      };
      i += 1;
    };
  }

  public final func ToggleMappin(mappinVariant: gamedataMappinVariant, enable: Bool, show: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, mappinVariant) {
        this.m_mappins[i].enabled = enable;
        if !enable {
          if this.m_mappins[i].active {
            this.HideSingleMappin(i);
          };
        } else {
          if show && !this.m_mappins[i].active {
            this.EvaluatePositions();
            this.ShowSingleMappin(i);
          };
        };
      };
      i += 1;
    };
  }

  public final func ToggleMappin(mappinVariant: gamedataMappinVariant, enable: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_mappins) {
      if Equals(this.m_mappins[i].mappinVariant, mappinVariant) {
        this.m_mappins[i].enabled = enable;
        if !enable {
          if this.m_mappins[i].active {
            this.HideSingleMappin(i);
          };
        };
      };
      i += 1;
    };
  }

  public final func ToggleMappin(mappinIndex: Int32, enable: Bool) -> Void {
    if mappinIndex > ArraySize(this.m_mappins) {
      return;
    };
    this.m_mappins[mappinIndex].enabled = enable;
    if !enable {
      if this.m_mappins[mappinIndex].active {
        this.HideSingleMappin(mappinIndex);
      };
    };
  }

  public final func AddMappin(data: SDeviceMappinData) -> Bool {
    if this.IsMappinDataValid(data) && !this.HasMappin(data) {
      ArrayPush(this.m_mappins, data);
      return true;
    };
    return false;
  }

  public final const func GetCurrentGameplayRole() -> EGameplayRole {
    return this.m_currentGameplayRole;
  }

  public final const func IsGameplayRoleStatic() -> Bool {
    return NotEquals(this.m_gameplayRole, EGameplayRole.UnAssigned);
  }

  protected final func UpdateDefaultHighlight() -> Void {
    let updateHighlightEvt: ref<ForceUpdateDefaultHighlightEvent> = new ForceUpdateDefaultHighlightEvent();
    this.GetOwner().QueueEvent(updateHighlightEvt);
  }

  private final func IsForceHidden() -> Bool {
    return this.m_isForceHidden;
  }

  private final func SetForceHidden(isHidden: Bool) -> Void {
    this.m_isForceHidden = isHidden;
    if isHidden {
      this.HideRoleMappins();
    } else {
      this.RequestHUDRefresh();
    };
  }

  protected cb func OnToggleGameplayMappinVisibilityEvent(evt: ref<ToggleGameplayMappinVisibilityEvent>) -> Bool {
    this.SetForceHidden(evt.isHidden);
  }

  private final func RequestHUDRefresh() -> Void {
    let hudManager: ref<HUDManager>;
    let modules: array<wref<HUDModule>>;
    let request: ref<RefreshActorRequest>;
    let owner: ref<GameObject> = this.GetOwner();
    if IsDefined(owner) {
      hudManager = owner.GetHudManager();
    };
    if !IsDefined(hudManager) {
      return;
    };
    ArrayPush(modules, hudManager.GetIconsModule());
    request = RefreshActorRequest.Construct(owner.GetEntityID(), modules);
    hudManager.QueueRequest(request);
  }
}
