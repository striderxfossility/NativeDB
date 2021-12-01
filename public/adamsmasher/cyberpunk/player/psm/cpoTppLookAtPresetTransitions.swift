
public abstract class LookAtPresetBaseDecisions extends DefaultTransition {

  public final const func HasItemEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let equippedItemType: gamedataItemType;
    let equippedObject: ref<ItemObject>;
    let desiredTypeStr: String = this.GetStaticStringParameterDefault("itemType", "");
    let desiredItemType: gamedataItemType = IntEnum(Cast(EnumValueFromString("gamedataItemType", desiredTypeStr)));
    if this.GetStaticBoolParameterDefault("leftHandItem", false) {
      equippedObject = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft");
    } else {
      equippedObject = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
    };
    if equippedObject == null {
      return false;
    };
    equippedItemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(equippedObject.GetItemID())).ItemType().Type();
    return Equals(desiredItemType, equippedItemType);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.HasItemEquipped(scriptInterface) {
      return true;
    };
    return false;
  }

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.HasItemEquipped(scriptInterface) {
      return true;
    };
    return false;
  }
}

public abstract class LookAtPresetBaseEvents extends DefaultTransition {

  public let m_lookAtEvents: array<ref<LookAtAddEvent>>;

  public let m_attachLeft: Bool;

  public let m_attachRight: Bool;

  public final static func GetLookatPartsRequests(lookatPresetRecord: wref<LookAtPreset_Record>, out lookAtParts: array<LookAtPartRequest>) -> Void {
    let i: Int32;
    let lookAtPartRequest: LookAtPartRequest;
    let partRecords: array<wref<LookAtPart_Record>>;
    lookatPresetRecord.LookAtParts(partRecords);
    i = 0;
    while i < ArraySize(partRecords) {
      lookAtPartRequest.partName = partRecords[i].PartName();
      lookAtPartRequest.weight = partRecords[i].Weight();
      lookAtPartRequest.suppress = partRecords[i].Suppress();
      lookAtPartRequest.mode = partRecords[i].Mode();
      ArrayPush(lookAtParts, lookAtPartRequest);
      i += 1;
    };
  }

  public final static func AddLookat(scriptInterface: ref<StateGameScriptInterface>, recordID: TweakDBID, priority: Int32, out lookAtEventsArray: array<ref<LookAtAddEvent>>, out attachLeft: Bool, out attachRight: Bool) -> Void {
    let facingPosProvider: ref<LookAtFacingPositionProvider>;
    let lookAtEvent: ref<LookAtAddEvent>;
    let lookAtPartRequests: array<LookAtPartRequest>;
    let lookatPreset: wref<LookAtPreset_Record> = TweakDBInterface.GetLookAtPresetRecord(recordID);
    if !IsDefined(lookatPreset) {
      return;
    };
    lookAtEvent = new LookAtAddEvent();
    facingPosProvider = new LookAtFacingPositionProvider();
    facingPosProvider.SetCameraComponent(scriptInterface.executionOwner);
    lookAtEvent.targetPositionProvider = facingPosProvider;
    lookAtEvent.bodyPart = lookatPreset.BodyPart();
    lookAtEvent.request.transitionSpeed = lookatPreset.TransitionSpeed();
    lookAtEvent.request.hasOutTransition = lookatPreset.HasOutTransition();
    lookAtEvent.request.outTransitionSpeed = lookatPreset.OutTransitionSpeed();
    lookAtEvent.request.limits.softLimitDegrees = lookatPreset.SoftLimitDegrees();
    lookAtEvent.request.limits.hardLimitDegrees = lookatPreset.HardLimitDegrees();
    lookAtEvent.request.limits.hardLimitDistance = lookatPreset.HardLimitDistance();
    lookAtEvent.request.limits.backLimitDegrees = lookatPreset.BackLimitDegrees();
    lookAtEvent.request.calculatePositionInParentSpace = lookatPreset.CalculatePositionInParentSpace();
    if !IsFinal() {
      lookAtEvent.SetDebugInfo("Gameplay " + TDBID.ToStringDEBUG(lookatPreset.GetID()));
    };
    lookAtEvent.request.suppress = lookatPreset.Suppress();
    lookAtEvent.request.mode = lookatPreset.Mode();
    lookAtEvent.request.priority = priority;
    LookAtPresetBaseEvents.GetLookatPartsRequests(lookatPreset, lookAtPartRequests);
    lookAtEvent.SetAdditionalPartsArray(lookAtPartRequests);
    scriptInterface.executionOwner.QueueEvent(lookAtEvent);
    ArrayPush(lookAtEventsArray, lookAtEvent);
    attachLeft = lookatPreset.AttachLeftHandtoRightHand();
    attachRight = lookatPreset.AttachRightHandtoLeftHand();
  }

  public final func SetHandAttachAnimVars(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    AnimationControllerComponent.SetInputFloatToReplicate(scriptInterface.executionOwner, n"pla_left_hand_attach", this.m_attachLeft ? 1.00 : 0.00);
    AnimationControllerComponent.SetInputFloatToReplicate(scriptInterface.executionOwner, n"pla_right_hand_attach", this.m_attachRight ? 1.00 : 0.00);
  }

  public final func AddAllLookAtsInList(scriptInterface: ref<StateGameScriptInterface>, presetNames: array<String>, priority: Int32, out lookAtEventsArray: array<ref<LookAtAddEvent>>) -> Void {
    let attachLeftReturn: Bool;
    let attachRightReturn: Bool;
    this.m_attachLeft = false;
    this.m_attachRight = false;
    let i: Int32 = 0;
    while i < ArraySize(presetNames) {
      LookAtPresetBaseEvents.AddLookat(scriptInterface, TDBID.Create("LookatPreset." + presetNames[i]), priority, lookAtEventsArray, attachLeftReturn, attachRightReturn);
      this.m_attachLeft = this.m_attachLeft || attachLeftReturn;
      this.m_attachRight = this.m_attachRight || attachRightReturn;
      i += 1;
    };
    this.SetHandAttachAnimVars(scriptInterface);
  }

  public final static func RemoveAddedLookAts(scriptInterface: ref<StateGameScriptInterface>, out lookAtEventsArray: array<ref<LookAtAddEvent>>) -> Void {
    let lookAtEvent: ref<LookAtAddEvent>;
    let i: Int32 = 0;
    while i < ArraySize(lookAtEventsArray) {
      lookAtEvent = lookAtEventsArray[i];
      if !IsDefined(lookAtEvent) {
      } else {
        LookAtRemoveEvent.QueueRemoveLookatEvent(scriptInterface.executionOwner, lookAtEvent);
      };
      i += 1;
    };
    ArrayClear(lookAtEventsArray);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.AddAllLookAtsInList(scriptInterface, this.GetStaticStringArrayParameter("lookAtPresetNames"), 1, this.m_lookAtEvents);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    LookAtPresetBaseEvents.RemoveAddedLookAts(scriptInterface, this.m_lookAtEvents);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    LookAtPresetBaseEvents.RemoveAddedLookAts(scriptInterface, this.m_lookAtEvents);
  }
}

public class lookAtPresetGunBaseEvents extends LookAtPresetBaseEvents {

  public let m_overrideLookAtEvents: array<ref<LookAtAddEvent>>;

  public let m_gunState: Int32;

  public let m_originalAttachLeft: Bool;

  public let m_originalAttachRight: Bool;

  public final static func IsReloading(const stateContext: ref<StateContext>) -> Bool {
    return Equals(stateContext.GetStateMachineCurrentState(n"Weapon"), n"reload");
  }

  public final static func IsInSafeMode(const stateContext: ref<StateContext>) -> Bool {
    return Equals(stateContext.GetStateMachineCurrentState(n"Weapon"), n"publicSafe");
  }

  public final func SetGunState(scriptInterface: ref<StateGameScriptInterface>, const newGunState: Int32) -> Void {
    if this.m_gunState != newGunState {
      LookAtPresetBaseEvents.RemoveAddedLookAts(scriptInterface, this.m_overrideLookAtEvents);
      this.m_gunState = newGunState;
      if this.m_gunState == 1 {
        this.AddAllLookAtsInList(scriptInterface, this.GetStaticStringArrayParameter("safeLookAtPresetNames"), 0, this.m_overrideLookAtEvents);
      } else {
        if this.m_gunState == 2 {
          this.AddAllLookAtsInList(scriptInterface, this.GetStaticStringArrayParameter("reloadLookAtPresetNames"), 0, this.m_overrideLookAtEvents);
        } else {
          this.m_attachLeft = this.m_originalAttachLeft;
          this.m_attachRight = this.m_originalAttachRight;
          this.SetHandAttachAnimVars(scriptInterface);
        };
      };
    };
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.m_originalAttachLeft = this.m_attachLeft;
    this.m_originalAttachRight = this.m_attachRight;
    this.m_gunState = 0;
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if lookAtPresetGunBaseEvents.IsReloading(stateContext) {
      this.SetGunState(scriptInterface, 2);
    } else {
      if lookAtPresetGunBaseEvents.IsInSafeMode(stateContext) {
        this.SetGunState(scriptInterface, 1);
      } else {
        this.SetGunState(scriptInterface, 0);
      };
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetGunState(scriptInterface, 0);
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetGunState(scriptInterface, 0);
    this.OnExit(stateContext, scriptInterface);
  }
}

public class UnarmedLookAtDecisions extends LookAtPresetBaseDecisions {

  protected const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if IsDefined(DefaultTransition.GetActiveWeapon(scriptInterface)) || IsDefined(DefaultTransition.GetActiveLeftHandItem(scriptInterface)) {
      return true;
    };
    return false;
  }
}
