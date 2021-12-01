
public class HitData_Base extends HitShapeUserData {

  public edit let m_hitShapeTag: CName;

  public edit let m_bodyPartStatPoolName: CName;

  public edit let m_hitShapeType: HitShape_Type;

  public final const func IsWeakspot() -> Bool {
    return Equals(this.m_hitShapeType, HitShape_Type.InternalWeakSpot) || Equals(this.m_hitShapeType, HitShape_Type.ExternalWeakSpot);
  }
}

public class HitShapeUserDataBase extends HitShapeUserData {

  public edit let m_hitShapeTag: CName;

  public edit let m_hitShapeType: EHitShapeType;

  public edit let m_hitReactionZone: EHitReactionZone;

  public edit let m_dismembermentPart: EAIDismembermentBodyPart;

  public edit let m_isProtectionLayer: Bool;

  public edit let m_isInternalWeakspot: Bool;

  public edit let m_hitShapeDamageMod: Float;

  public final static func GetHitShapeDamageMod(userData: ref<HitShapeUserDataBase>) -> Float {
    return userData.m_hitShapeDamageMod;
  }

  public final static func IsProtectionLayer(userData: ref<HitShapeUserDataBase>) -> Bool {
    return userData.m_isProtectionLayer;
  }

  public final static func IsInternalWeakspot(userData: ref<HitShapeUserDataBase>) -> Bool {
    return userData.m_isInternalWeakspot;
  }

  public final const func IsHead() -> Bool {
    return Equals(this.m_hitShapeTag, n"Head");
  }

  public final const func GetShapeType() -> EHitShapeType {
    return this.m_hitShapeType;
  }

  public final static func DisableHitShape(gameObj: wref<GameObject>, shapeName: CName, hierarchical: Bool) -> Void {
    let hitShapeEvent: ref<ToggleHitShapeEvent> = new ToggleHitShapeEvent();
    hitShapeEvent.enable = false;
    hitShapeEvent.hitShapeName = shapeName;
    hitShapeEvent.hierarchical = hierarchical;
    gameObj.QueueEvent(hitShapeEvent);
  }

  public final static func EnableHitShape(gameObj: wref<GameObject>, shapeName: CName, hierarchical: Bool) -> Void {
    let hitShapeEvent: ref<ToggleHitShapeEvent> = new ToggleHitShapeEvent();
    hitShapeEvent.enable = true;
    hitShapeEvent.hitShapeName = shapeName;
    hitShapeEvent.hierarchical = hierarchical;
    gameObj.QueueEvent(hitShapeEvent);
  }

  public final static func GetHitReactionZone(userData: ref<HitShapeUserDataBase>) -> EHitReactionZone {
    return userData.m_hitReactionZone;
  }

  public final static func GetDismembermentBodyPart(userData: ref<HitShapeUserDataBase>) -> gameDismBodyPart {
    let str: String = EnumValueToString("EAIDismembermentBodyPart", Cast(EnumInt(userData.m_dismembermentPart)));
    let dismBodyPart: gameDismBodyPart = IntEnum(Cast(EnumValueFromString("gameDismBodyPart", str)));
    return dismBodyPart;
  }

  public final static func IsHitReactionZoneHead(userData: ref<HitShapeUserDataBase>) -> Bool {
    return Equals(userData.m_hitReactionZone, EHitReactionZone.Head);
  }

  public final static func IsHitReactionZoneTorso(userData: ref<HitShapeUserDataBase>) -> Bool {
    return Equals(userData.m_hitReactionZone, EHitReactionZone.Abdomen) || Equals(userData.m_hitReactionZone, EHitReactionZone.ChestLeft) || Equals(userData.m_hitReactionZone, EHitReactionZone.ChestRight);
  }

  public final static func IsHitReactionZoneLeftArm(userData: ref<HitShapeUserDataBase>) -> Bool {
    return Equals(userData.m_hitReactionZone, EHitReactionZone.ArmLeft) || Equals(userData.m_hitReactionZone, EHitReactionZone.HandLeft);
  }

  public final static func IsHitReactionZoneRightArm(userData: ref<HitShapeUserDataBase>) -> Bool {
    return Equals(userData.m_hitReactionZone, EHitReactionZone.ArmRight) || Equals(userData.m_hitReactionZone, EHitReactionZone.ArmRight);
  }

  public final static func IsHitReactionZoneRightLeg(userData: ref<HitShapeUserDataBase>) -> Bool {
    return Equals(userData.m_hitReactionZone, EHitReactionZone.LegRight);
  }

  public final static func IsHitReactionZoneLeftLeg(userData: ref<HitShapeUserDataBase>) -> Bool {
    return Equals(userData.m_hitReactionZone, EHitReactionZone.LegLeft);
  }

  public final static func IsHitReactionZoneLeg(userData: ref<HitShapeUserDataBase>) -> Bool {
    return Equals(userData.m_hitReactionZone, EHitReactionZone.LegLeft) || Equals(userData.m_hitReactionZone, EHitReactionZone.LegRight);
  }

  public final static func IsHitReactionZoneLimb(userData: ref<HitShapeUserDataBase>) -> Bool {
    return HitShapeUserDataBase.IsHitReactionZoneLeftArm(userData) || HitShapeUserDataBase.IsHitReactionZoneRightArm(userData) || HitShapeUserDataBase.IsHitReactionZoneRightLeg(userData) || HitShapeUserDataBase.IsHitReactionZoneLeftLeg(userData);
  }
}
