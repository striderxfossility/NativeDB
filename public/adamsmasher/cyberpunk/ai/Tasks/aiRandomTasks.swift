
public class AIRandomTasks extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void;

  protected final func RollInteger(Max: Int32, Min: Int32) -> Int32 {
    return RandRange(Min, Max);
  }
}

public class SetRandomIntArgument extends AIRandomTasks {

  public edit let m_MaxValue: Int32;

  public edit let m_MinValue: Int32;

  public edit let m_ArgumentName: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.SetArgument(context, this.m_ArgumentName, this.RollInteger(this.m_MaxValue, this.m_MinValue));
  }

  protected final func SetArgument(context: ScriptExecutionContext, argumentName: CName, intValue: Int32) -> Void {
    ScriptExecutionContext.SetArgumentInt(context, this.m_ArgumentName, intValue);
  }
}

public class GetRandomThreat extends AIRandomTasks {

  public inline edit let m_outThreatArgument: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let chosenIndex: Int32;
    let chosenThreat: wref<GameObject>;
    let threats: array<TrackedLocation> = ScriptExecutionContext.GetOwner(context).GetTargetTracker().GetThreats(false);
    if ArraySize(threats) > 0 {
      chosenIndex = this.RollInteger(ArraySize(threats), 0);
      chosenThreat = threats[chosenIndex].entity as GameObject;
      ScriptExecutionContext.SetMappingValue(context, this.m_outThreatArgument, ToVariant(chosenThreat));
    };
  }
}

public class GetRandomPositionAroundPoint extends AIRandomTasks {

  public inline edit let m_originPoint: ref<AIArgumentMapping>;

  public inline edit let m_distanceMin: ref<AIArgumentMapping>;

  public inline edit let m_distanceMax: ref<AIArgumentMapping>;

  public inline edit let m_angleMin: ref<AIArgumentMapping>;

  public inline edit let m_angleMax: ref<AIArgumentMapping>;

  public inline edit let m_outPositionArgument: ref<AIArgumentMapping>;

  protected let m_finalPosition: Vector4;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let chosenAngle: Float;
    let chosenDistance: Float;
    let chosenOrientation: Quaternion;
    let finalPosition: Vector4;
    let originOrientation: Quaternion;
    let originPosition: Vector4;
    let originObject: wref<GameObject> = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_originPoint));
    if IsDefined(originObject) {
      originOrientation = originObject.GetWorldOrientation();
    } else {
      originPosition = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_originPoint));
      Quaternion.SetIdentity(originOrientation);
    };
    if !IsDefined(originObject) && Vector4.IsZero(originPosition) {
      return;
    };
    chosenAngle = RandRangeF(FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_angleMin)), FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_angleMax)));
    chosenDistance = RandRangeF(FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_distanceMin)), FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_distanceMax)));
    Quaternion.SetIdentity(chosenOrientation);
    Quaternion.SetZRot(chosenOrientation, Deg2Rad(chosenAngle));
    chosenOrientation *= originOrientation;
    if IsDefined(originObject) {
      finalPosition = originObject.GetWorldPosition() + Quaternion.GetForward(chosenOrientation) * chosenDistance;
    } else {
      finalPosition = originPosition + Quaternion.GetForward(chosenOrientation) * chosenDistance;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(finalPosition));
  }
}
