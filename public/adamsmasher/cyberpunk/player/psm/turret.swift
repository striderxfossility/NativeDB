
public abstract class TurretTransition extends DefaultTransition {

  protected func EnterWorkspot(game: GameInstance, turret: ref<GameObject>, activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt deviceData: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem>;
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).GetLocalInstanced(activator.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    workspotSystem = GameInstance.GetWorkspotSystem(game);
    workspotSystem.PlayInDevice(turret, activator, n"lockedCamera", componentName, deviceData, 0.50, WorkspotSlidingBehaviour.DontPlayAtResourcePosition);
  }

  protected final const func GetTurretEquippedWeapon(const initData: ref<TurretInitData>) -> ref<WeaponObject> {
    let turret: ref<SecurityTurret> = initData.turret as SecurityTurret;
    let weapon: wref<WeaponObject> = turret.GetTurretWeapon();
    return weapon;
  }
}

public class TurretBeginEvents extends TurretTransition {

  public const let stateMachineInitData: wref<TurretInitData>;

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let triggerSide: EDoorTriggerSide;
    let turret: ref<SecurityTurret> = this.stateMachineInitData.turret as SecurityTurret;
    if IsDefined(turret) {
      triggerSide = turret.GetRipOffTriggerSide(scriptInterface.executionOwner);
      if Equals(triggerSide, EDoorTriggerSide.TWO) {
        this.EnterWorkspot(scriptInterface.executionOwner.GetGame(), this.stateMachineInitData.turret, scriptInterface.executionOwner, false, n"playerDetachWorkspot", n"deviceWorkspot");
      } else {
        this.EnterWorkspot(scriptInterface.executionOwner.GetGame(), this.stateMachineInitData.turret, scriptInterface.executionOwner, false, n"playerDetachWorkspotBack", n"deviceDetachWorkspotBack");
      };
    };
  }
}

public class TurretBeginDecisions extends TurretTransition {

  public final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > this.GetStaticFloatParameterDefault("durationTime", 3.00);
  }
}

public class TurretRipOffEvents extends TurretTransition {

  public const let stateMachineInitData: wref<TurretInitData>;

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    transactionSystem.TransferItem(this.stateMachineInitData.turret as SecurityTurret, scriptInterface.executionOwner as PlayerPuppet, this.GetTurretEquippedWeapon(this.stateMachineInitData).GetItemID(), 1);
    this.SendDrawItemRequest(scriptInterface, this.GetTurretEquippedWeapon(this.stateMachineInitData).GetItemID());
  }
}

public class TurretEndEvents extends TurretTransition {

  public final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let stateMachineIdentifier: StateMachineIdentifier;
    stateMachineIdentifier.definitionName = n"Turret";
    let removeEvent: ref<PSMRemoveOnDemandStateMachine> = new PSMRemoveOnDemandStateMachine();
    removeEvent.stateMachineIdentifier = stateMachineIdentifier;
    scriptInterface.executionOwner.QueueEvent(removeEvent);
  }
}
