
public static exec func AnimationSystemSetForcedVisibleTrueTest(gameInstance: GameInstance) -> Void {
  let angleDist: EulerAngles;
  let target: ref<GameObject>;
  let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  if IsDefined(targetingSystem) {
    target = targetingSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
    if IsDefined(target) {
      GameInstance.GetAnimationSystem(gameInstance).SetForcedVisible(target.GetEntityID(), true);
    } else {
      Log("Finding target failed");
    };
  } else {
    Log("Finding target system failed");
  };
}

public static exec func AnimationSystemSetForcedVisibleFalseTest(gameInstance: GameInstance) -> Void {
  let angleDist: EulerAngles;
  let target: ref<GameObject>;
  let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  if IsDefined(targetingSystem) {
    target = targetingSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
    if IsDefined(target) {
      GameInstance.GetAnimationSystem(gameInstance).SetForcedVisible(target.GetEntityID(), false);
    } else {
      Log("Finding target failed");
    };
  } else {
    Log("Finding target system failed");
  };
}

public static exec func AnimWrapperWeightSetterTest(gameInstance: GameInstance, keyStr: String, valueStr: String) -> Void {
  let angleDist: EulerAngles;
  let ev: ref<AnimWrapperWeightSetter>;
  let target: ref<GameObject>;
  let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  if IsDefined(targetingSystem) {
    target = targetingSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
    if IsDefined(target) {
      ev = new AnimWrapperWeightSetter();
      ev.key = StringToName(keyStr);
      ev.value = StringToFloat(valueStr);
      target.QueueEvent(ev);
    } else {
      Log("Finding target failed");
    };
  } else {
    Log("Finding target system failed");
  };
}

public static exec func LookAtAdd(gameInstance: GameInstance, xStr: String, yStr: String, zStr: String, part: String) -> Void {
  let angleDist: EulerAngles;
  let ev: ref<LookAtAddEvent>;
  let target: ref<GameObject>;
  let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  if IsDefined(targetingSystem) {
    target = targetingSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
    if IsDefined(target) {
      ev = new LookAtAddEvent();
      if NotEquals(part, "") {
        ev.bodyPart = StringToName(part);
      };
      ev.SetStaticTarget(new Vector4(StringToFloat(xStr), StringToFloat(yStr), StringToFloat(zStr), 1.00));
      ev.SetLimits(animLookAtLimitDegreesType.Wide, IntEnum(3l), IntEnum(3l), IntEnum(3l));
      target.QueueEvent(ev);
    } else {
      Log("Finding target failed");
    };
  } else {
    Log("Finding target system failed");
  };
}

public static exec func LookAtAddWithOffset(gameInstance: GameInstance, xStr: String, yStr: String, zStr: String) -> Void {
  let angleDist: EulerAngles;
  let ev: ref<LookAtAddEvent>;
  let target: ref<GameObject>;
  let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  if IsDefined(targetingSystem) {
    target = targetingSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
    if IsDefined(target) {
      ev = new LookAtAddEvent();
      ev.SetEntityTarget(target, n"", new Vector4(StringToFloat(xStr), StringToFloat(yStr), StringToFloat(zStr), 1.00));
      ev.SetLimits(animLookAtLimitDegreesType.Wide, IntEnum(3l), IntEnum(3l), IntEnum(3l));
      target.QueueEvent(ev);
    } else {
      Log("Finding target failed");
    };
  } else {
    Log("Finding target system failed");
  };
}

public static exec func LookAtAddPlayerCameraSlot(gameInstance: GameInstance) -> Void {
  let angleDist: EulerAngles;
  let ev: ref<LookAtAddEvent>;
  let target: ref<GameObject>;
  let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  if IsDefined(targetingSystem) {
    target = targetingSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
    if IsDefined(target) {
      ev = new LookAtAddEvent();
      ev.SetEntityTarget(GetPlayer(gameInstance), n"camera", Vector4.EmptyVector());
      ev.SetLimits(animLookAtLimitDegreesType.Narrow, animLookAtLimitDegreesType.Normal, animLookAtLimitDistanceType.Normal, IntEnum(3l));
      if !IsDefined(GetPlayer(gameInstance)) {
        Log("Finding player failed");
      };
      target.QueueEvent(ev);
    } else {
      Log("Finding target failed");
    };
  } else {
    Log("Finding target system failed");
  };
}

public static exec func LookAtAddPlayerCameraSlotWithHands(gameInstance: GameInstance) -> Void {
  let angleDist: EulerAngles;
  let evEyes: ref<LookAtAddEvent>;
  let evLeftHand: ref<LookAtAddEvent>;
  let evRightHand: ref<LookAtAddEvent>;
  let target: ref<GameObject>;
  let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  if IsDefined(targetingSystem) {
    target = targetingSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
    if IsDefined(target) {
      if !IsDefined(GetPlayer(gameInstance)) {
        Log("Finding player failed");
      };
      evEyes = new LookAtAddEvent();
      evEyes.SetEntityTarget(GetPlayer(gameInstance), n"camera", Vector4.EmptyVector());
      evEyes.SetLimits(animLookAtLimitDegreesType.Wide, IntEnum(3l), IntEnum(3l), IntEnum(3l));
      target.QueueEvent(evEyes);
      evLeftHand = new LookAtAddEvent();
      evLeftHand.bodyPart = n"LeftHand";
      evLeftHand.SetEntityTarget(GetPlayer(gameInstance), n"camera", Vector4.EmptyVector());
      evLeftHand.SetLimits(animLookAtLimitDegreesType.Wide, IntEnum(3l), IntEnum(3l), IntEnum(3l));
      target.QueueEvent(evLeftHand);
      evRightHand = new LookAtAddEvent();
      evRightHand.bodyPart = n"RightHand";
      evRightHand.SetEntityTarget(GetPlayer(gameInstance), n"camera", Vector4.EmptyVector());
      evRightHand.SetLimits(animLookAtLimitDegreesType.Wide, IntEnum(3l), IntEnum(3l), IntEnum(3l));
      target.QueueEvent(evRightHand);
    } else {
      Log("Finding target failed");
    };
  } else {
    Log("Finding target system failed");
  };
}

public static exec func LookAtAddStaticLeftHand(gameInstance: GameInstance) -> Void {
  let angleDist: EulerAngles;
  let ev: ref<LookAtAddEvent>;
  let target: ref<GameObject>;
  let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(gameInstance);
  if IsDefined(targetingSystem) {
    target = targetingSystem.GetObjectClosestToCrosshair(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject(), angleDist, TSQ_ALL());
    if IsDefined(target) {
      ev = new LookAtAddEvent();
      ev.bodyPart = n"LeftHand";
      ev.SetStaticTarget(new Vector4(0.50, 2.00, 1.00, 1.00));
      if !IsDefined(GetPlayer(gameInstance)) {
        Log("Finding player failed");
      };
      target.QueueEvent(ev);
    } else {
      Log("Finding target failed");
    };
  } else {
    Log("Finding target system failed");
  };
}
