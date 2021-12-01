
public class DamageDigitsGameController extends inkProjectedHUDGameController {

  @default(DamageDigitsGameController, 50)
  public edit let m_maxVisible: Int32;

  @default(DamageDigitsGameController, 10)
  public edit let m_maxAccumulatedVisible: Int32;

  private let m_realOwner: wref<GameObject>;

  private let m_digitsQueue: ref<inkFIFOQueue>;

  private let m_isBeingUsed: Bool;

  private let m_ActiveWeapon: SlotWeaponData;

  private let m_BufferedRosterData: ref<SlotDataHolder>;

  private let m_individualControllerArray: array<wref<DamageDigitLogicController>>;

  private let m_accumulatedControllerArray: array<AccumulatedDamageDigitsNode>;

  private let m_damageDigitsMode: gameuiDamageDigitsMode;

  private let m_showDigitsIndividual: Bool;

  private let m_showDigitsAccumulated: Bool;

  private let m_damageDigitsStickingMode: gameuiDamageDigitsStickingMode;

  private let m_spawnedDigits: Int32;

  private let m_spawnedAccumulatedDigitsDigits: Int32;

  private let m_damageInfoBB: wref<IBlackboard>;

  private let m_UIBlackboard: wref<IBlackboard>;

  private let m_damageListBlackboardId: ref<CallbackHandle>;

  private let m_BBWeaponListBlackboardId: ref<CallbackHandle>;

  private let m_damageDigitsModeBlackboardId: ref<CallbackHandle>;

  private let m_damageDigitsStickingModeBlackboardId: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_damageInfoBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_DamageInfo);
    this.m_damageListBlackboardId = this.m_damageInfoBB.RegisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.DamageList, this, n"OnDamageAdded");
    this.m_damageDigitsModeBlackboardId = this.m_damageInfoBB.RegisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.DigitsMode, this, n"OnDamageDigitsModeChanged");
    this.m_damageDigitsStickingModeBlackboardId = this.m_damageInfoBB.RegisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.DigitsStickingMode, this, n"OnDigitsStickingModeChanged");
    this.m_UIBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_EquipmentData);
    this.m_BBWeaponListBlackboardId = this.m_UIBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this, n"OnWeaponDataChanged");
    this.m_UIBlackboard.SignalVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData);
    this.m_damageDigitsMode = FromVariant(this.m_damageInfoBB.GetVariant(GetAllBlackboardDefs().UI_DamageInfo.DigitsMode));
    this.m_damageDigitsStickingMode = FromVariant(this.m_damageInfoBB.GetVariant(GetAllBlackboardDefs().UI_DamageInfo.DigitsStickingMode));
    this.m_realOwner = this.GetOwnerEntity() as GameObject;
    this.CreateDigitsQueue();
    this.CreateAccumulatedDamageDigitsArray();
    this.UpdateDamageDigitsMode();
    this.UpdateDamageDigitsStickingMode();
    this.SetShouldNotifyProjections(false);
    this.EnableSleeping(true);
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_damageInfoBB.UnregisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.DamageList, this.m_damageListBlackboardId);
    this.m_damageInfoBB.UnregisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.DigitsMode, this.m_damageDigitsModeBlackboardId);
    this.m_damageInfoBB.UnregisterListenerVariant(GetAllBlackboardDefs().UI_DamageInfo.DigitsStickingMode, this.m_damageDigitsStickingModeBlackboardId);
    this.m_UIBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this.m_BBWeaponListBlackboardId);
    this.m_UIBlackboard = null;
  }

  protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
    this.m_realOwner = player;
    let i: Int32 = 0;
    while i < this.m_maxAccumulatedVisible {
      this.m_accumulatedControllerArray[i].m_controller.m_owner = player;
      i += 1;
    };
  }

  private final func CreateDigitsQueue() -> Void {
    let rootWidget: wref<inkWidget> = this.GetRootWidget();
    this.m_digitsQueue = new inkFIFOQueue();
    let i: Int32 = 0;
    while i < this.m_maxVisible {
      this.AsyncSpawnFromLocal(rootWidget, n"Digit", this, n"OnDamageDigitSpawned");
      i += 1;
    };
  }

  protected cb func OnDamageDigitSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let controller: wref<DamageDigitLogicController>;
    let projection: ref<inkScreenProjection>;
    let projectionData: inkScreenProjectionData;
    if widget == null {
      this.m_maxVisible -= 1;
      return true;
    };
    controller = widget.GetController() as DamageDigitLogicController;
    projectionData.userData = controller;
    projectionData.slotComponentName = n"UI_Slots";
    projectionData.slotName = n"roleMappin";
    projection = this.RegisterScreenProjection(projectionData);
    projection.SetEnabled(false);
    controller.SetProjection(projection, this);
    controller.RegisterToCallback(n"OnReadyToRemove", this, n"OnHideDigit");
    ArrayPush(this.m_individualControllerArray, controller);
    this.m_spawnedDigits += 1;
    if this.m_spawnedDigits == this.m_maxVisible {
      this.RegisterDigitsToQueue();
    };
  }

  private final func RegisterDigitsToQueue() -> Void {
    let controllerList: array<wref<IScriptable>>;
    let i: Int32 = 0;
    while i < this.m_maxVisible {
      ArrayPush(controllerList, this.m_individualControllerArray[i]);
      i += 1;
    };
    this.m_digitsQueue.Init(controllerList);
  }

  protected cb func OnAccumulatedDamageDigitSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let projectionData: inkScreenProjectionData;
    let digitsUserData: ref<DamageDigitUserData> = userData as DamageDigitUserData;
    let index: Int32 = digitsUserData.m_controllerIndex;
    let controller: wref<AccumulatedDamageDigitLogicController> = widget.GetController() as AccumulatedDamageDigitLogicController;
    this.m_accumulatedControllerArray[index].m_controller = controller;
    this.m_accumulatedControllerArray[index].m_controller.m_arrayPosition = index;
    this.m_accumulatedControllerArray[index].m_controller.m_owner = this.GetPlayerControlledObject();
    this.m_accumulatedControllerArray[index].m_isDamageOverTime = false;
    projectionData.userData = this.m_accumulatedControllerArray[index].m_controller;
    projectionData.slotComponentName = n"UI_Slots";
    projectionData.slotName = n"roleMappin";
    let projection: ref<inkScreenProjection> = this.RegisterScreenProjection(projectionData);
    projection.SetEnabled(false);
    this.m_accumulatedControllerArray[index].m_controller.SetProjection(projection, this);
    this.m_accumulatedControllerArray[index].m_controller.RegisterToCallback(n"OnReadyToRemoveAccumulatedDigit", this, n"OnHideAccumulatedDigit");
  }

  private final func CreateAccumulatedDamageDigitsArray() -> Void {
    let i: Int32;
    let userData: ref<DamageDigitUserData>;
    let rootWidget: wref<inkWidget> = this.GetRootWidget();
    ArrayResize(this.m_accumulatedControllerArray, this.m_maxAccumulatedVisible);
    i = 0;
    while i < this.m_maxAccumulatedVisible {
      userData = new DamageDigitUserData();
      userData.m_controllerIndex = i;
      this.m_accumulatedControllerArray[i].m_used = false;
      this.AsyncSpawnFromLocal(rootWidget, n"AccumulatedDamageDigit", this, n"OnAccumulatedDamageDigitSpawned", userData);
      i += 1;
    };
  }

  private final func ShowDamageFloater(damageInfo: DamageInfo) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(damageInfo.userData.flags) {
      if Equals(damageInfo.userData.flags[i].flag, hitFlag.DontShowDamageFloater) || Equals(damageInfo.userData.flags[i].flag, hitFlag.ImmortalTarget) || Equals(damageInfo.userData.flags[i].flag, hitFlag.DealNoDamage) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  private final func IsDamageOverTime(damageInfo: DamageInfo) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(damageInfo.userData.flags) {
      if Equals(damageInfo.userData.flags[i].flag, hitFlag.DamageOverTime) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected cb func OnDamageAdded(value: Variant) -> Bool {
    let controller: wref<DamageDigitLogicController>;
    let controllerFound: Bool;
    let damageInfo: DamageInfo;
    let damageListIndividual: array<DamageInfo>;
    let damageOverTime: Bool;
    let dotControllerFound: Bool;
    let entityDamageEntryList: array<DamageEntry>;
    let entityID: EntityID;
    let entityIDList: array<EntityID>;
    let k: Int32;
    let listPosition: Int32;
    let oneInstance: Bool;
    let showingBothSecondary: Bool;
    let damageList: array<DamageInfo> = FromVariant(value);
    let showingBoth: Bool = this.m_showDigitsIndividual && this.m_showDigitsAccumulated && (Equals(this.m_damageDigitsStickingMode, IntEnum(0l)) || Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Both));
    let individualDigitsSticking: Bool = Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Individual) || Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Both);
    let accumulatedDigitsSticking: Bool = Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Accumulated) || Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Both);
    let i: Int32 = 0;
    while i < ArraySize(damageList) {
      damageInfo = damageList[i];
      if this.m_realOwner == damageInfo.instigator {
        if this.ShowDamageFloater(damageInfo) {
          damageOverTime = this.IsDamageOverTime(damageInfo);
          if this.m_showDigitsAccumulated {
            if !EntityID.IsDefined(entityID) || entityID != damageInfo.entityHit.GetEntityID() {
              entityID = damageInfo.entityHit.GetEntityID();
              listPosition = ArrayFindFirst(entityIDList, entityID);
              if listPosition == -1 {
                listPosition = ArraySize(entityIDList);
                ArrayPush(entityIDList, entityID);
                ArrayGrow(entityDamageEntryList, 1);
              };
            };
            if damageOverTime && !accumulatedDigitsSticking {
              if entityDamageEntryList[listPosition].m_hasDamageOverTimeInfo {
                entityDamageEntryList[listPosition].m_damageOverTimeInfo.damageValue += damageInfo.damageValue;
                entityDamageEntryList[listPosition].m_damageOverTimeInfo.hitPosition += damageInfo.hitPosition;
                entityDamageEntryList[listPosition].m_damageOverTimeInfo.hitPosition *= 0.50;
                entityDamageEntryList[listPosition].m_oneDotInstance = false;
              } else {
                entityDamageEntryList[listPosition].m_damageOverTimeInfo = damageInfo;
                entityDamageEntryList[listPosition].m_hasDamageOverTimeInfo = true;
                entityDamageEntryList[listPosition].m_oneDotInstance = true;
              };
            } else {
              if entityDamageEntryList[listPosition].m_hasDamageInfo {
                entityDamageEntryList[listPosition].m_damageInfo.damageValue += damageInfo.damageValue;
                entityDamageEntryList[listPosition].m_damageInfo.hitPosition += damageInfo.hitPosition;
                entityDamageEntryList[listPosition].m_damageInfo.hitPosition *= 0.50;
                entityDamageEntryList[listPosition].m_oneInstance = false;
              } else {
                entityDamageEntryList[listPosition].m_damageInfo = damageInfo;
                entityDamageEntryList[listPosition].m_hasDamageInfo = true;
                entityDamageEntryList[listPosition].m_oneInstance = true;
              };
            };
          };
          if this.m_showDigitsIndividual {
            if this.m_showDigitsAccumulated {
              ArrayPush(damageListIndividual, damageInfo);
            } else {
              controller = this.m_digitsQueue.Dequeue() as DamageDigitLogicController;
              controller.Show(damageInfo, false, damageOverTime);
            };
          };
        };
      };
      i += 1;
    };
    if this.m_showDigitsAccumulated {
      i = 0;
      while i < ArraySize(entityIDList) {
        entityID = entityIDList[i];
        controllerFound = !entityDamageEntryList[i].m_hasDamageInfo;
        dotControllerFound = !entityDamageEntryList[i].m_hasDamageOverTimeInfo;
        k = 0;
        while k < this.m_maxAccumulatedVisible {
          if this.m_accumulatedControllerArray[k].m_used && this.m_accumulatedControllerArray[k].m_entityID == entityID {
            if entityDamageEntryList[i].m_hasDamageInfo && (!this.m_accumulatedControllerArray[k].m_isDamageOverTime || accumulatedDigitsSticking) {
              if !controllerFound {
                this.m_accumulatedControllerArray[k].m_controller.UpdateDamageInfo(entityDamageEntryList[i].m_damageInfo, showingBoth);
                entityDamageEntryList[i].m_oneInstance = false;
                controllerFound = true;
              };
            } else {
              if entityDamageEntryList[i].m_hasDamageOverTimeInfo && this.m_accumulatedControllerArray[k].m_isDamageOverTime {
                if !dotControllerFound {
                  this.m_accumulatedControllerArray[k].m_controller.UpdateDamageInfo(entityDamageEntryList[i].m_damageOverTimeInfo, this.m_showDigitsIndividual);
                  entityDamageEntryList[i].m_oneDotInstance = false;
                  dotControllerFound = true;
                };
              };
            };
            if this.m_accumulatedControllerArray[k].m_isDamageOverTime {
              entityDamageEntryList[i].m_hasDotAccumulator = true;
            };
          };
          k += 1;
        };
        if !controllerFound {
          oneInstance = entityDamageEntryList[i].m_oneInstance;
          k = 0;
          while k < this.m_maxAccumulatedVisible {
            if !this.m_accumulatedControllerArray[k].m_used {
              this.m_accumulatedControllerArray[k].m_used = true;
              this.m_accumulatedControllerArray[k].m_entityID = entityID;
              this.m_accumulatedControllerArray[k].m_isDamageOverTime = false;
              this.m_accumulatedControllerArray[k].m_controller.Show(entityDamageEntryList[i].m_damageInfo, showingBoth, oneInstance, false);
            } else {
              k += 1;
            };
          };
        };
        if !dotControllerFound {
          oneInstance = entityDamageEntryList[i].m_oneDotInstance;
          k = 0;
          while k < this.m_maxAccumulatedVisible {
            if !this.m_accumulatedControllerArray[k].m_used {
              this.m_accumulatedControllerArray[k].m_used = true;
              this.m_accumulatedControllerArray[k].m_entityID = entityID;
              this.m_accumulatedControllerArray[k].m_isDamageOverTime = true;
              this.m_accumulatedControllerArray[k].m_controller.Show(entityDamageEntryList[i].m_damageOverTimeInfo, this.m_showDigitsIndividual, oneInstance, true);
              entityDamageEntryList[i].m_hasDotAccumulator = true;
            } else {
              k += 1;
            };
          };
        };
        i += 1;
      };
    };
    if this.m_showDigitsIndividual && this.m_showDigitsAccumulated {
      i = 0;
      while i < ArraySize(damageListIndividual) {
        damageInfo = damageListIndividual[i];
        damageOverTime = this.IsDamageOverTime(damageInfo);
        if i == 0 || !EntityID.IsDefined(entityID) || entityID != damageInfo.entityHit.GetEntityID() {
          entityID = damageInfo.entityHit.GetEntityID();
          listPosition = ArrayFindFirst(entityIDList, entityID);
        };
        if damageOverTime && !accumulatedDigitsSticking {
          oneInstance = entityDamageEntryList[listPosition].m_oneDotInstance;
        } else {
          oneInstance = entityDamageEntryList[listPosition].m_oneInstance;
        };
        if !oneInstance {
          if !showingBoth {
            showingBothSecondary = damageOverTime || entityDamageEntryList[listPosition].m_hasDotAccumulator && individualDigitsSticking;
          };
          controller = this.m_digitsQueue.Dequeue() as DamageDigitLogicController;
          controller.Show(damageInfo, showingBoth || showingBothSecondary, damageOverTime);
        };
        i += 1;
      };
    };
    this.WakeUp();
  }

  protected cb func OnWeaponDataChanged(value: Variant) -> Bool {
    this.m_BufferedRosterData = FromVariant(value);
    let currentData: SlotWeaponData = this.m_BufferedRosterData.weapon;
    if ItemID.IsValid(currentData.weaponID) {
      this.m_ActiveWeapon = currentData;
    };
  }

  protected cb func OnDamageDigitsModeChanged(value: Variant) -> Bool {
    this.m_damageDigitsMode = FromVariant(value);
    this.UpdateDamageDigitsMode();
  }

  private final func UpdateDamageDigitsMode() -> Void {
    if Equals(this.m_damageDigitsMode, gameuiDamageDigitsMode.Off) {
      this.m_showDigitsIndividual = false;
      this.m_showDigitsAccumulated = false;
    } else {
      if Equals(this.m_damageDigitsMode, gameuiDamageDigitsMode.Individual) {
        this.m_showDigitsIndividual = true;
        this.m_showDigitsAccumulated = false;
      } else {
        if Equals(this.m_damageDigitsMode, gameuiDamageDigitsMode.Accumulated) {
          this.m_showDigitsIndividual = false;
          this.m_showDigitsAccumulated = true;
        } else {
          if Equals(this.m_damageDigitsMode, gameuiDamageDigitsMode.Both) {
            this.m_showDigitsIndividual = true;
            this.m_showDigitsAccumulated = true;
          };
        };
      };
    };
  }

  protected cb func OnDigitsStickingModeChanged(value: Variant) -> Bool {
    this.m_damageDigitsStickingMode = FromVariant(value);
    this.UpdateDamageDigitsStickingMode();
  }

  private final func UpdateDamageDigitsStickingMode() -> Void {
    let i: Int32;
    if Equals(this.m_damageDigitsStickingMode, IntEnum(0l)) {
      i = 0;
      while i < this.m_maxVisible {
        this.m_individualControllerArray[i].m_stickToTarget = false;
        i += 1;
      };
      i = 0;
      while i < this.m_maxAccumulatedVisible {
        this.m_accumulatedControllerArray[i].m_controller.m_stickToTarget = false;
        i += 1;
      };
    } else {
      if Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Individual) {
        i = 0;
        while i < this.m_maxVisible {
          this.m_individualControllerArray[i].m_stickToTarget = true;
          i += 1;
        };
        i = 0;
        while i < this.m_maxAccumulatedVisible {
          this.m_accumulatedControllerArray[i].m_controller.m_stickToTarget = false;
          i += 1;
        };
      } else {
        if Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Accumulated) {
          i = 0;
          while i < this.m_maxVisible {
            this.m_individualControllerArray[i].m_stickToTarget = false;
            i += 1;
          };
          i = 0;
          while i < this.m_maxAccumulatedVisible {
            this.m_accumulatedControllerArray[i].m_controller.m_stickToTarget = true;
            i += 1;
          };
        } else {
          if Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Both) {
            i = 0;
            while i < this.m_maxVisible {
              this.m_individualControllerArray[i].m_stickToTarget = true;
              i += 1;
            };
            i = 0;
            while i < this.m_maxAccumulatedVisible {
              this.m_accumulatedControllerArray[i].m_controller.m_stickToTarget = true;
              i += 1;
            };
          };
        };
      };
    };
    i = 0;
    while i < this.m_maxAccumulatedVisible {
      if this.m_accumulatedControllerArray[i].m_used && this.m_accumulatedControllerArray[i].m_controller.m_currentlySticking {
        this.m_accumulatedControllerArray[i].m_isDamageOverTime = Equals(this.m_damageDigitsStickingMode, IntEnum(0l)) || Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Individual);
      };
      i += 1;
    };
  }

  protected cb func OnHideDigit(digitWidget: wref<inkWidget>) -> Bool {
    this.m_digitsQueue.Enqueue();
  }

  protected cb func OnHideAccumulatedDigit(digitWidget: wref<inkWidget>) -> Bool {
    let accumulatedDamageDigitController: wref<AccumulatedDamageDigitLogicController> = digitWidget.GetController() as AccumulatedDamageDigitLogicController;
    if IsDefined(accumulatedDamageDigitController) {
      this.m_accumulatedControllerArray[accumulatedDamageDigitController.m_arrayPosition].m_used = false;
    };
  }

  private final func IsPlayingMultiplayer() -> Bool {
    let playerPuppet: ref<PlayerPuppet> = this.m_realOwner as PlayerPuppet;
    return IsDefined(playerPuppet) && GameInstance.GetRuntimeInfo(playerPuppet.GetGame()).IsMultiplayer();
  }

  private final func IsUsingAutoWeapon() -> Bool {
    let weaponType: gamedataTriggerMode = this.m_ActiveWeapon.triggerModeCurrent;
    let pistolTweakRecord: TweakDBID = t"Items.Preset_Overture_Default";
    if ItemID.GetTDBID(this.m_ActiveWeapon.weaponID) == pistolTweakRecord {
      return false;
    };
    switch weaponType {
      case gamedataTriggerMode.FullAuto:
      case gamedataTriggerMode.SemiAuto:
        return true;
      default:
        return false;
    };
  }
}

public class DamageDigitLogicController extends inkLogicController {

  private edit let m_critWidget: inkTextRef;

  private edit let m_headshotWidget: inkTextRef;

  private let m_rootWidget: wref<inkWidget>;

  private let m_panelWidget: wref<inkWidget>;

  private let m_textWidget: wref<inkText>;

  private let m_gameController: wref<DamageDigitsGameController>;

  private let m_active: Bool;

  private let m_successful: Bool;

  private let m_successfulCritical: Bool;

  private let m_showingBothDigits: Bool;

  private let m_distanceModifier: Float;

  private let m_calculatedDistanceHeightBias: Float;

  private let m_stickingDistanceHeightBias: Float;

  public let m_stickToTarget: Bool;

  private let m_forceStickToTarget: Bool;

  private let m_projection: ref<inkScreenProjection>;

  private let m_showPositiveAnimDef: ref<inkAnimDef>;

  private let m_showPositiveAnimFadeInInterpolator: ref<inkAnimTransparency>;

  private let m_showPositiveAnimFadeOutInterpolator: ref<inkAnimTransparency>;

  private let m_showPositiveAnimMarginInterpolator: ref<inkAnimMargin>;

  private let m_showPositiveAnimScaleInterpolator: ref<inkAnimScale>;

  private let m_showNegativeAnimDef: ref<inkAnimDef>;

  private let m_showNegativeAnimFadeInInterpolator: ref<inkAnimTransparency>;

  private let m_showNegativeAnimFadeOutInterpolator: ref<inkAnimTransparency>;

  private let m_showNegativeAnimMarginInterpolator: ref<inkAnimMargin>;

  private let m_showNegativeAnimScaleInterpolator: ref<inkAnimScale>;

  private let m_animStickTargetOffset: Vector4;

  @default(DamageDigitLogicController, 0.1f)
  private const let m_animTimeFadeIn: Float;

  @default(DamageDigitLogicController, 0.4f)
  private const let m_animTimeFadeOut: Float;

  @default(DamageDigitLogicController, 0.1f)
  private const let m_animBothTimeFadeIn: Float;

  @default(DamageDigitLogicController, 0.2f)
  private const let m_animBothTimeFadeOut: Float;

  @default(DamageDigitLogicController, 0.8f)
  private const let m_animTimeDelay: Float;

  @default(DamageDigitLogicController, 1.25f)
  private const let m_animTimeCritDelay: Float;

  @default(DamageDigitLogicController, 0.5f)
  private const let m_animBothTimeDelay: Float;

  @default(DamageDigitLogicController, 0.8f)
  private const let m_animBothTimeCritDelay: Float;

  @default(DamageDigitLogicController, -30.0f)
  private const let m_animStartHeight: Float;

  @default(DamageDigitLogicController, -45.f)
  private const let m_animAngleMin1: Float;

  @default(DamageDigitLogicController, 140.f)
  private const let m_animAngleMin2: Float;

  @default(DamageDigitLogicController, 40.f)
  private const let m_animAngleMax1: Float;

  @default(DamageDigitLogicController, 225.f)
  private const let m_animAngleMax2: Float;

  @default(DamageDigitLogicController, -20.f)
  private const let m_animBothAngleMin1: Float;

  @default(DamageDigitLogicController, 140.f)
  private const let m_animBothAngleMin2: Float;

  @default(DamageDigitLogicController, 40.f)
  private const let m_animBothAngleMax1: Float;

  @default(DamageDigitLogicController, 200.f)
  private const let m_animBothAngleMax2: Float;

  @default(DamageDigitLogicController, 70.f)
  private const let m_animDistanceMin: Float;

  @default(DamageDigitLogicController, 90.f)
  private const let m_animDistanceMax: Float;

  @default(DamageDigitLogicController, 110.f)
  private const let m_animDistanceMin_Crit: Float;

  @default(DamageDigitLogicController, 140.f)
  private const let m_animDistanceMax_Crit: Float;

  @default(DamageDigitLogicController, 0.0f)
  private const let m_animBothOffsetX: Float;

  @default(DamageDigitLogicController, 0.0f)
  private const let m_animBothOffsetY: Float;

  @default(DamageDigitLogicController, -70.0f)
  private const let m_animBothStickingOffsetY: Float;

  @default(DamageDigitLogicController, 0.5f)
  private const let m_animStickTargetWorldZOffset: Float;

  @default(DamageDigitLogicController, -70.0f)
  private const let m_animStickingOffsetY: Float;

  @default(DamageDigitLogicController, 7.0f)
  private const let m_animDistanceModifierMinDistance: Float;

  @default(DamageDigitLogicController, 25.0f)
  private const let m_animDistanceModifierMaxDistance: Float;

  @default(DamageDigitLogicController, 0.6f)
  private const let m_animDistanceModifierMinValue: Float;

  @default(DamageDigitLogicController, 1.0f)
  private const let m_animDistanceModifierMaxValue: Float;

  @default(DamageDigitLogicController, 50.0f)
  private const let m_animDistanceHeightBias: Float;

  @default(DamageDigitLogicController, 70.0f)
  private const let m_animStickingDistanceHeightBias: Float;

  @default(DamageDigitLogicController, 0.95f)
  private const let m_animPositiveOpacity: Float;

  @default(DamageDigitLogicController, 0.9f)
  private const let m_animNegativeOpacity: Float;

  private let m_animDynamicDuration: Float;

  private let m_animDynamicDelay: Float;

  private let m_animDynamicCritDuration: Float;

  private let m_animDynamicCritDelay: Float;

  protected cb func OnInitialize() -> Bool {
    let strCrit: String;
    let strHead: String;
    this.m_rootWidget = this.GetRootWidget();
    this.m_panelWidget = this.GetWidget(n"panel");
    this.m_textWidget = this.GetWidget(n"panel/text_panel/text") as inkText;
    this.m_rootWidget.SetAnchorPoint(new Vector2(0.50, 0.50));
    inkWidgetRef.SetVisible(this.m_critWidget, false);
    inkWidgetRef.SetVisible(this.m_headshotWidget, false);
    strCrit = GetLocalizedText("LocKey#25999");
    inkTextRef.SetText(this.m_critWidget, strCrit);
    strHead = GetLocalizedText("LocKey#23394");
    inkTextRef.SetText(this.m_headshotWidget, strHead);
    this.m_animStickTargetOffset = new Vector4(0.00, 0.00, this.m_animStickTargetWorldZOffset, 0.00);
    this.SetActive(false);
    this.CreateShowAnimation();
  }

  protected cb func OnUninitialize() -> Bool;

  public final func SetProjection(projection: ref<inkScreenProjection>, gameController: wref<DamageDigitsGameController>) -> Void {
    this.m_projection = projection;
    this.m_gameController = gameController;
  }

  private final func SetActive(active: Bool) -> Void {
    this.m_active = active;
    this.m_rootWidget.SetVisible(active);
  }

  public final func Show(damageInfo: DamageInfo, showingBothDigits: Bool, forceStickToTarget: Bool) -> Void {
    let desiredOpacity: Float;
    let state: CName;
    this.m_forceStickToTarget = forceStickToTarget;
    this.CalculateDistanceModifier(damageInfo.instigator.GetWorldPosition(), damageInfo.entityHit.GetWorldPosition());
    this.UpdatePositionAndScale(showingBothDigits);
    this.UpdateDuration(showingBothDigits);
    if this.m_stickToTarget || this.m_forceStickToTarget {
      if damageInfo.entityHit.IsDevice() {
        this.m_projection.ResetFixedWorldOffset();
      } else {
        this.m_projection.SetFixedWorldOffset(this.m_animStickTargetOffset);
      };
      this.m_projection.SetEntity(damageInfo.entityHit);
    } else {
      this.m_projection.ResetFixedWorldOffset();
      this.m_projection.ResetEntity();
      this.m_projection.SetStaticWorldPosition(damageInfo.hitPosition);
    };
    this.m_projection.RegisterListener(this, n"OnScreenProjectionUpdate");
    this.m_projection.SetEnabled(true);
    if Cast(damageInfo.damageValue) > 0 && Equals(damageInfo.userData.hitShapeType, EHitShapeType.Flesh) {
      this.m_successful = true;
      desiredOpacity = this.m_animPositiveOpacity;
    } else {
      this.m_successful = false;
      desiredOpacity = this.m_animNegativeOpacity;
    };
    this.m_successfulCritical = Equals(damageInfo.hitType, gameuiHitType.CriticalHit) || AttackData.HasFlag(damageInfo.userData.flags, hitFlag.Headshot);
    this.m_textWidget.SetText(" " + Cast(damageInfo.damageValue));
    this.m_textWidget.SetOpacity(desiredOpacity);
    inkWidgetRef.SetOpacity(this.m_critWidget, desiredOpacity);
    inkWidgetRef.SetOpacity(this.m_headshotWidget, desiredOpacity);
    state = this.BuildStateName(damageInfo.damageType, damageInfo.hitType);
    this.m_textWidget.SetState(state);
    inkWidgetRef.SetState(this.m_critWidget, state);
    inkWidgetRef.SetState(this.m_headshotWidget, state);
    inkWidgetRef.SetVisible(this.m_critWidget, Equals(damageInfo.hitType, gameuiHitType.CriticalHit));
    inkWidgetRef.SetVisible(this.m_headshotWidget, AttackData.HasFlag(damageInfo.userData.flags, hitFlag.Headshot));
  }

  private final func CalculateDistanceModifier(fromVec: Vector4, toVec: Vector4) -> Void {
    let distance: Float = Vector4.Distance(fromVec, toVec);
    let distanceAdjusted: Float = MinF(distance, this.m_animDistanceModifierMaxDistance);
    distanceAdjusted = MaxF(distanceAdjusted - this.m_animDistanceModifierMinDistance, 0.00);
    this.m_distanceModifier = this.m_animDistanceModifierMinValue + (this.m_animDistanceModifierMaxValue - this.m_animDistanceModifierMinValue) * (1.00 - distanceAdjusted / (this.m_animDistanceModifierMaxDistance - this.m_animDistanceModifierMinDistance));
    this.m_calculatedDistanceHeightBias = (this.m_animDistanceHeightBias * (this.m_animDistanceModifierMaxValue - this.m_distanceModifier)) / (this.m_animDistanceModifierMaxValue - this.m_animDistanceModifierMinValue);
    this.m_stickingDistanceHeightBias = MinF(distance, 50.00) / 50.00 * this.m_animStickingDistanceHeightBias * this.m_distanceModifier;
  }

  private final func UpdatePositionAndScale(showingBothDigits: Bool) -> Void {
    if showingBothDigits {
      if this.m_stickToTarget || this.m_forceStickToTarget {
        this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias, 0.00, 0.00));
      } else {
        this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothOffsetY * this.m_distanceModifier + this.m_animStartHeight + this.m_calculatedDistanceHeightBias, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothOffsetY * this.m_distanceModifier + this.m_animStartHeight + this.m_calculatedDistanceHeightBias, 0.00, 0.00));
      };
    } else {
      if this.m_stickToTarget || this.m_forceStickToTarget {
        this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias, 0.00, 0.00));
      } else {
        this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStartHeight + this.m_calculatedDistanceHeightBias, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStartHeight + this.m_calculatedDistanceHeightBias, 0.00, 0.00));
      };
    };
    this.m_showPositiveAnimScaleInterpolator.SetStartScale(new Vector2(1.00 * this.m_distanceModifier, 1.00 * this.m_distanceModifier));
    this.m_showPositiveAnimScaleInterpolator.SetEndScale(new Vector2(1.00 * this.m_distanceModifier, 1.00 * this.m_distanceModifier));
    this.m_showNegativeAnimScaleInterpolator.SetStartScale(new Vector2(1.00 * this.m_distanceModifier, 1.00 * this.m_distanceModifier));
    this.m_showNegativeAnimScaleInterpolator.SetEndScale(new Vector2(1.00 * this.m_distanceModifier, 1.00 * this.m_distanceModifier));
  }

  private final func UpdateDuration(showingBothDigits: Bool) -> Void {
    if NotEquals(this.m_showingBothDigits, showingBothDigits) {
      if showingBothDigits {
        this.m_showPositiveAnimFadeInInterpolator.SetDuration(this.m_animBothTimeFadeIn);
        this.m_showPositiveAnimFadeOutInterpolator.SetDuration(this.m_animBothTimeFadeOut);
        this.m_showNegativeAnimFadeInInterpolator.SetDuration(this.m_animBothTimeFadeIn);
        this.m_showNegativeAnimFadeOutInterpolator.SetDuration(this.m_animBothTimeFadeOut);
        this.m_animDynamicDuration = this.m_animBothTimeFadeOut + this.m_animBothTimeDelay;
        this.m_animDynamicDelay = this.m_animBothTimeDelay;
        this.m_animDynamicCritDuration = this.m_animBothTimeFadeOut + this.m_animBothTimeCritDelay;
        this.m_animDynamicCritDelay = this.m_animBothTimeCritDelay;
      } else {
        this.m_showPositiveAnimFadeInInterpolator.SetDuration(this.m_animTimeFadeIn);
        this.m_showPositiveAnimFadeOutInterpolator.SetDuration(this.m_animTimeFadeOut);
        this.m_showNegativeAnimFadeInInterpolator.SetDuration(this.m_animTimeFadeIn);
        this.m_showNegativeAnimFadeOutInterpolator.SetDuration(this.m_animTimeFadeOut);
        this.m_animDynamicDuration = this.m_animTimeFadeOut + this.m_animTimeDelay;
        this.m_animDynamicDelay = this.m_animTimeDelay;
        this.m_animDynamicCritDuration = this.m_animTimeFadeOut + this.m_animTimeCritDelay;
        this.m_animDynamicCritDelay = this.m_animTimeCritDelay;
      };
      this.m_showingBothDigits = showingBothDigits;
    };
  }

  protected cb func OnScreenProjectionUpdate(projection: ref<inkScreenProjection>) -> Bool {
    let margin: inkMargin;
    let showAnimProxy: ref<inkAnimProxy>;
    margin.left = projection.currentPosition.X;
    margin.top = projection.currentPosition.Y;
    this.m_gameController.ApplyProjectionMarginOnWidget(this.m_rootWidget, margin);
    this.m_rootWidget.SetVisible(!(AbsF(projection.uvPosition.X) >= 1.20 || AbsF(projection.uvPosition.Y) >= 1.20));
    if !this.m_active {
      this.SetActive(true);
      this.GenerateRandomMarginInterpolator(this.m_successful, this.m_successfulCritical, this.m_showingBothDigits);
      showAnimProxy = this.m_panelWidget.PlayAnimation(this.m_successful ? this.m_showPositiveAnimDef : this.m_showNegativeAnimDef);
      showAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHide");
    };
  }

  protected cb func OnHide(anim: ref<inkAnimProxy>) -> Bool {
    this.SetActive(false);
    this.m_projection.UnregisterListener(this, n"OnScreenProjectionUpdate");
    this.m_projection.SetEnabled(false);
    this.CallCustomCallback(n"OnReadyToRemove");
  }

  private final func GenerateRandomMarginInterpolator(positive: Bool, isCritical: Bool, showingBothDigits: Bool) -> Void {
    let angleRad: Float;
    let endMargin: Vector2;
    let distance: Float = isCritical ? RandRangeF(this.m_animDistanceMin_Crit, this.m_animDistanceMax_Crit) : RandRangeF(this.m_animDistanceMin, this.m_animDistanceMax);
    distance *= this.m_distanceModifier;
    if !positive {
      distance *= 0.50;
    };
    if showingBothDigits {
      if RandRange(0, 2) == 0 {
        angleRad = Deg2Rad(RandRangeF(this.m_animBothAngleMin1, this.m_animBothAngleMax1));
      } else {
        angleRad = Deg2Rad(RandRangeF(this.m_animBothAngleMin2, this.m_animBothAngleMax2));
      };
      endMargin.X = CosF(angleRad) * distance + this.m_animBothOffsetX * this.m_distanceModifier;
    } else {
      if RandRange(0, 2) == 0 {
        angleRad = Deg2Rad(RandRangeF(this.m_animAngleMin1, this.m_animAngleMax1));
      } else {
        angleRad = Deg2Rad(RandRangeF(this.m_animAngleMin2, this.m_animAngleMax2));
      };
      endMargin.X = CosF(angleRad) * distance;
    };
    endMargin.Y = SinF(angleRad) * distance;
    if this.m_stickToTarget || this.m_forceStickToTarget {
      endMargin.Y += showingBothDigits ? this.m_animBothStickingOffsetY * this.m_distanceModifier : this.m_animStickingOffsetY * this.m_distanceModifier;
      endMargin.Y -= this.m_stickingDistanceHeightBias;
    } else {
      if showingBothDigits {
        endMargin.Y += this.m_animBothOffsetY * this.m_distanceModifier;
      };
      endMargin.Y += this.m_animStartHeight + this.m_calculatedDistanceHeightBias;
    };
    if positive {
      this.m_showPositiveAnimFadeOutInterpolator.SetStartDelay(isCritical ? this.m_animDynamicCritDelay : this.m_animDynamicDelay);
      this.m_showPositiveAnimMarginInterpolator.SetEndMargin(new inkMargin(endMargin.X, endMargin.Y, 0.00, 0.00));
      this.m_showPositiveAnimMarginInterpolator.SetDuration(isCritical ? this.m_animDynamicCritDuration : this.m_animDynamicDuration);
    } else {
      this.m_showNegativeAnimFadeOutInterpolator.SetStartDelay(isCritical ? this.m_animDynamicCritDelay : this.m_animDynamicDelay);
      this.m_showNegativeAnimMarginInterpolator.SetEndMargin(new inkMargin(endMargin.X, endMargin.Y, 0.00, 0.00));
      this.m_showNegativeAnimMarginInterpolator.SetDuration(isCritical ? this.m_animDynamicCritDuration : this.m_animDynamicDuration);
    };
  }

  private final func CreateShowAnimation() -> Void {
    this.m_animDynamicDuration = this.m_animTimeFadeOut + this.m_animTimeDelay;
    this.m_animDynamicDelay = this.m_animTimeDelay;
    this.m_animDynamicCritDuration = this.m_animTimeFadeOut + this.m_animTimeCritDelay;
    this.m_animDynamicCritDelay = this.m_animTimeCritDelay;
    this.m_showPositiveAnimDef = new inkAnimDef();
    this.m_showPositiveAnimFadeInInterpolator = new inkAnimTransparency();
    this.m_showPositiveAnimFadeInInterpolator.SetStartTransparency(0.00);
    this.m_showPositiveAnimFadeInInterpolator.SetEndTransparency(1.00);
    this.m_showPositiveAnimFadeInInterpolator.SetDuration(this.m_animTimeFadeIn);
    this.m_showPositiveAnimFadeInInterpolator.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimFadeInInterpolator);
    this.m_showPositiveAnimFadeOutInterpolator = new inkAnimTransparency();
    this.m_showPositiveAnimFadeOutInterpolator.SetStartDelay(this.m_animDynamicDelay);
    this.m_showPositiveAnimFadeOutInterpolator.SetStartTransparency(1.00);
    this.m_showPositiveAnimFadeOutInterpolator.SetEndTransparency(0.00);
    this.m_showPositiveAnimFadeOutInterpolator.SetDuration(this.m_animTimeFadeOut);
    this.m_showPositiveAnimFadeOutInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimFadeOutInterpolator);
    this.m_showPositiveAnimMarginInterpolator = new inkAnimMargin();
    this.m_showPositiveAnimMarginInterpolator.SetDuration(this.m_animDynamicDuration);
    this.m_showPositiveAnimMarginInterpolator.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_showPositiveAnimMarginInterpolator.SetType(inkanimInterpolationType.Quadratic);
    this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStartHeight, 0.00, 0.00));
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimMarginInterpolator);
    this.m_showPositiveAnimScaleInterpolator = new inkAnimScale();
    this.m_showPositiveAnimScaleInterpolator.SetDuration(0.10);
    this.m_showPositiveAnimScaleInterpolator.SetStartScale(new Vector2(1.00, 1.00));
    this.m_showPositiveAnimScaleInterpolator.SetEndScale(new Vector2(1.00, 1.00));
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimScaleInterpolator);
    this.m_showNegativeAnimDef = new inkAnimDef();
    this.m_showNegativeAnimFadeInInterpolator = new inkAnimTransparency();
    this.m_showNegativeAnimFadeInInterpolator.SetStartTransparency(0.00);
    this.m_showNegativeAnimFadeInInterpolator.SetEndTransparency(1.00);
    this.m_showNegativeAnimFadeInInterpolator.SetDuration(this.m_animTimeFadeIn);
    this.m_showNegativeAnimFadeInInterpolator.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_showNegativeAnimDef.AddInterpolator(this.m_showNegativeAnimFadeInInterpolator);
    this.m_showNegativeAnimFadeOutInterpolator = new inkAnimTransparency();
    this.m_showNegativeAnimFadeOutInterpolator.SetStartDelay(this.m_animDynamicDelay);
    this.m_showNegativeAnimFadeOutInterpolator.SetStartTransparency(1.00);
    this.m_showNegativeAnimFadeOutInterpolator.SetEndTransparency(0.00);
    this.m_showNegativeAnimFadeOutInterpolator.SetDuration(this.m_animTimeFadeOut);
    this.m_showNegativeAnimFadeOutInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_showNegativeAnimDef.AddInterpolator(this.m_showNegativeAnimFadeOutInterpolator);
    this.m_showNegativeAnimMarginInterpolator = new inkAnimMargin();
    this.m_showNegativeAnimMarginInterpolator.SetDuration(this.m_animDynamicDuration);
    this.m_showNegativeAnimMarginInterpolator.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_showNegativeAnimMarginInterpolator.SetType(inkanimInterpolationType.Quadratic);
    this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStartHeight, 0.00, 0.00));
    this.m_showNegativeAnimDef.AddInterpolator(this.m_showNegativeAnimMarginInterpolator);
    this.m_showNegativeAnimScaleInterpolator = new inkAnimScale();
    this.m_showNegativeAnimScaleInterpolator.SetDuration(0.10);
    this.m_showNegativeAnimScaleInterpolator.SetStartScale(new Vector2(1.00, 1.00));
    this.m_showNegativeAnimScaleInterpolator.SetEndScale(new Vector2(1.00, 1.00));
    this.m_showNegativeAnimDef.AddInterpolator(this.m_showNegativeAnimScaleInterpolator);
  }

  private final func BuildStateName(damageType: gamedataDamageType, hitType: gameuiHitType) -> CName {
    let damageTypeStr: String;
    let hitTypeStr: String;
    let isCritical: Bool;
    if !this.m_successful {
      damageTypeStr = "Cyberware";
    } else {
      switch damageType {
        case gamedataDamageType.Chemical:
          damageTypeStr = "Chemical";
          break;
        case gamedataDamageType.Electric:
          damageTypeStr = "EMP";
          break;
        case gamedataDamageType.Physical:
          damageTypeStr = "Physical";
          break;
        case gamedataDamageType.Thermal:
          damageTypeStr = "Thermal";
      };
    };
    switch hitType {
      case gameuiHitType.Miss:
        hitTypeStr = "Miss";
        break;
      case gameuiHitType.Glance:
        hitTypeStr = "Glance";
        break;
      case gameuiHitType.Hit:
        hitTypeStr = "Hit";
        break;
      case gameuiHitType.CriticalHit:
        hitTypeStr = "CriticalHit";
        isCritical = true;
        break;
      case gameuiHitType.CriticalHit_x2:
        hitTypeStr = "CriticalHit_x2";
        isCritical = true;
    };
    if isCritical {
      return StringToName(hitTypeStr);
    };
    return StringToName(damageTypeStr + "_" + hitTypeStr);
  }
}

public class AccumulatedDamageDigitLogicController extends inkLogicController {

  private edit let m_critWidget: inkTextRef;

  private edit let m_headshotWidget: inkTextRef;

  private let m_rootWidget: wref<inkWidget>;

  private let m_panelWidget: wref<inkWidget>;

  private let m_textWidget: wref<inkText>;

  public let m_owner: wref<GameObject>;

  private let m_gameController: wref<DamageDigitsGameController>;

  private let m_active: Bool;

  private let m_successful: Bool;

  private let m_successfulCritical: Bool;

  private let m_damageAccumulated: Float;

  private let m_showingBothDigits: Bool;

  public let m_stickToTarget: Bool;

  public let m_currentlySticking: Bool;

  private let m_projection: ref<inkScreenProjection>;

  private let m_showAnimProxy: ref<inkAnimProxy>;

  private let m_critAnimProxy: ref<inkAnimProxy>;

  private let m_blinkProxy: ref<inkAnimProxy>;

  private let m_headshotAnimProxy: ref<inkAnimProxy>;

  private let m_distanceModifier: Float;

  private let m_calculatedDistanceHeightBias: Float;

  private let m_stickingDistanceHeightBias: Float;

  private let m_projectionInterpolationOffset: inkMargin;

  private let m_projectionInterpolationOffsetTotal: inkMargin;

  private let m_projectionInterpolationProgress: Float;

  private let m_projectionFreezePosition: Bool;

  private let m_positionUpdated: Bool;

  private let m_currentEngineTime: Float;

  private let m_lastEngineTime: Float;

  public let m_arrayPosition: Int32;

  private let m_showPositiveAnimDef: ref<inkAnimDef>;

  private let m_showPositiveAnimFadeInInterpolator: ref<inkAnimTransparency>;

  private let m_showPositiveAnimFadeOutInterpolator: ref<inkAnimTransparency>;

  private let m_showPositiveAnimMarginInterpolator: ref<inkAnimMargin>;

  private let m_showPositiveAnimScaleUpInterpolator: ref<inkAnimScale>;

  private let m_showPositiveAnimScaleDownInterpolator: ref<inkAnimScale>;

  private let m_showNegativeAnimDef: ref<inkAnimDef>;

  private let m_showNegativeAnimFadeInInterpolator: ref<inkAnimTransparency>;

  private let m_showNegativeAnimFadeOutInterpolator: ref<inkAnimTransparency>;

  private let m_showNegativeAnimMarginInterpolator: ref<inkAnimMargin>;

  private let m_showCritAnimDef: ref<inkAnimDef>;

  private let m_showCritAnimFadeOutInterpolator: ref<inkAnimTransparency>;

  private let m_animStickTargetOffset: Vector4;

  @default(AccumulatedDamageDigitLogicController, 0.1f)
  private const let m_animTimeFadeIn: Float;

  @default(AccumulatedDamageDigitLogicController, 0.4f)
  private const let m_animTimeFadeOut: Float;

  @default(AccumulatedDamageDigitLogicController, 0.1f)
  private const let m_animBothTimeFadeIn: Float;

  @default(AccumulatedDamageDigitLogicController, 0.25f)
  private const let m_animBothTimeFadeOut: Float;

  @default(AccumulatedDamageDigitLogicController, 1.3f)
  private const let m_animTimeDelay: Float;

  @default(AccumulatedDamageDigitLogicController, 1.75f)
  private const let m_animBothTimeDelay: Float;

  @default(AccumulatedDamageDigitLogicController, -80.0f)
  private const let m_animStartHeight: Float;

  @default(AccumulatedDamageDigitLogicController, -140.0f)
  private const let m_animEndHeight: Float;

  @default(AccumulatedDamageDigitLogicController, 1.5f)
  private const let m_animPopScale: Float;

  @default(AccumulatedDamageDigitLogicController, 1.2f)
  private const let m_animPopEndScale: Float;

  @default(AccumulatedDamageDigitLogicController, 0.05f)
  private const let m_animPopInDuration: Float;

  @default(AccumulatedDamageDigitLogicController, 0.15f)
  private const let m_animPopOutDuration: Float;

  @default(AccumulatedDamageDigitLogicController, 0.0f)
  private const let m_animBothOffsetX: Float;

  @default(AccumulatedDamageDigitLogicController, -50.0f)
  private const let m_animBothOffsetY: Float;

  @default(AccumulatedDamageDigitLogicController, -105.0f)
  private const let m_animBothStickingOffsetY: Float;

  @default(AccumulatedDamageDigitLogicController, 1.3f)
  private const let m_animTimeCritDelay: Float;

  @default(AccumulatedDamageDigitLogicController, 1.75f)
  private const let m_animBothTimeCritDelay: Float;

  @default(AccumulatedDamageDigitLogicController, 0.4f)
  private const let m_animTimeCritFade: Float;

  @default(AccumulatedDamageDigitLogicController, 0.25f)
  private const let m_animBothTimeCritFade: Float;

  @default(AccumulatedDamageDigitLogicController, 500.0f)
  private const let m_animMaxScreenDistanceFromLast: Float;

  @default(AccumulatedDamageDigitLogicController, 0.08f)
  private const let m_animScreenInterpolationTime: Float;

  @default(AccumulatedDamageDigitLogicController, 60.0f)
  private const let m_animMinScreenDistanceFromLast: Float;

  @default(AccumulatedDamageDigitLogicController, 0.5f)
  private const let m_animStickTargetWorldZOffset: Float;

  @default(AccumulatedDamageDigitLogicController, -85.0f)
  private const let m_animStickingOffsetY: Float;

  @default(AccumulatedDamageDigitLogicController, 7.0f)
  private const let m_animDistanceModifierMinDistance: Float;

  @default(AccumulatedDamageDigitLogicController, 25.0f)
  private const let m_animDistanceModifierMaxDistance: Float;

  @default(AccumulatedDamageDigitLogicController, 0.6f)
  private const let m_animDistanceModifierMinValue: Float;

  @default(AccumulatedDamageDigitLogicController, 1.0f)
  private const let m_animDistanceModifierMaxValue: Float;

  @default(AccumulatedDamageDigitLogicController, 70.0f)
  private const let m_animDistanceHeightBias: Float;

  @default(AccumulatedDamageDigitLogicController, 70.0f)
  private const let m_animStickingDistanceHeightBias: Float;

  @default(AccumulatedDamageDigitLogicController, 1.0f)
  private const let m_animPositiveOpacity: Float;

  @default(AccumulatedDamageDigitLogicController, 0.8f)
  private const let m_animNegativeOpacity: Float;

  private let m_animDynamicFadeInDuration: Float;

  protected cb func OnInitialize() -> Bool {
    let strCrit: String;
    this.m_rootWidget = this.GetRootWidget();
    this.m_panelWidget = this.GetWidget(n"panel");
    this.m_textWidget = this.GetWidget(n"panel/text") as inkText;
    this.m_rootWidget.SetAnchorPoint(new Vector2(0.50, 0.50));
    inkWidgetRef.SetVisible(this.m_critWidget, false);
    inkWidgetRef.SetVisible(this.m_headshotWidget, false);
    strCrit = GetLocalizedText("LocKey#25999");
    inkTextRef.SetText(this.m_critWidget, strCrit);
    inkTextRef.SetText(this.m_headshotWidget, GetLocalizedText("LocKey#23394"));
    this.m_animStickTargetOffset = new Vector4(0.00, 0.00, this.m_animStickTargetWorldZOffset, 0.00);
    this.SetActive(false);
    this.CreateShowAnimation();
  }

  protected cb func OnUninitialize() -> Bool;

  public final func IsProjectedEntity(entity: wref<GameObject>) -> Bool {
    return this.m_projection.GetEntity() == entity;
  }

  public final func SetProjection(projection: ref<inkScreenProjection>, gameController: wref<DamageDigitsGameController>) -> Void {
    this.m_projection = projection;
    this.m_gameController = gameController;
  }

  private final func SetActive(active: Bool) -> Void {
    this.m_active = active;
    this.m_rootWidget.SetVisible(active);
  }

  public final func Show(damageInfo: DamageInfo, showingBothDigits: Bool, oneInstance: Bool, forceStickToTarget: Bool) -> Void {
    let desiredOpacity: Float;
    let state: CName;
    this.m_damageAccumulated = damageInfo.damageValue;
    this.m_currentlySticking = this.m_stickToTarget || forceStickToTarget;
    this.CalculateDistanceModifier(damageInfo.instigator.GetWorldPosition(), damageInfo.entityHit.GetWorldPosition());
    this.UpdatePositionAndScale(showingBothDigits);
    this.UpdateDuration(showingBothDigits);
    if this.m_currentlySticking {
      if damageInfo.entityHit.IsDevice() {
        this.m_projection.ResetFixedWorldOffset();
      } else {
        this.m_projection.SetFixedWorldOffset(this.m_animStickTargetOffset);
      };
      this.m_projection.SetEntity(damageInfo.entityHit);
    } else {
      this.m_projection.ResetFixedWorldOffset();
      this.m_projection.ResetEntity();
      this.m_projection.SetStaticWorldPosition(damageInfo.hitPosition);
    };
    this.m_projection.RegisterListener(this, n"OnScreenProjectionUpdate");
    this.m_projection.SetEnabled(true);
    this.m_projectionInterpolationOffset.left = 0.00;
    this.m_projectionInterpolationOffset.top = 0.00;
    this.m_projectionFreezePosition = false;
    if Cast(damageInfo.damageValue) > 0 && Equals(damageInfo.userData.hitShapeType, EHitShapeType.Flesh) {
      this.m_successful = true;
      desiredOpacity = this.m_animPositiveOpacity;
    } else {
      this.m_successful = false;
      desiredOpacity = this.m_animNegativeOpacity;
    };
    if (!showingBothDigits || oneInstance) && (Equals(damageInfo.hitType, gameuiHitType.CriticalHit) || Equals(damageInfo.hitType, gameuiHitType.CriticalHit_x2)) {
      this.m_successfulCritical = true;
      inkWidgetRef.SetVisible(this.m_critWidget, true);
      if IsDefined(this.m_critAnimProxy) && this.m_critAnimProxy.IsPlaying() {
        this.m_critAnimProxy.Stop();
      };
      this.m_critAnimProxy = inkWidgetRef.PlayAnimation(this.m_critWidget, this.m_showCritAnimDef);
      inkWidgetRef.SetOpacity(this.m_critWidget, desiredOpacity);
    } else {
      this.m_successfulCritical = false;
      inkWidgetRef.SetVisible(this.m_critWidget, false);
    };
    if (!showingBothDigits || oneInstance) && AttackData.HasFlag(damageInfo.userData.flags, hitFlag.Headshot) {
      inkWidgetRef.SetVisible(this.m_headshotWidget, true);
      if IsDefined(this.m_headshotAnimProxy) && this.m_headshotAnimProxy.IsPlaying() {
        this.m_headshotAnimProxy.Stop();
      };
      this.m_headshotAnimProxy = inkWidgetRef.PlayAnimation(this.m_headshotWidget, this.m_showCritAnimDef);
      inkWidgetRef.SetOpacity(this.m_headshotWidget, desiredOpacity);
    } else {
      inkWidgetRef.SetVisible(this.m_headshotWidget, false);
    };
    this.m_textWidget.SetText(ToString(Cast(this.m_damageAccumulated)));
    this.m_textWidget.SetOpacity(desiredOpacity);
    state = this.BuildStateName(damageInfo.damageType, damageInfo.hitType, oneInstance ? false : showingBothDigits);
    this.m_textWidget.SetState(state);
    inkWidgetRef.SetState(this.m_critWidget, state);
    inkWidgetRef.SetState(this.m_headshotWidget, state);
  }

  private final func CalculateDistanceModifier(fromVec: Vector4, toVec: Vector4) -> Void {
    let distance: Float = Vector4.Distance(fromVec, toVec);
    let distanceAdjusted: Float = MinF(distance, this.m_animDistanceModifierMaxDistance);
    distanceAdjusted = MaxF(distanceAdjusted - this.m_animDistanceModifierMinDistance, 0.00);
    this.m_distanceModifier = this.m_animDistanceModifierMinValue + (this.m_animDistanceModifierMaxValue - this.m_animDistanceModifierMinValue) * (1.00 - distanceAdjusted / (this.m_animDistanceModifierMaxDistance - this.m_animDistanceModifierMinDistance));
    this.m_calculatedDistanceHeightBias = (this.m_animDistanceHeightBias * (this.m_animDistanceModifierMaxValue - this.m_distanceModifier)) / (this.m_animDistanceModifierMaxValue - this.m_animDistanceModifierMinValue);
    this.m_stickingDistanceHeightBias = MinF(distance, 50.00) / 50.00 * this.m_animStickingDistanceHeightBias * this.m_distanceModifier;
  }

  private final func UpdatePositionAndScale(showingBothDigits: Bool) -> Void {
    let heightDifference: Float = (this.m_animEndHeight - this.m_animStartHeight) * this.m_distanceModifier;
    if showingBothDigits {
      if this.m_currentlySticking {
        this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias + 10.00, 0.00, 0.00));
        this.m_showPositiveAnimMarginInterpolator.SetEndMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias + heightDifference, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetEndMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias + heightDifference * 0.25, 0.00, 0.00));
      } else {
        this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothOffsetY * this.m_distanceModifier + this.m_animStartHeight + this.m_calculatedDistanceHeightBias, 0.00, 0.00));
        this.m_showPositiveAnimMarginInterpolator.SetEndMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothOffsetY * this.m_distanceModifier + this.m_animStartHeight + this.m_calculatedDistanceHeightBias + heightDifference, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothOffsetY * this.m_distanceModifier + this.m_animStartHeight + this.m_calculatedDistanceHeightBias, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetEndMargin(new inkMargin(this.m_animBothOffsetX * this.m_distanceModifier, this.m_animBothOffsetY * this.m_distanceModifier + this.m_animStartHeight + this.m_calculatedDistanceHeightBias + heightDifference * 0.25, 0.00, 0.00));
      };
    } else {
      if this.m_currentlySticking {
        this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias, 0.00, 0.00));
        this.m_showPositiveAnimMarginInterpolator.SetEndMargin(new inkMargin(0.00, this.m_animStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias + heightDifference, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetEndMargin(new inkMargin(0.00, this.m_animStickingOffsetY * this.m_distanceModifier - this.m_stickingDistanceHeightBias + heightDifference * 0.25, 0.00, 0.00));
      } else {
        this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStartHeight + this.m_calculatedDistanceHeightBias, 0.00, 0.00));
        this.m_showPositiveAnimMarginInterpolator.SetEndMargin(new inkMargin(0.00, this.m_animStartHeight + this.m_calculatedDistanceHeightBias + heightDifference, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStartHeight + this.m_calculatedDistanceHeightBias, 0.00, 0.00));
        this.m_showNegativeAnimMarginInterpolator.SetEndMargin(new inkMargin(0.00, this.m_animStartHeight + this.m_calculatedDistanceHeightBias + heightDifference * 0.25, 0.00, 0.00));
      };
    };
    this.m_showPositiveAnimScaleUpInterpolator.SetStartScale(new Vector2(1.00 * this.m_distanceModifier, 1.00 * this.m_distanceModifier));
    this.m_showPositiveAnimScaleUpInterpolator.SetEndScale(new Vector2(this.m_animPopScale * this.m_distanceModifier, this.m_animPopScale * this.m_distanceModifier));
    this.m_showPositiveAnimScaleDownInterpolator.SetStartScale(new Vector2(this.m_animPopScale * this.m_distanceModifier, this.m_animPopScale * this.m_distanceModifier));
    this.m_showPositiveAnimScaleDownInterpolator.SetEndScale(new Vector2(this.m_animPopEndScale * this.m_distanceModifier, this.m_animPopEndScale * this.m_distanceModifier));
  }

  private final func UpdateDuration(showingBothDigits: Bool) -> Void {
    if NotEquals(this.m_showingBothDigits, showingBothDigits) {
      if showingBothDigits {
        this.m_showPositiveAnimMarginInterpolator.SetDuration(this.m_animBothTimeFadeOut + this.m_animBothTimeDelay);
        this.m_showPositiveAnimFadeInInterpolator.SetDuration(this.m_animBothTimeFadeIn);
        this.m_showPositiveAnimFadeOutInterpolator.SetDuration(this.m_animBothTimeFadeOut);
        this.m_showPositiveAnimFadeOutInterpolator.SetStartDelay(this.m_animBothTimeDelay);
        this.m_showNegativeAnimMarginInterpolator.SetDuration(this.m_animBothTimeFadeOut + this.m_animBothTimeDelay);
        this.m_showNegativeAnimFadeInInterpolator.SetDuration(this.m_animBothTimeFadeIn);
        this.m_showNegativeAnimFadeOutInterpolator.SetDuration(this.m_animBothTimeFadeOut);
        this.m_showNegativeAnimFadeOutInterpolator.SetStartDelay(this.m_animBothTimeDelay);
        this.m_showCritAnimFadeOutInterpolator.SetStartDelay(this.m_animBothTimeCritDelay);
        this.m_showCritAnimFadeOutInterpolator.SetDuration(this.m_animBothTimeCritFade);
        this.m_animDynamicFadeInDuration = this.m_animBothTimeFadeIn;
      } else {
        this.m_showPositiveAnimMarginInterpolator.SetDuration(this.m_animTimeFadeOut + this.m_animTimeDelay);
        this.m_showPositiveAnimFadeInInterpolator.SetDuration(this.m_animTimeFadeIn);
        this.m_showPositiveAnimFadeOutInterpolator.SetDuration(this.m_animTimeFadeOut);
        this.m_showPositiveAnimFadeOutInterpolator.SetStartDelay(this.m_animTimeDelay);
        this.m_showNegativeAnimMarginInterpolator.SetDuration(this.m_animTimeFadeOut + this.m_animTimeDelay);
        this.m_showNegativeAnimFadeInInterpolator.SetDuration(this.m_animTimeFadeIn);
        this.m_showNegativeAnimFadeOutInterpolator.SetDuration(this.m_animTimeFadeOut);
        this.m_showNegativeAnimFadeOutInterpolator.SetStartDelay(this.m_animTimeDelay);
        this.m_showCritAnimFadeOutInterpolator.SetStartDelay(this.m_animTimeCritDelay);
        this.m_showCritAnimFadeOutInterpolator.SetDuration(this.m_animTimeCritFade);
        this.m_animDynamicFadeInDuration = this.m_animTimeFadeIn;
      };
      this.m_showingBothDigits = showingBothDigits;
    };
  }

  public final func UpdateDamageInfo(damageInfo: DamageInfo, showingBothDigits: Bool) -> Void {
    let animationCurrentPlayTime: Float;
    let desiredOpacity: Float;
    let state: CName;
    this.m_damageAccumulated += damageInfo.damageValue;
    this.CalculateDistanceModifier(damageInfo.instigator.GetWorldPosition(), damageInfo.entityHit.GetWorldPosition());
    this.UpdatePositionAndScale(showingBothDigits);
    this.UpdateDuration(showingBothDigits);
    if !this.m_currentlySticking {
      this.m_projection.SetStaticWorldPosition(damageInfo.hitPosition);
    };
    this.m_positionUpdated = true;
    if Cast(damageInfo.damageValue) > 0 && Equals(damageInfo.userData.hitShapeType, EHitShapeType.Flesh) {
      this.m_successful = true;
      desiredOpacity = this.m_animPositiveOpacity;
    } else {
      this.m_successful = false;
      desiredOpacity = this.m_animNegativeOpacity;
    };
    if !showingBothDigits && (Equals(damageInfo.hitType, gameuiHitType.CriticalHit) || Equals(damageInfo.hitType, gameuiHitType.CriticalHit_x2)) {
      this.m_successfulCritical = true;
      inkWidgetRef.SetVisible(this.m_critWidget, true);
      if IsDefined(this.m_critAnimProxy) && this.m_critAnimProxy.IsPlaying() {
        this.m_critAnimProxy.Stop();
      };
      this.m_critAnimProxy = inkWidgetRef.PlayAnimation(this.m_critWidget, this.m_showCritAnimDef);
      inkWidgetRef.SetOpacity(this.m_critWidget, desiredOpacity);
    } else {
      this.m_successfulCritical = false;
    };
    if !showingBothDigits && AttackData.HasFlag(damageInfo.userData.flags, hitFlag.Headshot) {
      inkWidgetRef.SetVisible(this.m_headshotWidget, true);
      if IsDefined(this.m_headshotAnimProxy) && this.m_headshotAnimProxy.IsPlaying() {
        this.m_headshotAnimProxy.Stop();
      };
      this.m_headshotAnimProxy = inkWidgetRef.PlayAnimation(this.m_headshotWidget, this.m_showCritAnimDef);
      inkWidgetRef.SetOpacity(this.m_headshotWidget, desiredOpacity);
    };
    if showingBothDigits {
      inkWidgetRef.SetVisible(this.m_critWidget, false);
      inkWidgetRef.SetVisible(this.m_headshotWidget, false);
    };
    this.m_textWidget.SetText(ToString(Cast(this.m_damageAccumulated)));
    this.m_textWidget.SetOpacity(desiredOpacity);
    state = this.BuildStateName(damageInfo.damageType, damageInfo.hitType, showingBothDigits);
    this.m_textWidget.SetState(state);
    inkWidgetRef.SetState(this.m_critWidget, state);
    inkWidgetRef.SetState(this.m_headshotWidget, state);
    if IsDefined(this.m_blinkProxy) && this.m_blinkProxy.IsPlaying() {
      this.m_blinkProxy.Stop();
    };
    this.m_blinkProxy = this.PlayLibraryAnimation(n"blink_anim");
    this.m_showAnimProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnHide");
    animationCurrentPlayTime = this.m_showAnimProxy.GetTime();
    this.m_showAnimProxy.Stop();
    this.m_showPositiveAnimFadeInInterpolator.SetDuration(ClampF(this.m_showPositiveAnimFadeInInterpolator.GetDuration() - animationCurrentPlayTime, 0.00, this.m_animDynamicFadeInDuration));
    this.m_showNegativeAnimFadeInInterpolator.SetDuration(ClampF(this.m_showNegativeAnimFadeInInterpolator.GetDuration() - animationCurrentPlayTime, 0.00, this.m_animDynamicFadeInDuration));
    this.m_showAnimProxy = this.m_panelWidget.PlayAnimation(this.m_successful ? this.m_showPositiveAnimDef : this.m_showNegativeAnimDef);
    this.m_showAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHide");
  }

  protected cb func OnScreenProjectionUpdate(projection: ref<inkScreenProjection>) -> Bool {
    let distanceSquared: Float;
    let distanceX: Float;
    let distanceY: Float;
    let dt: Float;
    let interpolationEndTime: Float;
    let interpolationFactor: Float;
    let interpolationStartTime: Float;
    let margin: inkMargin;
    this.m_lastEngineTime = this.m_currentEngineTime;
    this.m_currentEngineTime = EngineTime.ToFloat(GameInstance.GetEngineTime(this.m_owner.GetGame()));
    if this.m_projectionFreezePosition {
      margin.left = projection.currentPosition.X + this.m_projectionInterpolationOffset.left;
      margin.top = projection.currentPosition.Y + this.m_projectionInterpolationOffset.top;
    } else {
      margin.left = projection.currentPosition.X;
      margin.top = projection.currentPosition.Y;
    };
    if this.m_active && !this.m_currentlySticking {
      dt = this.m_currentEngineTime - this.m_lastEngineTime;
      if this.m_positionUpdated {
        this.m_projectionInterpolationOffset.left += projection.previousPosition.X - projection.currentPosition.X;
        this.m_projectionInterpolationOffset.top += projection.previousPosition.Y - projection.currentPosition.Y;
        this.m_projectionInterpolationOffsetTotal = this.m_projectionInterpolationOffset;
        this.m_projectionInterpolationProgress = 0.00;
        this.m_positionUpdated = false;
        distanceSquared = this.m_projectionInterpolationOffset.left * this.m_projectionInterpolationOffset.left + this.m_projectionInterpolationOffset.top * this.m_projectionInterpolationOffset.top;
        if distanceSquared < this.m_animMinScreenDistanceFromLast * this.m_animMinScreenDistanceFromLast {
          this.m_projectionFreezePosition = true;
          margin.left = projection.currentPosition.X + this.m_projectionInterpolationOffset.left;
          margin.top = projection.currentPosition.Y + this.m_projectionInterpolationOffset.top;
        } else {
          this.m_projectionFreezePosition = false;
        };
      };
      if !this.m_projectionFreezePosition {
        if AbsF(this.m_projectionInterpolationOffset.left) > 0.00 || AbsF(this.m_projectionInterpolationOffset.top) > 0.00 {
          distanceX = this.m_projectionInterpolationOffsetTotal.left;
          distanceY = this.m_projectionInterpolationOffsetTotal.top;
          distanceSquared = distanceX * distanceX + distanceY * distanceY;
          if distanceSquared <= this.m_animMaxScreenDistanceFromLast * this.m_animMaxScreenDistanceFromLast {
            if this.m_projectionInterpolationProgress + dt >= this.m_animScreenInterpolationTime {
              this.m_projectionInterpolationOffset.left = 0.00;
              this.m_projectionInterpolationOffset.top = 0.00;
            } else {
              interpolationStartTime = this.m_projectionInterpolationProgress;
              interpolationEndTime = interpolationStartTime + dt;
              interpolationFactor = (((this.m_animScreenInterpolationTime - interpolationStartTime + this.m_animScreenInterpolationTime - interpolationEndTime) * dt) / this.m_animScreenInterpolationTime) / this.m_animScreenInterpolationTime;
              this.m_projectionInterpolationOffset.left -= distanceX * interpolationFactor;
              this.m_projectionInterpolationOffset.top -= distanceY * interpolationFactor;
              this.m_projectionInterpolationProgress += dt;
            };
            margin.left = projection.currentPosition.X + this.m_projectionInterpolationOffset.left;
            margin.top = projection.currentPosition.Y + this.m_projectionInterpolationOffset.top;
          } else {
            this.m_projectionInterpolationOffset.left = 0.00;
            this.m_projectionInterpolationOffset.top = 0.00;
          };
        };
      };
    };
    this.m_gameController.ApplyProjectionMarginOnWidget(this.m_rootWidget, margin);
    this.m_rootWidget.SetVisible(!(AbsF(projection.uvPosition.X) >= 1.20 || AbsF(projection.uvPosition.Y) >= 1.20));
    if !this.m_active {
      this.SetActive(true);
      this.m_showPositiveAnimFadeInInterpolator.SetDuration(this.m_animDynamicFadeInDuration);
      this.m_showNegativeAnimFadeInInterpolator.SetDuration(this.m_animDynamicFadeInDuration);
      this.m_showAnimProxy = this.m_panelWidget.PlayAnimation(this.m_successful ? this.m_showPositiveAnimDef : this.m_showNegativeAnimDef);
      this.m_showAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHide");
    };
  }

  protected cb func OnHide(anim: ref<inkAnimProxy>) -> Bool {
    this.SetActive(false);
    this.m_projection.UnregisterListener(this, n"OnScreenProjectionUpdate");
    this.m_projection.SetEnabled(false);
    this.CallCustomCallback(n"OnReadyToRemoveAccumulatedDigit");
  }

  private final func CreateShowAnimation() -> Void {
    this.m_animDynamicFadeInDuration = this.m_animTimeFadeIn;
    this.m_showPositiveAnimDef = new inkAnimDef();
    this.m_showPositiveAnimFadeInInterpolator = new inkAnimTransparency();
    this.m_showPositiveAnimFadeInInterpolator.SetStartTransparency(0.00);
    this.m_showPositiveAnimFadeInInterpolator.SetEndTransparency(1.00);
    this.m_showPositiveAnimFadeInInterpolator.SetDuration(this.m_animTimeFadeIn);
    this.m_showPositiveAnimFadeInInterpolator.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimFadeInInterpolator);
    this.m_showPositiveAnimFadeOutInterpolator = new inkAnimTransparency();
    this.m_showPositiveAnimFadeOutInterpolator.SetStartDelay(this.m_animTimeDelay);
    this.m_showPositiveAnimFadeOutInterpolator.SetStartTransparency(1.00);
    this.m_showPositiveAnimFadeOutInterpolator.SetEndTransparency(0.00);
    this.m_showPositiveAnimFadeOutInterpolator.SetDuration(this.m_animTimeFadeOut);
    this.m_showPositiveAnimFadeOutInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimFadeOutInterpolator);
    this.m_showPositiveAnimMarginInterpolator = new inkAnimMargin();
    this.m_showPositiveAnimMarginInterpolator.SetDuration(this.m_animTimeFadeOut + this.m_animTimeDelay);
    this.m_showPositiveAnimMarginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_showPositiveAnimMarginInterpolator.SetType(inkanimInterpolationType.Qubic);
    this.m_showPositiveAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStartHeight, 0.00, 0.00));
    this.m_showPositiveAnimMarginInterpolator.SetEndMargin(new inkMargin(0.00, this.m_animEndHeight, 0.00, 0.00));
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimMarginInterpolator);
    this.m_showPositiveAnimScaleUpInterpolator = new inkAnimScale();
    this.m_showPositiveAnimScaleUpInterpolator.SetDuration(this.m_animPopInDuration);
    this.m_showPositiveAnimScaleUpInterpolator.SetStartScale(new Vector2(1.00, 1.00));
    this.m_showPositiveAnimScaleUpInterpolator.SetEndScale(new Vector2(this.m_animPopScale, this.m_animPopScale));
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimScaleUpInterpolator);
    this.m_showPositiveAnimScaleDownInterpolator = new inkAnimScale();
    this.m_showPositiveAnimScaleDownInterpolator.SetDuration(this.m_animPopOutDuration);
    this.m_showPositiveAnimScaleDownInterpolator.SetStartDelay(this.m_animPopInDuration);
    this.m_showPositiveAnimScaleDownInterpolator.SetStartScale(new Vector2(this.m_animPopScale, this.m_animPopScale));
    this.m_showPositiveAnimScaleDownInterpolator.SetEndScale(new Vector2(this.m_animPopEndScale, this.m_animPopEndScale));
    this.m_showPositiveAnimDef.AddInterpolator(this.m_showPositiveAnimScaleDownInterpolator);
    this.m_showNegativeAnimDef = new inkAnimDef();
    this.m_showNegativeAnimFadeInInterpolator = new inkAnimTransparency();
    this.m_showNegativeAnimFadeInInterpolator.SetStartTransparency(0.00);
    this.m_showNegativeAnimFadeInInterpolator.SetEndTransparency(1.00);
    this.m_showNegativeAnimFadeInInterpolator.SetDuration(this.m_animTimeFadeIn);
    this.m_showNegativeAnimFadeInInterpolator.SetMode(inkanimInterpolationMode.EasyOut);
    this.m_showNegativeAnimDef.AddInterpolator(this.m_showNegativeAnimFadeInInterpolator);
    this.m_showNegativeAnimFadeOutInterpolator = new inkAnimTransparency();
    this.m_showNegativeAnimFadeOutInterpolator.SetStartDelay(this.m_animTimeDelay);
    this.m_showNegativeAnimFadeOutInterpolator.SetStartTransparency(1.00);
    this.m_showNegativeAnimFadeOutInterpolator.SetEndTransparency(0.00);
    this.m_showNegativeAnimFadeOutInterpolator.SetDuration(this.m_animTimeFadeOut);
    this.m_showNegativeAnimFadeOutInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_showNegativeAnimDef.AddInterpolator(this.m_showNegativeAnimFadeOutInterpolator);
    this.m_showNegativeAnimMarginInterpolator = new inkAnimMargin();
    this.m_showNegativeAnimMarginInterpolator.SetDuration(this.m_animTimeFadeOut + this.m_animTimeDelay);
    this.m_showNegativeAnimMarginInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_showNegativeAnimMarginInterpolator.SetType(inkanimInterpolationType.Qubic);
    this.m_showNegativeAnimMarginInterpolator.SetStartMargin(new inkMargin(0.00, this.m_animStartHeight, 0.00, 0.00));
    this.m_showNegativeAnimMarginInterpolator.SetEndMargin(new inkMargin(0.00, this.m_animEndHeight, 0.00, 0.00));
    this.m_showNegativeAnimDef.AddInterpolator(this.m_showNegativeAnimMarginInterpolator);
    this.m_showCritAnimDef = new inkAnimDef();
    this.m_showCritAnimFadeOutInterpolator = new inkAnimTransparency();
    this.m_showCritAnimFadeOutInterpolator.SetStartTransparency(1.00);
    this.m_showCritAnimFadeOutInterpolator.SetEndTransparency(0.00);
    this.m_showCritAnimFadeOutInterpolator.SetStartDelay(this.m_animTimeCritDelay);
    this.m_showCritAnimFadeOutInterpolator.SetDuration(this.m_animTimeCritFade);
    this.m_showCritAnimDef.AddInterpolator(this.m_showCritAnimFadeOutInterpolator);
  }

  private final func BuildStateName(damageType: gamedataDamageType, hitType: gameuiHitType, showingBothDigits: Bool) -> CName {
    let damageTypeStr: String;
    let hitTypeStr: String;
    let isCritical: Bool;
    if !this.m_successful {
      damageTypeStr = "Cyberware";
    } else {
      switch damageType {
        case gamedataDamageType.Chemical:
          damageTypeStr = "Chemical";
          break;
        case gamedataDamageType.Electric:
          damageTypeStr = "EMP";
          break;
        case gamedataDamageType.Physical:
          damageTypeStr = "Physical";
          break;
        case gamedataDamageType.Thermal:
          damageTypeStr = "Thermal";
      };
    };
    switch hitType {
      case gameuiHitType.Miss:
        hitTypeStr = "Miss";
        break;
      case gameuiHitType.Glance:
        hitTypeStr = "Glance";
        break;
      case gameuiHitType.Hit:
        hitTypeStr = "Hit";
        break;
      case gameuiHitType.CriticalHit:
        hitTypeStr = "CriticalHit";
        isCritical = true;
        break;
      case gameuiHitType.CriticalHit_x2:
        hitTypeStr = "CriticalHit_x2";
        isCritical = true;
    };
    if isCritical && !showingBothDigits {
      return StringToName(hitTypeStr);
    };
    return StringToName(damageTypeStr + "_" + hitTypeStr);
  }
}
