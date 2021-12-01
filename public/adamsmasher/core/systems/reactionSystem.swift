
public class ScriptedReactionSystem extends ScriptableSystem {

  private let m_fleeingNPCs: Int32;

  private let m_runners: array<wref<Entity>>;

  private let m_registeredTimeout: Float;

  private let m_callInAction: Bool;

  private let m_policeCaller: wref<Entity>;

  private final func OnRegisterFleeingNPC(request: ref<RegisterFleeingNPC>) -> Void {
    if !this.IsRegistered(request.runner) {
      this.m_fleeingNPCs = this.m_fleeingNPCs + 1;
      ArrayPush(this.m_runners, request.runner);
      if request.timestamp > this.m_registeredTimeout {
        this.m_registeredTimeout = request.timestamp + 2.00;
      };
    };
  }

  private final func OnUnregisterFleeingNPC(request: ref<UnregisterFleeingNPC>) -> Void {
    if this.IsRegistered(request.runner) {
      this.m_fleeingNPCs = this.m_fleeingNPCs - 1;
      ArrayRemove(this.m_runners, request.runner);
    };
  }

  public final const func GetFleeingNPCsCount() -> Int32 {
    return this.m_fleeingNPCs;
  }

  public final const func GetFleeingNPCsCountInDistance(position: Vector4, distance: Float) -> Int32 {
    let distanceSquaredCheck: Float;
    let runners: Int32;
    let count: Int32 = ArraySize(this.m_runners);
    let i: Int32 = 0;
    while i < count {
      distanceSquaredCheck = Vector4.DistanceSquared(this.m_runners[i].GetWorldPosition(), position);
      if distanceSquaredCheck < distance * distance {
        runners = runners + 1;
      };
      i += 1;
    };
    return runners;
  }

  public final const func GetRegisterTimeout() -> Float {
    return this.m_registeredTimeout;
  }

  private final func IsRegistered(runner: ref<Entity>) -> Bool {
    if ArrayContains(this.m_runners, runner) {
      return true;
    };
    return false;
  }

  private final func OnRegisterPoliceCaller(request: ref<RegisterPoliceCaller>) -> Void {
    if !this.m_callInAction || this.IsCallerCloser(request.caller, request.crimePosition) {
      this.m_callInAction = true;
      this.m_policeCaller = request.caller;
    };
  }

  private final func OnUnregisterPoliceCaller(request: ref<UnregisterPoliceCaller>) -> Void {
    this.m_callInAction = false;
    this.m_policeCaller = null;
  }

  private final func IsCallerCloser(newCaller: ref<Entity>, crimePosition: Vector4) -> Bool {
    let callerDistance: Float = Vector4.DistanceSquared(this.m_policeCaller.GetWorldPosition(), crimePosition);
    let newCallerDistance: Float = Vector4.DistanceSquared(newCaller.GetWorldPosition(), crimePosition);
    if newCallerDistance != 0.00 && newCallerDistance < callerDistance {
      return true;
    };
    return false;
  }

  public final const func IsCaller(entity: ref<Entity>) -> Bool {
    return entity == this.m_policeCaller;
  }
}
