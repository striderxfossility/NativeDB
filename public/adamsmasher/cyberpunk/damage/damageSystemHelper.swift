
public abstract class DamageSystemHelper extends IScriptable {

  public final static func GetHitShape(hitEvent: ref<gameHitEvent>) -> HitShapeData {
    return hitEvent.hitRepresentationResult.hitShapes[0];
  }

  public final static func GetHitShapeUserDataBase(data: HitShapeData) -> ref<HitShapeUserDataBase> {
    return data.userData as HitShapeUserDataBase;
  }

  public final static func GetLocalizedDamageMultiplier(type: EHitShapeType) -> Float {
    let multiplier: Float;
    switch type {
      case IntEnum(-1l):
        multiplier = 0.00;
        break;
      case EHitShapeType.Flesh:
        multiplier = 1.00;
        break;
      case EHitShapeType.Metal:
        multiplier = 0.85;
        break;
      case EHitShapeType.Cyberware:
        multiplier = 0.60;
        break;
      case EHitShapeType.Armor:
        multiplier = 0.85;
        break;
      default:
        multiplier = 1.00;
    };
    return multiplier;
  }

  public final static func GetHitShapeTypeFromData(data: HitShapeData) -> EHitShapeType {
    let baseData: ref<HitShapeUserDataBase> = data.userData as HitShapeUserDataBase;
    if IsDefined(baseData) {
      return baseData.m_hitShapeType;
    };
    return IntEnum(-1l);
  }

  public final static func IsProtectionLayer(data: HitShapeData) -> Bool {
    let baseData: ref<HitShapeUserDataBase> = data.userData as HitShapeUserDataBase;
    if IsDefined(baseData) {
      return baseData.m_isProtectionLayer;
    };
    return false;
  }
}
