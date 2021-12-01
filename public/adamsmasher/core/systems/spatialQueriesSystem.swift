
public class SpatialQueriesHelper extends IScriptable {

  public final static func HasSpaceInFront(const sourceObject: wref<GameObject>, groundClearance: Float, areaWidth: Float, areaLength: Float, areaHeight: Float) -> Bool {
    let hasSpace: Bool = SpatialQueriesHelper.HasSpaceInFront(sourceObject, sourceObject.GetWorldForward(), groundClearance, areaWidth, areaLength, areaHeight);
    return hasSpace;
  }

  public final static func HasSpaceInFront(const sourceObject: wref<GameObject>, queryDirection: Vector4, groundClearance: Float, areaWidth: Float, areaLength: Float, areaHeight: Float) -> Bool {
    let boxDimensions: Vector4;
    let boxOrientation: EulerAngles;
    let fitTestOvelap: TraceResult;
    let overlapSuccessStatic: Bool;
    let overlapSuccessVehicle: Bool;
    queryDirection.Z = 0.00;
    queryDirection = Vector4.Normalize(queryDirection);
    boxDimensions.X = areaWidth * 0.50;
    boxDimensions.Y = areaLength * 0.50;
    boxDimensions.Z = areaHeight * 0.50;
    let queryPosition: Vector4 = sourceObject.GetWorldPosition();
    queryPosition.Z += boxDimensions.Z + groundClearance;
    queryPosition += boxDimensions.Y * queryDirection;
    boxOrientation = Quaternion.ToEulerAngles(Quaternion.BuildFromDirectionVector(queryDirection));
    overlapSuccessStatic = GameInstance.GetSpatialQueriesSystem(sourceObject.GetGame()).Overlap(boxDimensions, queryPosition, boxOrientation, n"Static", fitTestOvelap);
    overlapSuccessVehicle = GameInstance.GetSpatialQueriesSystem(sourceObject.GetGame()).Overlap(boxDimensions, queryPosition, boxOrientation, n"Vehicle", fitTestOvelap);
    return !overlapSuccessStatic && !overlapSuccessVehicle;
  }

  public final static func GetFloorAngle(const sourceObject: wref<GameObject>, out floorAngle: Float) -> Bool {
    let raycastResult: TraceResult;
    let startPosition: Vector4 = sourceObject.GetWorldPosition() + new Vector4(0.00, 0.00, 0.10, 0.00);
    let endPosition: Vector4 = sourceObject.GetWorldPosition() + new Vector4(0.00, 0.00, -0.30, 0.00);
    if GameInstance.GetSpatialQueriesSystem(sourceObject.GetGame()).SyncRaycastByCollisionGroup(startPosition, endPosition, n"Static", raycastResult, true, false) {
      floorAngle = Vector4.GetAngleBetween(Cast(raycastResult.normal), sourceObject.GetWorldUp());
      return true;
    };
    return false;
  }
}
