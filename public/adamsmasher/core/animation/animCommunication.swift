
public static func CreateRagdollActivationRequestEvent(activationType: entragdollActivationRequestType, filterDataOverride: CName, applyPowerPose: Bool, applyMomentum: Bool, debugSourceName: CName) -> ref<RagdollActivationRequestEvent> {
  let evt: ref<RagdollActivationRequestEvent> = new RagdollActivationRequestEvent();
  evt.data.type = activationType;
  evt.data.applyPowerPose = applyPowerPose;
  evt.data.applyMomentum = applyMomentum;
  evt.data.filterDataOverride = filterDataOverride;
  evt.DebugSetSourceName(debugSourceName);
  return evt;
}

public static func CreateRagdollEvent(debugSourceName: CName) -> ref<RagdollActivationRequestEvent> {
  return CreateRagdollActivationRequestEvent(entragdollActivationRequestType.Default, n"", true, true, debugSourceName);
}

public static func CreateForceRagdollEvent(debugSourceName: CName) -> ref<RagdollActivationRequestEvent> {
  return CreateRagdollActivationRequestEvent(entragdollActivationRequestType.Forced, n"", true, true, debugSourceName);
}

public static func CreateForceRagdollWithCustomFilterDataEvent(customFilterData: CName, debugSourceName: CName) -> ref<RagdollActivationRequestEvent> {
  return CreateRagdollActivationRequestEvent(entragdollActivationRequestType.Forced, customFilterData, true, true, debugSourceName);
}

public static func CreateForceRagdollNoPowerPoseEvent(debugSourceName: CName) -> ref<RagdollActivationRequestEvent> {
  return CreateRagdollActivationRequestEvent(entragdollActivationRequestType.Forced, n"", false, true, debugSourceName);
}

public static func CreateDisableRagdollEvent() -> ref<RagdollDisableEvent> {
  let evt: ref<RagdollDisableEvent> = new RagdollDisableEvent();
  return evt;
}

public static func CreateDisableRagdollComponentEvent() -> ref<DisableRagdollComponentEvent> {
  let evt: ref<DisableRagdollComponentEvent> = new DisableRagdollComponentEvent();
  return evt;
}

public static func CreateRagdollApplyImpulseEvent(worldPos: Vector4, imuplseVal: Vector4, influenceRadius: Float) -> ref<RagdollApplyImpulseEvent> {
  let evt: ref<RagdollApplyImpulseEvent> = new RagdollApplyImpulseEvent();
  evt.worldImpulsePos = worldPos;
  evt.worldImpulseValue = imuplseVal;
  evt.influenceRadius = influenceRadius;
  return evt;
}
