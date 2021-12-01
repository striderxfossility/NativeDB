
public native class AINavigationSystem extends AIINavigationSystem {

  public final native func StartPathfinding(query: script_ref<AINavigationSystemQuery>) -> Uint32;

  public final native func StopPathfinding(id: Uint32) -> Bool;

  public final native func GetResult(id: Uint32, result: script_ref<AINavigationSystemResult>) -> Bool;

  public final native const func CalculatePathForCharacter(startPoint: Vector4, endPoint: Vector4, findPointTolerance: Float, owner: ref<Entity>, opt costModCircle: ref<NavigationCostModCircle>) -> ref<NavigationPath>;

  public final native func FindWallInLineForCharacter(startPoint: Vector4, endPoint: Vector4, findPointTolerance: Float, owner: ref<Entity>) -> ref<NavigationFindWallResult>;

  public final native const func FindPointInSphereForCharacter(center: Vector4, radius: Float, owner: ref<Entity>) -> NavigationFindPointResult;

  public final native const func FindPointInBoxForCharacter(center: Vector4, extents: Vector4, owner: ref<Entity>) -> NavigationFindPointResult;

  public final const func IsPointOnNavmesh(const character: wref<Entity>, point: Vector4, opt tolerance: Float) -> Bool {
    let pointResults: NavigationFindPointResult;
    if tolerance <= 0.00 {
      tolerance = 0.50;
    };
    pointResults = this.FindPointInSphereForCharacter(point, tolerance, character);
    if NotEquals(pointResults.status, worldNavigationRequestStatus.OK) {
      return false;
    };
    return true;
  }

  public final const func IsPointOnNavmesh(const character: wref<Entity>, point: Vector4, tolerance: Vector4) -> Bool {
    let pointResults: NavigationFindPointResult = this.FindPointInBoxForCharacter(point, tolerance, character);
    if NotEquals(pointResults.status, worldNavigationRequestStatus.OK) {
      return false;
    };
    return true;
  }

  public final const func IsPointOnNavmesh(const character: wref<Entity>, point: Vector4, tolerance: Vector4, out navmeshPoint: Vector4) -> Bool {
    let pointResults: NavigationFindPointResult = this.FindPointInBoxForCharacter(point, tolerance, character);
    navmeshPoint = pointResults.point;
    if NotEquals(pointResults.status, worldNavigationRequestStatus.OK) {
      return false;
    };
    return true;
  }

  public final const func GetNearestNavmeshPointBelow(const character: wref<Entity>, origin: Vector4, querySphereRadius: Float, numberOfSpheres: Int32) -> Vector4 {
    let point: Vector4;
    let pointResults: NavigationFindPointResult;
    let i: Int32 = 0;
    while i < numberOfSpheres {
      pointResults = this.FindPointInSphereForCharacter(origin, querySphereRadius, character);
      if NotEquals(pointResults.status, worldNavigationRequestStatus.OK) {
        origin.Z -= querySphereRadius;
      } else {
        point = pointResults.point;
        goto 258;
      };
      i += 1;
    };
    return point;
  }

  public final const func GetNearestNavmeshPointBehind(const origin: wref<Entity>, const querySphereRadius: Float, const numberOfSpheres: Int32, out point: Vector4, opt checkPathToOrigin: Bool) -> Bool {
    let center: Vector4;
    let i: Int32;
    let navigationPath: ref<NavigationPath>;
    let originHeading: Vector4;
    let originPosition: Vector4;
    let pointResults: NavigationFindPointResult;
    if !IsDefined(origin) {
      false;
    };
    originPosition = origin.GetWorldPosition();
    originHeading = origin.GetWorldForward();
    i = 1;
    while i <= numberOfSpheres {
      center = originPosition - originHeading * querySphereRadius * Cast(i);
      pointResults = this.FindPointInSphereForCharacter(center, querySphereRadius, origin);
      if NotEquals(pointResults.status, worldNavigationRequestStatus.OK) {
      } else {
        point = pointResults.point;
        if checkPathToOrigin {
          navigationPath = this.CalculatePathForCharacter(point, origin.GetWorldPosition(), 0.50, origin);
          if ArraySize(navigationPath.path) <= 0 {
          } else {
            return true;
          };
        };
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final const func GetFurthestNavmeshPointBehind(const origin: wref<Entity>, const querySphereRadius: Float, const numberOfSpheres: Int32, out point: Vector4, const opt offsetFromOrigin: Vector4, opt checkPathToOrigin: Bool, opt ratioCurveName: CName) -> Bool {
    let center: Vector4;
    let directLength: Float;
    let i: Int32;
    let navigationPath: ref<NavigationPath>;
    let originHeading: Vector4;
    let originPosition: Vector4;
    let pathLength: Float;
    let pointResults: NavigationFindPointResult;
    let ratio: Float;
    let statsDataSystem: ref<StatsDataSystem>;
    if !IsDefined(origin) {
      false;
    };
    statsDataSystem = GameInstance.GetStatsDataSystem((origin as GameObject).GetGame());
    originPosition = origin.GetWorldPosition() + offsetFromOrigin;
    originHeading = origin.GetWorldForward();
    i = numberOfSpheres;
    while i > 0 {
      center = originPosition - originHeading * querySphereRadius * Cast(i);
      pointResults = this.FindPointInSphereForCharacter(center, querySphereRadius, origin);
      if NotEquals(pointResults.status, worldNavigationRequestStatus.OK) {
      } else {
        point = pointResults.point;
        if checkPathToOrigin {
          navigationPath = this.CalculatePathForCharacter(point, origin.GetWorldPosition(), 0.50, origin);
          if ArraySize(navigationPath.path) <= 0 {
          } else {
            if NotEquals(ratioCurveName, n"") && IsDefined(statsDataSystem) {
              directLength = Vector4.Length(originPosition - point);
              pathLength = navigationPath.CalculateLength();
              ratio = statsDataSystem.GetValueFromCurve(n"pathLengthToDirectDistancesRatio", pathLength, ratioCurveName);
              if ratio > 1.00 && pathLength > ratio * directLength {
              } else {
                return true;
              };
            };
            return true;
          };
        };
        return true;
      };
      i -= 1;
    };
    return false;
  }

  public final const func TryToFindNavmeshPointAroundPoint(const owner: wref<Entity>, const originPosition: Vector4, const originOrientation: Quaternion, const probeDimensions: Vector4, const numberOfSpheres: Int32, const sphereDistanceFromOrigin: Float, out point: Vector4, opt checkPathToOrigin: Bool) -> Bool {
    let currentAngle: Float;
    let currentAngleRad: Float;
    let currentCheckPosition: Vector4;
    let navigationPath: ref<NavigationPath>;
    let pointResults: NavigationFindPointResult;
    let quat: Quaternion;
    let i: Int32 = numberOfSpheres;
    while i > 0 {
      Quaternion.SetIdentity(quat);
      currentAngleRad = Deg2Rad(currentAngle);
      Quaternion.SetZRot(quat, currentAngleRad);
      quat = originOrientation * quat;
      currentCheckPosition = originPosition + Quaternion.GetForward(quat) * sphereDistanceFromOrigin;
      pointResults = this.FindPointInBoxForCharacter(currentCheckPosition, probeDimensions, owner);
      currentAngle += Cast(360 / numberOfSpheres);
      if NotEquals(pointResults.status, worldNavigationRequestStatus.OK) {
      } else {
        point = pointResults.point;
        if checkPathToOrigin {
          navigationPath = this.CalculatePathForCharacter(point, originPosition, 0.50, owner);
          if ArraySize(navigationPath.path) <= 0 {
          } else {
            return true;
          };
        };
        return true;
      };
      i -= 1;
    };
    return false;
  }

  public final const func HasPathForward(const sourceObject: wref<GameObject>, const distance: Float) -> Bool {
    let navigationPath: ref<NavigationPath>;
    let originPoint: Vector4 = sourceObject.GetWorldPosition();
    let destinationPoint: Vector4 = originPoint + Vector4.Normalize(sourceObject.GetWorldForward()) * distance;
    let originPointNavmeshResult: NavigationFindPointResult = this.FindPointInBoxForCharacter(originPoint, new Vector4(0.20, 0.20, 0.75, 1.00), sourceObject);
    let destinationPointNavmeshResult: NavigationFindPointResult = this.FindPointInBoxForCharacter(destinationPoint, new Vector4(0.20, 0.20, 0.75, 1.00), sourceObject);
    if Equals(originPointNavmeshResult.status, worldNavigationRequestStatus.OK) && Equals(destinationPointNavmeshResult.status, worldNavigationRequestStatus.OK) {
      navigationPath = this.CalculatePathForCharacter(originPointNavmeshResult.point, destinationPointNavmeshResult.point, 0.50, sourceObject);
      if ArraySize(navigationPath.path) > 0 {
        return true;
      };
    };
    return false;
  }

  public final static func HasPathFromAtoB(const owner: wref<Entity>, game: GameInstance, originPoint: Vector4, targetPoint: Vector4) -> Bool {
    let navigationPath: ref<NavigationPath>;
    if !GameInstance.IsValid(game) {
      return false;
    };
    navigationPath = GameInstance.GetAINavigationSystem(game).CalculatePathForCharacter(originPoint, targetPoint, 0.50, owner);
    if ArraySize(navigationPath.path) <= 0 {
      return false;
    };
    return true;
  }
}

public class ExampleNavigationTask extends AIbehaviortaskScript {

  private let m_queryId: Uint32;

  private let m_queryStarted: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let query: AINavigationSystemQuery;
    let system: ref<AINavigationSystem>;
    this.m_queryStarted = false;
    let target: wref<GameObject> = ScriptExecutionContext.GetArgumentObject(context, n"CombatTarget");
    if IsDefined(target) {
      system = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame());
      AIPositionSpec.SetEntity(query.source, ScriptExecutionContext.GetOwner(context));
      AIPositionSpec.SetEntity(query.target, target);
      this.m_queryId = system.StartPathfinding(query);
      this.m_queryStarted = true;
    };
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let system: ref<AINavigationSystem>;
    if this.m_queryStarted {
      system = GameInstance.GetAINavigationSystem(ScriptExecutionContext.GetOwner(context).GetGame());
      system.StopPathfinding(this.m_queryId);
    };
  }
}

public class FindNavmeshPointAroundThePlayer extends AIbehaviortaskScript {

  public inline edit let m_outPositionArgument: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let navmeshPosition: Vector4;
    let pointResults: NavigationFindPointResult;
    let owner: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject();
    let playerPosition: Vector4 = player.GetWorldPosition();
    let navigationSystem: ref<AINavigationSystem> = GameInstance.GetAINavigationSystem(owner.GetGame());
    let tolerance: Vector4 = new Vector4(0.50, 0.50, 0.50, 1.00);
    if navigationSystem.IsPointOnNavmesh(owner, playerPosition, 0.20) {
      ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(playerPosition));
      return;
    };
    pointResults = navigationSystem.FindPointInBoxForCharacter(playerPosition, tolerance, owner);
    if Equals(pointResults.status, worldNavigationRequestStatus.OK) {
      ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(pointResults.point));
      return;
    };
    if navigationSystem.TryToFindNavmeshPointAroundPoint(owner, playerPosition, player.GetWorldOrientation(), tolerance, 5, 3.00, navmeshPosition, true) {
      ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(navmeshPosition));
      return;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(playerPosition));
  }
}
