
public native class DismembermentComponent extends IComponent {

  private final native func ReportExplosion(hitPosition: Vector4, strength: Float) -> Void;

  private final native func DoDismemberment(bodyPart: gameDismBodyPart, woundType: gameDismWoundType, opt strength: Float, isCritical: Bool, opt debrisPath: String, opt debrisStrength: Float) -> Void;

  private final native func SpawnGutsFromLastHit(resourcePath: String, strength: Float) -> Void;

  public final native func GetDismemberedLimbCount() -> DismemberedLimbCount;

  public final static func RequestGutsFromLastHit(obj: ref<GameObject>, resourcePath: String, strength: Float) -> Void {
    let evt: ref<DismembermentDebrisEvent> = new DismembermentDebrisEvent();
    evt.m_resourcePath = resourcePath;
    evt.m_strength = strength;
    obj.QueueEvent(evt);
  }

  public final static func RequestDismemberment(obj: ref<GameObject>, bodyPart: gameDismBodyPart, woundType: gameDismWoundType, opt hitPosition: Vector4, opt isCritical: Bool, opt debrisPath: String, opt debrisStrength: Float) -> Void {
    let audioEvt: ref<DismembermentAudioEvent>;
    let evt: ref<DismembermentEvent> = new DismembermentEvent();
    evt.m_bodyPart = bodyPart;
    evt.m_woundType = woundType;
    evt.m_strength = 8.00;
    evt.m_isCritical = isCritical;
    evt.m_debrisPath = debrisPath;
    evt.m_debrisStrength = debrisStrength;
    obj.QueueEvent(evt);
    if Vector4.IsZero(hitPosition) {
      return;
    };
    audioEvt = new DismembermentAudioEvent();
    switch evt.m_bodyPart {
      case gameDismBodyPart.HEAD:
        audioEvt.bodyPart = entAudioDismembermentPart.Head;
        break;
      case gameDismBodyPart.RIGHT_ARM:
      case gameDismBodyPart.LEFT_ARM:
        audioEvt.bodyPart = entAudioDismembermentPart.Arm;
        break;
      case gameDismBodyPart.RIGHT_LEG:
      case gameDismBodyPart.LEFT_LEG:
        audioEvt.bodyPart = entAudioDismembermentPart.Leg;
        break;
      default:
    };
    audioEvt.position = hitPosition;
    obj.QueueEvent(audioEvt);
  }

  protected cb func OnDismemberment(evt: ref<DismembermentEvent>) -> Bool {
    this.DoDismemberment(evt.m_bodyPart, evt.m_woundType, evt.m_strength, evt.m_isCritical, evt.m_debrisPath, evt.m_debrisStrength);
  }

  protected cb func OnDismembermentExplosion(evt: ref<DismembermentExplosionEvent>) -> Bool {
    this.ReportExplosion(evt.m_epicentrum, evt.m_strength);
  }

  protected cb func OnDismembermentDebris(evt: ref<DismembermentDebrisEvent>) -> Bool {
    this.SpawnGutsFromLastHit(evt.m_resourcePath, evt.m_strength);
  }
}
