
public native class SourceShootComponent extends IComponent {

  public final native func GetContinuousLineOfSightToTarget(target: ref<GameObject>, out continuousLineOfSight: Float) -> Bool;

  public final native func ClearDebugInformation() -> Void;

  public final native func AppendDebugInformation(lineToAppend: String) -> Void;

  public final func SetDebugParameters(params: TimeBetweenHitsParameters) -> Void {
    this.ClearDebugInformation();
    this.AppendDebugInformation("BASE " + FloatToString(params.baseCoefficient));
    this.AppendDebugInformation("LVL  " + FloatToString(params.difficultyLevelCoefficient));
    this.AppendDebugInformation("DIST " + FloatToString(params.distanceCoefficient));
    this.AppendDebugInformation("VIS  " + FloatToString(params.visibilityCoefficient));
    this.AppendDebugInformation("GRP  " + FloatToString(params.groupCoefficient));
    this.AppendDebugInformation("PLS " + FloatToString(params.playersCountCoefficient));
  }
}
