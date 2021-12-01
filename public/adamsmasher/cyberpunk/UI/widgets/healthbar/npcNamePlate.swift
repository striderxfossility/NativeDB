
public native class NpcNameplateGameController extends inkProjectedHUDGameController {

  private native let projection: inkWidgetRef;

  private edit let m_displayName: inkWidgetRef;

  private edit let m_iconHolder: inkWidgetRef;

  private edit let m_mappinSlot: inkWidgetRef;

  private edit let m_chattersSlot: inkWidgetRef;

  private let m_rootWidget: wref<inkCompoundWidget>;

  private let m_visualController: wref<NameplateVisualsLogicController>;

  private let m_cachedMappinControllers: array<wref<BaseMappinBaseController>>;

  @default(NpcNameplateGameController, false)
  private let m_visualControllerNeedsMappinsUpdate: Bool;

  private let m_nameplateProjection: ref<inkScreenProjection>;

  private let m_nameplateProjectionCloseDistance: ref<inkScreenProjection>;

  private let m_nameplateProjectionDevice: ref<inkScreenProjection>;

  private let m_nameplateProjectionDeviceCloseDistance: ref<inkScreenProjection>;

  private let m_bufferedGameObject: wref<GameObject>;

  private let m_bufferedPuppetHideNameTag: Bool;

  private let m_bufferedCharacterNamePlateRecord: ref<UINameplate_Record>;

  private let m_isScanning: Bool;

  private let m_isNewNPC: Bool;

  private let m_attitude: EAIAttitude;

  public let m_UI_NameplateDataDef: ref<UI_NameplateDataDef>;

  @default(NpcNameplateGameController, 1)
  private let m_zoom: Float;

  @default(NpcNameplateGameController, 100)
  private let m_currentHealth: Int32;

  @default(NpcNameplateGameController, 100)
  private let m_maximumHealth: Int32;

  private let c_DisplayRange: Float;

  private let c_MaxDisplayRange: Float;

  private let c_MaxDisplayRangeNotAggressive: Float;

  private let c_DisplayRangeNotAggressive: Float;

  private let m_bbNameplateData: ref<CallbackHandle>;

  private let m_bbBuffsList: ref<CallbackHandle>;

  private let m_bbDebuffsList: ref<CallbackHandle>;

  private let m_bbHighLevelStateID: ref<CallbackHandle>;

  private let m_bbNPCNamesEnabledID: ref<CallbackHandle>;

  private let m_VisionStateBlackboardId: ref<CallbackHandle>;

  private let m_ZoomStateBlackboardId: ref<CallbackHandle>;

  private let m_playerZonesBlackboardID: ref<CallbackHandle>;

  private let m_playerCombatBlackboardID: ref<CallbackHandle>;

  private let m_playerAimStatusBlackboardID: ref<CallbackHandle>;

  private let m_damagePreviewBlackboardID: ref<CallbackHandle>;

  private let m_uiBlackboardTargetNPC: wref<IBlackboard>;

  private let m_uiBlackboardInteractions: wref<IBlackboard>;

  private let m_interfaceOptionsBlackboard: wref<IBlackboard>;

  private let m_uiBlackboardNameplateBlackboard: wref<IBlackboard>;

  private let m_nextDistanceCheckTime: Float;

  private final native func GetNameplateVisible() -> Bool;

  private final native func SetNameplateVisible(visible: Bool) -> Void;

  private final native func SlotWidget(widgetToSlot: wref<inkWidget>, newParentWidget: wref<inkWidget>, opt index: Int32) -> Void;

  private final native func UnslotWidget(widgetToUnslot: wref<inkWidget>) -> Void;

  private final native func IsWidgetSlotted(widget: wref<inkWidget>) -> Bool;

  private final native func SetSlottedWidgets(widgetsToSlot: array<ref<inkWidget>>, newParentWidger: wref<inkWidget>) -> Void;

  private final native func ClearSlottedWidgets() -> Void;

  protected cb func OnInitialize() -> Bool {
    let nameplateProjectionData: inkScreenProjectionData;
    let playerPuppet: ref<PlayerPuppet>;
    this.c_DisplayRange = SNameplateRangesData.GetDisplayRange();
    this.c_MaxDisplayRange = SNameplateRangesData.GetMaxDisplayRange();
    this.c_DisplayRangeNotAggressive = SNameplateRangesData.GetDisplayRangeNotAggressive();
    this.c_MaxDisplayRangeNotAggressive = SNameplateRangesData.GetMaxDisplayRangeNotAggressive();
    this.m_uiBlackboardTargetNPC = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair);
    this.m_bbNameplateData = this.m_uiBlackboardTargetNPC.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair.NameplateData, this, n"OnNameplateDataChanged");
    this.m_uiBlackboardInteractions = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
    this.m_rootWidget = this.GetRootWidget() as inkCompoundWidget;
    this.m_visualController = inkWidgetRef.GetController(this.projection) as NameplateVisualsLogicController;
    this.m_interfaceOptionsBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_InterfaceOptions);
    this.m_UI_NameplateDataDef = GetAllBlackboardDefs().UI_NameplateData;
    this.m_uiBlackboardNameplateBlackboard = this.GetBlackboardSystem().Get(this.m_UI_NameplateDataDef);
    this.m_bbNPCNamesEnabledID = this.m_interfaceOptionsBlackboard.RegisterDelayedListenerBool(GetAllBlackboardDefs().UI_InterfaceOptions.NPCNamesEnabled, this, n"OnNPCNamesEnabledChanged");
    this.m_visualController.UpdateNPCNamesEnabled(this.m_interfaceOptionsBlackboard.GetBool(GetAllBlackboardDefs().UI_InterfaceOptions.NPCNamesEnabled), true);
    nameplateProjectionData.fixedWorldOffset = new Vector4(0.00, 0.00, 0.82, 0.00);
    nameplateProjectionData.slotComponentName = n"UI_Slots";
    nameplateProjectionData.slotName = n"UI_Interaction";
    this.m_nameplateProjection = this.RegisterScreenProjection(nameplateProjectionData);
    nameplateProjectionData.fixedWorldOffset.Z = 0.22;
    this.m_nameplateProjectionCloseDistance = this.RegisterScreenProjection(nameplateProjectionData);
    nameplateProjectionData.fixedWorldOffset.Z = 0.60;
    nameplateProjectionData.slotName = n"Nameplate";
    this.m_nameplateProjectionDevice = this.RegisterScreenProjection(nameplateProjectionData);
    nameplateProjectionData.fixedWorldOffset.Z = 0.00;
    this.m_nameplateProjectionDeviceCloseDistance = this.RegisterScreenProjection(nameplateProjectionData);
    inkWidgetRef.SetVAlign(this.projection, inkEVerticalAlign.Top);
    playerPuppet = this.GetPlayerControlledObject() as PlayerPuppet;
    if IsDefined(playerPuppet) {
      if GameInstance.GetRuntimeInfo(playerPuppet.GetGame()).IsMultiplayer() {
        this.m_rootWidget.ChangeTranslation(new Vector2(0.00, -14.00));
      };
    };
    this.SetMainVisible(false);
    this.m_uiBlackboardNameplateBlackboard.SetBool(GetAllBlackboardDefs().UI_NameplateData.IsVisible, false, false);
    this.m_damagePreviewBlackboardID = this.m_uiBlackboardNameplateBlackboard.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_NameplateData.DamageProjection, this, n"OnDamagePreview");
    this.UpdateHealthbarColor(false);
    this.EnableSleeping(true);
    this.EnableUpdates(false);
  }

  protected final func RegisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let uiBlackboardPSM: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(uiBlackboardPSM) {
      this.m_VisionStateBlackboardId = uiBlackboardPSM.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vision, this, n"OnIsEnabledChange");
      this.m_ZoomStateBlackboardId = uiBlackboardPSM.RegisterDelayedListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this, n"OnZoomChanged");
      this.m_playerZonesBlackboardID = uiBlackboardPSM.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Zones, this, n"OnZoneChange");
      this.m_playerCombatBlackboardID = uiBlackboardPSM.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this, n"OnAimStatusChange");
      this.m_playerAimStatusBlackboardID = uiBlackboardPSM.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Combat, this, n"OnPlayerCombatChange");
      this.m_visualController.UpdatePlayerZone(IntEnum(uiBlackboardPSM.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones)), true);
      this.m_visualController.UpdatePlayerCombat(IntEnum(uiBlackboardPSM.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat)), true);
      this.m_visualController.UpdatePlayerAimStatus(IntEnum(uiBlackboardPSM.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody)), true);
    };
  }

  protected final func EnableUpdates(enable: Bool) -> Void {
    this.m_nameplateProjection.SetEnabled(enable);
    this.m_nameplateProjectionCloseDistance.SetEnabled(enable);
    this.m_nameplateProjectionDevice.SetEnabled(enable);
    this.m_nameplateProjectionDeviceCloseDistance.SetEnabled(enable);
    if enable {
      this.WakeUp();
    };
  }

  protected final func UnregisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let uiBlackboardPSM: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(uiBlackboardPSM) {
      uiBlackboardPSM.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.Vision, this.m_VisionStateBlackboardId);
      uiBlackboardPSM.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.m_ZoomStateBlackboardId);
      uiBlackboardPSM.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.Zones, this.m_playerZonesBlackboardID);
      uiBlackboardPSM.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.Combat, this.m_playerCombatBlackboardID);
      uiBlackboardPSM.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this.m_playerAimStatusBlackboardID);
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_uiBlackboardTargetNPC) {
      if IsDefined(this.m_bbNameplateData) {
        this.m_uiBlackboardTargetNPC.UnregisterDelayedListener(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair.NameplateData, this.m_bbNameplateData);
      };
      if IsDefined(this.m_bbBuffsList) {
        this.m_uiBlackboardTargetNPC.UnregisterDelayedListener(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair.BuffsList, this.m_bbBuffsList);
      };
      if IsDefined(this.m_bbDebuffsList) {
        this.m_uiBlackboardTargetNPC.UnregisterDelayedListener(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair.DebuffsList, this.m_bbDebuffsList);
      };
      if IsDefined(this.m_bbNPCNamesEnabledID) {
        this.m_interfaceOptionsBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_InterfaceOptions.NPCNamesEnabled, this.m_bbNPCNamesEnabledID);
      };
    };
    if IsDefined(this.m_uiBlackboardNameplateBlackboard) {
      if IsDefined(this.m_damagePreviewBlackboardID) {
        this.m_uiBlackboardNameplateBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_NameplateData.DamageProjection, this.m_damagePreviewBlackboardID);
      };
    };
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    this.RegisterPSMListeners(playerGameObject);
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(playerGameObject);
  }

  protected cb func OnScreenProjectionUpdate(projections: ref<gameuiScreenProjectionsData>) -> Bool {
    let data: DialogChoiceHubs;
    let invalidID: EntityID;
    let mountInfo: MountingInfo;
    let nameplateDisplayType: gamedataUINameplateDisplayType;
    let owner: wref<GameObject>;
    let targetID: EntityID;
    let time: Float;
    let isNameplateVisible: Bool = false;
    let showDisplayName: Bool = false;
    let entityJustSet: Bool = false;
    if IsDefined(this.m_bufferedGameObject) {
      time = EngineTime.ToFloat(GameInstance.GetEngineTime(this.m_bufferedGameObject.GetGame()));
      if this.m_nextDistanceCheckTime < time {
        this.m_nextDistanceCheckTime = time + 0.25;
        if this.HelperCheckDistance(this.m_bufferedGameObject) {
          entityJustSet = this.m_nameplateProjection.GetEntity() == null;
          this.SetNameplateProjectionEntity(this.m_bufferedGameObject);
        } else {
          this.SetMainVisible(false);
          this.SetNameplateProjectionEntity(null);
        };
      };
    };
    if this.m_nameplateProjection.GetEntity() != null && !entityJustSet {
      if IsDefined(this.m_bufferedGameObject) && this.m_bufferedGameObject.IsDevice() {
        this.ApplyProjectionMarginOnWidget(inkWidgetRef.Get(this.projection), new inkMargin(projections.data[2].currentPosition.X, this.ComputeTopMargin(projections.data[3].currentPosition.Y, projections.data[2].currentPosition.Y), 0.00, 0.00));
      } else {
        this.ApplyProjectionMarginOnWidget(inkWidgetRef.Get(this.projection), new inkMargin(projections.data[0].currentPosition.X, this.ComputeTopMargin(projections.data[1].currentPosition.Y, projections.data[0].currentPosition.Y), 0.00, 0.00));
      };
      if IsDefined(this.m_bufferedGameObject) {
        targetID = this.GetHUDManager().GetCurrentTargetID();
        if targetID != new EntityID() && targetID != this.m_bufferedGameObject.GetEntityID() {
          isNameplateVisible = true;
        } else {
          isNameplateVisible = !this.m_bufferedPuppetHideNameTag;
        };
        mountInfo = GameInstance.GetMountingFacility(this.m_bufferedGameObject.GetGame()).GetMountingInfoSingleWithIds(this.m_bufferedGameObject.GetEntityID());
        if EntityID.IsDefined(mountInfo.parentId) {
          isNameplateVisible = false;
        };
        if isNameplateVisible {
          if this.m_bufferedCharacterNamePlateRecord != null && this.m_bufferedCharacterNamePlateRecord.Enabled() {
            nameplateDisplayType = this.m_bufferedCharacterNamePlateRecord.Type().Type();
            switch nameplateDisplayType {
              case gamedataUINameplateDisplayType.Always:
                showDisplayName = true;
                break;
              case gamedataUINameplateDisplayType.AfterScan:
                showDisplayName = this.m_bufferedGameObject.IsScanned();
                break;
              default:
                showDisplayName = false;
            };
          };
        };
      };
      owner = this.GetOwnerEntity() as GameObject;
      data = FromVariant(this.m_uiBlackboardInteractions.GetVariant(GetAllBlackboardDefs().UIInteractions.DialogChoiceHubs));
      if ArraySize(data.choiceHubs) > 0 || GameInstance.GetSceneSystem(owner.GetGame()).GetScriptInterface().IsRewindableSectionActive() {
        isNameplateVisible = false;
      };
      if isNameplateVisible {
        isNameplateVisible = this.m_visualController.IsAnyElementVisible();
      };
      this.SetMainVisible(isNameplateVisible);
      inkWidgetRef.SetVisible(this.m_displayName, showDisplayName);
    };
    if IsDefined(projections.data[0]) && IsDefined(projections.data[0].GetEntity()) {
      this.m_uiBlackboardNameplateBlackboard.SetVariant(this.m_UI_NameplateDataDef.EntityID, ToVariant(projections.data[0].GetEntity().GetEntityID()), false);
    } else {
      this.m_uiBlackboardNameplateBlackboard.SetVariant(this.m_UI_NameplateDataDef.EntityID, ToVariant(invalidID), false);
    };
    this.m_uiBlackboardNameplateBlackboard.SetBool(this.m_UI_NameplateDataDef.IsVisible, this.GetNameplateVisible(), false);
  }

  protected cb func OnZoomChanged(value: Float) -> Bool {
    this.m_zoom = MaxF(1.00, value);
  }

  protected cb func OnNameplateDataChanged(value: Variant) -> Bool {
    let charRecord: ref<Character_Record>;
    let invalidID: EntityID;
    let nameplateBlackboard: ref<UI_NameplateDataDef>;
    let playerPuppet: ref<PlayerPuppet>;
    let puppetNPC: wref<NPCPuppet>;
    let requestStatsEvent: ref<RequestStats>;
    let incomingData: NPCNextToTheCrosshair = FromVariant(value);
    this.m_attitude = incomingData.attitude;
    if this.m_bufferedGameObject != incomingData.npc {
      this.m_isNewNPC = true;
      this.m_bufferedGameObject = incomingData.npc;
      if IsDefined(this.m_bufferedGameObject) {
        this.EnableUpdates(true);
      };
      this.m_nextDistanceCheckTime = -1.00;
      puppetNPC = this.m_bufferedGameObject as NPCPuppet;
      if puppetNPC != null {
        charRecord = TweakDBInterface.GetCharacterRecord(puppetNPC.GetRecordID());
        if IsDefined(charRecord) {
          this.m_bufferedCharacterNamePlateRecord = charRecord.UiNameplate();
        } else {
          this.m_bufferedCharacterNamePlateRecord = null;
        };
        this.m_bufferedPuppetHideNameTag = puppetNPC.GetBoolFromCharacterTweak("hide_nametag");
      } else {
        this.m_bufferedCharacterNamePlateRecord = null;
        this.m_bufferedPuppetHideNameTag = false;
      };
      this.SetNameplateProjectionEntity(this.m_bufferedGameObject);
    };
    if incomingData.npc == null {
      this.EnableUpdates(false);
      this.SetMainVisible(false);
      this.SetNameplateProjectionEntity(null);
      this.m_uiBlackboardNameplateBlackboard.SetVariant(this.m_UI_NameplateDataDef.EntityID, ToVariant(invalidID), false);
      this.m_uiBlackboardNameplateBlackboard.SetBool(this.m_UI_NameplateDataDef.IsVisible, false, false);
    } else {
      if this.m_visualControllerNeedsMappinsUpdate {
        this.UpdateVisualControllerState(this.m_cachedMappinControllers);
      };
      this.m_visualController.SetVisualData(this.m_bufferedGameObject, incomingData, this.m_isNewNPC);
      this.GetBlackboardSystem().Get(nameplateBlackboard).SetFloat(this.m_UI_NameplateDataDef.HeightOffset, this.m_visualController.GetHeightOffser(), true);
    };
    this.m_visualControllerNeedsMappinsUpdate = false;
    playerPuppet = this.GetPlayerControlledObject() as PlayerPuppet;
    requestStatsEvent = new RequestStats();
    playerPuppet.QueueEvent(requestStatsEvent);
  }

  protected cb func OnIsEnabledChange(val: Int32) -> Bool {
    if val == EnumInt(gamePSMVision.Default) {
      this.m_isScanning = false;
    } else {
      if val == EnumInt(gamePSMVision.Focus) {
        this.m_isScanning = true;
      };
    };
  }

  protected cb func OnZoneChange(value: Int32) -> Bool {
    this.m_visualController.UpdatePlayerZone(IntEnum(value));
  }

  protected cb func OnAimStatusChange(value: Int32) -> Bool {
    this.m_visualController.UpdatePlayerAimStatus(IntEnum(value));
  }

  protected cb func OnPlayerCombatChange(value: Int32) -> Bool {
    this.m_visualController.UpdatePlayerCombat(IntEnum(value));
  }

  protected cb func OnBuffListChanged(value: Variant) -> Bool {
    this.m_visualController.UpdateBuffDebuffList(value, true);
  }

  protected cb func OnDeBuffListChanged(value: Variant) -> Bool {
    this.m_visualController.UpdateBuffDebuffList(value, false);
  }

  protected cb func OnDamagePreview(value: Int32) -> Bool {
    this.m_visualController.PreviewDamage(value);
  }

  protected cb func OnNPCNamesEnabledChanged(value: Bool) -> Bool {
    this.m_visualController.UpdateNPCNamesEnabled(value);
  }

  public final func UpdateHealthbarColor(isHostile: Bool) -> Void {
    this.m_visualController.UpdateHealthbarColor(isHostile);
  }

  public final func UpdateMappinSlotMargin(newBottomMargin: Float) -> Void {
    inkWidgetRef.SetMargin(this.m_mappinSlot, 0.00, 0.00, 0.00, newBottomMargin);
  }

  protected cb func OnMappinsUpdated(mappinControllers: array<wref<BaseMappinBaseController>>) -> Bool {
    this.m_cachedMappinControllers = mappinControllers;
    this.m_visualControllerNeedsMappinsUpdate = true;
  }

  protected final func ResolveSlotAttachment() -> Void {
    this.UpdateSlotAttachment(this.m_cachedMappinControllers);
  }

  private final func UpdateVisualControllerState(mappinControllers: array<wref<BaseMappinBaseController>>) -> Void {
    let controller: wref<BaseMappinBaseController>;
    let count: Int32;
    let i: Int32;
    let mappin: wref<IMappin>;
    let profile: wref<MappinUIRuntimeProfile_Record>;
    this.m_visualController.SetQuestTarget(false);
    this.m_visualController.SetForceHide(false);
    count = ArraySize(mappinControllers);
    i = 0;
    while i < count {
      controller = mappinControllers[i];
      mappin = controller.GetMappin();
      profile = controller.GetProfile();
      if IsDefined(mappin) {
        if mappin.IsQuestImportant() {
          this.m_visualController.SetQuestTarget(true);
        };
      };
      if IsDefined(profile) {
        if !profile.KeepNameplate() {
          this.m_visualController.SetForceHide(true);
        };
      };
      i += 1;
    };
  }

  private final func UpdateSlotAttachment(mappinControllers: array<wref<BaseMappinBaseController>>) -> Void {
    let attachmentWidget: wref<inkWidget>;
    let count: Int32;
    let i: Int32;
    let widgetsToSlot: array<ref<inkWidget>>;
    if this.GetNameplateVisible() {
      count = ArraySize(mappinControllers);
      i = 0;
      while i < count {
        attachmentWidget = mappinControllers[i].GetWidgetForNameplateSlot();
        if IsDefined(attachmentWidget) {
          ArrayPush(widgetsToSlot, attachmentWidget);
        };
        i += 1;
      };
      this.SetSlottedWidgets(widgetsToSlot, inkWidgetRef.Get(this.m_mappinSlot));
    } else {
      this.ClearSlottedWidgets();
    };
  }

  private final func SetMainVisible(visible: Bool) -> Void {
    let wasVisible: Bool = this.GetNameplateVisible();
    if NotEquals(visible, wasVisible) || this.m_isNewNPC {
      this.SetNameplateVisible(visible);
      this.SetNameplateOwnerID(visible);
    };
    this.m_isNewNPC = false;
  }

  private final func SetNameplateOwnerID(visible: Bool) -> Void {
    let id: EntityID;
    if IsDefined(this.m_uiBlackboardInteractions) {
      if visible && IsDefined(this.m_bufferedGameObject) {
        id = this.m_bufferedGameObject.GetEntityID();
      };
      this.m_uiBlackboardInteractions.SetEntityID(GetAllBlackboardDefs().UIInteractions.NameplateOwnerID, id);
    };
  }

  private final func GetHUDManager() -> ref<HUDManager> {
    return GameInstance.GetScriptableSystemsContainer(this.GetPlayerControlledObject().GetGame()).Get(n"HUDManager") as HUDManager;
  }

  private final func GetDistanceToEntity(entity: ref<Entity>) -> Float {
    let distToEntity: Float = -1.00;
    let playerPuppet: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
    let puppet: wref<GameObject> = entity as GameObject;
    if IsDefined(puppet) {
      distToEntity = Vector4.Distance(playerPuppet.GetWorldPosition(), puppet.GetWorldPosition());
    };
    return distToEntity;
  }

  private final func HelperCheckDistance(entity: ref<Entity>) -> Bool {
    let displayMaxRange: Float;
    let displayRange: Float;
    let distToEntity: Float;
    let gameObject: wref<GameObject>;
    let max_dist: Float;
    let puppet: wref<ScriptedPuppet>;
    if entity == null {
      return false;
    };
    gameObject = entity as GameObject;
    puppet = entity as ScriptedPuppet;
    if IsDefined(puppet) && (Equals(this.m_attitude, EAIAttitude.AIA_Hostile) || puppet.IsAggressive() && NotEquals(this.m_attitude, EAIAttitude.AIA_Friendly)) {
      displayRange = this.c_DisplayRange;
      displayMaxRange = this.c_MaxDisplayRange;
    } else {
      if IsDefined(gameObject) && gameObject.IsTurret() && NotEquals(this.m_attitude, EAIAttitude.AIA_Friendly) {
        displayRange = this.c_DisplayRange;
        displayMaxRange = this.c_MaxDisplayRange;
      } else {
        displayRange = this.c_DisplayRangeNotAggressive;
        displayMaxRange = this.c_MaxDisplayRangeNotAggressive;
      };
    };
    distToEntity = MinF(this.GetDistanceToEntity(entity), displayMaxRange * this.m_zoom);
    max_dist = displayRange * this.m_zoom;
    if distToEntity < max_dist {
      return true;
    };
    return false;
  }

  private final func SetNameplateProjectionEntity(entity: ref<Entity>) -> Void {
    this.m_nameplateProjection.SetEntity(entity);
    this.m_nameplateProjectionDevice.SetEntity(entity);
    this.m_nameplateProjectionCloseDistance.SetEntity(entity);
    this.m_nameplateProjectionDeviceCloseDistance.SetEntity(entity);
  }

  private final func ComputeTopMargin(marginClosest: Float, marginFurthest: Float) -> Float {
    let lerpCoef: Float;
    let result: Float;
    let distance: Float = this.GetDistanceToEntity(this.m_nameplateProjection.GetEntity());
    if distance >= 50.00 {
      return marginFurthest;
    };
    lerpCoef = MinF(distance, 50.00) / 50.00;
    result = LerpF(lerpCoef, marginClosest, marginFurthest);
    return result;
  }
}

public static exec func PreviewDamage(gameInstance: GameInstance, value: String) -> Void {
  let intValue: Int32 = StringToInt(value);
  let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(gameInstance).Get(GetAllBlackboardDefs().UI_NameplateData);
  if IsDefined(blackboard) {
    blackboard.SetInt(GetAllBlackboardDefs().UI_NameplateData.DamageProjection, intValue, true);
  };
}

public struct SNameplateRangesData {

  @default(SNameplateRangesData, 35)
  private let c_DisplayRange: Float;

  @default(SNameplateRangesData, 50)
  private let c_MaxDisplayRange: Float;

  @default(SNameplateRangesData, 10)
  private let c_MaxDisplayRangeNotAggressive: Float;

  @default(SNameplateRangesData, 3)
  private let c_DisplayRangeNotAggressive: Float;

  public final static func GetDisplayRange() -> Float {
    let self: SNameplateRangesData;
    return self.c_DisplayRange;
  }

  public final static func GetMaxDisplayRange() -> Float {
    let self: SNameplateRangesData;
    return self.c_MaxDisplayRange;
  }

  public final static func GetMaxDisplayRangeNotAggressive() -> Float {
    let self: SNameplateRangesData;
    return self.c_MaxDisplayRangeNotAggressive;
  }

  public final static func GetDisplayRangeNotAggressive() -> Float {
    let self: SNameplateRangesData;
    return self.c_DisplayRangeNotAggressive;
  }
}
