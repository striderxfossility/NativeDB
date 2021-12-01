
public static func OperatorEqual(goTarget: wref<GameObject>, target: ref<Target>) -> Bool {
  if goTarget == target.GetTarget() {
    return true;
  };
  return false;
}

public static func OperatorEqual(target: ref<Target>, goTarget: wref<GameObject>) -> Bool {
  if goTarget == target.GetTarget() {
    return true;
  };
  return false;
}

public class SimpleTargetManager extends ScriptableComponent {

  public final static func AddTarget(out targetsList: array<ref<Target>>, goTarget: wref<GameObject>, isInteresting: Bool, isVisible: Bool) -> Void {
    let newTarget: ref<Target>;
    let targetIndex: Int32 = SimpleTargetManager.IsTargetAlreadyAdded(targetsList, goTarget);
    if targetIndex >= 0 {
      targetsList[targetIndex].SetIsVisible(isVisible);
      targetsList[targetIndex].SetIsInteresting(isInteresting);
      if !IsFinal() {
        LogTargetManager("AddTarget / Target already added. Request rejected", n"w");
      };
      return;
    };
    newTarget = new Target();
    newTarget.CreateTarget(goTarget, isInteresting, isVisible);
    if goTarget.IsPlayer() {
      ArrayInsert(targetsList, 0, newTarget);
    } else {
      ArrayPush(targetsList, newTarget);
    };
  }

  public final static func RemoveTarget(out targetsList: array<ref<Target>>, targetToRemove: wref<GameObject>) -> Bool {
    let foundTarget: ref<Target> = SimpleTargetManager.GetSpecificTarget(targetsList, targetToRemove);
    if !IsDefined(foundTarget) {
      if !IsFinal() {
        LogTargetManager("CameraTargetsManager / RemoveTarget / Target not found");
      };
      return false;
    };
    ArrayRemove(targetsList, foundTarget);
    return true;
  }

  public final static func SetTargetVisible(targetsList: array<ref<Target>>, targetToRemove: wref<GameObject>, isVisible: Bool) -> Bool {
    let foundTarget: ref<Target> = SimpleTargetManager.GetSpecificTarget(targetsList, targetToRemove);
    if !IsDefined(foundTarget) {
      if !IsFinal() {
        LogTargetManager("CameraTargetsManager / RemoveTarget / Target not found");
      };
      return false;
    };
    foundTarget.SetIsVisible(isVisible);
    return true;
  }

  public final static func RemoveAllTargets(out targetsList: array<ref<Target>>) -> Void {
    ArrayClear(targetsList);
  }

  public final static func GetFirstInterestingTargetObject(targetsList: array<ref<Target>>) -> wref<GameObject> {
    let goTarget: wref<GameObject>;
    let target: ref<Target> = SimpleTargetManager.GetFirstInterestingTarget(targetsList);
    if IsDefined(target) {
      goTarget = target.GetTarget();
      if IsDefined(goTarget) {
        return goTarget;
      };
      if !IsFinal() {
        LogTargetManager("Target has no puppet - SHOULD NEVER HAPPEN. Debug!");
      };
      return null;
    };
    if !IsFinal() {
      LogTargetManager("Interesting Target not found");
    };
    return null;
  }

  public final static func GetFirstInterestingTarget(targetsList: array<ref<Target>>) -> ref<Target> {
    let i: Int32 = 0;
    while i < ArraySize(targetsList) {
      if targetsList[i].IsInteresting() && targetsList[i].IsVisible() {
        return targetsList[i];
      };
      i += 1;
    };
    if !IsFinal() {
      LogTargetManager("/ CameraTargetsManager / Interesting Target Not Found");
    };
    return null;
  }

  public final static func GetSpecificTarget(targetsList: array<ref<Target>>, target: wref<GameObject>) -> ref<Target> {
    let i: Int32 = 0;
    while i < ArraySize(targetsList) {
      if target == targetsList[i] {
        return targetsList[i];
      };
      i += 1;
    };
    if !IsFinal() {
      LogTargetManager("CameraTargetsManager / Wrong Camera Target Requested - DEBUG");
    };
    return null;
  }

  public final static func GetSpecificTarget(targetsList: array<ref<Target>>, targetID: EntityID) -> ref<Target> {
    let i: Int32 = 0;
    while i < ArraySize(targetsList) {
      if targetID == targetsList[i].GetTarget().GetEntityID() {
        return targetsList[i];
      };
      i += 1;
    };
    if !IsFinal() {
      LogTargetManager("CameraTargetsManager / Wrong Camera Target Requested - DEBUG");
    };
    return null;
  }

  public final static func GetSpecificTarget(targetsList: array<ref<Target>>, index: Int32) -> ref<Target> {
    if ArraySize(targetsList) == 0 {
      if !IsFinal() {
        LogTargetManager("CameraTargetsManager / CameraManager empty - no targets");
      };
      return null;
    };
    if index >= 0 && index < ArraySize(targetsList) {
      return targetsList[index];
    };
    if !IsFinal() {
      LogTargetManager("CameraTargetsManager / Wrong Camera Target Index Requested - DEBUG");
    };
    return null;
  }

  public final static func IsTargetAlreadyAdded(targets: array<ref<Target>>, targetToCheck: ref<Target>) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(targets) {
      if targetToCheck == targets[i] {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final static func IsTargetAlreadyAdded(targetsList: array<ref<Target>>, gameObject: wref<GameObject>) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(targetsList) {
      if gameObject == targetsList[i].GetTarget() {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final static func IsTargetVisible(targetsList: array<ref<Target>>, gameObject: wref<GameObject>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(targetsList) {
      if gameObject == targetsList[i].GetTarget() {
        return targetsList[i].IsVisible();
      };
      i += 1;
    };
    return false;
  }

  public final static func HasInterestingTargets(targetsList: array<ref<Target>>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(targetsList) {
      if targetsList[i].IsInteresting() && targetsList[i].IsVisible() {
        return true;
      };
      i += 1;
    };
    return false;
  }
}

public class Target extends IScriptable {

  private let target: wref<GameObject>;

  private let isInteresting: Bool;

  private let isVisible: Bool;

  public final func CreateTarget(currentTarget: wref<GameObject>, interesting: Bool, visible: Bool) -> Void {
    this.target = currentTarget;
    this.isInteresting = interesting;
    this.isVisible = visible;
  }

  public final func GetTarget() -> wref<GameObject> {
    return this.target;
  }

  public final func IsInteresting() -> Bool {
    return this.isInteresting;
  }

  public final func IsVisible() -> Bool {
    return this.isVisible;
  }

  public final func SetIsInteresting(interestingChange: Bool) -> Void {
    this.isInteresting = interestingChange;
  }

  public final func SetIsVisible(_isVisible: Bool) -> Void {
    this.isVisible = _isVisible;
  }
}
