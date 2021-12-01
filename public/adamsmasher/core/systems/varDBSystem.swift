
public static func GetPSGeneratorVersion() -> Int32 {
  return 666;
}

public struct VirtualComponentBinder {

  public final static func Bind(game: GameInstance, entityID: EntityID, componentName: CName, psClassName: CName) -> ref<PersistentState> {
    let psID: PersistentID = CreatePersistentID(entityID, componentName);
    let virtualPS: ref<PersistentState> = GameInstance.GetPersistencySystem(game).GetConstAccessToPSObject(psID, psClassName);
    if IsDefined(virtualPS) {
      return virtualPS;
    };
    return null;
  }
}

public static func SpawnVirtualPS(game: GameInstance, entityID: EntityID, componentName: CName, psClassName: CName) -> ref<PersistentState> {
  return VirtualComponentBinder.Bind(game, entityID, componentName, psClassName);
}

public static func GetNotSavableClasses() -> array<CName> {
  let classes: array<CName>;
  ArrayPush(classes, n"ElectricLightControllerPS");
  ArrayPush(classes, n"LcdScreenControllerPS");
  ArrayPush(classes, n"CrossingLightControllerPS");
  ArrayPush(classes, n"TrafficZebraControllerPS");
  ArrayPush(classes, n"TrafficLightControllerPS");
  ArrayPush(classes, n"TrafficIntersectionManagerControllerPS");
  ArrayPush(classes, n"BarbedWireControllerPS");
  return classes;
}

public native class GamePuppetPS extends GameObjectPS {

  public final native const func GetGender() -> CName;

  public final native const func WasQuickHacked() -> Bool;

  public final native func SetWasQuickHacked(newValue: Bool) -> Void;

  public final native const func HasNPCTriggeredCombatInSecuritySystem() -> Bool;

  public final native func SetHasNPCTriggeredCombatInSecuritySystem(set: Bool) -> Void;

  public final native func HasAlternativeName() -> Bool;

  public final native func SetCrouch(set: Bool) -> Void;

  public final native func IsCrouch() -> Bool;

  public final func OnNotifiedSecSysAboutCombat(evt: ref<NotifiedSecSysAboutCombat>) -> EntityNotificationType {
    this.SetHasNPCTriggeredCombatInSecuritySystem(true);
    return EntityNotificationType.DoNotNotifyEntity;
  }
}
