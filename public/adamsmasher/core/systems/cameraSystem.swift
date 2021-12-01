
public class CameraSystemHelper extends IScriptable {

  public final static func IsInCameraFrustum(obj: wref<GameObject>, objHeight: Float, objRadius: Float) -> Bool {
    let bestProjected: Vector4;
    let betweenXPoints: Bool;
    let betweenYPoints: Bool;
    let cameraSys: ref<CameraSystem>;
    let cameraToTarget: Vector4;
    let cameraTransform: Transform;
    let offset: Vector4;
    let projectedMax: Vector4;
    let projectedMin: Vector4;
    let targetPos: Vector4;
    if !IsDefined(obj) {
      return false;
    };
    cameraSys = GameInstance.GetCameraSystem(obj.GetGame());
    targetPos = obj.GetWorldPosition();
    targetPos.Z += objHeight * 0.50;
    if !cameraSys.GetActiveCameraWorldTransform(cameraTransform) {
      return false;
    };
    cameraToTarget = Transform.GetPosition(cameraTransform) - targetPos;
    cameraToTarget.Z = 0.00;
    cameraToTarget.W = 0.00;
    offset = Vector4.Cross(cameraToTarget, new Vector4(0.00, 0.00, 1.00, 0.00));
    offset.W = 0.00;
    offset = Vector4.Normalize(offset) * objRadius;
    offset.Z += objHeight * 0.50;
    projectedMin = new Vector4(1.00, 1.00, 0.00, 0.00);
    projectedMax = -projectedMin;
    bestProjected = projectedMin;
    CameraSystemHelper.HandlePairOfCorners(cameraSys, targetPos, offset, projectedMin, projectedMax, bestProjected);
    offset.X = -offset.X;
    CameraSystemHelper.HandlePairOfCorners(cameraSys, targetPos, offset, projectedMin, projectedMax, bestProjected);
    offset.Y = -offset.Y;
    CameraSystemHelper.HandlePairOfCorners(cameraSys, targetPos, offset, projectedMin, projectedMax, bestProjected);
    offset.X = -offset.X;
    CameraSystemHelper.HandlePairOfCorners(cameraSys, targetPos, offset, projectedMin, projectedMax, bestProjected);
    betweenXPoints = projectedMin.X > 0.00 ? projectedMax.X < 0.00 : projectedMax.X > 0.00;
    betweenYPoints = projectedMin.Y > 0.00 ? projectedMax.Y < 0.00 : projectedMax.Y > 0.00;
    if (betweenXPoints || bestProjected.X < 1.00) && (betweenYPoints || bestProjected.Y < 1.00) {
      return true;
    };
    return false;
  }

  public final static func HandlePairOfCorners(cameraSys: ref<CameraSystem>, center: Vector4, offset: Vector4, projectedMin: script_ref<Vector4>, projectedMax: script_ref<Vector4>, bestProjected: script_ref<Vector4>) -> Void {
    let tmp: Vector4 = center + offset;
    let tmpProjected: Vector4 = cameraSys.ProjectPoint(tmp);
    projectedMin = CameraSystemHelper.MinVector2D(Deref(projectedMin), tmpProjected);
    projectedMax = CameraSystemHelper.MaxVector2D(Deref(projectedMax), tmpProjected);
    bestProjected = CameraSystemHelper.MinAbsVector2D(Deref(bestProjected), tmpProjected);
    tmp = center - offset;
    tmpProjected = cameraSys.ProjectPoint(tmp);
    projectedMin = CameraSystemHelper.MinVector2D(Deref(projectedMin), tmpProjected);
    projectedMax = CameraSystemHelper.MaxVector2D(Deref(projectedMax), tmpProjected);
    bestProjected = CameraSystemHelper.MinAbsVector2D(Deref(bestProjected), tmpProjected);
  }

  private final static func MinVector2D(a: Vector4, b: Vector4) -> Vector4 {
    a.X = MinF(a.X, b.X);
    a.Y = MinF(a.Y, b.Y);
    return a;
  }

  private final static func MaxVector2D(a: Vector4, b: Vector4) -> Vector4 {
    a.X = MaxF(a.X, b.X);
    a.Y = MaxF(a.Y, b.Y);
    return a;
  }

  private final static func MinAbsVector2D(a: Vector4, b: Vector4) -> Vector4 {
    a.X = MinF(AbsF(a.X), AbsF(b.X));
    a.Y = MinF(AbsF(a.Y), AbsF(b.Y));
    return a;
  }
}
