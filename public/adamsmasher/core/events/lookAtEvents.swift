
public native class LookAtRemoveEvent extends Event {

  private native let lookAtRef: LookAtRef;

  public final static func QueueRemoveLookatEvent(owner: ref<GameObject>, addedBeforeEvent: ref<LookAtAddEvent>) -> Void {
    let removeLookatEvent: ref<LookAtRemoveEvent> = new LookAtRemoveEvent();
    removeLookatEvent.lookAtRef = addedBeforeEvent.outLookAtRef;
    addedBeforeEvent.request.invalid = true;
    owner.QueueEvent(removeLookatEvent);
  }

  public final static func QueueDelayedRemoveLookatEvent(context: ScriptExecutionContext, addedBeforeEvent: ref<LookAtAddEvent>, lookAtDeactivationDelay: Float) -> Void {
    let removeLookatEvent: ref<LookAtRemoveEvent> = new LookAtRemoveEvent();
    removeLookatEvent.lookAtRef = addedBeforeEvent.outLookAtRef;
    addedBeforeEvent.request.invalid = true;
    GameInstance.GetDelaySystem(ScriptExecutionContext.GetOwner(context).GetGame()).DelayEvent(ScriptExecutionContext.GetOwner(context), removeLookatEvent, lookAtDeactivationDelay);
  }
}

public abstract class AIActionLookat extends IScriptable {

  public final static func Activate(const context: ScriptExecutionContext, record: wref<AIActionLookAtData_Record>, out lookAtEvent: ref<LookAtAddEvent>) -> Void {
    let lookAtPartRequests: array<LookAtPartRequest>;
    let lookAtPosition: Vector4;
    let lookAtTarget: wref<GameObject>;
    let lookAtTargetSP: wref<ScriptedPuppet>;
    let realPositionProvider: ref<IPositionProvider>;
    let targetSlot: CName;
    let tmpPositionProvider: ref<IPositionProvider>;
    let trackingMode: gamedataTrackingMode;
    let lookAtOffset: Vector4 = Vector4.Vector3To4(record.Offset());
    let lookatPreset: wref<LookAtPreset_Record> = record.Preset();
    let ownerSP: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(lookatPreset) {
      return;
    };
    AIActionTarget.Get(context, record.Target(), false, lookAtTarget, lookAtPosition);
    if !IsDefined(lookAtTarget) && Vector4.IsZero(lookAtPosition) {
      return;
    };
    lookAtEvent = new LookAtAddEvent();
    lookAtTargetSP = lookAtTarget as ScriptedPuppet;
    if IsDefined(record.Target().TrackingMode()) {
      trackingMode = record.Target().TrackingMode().Type();
    } else {
      trackingMode = gamedataTrackingMode.RealPosition;
    };
    targetSlot = record.Target().TargetSlot();
    if NotEquals(targetSlot, n"") {
      realPositionProvider = IPositionProvider.CreateSlotPositionProvider(lookAtTarget, targetSlot, record.Offset());
    } else {
      realPositionProvider = IPositionProvider.CreateEntityPositionProvider(lookAtTarget, record.Offset());
    };
    if IsDefined(lookAtTargetSP) || IsDefined(lookAtTarget as Device) {
      if IsDefined(lookAtTargetSP) && record.TimeDelay() > 0.00 && IsDefined(lookAtTargetSP.GetTransformHistoryComponent()) {
        lookAtEvent.SetEntityTargetFromPast(lookAtTargetSP.GetTransformHistoryComponent(), record.TimeDelay(), lookAtOffset);
      } else {
        switch trackingMode {
          case gamedataTrackingMode.RealPosition:
            lookAtEvent.SetEntityTarget(lookAtTarget, targetSlot, lookAtOffset);
            break;
          case gamedataTrackingMode.LastKnownPosition:
            tmpPositionProvider = ownerSP.GetTargetTrackerComponent().GetThreatBeliefPositionProvider(lookAtTarget, record.Offset(), true, targetSlot, realPositionProvider);
            lookAtEvent.SetPositionProvider(ownerSP.GetTargetTrackerComponent().GetThreatLastKnownPositionProvider(lookAtTarget, record.Offset(), true, targetSlot, tmpPositionProvider));
            break;
          case gamedataTrackingMode.BeliefPosition:
            lookAtEvent.SetPositionProvider(ownerSP.GetTargetTrackerComponent().GetThreatBeliefPositionProvider(lookAtTarget, record.Offset(), true, targetSlot, realPositionProvider));
            break;
          case gamedataTrackingMode.SharedLastKnownPosition:
            tmpPositionProvider = ownerSP.GetTargetTrackerComponent().GetThreatBeliefPositionProvider(lookAtTarget, record.Offset(), true, targetSlot, realPositionProvider);
            lookAtEvent.SetPositionProvider(ownerSP.GetTargetTrackerComponent().GetThreatSharedLastKnownPositionProvider(lookAtTarget, record.Offset(), true, targetSlot, tmpPositionProvider));
            break;
          case gamedataTrackingMode.SharedBeliefPosition:
            lookAtEvent.SetPositionProvider(ownerSP.GetTargetTrackerComponent().GetThreatSharedBeliefPositionProvider(lookAtTarget, record.Offset(), true, targetSlot, realPositionProvider));
        };
      };
    } else {
      lookAtEvent.SetStaticTarget(lookAtPosition + lookAtOffset);
    };
    lookAtEvent.bodyPart = lookatPreset.BodyPart();
    lookAtEvent.request.transitionSpeed = lookatPreset.TransitionSpeed();
    lookAtEvent.request.hasOutTransition = lookatPreset.HasOutTransition();
    lookAtEvent.request.outTransitionSpeed = lookatPreset.OutTransitionSpeed();
    lookAtEvent.request.followingSpeedFactorOverride = lookatPreset.FollowingSpeedFactorOverride();
    lookAtEvent.request.limits.softLimitDegrees = lookatPreset.SoftLimitDegrees();
    lookAtEvent.request.limits.hardLimitDegrees = lookatPreset.HardLimitDegrees();
    lookAtEvent.request.limits.hardLimitDistance = lookatPreset.HardLimitDistance();
    lookAtEvent.request.limits.backLimitDegrees = lookatPreset.BackLimitDegrees();
    lookAtEvent.request.calculatePositionInParentSpace = lookatPreset.CalculatePositionInParentSpace();
    if !IsFinal() {
      lookAtEvent.SetDebugInfo("Gameplay " + TDBID.ToStringDEBUG(lookatPreset.GetID()));
    };
    AIActionLookat.GetLookatPartsRequests(lookatPreset, lookAtPartRequests);
    lookAtEvent.SetAdditionalPartsArray(lookAtPartRequests);
    ScriptExecutionContext.GetOwner(context).QueueEvent(lookAtEvent);
    AnimationControllerComponent.SetInputFloatToReplicate(ScriptExecutionContext.GetOwner(context), n"pla_left_hand_attach", lookatPreset.AttachLeftHandtoRightHand() ? 1.00 : 0.00);
    AnimationControllerComponent.SetInputFloatToReplicate(ScriptExecutionContext.GetOwner(context), n"pla_right_hand_attach", lookatPreset.AttachRightHandtoLeftHand() ? 1.00 : 0.00);
  }

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

  public final static func Deactivate(owner: wref<GameObject>, out lookAtAddEvents: array<ref<LookAtAddEvent>>) -> Void {
    let lookAtEvent: ref<LookAtAddEvent>;
    let i: Int32 = ArraySize(lookAtAddEvents) - 1;
    while i >= 0 {
      lookAtEvent = lookAtAddEvents[i];
      if !IsDefined(lookAtEvent) {
      } else {
        LookAtRemoveEvent.QueueRemoveLookatEvent(owner, lookAtEvent);
        ArrayErase(lookAtAddEvents, i);
      };
      i -= 1;
    };
  }
}
