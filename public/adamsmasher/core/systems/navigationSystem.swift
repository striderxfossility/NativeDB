
public native class NavigationSystem extends IScriptable {

  public final native const func CalculatePathOnlyHumanNavmesh(startPoint: Vector4, endPoint: Vector4, agentSize: NavGenAgentSize, findPointTolerance: Float, opt costModCircle: ref<NavigationCostModCircle>) -> ref<NavigationPath>;

  public final native func FindWallInLineOnlyHumanNavmesh(startPoint: Vector4, endPoint: Vector4, agentSize: NavGenAgentSize, findPointTolerance: Float) -> ref<NavigationFindWallResult>;

  public final native const func FindPointInSphereOnlyHumanNavmesh(center: Vector4, radius: Float, agentSize: NavGenAgentSize, heightDetail: Bool) -> NavigationFindPointResult;

  public final native const func FindPursuitPoint(playerPos: Vector4, pos: Vector4, dir: Vector4, radius: Float, navVisCheck: Bool, agentSize: NavGenAgentSize, out destination: Vector4, out isDestinationFallback: Bool) -> Bool;

  public final native const func FindPursuitPointRange(playerPos: Vector4, pos: Vector4, dir: Vector4, radiusMin: Float, radiusMax: Float, navVisCheck: Bool, agentSize: NavGenAgentSize, out destination: Vector4, out isDestinationFallback: Bool) -> Bool;

  public final native const func FindPursuitPointsRange(playerPos: Vector4, pos: Vector4, dir: Vector4, radiusMin: Float, radiusMax: Float, count: Int32, navVisCheck: Bool, agentSize: NavGenAgentSize, out results: array<Vector4>, out fallbackResults: array<Vector4>) -> Bool;

  public final native const func FindNavmeshPointAwayFromReferencePoint(pos: Vector4, refPos: Vector4, distance: Float, agentSize: NavGenAgentSize, out destination: Vector4, opt distanceTolerance: Float, opt angleTolerance: Float) -> Bool;

  public final native const func IsNavmeshStreamedInLocation(origin: Vector4, findPointTolerance: Float, opt allowedMask: Uint16, opt blockedMask: Uint16) -> Bool;

  public final native func AddObstacle(position: Vector4, radius: Float, height: Float, agentSize: NavGenAgentSize) -> ref<NavigationObstacle>;

  public final native func RemoveObstacle(obstacle: ref<NavigationObstacle>) -> Void;

  public final const func GetNearestNavmeshPointBelowOnlyHumanNavmesh(origin: Vector4, querySphereRadius: Float, numberOfSpheres: Int32) -> Vector4 {
    let point: Vector4;
    let pointResults: NavigationFindPointResult;
    let i: Int32 = 0;
    while i < numberOfSpheres {
      pointResults = this.FindPointInSphereOnlyHumanNavmesh(origin, querySphereRadius, NavGenAgentSize.Human, false);
      if NotEquals(pointResults.status, worldNavigationRequestStatus.OK) {
        origin.Z -= querySphereRadius;
      } else {
        point = pointResults.point;
        goto 266;
      };
      i += 1;
    };
    return point;
  }

  public final const func IsOnGround(const target: ref<GameObject>, opt queryLength: Float) -> Bool {
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let startingPoint: Vector4;
    let staticQueryFilter: QueryFilter;
    if queryLength == 0.00 {
      queryLength = 0.20;
    };
    startingPoint = target.GetWorldPosition() + target.GetWorldUp() * 0.10;
    QueryFilter.AddGroup(staticQueryFilter, n"Static");
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.refPosition = startingPoint;
    geometryDescription.refDirection = new Vector4(0.00, 0.00, -1.00, 0.00);
    geometryDescription.filter = staticQueryFilter;
    geometryDescription.primitiveDimension = new Vector4(0.10, 0.10, queryLength, 0.00);
    geometryDescriptionResult = GameInstance.GetSpatialQueriesSystem(target.GetGame()).GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    return Equals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.OK);
  }
}

public static exec func TestNavigationSystem(gameInstance: GameInstance) -> Void {
  let end: Vector4;
  let fw: ref<NavigationFindWallResult>;
  let start: Vector4;
  start.X = 0.00;
  start.Y = 0.00;
  start.Z = 0.00;
  end.X = 20.00;
  end.Y = 20.00;
  end.Z = 0.00;
  let path: ref<NavigationPath> = GameInstance.GetNavigationSystem(gameInstance).CalculatePathOnlyHumanNavmesh(start, end, NavGenAgentSize.Human, 1.00);
  Log(ToString(path.path[0]));
  Log(ToString(path.path[1]));
  Log(ToString(path.CalculateLength()));
  fw = GameInstance.GetNavigationSystem(gameInstance).FindWallInLineOnlyHumanNavmesh(start, end, NavGenAgentSize.Human, 1.00);
  Log(ToString(fw.status));
  Log(ToString(fw.isHit));
  Log(ToString(fw.hitPosition.X));
  Log(ToString(fw.hitPosition.Y));
  Log(ToString(fw.hitPosition.Z));
}
