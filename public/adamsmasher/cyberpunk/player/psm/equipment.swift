
public abstract class EquipmentBaseTransition extends DefaultTransition {

  protected final const func GetMappedInstanceData(referenceName: CName) -> InstanceDataMappedToReferenceName {
    let mappedInstanceData: InstanceDataMappedToReferenceName;
    if Equals(referenceName, n"RightHand") {
      mappedInstanceData.itemHandlingFeatureName = n"rightHandItemHandling";
      mappedInstanceData.attachmentSlot = "AttachmentSlots.WeaponRight";
    };
    if Equals(referenceName, n"LeftHand") {
      mappedInstanceData.itemHandlingFeatureName = n"leftHandItemHandling";
      mappedInstanceData.attachmentSlot = "AttachmentSlots.WeaponLeft";
    };
    return mappedInstanceData;
  }

  protected final const func GetWeaponManipulationRequest(const stateContext: ref<StateContext>, stateMachineInitData: wref<EquipmentInitData>) -> ref<EquipmentManipulationRequest> {
    let request: ref<EquipmentManipulationRequest> = stateContext.GetPermanentScriptableParameter(stateMachineInitData.eqManipulationVarName) as EquipmentManipulationRequest;
    return request;
  }

  protected final const func SaveProcessedEquipmentManipulationRequest(stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData, stateMachineInitData: wref<EquipmentInitData>) -> Void {
    stateContext.SetPermanentScriptableParameter(this.ReferenceNameToProcessRequestId(stateMachineInstanceData), this.GetWeaponManipulationRequest(stateContext, stateMachineInitData), true);
  }

  protected final const func GetProcessedEquipmentManipulationRequest(stateMachineInstanceData: StateMachineInstanceData, const stateContext: ref<StateContext>) -> ref<EquipmentManipulationRequest> {
    let request: ref<EquipmentManipulationRequest> = stateContext.GetPermanentScriptableParameter(this.ReferenceNameToProcessRequestId(stateMachineInstanceData)) as EquipmentManipulationRequest;
    return request;
  }

  protected final const func ClearProcessedEquipmentManipulationRequest(stateMachineInstanceData: StateMachineInstanceData, stateContext: ref<StateContext>) -> Void {
    stateContext.RemovePermanentScriptableParameter(this.ReferenceNameToProcessRequestId(stateMachineInstanceData));
  }

  protected final const func CheckSlotMatchAndCompareRequestType(const stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData, stateMachineInitData: wref<EquipmentInitData>, requestTypeCompare: EquipmentManipulationRequestType) -> Bool {
    let equipRequestMatch: Bool;
    let slotMatch: Bool;
    let request: ref<EquipmentManipulationRequest> = this.GetWeaponManipulationRequest(stateContext, stateMachineInitData);
    if request == null {
      return false;
    };
    equipRequestMatch = Equals(request.requestType, requestTypeCompare);
    slotMatch = Equals(request.requestSlot, EquipmentManipulationRequestSlot.Both) || Equals(request.requestSlot, this.ReferenceNameToRequestSlot(stateMachineInstanceData));
    return equipRequestMatch && slotMatch;
  }

  protected final const func CheckReplicatedEquipRequest(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Bool {
    let multiplyerRequestData: ref<parameterRequestItem>;
    let isDifferentItem: Bool = false;
    let slotMatch: Bool = false;
    if Equals(this.ReferenceNameToRequestSlot(stateMachineInstanceData), EquipmentManipulationRequestSlot.Right) {
      slotMatch = true;
    };
    multiplyerRequestData = stateContext.GetTemporaryScriptableParameter(n"cpo_replicatedEquipRequest") as parameterRequestItem;
    if multiplyerRequestData == null {
      multiplyerRequestData = stateContext.GetConditionScriptableParameter(n"cpo_replicatedEquipRequest") as parameterRequestItem;
    };
    if IsDefined(multiplyerRequestData) {
      isDifferentItem = this.GetSlotAttachedItemID(scriptInterface, stateMachineInstanceData) != multiplyerRequestData.requests[0].itemIDToEquip;
    };
    if isDifferentItem && slotMatch {
      stateContext.SetConditionScriptableParameter(n"cpo_replicatedEquipRequest", multiplyerRequestData, true);
      return true;
    };
    return false;
  }

  protected final const func ReferenceNameToProcessRequestId(stateMachineInstanceData: StateMachineInstanceData) -> CName {
    if Equals(stateMachineInstanceData.referenceName, n"RightHand") {
      return n"ProcessedEqRequest_Right";
    };
    if Equals(stateMachineInstanceData.referenceName, n"LeftHand") {
      return n"ProcessedEqRequest_Left";
    };
    return n"ProcessedEqRequest_Undefined";
  }

  protected final const func ReferenceNameToRequestSlot(stateMachineInstanceData: StateMachineInstanceData) -> EquipmentManipulationRequestSlot {
    if Equals(stateMachineInstanceData.referenceName, n"RightHand") {
      return EquipmentManipulationRequestSlot.Right;
    };
    if Equals(stateMachineInstanceData.referenceName, n"LeftHand") {
      return EquipmentManipulationRequestSlot.Left;
    };
    return EquipmentManipulationRequestSlot.Undefined;
  }

  protected final const func GetItemCategoryFromItemID(item: ItemID) -> gamedataItemCategory {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    return record.ItemCategory().Type();
  }

  protected final const func GetEquipAreaFromItemID(item: ItemID) -> gamedataEquipmentArea {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
    return record.EquipArea().Type();
  }

  protected final const func IsItemInSlot(const scriptInterface: ref<StateGameScriptInterface>, stateMachineInstanceData: StateMachineInstanceData) -> Bool {
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(stateMachineInstanceData.referenceName);
    return scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot)) != null;
  }

  protected final const func IsUsingFluffConsumable(const scriptInterface: ref<StateGameScriptInterface>, stateMachineInstanceData: StateMachineInstanceData) -> Bool {
    let item: ItemID = this.GetSlotActiveItem(scriptInterface, stateMachineInstanceData);
    if Equals(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ItemType().Type(), gamedataItemType.Con_Edible) {
      return true;
    };
    return false;
  }

  protected final const func GetIsPSMInValidState(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Bool {
    let weaponPSMState: gamePSMRangedWeaponStates;
    if Equals(this.GetItemCategoryFromItemID(this.GetSlotAttachedItemID(scriptInterface, stateMachineInstanceData)), gamedataItemCategory.Weapon) {
      weaponPSMState = IntEnum(scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon));
      return Equals(weaponPSMState, gamePSMRangedWeaponStates.Default) || Equals(weaponPSMState, gamePSMRangedWeaponStates.NoAmmo) || Equals(weaponPSMState, gamePSMRangedWeaponStates.Ready) || Equals(weaponPSMState, gamePSMRangedWeaponStates.Safe);
    };
    return true;
  }

  protected final const func GetWeaponEquipDuration(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Float {
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let weapon: wref<WeaponObject> = this.GetSlotAttachedItemObject(scriptInterface, stateMachineInstanceData) as WeaponObject;
    return statSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.EquipDuration);
  }

  protected final const func GetWeaponUnEquipDuration(const scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Float {
    let duration: Float;
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let weapon: wref<WeaponObject> = this.GetSlotAttachedItemObject(scriptInterface, stateMachineInstanceData) as WeaponObject;
    if Equals(this.GetProcessedEquipmentManipulationRequest(stateMachineInstanceData, stateContext).equipAnim, gameEquipAnimationType.Instant) {
      duration = 0.00;
    } else {
      duration = statSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.UnequipDuration);
    };
    stateContext.SetPermanentFloatParameter(n"rhUnequipDuration", duration, true);
    return duration;
  }

  protected final const func GetConsumableUnEquipDuration(stateMachineInstanceData: StateMachineInstanceData, const stateContext: ref<StateContext>) -> Float {
    if Equals(this.GetProcessedEquipmentManipulationRequest(stateMachineInstanceData, stateContext).equipAnim, gameEquipAnimationType.Instant) {
      return 0.00;
    };
    return 0.20;
  }

  protected final const func HandleWeaponEquip(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData, item: ItemID) -> Void {
    let statsEvent: ref<UpdateWeaponStatsEvent>;
    let weaponEquipEvent: ref<WeaponEquipEvent>;
    let animFeature: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    let weaponEquipAnimFeature: ref<AnimFeature_EquipType> = new AnimFeature_EquipType();
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(stateMachineInstanceData.referenceName);
    let firstEqSystem: ref<FirstEquipSystem> = FirstEquipSystem.GetInstance(scriptInterface.owner);
    let itemObject: wref<WeaponObject> = transactionSystem.GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot)) as WeaponObject;
    let isInCombat: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat);
    if TweakDBInterface.GetBool(t"player.weapon.enableWeaponBlur", false) {
      this.GetBlurParametersFromWeapon(scriptInterface);
    };
    if !isInCombat {
      if weaponEquipAnimFeature.firstEquip = Equals(this.GetProcessedEquipmentManipulationRequest(stateMachineInstanceData, stateContext).equipAnim, gameEquipAnimationType.FirstEquip) || this.GetStaticBoolParameterDefault("forceFirstEquip", false) || !firstEqSystem.HasPlayedFirstEquip(ItemID.GetTDBID(itemObject.GetItemID())) {
        weaponEquipAnimFeature.firstEquip = true;
        stateContext.SetConditionBoolParameter(n"firstEquip", true, true);
      };
    };
    animFeature.stateTransitionDuration = statSystem.GetStatValue(Cast(itemObject.GetEntityID()), gamedataStatType.EquipDuration);
    animFeature.itemState = 1;
    animFeature.itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ItemType().AnimFeatureIndex();
    this.BlockAimingForTime(stateContext, scriptInterface, animFeature.stateTransitionDuration + 0.10);
    weaponEquipAnimFeature.equipDuration = this.GetEquipDuration(scriptInterface, stateContext, stateMachineInstanceData);
    weaponEquipAnimFeature.unequipDuration = this.GetUnequipDuration(scriptInterface, stateContext, stateMachineInstanceData);
    scriptInterface.SetAnimationParameterFeature(mappedInstanceData.itemHandlingFeatureName, animFeature, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"equipUnequipItem", animFeature, itemObject);
    weaponEquipEvent = new WeaponEquipEvent();
    weaponEquipEvent.animFeature = weaponEquipAnimFeature;
    weaponEquipEvent.item = itemObject;
    GameInstance.GetDelaySystem(scriptInterface.executionOwner.GetGame()).DelayEvent(scriptInterface.executionOwner, weaponEquipEvent, 0.03);
    scriptInterface.executionOwner.QueueEventForEntityID(itemObject.GetEntityID(), new PlayerWeaponSetupEvent());
    statsEvent = new UpdateWeaponStatsEvent();
    scriptInterface.executionOwner.QueueEventForEntityID(itemObject.GetEntityID(), statsEvent);
    if weaponEquipAnimFeature.firstEquip {
      scriptInterface.SetAnimationParameterFloat(n"safe", 0.00);
      stateContext.SetPermanentBoolParameter(n"WeaponInSafe", false, true);
      stateContext.SetPermanentFloatParameter(n"TurnOffPublicSafeTimeStamp", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.owner.GetGame())), true);
    } else {
      if stateContext.GetBoolParameter(n"InPublicZone", true) {
      } else {
        if stateContext.GetBoolParameter(n"WeaponInSafe", true) {
          scriptInterface.SetAnimationParameterFloat(n"safe", 1.00);
        };
      };
    };
  }

  protected final const func HandleWeaponUnequip(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData, item: ItemID) -> Void {
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(stateMachineInstanceData.referenceName);
    let unequipStartEvent: ref<UnequipStart> = new UnequipStart();
    let animFeature: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let placementSlot: TweakDBID = EquipmentSystem.GetPlacementSlot(item);
    let itemObject: wref<WeaponObject> = transactionSystem.GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot)) as WeaponObject;
    animFeature.stateTransitionDuration = this.GetWeaponUnEquipDuration(scriptInterface, stateContext, stateMachineInstanceData);
    animFeature.itemState = 3;
    animFeature.itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ItemType().AnimFeatureIndex();
    this.BlockAimingForTime(stateContext, scriptInterface, animFeature.stateTransitionDuration + 0.10);
    scriptInterface.SetAnimationParameterFeature(mappedInstanceData.itemHandlingFeatureName, animFeature, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"equipUnequipItem", animFeature, itemObject);
    unequipStartEvent.SetSlotID(placementSlot);
    scriptInterface.executionOwner.QueueEvent(unequipStartEvent);
  }

  protected final func DropActiveWeapon(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Void {
    let weaponID: ItemID;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let transformVec: Vector4 = new Vector4(0.40, -0.60, -0.50, 0.00);
    let worldPosition: Vector4 = Transform.TransformPoint(cameraWorldTransform, transformVec);
    let dropRotation: Quaternion = DefaultTransition.GetActiveWeapon(scriptInterface).GetWorldOrientation();
    Quaternion.SetZRot(dropRotation, RandRangeF(0.00, 180.00));
    weaponID = this.GetItemIDFromParam(stateMachineInstanceData, stateContext);
    GameInstance.GetLootManager(scriptInterface.owner.GetGame()).SpawnItemDrop(scriptInterface.owner, weaponID, worldPosition, dropRotation);
  }

  protected final func CreateAndSendFirstEquipEndRequest(scriptInterface: ref<StateGameScriptInterface>, weaponTweakID: TweakDBID) -> Void {
    let firstEqSystem: ref<FirstEquipSystem> = FirstEquipSystem.GetInstance(scriptInterface.owner);
    let requestToSend: ref<CompletionOfFirstEquipRequest> = new CompletionOfFirstEquipRequest();
    requestToSend.weaponID = weaponTweakID;
    firstEqSystem.QueueRequest(requestToSend);
  }

  protected final const func GetSlotAttachedItemID(const scriptInterface: ref<StateGameScriptInterface>, stateMachineInstanceData: StateMachineInstanceData) -> ItemID {
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(stateMachineInstanceData.referenceName);
    let item: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot));
    if IsDefined(item) {
      return item.GetItemID();
    };
    return ItemID.undefined();
  }

  protected final const func GetSlotAttachedItemObject(const scriptInterface: ref<StateGameScriptInterface>, stateMachineInstanceData: StateMachineInstanceData) -> ref<ItemObject> {
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(stateMachineInstanceData.referenceName);
    return scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot));
  }

  protected final const func IsProperItemEquipped(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Bool {
    let item: ItemID = this.GetItemIDFromParam(stateMachineInstanceData, stateContext);
    let slotActiveItem: ItemID = this.GetSlotActiveItem(scriptInterface, stateMachineInstanceData);
    return item == slotActiveItem;
  }

  protected final const func GetSlotActiveItem(const scriptInterface: ref<StateGameScriptInterface>, stateMachineInstanceData: StateMachineInstanceData) -> ItemID {
    return EquipmentSystem.GetSlotActiveItem(scriptInterface.executionOwner, this.ReferenceNameToRequestSlot(stateMachineInstanceData));
  }

  protected final const func GetEquipDuration(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Float {
    switch this.GetItemCategoryFromItemID(this.GetSlotAttachedItemID(scriptInterface, stateMachineInstanceData)) {
      case gamedataItemCategory.Weapon:
        return this.GetWeaponEquipDuration(scriptInterface, stateContext, stateMachineInstanceData);
      case gamedataItemCategory.Consumable:
        return 0.00;
      case gamedataItemCategory.Gadget:
        return 0.00;
      case gamedataItemCategory.Cyberware:
        return this.GetWeaponEquipDuration(scriptInterface, stateContext, stateMachineInstanceData);
    };
    return 1.00;
  }

  protected final const func GetUnequipDuration(const scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Float {
    switch this.GetItemCategoryFromItemID(this.GetSlotAttachedItemID(scriptInterface, stateMachineInstanceData)) {
      case gamedataItemCategory.Weapon:
        return this.GetWeaponUnEquipDuration(scriptInterface, stateContext, stateMachineInstanceData);
      case gamedataItemCategory.Consumable:
        return this.GetConsumableUnEquipDuration(stateMachineInstanceData, stateContext);
      case gamedataItemCategory.Gadget:
        return 0.00;
      case gamedataItemCategory.Cyberware:
        return 0.00;
      default:
        return 0.50;
    };
  }

  protected final const func IsLeftHandLogic(stateMachineInstanceData: StateMachineInstanceData) -> Bool {
    return Equals(stateMachineInstanceData.referenceName, n"LeftHand");
  }

  protected final const func IsRightHandLogic(stateMachineInstanceData: StateMachineInstanceData) -> Bool {
    return Equals(stateMachineInstanceData.referenceName, n"RightHand");
  }

  protected final const func AddConsumableStateMachine(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmAdd: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    psmAdd.stateMachineName = n"Consumable";
    scriptInterface.executionOwner.QueueEvent(psmAdd);
  }

  protected final const func RemoveConsumableStateMachine(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmIdent: StateMachineIdentifier;
    let psmRemove: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
    psmIdent.definitionName = n"Consumable";
    psmRemove.stateMachineIdentifier = psmIdent;
    scriptInterface.executionOwner.QueueEvent(psmRemove);
  }

  protected final const func AddGrenadesStateMachine(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmAdd: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    psmAdd.stateMachineName = n"CombatGadget";
    scriptInterface.executionOwner.QueueEvent(psmAdd);
  }

  protected final const func RemoveGrenadesStateMachine(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmIdent: StateMachineIdentifier;
    let psmRemove: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
    psmIdent.definitionName = n"CombatGadget";
    psmRemove.stateMachineIdentifier = psmIdent;
    scriptInterface.executionOwner.QueueEvent(psmRemove);
  }

  protected final const func AddCyberwareStateMachine(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmAdd: ref<PSMAddOnDemandStateMachine> = new PSMAddOnDemandStateMachine();
    psmAdd.stateMachineName = n"LeftHandCyberware";
    scriptInterface.executionOwner.QueueEvent(psmAdd);
  }

  protected final const func RemoveCyberwareStateMachine(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmIdent: StateMachineIdentifier;
    let psmRemove: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
    psmIdent.definitionName = n"LeftHandCyberware";
    psmRemove.stateMachineIdentifier = psmIdent;
    scriptInterface.executionOwner.QueueEvent(psmRemove);
  }

  protected final const func SetRightHandItemParam(stateContext: ref<StateContext>, item: ItemID) -> Void {
    let wrapper: ref<ItemIdWrapper> = new ItemIdWrapper();
    wrapper.itemID = item;
    stateContext.SetPermanentScriptableParameter(n"rightHandItem", wrapper, true);
  }

  protected final const func ClearRightHandItemParam(stateContext: ref<StateContext>) -> Void {
    stateContext.RemovePermanentScriptableParameter(n"rightHandItem");
  }

  protected final const func SetLeftHandItemParam(stateContext: ref<StateContext>, item: ItemID) -> Void {
    let wrapper: ref<ItemIdWrapper> = new ItemIdWrapper();
    wrapper.itemID = item;
    stateContext.SetPermanentScriptableParameter(n"leftHandItem", wrapper, true);
  }

  protected final const func ClearLeftHandItemParam(stateContext: ref<StateContext>) -> Void {
    stateContext.RemovePermanentScriptableParameter(n"leftHandItem");
  }

  protected final const func ClearHandItemParam(stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData) -> Void {
    if this.IsRightHandLogic(stateMachineInstanceData) {
      this.ClearRightHandItemParam(stateContext);
    } else {
      if this.IsLeftHandLogic(stateMachineInstanceData) {
        this.ClearLeftHandItemParam(stateContext);
      };
    };
  }

  protected final const func GetItemIDFromParam(stateMachineInstanceData: StateMachineInstanceData, const stateContext: ref<StateContext>) -> ItemID {
    if this.IsRightHandLogic(stateMachineInstanceData) {
      return this.GetRightHandItemFromParam(stateContext);
    };
    if this.IsLeftHandLogic(stateMachineInstanceData) {
      return this.GetLeftHandItemFromParam(stateContext);
    };
    return ItemID.undefined();
  }

  protected final const func GetBlurParametersFromWeapon(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_WeaponBlur> = new AnimFeature_WeaponBlur();
    let weapon: ref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    let weaponTDB: TweakDBID = ItemID.GetTDBID(weapon.GetItemID());
    animFeature.weaponNearPlane = TDB.GetFloat(weaponTDB + t".weaponNearPlane");
    animFeature.weaponFarPlane = TDB.GetFloat(weaponTDB + t".weaponFarPlane");
    animFeature.weaponEdgesSharpness = TDB.GetFloat(weaponTDB + t".weaponEdgesSharpness");
    animFeature.weaponVignetteIntensity = TDB.GetFloat(weaponTDB + t".weaponVignetteIntensity");
    animFeature.weaponVignetteRadius = TDB.GetFloat(weaponTDB + t".weaponVignetteRadius");
    animFeature.weaponVignetteCircular = TDB.GetFloat(weaponTDB + t".weaponVignetteCircular");
    animFeature.weaponBlurIntensity = TDB.GetFloat(weaponTDB + t".weaponBlurIntensity");
    animFeature.weaponNearPlane_aim = TDB.GetFloat(weaponTDB + t".weaponNearPlane_aim");
    animFeature.weaponFarPlane_aim = TDB.GetFloat(weaponTDB + t".weaponFarPlane_aim");
    animFeature.weaponEdgesSharpness_aim = TDB.GetFloat(weaponTDB + t".weaponEdgesSharpness_aim");
    animFeature.weaponVignetteIntensity_aim = TDB.GetFloat(weaponTDB + t".weaponVignetteIntensity_aim");
    animFeature.weaponVignetteRadius_aim = TDB.GetFloat(weaponTDB + t".weaponVignetteRadius_aim");
    animFeature.weaponVignetteCircular_aim = TDB.GetFloat(weaponTDB + t".weaponVignetteCircular_aim");
    animFeature.weaponBlurIntensity_aim = TDB.GetFloat(weaponTDB + t".weaponBlurIntensity_aim");
    scriptInterface.SetAnimationParameterFeature(n"WeaponBlurData", animFeature);
  }

  protected final const func CanProcessEquip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let upperBodyState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody);
    return !this.IsPlayerInAnyMenu(scriptInterface) && this.CheckGenericEquipItemConditions(stateContext, scriptInterface) && upperBodyState != EnumInt(gamePSMUpperBodyStates.TemporaryUnequip) && (upperBodyState != EnumInt(gamePSMUpperBodyStates.ForceEmptyHands) || this.HasActiveConsumable(scriptInterface));
  }

  protected final const func CanProcessUnEquip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsPlayerInAnyMenu(scriptInterface);
  }
}

public class UnequippedDecisions extends EquipmentBaseDecisions {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  public const let stateMachineInitData: wref<EquipmentInitData>;

  protected final const func ToUnequippedWaitingForExternalFactors(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let upperBodyState: Int32;
    let equipRequestOccuredThisFrame: Bool = false;
    let hasEquipProcessedPrevFrame: Bool = false;
    if this.CheckSlotMatchAndCompareRequestType(stateContext, this.stateMachineInstanceData, this.stateMachineInitData, EquipmentManipulationRequestType.Equip) {
      this.SaveProcessedEquipmentManipulationRequest(stateContext, this.stateMachineInstanceData, this.stateMachineInitData);
      equipRequestOccuredThisFrame = true;
    };
    if !equipRequestOccuredThisFrame {
      hasEquipProcessedPrevFrame = IsDefined(this.GetProcessedEquipmentManipulationRequest(this.stateMachineInstanceData, stateContext));
    };
    if equipRequestOccuredThisFrame || hasEquipProcessedPrevFrame {
      return true;
    };
    if this.CheckReplicatedEquipRequest(scriptInterface, stateContext, this.stateMachineInstanceData) {
      return true;
    };
    upperBodyState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody);
    if !this.IsProperItemEquipped(scriptInterface, stateContext, this.stateMachineInstanceData) && this.IsRightHandLogic(this.stateMachineInstanceData) && upperBodyState != EnumInt(gamePSMUpperBodyStates.TemporaryUnequip) && upperBodyState != EnumInt(gamePSMUpperBodyStates.ForceEmptyHands) && NotEquals(this.GetItemCategoryFromItemID(this.GetSlotAttachedItemID(scriptInterface, this.stateMachineInstanceData)), gamedataItemCategory.Gadget) {
      return true;
    };
    return false;
  }
}

public class UnequippedEvents extends EquipmentBaseEvents {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  public const let stateMachineInitData: wref<EquipmentInitData>;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(this.stateMachineInstanceData.referenceName);
    let itemHandling: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    itemHandling.itemState = 0;
    scriptInterface.SetAnimationParameterFeature(mappedInstanceData.itemHandlingFeatureName, itemHandling);
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      this.ClearRightHandItemParam(stateContext);
    } else {
      if this.IsLeftHandLogic(this.stateMachineInstanceData) {
        this.ClearLeftHandItemParam(stateContext);
      };
    };
    this.ClearProcessedEquipmentManipulationRequest(this.stateMachineInstanceData, stateContext);
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.RemovePermanentScriptableParameter(this.stateMachineInitData.eqManipulationVarName);
  }
}

public class UnequippedWaitingForExternalFactorsDecisions extends EquipmentBaseDecisions {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  public const let stateMachineInitData: wref<EquipmentInitData>;

  protected final const func ExitCondition(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      if !this.CanProcessEquip(stateContext, scriptInterface) {
        return false;
      };
    } else {
      if this.IsLeftHandLogic(this.stateMachineInstanceData) {
        if !this.CheckGenericEquipItemConditions(stateContext, scriptInterface) || scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.ForceEmptyHands) {
          return false;
        };
      };
    };
    return true;
  }
}

public class SelfRemovalEvents extends StateFunctor {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  private final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let psmIdent: StateMachineIdentifier;
    let psmRemove: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
    psmIdent.definitionName = n"Equipment";
    psmIdent.referenceName = this.stateMachineInstanceData.referenceName;
    psmRemove.stateMachineIdentifier = psmIdent;
    scriptInterface.executionOwner.QueueEvent(psmRemove);
  }
}

public class EquippedDecisions extends EquipmentBaseDecisions {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  public const let stateMachineInitData: wref<EquipmentInitData>;

  protected final const func ToUnequipCycle(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let equipRequestOccuredThisFrame: Bool = false;
    let hasEquipProcessedPrevFrame: Bool = false;
    let upperBodyState: Int32 = 0;
    if this.CheckSlotMatchAndCompareRequestType(stateContext, this.stateMachineInstanceData, this.stateMachineInitData, EquipmentManipulationRequestType.Unequip) {
      this.SaveProcessedEquipmentManipulationRequest(stateContext, this.stateMachineInstanceData, this.stateMachineInitData);
      equipRequestOccuredThisFrame = true;
    };
    if this.CheckSlotMatchAndCompareRequestType(stateContext, this.stateMachineInstanceData, this.stateMachineInitData, EquipmentManipulationRequestType.Equip) && !this.IsProperItemEquipped(scriptInterface, stateContext, this.stateMachineInstanceData) {
      this.SaveProcessedEquipmentManipulationRequest(stateContext, this.stateMachineInstanceData, this.stateMachineInitData);
      equipRequestOccuredThisFrame = true;
    };
    if !equipRequestOccuredThisFrame {
      hasEquipProcessedPrevFrame = IsDefined(this.GetProcessedEquipmentManipulationRequest(this.stateMachineInstanceData, stateContext));
    };
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      if !this.CanProcessUnEquip(stateContext, scriptInterface) {
        return false;
      };
    };
    if equipRequestOccuredThisFrame || hasEquipProcessedPrevFrame {
      return true;
    };
    if this.CheckReplicatedEquipRequest(scriptInterface, stateContext, this.stateMachineInstanceData) {
      return true;
    };
    upperBodyState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody);
    if (upperBodyState == EnumInt(gamePSMUpperBodyStates.TemporaryUnequip) || upperBodyState == EnumInt(gamePSMUpperBodyStates.ForceEmptyHands)) && this.IsRightHandLogic(this.stateMachineInstanceData) {
      return true;
    };
    if !IsServer() {
      if !this.IsProperItemEquipped(scriptInterface, stateContext, this.stateMachineInstanceData) && this.IsRightHandLogic(this.stateMachineInstanceData) && NotEquals(this.GetItemCategoryFromItemID(this.GetSlotAttachedItemID(scriptInterface, this.stateMachineInstanceData)), gamedataItemCategory.Gadget) {
        return true;
      };
    };
    return false;
  }
}

public class EquippedEvents extends EquipmentBaseEvents {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  public const let stateMachineInitData: wref<EquipmentInitData>;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      MeleeTransition.ClearInputBuffer(stateContext);
      broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
      if !WeaponObject.IsFists(GameObject.GetActiveWeapon(scriptInterface.executionOwner).GetItemID()) && !stateContext.GetBoolParameter(n"weaponDisplayedStimuli", true) {
        if IsDefined(broadcaster) {
          broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.WeaponDisplayed);
        };
      } else {
        if WeaponObject.IsFists(GameObject.GetActiveWeapon(scriptInterface.executionOwner).GetItemID()) {
          if IsDefined(broadcaster) {
            broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.WeaponHolstered);
          };
        };
      };
      stateContext.RemovePermanentBoolParameter(n"weaponDisplayedStimuli");
    };
    this.ClearProcessedEquipmentManipulationRequest(this.stateMachineInstanceData, stateContext);
  }

  protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.RemovePermanentScriptableParameter(this.stateMachineInitData.eqManipulationVarName);
  }
}

public class EquipCycleInitDecisions extends EquipmentBaseDecisions {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  protected final const func ToEquipCycle(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsItemInSlot(scriptInterface, this.stateMachineInstanceData) || this.IsUsingFluffConsumable(scriptInterface, this.stateMachineInstanceData);
  }

  protected final const func ToUnequipped(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let threshold: Float = 1.00;
    if this.GetInStateTime() >= threshold {
      return true;
    };
    return false;
  }
}

public class EquipCycleInitEvents extends EquipmentBaseEvents {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let item: ItemID;
    let placementSlot: TweakDBID;
    let equipStartEvent: ref<EquipStart> = new EquipStart();
    let multiplayerRequestData: ref<parameterRequestItem> = stateContext.GetTemporaryScriptableParameter(n"cpo_replicatedEquipRequest") as parameterRequestItem;
    if multiplayerRequestData == null {
      multiplayerRequestData = stateContext.GetConditionScriptableParameter(n"cpo_replicatedEquipRequest") as parameterRequestItem;
      if multiplayerRequestData != null {
        stateContext.RemoveConditionScriptableParameter(n"cpo_replicatedEquipRequest");
      };
    };
    if IsServer() && multiplayerRequestData != null {
      item = multiplayerRequestData.requests[0].itemIDToEquip;
      placementSlot = multiplayerRequestData.requests[0].slotID;
    } else {
      item = this.GetSlotActiveItem(scriptInterface, this.stateMachineInstanceData);
      placementSlot = EquipmentSystem.GetPlacementSlot(item);
    };
    if ItemID.IsValid(item) {
      if IsClient() && scriptInterface.owner.IsControlledByLocalPeer() {
        scriptInterface.RequestWeaponEquipOnServer(placementSlot, item);
      };
      if !this.IsUsingFluffConsumable(scriptInterface, this.stateMachineInstanceData) {
        equipStartEvent.SetSlotID(placementSlot);
        equipStartEvent.SetItemID(item);
        equipStartEvent.SetHighPriority(NotEquals(WeaponObject.GetWeaponType(item), gamedataItemType.Invalid));
        if !stateContext.IsStateMachineActive(n"Vehicle") {
          equipStartEvent.SetStartingRenderingPlane(ERenderingPlane.RPl_Weapon);
        };
        equipStartEvent.SetFirstEquip(false);
        scriptInterface.executionOwner.QueueEvent(equipStartEvent);
      };
      if this.IsRightHandLogic(this.stateMachineInstanceData) {
        this.SetRightHandItemParam(stateContext, item);
      } else {
        if this.IsLeftHandLogic(this.stateMachineInstanceData) {
          this.SetLeftHandItemParam(stateContext, item);
        };
      };
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(this.stateMachineInstanceData.referenceName);
    let item: ItemID = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot)).GetItemID();
    if IsMultiplayer() {
      scriptInterface.GetTransactionSystem().SetActiveItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot), item);
    };
  }
}

public class EquipCycleDecisions extends EquipmentBaseDecisions {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  protected final const func ToEquipped(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let threshold: Float = this.GetEquipDuration(scriptInterface, stateContext, this.stateMachineInstanceData);
    let validPSMState: Bool = this.GetIsPSMInValidState(scriptInterface, stateContext, this.stateMachineInstanceData);
    return !validPSMState || this.GetInStateTime() >= threshold;
  }

  protected final const func ToUnequipCycle(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return false;
  }

  protected final const func ToFirstEquip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let firstEqSystem: ref<FirstEquipSystem> = FirstEquipSystem.GetInstance(scriptInterface.owner);
    let firstEquipResult: StateResultBool = stateContext.GetConditionBoolParameter(n"firstEquip");
    let itemId: ItemID = this.GetSlotActiveItem(scriptInterface, this.stateMachineInstanceData);
    return firstEquipResult.value && this.ToEquipped(stateContext, scriptInterface) && !firstEqSystem.HasPlayedFirstEquip(ItemID.GetTDBID(itemId));
  }
}

public class EquipCycleEvents extends EquipmentBaseEvents {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let item: ItemID = this.GetItemIDFromParam(this.stateMachineInstanceData, stateContext);
    if !ItemID.IsValid(item) {
      return;
    };
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Weapon) {
        this.HandleWeaponEquip(scriptInterface, stateContext, this.stateMachineInstanceData, item);
        return;
      };
    };
    if this.IsLeftHandLogic(this.stateMachineInstanceData) {
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Consumable) {
        this.AddConsumableStateMachine(scriptInterface);
        return;
      };
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Gadget) {
        this.AddGrenadesStateMachine(scriptInterface);
        return;
      };
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Cyberware) {
        this.AddCyberwareStateMachine(scriptInterface);
        return;
      };
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let itemObject: wref<WeaponObject>;
    let item: ItemID = this.GetItemIDFromParam(this.stateMachineInstanceData, stateContext);
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(this.stateMachineInstanceData.referenceName);
    let animFeature: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    if !ItemID.IsValid(item) {
      return;
    };
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Weapon) {
        itemObject = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot)) as WeaponObject;
        animFeature.stateTransitionDuration = statSystem.GetStatValue(Cast(itemObject.GetEntityID()), gamedataStatType.UnequipDuration);
        animFeature.itemState = 2;
        animFeature.itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ItemType().AnimFeatureIndex();
        scriptInterface.SetAnimationParameterFeature(mappedInstanceData.itemHandlingFeatureName, animFeature, scriptInterface.executionOwner);
        scriptInterface.SetAnimationParameterFeature(n"equipUnequipItem", animFeature, itemObject);
      };
    };
  }
}

public class FirstEquipDecisions extends EquipmentBaseDecisions {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  public const let stateMachineInitData: wref<EquipmentInitData>;

  protected final const func ToEquipped(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let leftHandCyberState: gamePSMLeftHandCyberware;
    let locomotionDetailedState: Int32;
    let threshold: Float;
    let upperBodyState: Int32;
    let weapon: wref<WeaponObject>;
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let validPSMState: Bool = this.GetIsPSMInValidState(scriptInterface, stateContext, this.stateMachineInstanceData);
    let isAiming: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
    if isAiming {
      return true;
    };
    upperBodyState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody);
    locomotionDetailedState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed);
    if stateContext.IsStateMachineActive(n"CombatGadget") || stateContext.IsStateMachineActive(n"LocomotionSwimming") || stateContext.IsStateMachineActive(n"Vehicle") || stateContext.IsStateMachineActive(n"CarriedObject") || stateContext.IsStateMachineActive(n"Consumable") || stateContext.IsStateMachineActive(n"LocomotionTakedown") || upperBodyState == EnumInt(gamePSMUpperBodyStates.TemporaryUnequip) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.Climb) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.Ladder) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.LadderSprint) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.LadderSlide) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.Vault) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.SuperheroFall) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.Slide) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.SlideFall) {
      return true;
    };
    leftHandCyberState = IntEnum(scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware));
    if NotEquals(leftHandCyberState, gamePSMLeftHandCyberware.Safe) && NotEquals(leftHandCyberState, gamePSMLeftHandCyberware.Default) && NotEquals(leftHandCyberState, gamePSMLeftHandCyberware.Idle) {
      return true;
    };
    if !validPSMState {
      return true;
    };
    weapon = this.GetSlotAttachedItemObject(scriptInterface, this.stateMachineInstanceData) as WeaponObject;
    threshold = statSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.EquipDuration_First) - statSystem.GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.EquipDuration);
    if this.GetInStateTime() >= threshold {
      return true;
    };
    if this.CheckSlotMatchAndCompareRequestType(stateContext, this.stateMachineInstanceData, this.stateMachineInitData, EquipmentManipulationRequestType.Unequip) {
      return true;
    };
    if this.CheckSlotMatchAndCompareRequestType(stateContext, this.stateMachineInstanceData, this.stateMachineInitData, EquipmentManipulationRequestType.Equip) && !this.IsProperItemEquipped(scriptInterface, stateContext, this.stateMachineInstanceData) {
      return true;
    };
    return false;
  }
}

public class FirstEquipEvents extends EquipmentBaseEvents {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  public const let stateMachineInitData: wref<EquipmentInitData>;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      if !WeaponObject.IsFists(GameObject.GetActiveWeapon(scriptInterface.executionOwner).GetItemID()) {
        broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
        if IsDefined(broadcaster) {
          broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.WeaponDisplayed);
        };
        stateContext.SetPermanentBoolParameter(n"weaponDisplayedStimuli", true, true);
      };
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(this.stateMachineInstanceData.referenceName);
    let itemObject: wref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot)) as WeaponObject;
    this.CreateAndSendFirstEquipEndRequest(scriptInterface, ItemID.GetTDBID(itemObject.GetItemID()));
    scriptInterface.PushAnimationEvent(n"FirstEquipEnd");
    stateContext.SetConditionBoolParameter(n"firstEquip", false, true);
    stateContext.RemovePermanentScriptableParameter(this.stateMachineInitData.eqManipulationVarName);
  }
}

public class UnequipCycleDecisions extends EquipmentBaseDecisions {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  protected final const func ToEquipCycleInit(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let threshold: Float = this.GetUnequipDuration(scriptInterface, stateContext, this.stateMachineInstanceData);
    let itemId: ItemID = this.GetSlotActiveItem(scriptInterface, this.stateMachineInstanceData);
    let upperBodyState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody);
    let smConditions: Bool = upperBodyState == EnumInt(gamePSMUpperBodyStates.TemporaryUnequip) || upperBodyState == EnumInt(gamePSMUpperBodyStates.ForceEmptyHands) || Equals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"entering") || Equals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"switchSeats");
    return this.GetInStateTime() >= threshold && itemId != ItemID.undefined() && !smConditions;
  }

  protected final const func ToUnequipped(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let threshold: Float = this.GetUnequipDuration(scriptInterface, stateContext, this.stateMachineInstanceData);
    let upperBodyState: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody);
    if this.GetInStateTime() >= threshold && this.GetSlotActiveItem(scriptInterface, this.stateMachineInstanceData) == ItemID.undefined() {
      if this.IsLeftHandLogic(this.stateMachineInstanceData) {
        return !stateContext.IsStateMachineActive(n"Consumable") && !stateContext.IsStateMachineActive(n"CombatGadget");
      };
      if this.IsRightHandLogic(this.stateMachineInstanceData) {
        return true;
      };
    } else {
      if (upperBodyState == EnumInt(gamePSMUpperBodyStates.TemporaryUnequip) || upperBodyState == EnumInt(gamePSMUpperBodyStates.ForceEmptyHands) || Equals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"entering") || Equals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"switchSeats")) && this.IsRightHandLogic(this.stateMachineInstanceData) {
        return true;
      };
    };
    return false;
  }
}

public class UnequipCycleEvents extends EquipmentBaseEvents {

  public const let stateMachineInstanceData: StateMachineInstanceData;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let item: ItemID = this.GetItemIDFromParam(this.stateMachineInstanceData, stateContext);
    if !ItemID.IsValid(item) {
      return;
    };
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Weapon) {
        this.HandleWeaponUnequip(scriptInterface, stateContext, this.stateMachineInstanceData, item);
      };
    };
    if this.IsLeftHandLogic(this.stateMachineInstanceData) {
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Consumable) {
        return;
      };
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Gadget) {
        return;
      };
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Cyberware) {
        this.RemoveCyberwareStateMachine(scriptInterface);
        return;
      };
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let itemObject: wref<GameObject>;
    let item: ItemID = this.GetItemIDFromParam(this.stateMachineInstanceData, stateContext);
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(this.stateMachineInstanceData.referenceName);
    let unequipEndEvent: ref<UnequipEnd> = new UnequipEnd();
    let animFeature: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let placementSlot: TweakDBID = EquipmentSystem.GetPlacementSlot(item);
    let upperBodyState: Int32 = 0;
    if !ItemID.IsValid(item) {
      return;
    };
    unequipEndEvent.SetSlotID(placementSlot);
    scriptInterface.executionOwner.QueueEvent(unequipEndEvent);
    if this.IsRightHandLogic(this.stateMachineInstanceData) {
      if Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Weapon) {
        animFeature.stateTransitionDuration = statSystem.GetStatValue(Cast(scriptInterface.executionOwnerEntityID), gamedataStatType.UnequipDuration);
        animFeature.itemState = 4;
        animFeature.itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ItemType().AnimFeatureIndex();
        scriptInterface.SetAnimationParameterFeature(mappedInstanceData.itemHandlingFeatureName, animFeature, scriptInterface.executionOwner);
        itemObject = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot));
        scriptInterface.SetAnimationParameterFeature(n"equipUnequipItem", animFeature, itemObject);
        upperBodyState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody);
        if (Equals(this.GetEquipAreaFromItemID(item), gamedataEquipmentArea.WeaponHeavy) || (itemObject as ItemObject).GetItemData().HasTag(n"DiscardOnEmpty")) && upperBodyState != EnumInt(gamePSMUpperBodyStates.ForceEmptyHands) {
          this.DropActiveWeapon(scriptInterface, stateContext, this.stateMachineInstanceData);
        };
      };
    };
  }
}
